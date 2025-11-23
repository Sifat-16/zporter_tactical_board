import 'package:logger/logger.dart';
// Your project specific imports
import 'package:zporter_tactical_board/app/config/feature_flags.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart'; // For zlog
import 'package:zporter_tactical_board/app/services/connectivity_service.dart';
import 'package:zporter_tactical_board/app/services/sync/models/sync_operation.dart';
import 'package:zporter_tactical_board/app/services/sync/sync_queue_manager.dart';
import 'package:zporter_tactical_board/app/services/storage/image_storage_service.dart';
import 'package:zporter_tactical_board/app/services/storage/image_conversion_service.dart';
import 'package:zporter_tactical_board/data/animation/datasource/animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/animation/model/history_model.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';

class AnimationCacheRepositoryImpl implements AnimationRepository {
  final AnimationDatasource _localDs;
  final AnimationDatasource _remoteDs;
  final SyncQueueManager? _syncQueueManager; // Optional, Phase 2 feature
  final ImageStorageService? _imageStorageService; // Phase 2 Week 2

  AnimationCacheRepositoryImpl({
    required AnimationDatasource localDatasource,
    required AnimationDatasource remoteDatasource,
    SyncQueueManager? syncQueueManager,
    ImageStorageService? imageStorageService,
  })  : _localDs = localDatasource,
        _remoteDs = remoteDatasource,
        _syncQueueManager = syncQueueManager,
        _imageStorageService = imageStorageService;

  // --- READ OPERATIONS ---
  // ... (Keep the previous Read implementations with fallback) ...
  @override
  Future<List<AnimationCollectionModel>> getAllAnimationCollection({
    required String userId,
  }) async {
    zlog(
      level: Level.debug,
      data:
          "[Repo] GET All Collections: Attempting REMOTE first (Firestore may use cache)...",
    );
    try {
      final remoteCollections = await _remoteDs.getAllAnimationCollection(
        userId: userId,
      );
      zlog(
        level: Level.info,
        data:
            "[Repo] Fetched ${remoteCollections.length} collections from REMOTE (or Firestore cache).",
      );
      zlog(
        level: Level.debug,
        data: "[Repo] Updating LOCAL Sembast cache (All Collections)...",
      );
      await _updateLocalCollections(remoteCollections);
      zlog(
        level: Level.debug,
        data: "[Repo] LOCAL Sembast cache (All Collections) updated.",
      );
      zlog(
        level: Level.debug,
        data:
            "[Repo] Reading updated collections from LOCAL Sembast to return.",
      );
      final localCollections = await _localDs.getAllAnimationCollection(
        userId: userId,
      );
      zlog(
        level: Level.info,
        data:
            "[Repo] Returning ${localCollections.length} collections from LOCAL Sembast after sync.",
      );
      return localCollections;
    } catch (e) {
      zlog(
        level: Level.warning,
        data:
            "[Repo] Remote fetch/sync failed for All Collections: $e. FALLING BACK TO LOCAL Sembast cache.",
      );
      try {
        final localCollections = await _localDs.getAllAnimationCollection(
          userId: userId,
        );
        zlog(
          level: Level.info,
          data:
              "[Repo] Fallback: Returning ${localCollections.length} collections from LOCAL Sembast (potentially stale).",
        );
        return localCollections;
      } catch (localError, localStackTrace) {
        zlog(
          level: Level.error,
          data:
              "[Repo] Fallback FAILED: Error reading from LOCAL Sembast storage: $localError\n$localStackTrace",
        );
        throw Exception(
          "Failed to get animation collections from both remote and local storage: $localError",
        );
      }
    }
  }

