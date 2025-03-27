import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/tactic_board_game_animation.dart';

final GlobalKey<RiverpodAwareGameWidgetState> animationWidgetKey =
    GlobalKey<RiverpodAwareGameWidgetState>();

class AnimationScreen extends ConsumerStatefulWidget {
  const AnimationScreen({super.key});

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
    tacticBoardGame = TacticBoardGameAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return RiverpodAwareGameWidget(
      game: tacticBoardGame,
      key: animationWidgetKey,
    );
  }
}
