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

class AnimationDatasourceImpl implements AnimationDatasource {
  // Get Firestore instance (can be injected)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to the Firestore collection
  late final CollectionReference<Map<String, dynamic>> _animationCollectionRef;

  // Constructor initializes the collection reference
  AnimationDatasourceImpl() {
    _animationCollectionRef = _firestore.collection(
      FirestoreConstant.ANIMATION_COLLECTIONS,
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
}
