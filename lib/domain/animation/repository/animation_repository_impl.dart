import 'package:zporter_tactical_board/data/animation/datasource/animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/history_model.dart';
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
  Future<List<AnimationCollectionModel>> getAllAnimationCollection({
    required String userId,
  }) async {
    return await animationDatasource.getAllAnimationCollection(userId: userId);
  }

  @override
  Future<List<AnimationItemModel>> getDefaultAnimations({
    required String userId,
  }) async {
    return await animationDatasource.getDefaultAnimations(userId: userId);
  }

  @override
  Future<List<AnimationItemModel>> saveDefaultAnimations({
    required List<AnimationItemModel> animationItems,
    required String userId,
  }) async {
    return await animationDatasource.saveDefaultAnimations(
      animationItems: animationItems,
      userId: userId,
    );
  }

  @override
  Future<AnimationItemModel> getDefaultSceneFromId({
    required String id,
    required String userId,
  }) {
    // TODO: implement getDefaultSceneFromId
    throw UnimplementedError();
  }

  @override
  Future<void> deleteHistory({required String id}) async {
    return await animationDatasource.deleteHistory(id: id);
  }

  @override
  Future<HistoryModel?> getHistory({required String id}) async {
    return await animationDatasource.getHistory(id: id);
  }

  @override
  Future<void> saveHistory({required HistoryModel historyModel}) async {
    return await animationDatasource.saveHistory(historyModel: historyModel);
  }

  @override
  Stream<HistoryModel?> getHistoryStream({required String id}) {
    return animationDatasource.getHistoryStream(id: id);
  }

  @override
  Future<void> deleteAnimationCollection({required String collectionId}) async {
    // This implementation simply passes the call to the underlying datasource.
    return await animationDatasource.deleteAnimationCollection(
        collectionId: collectionId);
  }
}
