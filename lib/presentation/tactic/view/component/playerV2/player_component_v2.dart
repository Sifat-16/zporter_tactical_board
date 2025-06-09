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
      // hapticFeedbackOnStart: true,
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

      // Feedback: Center should still be okay here as it renders in the overlay
      feedback: Material(
        color: Colors.transparent,
        child: Center(
          // SizedBox ensures feedback has the correct size
          child: SizedBox(
            width: AppSize.s32,
            height: AppSize.s32,
            child: _buildPlayerComponent(isDragging: true),
          ),
        ),
      ),

      // --- Child When Dragging: Center -> SizedBox -> Component ---
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: Center(
          // Center the SizedBox within the parent's constraints (e.g., grid cell)
          child: SizedBox(
            // Explicitly constrain the size
            width: AppSize.s32,
            height: AppSize.s32,
            child:
                _buildPlayerComponent(), // This already returns a sized container, but SizedBox reinforces it
          ),
        ),
      ),

      // --- Main Child: Center -> SizedBox -> Component ---
      child: Center(
        // Center the SizedBox within the parent's constraints
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              // Explicitly constrain the size
              width: AppSize.s32,
              height: AppSize.s32,
              child: _buildPlayerComponent(),
            ),
            _FittedPlayerName(
              name: widget.playerModel.name,
              maxWidth: AppSize.s32,
            ),
          ],
        ),
      ),
    );
  }

  // _buildPlayerComponent remains unchanged - it *already* returns a Container
  // with the correct height/width. The SizedBox wrapper outside is belts-and-braces.
  Widget _buildPlayerComponent({bool isDragging = false}) {
    final theme = Theme.of(context);
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

    // The actual visual component with fixed size
    return Container(
      key: ValueKey(
        "player_${widget.playerModel.id}",
      ), // Consider adding a key based on ID
      decoration: BoxDecoration(
        color: containsPlayerImage(widget.playerModel.imagePath)
            ? null
            : (widget.playerModel.color ?? ColorManager.grey).withValues(
                alpha: widget.playerModel.opacity ?? 1.0,
              ),
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
          if (containsPlayerImage(widget.playerModel.imagePath))
            Image.file(File(widget.playerModel.imagePath!))
          else
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 3.5,
                  vertical: 1,
                ),
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

class _FittedPlayerName extends StatelessWidget {
  const _FittedPlayerName({
    this.name,
    required this.maxWidth,
  });

  final String? name;
  final double maxWidth;

  /// Determines the best string format that fits within the [maxWidth].
  ///
  /// This function checks name formats in a specific order of priority:
  /// 1. Full Name ("John Doe")
  /// 2. Last Name Only ("Doe")
  /// 3. First Initial + Last Name ("J. Doe")
  /// If none of the above fit, it returns the full name to be truncated
  /// with an ellipsis by the Text widget.
  String _getBestFitName(String name, double width, TextStyle style) {
    // If there's no name, return an empty string.
    if (name.trim().isEmpty) return '';

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    // Helper function to check if a given string fits in the available width.
    bool doesFit(String text) {
      textPainter.text = TextSpan(text: text, style: style);
      textPainter.layout();
      return textPainter.width <= width;
    }

    // --- Priority 1: Try the full name ---
    if (doesFit(name)) {
      return name;
    }

    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();

    // --- Priority 2: Try Last Name Only (if more than one name part exists) ---
    if (parts.length > 1) {
      final lastName = parts.last;
      if (doesFit(lastName)) {
        return lastName;
      }
    }

    // --- Priority 3: Try First Initial + Last Name ---
    if (parts.length > 1) {
      final firstInitial = parts.first[0];
      final lastName = parts.last;
      final abbreviatedName = '$firstInitial. $lastName';
      if (doesFit(abbreviatedName)) {
        return abbreviatedName;
      }
    }
    // --- Fallback: Return the full name and let the Text widget truncate it ---
    // This is often better than returning just a first name or initials.
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .labelSmall!
        .copyWith(color: ColorManager.white);

    // Get the best possible name format that fits.
    final bestName = _getBestFitName(name ?? '', maxWidth, style);

    // If the resulting name is empty, return a sized box to maintain layout stability.
    if (bestName.isEmpty) {
      return SizedBox(height: style.fontSize);
    }

    return SizedBox(
      width: maxWidth,
      child: Text(
        bestName,
        textScaler: TextScaler.linear(0.7),
        style: style,
        textAlign: TextAlign.left,
        // Use ellipsis as a final fallback if even the best format overflows slightly.
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
