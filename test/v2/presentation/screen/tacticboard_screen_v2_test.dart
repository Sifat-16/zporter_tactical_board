import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/data/repositories/animation_repository_v2.dart';
import 'package:zporter_tactical_board/v2/models/animation_collection.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/presentation/screen/board_shell_v2.dart';
import 'package:zporter_tactical_board/v2/presentation/screen/tacticboard_screen_v2.dart';
import 'package:zporter_tactical_board/v2/state/animation_notifier.dart';
import 'package:zporter_tactical_board/v2/state/animation_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';
import 'package:zporter_tactical_board/v2/state/collection_provider.dart';

/// Fake repository that returns empty collections by default.
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
  late _FakeRepository fakeRepo;

  setUp(() {
    fakeRepo = _FakeRepository();
  });

  /// Creates a ProviderContainer with all V2 providers overridden,
  /// and keeps autoDispose providers alive via listeners.
  ProviderContainer _makeContainer() {
    final scene = SceneModelV2.empty(id: 'test', userId: 'user1');
    final boardNotifier = BoardNotifier(
      initialState: BoardStateV2(currentScene: scene),
    );
    final animNotifier = AnimationNotifier(boardNotifier: boardNotifier);

    final container = ProviderContainer(overrides: [
      boardProviderV2.overrideWith((_) => boardNotifier),
      animationProviderV2.overrideWith((_) => animNotifier),
      animationRepositoryV2Provider.overrideWithValue(fakeRepo),
    ]);

    // Keep autoDispose providers alive for the test duration
    container.listen(boardProviderV2, (_, __) {});
    container.listen(animationProviderV2, (_, __) {});
    container.listen(collectionProviderV2, (_, __) {});

    return container;
  }

  Widget _buildScreen(
    ProviderContainer container, {
    String? collectionId,
    String? animationId,
    bool isPlayerMode = false,
    ValueChanged<bool>? onFullScreenChanged,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: TacticboardScreenV2(
              userId: 'user1',
              collectionId: collectionId,
              animationId: animationId,
              isPlayerMode: isPlayerMode,
              onFullScreenChanged: onFullScreenChanged,
            ),
          ),
        ),
      ),
    );
  }

  group('TacticboardScreenV2', () {
    testWidgets('shows loading indicator during initialization',
        (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildScreen(container));

      // Before first pump, TacticboardScreenV2 shows its own loading indicator
      // (BoardShellV2 is not yet rendered, so no PlayersPanelV2 CPI exists)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(BoardShellV2), findsNothing);
    });

    testWidgets('loads and renders board after initialization',
        (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildScreen(container));
      // _initialize() completes within pumpWidget; one pump triggers the rebuild
      await tester.pump();

      // BoardShellV2 is rendered — screen is initialized
      expect(find.byType(BoardShellV2), findsOneWidget);
    });

    testWidgets('fires onFullScreenChanged when board fullscreen toggles',
        (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      bool? fullscreenValue;

      await tester.pumpWidget(_buildScreen(
        container,
        onFullScreenChanged: (val) => fullscreenValue = val,
      ));
      // ref.listen is registered on first build; no pump needed before setFullScreen
      await tester.pump(); // process the initialization rebuild

      // Toggle fullscreen via the board notifier
      container.read(boardProviderV2.notifier).setFullScreen(true);
      await tester.pump();

      expect(fullscreenValue, isTrue);
    });

    testWidgets('deep-links to collection when collectionId is provided',
        (tester) async {
      final now = DateTime.now();
      final collection = AnimationCollectionModelV2(
        id: 'deep-col',
        name: 'Deep Link Collection',
        userId: 'user1',
        animations: [],
        createdAt: now,
        updatedAt: now,
        orderIndex: 0,
      );
      fakeRepo.seed(collection);

      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
          _buildScreen(container, collectionId: 'deep-col'));
      await tester.pump();

      // Screen initialized successfully — no crash on deep-link
      expect(find.byType(BoardShellV2), findsOneWidget);
    });

    testWidgets('renders in player mode', (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
          _buildScreen(container, isPlayerMode: true));
      await tester.pump();

      expect(find.byType(BoardShellV2), findsOneWidget);
    });
  });
}
