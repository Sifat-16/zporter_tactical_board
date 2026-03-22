import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';

/// Riverpod provider for the V2 tactical board.
///
/// Replaces V1's `boardProvider = StateNotifierProvider<BoardController, BoardState>`.
///
/// The provider is auto-disposed when no longer watched, which is appropriate
/// for board screens that come and go. Override with `boardProviderV2.overrideWith`
/// in tests or when injecting a custom [BoardNotifier].
///
/// Usage:
/// ```dart
/// // In a widget:
/// final boardState = ref.watch(boardProviderV2);
/// final notifier = ref.read(boardProviderV2.notifier);
/// notifier.addElement(player);
///
/// // Override for tests:
/// ProviderScope(
///   overrides: [
///     boardProviderV2.overrideWith((ref) => BoardNotifier(
///       initialState: BoardStateV2(currentScene: testScene),
///     )),
///   ],
///   child: MyWidget(),
/// );
/// ```
final boardProviderV2 =
    StateNotifierProvider.autoDispose<BoardNotifier, BoardStateV2>(
  (ref) {
    final emptyScene = SceneModelV2.empty(id: 'default', userId: '');
    return BoardNotifier(
      initialState: BoardStateV2(currentScene: emptyScene),
    );
  },
);
