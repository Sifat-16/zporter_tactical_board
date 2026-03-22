import 'package:zporter_tactical_board/v2/models/animation_collection.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';

/// Abstract repository for animation data persistence.
///
/// V2 equivalent of V1's [AnimationRepository]. Uses V2 model types natively.
/// JSON format is V1-compatible — the same Firestore collections and Sembast
/// stores can be shared between V1 and V2 code.
abstract class AnimationRepositoryV2 {
  /// Fetch all animation collections for a user.
  Future<List<AnimationCollectionModelV2>> getAllCollections(String userId);

  /// Save (create or update) a collection. Returns the saved collection.
  Future<AnimationCollectionModelV2> saveCollection(
    AnimationCollectionModelV2 collection,
  );

  /// Delete a collection by ID.
  Future<void> deleteCollection(String collectionId);

  /// Save (create or update) an animation within a collection.
  Future<AnimationModelV2> saveAnimation(
    AnimationModelV2 animation,
    String collectionId,
  );

  /// Delete an animation from a collection.
  Future<void> deleteAnimation(String animationId, String collectionId);

  /// Save (create or update) a scene within an animation.
  Future<SceneModelV2> saveScene(
    SceneModelV2 scene,
    String animationId,
    String collectionId,
  );

  /// Delete a scene from an animation.
  Future<void> deleteScene(
    String sceneId,
    String animationId,
    String collectionId,
  );
}
