import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/presentation/widgets/draggable_board_tile_v2.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';

void main() {
  PlayerElement _makePlayer({String id = 'p1'}) {
    return PlayerElement(
      id: id,
      role: 'GK',
      jerseyNumber: 1,
      playerType: PlayerType.HOME,
      name: 'Player 1',
      imagePath: 'player.png',
      size: const Size(32, 32),
    );
  }

  Widget _buildTestWidget(BoardNotifier notifier, PlayerElement element) {
    return ProviderScope(
      overrides: [
        boardProviderV2.overrideWith((_) => notifier),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: DraggableBoardTileV2(
              element: element,
              child: Container(
                width: 50,
                height: 50,
                color: Colors.blue,
                child: const Text('Tile'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('DraggableBoardTileV2', () {
    testWidgets('renders child widget', (tester) async {
      final scene = SceneModelV2.empty(id: 'test', userId: 'user1');
      final notifier = BoardNotifier(
        initialState: BoardStateV2(currentScene: scene),
      );
      final player = _makePlayer();
      await tester.pumpWidget(_buildTestWidget(notifier, player));

      expect(find.text('Tile'), findsOneWidget);
    });

    testWidgets('wraps child in Draggable<BoardElement>', (tester) async {
      final scene = SceneModelV2.empty(id: 'test', userId: 'user1');
      final notifier = BoardNotifier(
        initialState: BoardStateV2(currentScene: scene),
      );
      final player = _makePlayer();
      await tester.pumpWidget(_buildTestWidget(notifier, player));

      // Generic types require predicate-based matching
      expect(
        find.byWidgetPredicate((w) => w is Draggable<BoardElement>),
        findsOneWidget,
      );
    });

    testWidgets('feedback widget has default 40px size', (tester) async {
      final scene = SceneModelV2.empty(id: 'test', userId: 'user1');
      final notifier = BoardNotifier(
        initialState: BoardStateV2(currentScene: scene),
      );
      final player = _makePlayer();
      await tester.pumpWidget(_buildTestWidget(notifier, player));

      // Verify the widget is a Draggable with default feedbackSize
      final draggable = tester.widget<DraggableBoardTileV2>(
        find.byType(DraggableBoardTileV2),
      );
      expect(draggable.feedbackSize, 40);
    });

    testWidgets('custom feedbackSize is respected', (tester) async {
      final scene = SceneModelV2.empty(id: 'test', userId: 'user1');
      final notifier = BoardNotifier(
        initialState: BoardStateV2(currentScene: scene),
      );
      final player = _makePlayer();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            boardProviderV2.overrideWith((_) => notifier),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: DraggableBoardTileV2(
                  element: player,
                  feedbackSize: 60,
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.blue,
                    child: const Text('Tile'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final draggable = tester.widget<DraggableBoardTileV2>(
        find.byType(DraggableBoardTileV2),
      );
      expect(draggable.feedbackSize, 60);
    });

    testWidgets('carries BoardElement as drag data', (tester) async {
      final scene = SceneModelV2.empty(id: 'test', userId: 'user1');
      final notifier = BoardNotifier(
        initialState: BoardStateV2(currentScene: scene),
      );
      final player = _makePlayer();
      await tester.pumpWidget(_buildTestWidget(notifier, player));

      final draggable = tester.widget<Draggable<BoardElement>>(
        find.byWidgetPredicate((w) => w is Draggable<BoardElement>),
      );
      expect(draggable.data, equals(player));
    });
  });
}
