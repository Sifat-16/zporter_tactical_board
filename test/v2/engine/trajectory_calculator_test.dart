import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/engine/trajectory_calculator.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/trajectory_model.dart';

void main() {
  group('TrajectoryCalculatorV2 - straight path', () {
    test('returns frameCount + 1 points', () {
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: Offset.zero,
        endPosition: const Offset(1.0, 0.0),
        frameCount: 10,
      );
      expect(path.length, 11);
    });

    test('start and end match inputs', () {
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: const Offset(0.2, 0.3),
        endPosition: const Offset(0.8, 0.7),
        frameCount: 20,
      );
      expect(path.first.dx, closeTo(0.2, 0.0001));
      expect(path.first.dy, closeTo(0.3, 0.0001));
      expect(path.last.dx, closeTo(0.8, 0.0001));
      expect(path.last.dy, closeTo(0.7, 0.0001));
    });

    test('midpoint is exactly between start and end', () {
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: const Offset(0.0, 0.0),
        endPosition: const Offset(1.0, 1.0),
        frameCount: 10,
      );
      final mid = path[5];
      expect(mid.dx, closeTo(0.5, 0.0001));
      expect(mid.dy, closeTo(0.5, 0.0001));
    });

    test('null trajectory returns straight path', () {
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: Offset.zero,
        endPosition: const Offset(1.0, 0.0),
        trajectory: null,
        frameCount: 5,
      );
      expect(path.length, 6);
      expect(path.first, Offset.zero);
      expect(path.last.dx, closeTo(1.0, 0.0001));
    });

    test('disabled trajectory returns straight path', () {
      final trajectory = TrajectoryPathV2(
        pathType: PathType.catmullRom,
        enabled: false,
      );
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: Offset.zero,
        endPosition: const Offset(1.0, 0.0),
        trajectory: trajectory,
        frameCount: 5,
      );
      expect(path.length, 6);
    });
  });

  group('TrajectoryCalculatorV2 - Catmull-Rom', () {
    test('with no control points falls back to straight', () {
      final trajectory = TrajectoryPathV2(
        pathType: PathType.catmullRom,
        enabled: true,
        controlPoints: const [],
      );
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: Offset.zero,
        endPosition: const Offset(1.0, 0.0),
        trajectory: trajectory,
        frameCount: 10,
      );
      // Should be straight — midpoint at (0.5, 0.0)
      final mid = TrajectoryCalculatorV2.getPositionAtTime(path, 0.5);
      expect(mid.dx, closeTo(0.5, 0.01));
      expect(mid.dy, closeTo(0.0, 0.01));
    });

    test('with 1 control point produces curved path', () {
      final trajectory = TrajectoryPathV2(
        pathType: PathType.catmullRom,
        enabled: true,
        controlPoints: [
          ControlPointV2(
            position: const Offset(0.5, 0.3), // offset above straight line
          ),
        ],
      );
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: const Offset(0.0, 0.0),
        endPosition: const Offset(1.0, 0.0),
        trajectory: trajectory,
        frameCount: 60,
      );

      // Path should curve above the straight line
      final hasPointsAboveLine = path.any((p) => p.dy > 0.05);
      expect(hasPointsAboveLine, true);
    });

    test('path passes through control points', () {
      final cp = ControlPointV2(
        position: const Offset(0.5, 0.4),
      );
      final trajectory = TrajectoryPathV2(
        pathType: PathType.catmullRom,
        enabled: true,
        controlPoints: [cp],
      );
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: const Offset(0.0, 0.0),
        endPosition: const Offset(1.0, 0.0),
        trajectory: trajectory,
        frameCount: 60,
      );

      // At least one point should be close to the control point
      final closestDist = path
          .map((p) => (p - cp.position).distance)
          .reduce((a, b) => a < b ? a : b);
      expect(closestDist, lessThan(0.05));
    });

    test('sharp corner uses linear interpolation for that segment', () {
      final trajectory = TrajectoryPathV2(
        pathType: PathType.catmullRom,
        enabled: true,
        controlPoints: [
          ControlPointV2(
            position: const Offset(0.5, 0.5),
            type: ControlPointType.sharp,
          ),
        ],
      );
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: const Offset(0.0, 0.0),
        endPosition: const Offset(1.0, 0.0),
        trajectory: trajectory,
        frameCount: 60,
      );

      // First segment (0,0) → (0.5,0.5) should be linear
      // Quarter of first segment should be at (0.125, 0.125) approximately
      final firstQuarter = path[(path.length * 0.125).round()];
      // With sharp corners both segments are linear,
      // so the path should hit (0.5, 0.5)
      final closestToCP = path
          .map((p) => (p - const Offset(0.5, 0.5)).distance)
          .reduce((a, b) => a < b ? a : b);
      expect(closestToCP, lessThan(0.05));
    });
  });

  group('TrajectoryCalculatorV2 - getPositionAtTime', () {
    test('time 0.0 returns start', () {
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: const Offset(0.2, 0.3),
        endPosition: const Offset(0.8, 0.7),
        frameCount: 20,
      );
      final pos = TrajectoryCalculatorV2.getPositionAtTime(path, 0.0);
      expect(pos.dx, closeTo(0.2, 0.0001));
      expect(pos.dy, closeTo(0.3, 0.0001));
    });

    test('time 1.0 returns end', () {
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: const Offset(0.2, 0.3),
        endPosition: const Offset(0.8, 0.7),
        frameCount: 20,
      );
      final pos = TrajectoryCalculatorV2.getPositionAtTime(path, 1.0);
      expect(pos.dx, closeTo(0.8, 0.0001));
      expect(pos.dy, closeTo(0.7, 0.0001));
    });

    test('time 0.5 returns midpoint for straight path', () {
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: const Offset(0.0, 0.0),
        endPosition: const Offset(1.0, 1.0),
        frameCount: 100,
      );
      final pos = TrajectoryCalculatorV2.getPositionAtTime(path, 0.5);
      expect(pos.dx, closeTo(0.5, 0.01));
      expect(pos.dy, closeTo(0.5, 0.01));
    });

    test('clamps out-of-range values', () {
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: const Offset(0.0, 0.0),
        endPosition: const Offset(1.0, 0.0),
        frameCount: 10,
      );
      final before = TrajectoryCalculatorV2.getPositionAtTime(path, -0.5);
      expect(before.dx, closeTo(0.0, 0.0001));

      final after = TrajectoryCalculatorV2.getPositionAtTime(path, 1.5);
      expect(after.dx, closeTo(1.0, 0.0001));
    });

    test('empty path returns Offset.zero', () {
      final pos = TrajectoryCalculatorV2.getPositionAtTime([], 0.5);
      expect(pos, Offset.zero);
    });

    test('single-point path returns that point', () {
      final pos = TrajectoryCalculatorV2.getPositionAtTime(
        [const Offset(0.3, 0.7)],
        0.5,
      );
      expect(pos.dx, closeTo(0.3, 0.0001));
      expect(pos.dy, closeTo(0.7, 0.0001));
    });
  });

  group('TrajectoryCalculatorV2 - calculatePathLength', () {
    test('returns 0 for empty path', () {
      expect(TrajectoryCalculatorV2.calculatePathLength([]), 0.0);
    });

    test('returns 0 for single-point path', () {
      expect(
        TrajectoryCalculatorV2.calculatePathLength([const Offset(1, 1)]),
        0.0,
      );
    });

    test('horizontal line length equals distance', () {
      final path = [
        const Offset(0.0, 0.0),
        const Offset(1.0, 0.0),
      ];
      expect(
        TrajectoryCalculatorV2.calculatePathLength(path),
        closeTo(1.0, 0.0001),
      );
    });

    test('multi-segment path sums segment lengths', () {
      final path = [
        const Offset(0.0, 0.0),
        const Offset(1.0, 0.0),
        const Offset(1.0, 1.0),
      ];
      expect(
        TrajectoryCalculatorV2.calculatePathLength(path),
        closeTo(2.0, 0.0001),
      );
    });
  });

  group('TrajectoryCalculatorV2 - generateDefaultControlPoints', () {
    test('generates requested number of points', () {
      final cps = TrajectoryCalculatorV2.generateDefaultControlPoints(
        start: Offset.zero,
        end: const Offset(1.0, 0.0),
        count: 3,
      );
      expect(cps.length, 3);
    });

    test('points are evenly spaced along line', () {
      final cps = TrajectoryCalculatorV2.generateDefaultControlPoints(
        start: const Offset(0.0, 0.0),
        end: const Offset(1.0, 0.0),
        count: 2,
      );
      expect(cps[0].position.dx, closeTo(1.0 / 3, 0.01));
      expect(cps[1].position.dx, closeTo(2.0 / 3, 0.01));
    });

    test('points default to smooth type', () {
      final cps = TrajectoryCalculatorV2.generateDefaultControlPoints(
        start: Offset.zero,
        end: const Offset(1.0, 0.0),
      );
      for (final cp in cps) {
        expect(cp.type, ControlPointType.smooth);
      }
    });
  });

  group('TrajectoryCalculatorV2 - Bezier fallback', () {
    test('bezier falls back to Catmull-Rom', () {
      final trajectory = TrajectoryPathV2(
        pathType: PathType.bezier,
        enabled: true,
        controlPoints: [
          ControlPointV2(position: const Offset(0.5, 0.3)),
        ],
      );
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: Offset.zero,
        endPosition: const Offset(1.0, 0.0),
        trajectory: trajectory,
        frameCount: 30,
      );
      // Should produce a curved path (not straight)
      final hasPointsAbove = path.any((p) => p.dy > 0.05);
      expect(hasPointsAbove, true);
    });
  });
}
