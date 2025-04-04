import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';

abstract class AnimationDatasource {
  Future<List<AnimationCollectionModel>> getAllAnimationCollection();
  Future<AnimationCollectionModel> saveAnimationCollection({
    required AnimationCollectionModel animationCollectionModel,
  });
  Future<List<AnimationItemModel>> getDefaultAnimations();

  Future<List<AnimationItemModel>> saveDefaultAnimations({
    required List<AnimationItemModel> animationItems,
  });

  Future<AnimationItemModel?> getDefaultSceneFromId({required String id});
}
