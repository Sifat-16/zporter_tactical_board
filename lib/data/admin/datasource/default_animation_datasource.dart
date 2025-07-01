import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart'; // Your AnimationModel

abstract class DefaultAnimationDatasource {
  // --- Animation Methods (Kept for managing individual items) ---
  Future<List<AnimationModel>> getAllDefaultAnimations();
  Future<AnimationModel> saveDefaultAnimation(AnimationModel animationModel);
  Future<void> deleteDefaultAnimation(String animationId);

  // --- Collection Methods (NEW) ---
  Future<List<AnimationCollectionModel>> getAllDefaultAnimationCollections();
  Future<AnimationCollectionModel> saveDefaultAnimationCollection(
      AnimationCollectionModel collection);
  Future<void> deleteDefaultAnimationCollection(String collectionId);
  Future<void> saveAllDefaultAnimationCollections(
      List<AnimationCollectionModel> collections);

  // --- Migration Method ---
  Future<List<AnimationModel>> getOrphanedDefaultAnimations();

  // ADDED: This method is crucial for saving reordered animations
  Future<void> saveAllDefaultAnimations(List<AnimationModel> animations);
}
