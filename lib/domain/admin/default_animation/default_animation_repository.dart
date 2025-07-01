import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart'; // Your AnimationModel

abstract class DefaultAnimationRepository {
  // Animation Methods
  Future<List<AnimationModel>> getAllDefaultAnimations();
  Future<AnimationModel> saveDefaultAnimation(AnimationModel animationModel);
  Future<void> deleteDefaultAnimation(String animationId);

  // Collection Methods
  Future<List<AnimationCollectionModel>> getAllDefaultAnimationCollections();
  Future<AnimationCollectionModel> saveDefaultAnimationCollection(
      AnimationCollectionModel collection);
  Future<void> deleteDefaultAnimationCollection(String collectionId);
  Future<void> saveAllDefaultAnimationCollections(
      List<AnimationCollectionModel> collections);

  // Migration
  Future<List<AnimationModel>> getOrphanedDefaultAnimations();

  // ADDED
  Future<void> saveAllDefaultAnimations(List<AnimationModel> animations);
}
