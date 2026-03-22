import 'package:zporter_tactical_board/v2/models/animation_collection.dart';

/// Abstract datasource interface for animation collection storage.
///
/// Shared contract for both local (Sembast) and remote (Firestore)
/// datasources. Operates at the collection level — animations and scenes
/// are nested within the collection JSON.
abstract class AnimationDatasourceV2 {
  /// Fetch all collections for a user.
  Future<List<AnimationCollectionModelV2>> getAllCollections(String userId);

  /// Get a single collection by ID. Returns null if not found.
  Future<AnimationCollectionModelV2?> getCollection(String collectionId);

  /// Save (create or update) a collection. Returns the saved collection.
  Future<AnimationCollectionModelV2> saveCollection(
    AnimationCollectionModelV2 collection,
  );

  /// Delete a collection by ID.
  Future<void> deleteCollection(String collectionId);
}
