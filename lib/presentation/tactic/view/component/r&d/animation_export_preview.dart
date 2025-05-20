// import 'package:flame_riverpod/flame_riverpod.dart';
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Your ColorManager
// import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game_animation.dart';
//
// GlobalKey<RiverpodAwareGameWidgetState> _animationWidgetKey =
//     GlobalKey<RiverpodAwareGameWidgetState>();
//
// class AnimationExportPreview extends StatefulWidget {
//   final AnimationModel animationModel;
//   final GlobalKey
//   repaintBoundaryKey; // Key for capturing the GameWidget content
//   final VoidCallback?
//   onExportComplete; // Optional: callback when animation finishes
//   final VoidCallback? onExportCancelled; // Optional: callback for cancel
//
//   const AnimationExportPreview({
//     super.key,
//     required this.animationModel,
//     required this.repaintBoundaryKey,
//     this.onExportComplete,
//     this.onExportCancelled,
//   });
//
//   @override
//   State<AnimationExportPreview> createState() => _AnimationExportPreviewState();
// }
//
// class _AnimationExportPreviewState extends State<AnimationExportPreview> {
//   late TacticBoardGameAnimation _exportGame;
//   double _exportProgress = 0.0;
//   bool _isExporting = true; // Assume it starts exporting immediately
//
//   @override
//   void initState() {
//     super.initState();
//     zlog(data: "AnimationExportPreview: initState. Creating game for export.");
//     _exportGame = TacticBoardGameAnimation(
//       animationModel: widget.animationModel,
//       autoPlay: true, // Start playing immediately for export
//       isForExportMode: true, // Configure for fast playback & progress reporting
//       onExportProgressUpdate: (progress) {
//         if (mounted) {
//           setState(() {
//             _exportProgress = progress;
//             zlog(
//               data:
//                   "Export Progress: ${(_exportProgress * 100).toStringAsFixed(0)}%",
//             );
//             if (_exportProgress >= 1.0) {
//               _isExporting = false; // Mark as complete
//               zlog(
//                 data:
//                     "AnimationExportPreview: Export animation sequence finished.",
//               );
//               widget.onExportComplete?.call();
//               // Optionally pop the dialog here after a short delay or based on parent's action
//             }
//           });
//         }
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     // Optional: If TacticBoardGameAnimation needs explicit disposal of resources
//     // _exportGame.dispose(); // FlameGame usually handles this via GameWidget
//     zlog(data: "AnimationExportPreview: dispose.");
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Use Scaffold for a full-screen dialog appearance
//       backgroundColor: Colors.black.withOpacity(
//         0.75,
//       ), // Semi-transparent background
//       body: Stack(
//         children: [
//           // Game Widget in the background, wrapped with the RepaintBoundary
//           Center(
//             child: RepaintBoundary(
//               key: widget.repaintBoundaryKey, // Use the passed key
//
//               child: RiverpodAwareGameWidget(
//                 game: _exportGame,
//                 key: _animationWidgetKey,
//               ),
//             ),
//           ),
//           // Progress Indicator Overlay
//           Positioned.fill(
//             child: Container(
//               // Optional: slightly darker overlay to make progress more visible
//               // color: Colors.black.withOpacity(0.1),
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: ColorManager.black,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           SizedBox(
//                             width: 80,
//                             height: 80,
//                             child: CircularProgressIndicator(
//                               value: _exportProgress,
//                               strokeWidth: 6.0,
//                               backgroundColor: ColorManager.grey.withOpacity(
//                                 0.3,
//                               ),
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 ColorManager.yellow,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           Text(
//                             _isExporting
//                                 ? "Exporting Animation...\n${(_exportProgress * 100).toStringAsFixed(0)}%"
//                                 : "Export Complete!",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: ColorManager.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           if (!_isExporting &&
//                               widget.onExportComplete ==
//                                   null) // Show close if no onExportComplete
//                             Padding(
//                               padding: const EdgeInsets.only(top: 20.0),
//                               child: ElevatedButton(
//                                 onPressed: () => Navigator.of(context).pop(),
//                                 child: const Text("Close"),
//                               ),
//                             ),
//                           if (_isExporting && widget.onExportCancelled != null)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 20.0),
//                               child: TextButton(
//                                 onPressed: () {
//                                   _exportGame
//                                       .performStopAnimation(); // Stop the game
//                                   setState(() {
//                                     _isExporting = false;
//                                   });
//                                   widget.onExportCancelled?.call();
//                                   Navigator.of(context).pop(); // Close dialog
//                                 },
//                                 child: Text(
//                                   "Cancel Export",
//                                   style: TextStyle(
//                                     color: ColorManager.white.withOpacity(0.7),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// animation_export_preview.dart
import 'dart:async' as a; // For Timer
import 'dart:typed_data'; // For Uint8List

import 'package:bot_toast/bot_toast.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/animation_sharer.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game_animation.dart';

GlobalKey<RiverpodAwareGameWidgetState> _animationWidgetKey =
    GlobalKey<RiverpodAwareGameWidgetState>();

class AnimationExportPreview extends StatefulWidget {
  final AnimationModel animationModel;
  final GlobalKey repaintBoundaryKey;
  final Function(List<Uint8List> capturedFrames)? onExportComplete;
  final VoidCallback? onExportCancelled;

  const AnimationExportPreview({
    super.key,
    required this.animationModel,
    required this.repaintBoundaryKey,
    this.onExportComplete,
    this.onExportCancelled,
  });

  @override
  State<AnimationExportPreview> createState() => _AnimationExportPreviewState();
}

class _AnimationExportPreviewState extends State<AnimationExportPreview> {
  late TacticBoardGameAnimation _exportGame;
  double _overallExportProgress = 0.0; // Progress of the game playing through
  bool _isGameSequenceComplete =
      false; // True when game calls onExportProgress(1.0)

  // Frame capture state
  final List<Uint8List> _capturedFramesData = [];
  a.Timer? _frameCaptureTimer;
  final int _gifTargetFps = 10; // Desired FPS for the output GIF
  bool _isCapturingFrames = false;

  @override
  void initState() {
    super.initState();
    zlog(data: "AnimationExportPreview: initState. Creating game for export.");
    _exportGame = TacticBoardGameAnimation(
      animationModel: widget.animationModel,
      autoPlay: true, // We will start it manually after setting up capture
      isForExportMode: true,
      onExportProgressUpdate: (progress) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((t) {
            setState(() {
              _overallExportProgress = progress;
              // zlog(data: "Game Playback Progress: ${(_overallExportProgress * 100).toStringAsFixed(0)}%");
              if (_overallExportProgress >= 1.0 && !_isGameSequenceComplete) {
                _isGameSequenceComplete = true;
                zlog(
                  data:
                      "AnimationExportPreview: Game animation sequence finished playing.",
                );
                _stopFrameCaptureAndFinalize();
              }
            });
          });
        }
      },
    );
    // Start animation and frame capture after a brief delay to ensure widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startExportAndCapture();
      }
    });
  }

  void _startExportAndCapture() {
    zlog(data: "AnimationExportPreview: Starting export and frame capture.");
    setState(() {
      _isCapturingFrames = true;
      _capturedFramesData.clear();
    });
    // Start the game's animation sequence
    _exportGame.performStartAnimationFromBeginning();

    // Start the periodic frame capture timer
    _frameCaptureTimer = a.Timer.periodic(
      Duration(milliseconds: 1000 ~/ _gifTargetFps),
      (timer) async {
        if (!_isCapturingFrames || !mounted) {
          // Stop if no longer exporting or widget disposed
          timer.cancel();
          return;
        }
        await _captureCurrentFrame();
      },
    );
  }

  Future<void> _captureCurrentFrame() async {
    if (!mounted) return;
    // zlog(data: "AnimationExportPreview: Attempting to capture frame...");
    final Uint8List? frameBytes = await AnimationSharer.captureWidgetAsPngBytes(
      widget.repaintBoundaryKey,
    );
    if (frameBytes != null && mounted) {
      setState(() {
        _capturedFramesData.add(frameBytes);
        // zlog(data: "AnimationExportPreview: Frame captured. Total frames: ${_capturedFramesData.length}");
      });
    } else {
      // zlog(data: "AnimationExportPreview: Frame capture failed.");
    }
  }

  void _stopFrameCaptureAndFinalize() {
    _frameCaptureTimer?.cancel();
    _isCapturingFrames =
        false; // Ensure this is set before calling onExportComplete
    zlog(
      data:
          "AnimationExportPreview: Frame capture stopped. Total frames collected: ${_capturedFramesData.length}.",
    );

    // Ensure game is fully stopped to prevent further updates
    _exportGame.performStopAnimation();

    if (_capturedFramesData.isNotEmpty) {
      widget.onExportComplete?.call(_capturedFramesData);
    } else {
      zlog(
        data:
            "AnimationExportPreview: No frames captured, calling onExportCancelled or just closing.",
      );
      widget.onExportCancelled?.call(); // Or handle error
      if (mounted &&
          (widget.onExportComplete == null &&
              widget.onExportCancelled == null)) {
        // If no callbacks, provide a way to close or show error
        BotToast.showText(text: "Export failed: No frames captured.");
        Navigator.of(context).pop();
      }
    }
  }

  void _cancelExportByUser() {
    zlog(data: "AnimationExportPreview: Export cancelled by user.");
    _frameCaptureTimer?.cancel();
    _isCapturingFrames = false;
    _exportGame.performStopAnimation(); // Stop the game
    widget.onExportCancelled?.call();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _frameCaptureTimer?.cancel();
    // _exportGame might need specific disposal if it holds resources not handled by FlameGame's dispose
    zlog(data: "AnimationExportPreview: dispose. Cancelling timer.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String progressText;
    if (_overallExportProgress >= 1.0 && !_isCapturingFrames) {
      progressText =
          "Finalizing..."; // Or "Encoding GIF..." if passed to another stage
    } else if (_isCapturingFrames) {
      progressText =
          "Capturing Frames: ${_capturedFramesData.length}\nGame Progress: ${(_overallExportProgress * 100).toStringAsFixed(0)}%";
    } else {
      progressText = "Preparing Export...";
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: RepaintBoundary(
              key: widget.repaintBoundaryKey,
              child: RiverpodAwareGameWidget(
                game: _exportGame,
                key: _animationWidgetKey,
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorManager.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        // value: _overallExportProgress < 1.0 ? _overallExportProgress : null, // Indeterminate while finalizing
                        strokeWidth: 6.0,
                        backgroundColor: ColorManager.grey,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorManager.yellow,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      progressText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorManager.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.onExportCancelled != null &&
                        _isCapturingFrames) // Show cancel only during capture
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextButton(
                          onPressed: _cancelExportByUser,
                          child: Text(
                            "Cancel Export",
                            style: TextStyle(
                              color: ColorManager.white.withOpacity(0.7),
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
    );
  }
}
