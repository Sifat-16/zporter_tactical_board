import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/presentation/panels/right/design_panel_v2.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';

void main() {
  PlayerElement _makePlayer({
    String id = 'p1',
    double opacity = 1.0,
    bool canBeCopied = true,
  }) {
    return PlayerElement(
      id: id,
      role: 'GK',
      jerseyNumber: 1,
      playerType: PlayerType.HOME,
      name: 'Player 1',
      imagePath: 'player.png',
      size: const Size(32, 32),
      opacity: opacity,
      canBeCopied: canBeCopied,
      offset: const Offset(0.5, 0.5),
    );
  }

  Widget _buildDesignPanel(BoardNotifier notifier) {
    return ProviderScope(
      overrides: [
        boardProviderV2.overrideWith((_) => notifier),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: DesignPanelV2(),
        ),
      ),
    );
  }

  group('DesignPanelV2', () {
    group('empty state', () {
      testWidgets('shows placeholder text when no element selected',
          (tester) async {
        final scene = SceneModelV2.empty(id: 'test', userId: 'u1');
        final notifier = BoardNotifier(
          initialState: BoardStateV2(currentScene: scene),
        );

        await tester.pumpWidget(_buildDesignPanel(notifier));

        expect(find.text('Tap and mark what to redesign'), findsOneWidget);
      });

      testWidgets('shows "Element not found" when selected ID has no match',
          (tester) async {
        final scene = SceneModelV2.empty(id: 'test', userId: 'u1');
        final notifier = BoardNotifier(
          initialState: BoardStateV2(
            currentScene: scene,
            selectedElementId: 'nonexistent',
          ),
        );

        await tester.pumpWidget(_buildDesignPanel(notifier));

        expect(find.text('Element not found'), findsOneWidget);
      });
    });

    group('with selected element', () {
      testWidgets('shows action buttons', (tester) async {
        final player = _makePlayer();
        final scene = SceneModelV2.empty(id: 'test', userId: 'u1').copyWith(
          components: [player],
        );
        final notifier = BoardNotifier(
          initialState: BoardStateV2(
            currentScene: scene,
            selectedElementId: 'p1',
          ),
        );

        await tester.pumpWidget(_buildDesignPanel(notifier));

        expect(find.text('Copy'), findsOneWidget);
        expect(find.text('Front'), findsOneWidget);
        expect(find.text('Back'), findsOneWidget);
        expect(find.text('Up'), findsOneWidget);
        expect(find.text('Down'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('shows opacity slider', (tester) async {
        final player = _makePlayer();
        final scene = SceneModelV2.empty(id: 'test', userId: 'u1').copyWith(
          components: [player],
        );
        final notifier = BoardNotifier(
          initialState: BoardStateV2(
            currentScene: scene,
            selectedElementId: 'p1',
          ),
        );

        await tester.pumpWidget(_buildDesignPanel(notifier));

        expect(find.text('Opacity'), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
      });

      testWidgets('shows color picker with 10 colors', (tester) async {
        final player = _makePlayer();
        final scene = SceneModelV2.empty(id: 'test', userId: 'u1').copyWith(
          components: [player],
        );
        final notifier = BoardNotifier(
          initialState: BoardStateV2(
            currentScene: scene,
            selectedElementId: 'p1',
          ),
        );

        await tester.pumpWidget(_buildDesignPanel(notifier));

        expect(find.text('Color'), findsOneWidget);
      });

      testWidgets('shows player-specific toggles for PlayerElement',
          (tester) async {
        final player = _makePlayer();
        final scene = SceneModelV2.empty(id: 'test', userId: 'u1').copyWith(
          components: [player],
        );
        final notifier = BoardNotifier(
          initialState: BoardStateV2(
            currentScene: scene,
            selectedElementId: 'p1',
          ),
        );

        await tester.pumpWidget(_buildDesignPanel(notifier));

        expect(find.text('Display Options'), findsOneWidget);
        expect(find.text('Show Image'), findsOneWidget);
        expect(find.text('Show Number'), findsOneWidget);
        expect(find.text('Show Name'), findsOneWidget);
        expect(find.text('Show Role'), findsOneWidget);
      });

      testWidgets('delete button removes element from board', (tester) async {
        final player = _makePlayer();
        final scene = SceneModelV2.empty(id: 'test', userId: 'u1').copyWith(
          components: [player],
        );
        final notifier = BoardNotifier(
          initialState: BoardStateV2(
            currentScene: scene,
            selectedElementId: 'p1',
          ),
        );

        await tester.pumpWidget(_buildDesignPanel(notifier));

        expect(notifier.state.components.length, 1);

        await tester.tap(find.text('Delete'));
        await tester.pump();

        expect(notifier.state.components.length, 0);
      });

      testWidgets('copy button duplicates element', (tester) async {
        final player = _makePlayer();
        final scene = SceneModelV2.empty(id: 'test', userId: 'u1').copyWith(
          components: [player],
        );
        final notifier = BoardNotifier(
          initialState: BoardStateV2(
            currentScene: scene,
            selectedElementId: 'p1',
          ),
        );

        await tester.pumpWidget(_buildDesignPanel(notifier));

        expect(notifier.state.components.length, 1);

        await tester.tap(find.text('Copy'));
        await tester.pump();

        expect(notifier.state.components.length, 2);
      });
    });
  });
}
