import 'package:zporter_tactical_board/data/animation/datasource/animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';

class AnimationRepositoryImpl implements AnimationRepository {
  final AnimationDatasource animationDatasource;
  AnimationRepositoryImpl({required this.animationDatasource});
  @override
  Future<AnimationCollectionModel> saveAnimationCollection({
    required AnimationCollectionModel animationCollectionModel,
  }) async {
    return await animationDatasource.saveAnimationCollection(
      animationCollectionModel: animationCollectionModel,
    );
  }

  @override
  Future<List<AnimationCollectionModel>> getAllAnimationCollection() async {
    return await animationDatasource.getAllAnimationCollection();
  }

  @override
  Future<List<AnimationItemModel>> getDefaultAnimations() async {
    return await animationDatasource.getDefaultAnimations();
  }

  @override
  Future<List<AnimationItemModel>> saveDefaultAnimations({
    required List<AnimationItemModel> animationItems,
  }) async {
    return await animationDatasource.saveDefaultAnimations(
      animationItems: animationItems,
    );
  }
}