  Future<void> _updateLocalCollections(
    List<AnimationCollectionModel> collections,
  ) async {
    try {
      // CRITICAL FIX: Check for pending sync operations before overwriting
      // If sync queue is available, get collections with unsynced changes
      Set<String> collectionsWithPendingChanges = {};

      if (FeatureFlags.enableSyncQueue && _syncQueueManager != null) {
        collectionsWithPendingChanges =
            await _syncQueueManager.getPendingCollectionIds();

        if (collectionsWithPendingChanges.isNotEmpty) {
          zlog(
            level: Level.warning,
            data:
                "[Repo] Found ${collectionsWithPendingChanges.length} collections with pending sync. Will NOT overwrite them.",
          );
        }
      }

      // Update only collections that don't have pending changes
      int skippedCount = 0;
      int updatedCount = 0;

      for (final collection in collections) {
        // Skip collections with pending sync operations to preserve local changes
        if (collectionsWithPendingChanges.contains(collection.id)) {
          skippedCount++;
          zlog(
            level: Level.debug,
            data:
                "[Repo] Skipping collection ${collection.id} - has pending sync operations",
          );
          continue;
        }

        // Safe to update - no pending changes
        await _localDs.saveAnimationCollection(
          animationCollectionModel: collection,
        );
        updatedCount++;
      }

      zlog(
        level: Level.info,
        data:
            "[Repo] Cache update complete: $updatedCount updated, $skippedCount skipped (pending sync)",
      );
    } catch (e) {
      zlog(
        level: Level.error,
        data: "[Repo] Error during sync Sembast cache update (Collections): $e",
      );
      rethrow;
    }
  }

  @override
  Future<List<AnimationItemModel>> getDefaultAnimations({
    required String userId,
  }) async {
    // CRITICAL FIX: Check if there are pending sync operations for default animations
    // If yes, return from LOCAL to avoid overwriting unsynced changes
    if (FeatureFlags.enableSyncQueue && _syncQueueManager != null) {
      final hasPending = await _syncQueueManager
          .hasPendingChanges('default_animations_$userId');
      if (hasPending) {
        zlog(
          level: Level.warning,
          data:
              "[Repo] GET Default Animations: PENDING SYNC detected for user $userId. Returning LOCAL data to preserve unsynced changes.",
        );
        try {
          final localItems =
              await _localDs.getDefaultAnimations(userId: userId);
          zlog(
            level: Level.info,
            data:
                "[Repo] Returning ${localItems.length} default animations from LOCAL (has pending sync).",
          );
          return localItems;
        } catch (localError) {
          zlog(
            level: Level.error,
            data:
                "[Repo] Failed to read local default animations despite pending sync: $localError",
          );
          // Continue to try remote as fallback
        }
      }
    }

    zlog(
      level: Level.debug,
      data:
          "[Repo] GET Default Animations: Attempting REMOTE first (Firestore may use cache)...",
    );
    try {
      final remoteItems = await _remoteDs.getDefaultAnimations(userId: userId);
      zlog(
        level: Level.info,
        data:
            "[Repo] Fetched ${remoteItems.length} default animations from REMOTE (or Firestore cache).",
      );
      zlog(
        level: Level.debug,
        data: "[Repo] Updating LOCAL Sembast cache (Default Animations)...",
      );
      await _localDs.saveDefaultAnimations(
        animationItems: remoteItems,
        userId: userId,
      );
      zlog(
        level: Level.debug,
        data: "[Repo] LOCAL Sembast cache (Default Animations) updated.",
      );
      zlog(
        level: Level.debug,
        data:
            "[Repo] Reading updated default animations from LOCAL Sembast to return.",
      );
      final localItems = await _localDs.getDefaultAnimations(userId: userId);
      zlog(
        level: Level.info,
        data:
            "[Repo] Returning ${localItems.length} default animations from LOCAL Sembast after sync.",
      );
      return localItems;
    } catch (e) {
      zlog(
        level: Level.warning,
        data:
            "[Repo] Remote fetch/sync failed for Default Animations: $e. FALLING BACK TO LOCAL Sembast cache.",
      );
      try {
        final localItems = await _localDs.getDefaultAnimations(userId: userId);
        zlog(
          level: Level.info,
          data:
              "[Repo] Fallback: Returning ${localItems.length} default animations from LOCAL Sembast (potentially stale).",
        );
        return localItems;
      } catch (localError, localStackTrace) {
        zlog(
          level: Level.error,
          data:
              "[Repo] Fallback FAILED: Error reading defaults from LOCAL Sembast storage: $localError\n$localStackTrace",
        );
        throw Exception(
          "Failed to get default animations from both remote and local storage: $localError",
        );
      }
    }
  }

