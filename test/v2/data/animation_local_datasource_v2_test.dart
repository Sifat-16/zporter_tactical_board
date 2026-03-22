import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:zporter_tactical_board/v2/data/datasources/local/animation_local_datasource_v2.dart';
import 'package:zporter_tactical_board/v2/models/animation_collection.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';

void main() {
  late Database db;
  late AnimationLocalDatasourceV2 datasource;

  final now = DateTime(2025, 1, 15, 10, 30);

  AnimationCollectionModelV2 _makeCollection({
    required String id,
    String userId = 'user1',
    String name = 'Test Collection',
    List<AnimationModelV2>? animations,
  }) {
    return AnimationCollectionModelV2(
      id: id,
      name: name,
      userId: userId,
      animations: animations ?? [],
      createdAt: now,
      updatedAt: now,
    );
  }

  AnimationModelV2 _makeAnimation({
    required String id,
    String name = 'Test Animation',
    String userId = 'user1',
  }) {
    return AnimationModelV2(
      id: id,
      name: name,
      userId: userId,
      fieldColor: const Color(0xFF9E9E9E),
      animationScenes: [
        SceneModelV2.empty(id: 's1', userId: userId),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() async {
    db = await newDatabaseFactoryMemory().openDatabase('test.db');
    datasource = AnimationLocalDatasourceV2(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AnimationLocalDatasourceV2', () {
    group('getAllCollections', () {
      test('returns empty list when no collections exist', () async {
        final result = await datasource.getAllCollections('user1');
        expect(result, isEmpty);
      });

      test('returns collections for the given user', () async {
        await datasource.saveCollection(_makeCollection(id: 'c1'));
        await datasource.saveCollection(
          _makeCollection(id: 'c2', userId: 'user2'),
        );

        final result = await datasource.getAllCollections('user1');
        expect(result, hasLength(1));
        expect(result.first.id, 'c1');
      });

      test('returns multiple collections for same user', () async {
        await datasource.saveCollection(
          _makeCollection(id: 'c1', name: 'First'),
        );
        await datasource.saveCollection(
          _makeCollection(id: 'c2', name: 'Second'),
        );

        final result = await datasource.getAllCollections('user1');
        expect(result, hasLength(2));
      });

      test('skips malformed records gracefully', () async {
        // Save a valid collection
        await datasource.saveCollection(_makeCollection(id: 'c1'));

        // Manually insert a malformed record
        final store =
            stringMapStoreFactory.store('animation_collections');
        await store.record('bad').put(db, {'garbage': true});

        final result = await datasource.getAllCollections('user1');
        // Should still return the valid collection
        expect(result, hasLength(1));
        expect(result.first.id, 'c1');
      });
    });

    group('getCollection', () {
      test('returns null when collection does not exist', () async {
        final result = await datasource.getCollection('nonexistent');
        expect(result, isNull);
      });

      test('returns collection by ID', () async {
        await datasource.saveCollection(
          _makeCollection(id: 'c1', name: 'My Collection'),
        );

        final result = await datasource.getCollection('c1');
        expect(result, isNotNull);
        expect(result!.id, 'c1');
        expect(result.name, 'My Collection');
      });
    });

    group('saveCollection', () {
      test('saves and retrieves a collection', () async {
        final collection = _makeCollection(id: 'c1', name: 'Saved');
        await datasource.saveCollection(collection);

        final result = await datasource.getCollection('c1');
        expect(result, isNotNull);
        expect(result!.name, 'Saved');
        expect(result.userId, 'user1');
      });

      test('generates ID when empty', () async {
        final collection = _makeCollection(id: '', name: 'No ID');
        final saved = await datasource.saveCollection(collection);

        expect(saved.id, isNotEmpty);
        expect(saved.name, 'No ID');

        // Should be retrievable by generated ID
        final result = await datasource.getCollection(saved.id);
        expect(result, isNotNull);
      });

      test('overwrites existing collection with same ID', () async {
        await datasource.saveCollection(
          _makeCollection(id: 'c1', name: 'Original'),
        );
        await datasource.saveCollection(
          _makeCollection(id: 'c1', name: 'Updated'),
        );

        final result = await datasource.getCollection('c1');
        expect(result!.name, 'Updated');

        // Should only have one record
        final all = await datasource.getAllCollections('user1');
        expect(all, hasLength(1));
      });

      test('preserves nested animations', () async {
        final anim = _makeAnimation(id: 'a1');
        final collection = _makeCollection(
          id: 'c1',
          animations: [anim],
        );
        await datasource.saveCollection(collection);

        final result = await datasource.getCollection('c1');
        expect(result!.animations, hasLength(1));
        expect(result.animations.first.id, 'a1');
        expect(result.animations.first.animationScenes, hasLength(1));
      });

      test('preserves hasPendingUpdates flag', () async {
        final collection = _makeCollection(id: 'c1').copyWith(
          hasPendingUpdates: true,
        );
        await datasource.saveCollection(collection);

        final result = await datasource.getCollection('c1');
        expect(result!.hasPendingUpdates, true);
      });
    });

    group('deleteCollection', () {
      test('deletes existing collection', () async {
        await datasource.saveCollection(_makeCollection(id: 'c1'));

        await datasource.deleteCollection('c1');

        final result = await datasource.getCollection('c1');
        expect(result, isNull);
      });

      test('no-op when deleting nonexistent collection', () async {
        // Should not throw
        await datasource.deleteCollection('nonexistent');
      });

      test('does not affect other collections', () async {
        await datasource.saveCollection(_makeCollection(id: 'c1'));
        await datasource.saveCollection(_makeCollection(id: 'c2'));

        await datasource.deleteCollection('c1');

        final all = await datasource.getAllCollections('user1');
        expect(all, hasLength(1));
        expect(all.first.id, 'c2');
      });
    });

    group('V1 JSON compatibility', () {
      test('reads V1-format JSON from store', () async {
        // Simulate V1 writing a collection to the same store
        final store =
            stringMapStoreFactory.store('animation_collections');
        final v1Json = {
          '_id': 'v1-collection',
          'name': 'V1 Collection',
          'userId': 'user1',
          'animations': <Map<String, dynamic>>[],
          'createdAt': '2025-01-15T10:30:00.000',
          'updatedAt': '2025-01-15T10:30:00.000',
          'orderIndex': 0,
          'isTemplate': false,
          'hasPendingUpdates': false,
        };
        await store.record('v1-collection').put(db, v1Json);

        final result = await datasource.getCollection('v1-collection');
        expect(result, isNotNull);
        expect(result!.id, 'v1-collection');
        expect(result.name, 'V1 Collection');
        expect(result.schemaVersion, 1); // V1 has no schemaVersion field
      });

      test('round-trips V2 JSON correctly', () async {
        final original = _makeCollection(
          id: 'c1',
          name: 'Round Trip',
          animations: [_makeAnimation(id: 'a1')],
        );
        await datasource.saveCollection(original);
        final loaded = await datasource.getCollection('c1');

        expect(loaded!.id, original.id);
        expect(loaded.name, original.name);
        expect(loaded.userId, original.userId);
        expect(loaded.animations.length, original.animations.length);
        expect(loaded.orderIndex, original.orderIndex);
        expect(loaded.isTemplate, original.isTemplate);
      });
    });
  });
}
