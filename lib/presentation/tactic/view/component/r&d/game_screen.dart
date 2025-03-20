import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/tactic_board_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  TacticBoardGame tacticBoardGame = TacticBoardGame();

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
        return GameWidget(game: tacticBoardGame);
      },
    );
  }
}