  /// Phase 2 Week 2: Migrate images from base64 to Firebase Storage URLs
  /// OFFLINE-FIRST: Only migrates when online, preserves base64 offline
  Future<AnimationCollectionModel> _migrateCollectionImages(
    AnimationCollectionModel collection,
  ) async {
    // Check if image optimization is enabled
    if (!FeatureFlags.enableImageOptimization ||
        !FeatureFlags.enableAutoImageUpload ||
        _imageStorageService == null) {
      return collection;
    }

    // CRITICAL: Check connectivity before attempting upload
    final isOnline = ConnectivityService.statusNotifier.value.isOnline;
    if (!isOnline) {
      zlog(
        level: Level.info,
        data:
            '[Repo] OFFLINE: Skipping image migration for ${collection.id}. Images will be migrated when online.',
      );
      // Return original collection with base64 images intact
      // When sync queue processes this later online, images will be migrated then
      return collection;
    }

    zlog(
      level: Level.debug,
      data:
          '[Repo] ONLINE: Checking collection ${collection.id} for images needing migration...',
    );

    bool hasChanges = false;
    final migratedAnimations = <AnimationModel>[];

    // Process each animation in the collection
    for (final animation in collection.animations) {
      final migratedScenes = <AnimationItemModel>[];
      bool animationChanged = false;

      // Process each scene in the animation
      for (final scene in animation.animationScenes) {
        final migratedComponents = [...scene.components];
        bool sceneChanged = false;

        // Process each component in the scene
        for (int i = 0; i < migratedComponents.length; i++) {
          final component = migratedComponents[i];

          // Migrate PlayerModel images
          if (component is PlayerModel && component.needsImageMigration) {
            try {
              zlog(
                level: Level.debug,
                data: '[Repo] Migrating player image: ${component.id}',
              );

              final bytes =
                  ImageConversionService.base64ToBytes(component.imageBase64);
              if (bytes != null) {
                final imageUrl = await _imageStorageService.uploadPlayerImage(
                  userId: collection.userId,
                  playerId: component.id,
                  imageData: bytes,
                );

                migratedComponents[i] = component.copyWith(imageUrl: imageUrl);
                sceneChanged = true;
                hasChanges = true;

                zlog(
                  level: Level.info,
                  data:
                      '[Repo] Player image migrated: ${component.id} -> $imageUrl',
                );
              }
            } catch (e) {
              zlog(
                level: Level.warning,
                data:
                    '[Repo] Failed to migrate player image ${component.id}: $e. Keeping base64.',
              );
              // Keep original component with base64 - don't fail entire save
              // This handles cases where upload fails due to network issues
            }
          }

          // Migrate EquipmentModel images
          if (component is EquipmentModel && component.needsImageMigration) {
            try {
              zlog(
                level: Level.debug,
                data: '[Repo] Migrating equipment image: ${component.id}',
              );

              // Equipment uses imagePath, not base64, so skip migration
              // (imagePath is for local assets, not user-uploaded images)
              // Only migrate if we add support for user-uploaded equipment images
            } catch (e) {
              zlog(
                level: Level.error,
                data:
                    '[Repo] Failed to migrate equipment image ${component.id}: $e',
              );
            }
          }
        }

        if (sceneChanged) {
          migratedScenes.add(scene.copyWith(components: migratedComponents));
          animationChanged = true;
        } else {
          migratedScenes.add(scene);
        }
      }

      if (animationChanged) {
        migratedAnimations
            .add(animation.copyWith(animationScenes: migratedScenes));
      } else {
        migratedAnimations.add(animation);
      }
    }

    if (hasChanges) {
      zlog(
        level: Level.info,
        data:
            '[Repo] Collection ${collection.id} had images migrated to Firebase Storage',
      );
      return collection.copyWith(animations: migratedAnimations);
    }

    return collection;
  }

