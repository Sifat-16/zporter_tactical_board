import 'package:zporter_tactical_board/data/admin/datasource/default_animation_datasource.dart'; // The new datasource interface
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';

import 'default_animation_repository.dart';

class DefaultAnimationRepositoryImpl implements DefaultAnimationRepository {
  final DefaultAnimationDatasource datasource;

  DefaultAnimationRepositoryImpl({required this.datasource});

  @override
  Future<List<AnimationModel>> getAllDefaultAnimations() =>
      datasource.getAllDefaultAnimations();

  @override
  Future<AnimationModel> saveDefaultAnimation(AnimationModel animationModel) =>
      datasource.saveDefaultAnimation(animationModel);

  @override
  Future<void> deleteDefaultAnimation(String animationId) =>
      datasource.deleteDefaultAnimation(animationId);

  @override
  Future<List<AnimationCollectionModel>> getAllDefaultAnimationCollections() =>
      datasource.getAllDefaultAnimationCollections();

  @override
  Future<AnimationCollectionModel> saveDefaultAnimationCollection(
          AnimationCollectionModel collection) =>
      datasource.saveDefaultAnimationCollection(collection);

  @override
  Future<void> deleteDefaultAnimationCollection(String collectionId) =>
      datasource.deleteDefaultAnimationCollection(collectionId);

  @override
  Future<void> saveAllDefaultAnimationCollections(
          List<AnimationCollectionModel> collections) =>
      datasource.saveAllDefaultAnimationCollections(collections);

  @override
  Future<List<AnimationModel>> getOrphanedDefaultAnimations() =>
      datasource.getOrphanedDefaultAnimations();

  @override
  Future<void> saveAllDefaultAnimations(List<AnimationModel> animations) =>
      datasource.saveAllDefaultAnimations(animations);
}
