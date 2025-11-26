// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart'; // Assuming this path
// import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Assuming this path
// import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/mixin/animation_playback_mixin.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
//
// class PaceSliderThumbShape extends SliderComponentShape {
//   final double enabledThumbRadius;
//   final String currentPaceText;
//   final Color textColor;
//   final double fontSize;
//
//   const PaceSliderThumbShape({
//     required this.enabledThumbRadius,
//     required this.currentPaceText,
//     this.textColor = Colors.black,
//     this.fontSize = 10.0,
//   });
//
//   @override
//   Size getPreferredSize(bool isEnabled, bool isDiscrete) {
//     return Size.fromRadius(enabledThumbRadius);
//   }
//
//   @override
//   void paint(
//     PaintingContext context,
//     Offset center, {
//     required Animation<double> activationAnimation,
//     required Animation<double> enableAnimation,
//     required bool isDiscrete,
//     required TextPainter labelPainter,
//     required RenderBox parentBox,
//     required SliderThemeData sliderTheme,
//     required TextDirection textDirection,
//     required double value,
//     required double textScaleFactor,
//     required Size sizeWithOverflow,
//   }) {
//     final Canvas canvas = context.canvas;
//
//     final Paint paint = Paint()
//       ..color = sliderTheme.thumbColor ?? Colors.blue
//       ..style = PaintingStyle.fill;
//     canvas.drawCircle(center, enabledThumbRadius, paint);
//
//     TextSpan span = TextSpan(
//       style: TextStyle(
//         fontSize: fontSize,
//         fontWeight: FontWeight.bold,
//         color: textColor,
//       ),
//       text: currentPaceText,
//     );
//     TextPainter tp = TextPainter(
//       text: span,
//       textAlign: TextAlign.center,
//       textDirection: textDirection,
//     );
//     tp.layout();
//     Offset textCenter = Offset(
//       center.dx - (tp.width / 2),
//       center.dy - (tp.height / 2),
//     );
//     tp.paint(canvas, textCenter);
//   }
// }
//
// class AnimationControlsWidget extends StatefulWidget {
//   final AnimationModel animationModel;
//   final AnimatingObj animatingObj;
//   final TacticBoard game; // Your TacticBoard game instance
//   final bool initialIsPlaying;
//   final double initialPaceFactor;
//   final Function(double)? onExportProgressCallback;
//
//   const AnimationControlsWidget({
//     super.key,
//     required this.game,
//     required this.animatingObj,
//     required this.animationModel,
//     required this.initialIsPlaying,
//     required this.initialPaceFactor,
//     this.onExportProgressCallback,
//   });
//
//   @override
//   State<AnimationControlsWidget> createState() =>
//       _AnimationControlsWidgetState();
// }
//
// class _AnimationControlsWidgetState extends State<AnimationControlsWidget> {
//   late bool _isCurrentlyPlaying;
//   late double _currentUiPaceFactor;
//
//   final Color controlButtonColor = Colors.white;
//   final Color controlButtonBackgroundColor = Colors.black.withOpacity(0.6);
//   final List<double> _paceValues = [0.5, 1.0, 2.0, 4.0, 8.0];
//
//   bool _isCompleted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     zlog(
//         data:
//             "AnimationControlsWidget initState: animatingObj: ${widget.animatingObj}");
//     _initializeState();
//     _startAnimationConditionally();
//   }
//
//   // @override
//   // void didUpdateWidget(covariant AnimationControlsWidget oldWidget) {
//   //   super.didUpdateWidget(oldWidget);
//   //   bool modelChanged = oldWidget.animationModel.id != widget.animationModel.id;
//   //   bool animatingObjChanged = oldWidget.animatingObj != widget.animatingObj;
//   //
//   //   if (modelChanged || animatingObjChanged) {
//   //     zlog(
//   //         data:
//   //             "AnimationControlsWidget didUpdateWidget: modelChanged: $modelChanged, animatingObjChanged: $animatingObjChanged. New: ${widget.animatingObj}");
//   //     widget.game.performStopAnimation(hardReset: animatingObjChanged);
//   //     _initializeState();
//   //     _startAnimationConditionally();
//   //   }
//   // }
//
//   void _initializeState() {
//     _isCurrentlyPlaying = widget.animatingObj.isExporting ||
//         (widget.animatingObj.isAnimating && widget.initialIsPlaying);
//
//     if (_paceValues.contains(widget.initialPaceFactor)) {
//       _currentUiPaceFactor = widget.initialPaceFactor;
//     } else {
//       _currentUiPaceFactor =
//           _paceValues.contains(1.0) ? 1.0 : _paceValues.first;
//     }
//     // Set pace only if not exporting, as export might have a fixed pace or be managed internally by the game.
//     if (!widget.animatingObj.isExporting) {
//       widget.game.setAnimationPace(_currentUiPaceFactor);
//     }
//     zlog(
//         data:
//             "AnimationControlsWidget _initializeState: isPlaying: $_isCurrentlyPlaying, pace: $_currentUiPaceFactor, isExporting: ${widget.animatingObj.isExporting}");
//   }
//
//   void _startAnimationConditionally() {
//     zlog(
//         data:
//             "AnimationControlsWidget _startAnimationConditionally: animatingObj: ${widget.animatingObj}, _isCurrentlyPlaying: $_isCurrentlyPlaying");
//     if (widget.animatingObj.isExporting) {
//       _startAnimation(); // Always start for export
//     } else if (widget.animatingObj.isAnimating) {
//       _startAnimation(); // Start if isAnimating and _isCurrentlyPlaying is true (or setup initial frame if false)
//     }
//   }
//
//   // void _startAnimation() {
//   //   zlog(
//   //       data:
//   //           "AnimationControlsWidget _startAnimation: isExporting: ${widget.animatingObj.isExporting}, effective play state for game.startAnimation: ${widget.animatingObj.isExporting || _isCurrentlyPlaying}");
//   //   widget.game.startAnimation(
//   //     am: widget.animationModel,
//   //     ap: widget.animatingObj.isExporting ||
//   //         _isCurrentlyPlaying, // Autoplay for export or if _isCurrentlyPlaying
//   //     isForE: widget.animatingObj.isExporting,
//   //     onExportP: widget.animatingObj.isExporting
//   //         ? widget.onExportProgressCallback
//   //         : (progress) {
//   //             if (!widget.animatingObj.isExporting &&
//   //                 widget.animatingObj.isAnimating &&
//   //                 progress >= 1.0) {
//   //               if (mounted) {
//   //                 setState(() {
//   //                   _isCurrentlyPlaying = false;
//   //                 });
//   //                 zlog(
//   //                     data:
//   //                         "AnimationControlsWidget: Normal animation completed, setting _isCurrentlyPlaying to false.");
//   //               }
//   //             }
//   //           },
//   //   );
//   // }
//
//   void _startAnimation() {
//     zlog(
//         data:
//             "AnimationControlsWidget _startAnimation: isExporting: ${widget.animatingObj.isExporting}, effective play state for game.startAnimation: ${widget.animatingObj.isExporting || _isCurrentlyPlaying}");
//     widget.game.startAnimation(
//       am: widget.animationModel,
//       ap: widget.animatingObj.isExporting || _isCurrentlyPlaying,
//       isForE: widget.animatingObj.isExporting,
//       onExportP: widget.animatingObj.isExporting
//           ? widget.onExportProgressCallback
//           : (progress) {
//               if (!widget.animatingObj.isExporting &&
//                   widget.animatingObj.isAnimating &&
//                   progress >= 1.0) {
//                 if (mounted) {
//                   setState(() {
//                     _isCurrentlyPlaying = false;
//                     _isCompleted = true; // MODIFIED: Add this line
//                   });
//                   zlog(
//                       data:
//                           "AnimationControlsWidget: Normal animation completed, setting state.");
//                 }
//               }
//             },
//     );
//   }
//
//   // void _togglePlayPause() {
//   //   if (widget.animatingObj.isExporting) return;
//   //   if (!mounted) return;
//   //
//   //   // If the button shows "Pause" (meaning we believe it's playing)
//   //   if (_isCurrentlyPlaying) {
//   //     // Action: Pause the game.
//   //     widget.game.pauseAnimation();
//   //     zlog(data: "AnimationControlsWidget: Pause button pressed.");
//   //
//   //     // Result: The animation is now paused. Update UI to show "Play".
//   //     setState(() {
//   //       _isCurrentlyPlaying = false;
//   //     });
//   //   }
//   //   // If the button shows "Play" (meaning we believe it's paused or stopped)
//   //   else {
//   //     // Action: Start or resume the game.
//   //
//   //     // Case A: The game is already loaded and just needs to be resumed.
//   //     if (widget.game.isAnimationCurrentlyPlaying ||
//   //         widget.game.isAnimationCurrentlyPaused) {
//   //       widget.game.playAnimation(); // Assumes this resumes the animation
//   //       zlog(data: "AnimationControlsWidget: Resume button pressed.");
//   //     }
//   //     // Case B: The game is fully stopped (e.g., after a reset) and needs to be started from the beginning.
//   //     else {
//   //       // To make `_startAnimation` work correctly, we must set the UI state
//   //       // to `true` *before* calling it. This allows `_startAnimation` to read
//   //       // the correct state and set the `autoplay` parameter to true.
//   //       _isCurrentlyPlaying = true;
//   //       _startAnimation();
//   //       zlog(
//   //           data:
//   //               "AnimationControlsWidget: Play (from beginning) button pressed.");
//   //     }
//   //
//   //     // Result: The animation is now playing. Update UI to show "Pause".
//   //     // This handles both resuming (Case A) and restarting (Case B).
//   //     setState(() {
//   //       _isCurrentlyPlaying = true;
//   //     });
//   //   }
//   // }
//
//   void _togglePlayPause() {
//     if (widget.animatingObj.isExporting) return;
//     if (!mounted) return;
//
//     // If the animation is currently playing, the action is always to PAUSE.
//     if (_isCurrentlyPlaying) {
//       widget.game.pauseAnimation();
//       setState(() {
//         _isCurrentlyPlaying = false;
//       });
//       zlog(data: "AnimationControlsWidget: Paused animation.");
//     }
//     // If the animation is NOT playing, we decide whether to RESUME or RESTART.
//     else {
//       // CASE 1: The animation has finished. Pressing play should RESTART it.
//       if (_isCompleted) {
//         widget.game.performStartAnimationFromBeginning();
//         setState(() {
//           _isCurrentlyPlaying = true; // It's now playing
//           _isCompleted = false; // It's no longer completed
//         });
//         zlog(data: "AnimationControlsWidget: Restarting completed animation.");
//       }
//       // CASE 2: The animation is just paused mid-way. Pressing play should RESUME it.
//       else {
//         widget.game.playAnimation(); // This is your existing resume logic
//         setState(() {
//           _isCurrentlyPlaying = true;
//         });
//         zlog(data: "AnimationControlsWidget: Resuming paused animation.");
//       }
//     }
//   }
//
//   // void _handleHardReset() {
//   //   if (widget.animatingObj.isExporting) return;
//   //   zlog(data: "ControlsWidget: Hard Reset button pressed.");
//   //
//   //   widget.game
//   //       .pauseAnimation(); // Ensure it's paused before resetting UI state
//   //
//   //   if (mounted) {
//   //     setState(() {
//   //       _isCurrentlyPlaying = false;
//   //       _currentUiPaceFactor =
//   //           _paceValues.contains(1.0) ? 1.0 : _paceValues.first;
//   //     });
//   //   }
//   //   widget.game.setAnimationPace(_currentUiPaceFactor);
//   //   widget.game.resetAnimation(); // This should set up the first frame, paused.
//   //   // After resetAnimation, the game is at frame 0, paused. UI reflects this.
//   // }
//
//   void _handleHardReset() {
//     if (widget.animatingObj.isExporting) return;
//     zlog(data: "ControlsWidget: Hard Reset button pressed.");
//
//     widget.game.pauseAnimation();
//
//     if (mounted) {
//       setState(() {
//         _isCurrentlyPlaying = false;
//         _isCompleted = false; // NEW: Add this line to reset the flag
//         _currentUiPaceFactor =
//             _paceValues.contains(1.0) ? 1.0 : _paceValues.first;
//       });
//     }
//     widget.game.setAnimationPace(_currentUiPaceFactor);
//     widget.game.resetAnimation();
//   }
//
//   void _increaseSpeed() {
//     if (widget.animatingObj.isExporting ||
//         !_paceValues.contains(_currentUiPaceFactor)) return;
//     if (!mounted) return;
//     int currentIndex = _paceValues.indexOf(_currentUiPaceFactor);
//     if (currentIndex < _paceValues.length - 1) {
//       _setNewPace(_paceValues[currentIndex + 1]);
//     }
//   }
//
//   void _decreaseSpeed() {
//     if (widget.animatingObj.isExporting ||
//         !_paceValues.contains(_currentUiPaceFactor)) return;
//     if (!mounted) return;
//     int currentIndex = _paceValues.indexOf(_currentUiPaceFactor);
//     if (currentIndex > 0) {
//       _setNewPace(_paceValues[currentIndex - 1]);
//     }
//   }
//
//   void _setNewPace(double newPace) {
//     if (widget.animatingObj.isExporting) return;
//     if (!_paceValues.contains(newPace)) {
//       zlog(
//           data:
//               "ControlsWidget: Attempted to set invalid pace $newPace. Ignoring.");
//       return;
//     }
//     if (_currentUiPaceFactor == newPace) return;
//     if (!mounted) return;
//
//     widget.game.setAnimationPace(newPace);
//     if (mounted) {
//       setState(() {
//         _currentUiPaceFactor = newPace;
//       });
//     }
//     zlog(data: "ControlsWidget: Pace factor set to $_currentUiPaceFactor");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This UI will be Offstage during export, so it won't be visible.
//     // The logic in initState/didUpdateWidget handles starting the export.
//     String formattedPaceText = _paceValues.contains(_currentUiPaceFactor)
//         ? "${_currentUiPaceFactor.toStringAsFixed(_currentUiPaceFactor % 1 == 0 ? 0 : 1)}x"
//         : "1x";
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
//       decoration: BoxDecoration(
//         color: controlButtonBackgroundColor,
//         borderRadius: BorderRadius.circular(30.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             spreadRadius: 1,
//             blurRadius: 3,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Material(
//             /* ... Play/Pause Button ... */
//             color: Colors.transparent,
//             shape: const CircleBorder(),
//             clipBehavior: Clip.antiAlias,
//             child: InkWell(
//               onTap: _togglePlayPause,
//               splashColor: Colors.white24,
//               child: Icon(
//                 _isCurrentlyPlaying
//                     ? Icons.pause_rounded
//                     : Icons.play_arrow_rounded,
//                 color: controlButtonColor,
//                 size: 28.0,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Material(
//             /* ... Decrease Speed Button ... */
//             color: Colors.transparent,
//             shape: const CircleBorder(),
//             clipBehavior: Clip.antiAlias,
//             child: InkWell(
//               onTap: _decreaseSpeed,
//               splashColor: Colors.white24,
//               child: Icon(
//                 Icons.remove_circle_outline_rounded,
//                 color: controlButtonColor,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           SizedBox(
//             /* ... Slider ... */
//             width: 150.0,
//             child: SliderTheme(
//               data: SliderTheme.of(context).copyWith(
//                 activeTrackColor: controlButtonColor,
//                 inactiveTrackColor: controlButtonColor.withOpacity(0.3),
//                 trackHeight: 2.0,
//                 thumbColor: controlButtonColor,
//                 thumbShape: PaceSliderThumbShape(
//                   enabledThumbRadius: 14.0,
//                   currentPaceText: formattedPaceText,
//                   textColor: ColorManager.black,
//                   fontSize: 10.0,
//                 ),
//                 overlayColor: controlButtonColor.withAlpha(0x29),
//                 overlayShape:
//                     const RoundSliderOverlayShape(overlayRadius: 20.0),
//               ),
//               child: Slider(
//                 value: _paceValues.contains(_currentUiPaceFactor)
//                     ? _paceValues.indexOf(_currentUiPaceFactor).toDouble()
//                     : _paceValues
//                         .indexOf(1.0)
//                         .toDouble(), // Default to 1.0 if invalid
//                 min: 0,
//                 max: (_paceValues.length - 1).toDouble(),
//                 divisions: _paceValues.length - 1,
//                 // label: formattedPaceText, // Label is on thumb
//                 onChanged: (double value) {
//                   int newIndex = value.round();
//                   if (newIndex >= 0 && newIndex < _paceValues.length) {
//                     _setNewPace(_paceValues[newIndex]);
//                   }
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Material(
//             /* ... Increase Speed Button ... */
//             color: Colors.transparent,
//             shape: const CircleBorder(),
//             clipBehavior: Clip.antiAlias,
//             child: InkWell(
//               onTap: _increaseSpeed,
//               splashColor: Colors.white24,
//               child: Icon(
//                 Icons.add_circle_outline_rounded,
//                 color: controlButtonColor,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Material(
//             color: Colors.transparent,
//             shape: const CircleBorder(),
//             clipBehavior: Clip.antiAlias,
//             child: InkWell(
//               onTap: _handleHardReset,
//               splashColor: Colors.white24,
//               child: Icon(
//                 Icons.replay_rounded,
//                 color: controlButtonColor,
//                 size: 26.0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async' as a;
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
// Make sure this path is correct and the enum is accessible
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/mixin/animation_playback_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';

class AnimationControlsWidget extends StatefulWidget {
  final AnimationModel animationModel;
  final AnimatingObj animatingObj;
  final TacticBoard game;
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
  final List<double> _paceValues = [0.5, 1.0, 2.0, 3.0];
  bool _isCompleted = false;

  a.Timer? _progressPollTimer;
  final Stopwatch _debugStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _initializeState();
    _startAnimationConditionally();

    _progressPollTimer =
        a.Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _progressPollTimer?.cancel();
    super.dispose();
  }

  void _initializeState() {
    _isCurrentlyPlaying = widget.animatingObj.isExporting ||
        (widget.animatingObj.isAnimating && widget.initialIsPlaying);

    if (_paceValues.contains(widget.initialPaceFactor)) {
      _currentUiPaceFactor = widget.initialPaceFactor;
    } else {
      _currentUiPaceFactor =
          _paceValues.contains(1.0) ? 1.0 : _paceValues.first;
    }

    if (!widget.animatingObj.isExporting) {
      widget.game.performSetAnimationPace(_currentUiPaceFactor);
    }
  }

  void _startAnimationConditionally() {
    if (widget.animatingObj.isExporting) {
      _startAnimation(); // This correctly starts the export process.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.game.performStartAnimationFromBeginning();
        }
      });
    } else if (widget.animatingObj.isAnimating) {
      _startAnimation(); // This sets up the animation to frame 0.

      // THIS IS THE NEW LOGIC FOR AUTOPLAY
      if (widget.initialIsPlaying) {
        // We use a post-frame callback to ensure the initial setup from
        // _startAnimation is complete before we tell it to play.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.game.performStartAnimationFromBeginning();
          }
        });
      }
    }
  }

  void _startAnimation() {
    widget.game.startAnimation(
      am: widget.animationModel,
      ap: widget.animatingObj.isExporting || _isCurrentlyPlaying,
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
                    _isCompleted = true;
                  });
                }
              }
            },
    );
  }

  void _togglePlayPause() {
    if (widget.animatingObj.isExporting || !mounted) return;

    final currentState = widget.game.currentPlaybackState;
    if (currentState == PlaybackState.playing) {
      widget.game.performPauseAnimation();
    } else if (currentState == PlaybackState.paused) {
      widget.game.performResumeAnimation();
    } else if (currentState == PlaybackState.stopped) {
      widget.game.performStartAnimationFromBeginning();
    }
    // Do nothing if it's preparing
    setState(() {});
  }

  void _handleHardReset() {
    if (widget.animatingObj.isExporting || !mounted) return;

    widget.game.performHardResetAnimation();
    if (mounted) {
      setState(() {
        _isCurrentlyPlaying = false;
        _isCompleted = false;
        _currentUiPaceFactor =
            _paceValues.contains(1.0) ? 1.0 : _paceValues.first;
      });
    }
    widget.game.performSetAnimationPace(_currentUiPaceFactor);
  }

  void _setNewPace(double newPace) {
    if (widget.animatingObj.isExporting ||
        !_paceValues.contains(newPace) ||
        _currentUiPaceFactor == newPace ||
        !mounted) {
      return;
    }

    widget.game.performSetAnimationPace(newPace);
    if (mounted) {
      setState(() {
        _currentUiPaceFactor = newPace;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animatingObj.isExporting) {
      return const Offstage();
    }

    String formattedPaceText = "${_currentUiPaceFactor.toStringAsFixed(1)}x";

    final bool isPlaying = widget.game.isAnimationCurrentlyPlaying;
    final IconData playPauseIcon =
        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
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
            // ## THIS IS THE CRITICAL CHANGE ##
            // This widget now shows a spinner when the engine is preparing.
            SizedBox(
              width: 28.0,
              height: 28.0,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _togglePlayPause,
                  splashColor: Colors.white24,
                  child: Icon(
                    playPauseIcon,
                    color: controlButtonColor,
                    size: 28.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Timeline Scrubbing Slider
            // Expanded(
            //   // The IgnorePointer has been REMOVED.
            //   child: GestureDetector(
            //     onTap: () {
            //       zlog(
            //           data:
            //               "is animation playing ${widget.game.isAnimationCurrentlyPlaying}",
            //           show: true);
            //       if (widget.game.isAnimationCurrentlyPlaying) {
            //         widget.game.performPauseAnimation();
            //         widget.game.beginScrubbing();
            //         setState(() {});
            //       }
            //     },
            //     child: IgnorePointer(
            //       ignoring: widget.game.isAnimationCurrentlyPlaying,
            //       child: Opacity(
            //         // The opacity is still dynamic, providing the visual cue.
            //         opacity:
            //             widget.game.isAnimationCurrentlyPlaying ? 0.6 : 1.0,
            //         child: SliderTheme(
            //           data: SliderTheme.of(context).copyWith(
            //             activeTrackColor: controlButtonColor,
            //             inactiveTrackColor: controlButtonColor.withOpacity(0.3),
            //             trackHeight: 4.0,
            //             thumbColor: controlButtonColor,
            //             thumbShape: const RoundSliderThumbShape(
            //                 enabledThumbRadius: 8.0),
            //             overlayColor: controlButtonColor.withAlpha(0x29),
            //             overlayShape:
            //                 const RoundSliderOverlayShape(overlayRadius: 20.0),
            //           ),
            //           child: Slider(
            //             value: widget.game.currentAnimationProgress,
            //             min: 0.0,
            //             max: 1.0,
            //             onChanged: (double value) {
            //               // This will only work if the state is not 'playing',
            //               // which is handled by the mixin.
            //               widget.game.seekToProgress(value);
            //               setState(() {});
            //             },
            //             onChangeStart: (double value) {
            //               // This will pause the animation if it's playing.
            //               widget.game.beginScrubbing();
            //               // This forces the UI to update immediately, changing opacity to 1.0.
            //               setState(() {});
            //             },
            //             onChangeEnd: (double value) {
            //               widget.game.endScrubbing();
            //             },
            //
            //             ///2nd
            //             // onChangeStart: (double value) {
            //             //   // This is the first event that fires when the user's finger touches the slider.
            //             //   if (widget.game.isAnimationCurrentlyPlaying) {
            //             //     // Rule 1: If playing, the ONLY action is to pause.
            //             //     widget.game.performPauseAnimation();
            //             //   } else {
            //             //     // Rule 2: If already paused, it's safe to start scrubbing.
            //             //     widget.game.beginScrubbing();
            //             //     // We also immediately seek to the tapped position.
            //             //     widget.game.seekToProgress(value);
            //             //   }
            //             //   // Force the UI to update to reflect the new state (e.g., opacity change).
            //             //   setState(() {});
            //             // },
            //             //
            //             // onChanged: (double value) {
            //             //   // This event fires as the user drags their finger.
            //             //   // It should ONLY work if we are already in the scrubbing state.
            //             //   // The engine's seekToProgress method now handles this check internally.
            //             //   widget.game.seekToProgress(value);
            //             //   setState(() {});
            //             // },
            //             //
            //             // onChangeEnd: (double value) {
            //             //   // When the user lifts their finger, always end in the paused state.
            //             //   widget.game.endScrubbing();
            //             //   setState(() {});
            //             // },
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // LAYER 1: The Slider. It's always here.
                  Opacity(
                    opacity:
                        widget.game.isAnimationCurrentlyPlaying ? 0.6 : 1.0,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: controlButtonColor,
                        inactiveTrackColor: controlButtonColor.withOpacity(0.3),
                        trackHeight: 4.0,
                        thumbColor: controlButtonColor,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8.0),
                        overlayColor: controlButtonColor.withAlpha(0x29),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 20.0),
                      ),
                      child: Slider(
                        value: widget.game.currentAnimationProgress,
                        min: 0.0,
                        max: 1.0,
                        // These will only work when the overlay is gone.
                        onChanged: (double value) {
                          // This will only work if the state is not 'playing',
                          // which is handled by the mixin.
                          widget.game.seekToProgress(value);
                          setState(() {});
                        },
                        onChangeStart: (double value) {
                          // This will pause the animation if it's playing.
                          widget.game.beginScrubbing();
                          // This forces the UI to update immediately, changing opacity to 1.0.
                          setState(() {});
                        },
                        onChangeEnd: (double value) {
                          widget.game.endScrubbing();
                        },
                      ),
                    ),
                  ),

                  // LAYER 2: The "Tap to Pause" overlay. This only exists when the animation is playing.
                  if (widget.game.isAnimationCurrentlyPlaying)
                    GestureDetector(
                      onTap: () {
                        // The ONLY job of this widget is to pause the animation.
                        widget.game.performPauseAnimation();
                        setState(
                            () {}); // Force the UI to rebuild, which will remove this overlay.
                      },
                      // This transparent container makes the entire slider area tappable.
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.transparent,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Speed Selection Drop-up Button
            PopupMenuButton<double>(
              color: ColorManager.dark3,
              tooltip: "Set Playback Speed",
              onSelected: (double newPace) {
                _setNewPace(newPace);
              },
              itemBuilder: (BuildContext context) {
                return _paceValues.map((double pace) {
                  return PopupMenuItem<double>(
                    value: pace,
                    child: Text(
                      "${pace.toStringAsFixed(1)}x",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: ColorManager.white),
                    ),
                  );
                }).toList();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  formattedPaceText,
                  style: TextStyle(
                    color: controlButtonColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Reset Button
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
      ),
    );
  }
}