  @override
  Future<AnimationCollectionModel> saveAnimationCollection({
    required AnimationCollectionModel animationCollectionModel,
  }) async {
    // 1. Check Connectivity Status
    // Using cached status might be slightly faster if realtime check isn't critical here
    // bool isOnline = ConnectivityService.isOnline;
    // Using realtime check provides most current status before operation:
    bool isOnline = await ConnectivityService.checkRealtimeConnectivity();

    if (!isOnline) {
      // --- OFFLINE PATH: Save Local First, Queue for Sync ---
      zlog(
        level: Level.info,
        data:
            "[Repo] Network Offline: Saving Collection ${animationCollectionModel.id} to LOCAL first.",
      );
      try {
        // Phase 2 Week 2: Migrate images (will be no-op if offline or feature disabled)
        final migratedCollection =
            await _migrateCollectionImages(animationCollectionModel);

        // 2a. Save Locally First (Await this)
        final savedLocalModel = await _localDs.saveAnimationCollection(
          animationCollectionModel: migratedCollection,
        );
        zlog(
          level: Level.info,
          data:
              "[Repo] Saved collection ${savedLocalModel.id} to LOCAL successfully (Offline).",
        );

        // 2b. Choose sync strategy based on feature flags
        if (FeatureFlags.enableSyncQueue && _syncQueueManager != null) {
          // PHASE 2: Use sync queue with retry logic
          zlog(
            level: Level.debug,
            data:
                "[Repo] Phase 2: Enqueuing sync operation for ${savedLocalModel.id}...",
          );
          final syncOperation = SyncOperation(
            id: RandomGenerator.generateId(),
            type: SyncOperationType.update,
            collectionId: savedLocalModel.id,
            userId: savedLocalModel.userId,
            priority: SyncPriority.high, // User-initiated action
            createdAt: DateTime.now(),
          );
          await _syncQueueManager.enqueue(syncOperation);
          zlog(
            level: Level.info,
            data:
                "[Repo] Sync operation enqueued for ${savedLocalModel.id}. Will sync when online.",
          );
        } else {
          // PHASE 1: Fire and forget (original behavior)
          zlog(
            level: Level.debug,
            data:
                "[Repo] Phase 1: Triggering background remote save for ${savedLocalModel.id} (fire and forget)...",
          );
          _remoteDs
              .saveAnimationCollection(
                  animationCollectionModel: savedLocalModel)
              .then((_) {
            zlog(
              level: Level.debug,
              data:
                  "[Repo] Background remote save ACKNOWLEDGED by SDK for ${savedLocalModel.id}.",
            );
          }).catchError((e, s) {
            zlog(
              level: Level.error,
              data:
                  "[Repo] Background remote save FAILED for ${savedLocalModel.id}: $e\n$s",
            );
          });
        }

        // 2c. Return the Local Result Immediately
        return savedLocalModel;
      } catch (localError, localStack) {
        // Handle failure during the essential OFFLINE local save
        zlog(
          level: Level.error,
          data:
              "[Repo] OFFLINE SAVE FAILED: Error saving collection ${animationCollectionModel.id} to LOCAL storage: $localError\n$localStack",
        );
        throw Exception(
          "Failed to save animation collection to local storage while offline: $localError",
        );
      }
    } else {
      // --- ONLINE PATH: Save Remote First, Then Update Local ---
      zlog(
        level: Level.info,
        data:
            "[Repo] Network Online: Saving Collection ${animationCollectionModel.id} to REMOTE first...",
      );
      try {
        // Phase 2 Week 2: Migrate images before saving to remote
        final migratedCollection =
            await _migrateCollectionImages(animationCollectionModel);

        // 3a. Save to Remote First (Await this)
        final savedRemoteModel = await _remoteDs.saveAnimationCollection(
          animationCollectionModel: migratedCollection,
        );
        zlog(
          level: Level.info,
          data:
              "[Repo] Saved collection ${savedRemoteModel.id} to REMOTE successfully.",
        );

        // 3b. Update Local Cache (Await this)
        zlog(
          level: Level.debug,
          data:
              "[Repo] Updating LOCAL cache for collection ${savedRemoteModel.id}...",
        );
        final savedLocalModel = await _localDs.saveAnimationCollection(
          animationCollectionModel:
              savedRemoteModel, // Use definitive remote version
        );
        zlog(
          level: Level.debug,
          data:
              "[Repo] LOCAL cache updated for collection ${savedLocalModel.id}.",
        );

        // 3c. Return Local Result (ensures consistency with cache)
        return savedLocalModel;
      } catch (e, stackTrace) {
        // Handle failure during the ONLINE remote save OR the subsequent local update
        zlog(
          level: Level.error,
          data:
              "[Repo] ONLINE SAVE FAILED: Error during saveAnimationCollection (Remote or Local update): $e\n$stackTrace",
        );
        throw Exception("Failed to save animation collection while online: $e");
      }
    }
  }

