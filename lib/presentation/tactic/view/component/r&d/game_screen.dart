import 'package:flame/extensions.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/form_speed_dial_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.scene});
  final AnimationItemModel? scene;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late TacticBoard tacticBoardGame;
  bool gameInitialized = false;
  int previousAngle = 0;
  final GlobalKey<RiverpodAwareGameWidgetState> gameWidgetKey =
      GlobalKey<RiverpodAwareGameWidgetState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateTacticBoardIfNecessary(widget.scene);
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene?.id == widget.scene?.id) {
      WidgetsBinding.instance.addPostFrameCallback((t) {
        if (ref.read(animationProvider).isPerformingUndo == true) {
          updateTacticBoardIfNecessary(widget.scene);
          ref.read(animationProvider.notifier).toggleUndo(undo: false);
        }
      });
    } else {
      updateTacticBoardIfNecessary(widget.scene);
    }
  }

  updateTacticBoardIfNecessary(AnimationItemModel? selectedScene) {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      setState(() {
        tacticBoardGame = TacticBoard(scene: selectedScene);
        zlog(data: "Build new tactic board");
        ref.read(boardProvider.notifier).updateGameBoard(tacticBoardGame);
        gameInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    final lp = ref.watch(lineProvider);
    int quarterTurns = bp.boardAngle;
    if (quarterTurns != previousAngle) {
      updateTacticBoardIfNecessary(widget.scene);
    }
    previousAngle = quarterTurns;
    return DragTarget<FieldItemModel>(
      onAcceptWithDetails: (DragTargetDetails<FieldItemModel> dragDetails) {
        if (!gameInitialized) return; // Ensure game is ready

        FieldItemModel fieldItemModel = dragDetails.data;
        final RenderBox gameScreenBox = context.findRenderObject() as RenderBox;

        // --- Essential: Get the size of the widget BEFORE rotation ---
        final Vector2 gameScreenSize = gameScreenBox.size.toVector2();
        final double gameScreenWidth = gameScreenSize.x;
        // final double gameScreenHeight = gameScreenSize.height; // Needed for turns 2, 3

        // 1. Calculate offset relative to the GameScreen's top-left (in SCREEN orientation)
        final Offset globalGameScreenOffset = gameScreenBox.localToGlobal(
          Offset.zero,
        );
        final Vector2 screenRelativeOffset =
            dragDetails.offset.toVector2() - globalGameScreenOffset.toVector2();
        final double dx =
            screenRelativeOffset
                .x; // Horizontal distance from left in screen coords
        final double dy =
            screenRelativeOffset
                .y; // Vertical distance from top in screen coords

        // --- Define the rotation state (should match your RotatedBox) ---

        // 2. Transform the offset based ONLY on RotatedBox's quarterTurns
        Vector2 transformedOffset;
        if (quarterTurns == 1) {
          // Apply the 90-degree clockwise transformation rule:
          // New X is original Y
          // New Y is original Width minus original X
          transformedOffset = Vector2(dy, gameScreenWidth - dx);
        }
        // --- Add cases for other rotations if needed ---
        // else if (quarterTurns == 2) { // 180 degrees
        //   transformedOffset = Vector2(gameScreenWidth - dx, gameScreenHeight - dy);
        // } else if (quarterTurns == 3) { // 270 degrees clockwise
        //   transformedOffset = Vector2(gameScreenHeight - dy, dx);
        // }
        else {
          // Default: No rotation (quarterTurns == 0 or 4)
          transformedOffset = screenRelativeOffset; // Use the original offset
        }

        // --- Logging for Debugging ---

        // -----------------------------

        // 3. Assign the final offset in the game's coordinate system
        //    We use the transformed offset, and keep your gameField.position addition for now.

        Vector2 actualPosition =
            transformedOffset + tacticBoardGame.gameField.position;

        fieldItemModel.offset = SizeHelper.getBoardRelativeVector(
          gameScreenSize: gameScreenSize,
          actualPosition: actualPosition,
        );

        tacticBoardGame.addItem(fieldItemModel);
      },
      builder: (
        BuildContext context,
        List<Object?> candidateData,
        List<dynamic> rejectedData,
      ) {
        if (!gameInitialized) {
          return Center(
            child: Text(
              "Field is not initialized. Contact developer!!",
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: ColorManager.white),
            ),
          );
        }
        return RotatedBox(
          quarterTurns: quarterTurns,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 0),
                child: RiverpodAwareGameWidget(
                  game: tacticBoardGame,
                  key: gameWidgetKey,
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 30,
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [FormSpeedDialComponent()],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LargeGameScreen extends ConsumerStatefulWidget {
  const LargeGameScreen({
    super.key,
    required this.heroTag,
    required this.selectedScene,
  });
  final AnimationItemModel selectedScene;
  final Object heroTag;

  @override
  ConsumerState<LargeGameScreen> createState() => _LargeGameScreenState();
}

class _LargeGameScreenState extends ConsumerState<LargeGameScreen> {
  final closeButtonColor = Colors.grey[300]; // Lighter grey for icon
  final closeButtonBackgroundColor = Colors.black.withOpacity(0.4);

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    return Scaffold(
      backgroundColor: ColorManager.black,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.95,
          heightFactor: 0.95,
          child: Hero(
            tag: widget.heroTag,
            child: Stack(
              children: [
                GameScreen(scene: widget.selectedScene),
                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: Material(
                    // Use Material for ink splash on tap
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      // InkWell provides splash
                      splashColor: Colors.white12,
                      onTap: () {
                        ref.read(animationProvider.notifier).toggleFullScreen();
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

  // _buildGameWidget({required TacticBoardGame tacticBoardGame}) {
  //   final GlobalKey<RiverpodAwareGameWidgetState> gameWidgetKey =
  //       GlobalKey<RiverpodAwareGameWidgetState>();
  //   return Stack(
  //     children: [
  //       Container(
  //         padding: EdgeInsets.only(bottom: 0),
  //         child: RiverpodAwareGameWidget(
  //           game: tacticBoardGame,
  //           key: gameWidgetKey,
  //         ),
  //       ),
  //
  //       Align(
  //         alignment: Alignment.bottomCenter,
  //         child: Container(
  //           height: 30,
  //           padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
  //           decoration: BoxDecoration(),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [FormSpeedDialComponent()],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
