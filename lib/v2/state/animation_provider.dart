import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/v2/state/animation_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';

/// Riverpod provider for animation playback.
///
/// Depends on [boardProviderV2] — the AnimationNotifier drives
/// the BoardNotifier with interpolated scenes during playback.
///
/// Usage:
/// ```dart
/// // Start playback:
/// final notifier = ref.read(animationProviderV2.notifier);
/// notifier.loadAnimation(animation);
/// notifier.play();
///
/// // Watch playback state:
/// final playbackState = ref.watch(animationProviderV2);
/// if (playbackState.isPlaying) { ... }
/// ```
final animationProviderV2 = StateNotifierProvider.autoDispose<
    AnimationNotifier, AnimationPlaybackState>(
  (ref) {
    final boardNotifier = ref.read(boardProviderV2.notifier);
    return AnimationNotifier(boardNotifier: boardNotifier);
  },
);
