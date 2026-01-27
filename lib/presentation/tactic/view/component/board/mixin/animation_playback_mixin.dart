

import 'dart:async' as a;
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/helper/trajectory_calculator.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/game_field.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/text_field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/circle_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/polygon_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/square_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';

class AnimatingObj {
  final bool isAnimating;
  final bool isExporting;
  AnimatingObj({required this.isAnimating, required this.isExporting});
  factory AnimatingObj.animate() {
    return AnimatingObj(isAnimating: true, isExporting: false);
  }
  factory AnimatingObj.export() {
    return AnimatingObj(isAnimating: false, isExporting: true);
  }
}

enum PlaybackState {
  stopped,
  preparing,
  playing,
  paused,
  scrubbing,
}

mixin AnimationPlaybackMixin on TacticBoardGame {
  bool _isRendering = false;
  late TacticBoard _tacticBoard;
  AnimationModel? animationModel;
  late bool isForExportMode;
  late Function(double progress)? onExportProgressUpdate;

  PlaybackState _playbackState = PlaybackState.stopped;
  double _scenePaceFactor = 1.0;
  Duration _currentTotalElapsedTime = Duration.zero;

  @override
  bool get isAnimationCurrentlyPlaying =>
      _playbackState == PlaybackState.playing;
  @override
  bool get isAnimationCurrentlyPaused =>
      _playbackState == PlaybackState.paused ||
      _playbackState == PlaybackState.scrubbing;

  PlaybackState get currentPlaybackState => _playbackState;

  void startAnimation({
    required AnimationModel am,
    bool ap = false,
    bool isForE = false,
    Function(double progress)? onExportP,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      animationModel = am;
      isForExportMode = isForE;
      onExportProgressUpdate = onExportP;
      _tacticBoard = (this as TacticBoard);
      _playbackState = PlaybackState.stopped;
      _currentTotalElapsedTime = Duration.zero;
      _renderStateForTime(Duration.zero);
      if (isForExportMode || ap) {
        performStartAnimationFromBeginning();
      }
    });
  }

  @override
  void update(double dt) {
    if (_isRendering) return;
    super.update(dt);

    if (_playbackState == PlaybackState.playing) {
      final timeStep =
          Duration(microseconds: (dt * 1000000 * _scenePaceFactor).round());
      _currentTotalElapsedTime += timeStep;

      final totalDuration = _totalAnimationDuration;
      if (_currentTotalElapsedTime >= totalDuration) {
        _currentTotalElapsedTime = totalDuration;
        _playbackState = PlaybackState.stopped;
        onExportProgressUpdate?.call(1.0);
      }
      if (isForExportMode) {
        onExportProgressUpdate?.call(currentAnimationProgress);
      }
      _renderStateForTime(_currentTotalElapsedTime);
    }
  }

  Duration get _totalAnimationDuration {
    if (!isLoaded ||
        animationModel == null ||
        animationModel!.animationScenes.isEmpty) {
      return Duration.zero;
    }
    return animationModel!.animationScenes.fold(
      Duration.zero,
      (previousValue, scene) => previousValue + scene.sceneDuration,
    );
  }

  double get currentAnimationProgress {
    if (!isLoaded) return 0.0;
    final totalMs = _totalAnimationDuration.inMilliseconds;
    if (totalMs == 0) return 0.0;
    final currentMs = _currentTotalElapsedTime.inMilliseconds;
    return (currentMs / totalMs).clamp(0.0, 1.0);
  }

  Future<void> _renderStateForTime(Duration targetTime) async {
    if (!isLoaded ||
        animationModel == null ||
        animationModel!.animationScenes.isEmpty ||
        _isRendering) return;

    try {
      _isRendering = true;

      final totalDuration = _totalAnimationDuration;
      if (targetTime > totalDuration) targetTime = totalDuration;

      Duration cumulativeTime = Duration.zero;
      int sceneIndex = -1;
      for (int i = 0; i < animationModel!.animationScenes.length; i++) {
        final scene = animationModel!.animationScenes[i];
        if (targetTime <= cumulativeTime + scene.sceneDuration ||
            i == animationModel!.animationScenes.length - 1) {
          sceneIndex = i;
          break;
        }
        cumulativeTime += scene.sceneDuration;
      }
      if (sceneIndex == -1) return;

      final currentScene = animationModel!.animationScenes[sceneIndex];
      final prevScene = sceneIndex > 0
          ? animationModel!.animationScenes[sceneIndex - 1]
          : null;

      // --- THE DEFINITIVE FIX FOR DUPLICATES ---
      // 1. Schedule all components for removal.
      removeAll(children
          .where((c) => c is! GameField && c is! DrawingBoardComponent));

      // 2. Wait for the next frame/game tick to pass.
      // This gives the engine time to process the removals before we add anything new.
      await Future.delayed(Duration.zero);
      // --- END OF FIX ---

      final timeIntoScene = targetTime - cumulativeTime;
      double intraSceneProgress = 0.0;
      if (currentScene.sceneDuration.inMilliseconds > 0) {
        intraSceneProgress = (timeIntoScene.inMilliseconds /
                currentScene.sceneDuration.inMilliseconds)
            .clamp(0.0, 1.0);
      }

      final itemsInCurrentScene = {
        for (var item in currentScene.components) item.id: item
      };
      final itemsInPrevScene = {
        if (prevScene != null)
          for (var item in prevScene.components) item.id: item
      };

      for (final id in itemsInCurrentScene.keys) {
        final modelInCurrent = itemsInCurrentScene[id]!;
        final modelInPrev = itemsInPrevScene[id];

        await _addComponentToBoard(
            modelInCurrent, modelInPrev, intraSceneProgress, currentScene);
      }

      List<FreeDrawModelV2> freeLines =
          currentScene.components.whereType<FreeDrawModelV2>().toList();
      List<FreeDrawModelV2> processedFreeLines = freeLines.map((e) {
        var cloned = e.clone();
        cloned.points = cloned.points
            .map((p) => SizeHelper.getBoardActualVector(
                gameScreenSize: _tacticBoard.gameField.size, actualPosition: p))
            .toList();
        return cloned;
      }).toList();
      drawingBoard.loadLines(processedFreeLines, suppressNotification: true);
    } finally {
      _isRendering = false;
    }
  }

  Future<void> _addComponentToBoard(
      FieldItemModel modelInCurrent,
      FieldItemModel? modelInPrev,
      double intraSceneProgress,
      AnimationItemModel currentScene) async {
    final displayModel = modelInCurrent.clone();
    double altitude = 0.0;
    Vector2? visualSize;

    if (displayModel.offset != null) {
      final startPos = modelInPrev?.offset ?? modelInCurrent.offset!;
      final endPos = modelInCurrent.offset!;

      // Check if this component has a custom trajectory path
      final hasCustomTrajectory =
          currentScene.trajectoryData?.hasTrajectory(modelInCurrent.id) ??
              false;

      if (hasCustomTrajectory) {
        // Use custom trajectory path for curved movement
        final trajectory =
            currentScene.trajectoryData!.getTrajectory(modelInCurrent.id)!;

        // Calculate the curved path using TrajectoryCalculator
        final pathPoints = TrajectoryCalculator.calculatePath(
          startPosition: startPos,
          endPosition: endPos,
          trajectory: trajectory,
          frameCount: 100, // Higher frame count for smoother curves
        );

        // Interpolate position along the curved path
        if (pathPoints.isNotEmpty) {
          final segmentIndex =
              (intraSceneProgress * (pathPoints.length - 1)).floor();
          final clampedIndex = segmentIndex.clamp(0, pathPoints.length - 2);
          final segmentProgress =
              (intraSceneProgress * (pathPoints.length - 1)) - clampedIndex;

          final segmentStart = pathPoints[clampedIndex];
          final segmentEnd = pathPoints[clampedIndex + 1];

          displayModel.offset = Vector2(
            ui.lerpDouble(segmentStart.x, segmentEnd.x, segmentProgress)!,
            ui.lerpDouble(segmentStart.y, segmentEnd.y, segmentProgress)!,
          );
        } else {
          // Fallback to straight line if path calculation fails
          displayModel.offset = Vector2(
            ui.lerpDouble(startPos.x, endPos.x, intraSceneProgress)!,
            ui.lerpDouble(startPos.y, endPos.y, intraSceneProgress)!,
          );
        }
      } else {
        // Use straight line interpolation (default behavior)
        displayModel.offset = Vector2(
          ui.lerpDouble(startPos.x, endPos.x, intraSceneProgress)!,
          ui.lerpDouble(startPos.y, endPos.y, intraSceneProgress)!,
        );
      }

      if (displayModel is EquipmentModel && displayModel.isAerialArrival) {
        final distance = startPos.distanceTo(endPos);
        final arcHeight = (distance * 0.12).clamp(20.0, 120.0);
        final spin = displayModel.spin ?? BallSpin.none;

        // Calculate direction and perpendicular for curves
        final diff = endPos - startPos;
        final perpendicular = Vector2(-diff.y, diff.x).normalized();

        Vector2 curvedPosition;
        switch (spin) {
          case BallSpin.left:
            // Left curve: ball curves to the left
            final curveAmount = distance * 0.1;
            final lateralOffset = curveAmount * sin(intraSceneProgress * pi);
            curvedPosition = Vector2.copy(startPos)
              ..lerp(endPos, intraSceneProgress);
            curvedPosition += perpendicular * lateralOffset;
            altitude = arcHeight * sin(intraSceneProgress * pi);
            break;

          case BallSpin.right:
            // Right curve: ball curves to the right
            final curveAmount = distance * 0.1;
            final lateralOffset = curveAmount * sin(intraSceneProgress * pi);
            curvedPosition = Vector2.copy(startPos)
              ..lerp(endPos, intraSceneProgress);
            curvedPosition -= perpendicular * lateralOffset;
            altitude = arcHeight * sin(intraSceneProgress * pi);
            break;

          case BallSpin.knuckleball:
            // Knuckleball: S-curve using cubic Bezier
            altitude = arcHeight * sin(intraSceneProgress * pi);
            final curveAmount =
                distance * 0.3; // Increased to 30% for MORE visible S

            // Control points positioned to create visible S-curve
            // CP1 at 25% of path, pushed LEFT
            // CP2 at 75% of path, pushed RIGHT
            final controlPoint1 =
                startPos + (diff * 0.25) + (perpendicular * curveAmount);
            final controlPoint2 =
                startPos + (diff * 0.75) - (perpendicular * curveAmount);

            final t = intraSceneProgress;
            final oneMinusT = 1 - t;
            curvedPosition = (startPos * (oneMinusT * oneMinusT * oneMinusT)) +
                (controlPoint1 * (3 * (oneMinusT * oneMinusT) * t)) +
                (controlPoint2 * (3 * oneMinusT * (t * t))) +
                (endPos * (t * t * t));
            break;

          case BallSpin.none:
            curvedPosition = Vector2.copy(startPos)
              ..lerp(endPos, intraSceneProgress);
            altitude = arcHeight * sin(intraSceneProgress * pi);
            break;
        }

        displayModel.offset = curvedPosition;
        final arcFactor = sin(intraSceneProgress * pi);
        final baseSize = displayModel.size?.x ?? 32.0;
        visualSize = Vector2.all(baseSize * (1 + (1.3 - 1) * arcFactor));
      }
    }

    Component? component;
    if (displayModel is PlayerModel) {
      component = PlayerComponent(object: displayModel);
    } else if (displayModel is EquipmentModel) {
      final equipmentComponent = EquipmentComponent(object: displayModel);
      equipmentComponent.altitude = altitude;
      equipmentComponent.visualSize = visualSize;
      component = equipmentComponent;
    } else if (displayModel is LineModelV2) {
      component = LineDrawerComponentV2(lineModelV2: displayModel);
    } else if (displayModel is CircleShapeModel) {
      component = CircleShapeDrawerComponent(circleModel: displayModel);
    } else if (displayModel is SquareShapeModel) {
      component = SquareShapeDrawerComponent(squareModel: displayModel);
    } else if (displayModel is PolygonShapeModel) {
      component = PolygonShapeDrawerComponent(polygonModel: displayModel);
    } else if (displayModel is TextModel) {
      component = TextFieldComponent(object: displayModel);
    }

    if (component != null) {
      await add(component);
    }
  }

  @override
  Future<void> performStartAnimationFromBeginning() async {
    if (_playbackState == PlaybackState.preparing) return;
    if (paused) resumeEngine();
    _playbackState = PlaybackState.preparing;
    _currentTotalElapsedTime = Duration.zero;
    await _renderStateForTime(Duration.zero);
    _playbackState = PlaybackState.playing;
  }

  @override
  Future<void> performResumeAnimation() async {
    if (_playbackState != PlaybackState.paused) return;
    if (paused) resumeEngine();

    if (_currentTotalElapsedTime >= _totalAnimationDuration) {
      await performStartAnimationFromBeginning();
    } else {
      _playbackState = PlaybackState.playing;
    }
  }

  @override
  void performPauseAnimation() {
    if (_playbackState != PlaybackState.playing) return;
    _playbackState = PlaybackState.paused;
  }

  @override
  void performHardResetAnimation() {
    _playbackState = PlaybackState.stopped;
    _currentTotalElapsedTime = Duration.zero;
    _renderStateForTime(Duration.zero);
  }

  void beginScrubbing() {
    // This method's ONLY job is to set the state.
    // The decision to pause is now handled by the UI widget.
    _playbackState = PlaybackState.scrubbing;
  }

  void seekToProgress(double progress) {
    // THIS IS THE FIX: Only allow seeking if the state is 'scrubbing'.
    // This prevents the seek from happening on the initial tap when the state is 'playing' or 'paused'.
    if (_playbackState != PlaybackState.scrubbing ||
        !isLoaded ||
        _isRendering) {
      return;
    }

    final targetTime = _totalAnimationDuration * progress;
    _currentTotalElapsedTime = targetTime;
    _renderStateForTime(targetTime);
  }

  void endScrubbing() {
    _playbackState = PlaybackState.paused;
  }

  @override
  void performSetAnimationPace(double newPaceFactor) {
    if (newPaceFactor > 0) {
      _scenePaceFactor = newPaceFactor;
    }
  }

  @override
  void performStopAnimation({bool hardReset = false}) {
    if (isMounted) {
      _playbackState = PlaybackState.stopped;
      _currentTotalElapsedTime = Duration.zero;
    }
  }
}

/// 3rd end
