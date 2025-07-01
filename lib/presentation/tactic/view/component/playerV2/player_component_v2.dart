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

  bool containsPlayerImage(String? imagePath) {
    if (imagePath == null) return false;
    return File(imagePath).existsSync();
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
    // --- MODIFIED: Check imageBase64 instead of file path ---
    final imageBase64 = widget.playerModel.imageBase64;
    final hasImage = imageBase64 != null && imageBase64.isNotEmpty;

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
                image: MemoryImage(base64Decode(imageBase64)),
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
          if (!hasImage)
            Center(
              child: Text(
                widget.playerModel.role,
                style: roleTextStyle,
                overflow: TextOverflow.clip,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          if (widget.playerModel.jerseyNumber > 0 && !isDragging)
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 3.5, vertical: 1),
                child: Text(
                  "${widget.playerModel.jerseyNumber}",
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
    if (playerName.isEmpty) {
      // Return a small sized box to maintain layout stability.
      return SizedBox(height: style.fontSize);
    }

    // // The complex _getBestFitName function has been removed.
    // // We now directly format the name for two-line display.
    // String textToRender = playerName;
    // if (playerName.contains(' ')) {
    //   textToRender = playerName.replaceFirst(' ', '\n');
    // }

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
      // width: maxWidth,
      // child: Text(
      //   textToRender,
      //   textScaler: TextScaler.linear(0.7),
      //   style: style,
      //   textAlign: TextAlign.start, // Center align the name block
      //   overflow: TextOverflow.ellipsis,
      //   // Allow up to 2 lines for the name
      //   maxLines: 2,
      // ),

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
