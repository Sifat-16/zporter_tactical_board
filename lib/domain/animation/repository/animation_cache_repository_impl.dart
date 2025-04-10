import 'package:logger/logger.dart';
// Your project specific imports
import 'package:zporter_tactical_board/app/helper/logger.dart'; // For zlog
import 'package:zporter_tactical_board/app/services/connectivity_service.dart';
import 'package:zporter_tactical_board/data/animation/datasource/animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/history_model.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';

class AnimationCacheRepositoryImpl implements AnimationRepository {
  final AnimationDatasource _localDs;
  final AnimationDatasource _remoteDs;

  AnimationCacheRepositoryImpl({
    required AnimationDatasource localDatasource,
    required AnimationDatasource remoteDatasource,
  }) : _localDs = localDatasource,
       _remoteDs = remoteDatasource;

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
    } catch (e, stackTrace) {
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
      for (final collection in collections) {
        await _localDs.saveAnimationCollection(
          animationCollectionModel: collection,
        );
      }
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
    } catch (e, stackTrace) {
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
      // --- OFFLINE PATH: Save Local First, Trigger Remote Async ---
      zlog(
        level: Level.info,
        data:
            "[Repo] Network Offline: Saving Collection ${animationCollectionModel.id} to LOCAL first.",
      );
      try {
        // 2a. Save Locally First (Await this)
        final savedLocalModel = await _localDs.saveAnimationCollection(
          animationCollectionModel: animationCollectionModel,
          // If localDs needs explicit status: .copyWith(syncStatus: 'pending'),
        );
        zlog(
          level: Level.info,
          data:
              "[Repo] Saved collection ${savedLocalModel.id} to LOCAL successfully (Offline).",
        );

        // 2b. Trigger Remote Save Asynchronously (Fire and Forget with Error Logging)
        zlog(
          level: Level.debug,
          data:
              "[Repo] Triggering background remote save for ${savedLocalModel.id} (queued by Firestore)...",
        );
        _remoteDs
            .saveAnimationCollection(animationCollectionModel: savedLocalModel)
            .then((_) {
              zlog(
                level: Level.debug,
                data:
                    "[Repo] Background remote save ACKNOWLEDGED by SDK for ${savedLocalModel.id}.",
              );
              // Optional: Update local syncStatus to 'synced' if tracking it
              // _localDs.updateSyncStatus(savedLocalModel.id, 'synced');
            })
            .catchError((e, s) {
              zlog(
                level: Level.error,
                data:
                    "[Repo] Background remote save FAILED for ${savedLocalModel.id}: $e\n$s",
              );
              // Data remains locally saved. TODO: Implement retry/manual sync later if needed.
            });

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
        // 3a. Save to Remote First (Await this)
        final savedRemoteModel = await _remoteDs.saveAnimationCollection(
          animationCollectionModel: animationCollectionModel,
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
        final itemsToSaveLocally =
            animationItems.map((item) {
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

        // 2b. Trigger Remote Save Asynchronously
        zlog(
          level: Level.debug,
          data:
              "[Repo] Triggering background remote save/sync for default items (queued by Firestore)...",
        );
        _remoteDs
            .saveDefaultAnimations(
              animationItems: savedLocalItems,
              userId: userId,
            ) // Use locally saved items
            .then((_) {
              zlog(
                level: Level.debug,
                data:
                    "[Repo] Background remote save/sync ACKNOWLEDGED by SDK for default items.",
              );
              // Optional: Update sync status for items locally if tracked
            })
            .catchError((e, s) {
              zlog(
                level: Level.error,
                data:
                    "[Repo] Background remote save/sync FAILED for default items: $e\n$s",
              );
              // TODO: Handle background failure if needed
            });

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
} // End of class AnimationCacheRepositoryImpl
