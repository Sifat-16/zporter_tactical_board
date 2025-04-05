// 1. Modify AnimationCollectionModel FIRST
// (Will provide this code separately)

// 2. Rewrite AnimationDatasourceImpl
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/core/constants/firestore_constant.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
// Remove MongoDB imports
// Keep datasource interface and model imports
import 'package:zporter_tactical_board/data/animation/datasource/animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';

class AnimationRemoteDatasourceImpl implements AnimationDatasource {
  // Get Firestore instance (can be injected)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to the Firestore collection
  late final CollectionReference<Map<String, dynamic>> _animationCollectionRef;

  // Reference to the Firestore collection
  late final CollectionReference<Map<String, dynamic>> _defaultAnimationItemRef;

  // Constructor initializes the collection reference
  AnimationRemoteDatasourceImpl() {
    _animationCollectionRef = _firestore.collection(
      FirestoreConstant.ANIMATION_COLLECTIONS,
    );
    _defaultAnimationItemRef = _firestore.collection(
      FirestoreConstant.DEFAULT_ANIMATION_ITEMS,
    );
  }

  @override
  Future<AnimationCollectionModel> saveAnimationCollection({
    required AnimationCollectionModel animationCollectionModel,
  }) async {
    try {
      // Assume animationCollectionModel.id is a non-null String ID
      // generated before calling this method (e.g., using _animationCollectionRef.doc().id)
      if (animationCollectionModel.id.isEmpty) {
        // If ID is somehow missing, we either throw or generate one now.
        // Let's generate one for robustness, although ideally it comes in set.
        final newDocRef = _animationCollectionRef.doc();
        animationCollectionModel = animationCollectionModel.copyWith(
          id: newDocRef.id,
        ); // Update model with new ID
        zlog(
          level: Level.warning,
          data: "Generated new ID during save: ${animationCollectionModel.id}",
        );
      }

      // Convert model to JSON (ensure toJson is updated for Firestore compatibility)
      final jsonData = animationCollectionModel.toJson();

      // Use set with the specific document ID. This performs an UPSERT (update or insert).
      await _animationCollectionRef
          .doc(animationCollectionModel.id)
          .set(jsonData);

      // Firestore doesn't return the saved data directly on set.
      // We assume the operation was successful and return the model passed in
      // (potentially updated with a newly generated ID if it was missing).
      // If confirmation from DB is needed, add a .get() call after .set().
      return animationCollectionModel;
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error saving animation collection: ${e.code} - ${e.message}",
      );
      throw Exception("Error saving animation collection: ${e.message}");
    } catch (e) {
      zlog(level: Level.error, data: "Error saving animation collection: $e");
      throw Exception("Error saving animation collection: $e");
    }
  }

  @override
  Future<List<AnimationCollectionModel>> getAllAnimationCollection() async {
    try {
      // Get all documents from the collection
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _animationCollectionRef.get();

      List<AnimationCollectionModel> animationCollections = [];

      if (snapshot.docs.isEmpty) {
        return animationCollections; // Return empty list if no documents
      }

      // Iterate through the document snapshots
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        try {
          final data = doc.data();
          // --- Call your MODIFIED fromJson(Map) ---
          // Pass the data map directly. It expects '_id' and handles Timestamps.
          animationCollections.add(AnimationCollectionModel.fromJson(data));
        } catch (e, stackTrace) {
          zlog(
            level: Level.error,
            data:
                "Error parsing animation collection document ${doc.id}: $e\n$stackTrace",
          ); // Use LogLevel
        }
      }

      return animationCollections;
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error getting all animation collections: ${e.code} - ${e.message}",
      );
      throw Exception("Error getting animation collections: ${e.message}");
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error getting all animation collections: $e",
      );
      throw Exception("Error getting all animation collections: $e");
    }
  }

  @override
  Future<List<AnimationItemModel>> getDefaultAnimations() async {
    try {
      // Get all documents from the collection
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _defaultAnimationItemRef.get();

      List<AnimationItemModel> animationItems = [];

      if (snapshot.docs.isEmpty) {
        return animationItems; // Return empty list if no documents
      }

      // Iterate through the document snapshots
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        try {
          final data = doc.data();
          // --- Call your MODIFIED fromJson(Map) ---
          // Pass the data map directly. It expects '_id' and handles Timestamps.
          animationItems.add(AnimationItemModel.fromJson(data));
        } catch (e, stackTrace) {
          zlog(
            level: Level.error,
            data:
                "Error parsing default animation items document ${doc.id}: $e\n$stackTrace",
          ); // Use LogLevel
        }
      }

      return animationItems;
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error getting all default animations : ${e.code} - ${e.message}",
      );
      throw Exception("Error getting default animation : ${e.message}");
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error getting all default animation : $e",
      );
      throw Exception("Error getting all default animation : $e");
    }
  }

  @override
  Future<List<AnimationItemModel>> saveDefaultAnimations({
    required List<AnimationItemModel> animationItems,
  }) async {
    // Create a WriteBatch instance from Firestore
    final WriteBatch batch = _firestore.batch();
    // List to hold models potentially updated with new IDs (returned value)
    final List<AnimationItemModel> savedOrUpdatedItems = [];
    // Set to keep track of the IDs present in the input list
    final Set<String> inputItemIds = {};

    try {
      // --- Step 1: Fetch existing document IDs from Firestore ---
      zlog(
        level: Level.debug,
        data: "Fetching existing default animation IDs...",
      );
      final QuerySnapshot<Map<String, dynamic>> existingSnapshot =
          await _defaultAnimationItemRef.get();
      // Store existing IDs in a Set for efficient lookup
      final Set<String> existingFirestoreIds =
          existingSnapshot.docs.map((doc) => doc.id).toSet();
      zlog(
        level: Level.debug,
        data:
            "Found ${existingFirestoreIds.length} existing default animations in Firestore.",
      );

      // --- Step 2: Process input items and prepare SET operations ---
      zlog(
        level: Level.debug,
        data:
            "Processing ${animationItems.length} input default animations for saving/updating...",
      );
      for (var item in animationItems) {
        DocumentReference<Map<String, dynamic>> docRef;
        String currentItemId = item.id; // Use a local var for the definite ID

        // Ensure each item has an ID, generating one if necessary
        if (currentItemId.isNotEmpty) {
          docRef = _defaultAnimationItemRef.doc(currentItemId);
        } else {
          // Generate a new document reference (which includes a new ID)
          docRef = _defaultAnimationItemRef.doc();
          currentItemId = docRef.id; // Get the newly generated ID
          // Update the item model instance with the new ID
          item = item.copyWith(id: currentItemId);
          zlog(
            level: Level.info,
            data:
                "Generated new Firestore ID for default animation: $currentItemId",
          );
        }

        // Track the ID of this input item
        inputItemIds.add(currentItemId);

        // Convert the item model (with definite ID) to JSON
        final jsonData = item.toJson();

        // Add a 'set' operation to the batch (creates or overwrites)
        batch.set(docRef, jsonData);

        // Add the item (potentially updated with ID) to our result list
        savedOrUpdatedItems.add(item);
      }
      zlog(
        level: Level.debug,
        data: "Prepared SET operations for ${inputItemIds.length} items.",
      );

      // --- Step 3: Determine which existing IDs need to be deleted ---
      // Find IDs that are in Firestore but NOT in the input list
      final Set<String> idsToDelete = existingFirestoreIds.difference(
        inputItemIds,
      );
      // This is equivalent to:
      // final idsToDelete = existingFirestoreIds.where((id) => !inputItemIds.contains(id)).toSet();

      // --- Step 4: Add DELETE operations to the batch ---
      if (idsToDelete.isNotEmpty) {
        zlog(
          level: Level.info,
          data:
              "Identified ${idsToDelete.length} default animations in Firestore to DELETE (not in input list): ${idsToDelete.join(', ')}",
        );
        for (final idToDelete in idsToDelete) {
          batch.delete(_defaultAnimationItemRef.doc(idToDelete));
        }
      } else {
        zlog(
          level: Level.debug,
          data: "No existing default animations need deletion.",
        );
      }

      // --- Step 5: Commit all operations (sets and deletes) atomically ---
      zlog(level: Level.debug, data: "Committing batch operations...");
      await batch.commit();

      zlog(
        level: Level.info,
        data:
            "Successfully synchronized default animations. Saved/Updated: ${savedOrUpdatedItems.length}, Deleted: ${idsToDelete.length}.",
      );

      // --- Step 6: Return the list of items that were saved or updated ---
      return savedOrUpdatedItems;
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error synchronizing default animations: ${e.code} - ${e.message}",
      );
      throw Exception("Error synchronizing default animations: ${e.message}");
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Error synchronizing default animations: $e\n$stackTrace",
      );
      throw Exception("Error synchronizing default animations: $e");
    }
  }

  @override
  Future<AnimationItemModel> getDefaultSceneFromId({required String id}) {
    // TODO: implement getDefaultSceneFromId
    throw UnimplementedError();
  }
} // End of AnimationDatasourceImpl class
