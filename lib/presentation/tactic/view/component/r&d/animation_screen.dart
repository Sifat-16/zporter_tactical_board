import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game_animation.dart';

final GlobalKey<RiverpodAwareGameWidgetState> animationWidgetKey =
    GlobalKey<RiverpodAwareGameWidgetState>();

class AnimationScreen extends ConsumerStatefulWidget {
  const AnimationScreen({
    super.key,
    required this.animationModel,
    required this.heroTag,
  });

  final AnimationModel animationModel;
  final Object heroTag;

  @override
  ConsumerState<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends ConsumerState<AnimationScreen> {
  late TacticBoardGameAnimation tacticBoardGame;
  @override
  void initState() {
    zlog(data: "Animation screen rendering");
    // TODO: implement initState
    super.initState();
    tacticBoardGame = TacticBoardGameAnimation(
      animationModel: widget.animationModel,
    );
  }

  final closeButtonColor = Colors.grey[300]; // Lighter grey for icon
  final closeButtonBackgroundColor = Colors.black.withOpacity(0.4);

  @override
  Widget build(BuildContext context) {
    zlog(data: "Came here for animation showing ");
    return Scaffold(
      backgroundColor: ColorManager.black,
      body: SafeArea(
        child: Center(
          child: Hero(
            tag: widget.heroTag,
            child: Stack(
              children: [
                Center(
                  child: RiverpodAwareGameWidget(
                    game: tacticBoardGame,
                    key: animationWidgetKey,
                  ),
                ),

                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: Material(
                    // Use Material for ink splash on tap
                    color: Colors.black,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      // InkWell provides splash
                      splashColor: Colors.white12,
                      onTap: () {
                        Navigator.pop(context);
                      }, // Call the close callback
                      child: Container(
                        padding: const EdgeInsets.all(
                          4,
                        ), // Padding around the icon
                        decoration: BoxDecoration(
                          color: closeButtonBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: closeButtonColor,
                          size: 26.0,
                        ),
                      ),
                    ),
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
