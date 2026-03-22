import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/core/coordinate_system.dart';
import 'package:zporter_tactical_board/v2/engine/hit_tester.dart' as v2;
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/models/line_element.dart';
import 'package:zporter_tactical_board/v2/models/shape_elements.dart';

void main() {
  const fieldSize = Size(1050, 680);
  const coords = CoordinateSystem(fieldSize);
  const hitTester = v2.HitTester();

  group('HitTester - player elements', () {
    test('hit test detects tap on player center', () {
      final player = const PlayerElement(
        id: 'p1',
        offset: Offset(0.5, 0.5),
        role: 'ST',
        jerseyNumber: 9,
        playerType: PlayerType.HOME,
        size: Size(0.04, 0.06),
      );

      // Tap at field center (where player is)
      final hit = hitTester.hitTest(
        const Offset(525, 340),
        [player],
        coords,
      );
      expect(hit, isNotNull);
      expect(hit!.id, 'p1');
    });

    test('hit test misses when tapping far from player', () {
      final player = const PlayerElement(
        id: 'p1',
        offset: Offset(0.5, 0.5),
        role: 'ST',
        jerseyNumber: 9,
        playerType: PlayerType.HOME,
        size: Size(0.04, 0.06),
      );

      // Tap far from player
      final hit = hitTester.hitTest(
        const Offset(100, 100),
        [player],
        coords,
      );
      expect(hit, isNull);
    });

    test('returns topmost element when overlapping', () {
      const player1 = PlayerElement(
        id: 'p1',
        offset: Offset(0.5, 0.5),
        role: 'GK',
        jerseyNumber: 1,
        playerType: PlayerType.HOME,
        size: Size(0.04, 0.06),
        zIndex: 1,
      );
      const player2 = PlayerElement(
        id: 'p2',
        offset: Offset(0.5, 0.5), // same position
        role: 'ST',
        jerseyNumber: 9,
        playerType: PlayerType.AWAY,
        size: Size(0.04, 0.06),
        zIndex: 5, // higher z-index
      );

      final hit = hitTester.hitTest(
        const Offset(525, 340),
        [player1, player2],
        coords,
      );
      expect(hit, isNotNull);
      expect(hit!.id, 'p2'); // higher zIndex wins
    });
  });

  group('HitTester - line elements', () {
    test('hit test detects tap near line segment', () {
      const line = LineElement(
        id: 'line-1',
        start: Offset(0.2, 0.5),
        end: Offset(0.8, 0.5),
        lineType: LineType.PASS,
        name: 'Pass',
        imagePath: '',
      );

      // Tap at midpoint of line
      final midX = (0.2 + 0.8) / 2 * 1050;
      final midY = 0.5 * 680;
      final hit = hitTester.hitTest(
        Offset(midX, midY),
        [line],
        coords,
      );
      expect(hit, isNotNull);
      expect(hit!.id, 'line-1');
    });

    test('hit test misses when far from line', () {
      const line = LineElement(
        id: 'line-1',
        start: Offset(0.2, 0.5),
        end: Offset(0.8, 0.5),
        lineType: LineType.PASS,
        name: 'Pass',
        imagePath: '',
      );

      // Tap far above line
      final hit = hitTester.hitTest(
        const Offset(525, 50),
        [line],
        coords,
      );
      expect(hit, isNull);
    });
  });

  group('HitTester - circle elements', () {
    test('hit test detects tap inside circle', () {
      final circle = CircleElement(
        id: 'c1',
        center: const Offset(0.5, 0.5),
        radius: 0.05,
        name: 'Zone',
        imagePath: '',
      );

      final hit = hitTester.hitTest(
        const Offset(525, 340),
        [circle],
        coords,
      );
      expect(hit, isNotNull);
      expect(hit!.id, 'c1');
    });

    test('hit test misses outside circle', () {
      final circle = CircleElement(
        id: 'c1',
        center: const Offset(0.5, 0.5),
        radius: 0.02,
        name: 'Zone',
        imagePath: '',
      );

      // Tap far from circle
      final hit = hitTester.hitTest(
        const Offset(100, 100),
        [circle],
        coords,
      );
      expect(hit, isNull);
    });
  });

  group('HitTester - hitTestAll', () {
    test('returns all overlapping elements in z-order', () {
      const player1 = PlayerElement(
        id: 'p1',
        offset: Offset(0.5, 0.5),
        role: 'GK',
        jerseyNumber: 1,
        playerType: PlayerType.HOME,
        size: Size(0.04, 0.06),
        zIndex: 1,
      );
      const player2 = PlayerElement(
        id: 'p2',
        offset: Offset(0.5, 0.5),
        role: 'ST',
        jerseyNumber: 9,
        playerType: PlayerType.AWAY,
        size: Size(0.04, 0.06),
        zIndex: 5,
      );

      final hits = hitTester.hitTestAll(
        const Offset(525, 340),
        [player1, player2],
        coords,
      );
      expect(hits.length, 2);
      expect(hits[0].id, 'p2'); // highest zIndex first
      expect(hits[1].id, 'p1');
    });

    test('returns empty list when nothing hit', () {
      const player = PlayerElement(
        id: 'p1',
        offset: Offset(0.5, 0.5),
        role: 'ST',
        jerseyNumber: 9,
        playerType: PlayerType.HOME,
        size: Size(0.04, 0.06),
      );

      final hits = hitTester.hitTestAll(
        const Offset(0, 0),
        [player],
        coords,
      );
      expect(hits, isEmpty);
    });
  });

  group('HitTester - center anchoring', () {
    test('element at 0.5,0.5 is hit-testable at field center pixel', () {
      const player = PlayerElement(
        id: 'center-player',
        offset: Offset(0.5, 0.5),
        role: 'CM',
        jerseyNumber: 8,
        playerType: PlayerType.HOME,
        size: Size(0.04, 0.06),
      );

      // Field center in pixels
      const fieldCenter = Offset(525, 340);

      final hit = hitTester.hitTest(fieldCenter, [player], coords);
      expect(hit, isNotNull);
      expect(hit!.id, 'center-player');
    });

    test('dragging position represents center, not top-left', () {
      // Simulating: user taps at (525, 340), this becomes the element's center
      final relativeCenter = coords.toRelative(const Offset(525, 340));
      expect(relativeCenter.dx, closeTo(0.5, 0.001));
      expect(relativeCenter.dy, closeTo(0.5, 0.001));

      // When painting, the element rect should be centered at this position
      final rect = coords.elementRect(
        relativeCenter: relativeCenter,
        relativeSize: const Size(0.04, 0.04),
      );
      expect(rect.center.dx, closeTo(525, 1.0));
      expect(rect.center.dy, closeTo(340, 1.0));
    });
  });
}
