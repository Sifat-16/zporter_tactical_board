import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/data/repositories/animation_repository_v2.dart';
import 'package:zporter_tactical_board/v2/models/animation_collection.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';
import 'package:zporter_tactical_board/v2/state/collection_notifier.dart';

/// Fake repository for testing the CollectionNotifier.
class _FakeRepository implements AnimationRepositoryV2 {
  final Map<String, AnimationCollectionModelV2> _store = {};
  bool shouldThrow = false;

  void seed(AnimationCollectionModelV2 collection) {
    _store[collection.id] = collection;
  }

  @override
  Future<List<AnimationCollectionModelV2>> getAllCollections(
    String userId,
  ) async {
    if (shouldThrow) throw Exception('Repository error');
    return _store.values.where((c) => c.userId == userId).toList();
  }

  @override
  Future<AnimationCollectionModelV2> saveCollection(
    AnimationCollectionModelV2 collection,
  ) async {
    if (shouldThrow) throw Exception('Repository error');
    _store[collection.id] = collection;
    return collection;
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    if (shouldThrow) throw Exception('Repository error');
    _store.remove(collectionId);
  }

  @override
  Future<AnimationModelV2> saveAnimation(
    AnimationModelV2 animation,
    String collectionId,
  ) async {
    if (shouldThrow) throw Exception('Repository error');
    final collection = _store[collectionId];
    if (collection == null) throw Exception('Not found');

    final animations = List<AnimationModelV2>.of(collection.animations);
    final idx = animations.indexWhere((a) => a.id == animation.id);
    if (idx >= 0) {
      animations[idx] = animation;
    } else {
      animations.add(animation);
    }
    _store[collectionId] = collection.copyWith(animations: animations);
    return animation;
  }

  @override
  Future<void> deleteAnimation(
    String animationId,
    String collectionId,
  ) async {
    if (shouldThrow) throw Exception('Repository error');
    final collection = _store[collectionId];
    if (collection == null) return;

    final animations =
        collection.animations.where((a) => a.id != animationId).toList();
    _store[collectionId] = collection.copyWith(animations: animations);
  }

  @override
  Future<SceneModelV2> saveScene(
    SceneModelV2 scene,
    String animationId,
    String collectionId,
  ) async {
    if (shouldThrow) throw Exception('Repository error');
    return scene;
  }

  @override
  Future<void> deleteScene(
    String sceneId,
    String animationId,
    String collectionId,
  ) async {
    if (shouldThrow) throw Exception('Repository error');
  }
}

