import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/data/repositories/animation_repository_v2.dart';
import 'package:zporter_tactical_board/v2/models/animation_collection.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/presentation/screen/board_shell_v2.dart';
import 'package:zporter_tactical_board/v2/presentation/widgets/panel_toggle_button.dart';
import 'package:zporter_tactical_board/v2/state/animation_notifier.dart';
import 'package:zporter_tactical_board/v2/state/animation_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';
import 'package:zporter_tactical_board/v2/state/collection_provider.dart';

/// Fake repository for testing — no real I/O.
class _FakeRepository implements AnimationRepositoryV2 {
  @override
  Future<List<AnimationCollectionModelV2>> getAllCollections(
      String userId) async => [];
  @override
  Future<AnimationCollectionModelV2> saveCollection(
      AnimationCollectionModelV2 collection) async => collection;
  @override
  Future<void> deleteCollection(String collectionId) async {}
  @override
  Future<AnimationModelV2> saveAnimation(
      AnimationModelV2 animation, String collectionId) async => animation;
  @override
  Future<void> deleteAnimation(
      String animationId, String collectionId) async {}
  @override
  Future<SceneModelV2> saveScene(
      SceneModelV2 scene, String animationId, String collectionId) async =>
      scene;
  @override
  Future<void> deleteScene(
      String sceneId, String animationId, String collectionId) async {}
}

void main() {
  late BoardNotifier boardNotifier;
  late AnimationNotifier animNotifier;

  setUp(() {
    final scene = SceneModelV2.empty(id: 'test', userId: 'u1');
    boardNotifier = BoardNotifier(
      initialState: BoardStateV2(currentScene: scene),
    );
    animNotifier = AnimationNotifier(boardNotifier: boardNotifier);
  });

  Widget _buildShell() {
    return ProviderScope(
      overrides: [
        boardProviderV2.overrideWith((_) => boardNotifier),
        animationProviderV2.overrideWith((_) => animNotifier),
        animationRepositoryV2Provider.overrideWithValue(_FakeRepository()),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: BoardShellV2(userId: 'user1'),
          ),
        ),
      ),
    );
  }

  group('BoardShellV2', () {
    testWidgets('renders two toggle buttons', (tester) async {
      await tester.pumpWidget(_buildShell());
      await tester.pump();

      expect(find.byType(PanelToggleButton), findsNWidgets(2));
    });

    testWidgets('left panel toggle opens/closes left panel', (tester) async {
      await tester.pumpWidget(_buildShell());
      await tester.pump();

      final toggleButtons = find.byType(PanelToggleButton);
      expect(toggleButtons.evaluate().length, 2);

      // Tap left toggle to open
      await tester.tap(toggleButtons.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap again to close
      await tester.tap(toggleButtons.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('right panel toggle opens/closes right panel', (tester) async {
      await tester.pumpWidget(_buildShell());
      await tester.pump();

      final toggleButtons = find.byType(PanelToggleButton);

      // Tap right toggle to open
      await tester.tap(toggleButtons.last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap again to close
      await tester.tap(toggleButtons.last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('uses 25% panel width fraction', (tester) async {
      await tester.pumpWidget(_buildShell());
      await tester.pump();

      final animatedPositioned = tester.widgetList<AnimatedPositioned>(
        find.byType(AnimatedPositioned),
      );

      // Both panels should be 25% of 800 = 200
      final panelWidths = animatedPositioned
          .where((ap) => ap.width != null)
          .map((ap) => ap.width!)
          .toList();

      expect(panelWidths.where((w) => w == 200).length, 2);
    });

    testWidgets('uses AnimatedPositioned for panel sliding', (tester) async {
      await tester.pumpWidget(_buildShell());
      await tester.pump();

      expect(find.byType(AnimatedPositioned), findsAtLeastNWidgets(2));
    });
  });
}
