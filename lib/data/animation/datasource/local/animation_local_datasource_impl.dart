import 'package:logger/logger.dart'; // Assuming zlog uses this
import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
// Your project specific imports
import 'package:zporter_tactical_board/app/helper/logger.dart'; // For zlog
import 'package:zporter_tactical_board/data/animation/datasource/animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';

class AnimationLocalDatasourceImpl implements AnimationDatasource {
  // Sembast store references
  // Use stringMapStoreFactory for storing Map<String, dynamic> with String keys (IDs)
  static final _animationCollectionStore = stringMapStoreFactory.store(
    'animation_collections',
  );
  static final _defaultAnimationItemStore = stringMapStoreFactory.store(
    'default_animation_items',
  );

  // final _uuid = const Uuid(); // Instance to generate IDs

  // --- Animation Collection Methods ---

  @override
  Future<AnimationCollectionModel> saveAnimationCollection({
    required AnimationCollectionModel animationCollectionModel,
  }) async {
    try {
      final db = await SemDB.database;
      String id = animationCollectionModel.id;

      // Ensure the model has an ID. Generate one if missing.
      if (id.isEmpty) {
        id = RandomGenerator.generateId();
        animationCollectionModel = animationCollectionModel.copyWith(id: id);
        zlog(
          level: Level.info,
          data: "Sembast: Generated new ID for animation collection: $id",
        );
      }

      // Convert model to JSON map for Sembast
      final jsonData = animationCollectionModel.toJson();

      // Use put with the record ID. This performs an UPSERT (update or insert).
      await _animationCollectionStore.record(id).put(db, jsonData);

      zlog(
        level: Level.debug,
        data: "Sembast: Saved/Updated animation collection with ID: $id",
      );

      // Return the model (potentially updated with a new ID)
      return animationCollectionModel;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Sembast: Error saving animation collection: $e\n$stackTrace",
      );
      // Rethrow a generic exception or a custom one
      throw Exception("Error saving animation collection locally: $e");
    }
  }

  @override
  Future<List<AnimationCollectionModel>> getAllAnimationCollection() async {
    try {
      final db = await SemDB.database;

      // Find all records in the store
      final snapshots = await _animationCollectionStore.find(db);

      List<AnimationCollectionModel> animationCollections = [];

      if (snapshots.isEmpty) {
        zlog(
          level: Level.debug,
          data: "Sembast: No animation collections found.",
        );
        return animationCollections; // Return empty list
      }

      // Iterate through the record snapshots
      for (final snapshot in snapshots) {
        try {
          final data = snapshot.value; // The Map<String, dynamic> data
          // Assuming fromJson handles the Sembast map structure correctly
          // (ensure Timestamps if any are handled, e.g., stored as ISO strings)
          animationCollections.add(AnimationCollectionModel.fromJson(data));
        } catch (e, stackTrace) {
          zlog(
            level: Level.error,
            data:
                "Sembast: Error parsing animation collection document ${snapshot.key}: $e\n$stackTrace",
          );
          // Decide whether to skip the record or rethrow
        }
      }
      zlog(
        level: Level.debug,
        data:
            "Sembast: Fetched ${animationCollections.length} animation collections.",
      );
      return animationCollections;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Sembast: Error getting all animation collections: $e\n$stackTrace",
      );
      throw Exception("Error getting animation collections locally: $e");
    }
  }

  // --- Default Animation Item Methods ---

  @override
  Future<List<AnimationItemModel>> getDefaultAnimations() async {
    try {
      final db = await SemDB.database;

      // Find all records in the store
      final snapshots = await _defaultAnimationItemStore.find(db);

      List<AnimationItemModel> animationItems = [];

      if (snapshots.isEmpty) {
        zlog(level: Level.debug, data: "Sembast: No default animations found.");
        return animationItems; // Return empty list
      }

      // Iterate through the record snapshots
      for (final snapshot in snapshots) {
        try {
          final data = snapshot.value;
          // Assuming fromJson works for Sembast maps
          animationItems.add(AnimationItemModel.fromJson(data));
        } catch (e, stackTrace) {
          zlog(
            level: Level.error,
            data:
                "Sembast: Error parsing default animation item document ${snapshot.key}: $e\n$stackTrace",
          );
        }
      }
      zlog(
        level: Level.debug,
        data: "Sembast: Fetched ${animationItems.length} default animations.",
      );
      return animationItems;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Sembast: Error getting all default animations: $e\n$stackTrace",
      );
      throw Exception("Error getting default animations locally: $e");
    }
  }

  @override
  Future<List<AnimationItemModel>> saveDefaultAnimations({
    required List<AnimationItemModel> animationItems,
  }) async {
    final db = await SemDB.database;
    // List to hold models potentially updated with new IDs (returned value)
    final List<AnimationItemModel> savedOrUpdatedItems = [];
    // Set to keep track of the final IDs present in the input list
    final Set<String> inputItemIds = {};
    // Track IDs generated during this operation
    final List<String> generatedIds = [];
    // Track keys (IDs) to be deleted
    Set<String> keysToDelete = {};

    try {
      // --- Use a transaction for atomic operations ---
      await db.transaction((txn) async {
        // --- Step 1: Fetch existing keys from Sembast store within the transaction ---
        zlog(
          level: Level.debug,
          data: "Sembast Txn: Fetching existing default animation keys...",
        );
        // findKeys is efficient for getting just the IDs
        final existingSembastKeys =
            (await _defaultAnimationItemStore.findKeys(txn)).toSet();
        zlog(
          level: Level.debug,
          data:
              "Sembast Txn: Found ${existingSembastKeys.length} existing default animation keys.",
        );

        // --- Step 2: Process input items and prepare PUT operations ---
        zlog(
          level: Level.debug,
          data:
              "Sembast Txn: Processing ${animationItems.length} input default animations for saving/updating...",
        );
        for (var item in animationItems) {
          String currentItemId = item.id;

          // Ensure each item has an ID, generating one if necessary
          if (currentItemId.isEmpty) {
            currentItemId = RandomGenerator.generateId(); // Generate a new UUID
            generatedIds.add(currentItemId);
            // Update the item model instance with the new ID
            item = item.copyWith(id: currentItemId);
            zlog(
              level: Level.info,
              data:
                  "Sembast Txn: Generated new ID for default animation: $currentItemId",
            );
          }

          // Track the final ID of this input item
          inputItemIds.add(currentItemId);

          // Convert the item model (with definite ID) to JSON
          final jsonData = item.toJson();

          // Add a 'put' operation to the transaction (creates or overwrites)
          await _defaultAnimationItemStore
              .record(currentItemId)
              .put(txn, jsonData);

          // Add the item (potentially updated with ID) to our result list
          savedOrUpdatedItems.add(item);
        }
        zlog(
          level: Level.debug,
          data:
              "Sembast Txn: Prepared PUT operations for ${inputItemIds.length} items. ${generatedIds.length} new IDs generated.",
        );

        // --- Step 3: Determine which existing keys need to be deleted ---
        keysToDelete = existingSembastKeys.difference(inputItemIds);

        // --- Step 4: Add DELETE operations to the transaction ---
        if (keysToDelete.isNotEmpty) {
          zlog(
            level: Level.info,
            data:
                "Sembast Txn: Identified ${keysToDelete.length} default animations to DELETE (not in input list): ${keysToDelete.join(', ')}",
          );
          for (final keyToDelete in keysToDelete) {
            await _defaultAnimationItemStore.record(keyToDelete).delete(txn);
          }
        } else {
          zlog(
            level: Level.debug,
            data: "Sembast Txn: No existing default animations need deletion.",
          );
        }
        // Transaction commits automatically if no error is thrown
      }); // End of transaction

      zlog(
        level: Level.info,
        data:
            "Sembast: Successfully synchronized default animations. Saved/Updated: ${savedOrUpdatedItems.length}, Deleted: ${keysToDelete.length}.",
      );

      // --- Step 5: Return the list of items that were saved or updated ---
      return savedOrUpdatedItems;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Sembast: Error synchronizing default animations: $e\n$stackTrace",
      );
      throw Exception("Error synchronizing default animations locally: $e");
    }
  }

  @override
  Future<AnimationItemModel?> getDefaultSceneFromId({
    required String id,
  }) async {
    List<AnimationItemModel> savedScenes = await getDefaultAnimations();
    return savedScenes.firstWhereOrNull((t) => t.id == id);
  }
} // End of AnimationLocalDatasource class
