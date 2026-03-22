import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/presentation/widgets/panel_toggle_button.dart';

void main() {
  group('PanelToggleButton', () {
    group('left side', () {
      testWidgets('shows chevron_right when closed', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PanelToggleButton(
                isOpen: false,
                onToggle: () {},
                side: PanelSide.left,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.byIcon(Icons.chevron_left), findsNothing);
      });

      testWidgets('shows chevron_left when open', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PanelToggleButton(
                isOpen: true,
                onToggle: () {},
                side: PanelSide.left,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsNothing);
      });
    });

    group('right side', () {
      testWidgets('shows chevron_left when closed', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PanelToggleButton(
                isOpen: false,
                onToggle: () {},
                side: PanelSide.right,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsNothing);
      });

      testWidgets('shows chevron_right when open', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PanelToggleButton(
                isOpen: true,
                onToggle: () {},
                side: PanelSide.right,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.byIcon(Icons.chevron_left), findsNothing);
      });
    });

    testWidgets('fires onToggle callback on tap', (tester) async {
      var toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PanelToggleButton(
              isOpen: false,
              onToggle: () => toggled = true,
              side: PanelSide.left,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PanelToggleButton));
      expect(toggled, isTrue);
    });

    testWidgets('has semi-transparent background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PanelToggleButton(
              isOpen: false,
              onToggle: () {},
              side: PanelSide.left,
            ),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(PanelToggleButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, Colors.black54);
    });

    testWidgets('left side has right-side border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PanelToggleButton(
              isOpen: false,
              onToggle: () {},
              side: PanelSide.left,
            ),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(PanelToggleButton),
          matching: find.byType(Material),
        ),
      );
      expect(
        material.borderRadius,
        const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      );
    });

    testWidgets('right side has left-side border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PanelToggleButton(
              isOpen: false,
              onToggle: () {},
              side: PanelSide.right,
            ),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(PanelToggleButton),
          matching: find.byType(Material),
        ),
      );
      expect(
        material.borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      );
    });
  });
}
