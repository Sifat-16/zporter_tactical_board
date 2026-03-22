import 'dart:developer' as developer;

import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/services/sync/models/sync_operation.dart';
import 'package:zporter_tactical_board/app/services/sync/sync_queue_manager.dart';
import 'package:zporter_tactical_board/v2/data/datasources/animation_datasource_v2.dart';
import 'package:zporter_tactical_board/v2/data/repositories/animation_repository_v2.dart';
import 'package:zporter_tactical_board/v2/models/animation_collection.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';

/// Local-first cache repository that reads from Sembast first and
/// falls back to Firestore. Writes go to local first, then enqueue
/// a sync operation for background remote persistence.
///
/// Mirrors V1's [AnimationCacheRepositoryImpl] pattern.
class AnimationCacheRepositoryV2 implements AnimationRepositoryV2 {
  final AnimationDatasourceV2 _localDatasource;
  final AnimationDatasourceV2 _remoteDatasource;
  final SyncQueueManager? _syncQueueManager;

  AnimationCacheRepositoryV2({
    required AnimationDatasourceV2 localDatasource,
    required AnimationDatasourceV2 remoteDatasource,
    SyncQueueManager? syncQueueManager,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _syncQueueManager = syncQueueManager;

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  @override
  Future<List<AnimationCollectionModelV2>> getAllCollections(
    String userId,
  ) async {
    try {
      // Try local first
      final localCollections =
          await _localDatasource.getAllCollections(userId);

      if (localCollections.isNotEmpty) {
        // Background refresh from remote (fire-and-forget)
        _backgroundRefresh(userId);
        return localCollections;
      }

      // Local empty — fetch from remote and cache locally
      final remoteCollections =
          await _remoteDatasource.getAllCollections(userId);
      for (final collection in remoteCollections) {
        await _localDatasource.saveCollection(collection);
      }
      return remoteCollections;
    } catch (e) {
      developer.log(
        'Error in getAllCollections for userId=$userId',
        name: 'AnimationCacheRepositoryV2',
        error: e,
      );
      // Graceful fallback
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Write — Collection
  // ---------------------------------------------------------------------------

  @override
  Future<AnimationCollectionModelV2> saveCollection(
    AnimationCollectionModelV2 collection,
  ) async {
    // Assign ID if needed
    final id = collection.id.isEmpty
        ? RandomGenerator.generateId()
        : collection.id;
    final toSave = collection.copyWith(
      id: id,
      updatedAt: DateTime.now(),
      hasPendingUpdates: true,
    );

    // Save locally first
    final saved = await _localDatasource.saveCollection(toSave);

    // Enqueue remote sync
    _enqueueSync(
      collectionId: saved.id,
      userId: saved.userId,
      type: collection.id.isEmpty
          ? SyncOperationType.create
          : SyncOperationType.update,
    );

    return saved;
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    // Get collection to find userId for sync operation
    final existing = await _localDatasource.getCollection(collectionId);
    final userId = existing?.userId ?? '';

    await _localDatasource.deleteCollection(collectionId);

    _enqueueSync(
      collectionId: collectionId,
      userId: userId,
      type: SyncOperationType.delete,
    );
  }

  // ---------------------------------------------------------------------------
  // Write — Animation (within collection)
  // ---------------------------------------------------------------------------

  @override
  Future<AnimationModelV2> saveAnimation(
    AnimationModelV2 animation,
    String collectionId,
  ) async {
    final collection = await _localDatasource.getCollection(collectionId);
    if (collection == null) {
      throw Exception('Collection not found: $collectionId');
    }

    final animId = animation.id.isEmpty
        ? RandomGenerator.generateId()
        : animation.id;
    final toSave = animation.copyWith(
      id: animId,
      collectionId: collectionId,
      updatedAt: DateTime.now(),
    );

    // Replace or add animation in collection
    final animations = List<AnimationModelV2>.of(collection.animations);
    final existingIndex = animations.indexWhere((a) => a.id == animId);
    if (existingIndex >= 0) {
      animations[existingIndex] = toSave;
    } else {
      animations.add(toSave);
    }

    final updatedCollection = collection.copyWith(
      animations: animations,
      updatedAt: DateTime.now(),
      hasPendingUpdates: true,
    );
    await _localDatasource.saveCollection(updatedCollection);

    _enqueueSync(
      collectionId: collectionId,
      userId: collection.userId,
      type: SyncOperationType.update,
    );

    return toSave;
  }

  @override
  Future<void> deleteAnimation(
    String animationId,
    String collectionId,
  ) async {
    final collection = await _localDatasource.getCollection(collectionId);
    if (collection == null) return;

    final animations = collection.animations
        .where((a) => a.id != animationId)
        .toList();

    final updatedCollection = collection.copyWith(
      animations: animations,
      updatedAt: DateTime.now(),
      hasPendingUpdates: true,
    );
    await _localDatasource.saveCollection(updatedCollection);

    _enqueueSync(
      collectionId: collectionId,
      userId: collection.userId,
      type: SyncOperationType.update,
    );
  }

  // ---------------------------------------------------------------------------
  // Write — Scene (within animation within collection)
  // ---------------------------------------------------------------------------

  @override
  Future<SceneModelV2> saveScene(
    SceneModelV2 scene,
    String animationId,
    String collectionId,
  ) async {
    final collection = await _localDatasource.getCollection(collectionId);
    if (collection == null) {
      throw Exception('Collection not found: $collectionId');
    }

    final animIndex =
        collection.animations.indexWhere((a) => a.id == animationId);
    if (animIndex < 0) {
      throw Exception('Animation not found: $animationId');
    }

    final animation = collection.animations[animIndex];
    final sceneId = scene.id.isEmpty
        ? RandomGenerator.generateId()
        : scene.id;
    final toSave = scene.copyWith(
      id: sceneId,
      updatedAt: DateTime.now(),
    );

    // Replace or add scene
    final scenes = List<SceneModelV2>.of(animation.animationScenes);
    final existingIndex = scenes.indexWhere((s) => s.id == sceneId);
    if (existingIndex >= 0) {
      scenes[existingIndex] = toSave;
    } else {
      scenes.add(toSave);
    }

    final updatedAnim = animation.copyWith(
      animationScenes: scenes,
      updatedAt: DateTime.now(),
    );
    final animations = List<AnimationModelV2>.of(collection.animations);
    animations[animIndex] = updatedAnim;

    final updatedCollection = collection.copyWith(
      animations: animations,
      updatedAt: DateTime.now(),
      hasPendingUpdates: true,
    );
    await _localDatasource.saveCollection(updatedCollection);

    _enqueueSync(
      collectionId: collectionId,
      userId: collection.userId,
      type: SyncOperationType.update,
    );

    return toSave;
  }

  @override
  Future<void> deleteScene(
    String sceneId,
    String animationId,
    String collectionId,
  ) async {
    final collection = await _localDatasource.getCollection(collectionId);
    if (collection == null) return;

    final animIndex =
        collection.animations.indexWhere((a) => a.id == animationId);
    if (animIndex < 0) return;

    final animation = collection.animations[animIndex];
    final scenes = animation.animationScenes
        .where((s) => s.id != sceneId)
        .toList();

    final updatedAnim = animation.copyWith(
      animationScenes: scenes,
      updatedAt: DateTime.now(),
    );
    final animations = List<AnimationModelV2>.of(collection.animations);
    animations[animIndex] = updatedAnim;

    final updatedCollection = collection.copyWith(
      animations: animations,
      updatedAt: DateTime.now(),
      hasPendingUpdates: true,
    );
    await _localDatasource.saveCollection(updatedCollection);

    _enqueueSync(
      collectionId: collectionId,
      userId: collection.userId,
      type: SyncOperationType.update,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Background refresh: fetch remote collections and update local cache,
  /// respecting pending sync operations.
  void _backgroundRefresh(String userId) async {
    try {
      final remoteCollections =
          await _remoteDatasource.getAllCollections(userId);

      // Get IDs with pending sync to avoid overwriting unsynced edits
      final pendingIds = _syncQueueManager != null
          ? await _syncQueueManager.getPendingCollectionIds()
          : <String>{};

      for (final remote in remoteCollections) {
        if (!pendingIds.contains(remote.id)) {
          await _localDatasource.saveCollection(remote);
        }
      }
    } catch (e) {
      developer.log(
        'Background refresh failed for userId=$userId',
        name: 'AnimationCacheRepositoryV2',
        error: e,
      );
      // Swallow — this is best-effort
    }
  }

  /// Enqueue a sync operation if a sync queue manager is available.
  void _enqueueSync({
    required String collectionId,
    required String userId,
    required SyncOperationType type,
  }) {
    if (_syncQueueManager == null) return;

    _syncQueueManager.enqueue(SyncOperation(
      id: RandomGenerator.generateId(),
      type: type,
      collectionId: collectionId,
      userId: userId,
      createdAt: DateTime.now(),
    ));
  }
}
