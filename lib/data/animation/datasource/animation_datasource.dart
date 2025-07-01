import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/animation/model/history_model.dart';

abstract class AnimationDatasource {
  Future<List<AnimationCollectionModel>> getAllAnimationCollection({
    required String userId,
  });

  Future<AnimationCollectionModel> saveAnimationCollection({
    required AnimationCollectionModel
        animationCollectionModel, // Contains userId
  });

  Future<List<AnimationItemModel>> getDefaultAnimations({
    required String userId, // <-- ADDED: userId parameter
  });

  Future<List<AnimationItemModel>> saveDefaultAnimations({
    required List<AnimationItemModel> animationItems,
    required String userId, // <-- ADDED: userId parameter
  });

  Future<AnimationItemModel?> getDefaultSceneFromId({
    required String id,
    required String userId, // <-- ADDED: userId parameter
  });

  /// Saves or updates the history for a specific item (identified by historyModel.id).
  Future<void> saveHistory({required HistoryModel historyModel});

  /// Retrieves the history for a specific item ID. Returns null if not found.
  Future<HistoryModel?> getHistory({required String id});

  /// Deletes the history associated with a specific item ID.
  Future<void> deleteHistory({required String id});

  Stream<HistoryModel?> getHistoryStream({required String id});

  Future<void> deleteAnimationCollection({required String collectionId});

  Future<void> saveAllDefaultAnimations(List<AnimationModel> animations);
}
