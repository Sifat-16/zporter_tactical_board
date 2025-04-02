import 'package:flame/extensions.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';

final GlobalKey<RiverpodAwareGameWidgetState> gameWidgetKey =
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
    if (oldWidget.scene?.id != widget.scene?.id) {
      updateTacticBoardIfNecessary(widget.scene);
    }
  }

  updateTacticBoardIfNecessary(AnimationItemModel? selectedScene) {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      setState(() {
        tacticBoardGame = TacticBoard(scene: selectedScene);
        gameInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<FieldItemModel>(
      onAcceptWithDetails: (DragTargetDetails<FieldItemModel> dragDetails) {
        FieldItemModel fieldItemModel = dragDetails.data;
        // Dynamically adjust for GameScreen position
        final RenderBox gameScreenBox = context.findRenderObject() as RenderBox;
        final Offset gameScreenOffset = gameScreenBox.localToGlobal(
          Offset.zero,
        );
        Vector2 adjustedOffset =
            dragDetails.offset.toVector2() - gameScreenOffset.toVector2();
        fieldItemModel.offset =
            adjustedOffset + tacticBoardGame.gameField.position;
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
        return RiverpodAwareGameWidget(
          game: tacticBoardGame,
          key: gameWidgetKey,
        );
      },
    );
  }
}
