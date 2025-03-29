import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';

abstract class AnimationRepository {
  Future<List<AnimationCollectionModel>> getAllAnimationCollection();
  Future<AnimationCollectionModel> saveAnimationCollection({
    required AnimationCollectionModel animationCollectionModel,
  });
}
