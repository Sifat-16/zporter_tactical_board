import 'package:bot_toast/bot_toast.dart';
import 'package:zporter_tactical_board/app/config/feature_flags.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/app/services/sync/models/sync_operation.dart';
import 'package:zporter_tactical_board/app/services/sync/sync_queue_manager.dart';
import 'package:zporter_tactical_board/data/admin/datasource/default_animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/datasource/local/animation_local_datasource_impl.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';

import 'default_animation_repository.dart';

class DefaultAnimationRepositoryImpl implements DefaultAnimationRepository {
  final DefaultAnimationDatasource datasource;
  final AnimationLocalDatasourceImpl _localDataSource;
  SyncQueueManager? _syncQueueManager;

  DefaultAnimationRepositoryImpl({
    required this.datasource,
  }) : _localDataSource = AnimationLocalDatasourceImpl() {
    if (FeatureFlags.enableSyncQueue) {
      try {
        _syncQueueManager = sl.get<SyncQueueManager>();
      } catch (e) {
        // SyncQueueManager not available, continue without it
      }
    }
  }

  @override
  Future<List<AnimationModel>> getAllDefaultAnimations() =>
      datasource.getAllDefaultAnimations();

  @override
  Future<AnimationModel> saveDefaultAnimation(
      AnimationModel animationModel) async {
    BotToast.showText(
        text: '🏪 REPO: saveDefaultAnimation called',
        duration: Duration(seconds: 3));
    BotToast.showText(
        text:
            '🏪 OfflineFirst=${FeatureFlags.useOfflineFirstArchitecture}, Queue=${_syncQueueManager != null}',
        duration: Duration(seconds: 3));

    // Check if offline-first is enabled
    if (FeatureFlags.useOfflineFirstArchitecture) {
      BotToast.showText(
          text: '🏪 Using offline-first path', duration: Duration(seconds: 3));
      // ALWAYS use local-first path (even when online)
      // 1. Save to Sembast (local) first (~30-50ms) - ONLY await this
      final savedLocalModel =
          await _localDataSource.saveDefaultAnimationModel(animationModel);
      BotToast.showText(
          text: '🏪 Saved to local Sembast!', duration: Duration(seconds: 3));

      // 2. Return IMMEDIATELY (UI gets unblocked here - user sees instant save)
      // 3. Queue for background Firebase sync (fire-and-forget, NO await)
      if (_syncQueueManager != null && FeatureFlags.enableSyncQueue) {
        _syncQueueManager!.enqueue(
          SyncOperation(
            id: '${animationModel.id}_${DateTime.now().millisecondsSinceEpoch}',
            type: SyncOperationType.update,
            userId: animationModel.userId,
            collectionId: animationModel.id,
            createdAt: DateTime.now(),
            priority: SyncPriority.high,
            metadata: {
              'dataType': 'singleDefaultAnimation',
              'animationId': animationModel.id,
            },
          ),
        );
        BotToast.showText(
            text: '🏪 Queued for sync!', duration: Duration(seconds: 3));
      }

      return savedLocalModel;
    } else {
      BotToast.showText(
          text: '🏪 Using LEGACY Firebase path',
          duration: Duration(seconds: 3));
      // LEGACY: Direct Firebase save (blocks UI for ~470ms)
      return datasource.saveDefaultAnimation(animationModel);
    }
  }

  @override
  Future<void> deleteDefaultAnimation(String animationId) =>
      datasource.deleteDefaultAnimation(animationId);

  @override
  Future<List<AnimationCollectionModel>> getAllDefaultAnimationCollections() =>
      datasource.getAllDefaultAnimationCollections();

  @override
  Future<AnimationCollectionModel> saveDefaultAnimationCollection(
          AnimationCollectionModel collection) =>
      datasource.saveDefaultAnimationCollection(collection);

  @override
  Future<void> deleteDefaultAnimationCollection(String collectionId) =>
      datasource.deleteDefaultAnimationCollection(collectionId);

  @override
  Future<void> saveAllDefaultAnimationCollections(
          List<AnimationCollectionModel> collections) =>
      datasource.saveAllDefaultAnimationCollections(collections);

  @override
  Future<List<AnimationModel>> getOrphanedDefaultAnimations() =>
      datasource.getOrphanedDefaultAnimations();

  @override
  Future<void> saveAllDefaultAnimations(List<AnimationModel> animations) =>
      datasource.saveAllDefaultAnimations(animations);
}