  @override
  Future<List<AnimationItemModel>> saveDefaultAnimations({
    required List<AnimationItemModel> animationItems,
    required String userId,
  }) async {
    // 1. Check Connectivity Status
    bool isOnline = await ConnectivityService.checkRealtimeConnectivity();

    if (!isOnline) {
      // --- OFFLINE PATH: Save Local First, Trigger Remote Async ---
      zlog(
        level: Level.info,
        data:
            "[Repo] Network Offline: Saving ${animationItems.length} Default Animations to LOCAL first.",
      );
      try {
        // Prepare items for local save (e.g., ensure IDs, set pending status if tracked)
        final itemsToSaveLocally = animationItems.map((item) {
          // Example: if (item.id.isEmpty) item = item.copyWith(id: RandomId());
          // Example: return item.copyWith(syncStatus: 'pending');
          return item;
        }).toList();

        // 2a. Save Locally First (Await this)
        final savedLocalItemsResult = await _localDs.saveDefaultAnimations(
          animationItems: itemsToSaveLocally,
          userId: userId,
        );
        // Note: saveDefaultAnimations might return void or the saved items. Adjust based on its signature.
        // Assuming it returns the list for consistency:
        final savedLocalItems = savedLocalItemsResult; // Adjust if needed
        zlog(
          level: Level.info,
          data:
              "[Repo] Saved/Synced ${savedLocalItems.length} default items to LOCAL successfully (Offline).",
        );

        // 2b. Choose sync strategy based on feature flags
        if (FeatureFlags.enableSyncQueue && _syncQueueManager != null) {
          // PHASE 2: Use sync queue with retry logic
          zlog(
            level: Level.debug,
            data:
                "[Repo] Phase 2: Enqueuing sync operation for default animations (user: $userId)...",
          );
          final syncOperation = SyncOperation(
            id: RandomGenerator.generateId(),
            type: SyncOperationType.update,
            collectionId:
                'default_animations_$userId', // Unique ID for this user's default animations
            userId: userId,
            priority: SyncPriority.high, // User-initiated action
            createdAt: DateTime.now(),
            metadata: {
              'dataType': 'defaultAnimations',
              'itemCount': savedLocalItems.length,
            },
          );
          await _syncQueueManager.enqueue(syncOperation);
          zlog(
            level: Level.info,
            data:
                "[Repo] Sync operation enqueued for default animations. Will sync when online.",
          );
        } else {
          // PHASE 1: Fire and forget (original behavior)
          zlog(
            level: Level.debug,
            data:
                "[Repo] Phase 1: Triggering background remote save for default animations (fire and forget)...",
          );
          _remoteDs
              .saveDefaultAnimations(
            animationItems: savedLocalItems,
            userId: userId,
          )
              .then((_) {
            zlog(
              level: Level.debug,
              data:
                  "[Repo] Background remote save ACKNOWLEDGED by SDK for default animations.",
            );
          }).catchError((e, s) {
            zlog(
              level: Level.error,
              data:
                  "[Repo] Background remote save FAILED for default animations: $e\n$s",
            );
          });
        }

        // 2c. Read back from Local to return consistent state
        final currentLocalItems = await _localDs.getDefaultAnimations(
          userId: userId,
        );
        return currentLocalItems;
      } catch (localError, localStack) {
        zlog(
          level: Level.error,
          data:
              "[Repo] OFFLINE SAVE FAILED: Error saving default items to LOCAL storage: $localError\n$localStack",
        );
        throw Exception(
          "Failed to save default animations to local storage while offline: $localError",
        );
      }
    } else {
      // --- ONLINE PATH: Save Remote First, Then Update Local ---
      zlog(
        level: Level.info,
        data:
            "[Repo] Network Online: Syncing ${animationItems.length} Default Animations to REMOTE first...",
      );
      try {
        // 3a. Save/Sync to Remote First (Await this)
        final savedRemoteItems = await _remoteDs.saveDefaultAnimations(
          animationItems: animationItems,
          userId: userId,
        );
        zlog(
          level: Level.info,
          data:
              "[Repo] Synced ${savedRemoteItems.length} default items to REMOTE successfully.",
        );

        // 3b. Update Local Cache (Await this)
        zlog(
          level: Level.debug,
          data: "[Repo] Updating LOCAL cache for default animations...",
        );
        await _localDs.saveDefaultAnimations(
          animationItems: savedRemoteItems, // Use list confirmed by remote
          userId: userId,
        );
        zlog(
          level: Level.debug,
          data: "[Repo] LOCAL cache updated for default animations.",
        );

        // 3c. Read back from Local Cache and return
        final localItems = await _localDs.getDefaultAnimations(userId: userId);
        zlog(
          level: Level.info,
          data:
              "[Repo] Returning ${localItems.length} default animations from LOCAL Sembast after remote sync.",
        );
        return localItems;
      } catch (e, stackTrace) {
        // Handle failure during the ONLINE remote save OR the subsequent local update
        zlog(
          level: Level.error,
          data:
              "[Repo] ONLINE SAVE/SYNC FAILED: Error during saveDefaultAnimations (Remote or Local update): $e\n$stackTrace",
        );
        throw Exception("Failed to save default animations while online: $e");
      }
    }
  }

