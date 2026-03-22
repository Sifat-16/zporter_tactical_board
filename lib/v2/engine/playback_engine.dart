import 'package:zporter_tactical_board/v2/engine/scene_interpolator.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';

/// Output of a single playback engine tick.
class PlaybackFrame {
  /// The interpolated scene at this point in time.
  final SceneModelV2 scene;

  /// Overall animation progress (0.0–1.0).
  final double progress;

  /// Index of the current scene being displayed.
  final int currentSceneIndex;

  /// Progress within the current scene transition (0.0–1.0).
  final double intraSceneProgress;

  /// Whether the animation has completed.
  final bool isComplete;

  const PlaybackFrame({
    required this.scene,
    required this.progress,
    required this.currentSceneIndex,
    required this.intraSceneProgress,
    required this.isComplete,
  });
}

/// Pure Dart animation playback engine.
///
/// Computes interpolated scenes for any point in time within an animation.
/// Does not own a Ticker — receives tick calls from external code (the widget
/// layer). This makes the engine fully testable without Flutter.
///
/// Replaces V1's `AnimationPlaybackMixin` timing and scene-selection logic.
class PlaybackEngine {
  final AnimationModelV2 animation;

  Duration _elapsedTime = Duration.zero;
  double _speedFactor = 1.0;

  PlaybackEngine({required this.animation});

  // ---------------------------------------------------------------------------
  // Computed properties
  // ---------------------------------------------------------------------------

  /// Total animation duration (sum of all scene durations).
  Duration get totalDuration {
    if (animation.animationScenes.isEmpty) return Duration.zero;
    return animation.animationScenes.fold(
      Duration.zero,
      (sum, scene) => sum + scene.sceneDuration,
    );
  }

  /// Overall progress (0.0–1.0).
  double get currentProgress {
    final total = totalDuration.inMicroseconds;
    if (total == 0) return 0.0;
    return (_elapsedTime.inMicroseconds / total).clamp(0.0, 1.0);
  }

  Duration get elapsedTime => _elapsedTime;
  double get speedFactor => _speedFactor;

  // ---------------------------------------------------------------------------
  // Core methods
  // ---------------------------------------------------------------------------

  /// Advance by [elapsed] (scaled by speed factor) and return the frame.
  PlaybackFrame tick(Duration elapsed) {
    final scaledMicros =
        (elapsed.inMicroseconds * _speedFactor).round();
    _elapsedTime += Duration(microseconds: scaledMicros);

    final total = totalDuration;
    if (_elapsedTime > total) {
      _elapsedTime = total;
    }

    return _computeFrameAtTime(_elapsedTime);
  }

  /// Seek to an overall [progress] (0.0–1.0).
  PlaybackFrame seekToProgress(double progress) {
    final p = progress.clamp(0.0, 1.0);
    _elapsedTime = Duration(
      microseconds: (totalDuration.inMicroseconds * p).round(),
    );
    return _computeFrameAtTime(_elapsedTime);
  }

  /// Seek to an absolute [time].
  PlaybackFrame seekToTime(Duration time) {
    _elapsedTime = Duration(
      microseconds: time.inMicroseconds.clamp(
        0,
        totalDuration.inMicroseconds,
      ),
    );
    return _computeFrameAtTime(_elapsedTime);
  }

  /// Set playback speed (1.0 = normal, 2.0 = double, 0.5 = half).
  void setSpeed(double factor) {
    _speedFactor = factor.clamp(0.1, 10.0);
  }

  /// Reset to beginning.
  PlaybackFrame reset() {
    _elapsedTime = Duration.zero;
    return _computeFrameAtTime(_elapsedTime);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  PlaybackFrame _computeFrameAtTime(Duration targetTime) {
    final scenes = animation.animationScenes;

    if (scenes.isEmpty) {
      return PlaybackFrame(
        scene: SceneModelV2.empty(id: 'empty', userId: ''),
        progress: 0.0,
        currentSceneIndex: 0,
        intraSceneProgress: 0.0,
        isComplete: true,
      );
    }

    if (scenes.length == 1) {
      return PlaybackFrame(
        scene: scenes.first,
        progress: currentProgress,
        currentSceneIndex: 0,
        intraSceneProgress: 0.0,
        isComplete: targetTime >= totalDuration,
      );
    }

    final loc = _findSceneAtTime(targetTime);
    final currentScene = scenes[loc.sceneIndex];

    SceneModelV2 interpolatedScene;
    if (loc.sceneIndex == 0) {
      // First scene — no 'from' to interpolate from
      interpolatedScene = currentScene;
    } else {
      final prevScene = scenes[loc.sceneIndex - 1];
      interpolatedScene = SceneInterpolator.interpolate(
        from: prevScene,
        to: currentScene,
        progress: loc.intraSceneProgress,
      );
    }

    return PlaybackFrame(
      scene: interpolatedScene,
      progress: currentProgress,
      currentSceneIndex: loc.sceneIndex,
      intraSceneProgress: loc.intraSceneProgress,
      isComplete: targetTime >= totalDuration,
    );
  }

  /// Find which scene transition contains [targetTime].
  ({int sceneIndex, Duration timeIntoScene, double intraSceneProgress})
      _findSceneAtTime(Duration targetTime) {
    final scenes = animation.animationScenes;
    Duration cumulative = Duration.zero;

    for (int i = 0; i < scenes.length; i++) {
      final sceneDur = scenes[i].sceneDuration;
      if (targetTime <= cumulative + sceneDur ||
          i == scenes.length - 1) {
        final timeIntoScene = targetTime - cumulative;
        final intraProgress = sceneDur.inMicroseconds > 0
            ? (timeIntoScene.inMicroseconds / sceneDur.inMicroseconds)
                .clamp(0.0, 1.0)
            : 0.0;
        return (
          sceneIndex: i,
          timeIntoScene: timeIntoScene,
          intraSceneProgress: intraProgress,
        );
      }
      cumulative += sceneDur;
    }

    // Fallback (shouldn't reach here)
    return (
      sceneIndex: scenes.length - 1,
      timeIntoScene: Duration.zero,
      intraSceneProgress: 1.0,
    );
  }
}
