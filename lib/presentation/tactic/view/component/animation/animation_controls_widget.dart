import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart'; // Assuming this path
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Assuming this path
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/mixin/animation_playback_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';

class PaceSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final String currentPaceText;
  final Color textColor;
  final double fontSize;

  const PaceSliderThumbShape({
    required this.enabledThumbRadius,
    required this.currentPaceText,
    this.textColor = Colors.black,
    this.fontSize = 10.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, enabledThumbRadius, paint);

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      text: currentPaceText,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: textDirection,
    );
    tp.layout();
    Offset textCenter = Offset(
      center.dx - (tp.width / 2),
      center.dy - (tp.height / 2),
    );
    tp.paint(canvas, textCenter);
  }
}

class AnimationControlsWidget extends StatefulWidget {
  final AnimationModel animationModel;
  final AnimatingObj animatingObj;
  final TacticBoard game; // Your TacticBoard game instance
  final bool initialIsPlaying;
  final double initialPaceFactor;
  final Function(double)? onExportProgressCallback;

  const AnimationControlsWidget({
    super.key,
    required this.game,
    required this.animatingObj,
    required this.animationModel,
    required this.initialIsPlaying,
    required this.initialPaceFactor,
    this.onExportProgressCallback,
  });

  @override
  State<AnimationControlsWidget> createState() =>
      _AnimationControlsWidgetState();
}

class _AnimationControlsWidgetState extends State<AnimationControlsWidget> {
  late bool _isCurrentlyPlaying;
  late double _currentUiPaceFactor;

  final Color controlButtonColor = Colors.white;
  final Color controlButtonBackgroundColor = Colors.black.withOpacity(0.6);
  final List<double> _paceValues = [0.5, 1.0, 2.0, 4.0, 8.0];

  @override
  void initState() {
    super.initState();
    zlog(
        data:
            "AnimationControlsWidget initState: animatingObj: ${widget.animatingObj}");
    _initializeState();
    _startAnimationConditionally();
  }

  // @override
  // void didUpdateWidget(covariant AnimationControlsWidget oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   bool modelChanged = oldWidget.animationModel.id != widget.animationModel.id;
  //   bool animatingObjChanged = oldWidget.animatingObj != widget.animatingObj;
  //
  //   if (modelChanged || animatingObjChanged) {
  //     zlog(
  //         data:
  //             "AnimationControlsWidget didUpdateWidget: modelChanged: $modelChanged, animatingObjChanged: $animatingObjChanged. New: ${widget.animatingObj}");
  //     widget.game.performStopAnimation(hardReset: animatingObjChanged);
  //     _initializeState();
  //     _startAnimationConditionally();
  //   }
  // }

  void _initializeState() {
    _isCurrentlyPlaying = widget.animatingObj.isExporting ||
        (widget.animatingObj.isAnimating && widget.initialIsPlaying);

    if (_paceValues.contains(widget.initialPaceFactor)) {
      _currentUiPaceFactor = widget.initialPaceFactor;
    } else {
      _currentUiPaceFactor =
          _paceValues.contains(1.0) ? 1.0 : _paceValues.first;
    }
    // Set pace only if not exporting, as export might have a fixed pace or be managed internally by the game.
    if (!widget.animatingObj.isExporting) {
      widget.game.setAnimationPace(_currentUiPaceFactor);
    }
    zlog(
        data:
            "AnimationControlsWidget _initializeState: isPlaying: $_isCurrentlyPlaying, pace: $_currentUiPaceFactor, isExporting: ${widget.animatingObj.isExporting}");
  }

  void _startAnimationConditionally() {
    zlog(
        data:
            "AnimationControlsWidget _startAnimationConditionally: animatingObj: ${widget.animatingObj}, _isCurrentlyPlaying: $_isCurrentlyPlaying");
    if (widget.animatingObj.isExporting) {
      _startAnimation(); // Always start for export
    } else if (widget.animatingObj.isAnimating) {
      _startAnimation(); // Start if isAnimating and _isCurrentlyPlaying is true (or setup initial frame if false)
    }
  }

  void _startAnimation() {
    zlog(
        data:
            "AnimationControlsWidget _startAnimation: isExporting: ${widget.animatingObj.isExporting}, effective play state for game.startAnimation: ${widget.animatingObj.isExporting || _isCurrentlyPlaying}");
    widget.game.startAnimation(
      am: widget.animationModel,
      ap: widget.animatingObj.isExporting ||
          _isCurrentlyPlaying, // Autoplay for export or if _isCurrentlyPlaying
      isForE: widget.animatingObj.isExporting,
      onExportP: widget.animatingObj.isExporting
          ? widget.onExportProgressCallback
          : (progress) {
              if (!widget.animatingObj.isExporting &&
                  widget.animatingObj.isAnimating &&
                  progress >= 1.0) {
                if (mounted) {
                  setState(() {
                    _isCurrentlyPlaying = false;
                  });
                  zlog(
                      data:
                          "AnimationControlsWidget: Normal animation completed, setting _isCurrentlyPlaying to false.");
                }
              }
            },
    );
  }

