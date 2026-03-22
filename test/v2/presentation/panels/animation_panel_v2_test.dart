import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/data/repositories/animation_repository_v2.dart';
import 'package:zporter_tactical_board/v2/models/animation_collection.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/presentation/panels/right/animation_panel_v2.dart';
import 'package:zporter_tactical_board/v2/state/animation_notifier.dart';
import 'package:zporter_tactical_board/v2/state/animation_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';
import 'package:zporter_tactical_board/v2/state/collection_notifier.dart';
import 'package:zporter_tactical_board/v2/state/collection_provider.dart';

/// Fake repository for testing — no real I/O.
class _FakeRepository implements AnimationRepositoryV2 {
  final Map<String, AnimationCollectionModelV2> _store = {};

  void seed(AnimationCollectionModelV2 collection) {
    _store[collection.id] = collection;
  }

  @override
  Future<List<AnimationCollectionModelV2>> getAllCollections(
      String userId) async {
    return _store.values.where((c) => c.userId == userId).toList();
  }

  @override
  Future<AnimationCollectionModelV2> saveCollection(
      AnimationCollectionModelV2 collection) async {
    _store[collection.id] = collection;
    return collection;
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    _store.remove(collectionId);
  }

  @override
  Future<AnimationModelV2> saveAnimation(
      AnimationModelV2 animation, String collectionId) async {
    return animation;
  }

  @override
  Future<void> deleteAnimation(
      String animationId, String collectionId) async {}

  @override
  Future<SceneModelV2> saveScene(
      SceneModelV2 scene, String animationId, String collectionId) async {
    return scene;
  }

  @override
  Future<void> deleteScene(
      String sceneId, String animationId, String collectionId) async {}
}

void main() {
  late BoardNotifier boardNotifier;
  late _FakeRepository fakeRepo;
  late SceneModelV2 testScene;

  AnimationCollectionModelV2 _makeCollection({
    String id = 'col1',
    String name = 'Test Collection',
    List<AnimationModelV2>? animations,
  }) {
    final now = DateTime.now();
    return AnimationCollectionModelV2(
      id: id,
      name: name,
      userId: 'user1',
      animations: animations ?? [],
      createdAt: now,
      updatedAt: now,
      orderIndex: 0,
    );
  }

  AnimationModelV2 _makeAnimation({
    String id = 'anim1',
    String name = 'Test Animation',
    List<SceneModelV2>? scenes,
  }) {
    final now = DateTime.now();
    return AnimationModelV2(
      id: id,
      name: name,
      userId: 'user1',
      collectionId: 'col1',
      fieldColor: const Color(0xFF9E9E9E),
      animationScenes: scenes ?? [SceneModelV2.empty(id: 's1', userId: 'user1')],
      createdAt: now,
      updatedAt: now,
      orderIndex: 0,
    );
  }

  setUp(() {
    testScene = SceneModelV2.empty(id: 'test', userId: 'user1');
    boardNotifier = BoardNotifier(
      initialState: BoardStateV2(currentScene: testScene),
    );
    fakeRepo = _FakeRepository();
  });

  Widget _buildAnimationPanel({
    CollectionNotifier? collNotifier,
  }) {
    final cn = collNotifier ??
        CollectionNotifier(
          repository: fakeRepo,
          boardNotifier: boardNotifier,
        );
    final animNotifier = AnimationNotifier(boardNotifier: boardNotifier);
    return ProviderScope(
      overrides: [
        boardProviderV2.overrideWith((_) => boardNotifier),
        animationProviderV2.overrideWith((_) => animNotifier),
        animationRepositoryV2Provider.overrideWithValue(fakeRepo),
        collectionProviderV2.overrideWith((_) => cn),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: AnimationPanelV2(userId: 'user1'),
        ),
      ),
    );
  }

  group('AnimationPanelV2', () {
    testWidgets('shows collection dropdown', (tester) async {
      await tester.pumpWidget(_buildAnimationPanel());

      expect(find.text('Collection'), findsOneWidget);
      expect(find.text('Select Collection'), findsOneWidget);
    });

    testWidgets('shows add button for collections', (tester) async {
      await tester.pumpWidget(_buildAnimationPanel());

      // At least one add icon (for collection)
      expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
    });

    testWidgets('shows playback controls', (tester) async {
      await tester.pumpWidget(_buildAnimationPanel());

      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('selecting collection reveals animation dropdown',
        (tester) async {
      final anim = _makeAnimation();
      final collection = _makeCollection(animations: [anim]);
      fakeRepo.seed(collection);

      final cn = CollectionNotifier(
        repository: fakeRepo,
        boardNotifier: boardNotifier,
      );
      await cn.loadCollections('user1');
      cn.selectCollection(collection);

      await tester.pumpWidget(_buildAnimationPanel(collNotifier: cn));
      await tester.pump();

      expect(find.text('Animation'), findsOneWidget);
    });

    testWidgets('selecting animation reveals scene list and save button',
        (tester) async {
      final scene = SceneModelV2.empty(id: 's1', userId: 'user1');
      final anim = _makeAnimation(scenes: [scene]);
      final collection = _makeCollection(animations: [anim]);
      fakeRepo.seed(collection);

      final cn = CollectionNotifier(
        repository: fakeRepo,
        boardNotifier: boardNotifier,
      );
      await cn.loadCollections('user1');
      cn.selectCollection(collection);
      cn.selectAnimation(anim);

      await tester.pumpWidget(_buildAnimationPanel(collNotifier: cn));
      await tester.pump();

      expect(find.text('Scenes'), findsOneWidget);
      expect(find.text('Scene 1'), findsOneWidget);
      expect(find.text('Save Scene'), findsOneWidget);
    });
  });
}
