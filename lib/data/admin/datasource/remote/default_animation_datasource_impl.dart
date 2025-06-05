import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart'; // Assuming you use this
import 'package:zporter_tactical_board/app/helper/logger.dart'; // Your zlog helper
import 'package:zporter_tactical_board/data/admin/datasource/default_animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';

// Define this constant or import it
const String DEFAULT_ANIMATIONS_COLLECTION = "defaultAnimations";
// This system user ID will be embedded in each AnimationModel if your model requires it.
const String SYSTEM_USER_ID_FOR_DEFAULTS = "system_default_user_for_animations";

class DefaultAnimationDatasourceImpl implements DefaultAnimationDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _defaultAnimationsRef;

  DefaultAnimationDatasourceImpl() {
    _defaultAnimationsRef = _firestore.collection(
      DEFAULT_ANIMATIONS_COLLECTION,
    );
  }

  @override
  Future<List<AnimationModel>> getAllDefaultAnimations() async {
    zlog(
      level: Level.info,
      data: "Firestore DS: Fetching all default animations...",
    );
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _defaultAnimationsRef.get();

      if (snapshot.docs.isEmpty) {
        zlog(
          level: Level.debug,
          data: "Firestore DS: No default animations found.",
        );
        return [];
      }

      List<AnimationModel> animations = [];
      for (final doc in snapshot.docs) {
        try {
          animations.add(AnimationModel.fromJson(doc.data()));
        } catch (e, stackTrace) {
          zlog(
            level: Level.error,
            data:
                "Firestore DS: Error parsing default animation document ${doc.id}: $e\n$stackTrace",
          );
          // Optionally skip problematic documents or rethrow
        }
      }
      zlog(
        level: Level.debug,
        data: "Firestore DS: Fetched ${animations.length} default animations.",
      );
      return animations;
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firestore DS: Firebase error getting default animations: ${e.code} - ${e.message}",
      );
      throw Exception("Error getting default animations: ${e.message}");
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Firestore DS: Generic error getting default animations: $e\n$stackTrace",
      );
      throw Exception("Error getting default animations: $e");
    }
  }

  @override
  Future<AnimationModel> saveDefaultAnimation(
    AnimationModel animationModel,
  ) async {
    AnimationModel modelToSave = animationModel;
    try {
      String docId = modelToSave.id;

      // Ensure the model has the system user ID
      // This assumes your AnimationModel has a userId field and copyWith method.
      // If it doesn't, you might store this implicitly or decide not to store it for system defaults.
      if (modelToSave.userId != SYSTEM_USER_ID_FOR_DEFAULTS) {
        modelToSave = modelToSave.copyWith(userId: SYSTEM_USER_ID_FOR_DEFAULTS);
      }

      if (docId.isEmpty) {
        final newDocRef = _defaultAnimationsRef.doc();
        docId = newDocRef.id;
        modelToSave = modelToSave.copyWith(
          id: docId,
        ); // Update model with new ID
        zlog(
          level: Level.info,
          data: "Firestore DS: Generated new ID for default animation: $docId",
        );
      }

      final jsonData = modelToSave.toJson();
      await _defaultAnimationsRef.doc(docId).set(jsonData);
      zlog(
        level: Level.debug,
        data: "Firestore DS: Saved/Updated default animation ID: $docId",
      );
      return modelToSave; // Return the model, possibly with the new ID
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firestore DS: Firebase error saving default animation ${modelToSave.id}: ${e.code} - ${e.message}",
      );
      throw Exception("Error saving default animation: ${e.message}");
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Firestore DS: Generic error saving default animation ${modelToSave.id}: $e\n$stackTrace",
      );
      throw Exception("Error saving default animation: $e");
    }
  }

  @override
  Future<void> deleteDefaultAnimation(String animationId) async {
    zlog(
      level: Level.info,
      data: "Firestore DS: Deleting default animation ID: $animationId",
    );
    if (animationId.isEmpty) {
      zlog(
        level: Level.warning,
        data: "Firestore DS: Animation ID is empty. Cannot delete.",
      );
      throw Exception("Animation ID cannot be empty for deletion.");
    }
    try {
      await _defaultAnimationsRef.doc(animationId).delete();
      zlog(
        level: Level.debug,
        data: "Firestore DS: Deleted default animation ID: $animationId",
      );
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firestore DS: Firebase error deleting default animation $animationId: ${e.code} - ${e.message}",
      );
      throw Exception("Error deleting default animation: ${e.message}");
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            "Firestore DS: Generic error deleting default animation $animationId: $e\n$stackTrace",
      );
      throw Exception("Error deleting default animation: $e");
    }
  }
}