void main() {
  late _FakeRepository repo;
  late BoardNotifier boardNotifier;
  late CollectionNotifier notifier;

  final now = DateTime(2025, 1, 15);

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
      animationScenes: scenes ??
          [
            SceneModelV2.empty(id: 's1', userId: userId),
            SceneModelV2.empty(id: 's2', userId: userId, index: 1),
          ],
      createdAt: now,
      updatedAt: now,
    );
  }

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

  setUp(() {
    repo = _FakeRepository();
    boardNotifier = BoardNotifier(
      initialState: BoardStateV2(
        currentScene: SceneModelV2.empty(id: 'board', userId: 'user1'),
      ),
    );
    notifier = CollectionNotifier(
      repository: repo,
      boardNotifier: boardNotifier,
    );
  });

  tearDown(() {
    notifier.dispose();
    boardNotifier.dispose();
  });

  group('CollectionNotifier - initial state', () {
    test('starts with empty state', () {
      expect(notifier.state.collections, isEmpty);
      expect(notifier.state.selectedCollection, isNull);
      expect(notifier.state.selectedAnimation, isNull);
      expect(notifier.state.selectedSceneIndex, 0);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });
  });

  group('CollectionNotifier - loadCollections', () {
    test('loads collections from repository', () async {
      repo.seed(_makeCollection(id: 'c1', name: 'First'));
      repo.seed(_makeCollection(id: 'c2', name: 'Second'));

      await notifier.loadCollections('user1');

      expect(notifier.state.collections, hasLength(2));
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });

    test('sets isLoading during load', () async {
      bool wasLoading = false;
      notifier.addListener((state) {
        if (state.isLoading) wasLoading = true;
      });

      await notifier.loadCollections('user1');
      expect(wasLoading, true);
      expect(notifier.state.isLoading, false);
    });

    test('sorts by orderIndex', () async {
      repo.seed(_makeCollection(id: 'c1').copyWith(orderIndex: 2));
      repo.seed(_makeCollection(id: 'c2').copyWith(orderIndex: 0));
      repo.seed(_makeCollection(id: 'c3').copyWith(orderIndex: 1));

      await notifier.loadCollections('user1');

      expect(notifier.state.collections[0].id, 'c2');
      expect(notifier.state.collections[1].id, 'c3');
      expect(notifier.state.collections[2].id, 'c1');
    });

    test('sets error on failure', () async {
      repo.shouldThrow = true;

      await notifier.loadCollections('user1');

      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNotNull);
    });

    test('filters by userId', () async {
      repo.seed(_makeCollection(id: 'c1', userId: 'user1'));
      repo.seed(_makeCollection(id: 'c2', userId: 'user2'));

      await notifier.loadCollections('user1');

      expect(notifier.state.collections, hasLength(1));
      expect(notifier.state.collections.first.id, 'c1');
    });
  });

  group('CollectionNotifier - selection', () {
    test('selectCollection updates state', () {
      final collection = _makeCollection(id: 'c1');
      notifier.selectCollection(collection);

      expect(notifier.state.selectedCollection?.id, 'c1');
      expect(notifier.state.selectedAnimation, isNull);
      expect(notifier.state.selectedSceneIndex, 0);
    });

    test('selectCollection clears animation selection', () {
      notifier.selectCollection(_makeCollection(
        id: 'c1',
        animations: [_makeAnimation(id: 'a1')],
      ));
      notifier.selectAnimation(_makeAnimation(id: 'a1'));

      // Now select a different collection
      notifier.selectCollection(_makeCollection(id: 'c2'));

      expect(notifier.state.selectedAnimation, isNull);
    });

    test('selectAnimation updates state', () {
      final anim = _makeAnimation(id: 'a1');
      notifier.selectAnimation(anim);

      expect(notifier.state.selectedAnimation?.id, 'a1');
      expect(notifier.state.selectedSceneIndex, 0);
    });

    test('selectAnimation pushes first scene to board', () {
      final anim = _makeAnimation(id: 'a1');
      notifier.selectAnimation(anim);

      expect(boardNotifier.state.currentScene.id, 's1');
    });

    test('selectScene updates index and pushes to board', () {
      notifier.selectAnimation(_makeAnimation(id: 'a1'));
      notifier.selectScene(1);

      expect(notifier.state.selectedSceneIndex, 1);
      expect(boardNotifier.state.currentScene.id, 's2');
    });

    test('selectScene ignores invalid index', () {
      notifier.selectAnimation(_makeAnimation(id: 'a1'));
      notifier.selectScene(99);

      expect(notifier.state.selectedSceneIndex, 0);
    });

    test('selectScene no-op without animation', () {
      notifier.selectScene(0);
      expect(notifier.state.selectedSceneIndex, 0);
    });

    test('selectedScene returns correct scene', () {
      notifier.selectAnimation(_makeAnimation(id: 'a1'));
      notifier.selectScene(1);

      expect(notifier.state.selectedScene?.id, 's2');
    });

    test('selectedScene returns null without animation', () {
      expect(notifier.state.selectedScene, isNull);
    });
  });

  group('CollectionNotifier - createCollection', () {
    test('creates and adds collection', () async {
      await notifier.createCollection('New Collection', 'user1');

      expect(notifier.state.collections, hasLength(1));
      expect(notifier.state.collections.first.name, 'New Collection');
      expect(notifier.state.collections.first.userId, 'user1');
    });

    test('sets error on failure', () async {
      repo.shouldThrow = true;
      await notifier.createCollection('New', 'user1');

      expect(notifier.state.error, isNotNull);
    });
  });

  group('CollectionNotifier - deleteCollection', () {
    test('removes collection from state', () async {
      repo.seed(_makeCollection(id: 'c1'));
      await notifier.loadCollections('user1');

      await notifier.deleteCollection('c1');

      expect(notifier.state.collections, isEmpty);
    });

    test('clears selection when deleting selected collection', () async {
      repo.seed(_makeCollection(
        id: 'c1',
        animations: [_makeAnimation(id: 'a1')],
      ));
      await notifier.loadCollections('user1');
      notifier.selectCollection(notifier.state.collections.first);
      notifier.selectAnimation(
        notifier.state.selectedCollection!.animations.first,
      );

      await notifier.deleteCollection('c1');

      expect(notifier.state.selectedCollection, isNull);
      expect(notifier.state.selectedAnimation, isNull);
    });

    test('does not clear selection of a different collection', () async {
      repo.seed(_makeCollection(id: 'c1'));
      repo.seed(_makeCollection(id: 'c2'));
      await notifier.loadCollections('user1');
      notifier.selectCollection(notifier.state.collections.first);

      await notifier.deleteCollection('c2');

      expect(notifier.state.selectedCollection?.id, 'c1');
    });
  });

  group('CollectionNotifier - createAnimation', () {
    test('creates animation in selected collection', () async {
      repo.seed(_makeCollection(id: 'c1'));
      await notifier.loadCollections('user1');
      notifier.selectCollection(notifier.state.collections.first);

      await notifier.createAnimation('New Anim', 'user1');

      final collection = notifier.state.collections.first;
      expect(collection.animations, hasLength(1));
      expect(collection.animations.first.name, 'New Anim');
    });

    test('no-op without selected collection', () async {
      await notifier.createAnimation('Anim', 'user1');
      expect(notifier.state.collections, isEmpty);
    });

    test('creates animation with one default scene', () async {
      repo.seed(_makeCollection(id: 'c1'));
      await notifier.loadCollections('user1');
      notifier.selectCollection(notifier.state.collections.first);

      await notifier.createAnimation('Anim', 'user1');

      final anim = notifier.state.collections.first.animations.first;
      expect(anim.animationScenes, hasLength(1));
    });
  });

  group('CollectionNotifier - deleteAnimation', () {
    test('removes animation from collection', () async {
      repo.seed(_makeCollection(
        id: 'c1',
        animations: [
          _makeAnimation(id: 'a1'),
          _makeAnimation(id: 'a2'),
        ],
      ));
      await notifier.loadCollections('user1');
      notifier.selectCollection(notifier.state.collections.first);

      await notifier.deleteAnimation('a1');

      final collection = notifier.state.collections.first;
      expect(collection.animations, hasLength(1));
      expect(collection.animations.first.id, 'a2');
    });

    test('clears selection when deleting selected animation', () async {
      repo.seed(_makeCollection(
        id: 'c1',
        animations: [_makeAnimation(id: 'a1')],
      ));
      await notifier.loadCollections('user1');
      notifier.selectCollection(notifier.state.collections.first);
      notifier.selectAnimation(
        notifier.state.selectedCollection!.animations.first,
      );

      await notifier.deleteAnimation('a1');

      expect(notifier.state.selectedAnimation, isNull);
    });
  });

  group('CollectionNotifier - saveCurrentScene', () {
    test('saves scene through repository', () async {
      final anim = _makeAnimation(id: 'a1');
      repo.seed(_makeCollection(id: 'c1', animations: [anim]));
      await notifier.loadCollections('user1');
      notifier.selectCollection(notifier.state.collections.first);
      notifier.selectAnimation(
        notifier.state.selectedCollection!.animations.first,
      );

      final updatedScene = SceneModelV2.empty(
        id: 's1',
        userId: 'user1',
      ).copyWith(index: 99);

      await notifier.saveCurrentScene(updatedScene);

      // State should reflect the update
      final stateAnim = notifier.state.selectedAnimation!;
      expect(stateAnim.animationScenes.first.index, 99);
    });

    test('no-op without selection', () async {
      final scene = SceneModelV2.empty(id: 's1', userId: 'user1');
      // Should not throw
      await notifier.saveCurrentScene(scene);
    });
  });

  group('CollectionNotifier - addScene', () {
    test('adds scene to current animation', () async {
      final anim = _makeAnimation(id: 'a1', scenes: [
        SceneModelV2.empty(id: 's1', userId: 'user1'),
      ]);
      repo.seed(_makeCollection(id: 'c1', animations: [anim]));
      await notifier.loadCollections('user1');
      notifier.selectCollection(notifier.state.collections.first);
      notifier.selectAnimation(
        notifier.state.selectedCollection!.animations.first,
      );

      final newScene = SceneModelV2.empty(
        id: 's-new',
        userId: 'user1',
        index: 1,
      );
      await notifier.addScene(newScene);

      final stateAnim = notifier.state.selectedAnimation!;
      expect(stateAnim.animationScenes, hasLength(2));
    });
  });

  group('CollectionNotifier - deleteScene', () {
    test('removes scene from current animation', () async {
      final anim = _makeAnimation(id: 'a1');
      repo.seed(_makeCollection(id: 'c1', animations: [anim]));
      await notifier.loadCollections('user1');
      notifier.selectCollection(notifier.state.collections.first);
      notifier.selectAnimation(
        notifier.state.selectedCollection!.animations.first,
      );

      await notifier.deleteScene('s1');

      final stateAnim = notifier.state.selectedAnimation!;
      expect(stateAnim.animationScenes, hasLength(1));
      expect(stateAnim.animationScenes.first.id, 's2');
    });
  });

  group('CollectionState', () {
    test('equality works', () {
      const s1 = CollectionState();
      const s2 = CollectionState();
      expect(s1, equals(s2));
    });

    test('copyWith preserves values', () {
      const original = CollectionState(isLoading: true);
      final copy = original.copyWith();
      expect(copy.isLoading, true);
    });

    test('copyWith with null values uses sentinel', () {
      final state = CollectionState(
        selectedCollection: _makeCollection(id: 'c1'),
      );
      final cleared = state.copyWith(selectedCollection: null);
      expect(cleared.selectedCollection, isNull);
    });
  });
}
