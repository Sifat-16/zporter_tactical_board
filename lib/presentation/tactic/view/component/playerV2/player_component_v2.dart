import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class PlayerComponentV2 extends ConsumerStatefulWidget {
  const PlayerComponentV2({
    super.key,
    required this.playerModel,
    this.activateFocus = false,
  });

  final PlayerModel playerModel;
  final bool activateFocus;

  @override
  ConsumerState<PlayerComponentV2> createState() => _PlayerComponentV2State();
}

class _PlayerComponentV2State extends ConsumerState<PlayerComponentV2> {
  bool _isFocused = false;

  void _setFocus(bool focus) {
    setState(() {
      _isFocused = focus;
    });
  }

  // Replace the old 'containsPlayerImage' method with this new helper function:
  ImageProvider? _getImageProvider() {
    final model = widget.playerModel;

    // Priority 1: Check for Base64 (for any old data)
    if (model.imageBase64 != null && model.imageBase64!.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(model.imageBase64!));
      } catch (e) {
        zlog(data: "Failed to decode base64 in PlayerComponentV2: $e");
        // Fall through to check imagePath
      }
    }

    // Priority 2: Check imagePath (which can be a Network URL or Local File Path)
    if (model.imagePath != null && model.imagePath!.isNotEmpty) {
      // Check if it's a network URL
      if (model.imagePath!.startsWith('http')) {
        return NetworkImage(model.imagePath!);
      }
      // Check if it's a local file path
      else {
        // Note: FileImage will throw an error if the file doesn't exist,
        // but this is the expected behavior. Our logic *should* be creating valid files.
        return FileImage(File(model.imagePath!));
      }
    }

    // No image source found
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<PlayerModel>(
      data: widget.playerModel.clone(),
      rootOverlay: true,
      onDragStarted: () {
        ref
            .read(boardProvider.notifier)
            .updateDraggingToBoard(isDragging: true);
      },
      hitTestBehavior: HitTestBehavior.deferToChild,
      onDragEnd: (DraggableDetails details) {
        ref
            .read(boardProvider.notifier)
            .updateDraggingToBoard(isDragging: false);
        zlog(
          data:
              "Drag ended: accepted=${details.wasAccepted}, offset=${details.offset}",
        );
      },
      feedback: Material(
        color: Colors.transparent,
        child: Center(
          child: SizedBox(
            width: AppSize.s32,
            height: AppSize.s32,
            child: _buildPlayerComponent(isDragging: true),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: Center(
          child: SizedBox(
            width: AppSize.s32,
            height: AppSize.s32,
            child: _buildPlayerComponent(),
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: AppSize.s32,
              height: AppSize.s32,
              child: _buildPlayerComponent(),
            ),
            // This now uses the updated _FittedPlayerName
            _FittedPlayerName(
              name: widget.playerModel.name,
              maxWidth: AppSize.s32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerComponent({bool isDragging = false}) {
    final theme = Theme.of(context);

    // --- THIS IS THE NEW LOGIC ---
    final ImageProvider? imageProvider = _getImageProvider();
    final bool hasImage = imageProvider != null;
    // --- END NEW LOGIC ---

    final roleTextStyle = theme.textTheme.labelLarge?.copyWith(
          color: ColorManager.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ) ??
        const TextStyle(
          color: ColorManager.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        );

    final indexTextStyle = theme.textTheme.labelSmall?.copyWith(
          color: ColorManager.white,
          fontSize: 10,
        ) ??
        const TextStyle(color: ColorManager.white, fontSize: 9);

    return Container(
      key: ValueKey("player_${widget.playerModel.id}"),
      decoration: BoxDecoration(
        image: hasImage
            ? DecorationImage(
                // --- MODIFIED: Use MemoryImage with base64Decode ---
                image: imageProvider,
                fit: BoxFit.cover,
              )
            : null,
        color: hasImage
            ? null
            : (widget.playerModel.color ?? ColorManager.grey)
                .withValues(alpha: widget.playerModel.opacity ?? 1.0),
        borderRadius: BorderRadius.circular(AppSize.s4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Only show role if there's no image AND role is not "-" (neutral)
          if (!hasImage && widget.playerModel.role != '-')
            Center(
              child: Text(
                widget.playerModel.role,
                style: roleTextStyle,
                overflow: TextOverflow.clip,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),

          // Only show number if it's greater than 0 (not -1 for neutral) and not dragging
          if ((widget.playerModel.displayNumber ??
                      widget.playerModel.jerseyNumber) >
                  0 &&
              !isDragging)
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 3.5, vertical: 1),
                child: Text(
                  // Prioritize displayNumber, fall back to jerseyNumber
                  "${widget.playerModel.displayNumber ?? widget.playerModel.jerseyNumber}",
                  style: indexTextStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- MODIFIED WIDGET ---
class _FittedPlayerName extends StatelessWidget {
  const _FittedPlayerName({
    this.name,
    required this.maxWidth,
  });

  final String? name;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .labelSmall!
        .copyWith(color: ColorManager.white);

    final playerName = name ?? '';
    // Hide name if empty or if it's "-" (neutral)
    if (playerName.isEmpty || playerName == '-') {
      // Return a small sized box to maintain layout stability.
      return SizedBox(height: style.fontSize);
    }

    // --- START: MODIFIED NAME LOGIC ---
    // Requirement 3: Truncate names to 9 characters.
    String truncate(String s) => s.length > 9 ? s.substring(0, 9) : s;

    final parts =
        playerName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    String textToRender;

    if (parts.length > 1) {
      final firstName = truncate(parts.first);
      // Join the rest back in case of multiple last/middle names
      final lastName = truncate(parts.sublist(1).join(' '));
      textToRender = '$firstName\n$lastName';
    } else {
      textToRender = truncate(playerName);
    }
    // --- END: MODIFIED NAME LOGIC ---

    return SizedBox(
      width: maxWidth * 1.5,
      child: Text(
        textToRender,
        textScaler: TextScaler.linear(0.7),
        style: style,
        // Requirement 1: Centralize the text
        textAlign: TextAlign.center,
        // Requirement 2: Take away ellipsis by removing the 'overflow' property
        maxLines: 2, // Allow up to 2 lines for first and last name
      ),
    );
  }
}
