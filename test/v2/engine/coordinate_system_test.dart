import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/core/coordinate_system.dart';

void main() {
  // Use V1's default field size for consistency
  const fieldSize = Size(1050, 680);
  const coords = CoordinateSystem(fieldSize);

  group('CoordinateSystem - position conversion', () {
    test('toScreen converts relative 0.5, 0.5 to field center', () {
      final screen = coords.toScreen(const Offset(0.5, 0.5));
      expect(screen.dx, 525.0);
      expect(screen.dy, 340.0);
    });

    test('toScreen converts relative 0, 0 to origin', () {
      final screen = coords.toScreen(Offset.zero);
      expect(screen, Offset.zero);
    });

    test('toScreen converts relative 1, 1 to bottom-right', () {
      final screen = coords.toScreen(const Offset(1.0, 1.0));
      expect(screen.dx, 1050.0);
      expect(screen.dy, 680.0);
    });

    test('toRelative converts center pixels to 0.5, 0.5', () {
      final relative = coords.toRelative(const Offset(525.0, 340.0));
      expect(relative.dx, 0.5);
      expect(relative.dy, 0.5);
    });

    test('round-trip preserves position', () {
      const original = Offset(0.37, 0.82);
      final screen = coords.toScreen(original);
      final back = coords.toRelative(screen);
      expect(back.dx, closeTo(0.37, 0.0001));
      expect(back.dy, closeTo(0.82, 0.0001));
    });

    test('handles zero-size field gracefully', () {
      const zeroCoords = CoordinateSystem(Size.zero);
      final screen = zeroCoords.toScreen(const Offset(0.5, 0.5));
      expect(screen, Offset.zero);

      final relative = zeroCoords.toRelative(const Offset(100, 100));
      expect(relative, Offset.zero);
    });
  });

  group('CoordinateSystem - dimension conversion', () {
    test('dimensionToScreen uses average of width and height', () {
      // Average = (1050 + 680) / 2 = 865
      final screen = coords.dimensionToScreen(0.1);
      expect(screen, closeTo(86.5, 0.01));
    });

    test('dimensionToRelative is inverse of dimensionToScreen', () {
      const relativeSize = 0.05;
      final screen = coords.dimensionToScreen(relativeSize);
      final back = coords.dimensionToRelative(screen);
      expect(back, closeTo(relativeSize, 0.0001));
    });

    test('dimension round-trip preserves value', () {
      const original = 0.123;
      final screen = coords.dimensionToScreen(original);
      final back = coords.dimensionToRelative(screen);
      expect(back, closeTo(original, 0.0001));
    });
  });

  group('CoordinateSystem - size conversion', () {
    test('sizeToScreen scales per axis', () {
      final screen = coords.sizeToScreen(const Size(0.1, 0.2));
      expect(screen.width, closeTo(105.0, 0.01));
      expect(screen.height, closeTo(136.0, 0.01));
    });

    test('sizeToRelative is inverse', () {
      const relative = Size(0.15, 0.25);
      final screen = coords.sizeToScreen(relative);
      final back = coords.sizeToRelative(screen);
      expect(back.width, closeTo(0.15, 0.0001));
      expect(back.height, closeTo(0.25, 0.0001));
    });
  });

  group('CoordinateSystem - delta conversion', () {
    test('deltaToRelative converts screen drag to relative', () {
      final delta = coords.deltaToRelative(const Offset(105, 68));
      expect(delta.dx, closeTo(0.1, 0.0001));
      expect(delta.dy, closeTo(0.1, 0.0001));
    });
  });

  group('CoordinateSystem - elementRect', () {
    test('elementRect creates center-anchored rect', () {
      final rect = coords.elementRect(
        relativeCenter: const Offset(0.5, 0.5),
        relativeSize: const Size(0.1, 0.1),
      );

      // Center should be at 525, 340
      expect(rect.center.dx, closeTo(525.0, 0.01));
      expect(rect.center.dy, closeTo(340.0, 0.01));

      // Width and height use dimensionToScreen (average-based)
      final dim = coords.dimensionToScreen(0.1);
      expect(rect.width, closeTo(dim, 0.01));
      expect(rect.height, closeTo(dim, 0.01));
    });

    test('containsPoint detects point inside element', () {
      expect(
        coords.containsPoint(
          screenPoint: const Offset(525, 340),
          relativeCenter: const Offset(0.5, 0.5),
          relativeSize: const Size(0.1, 0.1),
        ),
        true,
      );
    });

    test('containsPoint rejects point outside element', () {
      expect(
        coords.containsPoint(
          screenPoint: const Offset(0, 0),
          relativeCenter: const Offset(0.5, 0.5),
          relativeSize: const Size(0.1, 0.1),
        ),
        false,
      );
    });
  });

  group('CoordinateSystem - V1 compatibility', () {
    test('matches V1 SizeHelper.getBoardActualVector', () {
      // V1: screen = relative × fieldSize (per axis)
      const relative = Offset(0.5, 0.25);
      final screen = coords.toScreen(relative);
      expect(screen.dx, 525.0); // 0.5 × 1050
      expect(screen.dy, 170.0); // 0.25 × 680
    });

    test('matches V1 SizeHelper.getBoardRelativeVector', () {
      // V1: relative = screen ÷ fieldSize (per axis)
      const screen = Offset(600.0, 300.0);
      final relative = coords.toRelative(screen);
      expect(relative.dx, closeTo(600.0 / 1050.0, 0.0001));
      expect(relative.dy, closeTo(300.0 / 680.0, 0.0001));
    });

    test('matches V1 SizeHelper.getBoardActualDimension', () {
      // V1: screenSize = relativeSize × average(w, h)
      final screen = coords.dimensionToScreen(0.1);
      final avgDim = (1050 + 680) / 2.0;
      expect(screen, closeTo(0.1 * avgDim, 0.01));
    });

    test('matches V1 SizeHelper.getBoardRelativeDimension', () {
      // V1: relativeSize = screenSize ÷ average(w, h)
      final relative = coords.dimensionToRelative(86.5);
      final avgDim = (1050 + 680) / 2.0;
      expect(relative, closeTo(86.5 / avgDim, 0.0001));
    });
  });
}
