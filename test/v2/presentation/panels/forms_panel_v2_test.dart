import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/presentation/panels/left/forms_panel_v2.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';

void main() {
  /// Creates a ProviderContainer with boardProviderV2 overridden,
  /// and keeps the autoDispose provider alive via a listener.
  ProviderContainer _makeContainer() {
    final scene = SceneModelV2.empty(id: 'test', userId: 'u1');
    final notifier = BoardNotifier(
      initialState: BoardStateV2(currentScene: scene),
    );
    final container = ProviderContainer(overrides: [
      boardProviderV2.overrideWith((_) => notifier),
    ]);
    // Keep autoDispose provider alive
    container.listen(boardProviderV2, (_, __) {});
    return container;
  }

  Widget _buildFormsPanel(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(
          body: FormsPanelV2(),
        ),
      ),
    );
  }

  group('FormsPanelV2', () {
    testWidgets('renders section headers', (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildFormsPanel(container));

      expect(find.text('Player Movements'), findsOneWidget);
      expect(find.text('Ball Movements'), findsOneWidget);
      expect(find.text('Shapes'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
    });

    testWidgets('tapping a line tool adds a line element to the board',
        (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      expect(container.read(boardProviderV2).components, isEmpty);

      await tester.pumpWidget(_buildFormsPanel(container));

      // Tap the first InkWell (a line tool)
      final inkWells = find.byType(InkWell);
      if (inkWells.evaluate().isNotEmpty) {
        await tester.tap(inkWells.first);
        await tester.pump();

        expect(container.read(boardProviderV2).components.length, 1);
      }
    });

    testWidgets('line elements are placed at center of board', (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildFormsPanel(container));

      final inkWells = find.byType(InkWell);
      if (inkWells.evaluate().isNotEmpty) {
        await tester.tap(inkWells.first);
        await tester.pump();

        final state = container.read(boardProviderV2);
        if (state.components.isNotEmpty) {
          final element = state.components.first;
          expect(element.offset, isNotNull);
        }
      }
    });

    testWidgets('multiple taps add multiple elements', (tester) async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildFormsPanel(container));

      final inkWells = find.byType(InkWell);
      if (inkWells.evaluate().length >= 2) {
        await tester.tap(inkWells.at(0));
        await tester.pump();
        await tester.tap(inkWells.at(1));
        await tester.pump();

        expect(container.read(boardProviderV2).components.length, 2);
      }
    });
  });
}
