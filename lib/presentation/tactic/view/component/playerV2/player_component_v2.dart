import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tutorials/tutorial_events.dart';
import 'package:zporter_tactical_board/presentation/tutorials/tutorial_keys.dart';

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
        if (widget.key == TutorialKeys.firstPlayerKey) {
          zlog(
            data:
                "PlayerComponentV2: Tutorial drag interaction started for the tutored player. Firing event.",
          );
          TutorialEvents.firePlayerTutorialDragInteractionStarted(
            TutorialKeys.firstPlayerKey,
          );
        }
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
        TutorialEvents.firePlayerSuccessfullyDraggedToField(
          // If you can identify if it was TutorialKeys.firstPlayerKey, that's even better.
          // For now, let's assume any successful drag after the tutorial step starts is fine.
          // playerKey: /* key of the dragged player if available */
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
        child: SizedBox(
          // Explicitly constrain the size
          width: AppSize.s32,
          height: AppSize.s32,
          child: _buildPlayerComponent(),
        ),
      ),
    );
  }

  // _buildPlayerComponent remains unchanged - it *already* returns a Container
  // with the correct height/width. The SizedBox wrapper outside is belts-and-braces.
  Widget _buildPlayerComponent({bool isDragging = false}) {
    final theme = Theme.of(context);
    final roleTextStyle =
        theme.textTheme.labelLarge?.copyWith(
          color: ColorManager.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ) ??
        const TextStyle(
          color: ColorManager.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        );

    final indexTextStyle =
        theme.textTheme.labelSmall?.copyWith(
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
        color: (widget.playerModel.color ?? ColorManager.grey).withValues(
          alpha: widget.playerModel.opacity ?? 1.0,
        ),
        borderRadius: BorderRadius.circular(AppSize.s4),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
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
