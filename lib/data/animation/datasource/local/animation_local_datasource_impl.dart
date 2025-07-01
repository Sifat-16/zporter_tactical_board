import 'package:logger/logger.dart';
import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/animation/datasource/animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/animation/model/history_model.dart';

class AnimationLocalDatasourceImpl implements AnimationDatasource {
  static final _animationCollectionStore = stringMapStoreFactory.store(
    'animation_collections',
  );
  // Store for user-specific "default" animation items
  static final _defaultAnimationItemStore = stringMapStoreFactory.store(
    'default_animation_items',
  );

  static final _historyStore = stringMapStoreFactory.store('animation_history');

  // --- Animation Collection Methods ---
  // ... (saveAnimationCollection and getAllAnimationCollection are unchanged from last version)
  @override
  Future<AnimationCollectionModel> saveAnimationCollection({
    required AnimationCollectionModel animationCollectionModel,
  }) async {
    try {
      final db = await SemDB.database;
      String id = animationCollectionModel.id;
      final String userId = animationCollectionModel.userId;
      if (id.isEmpty) {
        id = RandomGenerator.generateId();
        animationCollectionModel = animationCollectionModel.copyWith(id: id);
        zlog(
          level: Level.info,
          data:
              "Sembast: Generated new ID for animation collection: $id for user: $userId",
        );
      }
      final jsonData = animationCollectionModel.toJson();
      await _animationCollectionStore.record(id).put(db, jsonData);
      zlog(
        level: Level.debug,
        data:
            "Sembast: Saved/Updated animation collection ID: $id for user: $userId",
      );
      return animationCollectionModel;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Sembast: Error saving animation collection for user ${animationCollectionModel.userId}: $e\n$stackTrace",
      );
      throw Exception("Error saving animation collection locally: $e");
    }
  }

  @override
  Future<List<AnimationCollectionModel>> getAllAnimationCollection({
    required String userId,
  }) async {
    try {
      final db = await SemDB.database;
      final finder = Finder(filter: Filter.equals('userId', userId));
      final snapshots = await _animationCollectionStore.find(
        db,
        finder: finder,
      );
      List<AnimationCollectionModel> animationCollections = [];
      if (snapshots.isEmpty) {
        zlog(
          level: Level.debug,
          data: "Sembast: No animation collections found for user: $userId.",
        );
        return animationCollections;
      }
      for (final snapshot in snapshots) {
        try {
          animationCollections.add(
            AnimationCollectionModel.fromJson(snapshot.value),
          );
        } catch (e, stackTrace) {
          zlog(
            level: Level.error,
            data:
                "Sembast: Error parsing animation collection document ${snapshot.key} for user $userId: $e\n$stackTrace",
          );
        }
      }
      zlog(
        level: Level.debug,
        data:
            "Sembast: Fetched ${animationCollections.length} animation collections for user: $userId.",
      );
      return animationCollections;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Sembast: Error getting animation collections for user $userId: $e\n$stackTrace",
      );
      throw Exception(
        "Error getting animation collections locally for user $userId: $e",
      );
    }
  }

  // --- Default Animation Item Methods (User-Specific) ---
  // ... (getDefaultAnimations and saveDefaultAnimations are unchanged from last version)
  @override
  Future<List<AnimationItemModel>> getDefaultAnimations({
    required String userId,
  }) async {
    try {
      final db = await SemDB.database;
      final finder = Finder(filter: Filter.equals('userId', userId));
      final snapshots = await _defaultAnimationItemStore.find(
        db,
        finder: finder,
      );

      List<AnimationItemModel> animationItems = [];
      if (snapshots.isEmpty) {
        zlog(
          level: Level.debug,
          data: "Sembast: No default animations found for user: $userId.",
        );
        return animationItems;
      }
      for (final snapshot in snapshots) {
        try {
          animationItems.add(AnimationItemModel.fromJson(snapshot.value));
        } catch (e, stackTrace) {
          zlog(
            level: Level.error,
            data:
                "Sembast: Error parsing default animation item document ${snapshot.key} for user $userId: $e\n$stackTrace",
          );
        }
      }
      zlog(
        level: Level.debug,
        data:
            "Sembast: Fetched ${animationItems.length} default animations for user: $userId.",
      );
      return animationItems;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Sembast: Error getting default animations for user $userId: $e\n$stackTrace",
      );
      throw Exception(
        "Error getting default animations locally for user $userId: $e",
      );
    }
  }

  @override
  Future<List<AnimationItemModel>> saveDefaultAnimations({
    required List<AnimationItemModel> animationItems,
    required String userId,
  }) async {
    final db = await SemDB.database;
    final List<AnimationItemModel> savedOrUpdatedItems = [];
    final Set<String> inputItemIds = {};
    final List<String> generatedIds = [];
    Set<String> keysToDelete = {};

    try {
      await db.transaction((txn) async {
        final finder = Finder(filter: Filter.equals('userId', userId));
        zlog(
          level: Level.debug,
          data:
              "Sembast Txn: Fetching existing default animation keys for user $userId...",
        );
        final existingSembastKeys = (await _defaultAnimationItemStore.findKeys(
          txn,
          finder: finder,
        ))
            .toSet();
        zlog(
          level: Level.debug,
          data:
              "Sembast Txn: Found ${existingSembastKeys.length} existing default animation keys for user $userId.",
        );

        zlog(
          level: Level.debug,
          data:
              "Sembast Txn: Processing ${animationItems.length} input default animations for saving/updating for user $userId...",
        );
        for (var item in animationItems) {
          String currentItemId = item.id;
          item = item.copyWith(userId: userId);

          if (currentItemId.isEmpty || currentItemId == null) {
            currentItemId = RandomGenerator.generateId();
            generatedIds.add(currentItemId);
            item = item.copyWith(id: currentItemId);
            zlog(
              level: Level.info,
              data:
                  "Sembast Txn: Generated new ID for default animation: $currentItemId for user $userId",
            );
          } else {
            currentItemId = item.id;
          }

          inputItemIds.add(currentItemId);
          final jsonData = item.toJson();
          await _defaultAnimationItemStore
              .record(currentItemId)
              .put(txn, jsonData);
          savedOrUpdatedItems.add(item);
        }
        zlog(
          level: Level.debug,
          data:
              "Sembast Txn: Prepared PUT operations for ${inputItemIds.length} items for user $userId. ${generatedIds.length} new IDs generated.",
        );

        keysToDelete = existingSembastKeys.difference(inputItemIds);

        if (keysToDelete.isNotEmpty) {
          zlog(
            level: Level.info,
            data:
                "Sembast Txn: Identified ${keysToDelete.length} default animations for user $userId to DELETE: ${keysToDelete.join(', ')}",
          );
          for (final keyToDelete in keysToDelete) {
            await _defaultAnimationItemStore.record(keyToDelete).delete(txn);
          }
        } else {
          zlog(
            level: Level.debug,
            data:
                "Sembast Txn: No existing default animations need deletion for user $userId.",
          );
        }
      });

      zlog(
        level: Level.info,
        data:
            "Sembast: Successfully synchronized default animations for user $userId. Saved/Updated: ${savedOrUpdatedItems.length}, Deleted: ${keysToDelete.length}.",
      );
      return savedOrUpdatedItems;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Sembast: Error synchronizing default animations for user $userId: $e\n$stackTrace",
      );
      throw Exception(
        "Error synchronizing default animations locally for user $userId: $e",
      );
    }
  }

  @override
  Future<AnimationItemModel?> getDefaultSceneFromId({
    required String id,
    required String userId,
  }) async {
    try {
      final db = await SemDB.database;
      // getSnapshot returns RecordSnapshot? (nullable)
      final RecordSnapshot<String, Map<String, dynamic>>? record =
          await _defaultAnimationItemStore.record(id).getSnapshot(db);

      // --- CORRECTED CHECK: Check if record is not null ---
      if (record != null) {
        // If record is not null, it was found. Now check its content.
        final data = record.value; // Get the Map<String, dynamic> value
        final fetchedUserId = data['userId'] as String?;

        // Verify userId match
        if (fetchedUserId == userId) {
          zlog(
            level: Level.debug,
            data:
                "Sembast: Found default scene ID: $id belonging to user $userId.",
          );
          try {
            return AnimationItemModel.fromJson(data);
          } catch (e, stackTrace) {
            zlog(
              level: Level.error,
              data:
                  "Sembast: Error parsing default scene data for ID $id, user $userId: $e\n$stackTrace",
            );
            // Depending on desired behavior, you might return null or rethrow
            return null;
          }
        } else {
          zlog(
            data:
                "Sembast: Default scene ID: $id found, but belongs to different user (expected $userId, found $fetchedUserId).",
          );
          return null; // Found, but not for this user
        }
      } else {
        // If record is null, the key wasn't found in the store
        zlog(
          level: Level.debug,
          data: "Sembast: Default scene ID: $id not found.",
        );
        return null; // Not found at all
      }
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Sembast: Error getting default scene by ID $id for user $userId: $e\n$stackTrace",
      );
      // Rethrow a more specific exception or handle as needed
      throw Exception(
        "Error getting default scene $id locally for user $userId: $e",
      );
    }
  }

  @override
  Future<void> saveHistory({required HistoryModel historyModel}) async {
    try {
      final db = await SemDB.database;
      final jsonData = historyModel.toJson(); // Use the model's toJson
      await _historyStore.record(historyModel.id).put(db, jsonData);
      zlog(
        level: Level.debug,
        data: "Sembast: Saved/Updated history for ID: ${historyModel.id}",
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Sembast: Error saving history for ID ${historyModel.id}: $e\n$stackTrace",
      );
      throw Exception("Error saving history locally: $e");
    }
  }

  @override
  Future<HistoryModel?> getHistory({required String id}) async {
    try {
      final db = await SemDB.database;
      final recordData = await _historyStore.record(id).get(db);

      if (recordData != null) {
        zlog(level: Level.debug, data: "Sembast: Found history for ID: $id.");
        try {
          // Use the model's fromJson factory
          return HistoryModel.fromJson(recordData);
        } catch (e, stackTrace) {
          zlog(
            level: Level.error,
            data:
                "Sembast: Error parsing history data for ID $id: $e\n$stackTrace",
          );
          return null; // Return null if parsing fails
        }
      } else {
        zlog(
          level: Level.debug,
          data: "Sembast: No history found for ID: $id.",
        );
        return null; // Not found
      }
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Sembast: Error getting history for ID $id: $e\n$stackTrace",
      );
      throw Exception("Error getting history locally: $e");
    }
  }

  @override
  Future<void> deleteHistory({required String id}) async {
    try {
      final db = await SemDB.database;
      final count = await _historyStore.record(id).delete(db);
      if (count != null) {
        zlog(level: Level.debug, data: "Sembast: Deleted history for ID: $id.");
      } else {
        zlog(
          level: Level.debug,
          data:
              "Sembast: Attempted to delete history for ID: $id, but it was not found.",
        );
      }
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Sembast: Error deleting history for ID $id: $e\n$stackTrace",
      );
      throw Exception("Error deleting history locally: $e");
    }
  }

  @override
  Stream<HistoryModel?> getHistoryStream({required String id}) async* {
    Database? dbInstance;
    try {
      dbInstance = await SemDB.database; // Await the database future
      final recordStream = _historyStore.record(id).onSnapshot(dbInstance);
      yield* recordStream.map((snapshot) {
        if (snapshot != null) {
          try {
            final historyModel = HistoryModel.fromJson(snapshot.value);

            return historyModel;
          } catch (e, stackTrace) {
            zlog(
              level: Level.error,
              data:
                  "Sembast Stream: Error parsing history snapshot for ID $id: $e\n$stackTrace",
            );
            return null; // Emit null on parsing error
          }
        } else {
          zlog(
            level: Level.debug,
            data:
                "Sembast Stream: Emitting null (no history found) for ID: $id.",
          );
          return null; // Emit null if record doesn't exist or value is null
        }
      }).handleError((error, stackTrace) {
        // Log errors within the stream's transformation pipeline
        zlog(
          level: Level.error,
          data:
              "Sembast Stream: Error in getHistory stream processing for ID $id: $error\n$stackTrace",
        );
      });
    } catch (e, stackTrace) {
      // --- Handle Errors During Setup ---
      zlog(
        level: Level.error,
        data:
            "Sembast: Error setting up getHistory stream for ID $id: $e\n$stackTrace",
      );
      // Emit the error into the stream returned by this generator function
      yield* Stream.error(
        Exception("Error setting up history stream locally for ID $id: $e"),
      );
    } finally {}
  }

  @override
  Future<void> deleteAnimationCollection({required String collectionId}) async {
    try {
      final db = await SemDB.database;
      final count =
          await _animationCollectionStore.record(collectionId).delete(db);
      if (count != null) {
        zlog(
          level: Level.info,
          data:
              "Sembast: Successfully deleted animation collection ID: $collectionId.",
        );
      } else {
        zlog(
          level: Level.debug,
          data:
              "Sembast: Tried to delete collection ID: $collectionId, but it was not found.",
        );
      }
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Sembast: Error deleting collection ID $collectionId: $e\n$stackTrace",
      );
      throw Exception("Error deleting animation collection locally: $e");
    }
  }

  @override
  Future<void> saveAllDefaultAnimations(List<AnimationModel> animations) async {
    final db = await SemDB.database;
    try {
      await db.transaction((txn) async {
        for (final animation in animations) {
          await _defaultAnimationItemStore
              .record(animation.id)
              .put(txn, animation.toJson());
        }
      });
      zlog(
        level: Level.info,
        data:
            "Sembast: Successfully batch-saved ${animations.length} default animations.",
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Sembast: Error in saveAllDefaultAnimations: $e\n$stackTrace",
      );
      throw Exception("Error saving default animations locally: $e");
    }
  }
}
