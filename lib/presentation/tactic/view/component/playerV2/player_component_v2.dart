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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _setFocus(!_isFocused),
      child: Draggable<PlayerModel>(
        data: widget.playerModel,
        rootOverlay: true,

        onDragStarted: () {
          _setFocus(true);
          ref
              .read(boardProvider.notifier)
              .updateDraggingToBoard(isDragging: true);
        },
        hitTestBehavior: HitTestBehavior.translucent,
        onDragEnd: (DraggableDetails details) {
          _setFocus(false);
          zlog(
            data:
                "Drag ended overlay ${details.wasAccepted} - ${details.offset}",
          );
        },
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: _buildPlayerComponent(),
        ),
        feedback: Material(
          color: Colors.transparent,
          child: _buildPlayerComponent(),
        ),
        child: _buildPlayerComponent(),
      ),
    );
  }

  Widget _buildPlayerComponent() {
    return RepaintBoundary(
      key: UniqueKey(),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(AppSize.s8),
          decoration: BoxDecoration(
            color:
                widget.playerModel.playerType == PlayerType.HOME
                    ? ColorManager.blueAccent
                    : ColorManager.red,
            borderRadius: BorderRadius.circular(AppSize.s4),
            // border: _isFocused
            //     ? Border.all(color: Colors.yellow, width: 3)
            //     : null, // Add border if focused
          ),
          child: SizedBox(
            height: AppSize.s32,
            width: AppSize.s32,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    widget.playerModel.role,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: ColorManager.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    "${widget.playerModel.index}",
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall!.copyWith(color: ColorManager.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
