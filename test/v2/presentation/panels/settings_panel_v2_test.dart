import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/presentation/panels/right/settings_panel_v2.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';

void main() {
  BoardNotifier _makeNotifier() {
    final scene = SceneModelV2.empty(id: 'test', userId: 'u1');
    return BoardNotifier(
      initialState: BoardStateV2(currentScene: scene),
    );
  }

  Widget _buildSettingsPanel(BoardNotifier notifier) {
    return ProviderScope(
      overrides: [
        boardProviderV2.overrideWith((_) => notifier),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SettingsPanelV2(),
        ),
      ),
    );
  }

  group('SettingsPanelV2', () {
    testWidgets('renders all sections', (tester) async {
      final notifier = _makeNotifier();
      await tester.pumpWidget(_buildSettingsPanel(notifier));

      expect(find.text('Field Color'), findsOneWidget);
      expect(find.text('Home Team Border'), findsOneWidget);
      expect(find.text('Away Team Border'), findsOneWidget);
      expect(find.text('Background'), findsOneWidget);
      expect(find.textContaining('Grid Size'), findsOneWidget);
      expect(find.text('Rotate Field'), findsOneWidget);
    });

    testWidgets('shows background options as ChoiceChips', (tester) async {
      final notifier = _makeNotifier();
      await tester.pumpWidget(_buildSettingsPanel(notifier));

      expect(find.text('Full'), findsOneWidget);
      expect(find.text('Half Up'), findsOneWidget);
      expect(find.text('Half Down'), findsOneWidget);
      expect(find.text('Corridors'), findsOneWidget);
      expect(find.text('Clean'), findsOneWidget);
    });

    testWidgets('grid size slider has correct range', (tester) async {
      final notifier = _makeNotifier();
      await tester.pumpWidget(_buildSettingsPanel(notifier));

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, 0);
      expect(slider.max, 50);
      expect(slider.divisions, 10);
    });

    testWidgets('grid size label shows current value', (tester) async {
      final notifier = _makeNotifier();
      await tester.pumpWidget(_buildSettingsPanel(notifier));

      expect(find.text('Grid Size: 50'), findsOneWidget);
    });

    testWidgets('changing background updates board state', (tester) async {
      final notifier = _makeNotifier();
      await tester.pumpWidget(_buildSettingsPanel(notifier));

      expect(notifier.state.boardBackground, BoardBackground.full);

      await tester.tap(find.text('Clean'));
      await tester.pump();

      expect(notifier.state.boardBackground, BoardBackground.clean);
    });

    testWidgets('rotate field button triggers rotation', (tester) async {
      final notifier = _makeNotifier();
      await tester.pumpWidget(_buildSettingsPanel(notifier));

      expect(notifier.state.boardAngle, 0);

      await tester.tap(find.text('Rotate Field'));
      await tester.pump();

      expect(notifier.state.boardAngle, 1);
    });
  });
}