  void _togglePlayPause() {
    if (widget.animatingObj.isExporting) return;
    if (!mounted) return;

    if (_isCurrentlyPlaying) {
      widget.game.pauseAnimation();
      zlog(data: "AnimationControlsWidget: Pause button pressed.");
    } else {
      // If animation was finished and we press play, it should restart.
      // playAnimation should ideally handle resuming or restarting from beginning if already completed.
      if (widget.game.isAnimationCurrentlyPlaying ||
          widget.game.isAnimationCurrentlyPaused) {
        widget.game.playAnimation(); // Resume
      } else {
        // Animation was likely stopped or completed, restart.
        // Re-initialize state for play and start.
        _isCurrentlyPlaying =
            true; // Set desired state before calling _startAnimation
        _startAnimation();
      }
      zlog(data: "AnimationControlsWidget: Play button pressed.");
    }
    if (mounted) {
      // Ensure state reflects action, especially if playAnimation() is async or complex
      // For pause, it's immediate. For play, it might depend on game.playAnimation behavior.
      // If playAnimation ensures it's playing, then this setState is correct.
      setState(() {
        if (!widget.game.isAnimationCurrentlyPlaying &&
            !widget.game.isAnimationCurrentlyPaused &&
            !_isCurrentlyPlaying) {
          // If we tried to play but it didn't start (e.g. no scenes), don't set to playing
        } else {
          _isCurrentlyPlaying = !_isCurrentlyPlaying;
        }
      });
    }
  }

  void _handleHardReset() {
    if (widget.animatingObj.isExporting) return;
    zlog(data: "ControlsWidget: Hard Reset button pressed.");

    widget.game
        .pauseAnimation(); // Ensure it's paused before resetting UI state

    if (mounted) {
      setState(() {
        _isCurrentlyPlaying = false;
        _currentUiPaceFactor =
            _paceValues.contains(1.0) ? 1.0 : _paceValues.first;
      });
    }
    widget.game.setAnimationPace(_currentUiPaceFactor);
    widget.game.resetAnimation(); // This should set up the first frame, paused.
    // After resetAnimation, the game is at frame 0, paused. UI reflects this.
  }

  void _increaseSpeed() {
    if (widget.animatingObj.isExporting ||
        !_paceValues.contains(_currentUiPaceFactor)) return;
    if (!mounted) return;
    int currentIndex = _paceValues.indexOf(_currentUiPaceFactor);
    if (currentIndex < _paceValues.length - 1) {
      _setNewPace(_paceValues[currentIndex + 1]);
    }
  }

  void _decreaseSpeed() {
    if (widget.animatingObj.isExporting ||
        !_paceValues.contains(_currentUiPaceFactor)) return;
    if (!mounted) return;
    int currentIndex = _paceValues.indexOf(_currentUiPaceFactor);
    if (currentIndex > 0) {
      _setNewPace(_paceValues[currentIndex - 1]);
    }
  }

  void _setNewPace(double newPace) {
    if (widget.animatingObj.isExporting) return;
    if (!_paceValues.contains(newPace)) {
      zlog(
          data:
              "ControlsWidget: Attempted to set invalid pace $newPace. Ignoring.");
      return;
    }
    if (_currentUiPaceFactor == newPace) return;
    if (!mounted) return;

    widget.game.setAnimationPace(newPace);
    if (mounted) {
      setState(() {
        _currentUiPaceFactor = newPace;
      });
    }
    zlog(data: "ControlsWidget: Pace factor set to $_currentUiPaceFactor");
  }

  @override
  Widget build(BuildContext context) {
    // This UI will be Offstage during export, so it won't be visible.
    // The logic in initState/didUpdateWidget handles starting the export.
    String formattedPaceText = _paceValues.contains(_currentUiPaceFactor)
        ? "${_currentUiPaceFactor.toStringAsFixed(_currentUiPaceFactor % 1 == 0 ? 0 : 1)}x"
        : "1x";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
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
          Material(
            /* ... Play/Pause Button ... */
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _togglePlayPause,
              splashColor: Colors.white24,
              child: Icon(
                _isCurrentlyPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: controlButtonColor,
                size: 28.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            /* ... Decrease Speed Button ... */
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _decreaseSpeed,
              splashColor: Colors.white24,
              child: Icon(
                Icons.remove_circle_outline_rounded,
                color: controlButtonColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            /* ... Slider ... */
            width: 150.0,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: controlButtonColor,
                inactiveTrackColor: controlButtonColor.withOpacity(0.3),
                trackHeight: 2.0,
                thumbColor: controlButtonColor,
                thumbShape: PaceSliderThumbShape(
                  enabledThumbRadius: 14.0,
                  currentPaceText: formattedPaceText,
                  textColor: ColorManager.black,
                  fontSize: 10.0,
                ),
                overlayColor: controlButtonColor.withAlpha(0x29),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 20.0),
              ),
              child: Slider(
                value: _paceValues.contains(_currentUiPaceFactor)
                    ? _paceValues.indexOf(_currentUiPaceFactor).toDouble()
                    : _paceValues
                        .indexOf(1.0)
                        .toDouble(), // Default to 1.0 if invalid
                min: 0,
                max: (_paceValues.length - 1).toDouble(),
                divisions: _paceValues.length - 1,
                // label: formattedPaceText, // Label is on thumb
                onChanged: (double value) {
                  int newIndex = value.round();
                  if (newIndex >= 0 && newIndex < _paceValues.length) {
                    _setNewPace(_paceValues[newIndex]);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            /* ... Increase Speed Button ... */
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _increaseSpeed,
              splashColor: Colors.white24,
              child: Icon(
                Icons.add_circle_outline_rounded,
                color: controlButtonColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _handleHardReset,
              splashColor: Colors.white24,
              child: Icon(
                Icons.replay_rounded,
                color: controlButtonColor,
                size: 26.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
