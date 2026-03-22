import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/v2/data/datasources/local/animation_local_datasource_v2.dart';
import 'package:zporter_tactical_board/v2/data/datasources/remote/animation_remote_datasource_v2.dart';
import 'package:zporter_tactical_board/v2/data/repositories/animation_cache_repository_v2.dart';
import 'package:zporter_tactical_board/v2/data/repositories/animation_repository_v2.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';
import 'package:zporter_tactical_board/v2/state/collection_notifier.dart';

/// Provider for the animation repository.
///
/// Override this to inject a mock repository in tests:
/// ```dart
/// ProviderScope(
///   overrides: [
///     animationRepositoryV2Provider.overrideWithValue(mockRepo),
///   ],
///   child: MyApp(),
/// );
/// ```
final animationRepositoryV2Provider = Provider<AnimationRepositoryV2>(
  (ref) {
    return AnimationCacheRepositoryV2(
      localDatasource: AnimationLocalDatasourceV2(),
      remoteDatasource: AnimationRemoteDatasourceV2(),
    );
  },
);

/// Provider for the collection state notifier.
///
/// Depends on [animationRepositoryV2Provider] and [boardProviderV2].
///
/// Usage:
/// ```dart
/// // Load collections:
/// final notifier = ref.read(collectionProviderV2.notifier);
/// await notifier.loadCollections(userId);
///
/// // Watch state:
/// final state = ref.watch(collectionProviderV2);
/// if (state.isLoading) { ... }
/// ```
final collectionProviderV2 = StateNotifierProvider.autoDispose<
    CollectionNotifier, CollectionState>(
  (ref) {
    final repository = ref.read(animationRepositoryV2Provider);
    final boardNotifier = ref.read(boardProviderV2.notifier);
    return CollectionNotifier(
      repository: repository,
      boardNotifier: boardNotifier,
    );
  },
);
