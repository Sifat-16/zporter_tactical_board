import 'dart:developer' as developer;

import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/v2/data/datasources/animation_datasource_v2.dart';
import 'package:zporter_tactical_board/v2/models/animation_collection.dart';

/// Sembast implementation of [AnimationDatasourceV2].
///
/// Uses the same store name (`animation_collections`) as V1, so V1 and V2
/// can read/write the same local cache. V2 models produce V1-compatible JSON.
class AnimationLocalDatasourceV2 implements AnimationDatasourceV2 {
  static final _store =
      stringMapStoreFactory.store('animation_collections');

  /// Optional database override for testing.
  final Database? _testDb;

  AnimationLocalDatasourceV2({Database? database}) : _testDb = database;

  Future<Database> get _db async => _testDb ?? await SemDB.database;

  @override
  Future<List<AnimationCollectionModelV2>> getAllCollections(
    String userId,
  ) async {
    try {
      final db = await _db;
      final finder = Finder(filter: Filter.equals('userId', userId));
      final snapshots = await _store.find(db, finder: finder);

      final collections = <AnimationCollectionModelV2>[];
      for (final snapshot in snapshots) {
        try {
          collections
              .add(AnimationCollectionModelV2.fromJson(snapshot.value));
        } catch (e) {
          developer.log(
            'Skipping malformed collection record: ${snapshot.key}',
            name: 'AnimationLocalDatasourceV2',
            error: e,
          );
        }
      }
      return collections;
    } catch (e) {
      developer.log(
        'Error reading collections for userId=$userId',
        name: 'AnimationLocalDatasourceV2',
        error: e,
      );
      return [];
    }
  }

  @override
  Future<AnimationCollectionModelV2?> getCollection(
    String collectionId,
  ) async {
    try {
      final db = await _db;
      final record = await _store.record(collectionId).get(db);
      if (record == null) return null;
      return AnimationCollectionModelV2.fromJson(record);
    } catch (e) {
      developer.log(
        'Error reading collection id=$collectionId',
        name: 'AnimationLocalDatasourceV2',
        error: e,
      );
      return null;
    }
  }

  @override
  Future<AnimationCollectionModelV2> saveCollection(
    AnimationCollectionModelV2 collection,
  ) async {
    final db = await _db;
    final id = collection.id.isEmpty
        ? RandomGenerator.generateId()
        : collection.id;
    final saved = collection.copyWith(id: id);
    await _store.record(id).put(db, saved.toJson());
    return saved;
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    final db = await _db;
    await _store.record(collectionId).delete(db);
  }
}