  @override
  Future<AnimationItemModel?> getDefaultSceneFromId({
    required String id,
    required String userId,
  }) async {
    return await _localDs.getDefaultSceneFromId(id: id, userId: userId);
  }

  @override
  Future<void> deleteHistory({required String id}) async {
    return await _localDs.deleteHistory(id: id);
  }

  @override
  Future<HistoryModel?> getHistory({required String id}) async {
    return await _localDs.getHistory(id: id);
  }

  @override
  Future<void> saveHistory({required HistoryModel historyModel}) async {
    return await _localDs.saveHistory(historyModel: historyModel);
  }

  @override
  Stream<HistoryModel?> getHistoryStream({required String id}) {
    return _localDs.getHistoryStream(id: id);
  }

  @override
  Future<void> deleteAnimationCollection({required String collectionId}) async {
    bool isOnline = await ConnectivityService.checkRealtimeConnectivity();

    if (!isOnline) {
      // --- OFFLINE PATH: Delete locally and queue for remote deletion ---
      if (FeatureFlags.enableSyncQueue && _syncQueueManager != null) {
        // PHASE 2: Support offline deletion with sync queue
        zlog(
          level: Level.info,
          data:
              "[Repo] Network Offline (Phase 2): Deleting collection $collectionId from LOCAL and queueing for sync...",
        );
        try {
          // Delete from local storage first
          await _localDs.deleteAnimationCollection(collectionId: collectionId);
          zlog(
            level: Level.info,
            data:
                "[Repo] Deleted collection $collectionId from LOCAL successfully.",
          );

          // Get userId from local collections (need to fetch before it's deleted)
          // For now, we'll use a placeholder - in production, you'd want to pass userId
          final syncOperation = SyncOperation(
            id: RandomGenerator.generateId(),
            type: SyncOperationType.delete,
            collectionId: collectionId,
            userId: '', // TODO: Pass userId from caller or fetch before delete
            priority: SyncPriority.high,
            createdAt: DateTime.now(),
          );
          await _syncQueueManager.enqueue(syncOperation);
          zlog(
            level: Level.info,
            data:
                "[Repo] Delete operation enqueued for $collectionId. Will sync when online.",
          );
          return;
        } catch (e, stackTrace) {
          zlog(
            level: Level.error,
            data:
                "[Repo] OFFLINE DELETE FAILED: Error deleting collection $collectionId: $e\n$stackTrace",
          );
          throw Exception("Failed to delete collection while offline: $e");
        }
      } else {
        // PHASE 1: Require online connection for deletion
        zlog(
          level: Level.warning,
          data:
              "[Repo] Network Offline (Phase 1): Cannot perform delete operation for collection $collectionId. Deletion requires an internet connection.",
        );
        throw Exception("Cannot delete collection while offline.");
      }
    }

    // --- ONLINE PATH ---
    zlog(
      level: Level.info,
      data:
          "[Repo] Network Online: Deleting Collection $collectionId from REMOTE first...",
    );
    try {
      // 1. Delete from Remote First
      await _remoteDs.deleteAnimationCollection(collectionId: collectionId);
      zlog(
        level: Level.info,
        data:
            "[Repo] Deleted collection $collectionId from REMOTE successfully.",
      );

      // 2. On remote success, delete from Local Cache to maintain sync
      zlog(
        level: Level.debug,
        data: "[Repo] Deleting collection $collectionId from LOCAL cache...",
      );
      await _localDs.deleteAnimationCollection(collectionId: collectionId);
      zlog(
        level: Level.debug,
        data: "[Repo] Deleted collection $collectionId from LOCAL cache.",
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "[Repo] ONLINE DELETE FAILED: Error during deleteAnimationCollection (Remote or Local): $e\n$stackTrace",
      );
      // Re-throw the exception to be handled by the UI layer (e.g., show an error message).
      throw Exception("Failed to delete animation collection: $e");
    }
  }

