import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/v2/engine/playback_engine.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';

/// Immutable state for animation playback.
class AnimationPlaybackState {
  final PlaybackState playbackState;
  final double progress;
  final int currentSceneIndex;
  final double speedFactor;
  final AnimationModelV2? animation;

  const AnimationPlaybackState({
    this.playbackState = PlaybackState.stopped,
    this.progress = 0.0,
    this.currentSceneIndex = 0,
    this.speedFactor = 1.0,
    this.animation,
  });

  bool get isPlaying => playbackState == PlaybackState.playing;
  bool get isPaused => playbackState == PlaybackState.paused;
  bool get isStopped => playbackState == PlaybackState.stopped;
  bool get isScrubbing => playbackState == PlaybackState.scrubbing;

  /// Whether playback is active in any form (playing, paused, or scrubbing).
  bool get isActive =>
      playbackState != PlaybackState.stopped &&
      playbackState != PlaybackState.preparing;

  AnimationPlaybackState copyWith({
    PlaybackState? playbackState,
    double? progress,
    int? currentSceneIndex,
    double? speedFactor,
    Object? animation = _sentinel,
  }) {
    return AnimationPlaybackState(
      playbackState: playbackState ?? this.playbackState,
      progress: progress ?? this.progress,
      currentSceneIndex: currentSceneIndex ?? this.currentSceneIndex,
      speedFactor: speedFactor ?? this.speedFactor,
      animation: animation == _sentinel
          ? this.animation
          : animation as AnimationModelV2?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnimationPlaybackState) return false;
    return playbackState == other.playbackState &&
        progress == other.progress &&
        currentSceneIndex == other.currentSceneIndex &&
        speedFactor == other.speedFactor &&
        animation == other.animation;
  }

  @override
  int get hashCode => Object.hash(
        playbackState,
        progress,
        currentSceneIndex,
        speedFactor,
        animation,
      );
}

const Object _sentinel = Object();

/// Manages animation playback and drives [BoardNotifier] with
/// interpolated scenes.
///
/// Replaces V1's `AnimationPlaybackMixin` state management.
/// The actual Ticker lives in the widget layer — this notifier
/// receives `onTick()` calls and is fully testable without Flutter.
class AnimationNotifier extends StateNotifier<AnimationPlaybackState> {
  final BoardNotifier _boardNotifier;
  PlaybackEngine? _engine;

  /// Saved editing scene — restored when playback stops.
  SceneModelV2? _savedEditingScene;

  AnimationNotifier({
    required BoardNotifier boardNotifier,
  })  : _boardNotifier = boardNotifier,
        super(const AnimationPlaybackState());

  // ---------------------------------------------------------------------------
  // Playback control
  // ---------------------------------------------------------------------------

  /// Load an animation for playback (does not start playing).
  void loadAnimation(AnimationModelV2 animation) {
    stop();
    state = state.copyWith(animation: animation);
  }

  /// Start playback from the beginning.
  void play() {
    final anim = state.animation;
    if (anim == null || anim.animationScenes.isEmpty) return;

    _saveEditingState();
    _engine = PlaybackEngine(animation: anim);
    _engine!.setSpeed(state.speedFactor);

    state = state.copyWith(
      playbackState: PlaybackState.playing,
      progress: 0.0,
      currentSceneIndex: 0,
    );

    // Render first frame immediately
    final frame = _engine!.seekToProgress(0.0);
    _pushFrameToBoard(frame);
  }

  /// Resume from paused or scrubbing state.
  void resume() {
    if (_engine == null) return;
    if (!state.isPaused && !state.isScrubbing) return;

    _engine!.setSpeed(state.speedFactor);
    state = state.copyWith(playbackState: PlaybackState.playing);
  }

  /// Pause playback.
  void pause() {
    if (!state.isPlaying) return;
    state = state.copyWith(playbackState: PlaybackState.paused);
  }

  /// Stop playback and restore the editing scene.
  void stop() {
    if (state.isStopped) return;

    _engine = null;
    state = state.copyWith(
      playbackState: PlaybackState.stopped,
      progress: 0.0,
      currentSceneIndex: 0,
    );
    _restoreEditingState();
  }

  /// Enter scrubbing mode.
  void beginScrubbing() {
    if (_engine == null) return;
    state = state.copyWith(playbackState: PlaybackState.scrubbing);
  }

  /// Seek to a specific progress while scrubbing.
  void seekToProgress(double progress) {
    if (_engine == null) return;

    final frame = _engine!.seekToProgress(progress);
    _pushFrameToBoard(frame);
    state = state.copyWith(
      progress: frame.progress,
      currentSceneIndex: frame.currentSceneIndex,
    );
  }

  /// Exit scrubbing mode (enters paused state).
  void endScrubbing() {
    if (!state.isScrubbing) return;
    state = state.copyWith(playbackState: PlaybackState.paused);
  }

  /// Set playback speed.
  void setSpeed(double factor) {
    state = state.copyWith(speedFactor: factor.clamp(0.1, 10.0));
    _engine?.setSpeed(state.speedFactor);
  }

  // ---------------------------------------------------------------------------
  // Ticker callback — called by the widget layer
  // ---------------------------------------------------------------------------

  /// Process one animation frame. Returns true if still playing.
  bool onTick(Duration elapsed) {
    if (!state.isPlaying || _engine == null) return false;

    final frame = _engine!.tick(elapsed);
    _pushFrameToBoard(frame);

    state = state.copyWith(
      progress: frame.progress,
      currentSceneIndex: frame.currentSceneIndex,
    );

    if (frame.isComplete) {
      _engine = null;
      state = state.copyWith(
        playbackState: PlaybackState.stopped,
        progress: 1.0,
      );
      _restoreEditingState();
      return false;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _pushFrameToBoard(PlaybackFrame frame) {
    _boardNotifier.replaceSceneForPlayback(frame.scene);
  }

  void _saveEditingState() {
    _savedEditingScene = _boardNotifier.state.currentScene;
  }

  void _restoreEditingState() {
    if (_savedEditingScene != null) {
      _boardNotifier.loadScene(_savedEditingScene!);
      _savedEditingScene = null;
    }
  }
}
