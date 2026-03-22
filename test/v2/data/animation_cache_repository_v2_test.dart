import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/data/datasources/animation_datasource_v2.dart';
import 'package:zporter_tactical_board/v2/data/repositories/animation_cache_repository_v2.dart';
import 'package:zporter_tactical_board/v2/models/animation_collection.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';

/// In-memory datasource for testing the cache repository.
class _FakeDatasource implements AnimationDatasourceV2 {
  final Map<String, AnimationCollectionModelV2> _store = {};
  int saveCallCount = 0;
  int getAllCallCount = 0;
  bool shouldThrow = false;

  @override
  Future<List<AnimationCollectionModelV2>> getAllCollections(
    String userId,
  ) async {
    getAllCallCount++;
    if (shouldThrow) throw Exception('Datasource error');
    return _store.values.where((c) => c.userId == userId).toList();
  }

  @override
  Future<AnimationCollectionModelV2?> getCollection(
    String collectionId,
  ) async {
    if (shouldThrow) throw Exception('Datasource error');
    return _store[collectionId];
  }

  @override
  Future<AnimationCollectionModelV2> saveCollection(
    AnimationCollectionModelV2 collection,
  ) async {
    saveCallCount++;
    if (shouldThrow) throw Exception('Datasource error');
    _store[collection.id] = collection;
    return collection;
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    if (shouldThrow) throw Exception('Datasource error');
    _store.remove(collectionId);
  }
}

