import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_model_v2.dart';
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
    return DragTarget<PlayerModelV2>(
      onAcceptWithDetails: (DragTargetDetails<PlayerModelV2> dragDetails) {
        PlayerModelV2 playerModelV2 = dragDetails.data;
        playerModelV2.offset = dragDetails.offset;
        tacticBoardGame.addPlayer(playerModelV2);
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
