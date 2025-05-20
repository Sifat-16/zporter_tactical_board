import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game_animation.dart';

GlobalKey<RiverpodAwareGameWidgetState> animationWidgetKey =
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

  bool _isCurrentlyPlaying = true;

  double _currentUiPaceFactor = 1.0; // Initial pace for UI display
  final double _paceStep = 0.25;
  final double _minPace = 0.25;
  final double _maxPace = 3.0;

  @override
  void initState() {
    super.initState();
    zlog(
      data:
          "AnimationScreen initState: Creating TacticBoardGameAnimation instance.",
    );

    tacticBoardGame = TacticBoardGameAnimation(
      animationModel: widget.animationModel,
      autoPlay: true,
    );

    _currentUiPaceFactor = 1.0;
  }

  final closeButtonColor = Colors.grey[300];
  final closeButtonBackgroundColor = Colors.black.withOpacity(0.4);
  final controlButtonColor = Colors.white;
  final controlButtonBackgroundColor = Colors.black.withOpacity(0.6);

  void _togglePlayPause() async {
    if (!mounted) return; // Check if widget is still in the tree

    if (_isCurrentlyPlaying) {
      tacticBoardGame.pauseAnimation();
      zlog(data: "UI: Pause button pressed.");
    } else {
      // playAnimation calls performStartAnimationFromBeginning if animation was stopped/reset
      // which will clear the _wasHardResetRecently flag and start the animation.
      await tacticBoardGame.playAnimation();
      zlog(data: "UI: Play button pressed.");
    }
    if (mounted) {
      setState(() {
        _isCurrentlyPlaying = !_isCurrentlyPlaying;
      });
    }
  }

  void _handleHardReset() {
    zlog(data: "UI: Hard Reset button pressed. Calling game.resetAnimation()");

    // Call the hard reset method on the *existing* game instance
    // This will use the performHardResetAnimation() logic inside your game class.
    tacticBoardGame.pauseAnimation();

    if (mounted) {
      setState(() {
        // After a hard reset, the animation is stopped and at the beginning.
        // The UI should reflect that it's ready to be played (showing "Play" icon).
        animationWidgetKey = GlobalKey<RiverpodAwareGameWidgetState>();
        tacticBoardGame = TacticBoardGameAnimation(
          animationModel: widget.animationModel,
          autoPlay: false,
        );
        _isCurrentlyPlaying = false;
      });
    }
  }

  void _increaseSpeed() {
    if (!mounted) return;
    double newPace = _currentUiPaceFactor + _paceStep;
    if (newPace > _maxPace) newPace = _maxPace;
    _setNewPace(newPace);
  }

  void _decreaseSpeed() {
    if (!mounted) return;
    double newPace = _currentUiPaceFactor - _paceStep;
    if (newPace < _minPace) newPace = _minPace;
    _setNewPace(newPace);
  }

  void _setNewPace(double newPace) {
    if (_currentUiPaceFactor == newPace) return;
    if (!mounted) return;

    tacticBoardGame.setAnimationPace(newPace);
    if (mounted) {
      setState(() {
        _currentUiPaceFactor = newPace;
      });
    }
    zlog(data: "UI: Pace factor set to $_currentUiPaceFactor");
  }

  @override
  Widget build(BuildContext context) {
    zlog(
      data:
          "AnimationScreen: build method called. _isCurrentlyPlaying: $_isCurrentlyPlaying",
    );
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
                // Close Button
                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      splashColor: Colors.white12,
                      onTap: () {
                        // Optional: tacticBoardGame.stopAnimation();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
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
                // Control Buttons
                Positioned(
                  bottom: 0.0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: controlButtonBackgroundColor,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Decrease Speed Button
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: _decreaseSpeed,
                              splashColor: Colors.white24,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: controlButtonColor,
                                  // size: 28.0,
                                ),
                              ),
                            ),
                          ),
                          // Speed Display
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              // Show integer if whole number, else 2 decimal places
                              _currentUiPaceFactor ==
                                      _currentUiPaceFactor.truncateToDouble()
                                  ? "${_currentUiPaceFactor.toInt()}x"
                                  : "${_currentUiPaceFactor.toStringAsFixed(2)}x",
                              style: TextStyle(
                                color: controlButtonColor,
                                // fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Increase Speed Button
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: _increaseSpeed,
                              splashColor: Colors.white24,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: controlButtonColor,
                                  // size: 28.0,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 20), // Wider Spacer
                          // Play/Pause Button
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: _togglePlayPause,
                              splashColor: Colors.white24,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  _isCurrentlyPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: controlButtonColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20), // Wider Spacer
                          // Restart Button (Hard Reset)
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: _handleHardReset,
                              splashColor: Colors.white24,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.replay_rounded,
                                  color: controlButtonColor,
                                ),
                              ),
                            ),
                          ),
                        ],
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