  @override
  Future<void> saveAllDefaultAnimations(List<AnimationModel> animations) async {
    bool isOnline = await ConnectivityService.checkRealtimeConnectivity();

    if (!isOnline) {
      // --- OFFLINE PATH: Save to local, trigger remote async ---
      zlog(
        level: Level.info,
        data:
            "[Repo] Network Offline: Saving all ${animations.length} default animations to LOCAL.",
      );
      try {
        await _localDs.saveAllDefaultAnimations(animations);
        zlog(
          level: Level.info,
          data: "[Repo] Saved all default animations to LOCAL successfully.",
        );

        // Use sync queue if available (need userId from animations)
        if (FeatureFlags.enableSyncQueue &&
            _syncQueueManager != null &&
            animations.isNotEmpty) {
          final userId =
              animations.first.userId; // Get userId from first animation
          zlog(
            level: Level.debug,
            data:
                "[Repo] Phase 2: Enqueuing sync operation for bulk default animations...",
          );
          final syncOperation = SyncOperation(
            id: RandomGenerator.generateId(),
            type: SyncOperationType.update,
            collectionId: 'default_animations_$userId',
            userId: userId,
            priority: SyncPriority.normal,
            createdAt: DateTime.now(),
            metadata: {
              'dataType': 'defaultAnimations',
              'itemCount': animations.length,
            },
          );
          await _syncQueueManager.enqueue(syncOperation);
          zlog(
            level: Level.info,
            data:
                "[Repo] Sync operation enqueued for bulk default animations. Will sync when online.",
          );
        } else {
          // Fire-and-forget fallback
          zlog(
            level: Level.debug,
            data:
                "[Repo] Triggering background remote save for all default animations...",
          );
          _remoteDs.saveAllDefaultAnimations(animations).catchError((e, s) {
            zlog(
              level: Level.error,
              data:
                  "[Repo] Background remote save FAILED for all default animations: $e\n$s",
            );
          });
        }
      } catch (localError) {
        zlog(
          level: Level.error,
          data:
              "[Repo] OFFLINE SAVE FAILED: Could not save all default animations locally: $localError",
        );
        throw Exception(
            "Failed to save default animations locally while offline: $localError");
      }
    } else {
      // --- ONLINE PATH: Save to remote, then update local cache ---
      zlog(
        level: Level.info,
        data:
            "[Repo] Network Online: Saving all ${animations.length} default animations to REMOTE first...",
      );
      try {
        await _remoteDs.saveAllDefaultAnimations(animations);
        zlog(
            level: Level.debug,
            data: "[Repo] Remote save successful. Updating local cache...");
        await _localDs.saveAllDefaultAnimations(animations);
        zlog(
            level: Level.debug,
            data: "[Repo] Local cache updated successfully.");
      } catch (e) {
        zlog(
          level: Level.error,
          data:
              "[Repo] ONLINE SAVE FAILED: Could not save all default animations: $e",
        );
        throw Exception("Failed to save default animations while online: $e");
      }
    }
  }
} // End of class AnimationCacheRepositoryImpl
