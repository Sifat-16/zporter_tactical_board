import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/presentation/board_widget.dart';
import 'package:zporter_tactical_board/v2/state/animation_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';

/// Wraps [TacticBoardV2] with animation playback support.
///
/// During playback (playing, paused, or scrubbing):
///   - Gesture interactions are disabled (no drag/tap)
///   - A [Ticker] drives [AnimationNotifier.onTick()] at 60fps
///
/// When stopped, this widget behaves identically to [TacticBoardV2].
class AnimatedTacticBoardV2 extends ConsumerStatefulWidget {
  /// Called when the user taps an element (disabled during playback).
  final ValueChanged<BoardElement?>? onElementSelected;

  /// Called when the user drags an element (disabled during playback).
  final void Function(String elementId, Offset newRelativeOffset)?
      onElementMoved;

  /// Called when the user double-taps an element (disabled during playback).
  final ValueChanged<BoardElement>? onElementDoubleTap;

  /// Called when the user taps empty space (disabled during playback).
  final VoidCallback? onBoardTap;

  /// Called when a drag starts (disabled during playback).
  final ValueChanged<String>? onDragStart;

  /// Called when a drag ends (disabled during playback).
  final VoidCallback? onDragEnd;

  const AnimatedTacticBoardV2({
    super.key,
    this.onElementSelected,
    this.onElementMoved,
    this.onElementDoubleTap,
    this.onBoardTap,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  ConsumerState<AnimatedTacticBoardV2> createState() =>
      _AnimatedTacticBoardV2State();
}

class _AnimatedTacticBoardV2State extends ConsumerState<AnimatedTacticBoardV2>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTickTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastTickTime;
    _lastTickTime = elapsed;

    final notifier = ref.read(animationProviderV2.notifier);
    final stillPlaying = notifier.onTick(delta);
    if (!stillPlaying) {
      _ticker.stop();
      _lastTickTime = Duration.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final animState = ref.watch(animationProviderV2);
    final boardState = ref.watch(boardProviderV2);

    final isPlaybackActive = animState.isActive;

    // Start ticker when transitioning to playing
    if (animState.isPlaying && !_ticker.isActive) {
      _lastTickTime = Duration.zero;
      _ticker.start();
    } else if (!animState.isPlaying && _ticker.isActive) {
      _ticker.stop();
      _lastTickTime = Duration.zero;
    }

    return TacticBoardV2(
      state: boardState,
      // Disable interactions during playback
      onElementSelected:
          isPlaybackActive ? null : widget.onElementSelected,
      onElementMoved:
          isPlaybackActive ? null : widget.onElementMoved,
      onElementDoubleTap:
          isPlaybackActive ? null : widget.onElementDoubleTap,
      onBoardTap: isPlaybackActive ? null : widget.onBoardTap,
      onDragStart: isPlaybackActive ? null : widget.onDragStart,
      onDragEnd: isPlaybackActive ? null : widget.onDragEnd,
    );
  }
}
