import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/core/constants/firestore_constant.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/animation/datasource/animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/animation/model/history_model.dart';

class AnimationRemoteDatasourceImpl implements AnimationDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Map<String, dynamic>> _animationCollectionRef;
  late final CollectionReference<Map<String, dynamic>> _defaultAnimationItemRef;

  AnimationRemoteDatasourceImpl() {
    _animationCollectionRef = _firestore.collection(
      FirestoreConstant.ANIMATION_COLLECTIONS,
    );
    _defaultAnimationItemRef = _firestore.collection(
      FirestoreConstant
          .DEFAULT_ANIMATION_ITEMS, // Still used, but now userId scoped
    );
  }

  // --- Animation Collection Methods (User-Specific) ---
  // (saveAnimationCollection and getAllAnimationCollection remain the same as previous version)
  @override
  Future<AnimationCollectionModel> saveAnimationCollection({
    required AnimationCollectionModel animationCollectionModel,
  }) async {
    try {
      String docId = animationCollectionModel.id;
      final String userId = animationCollectionModel.userId;
      if (docId.isEmpty) {
        final newDocRef = _animationCollectionRef.doc();
        docId = newDocRef.id;
        animationCollectionModel = animationCollectionModel.copyWith(id: docId);
        zlog(
          level: Level.info,
          data:
              "Firestore: Generated new document ID for animation collection: $docId for user: $userId",
        );
      }
      final jsonData = animationCollectionModel.toJson();
      await _animationCollectionRef.doc(docId).set(jsonData);
      zlog(
        level: Level.debug,
        data:
            "Firestore: Saved/Updated animation collection ID: $docId for user: $userId",
      );
      return animationCollectionModel;
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error saving animation collection for user ${animationCollectionModel.userId}: ${e.code} - ${e.message}",
      );
      throw Exception("Error saving animation collection: ${e.message}");
    } catch (e) {
      zlog(
        level: Level.error,
        data:
            "Error saving animation collection for user ${animationCollectionModel.userId}: $e",
      );
      throw Exception("Error saving animation collection: $e");
    }
  }

  @override
  Future<List<AnimationCollectionModel>> getAllAnimationCollection({
    required String userId,
  }) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _animationCollectionRef
              .where('userId', isEqualTo: userId)
              .get();
      List<AnimationCollectionModel> animationCollections = [];
      if (snapshot.docs.isEmpty) {
        zlog(
          level: Level.debug,
          data: "Firestore: No animation collections found for user: $userId.",
        );
        return animationCollections;
      }

      zlog(data: "Animation collection found ${snapshot.docs}");
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        try {
          animationCollections.add(
            AnimationCollectionModel.fromJson(doc.data()),
          );
        } catch (e, stackTrace) {
          zlog(
            level: Level.error,
            data:
                "Firestore: Error parsing animation collection document ${doc.id} for user $userId: $e\n$stackTrace",
          );
        }
      }
      zlog(
        level: Level.debug,
        data:
            "Firestore: Fetched ${animationCollections.length} animation collections for user: $userId.",
      );
      return animationCollections;
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error getting animation collections for user $userId: ${e.code} - ${e.message}",
      );
      throw Exception(
        "Error getting animation collections for user $userId: ${e.message}",
      );
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error getting animation collections for user $userId: $e",
      );
      throw Exception(
        "Error getting all animation collections for user $userId: $e",
      );
    }
  }

  // --- Default Animation Item Methods (NOW User-Specific) ---

  @override
  Future<List<AnimationItemModel>> getDefaultAnimations({
    required String userId, // <-- Takes userId
  }) async {
    try {
      // --- ADDED: Filter by userId ---
      // final QuerySnapshot<Map<String, dynamic>> snapshot =
      //     await _defaultAnimationItemRef
      //         .where('userId', isEqualTo: userId)
      //         .get();

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _defaultAnimationItemRef
              .where('userId', isEqualTo: userId)
              .orderBy('orderIndex') // ADD THIS LINE
              .get();

      List<AnimationItemModel> animationItems = [];
      if (snapshot.docs.isEmpty) {
        zlog(
          level: Level.debug,
          data: "Firestore: No default animations found for user: $userId.",
        );
        return animationItems;
      }
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        try {
          // Ensure fromJson handles userId correctly
          animationItems.add(AnimationItemModel.fromJson(doc.data()));
        } catch (e, stackTrace) {
          zlog(
            level: Level.error,
            data:
                "Firestore: Error parsing default animation items document ${doc.id} for user $userId: $e\n$stackTrace",
          );
        }
      }
      zlog(
        level: Level.debug,
        data:
            "Firestore: Fetched ${animationItems.length} default animations for user: $userId.",
      );
      return animationItems;
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error getting default animations for user $userId: ${e.code} - ${e.message}",
      );
      throw Exception(
        "Error getting default animations for user $userId: ${e.message}",
      );
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error getting default animations for user $userId: $e",
      );
      throw Exception("Error getting default animations for user $userId: $e");
    }
  }

  @override
  Future<List<AnimationItemModel>> saveDefaultAnimations({
    required List<AnimationItemModel> animationItems,
    required String userId, // <-- Takes userId
  }) async {
    final WriteBatch batch = _firestore.batch();
    final List<AnimationItemModel> savedOrUpdatedItems = [];
    final Set<String> inputItemIds = {};

    try {
      // --- MODIFIED: Fetch existing IDs ONLY for this user ---
      zlog(
        level: Level.debug,
        data: "Fetching existing default animation IDs for user $userId...",
      );
      final QuerySnapshot<Map<String, dynamic>> existingSnapshot =
          await _defaultAnimationItemRef
              .where('userId', isEqualTo: userId)
              .get();
      final Set<String> existingFirestoreIds =
          existingSnapshot.docs.map((doc) => doc.id).toSet();
      zlog(
        level: Level.debug,
        data:
            "Found ${existingFirestoreIds.length} existing default animations for user $userId in Firestore.",
      );

      zlog(
        level: Level.debug,
        data:
            "Processing ${animationItems.length} input default animations for saving/updating for user $userId...",
      );
      for (var item in animationItems) {
        DocumentReference<Map<String, dynamic>> docRef;
        String currentItemId = item.id;

        // --- IMPORTANT: Ensure item has the correct userId before saving ---
        item = item.copyWith(userId: userId); // Assign the target userId

        if (currentItemId.isEmpty || currentItemId == null) {
          // Check for empty or null ID
          docRef = _defaultAnimationItemRef.doc(); // Generate Firestore ID
          currentItemId = docRef.id;
          item = item.copyWith(
            id: currentItemId,
          ); // Update ID along with userId
          zlog(
            level: Level.info,
            data:
                "Generated new Firestore ID for default animation: $currentItemId for user $userId",
          );
        } else {
          // If ID exists, ensure we are using the one from the potentially updated item
          currentItemId = item.id;
          docRef = _defaultAnimationItemRef.doc(currentItemId);
        }

        inputItemIds.add(currentItemId);
        final jsonData = item.toJson(); // toJson includes the correct userId
        batch.set(
          docRef,
          jsonData,
        ); // Set operation for the specific user's item
        savedOrUpdatedItems.add(item); // Add the item with correct userId
      }
      zlog(
        level: Level.debug,
        data:
            "Prepared SET operations for ${inputItemIds.length} items for user $userId.",
      );

      // Determine IDs to delete (only those belonging to this user)
      final Set<String> idsToDelete = existingFirestoreIds.difference(
        inputItemIds,
      );

      if (idsToDelete.isNotEmpty) {
        zlog(
          level: Level.info,
          data:
              "Identified ${idsToDelete.length} default animations for user $userId to DELETE: ${idsToDelete.join(', ')}",
        );
        for (final idToDelete in idsToDelete) {
          // Deleting by doc ID is safe as idsToDelete was derived from a userId-filtered query
          batch.delete(_defaultAnimationItemRef.doc(idToDelete));
        }
      } else {
        zlog(
          level: Level.debug,
          data:
              "No existing default animations need deletion for user $userId.",
        );
      }

      zlog(
        level: Level.debug,
        data: "Committing batch operations for user $userId...",
      );
      await batch.commit();

      zlog(
        level: Level.info,
        data:
            "Successfully synchronized default animations for user $userId. Saved/Updated: ${savedOrUpdatedItems.length}, Deleted: ${idsToDelete.length}.",
      );
      return savedOrUpdatedItems;
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error synchronizing default animations for user $userId: ${e.code} - ${e.message}",
      );
      throw Exception(
        "Error synchronizing default animations for user $userId: ${e.message}",
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Error synchronizing default animations for user $userId: $e\n$stackTrace",
      );
      throw Exception(
        "Error synchronizing default animations for user $userId: $e",
      );
    }
  }

  @override
  Future<AnimationItemModel?> getDefaultSceneFromId({
    required String id,
    required String userId, // <-- Takes userId
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _defaultAnimationItemRef.doc(id).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final fetchedUserId = data['userId'] as String?;
          // --- ADDED: Verify userId match ---
          if (fetchedUserId == userId) {
            zlog(
              level: Level.debug,
              data:
                  "Firestore: Found default scene ID: $id belonging to user $userId.",
            );
            // Ensure fromJson handles userId and potential Timestamps
            return AnimationItemModel.fromJson(data);
          } else {
            zlog(
              data:
                  "Firestore: Default scene ID: $id found, but belongs to different user (expected $userId, found $fetchedUserId).",
            );
            return null; // Found, but not for this user
          }
        } else {
          zlog(
            data:
                "Firestore: Default scene document $id exists but data is null (user $userId).",
          );
          return null; // Document exists but no data
        }
      } else {
        zlog(
          level: Level.debug,
          data: "Firestore: Default scene ID: $id not found for user $userId.",
        );
        return null; // Not found at all
      }
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error getting default scene by ID $id for user $userId: ${e.code} - ${e.message}",
      );
      throw Exception(
        "Error getting default scene $id for user $userId: ${e.message}",
      );
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error getting default scene by ID $id for user $userId: $e",
      );
      throw Exception("Error getting default scene $id for user $userId: $e");
    }
  }

  @override
  Future<void> deleteHistory({required String id}) {
    // TODO: implement deleteHistory
    throw UnimplementedError();
  }

  @override
  Future<HistoryModel?> getHistory({required String id}) {
    // TODO: implement getHistory
    throw UnimplementedError();
  }

  @override
  Future<void> saveHistory({required HistoryModel historyModel}) {
    // TODO: implement saveHistory
    throw UnimplementedError();
  }

  @override
  Stream<HistoryModel?> getHistoryStream({required String id}) {
    // TODO: implement getHistoryStream
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAnimationCollection({required String collectionId}) async {
    try {
      await _animationCollectionRef.doc(collectionId).delete();
      zlog(
        level: Level.info,
        data:
            "Firestore: Successfully deleted animation collection ID: $collectionId",
      );
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error deleting animation collection $collectionId: ${e.code} - ${e.message}",
      );
      throw Exception("Error deleting animation collection: ${e.message}");
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error deleting animation collection $collectionId: $e",
      );
      throw Exception("Error deleting animation collection: $e");
    }
  }

  @override
  Future<void> saveAllDefaultAnimations(List<AnimationModel> animations) async {
    final batch = _firestore.batch();
    try {
      for (final animation in animations) {
        final docRef = _defaultAnimationItemRef.doc(animation.id);
        // Use set with merge:true to be safe, it updates or creates.
        batch.set(docRef, animation.toJson(), SetOptions(merge: true));
      }
      await batch.commit();
      zlog(
        level: Level.info,
        data:
            "Firestore: Successfully batch-saved ${animations.length} default animations.",
      );
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error in saveAllDefaultAnimations: ${e.code} - ${e.message}",
      );
      throw Exception("Error saving default animations: ${e.message}");
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error in saveAllDefaultAnimations: $e",
      );
      throw Exception("Error saving default animations: $e");
    }
  }
}
