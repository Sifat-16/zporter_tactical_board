import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/tactic_board_game_animation.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_bloc.dart';

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> {
  late TacticBoardGameAnimation tacticBoardGame;
  @override
  void initState() {
    zlog(data: "Animation screen rendering");
    // TODO: implement initState
    super.initState();
    tacticBoardGame = TacticBoardGameAnimation(
      boardBloc: context.read<BoardBloc>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: tacticBoardGame);
  }
}