void main() {
  late _FakeDatasource localDs;
  late _FakeDatasource remoteDs;
  late AnimationCacheRepositoryV2 repo;

  final now = DateTime(2025, 1, 15, 10, 30);

  AnimationCollectionModelV2 _makeCollection({
    required String id,
    String userId = 'user1',
    String name = 'Test',
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
    String name = 'Anim',
    String userId = 'user1',
    List<SceneModelV2>? scenes,
  }) {
    return AnimationModelV2(
      id: id,
      name: name,
      userId: userId,
      fieldColor: const Color(0xFF9E9E9E),
      animationScenes: scenes ?? [
        SceneModelV2.empty(id: 's1', userId: userId),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    localDs = _FakeDatasource();
    remoteDs = _FakeDatasource();
    repo = AnimationCacheRepositoryV2(
      localDatasource: localDs,
      remoteDatasource: remoteDs,
    );
  });

  group('AnimationCacheRepositoryV2 - getAllCollections', () {
    test('returns local data when available', () async {
      await localDs.saveCollection(_makeCollection(id: 'c1'));

      final result = await repo.getAllCollections('user1');

      expect(result, hasLength(1));
      expect(result.first.id, 'c1');
    });

    test('falls back to remote when local is empty', () async {
      await remoteDs.saveCollection(_makeCollection(id: 'c1'));

      final result = await repo.getAllCollections('user1');

      expect(result, hasLength(1));
      expect(result.first.id, 'c1');
      // Should also cache locally
      expect(localDs.saveCallCount, 1);
    });

    test('returns empty list when both sources are empty', () async {
      final result = await repo.getAllCollections('user1');
      expect(result, isEmpty);
    });

    test('returns empty list on error (graceful fallback)', () async {
      localDs.shouldThrow = true;

      final result = await repo.getAllCollections('user1');
      expect(result, isEmpty);
    });

    test('triggers background refresh when local data exists', () async {
      await localDs.saveCollection(_makeCollection(id: 'c1'));
      // Remote has an updated version
      await remoteDs.saveCollection(
        _makeCollection(id: 'c1', name: 'Updated from Remote'),
      );

      // First call returns local data
      final result = await repo.getAllCollections('user1');
      expect(result.first.name, 'Test');

      // Wait for background refresh to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Local should now have the remote data
      final refreshed = await localDs.getCollection('c1');
      expect(refreshed!.name, 'Updated from Remote');
    });
  });

  group('AnimationCacheRepositoryV2 - saveCollection', () {
    test('saves to local datasource', () async {
      final saved = await repo.saveCollection(
        _makeCollection(id: 'c1', name: 'New'),
      );

      expect(saved.id, 'c1');
      expect(saved.name, 'New');
      expect(saved.hasPendingUpdates, true);

      final local = await localDs.getCollection('c1');
      expect(local, isNotNull);
    });

    test('generates ID when empty', () async {
      final saved = await repo.saveCollection(
        _makeCollection(id: '', name: 'No ID'),
      );

      expect(saved.id, isNotEmpty);
      expect(saved.name, 'No ID');
    });

    test('sets hasPendingUpdates to true', () async {
      final saved = await repo.saveCollection(
        _makeCollection(id: 'c1'),
      );
      expect(saved.hasPendingUpdates, true);
    });
  });

  group('AnimationCacheRepositoryV2 - deleteCollection', () {
    test('removes from local datasource', () async {
      await localDs.saveCollection(_makeCollection(id: 'c1'));

      await repo.deleteCollection('c1');

      final result = await localDs.getCollection('c1');
      expect(result, isNull);
    });

    test('no-op when collection does not exist', () async {
      // Should not throw
      await repo.deleteCollection('nonexistent');
    });
  });

  group('AnimationCacheRepositoryV2 - saveAnimation', () {
    test('adds animation to existing collection', () async {
      await localDs.saveCollection(_makeCollection(id: 'c1'));

      final anim = _makeAnimation(id: 'a1', name: 'New Anim');
      final saved = await repo.saveAnimation(anim, 'c1');

      expect(saved.id, 'a1');
      expect(saved.collectionId, 'c1');

      final collection = await localDs.getCollection('c1');
      expect(collection!.animations, hasLength(1));
      expect(collection.animations.first.id, 'a1');
    });

    test('updates existing animation in collection', () async {
      final anim = _makeAnimation(id: 'a1', name: 'Original');
      await localDs.saveCollection(
        _makeCollection(id: 'c1', animations: [anim]),
      );

      final updated = _makeAnimation(id: 'a1', name: 'Updated');
      final saved = await repo.saveAnimation(updated, 'c1');

      expect(saved.name, 'Updated');

      final collection = await localDs.getCollection('c1');
      expect(collection!.animations, hasLength(1));
      expect(collection.animations.first.name, 'Updated');
    });

    test('generates ID for animation with empty ID', () async {
      await localDs.saveCollection(_makeCollection(id: 'c1'));

      final anim = _makeAnimation(id: '', name: 'No ID');
      final saved = await repo.saveAnimation(anim, 'c1');

      expect(saved.id, isNotEmpty);
    });

    test('throws when collection not found', () async {
      final anim = _makeAnimation(id: 'a1');

      expect(
        () => repo.saveAnimation(anim, 'nonexistent'),
        throwsException,
      );
    });

    test('marks collection as having pending updates', () async {
      await localDs.saveCollection(_makeCollection(id: 'c1'));
      await repo.saveAnimation(_makeAnimation(id: 'a1'), 'c1');

      final collection = await localDs.getCollection('c1');
      expect(collection!.hasPendingUpdates, true);
    });
  });

  group('AnimationCacheRepositoryV2 - deleteAnimation', () {
    test('removes animation from collection', () async {
      final anim = _makeAnimation(id: 'a1');
      await localDs.saveCollection(
        _makeCollection(id: 'c1', animations: [anim]),
      );

      await repo.deleteAnimation('a1', 'c1');

      final collection = await localDs.getCollection('c1');
      expect(collection!.animations, isEmpty);
    });

    test('does not affect other animations', () async {
      final anim1 = _makeAnimation(id: 'a1', name: 'Keep');
      final anim2 = _makeAnimation(id: 'a2', name: 'Delete');
      await localDs.saveCollection(
        _makeCollection(id: 'c1', animations: [anim1, anim2]),
      );

      await repo.deleteAnimation('a2', 'c1');

      final collection = await localDs.getCollection('c1');
      expect(collection!.animations, hasLength(1));
      expect(collection.animations.first.id, 'a1');
    });

    test('no-op when collection not found', () async {
      // Should not throw
      await repo.deleteAnimation('a1', 'nonexistent');
    });
  });

  group('AnimationCacheRepositoryV2 - saveScene', () {
    test('adds scene to animation within collection', () async {
      final anim = _makeAnimation(id: 'a1', scenes: []);
      await localDs.saveCollection(
        _makeCollection(id: 'c1', animations: [anim]),
      );

      final scene = SceneModelV2.empty(id: 'new-scene', userId: 'user1');
      final saved = await repo.saveScene(scene, 'a1', 'c1');

      expect(saved.id, 'new-scene');

      final collection = await localDs.getCollection('c1');
      final updatedAnim = collection!.animations.first;
      expect(updatedAnim.animationScenes, hasLength(1));
      expect(updatedAnim.animationScenes.first.id, 'new-scene');
    });

    test('updates existing scene', () async {
      final scene = SceneModelV2.empty(id: 's1', userId: 'user1');
      final anim = _makeAnimation(id: 'a1', scenes: [scene]);
      await localDs.saveCollection(
        _makeCollection(id: 'c1', animations: [anim]),
      );

      final updated = scene.copyWith(index: 5);
      final saved = await repo.saveScene(updated, 'a1', 'c1');

      expect(saved.index, 5);

      final collection = await localDs.getCollection('c1');
      final updatedAnim = collection!.animations.first;
      expect(updatedAnim.animationScenes, hasLength(1));
      expect(updatedAnim.animationScenes.first.index, 5);
    });

    test('throws when collection not found', () async {
      final scene = SceneModelV2.empty(id: 's1', userId: 'user1');

      expect(
        () => repo.saveScene(scene, 'a1', 'nonexistent'),
        throwsException,
      );
    });

    test('throws when animation not found', () async {
      await localDs.saveCollection(_makeCollection(id: 'c1'));

      final scene = SceneModelV2.empty(id: 's1', userId: 'user1');

      expect(
        () => repo.saveScene(scene, 'nonexistent', 'c1'),
        throwsException,
      );
    });
  });

  group('AnimationCacheRepositoryV2 - deleteScene', () {
    test('removes scene from animation', () async {
      final scene1 = SceneModelV2.empty(id: 's1', userId: 'user1');
      final scene2 = SceneModelV2.empty(
        id: 's2',
        userId: 'user1',
        index: 1,
      );
      final anim = _makeAnimation(
        id: 'a1',
        scenes: [scene1, scene2],
      );
      await localDs.saveCollection(
        _makeCollection(id: 'c1', animations: [anim]),
      );

      await repo.deleteScene('s1', 'a1', 'c1');

      final collection = await localDs.getCollection('c1');
      final updatedAnim = collection!.animations.first;
      expect(updatedAnim.animationScenes, hasLength(1));
      expect(updatedAnim.animationScenes.first.id, 's2');
    });

    test('no-op when collection not found', () async {
      await repo.deleteScene('s1', 'a1', 'nonexistent');
    });

    test('no-op when animation not found', () async {
      await localDs.saveCollection(_makeCollection(id: 'c1'));
      await repo.deleteScene('s1', 'nonexistent', 'c1');
    });
  });
}
