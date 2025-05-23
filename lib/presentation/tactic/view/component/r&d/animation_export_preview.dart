import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:screen_recorder/screen_recorder.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Your ColorManager
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game_animation.dart';

GlobalKey<RiverpodAwareGameWidgetState> _animationWidgetKey =
    GlobalKey<RiverpodAwareGameWidgetState>();

class AnimationExportPreview extends StatefulWidget {
  final AnimationModel animationModel;

  final Function(List<int>?)?
  onExportComplete; // Optional: callback when animation finishes
  final VoidCallback? onExportCancelled; // Optional: callback for cancel

  const AnimationExportPreview({
    super.key,
    required this.animationModel,
    this.onExportComplete,
    this.onExportCancelled,
  });

  @override
  State<AnimationExportPreview> createState() => _AnimationExportPreviewState();
}

class _AnimationExportPreviewState extends State<AnimationExportPreview> {
  late TacticBoardGameAnimation _exportGame;
  double _exportProgress = 0.0;
  bool _isExporting = true; // Assume it starts exporting immediately
  ScreenRecorderController controller = ScreenRecorderController(
    skipFramesBetweenCaptures: 2,
    pixelRatio: 0.75,
  );

  @override
  void initState() {
    super.initState();
    zlog(data: "AnimationExportPreview: initState. Creating game for export.");
    _exportGame = TacticBoardGameAnimation(
      animationModel: widget.animationModel,
      autoPlay: true, // Start playing immediately for export
      isForExportMode: true, // Configure for fast playback & progress reporting
      onExportProgressUpdate: (progress) async {
        if (mounted) {
          if (_exportProgress >= 1.0) {
            setState(() {
              if (_exportProgress >= 1.0) {
                _isExporting = false; // Mark as complete
                zlog(
                  data:
                      "AnimationExportPreview: Export animation sequence finished.",
                );

                // Optionally pop the dialog here after a short delay or based on parent's action
              }
            });
            final gif = await _stopRecording();
            widget.onExportComplete?.call(gif);
          } else {
            setState(() {
              _exportProgress = progress;
            });
          }
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startRecording();
      }
    });
  }

  @override
  void dispose() {
    // Optional: If TacticBoardGameAnimation needs explicit disposal of resources
    // _exportGame.dispose(); // FlameGame usually handles this via GameWidget
    zlog(data: "AnimationExportPreview: dispose.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use Scaffold for a full-screen dialog appearance
      backgroundColor: Colors.black.withOpacity(
        0.75,
      ), // Semi-transparent background
      body: Stack(
        children: [
          // Game Widget in the background, wrapped with the RepaintBoundary
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ScreenRecorder(
                  controller: controller,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: RiverpodAwareGameWidget(
                    game: _exportGame,
                    key: _animationWidgetKey,
                  ),
                );
              },
            ),
          ),
          // Progress Indicator Overlay
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorManager.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isExporting)
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: _exportProgress,
                              strokeWidth: 6.0,
                              backgroundColor: ColorManager.grey.withOpacity(
                                0.3,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorManager.yellow,
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              strokeWidth: 6.0,
                              backgroundColor: ColorManager.grey.withOpacity(
                                0.3,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorManager.yellow,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          _isExporting
                              ? "Extracting Scene...\n${(_exportProgress * 100).toStringAsFixed(0)}%"
                              : "Preparing Animation",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorManager.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isExporting &&
                            widget.onExportComplete ==
                                null) // Show close if no onExportComplete
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Close"),
                            ),
                          ),
                        if (_isExporting && widget.onExportCancelled != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: TextButton(
                              onPressed: () {
                                _exportGame
                                    .performStopAnimation(); // Stop the game
                                setState(() {
                                  _isExporting = false;
                                });
                                widget.onExportCancelled?.call();
                                Navigator.of(context).pop(); // Close dialog
                              },
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startRecording() {
    controller.start();
    zlog(data: "CPTURED GIF FROM RECORDER started");
  }

  Future<List<int>?> _stopRecording() async {
    controller.stop();
    final gif = await controller.exporter.exportGif();
    return gif;
  }
}
