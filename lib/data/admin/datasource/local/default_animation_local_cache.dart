import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';

/// Sembast-backed local cache for admin/default animation data.
/// Used to avoid blocking on Firebase when cached data is available.
class DefaultAnimationLocalCache {
  DefaultAnimationLocalCache._();

  static final _collectionsStore =
      stringMapStoreFactory.store('default_animation_collections_cache');
  static final _animationsStore =
      stringMapStoreFactory.store('default_animations_cache');

  // --------------- Collections ---------------

  static Future<List<AnimationCollectionModel>>
      getCachedCollections() async {
    try {
      final db = await SemDB.database;
      final snapshots = await _collectionsStore.find(db);
      if (snapshots.isEmpty) return [];
      return snapshots
          .map((s) => AnimationCollectionModel.fromJson(s.value))
          .toList();
    } catch (e) {
      zlog(data: "[DefaultAnimLocalCache] Error reading collections: $e");
      return [];
    }
  }

  static Future<void> cacheCollections(
      List<AnimationCollectionModel> collections) async {
    try {
      final db = await SemDB.database;
      await db.transaction((txn) async {
        await _collectionsStore.delete(txn);
        for (final col in collections) {
          await _collectionsStore.record(col.id).put(txn, col.toJson());
        }
      });
    } catch (e) {
      zlog(data: "[DefaultAnimLocalCache] Error caching collections: $e");
    }
  }

  // --------------- Animations ---------------

  static Future<List<AnimationModel>> getCachedAnimations() async {
    try {
      final db = await SemDB.database;
      final snapshots = await _animationsStore.find(db);
      if (snapshots.isEmpty) return [];
      return snapshots
          .map((s) => AnimationModel.fromJson(s.value))
          .toList();
    } catch (e) {
      zlog(data: "[DefaultAnimLocalCache] Error reading animations: $e");
      return [];
    }
  }

  static Future<void> cacheAnimations(
      List<AnimationModel> animations) async {
    try {
      final db = await SemDB.database;
      await db.transaction((txn) async {
        await _animationsStore.delete(txn);
        for (final anim in animations) {
          await _animationsStore.record(anim.id).put(txn, anim.toJson());
        }
      });
    } catch (e) {
      zlog(data: "[DefaultAnimLocalCache] Error caching animations: $e");
    }
  }
}
