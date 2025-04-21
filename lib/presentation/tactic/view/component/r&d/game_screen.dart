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

final GlobalKey<RiverpodAwareGameWidgetState> gameWidgetKey =
    GlobalKey<RiverpodAwareGameWidgetState>();

final GlobalKey<RiverpodAwareGameWidgetState> largeGameWidgetKey =
    GlobalKey<RiverpodAwareGameWidgetState>();

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
        boardComparator = null;
        tacticBoardGame = TacticBoard(scene: selectedScene);
        zlog(data: "Build new tactic board");
        ref.read(boardProvider.notifier).updateGameBoard(tacticBoardGame);
        ref
            .read(boardProvider.notifier)
            .updateBoardColor(
              ref.read(animationProvider.notifier).getFieldColor(),
            );
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
    ref.listen(boardProvider, (prev, current) {
      if (prev?.showFullScreen != current.showFullScreen) {
        tacticBoardGame.redrawLines();
      }
    });
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

        Vector2 transformedOffset;
        if (quarterTurns == 1) {
          transformedOffset = Vector2(dy, gameScreenWidth - dx);
        } else {
          transformedOffset = screenRelativeOffset; // Use the original offset
        }

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
                    children: [
                      FormSpeedDialComponent(tacticBoardGame: tacticBoardGame),
                    ],
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
