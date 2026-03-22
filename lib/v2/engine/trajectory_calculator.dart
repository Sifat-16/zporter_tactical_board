import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/trajectory_model.dart';

/// Calculates interpolated positions along trajectory paths.
///
/// Port of V1's [TrajectoryCalculator] using [Offset] instead of
/// Flame's [Vector2]. Pure Dart — no Flutter dependency.
///
/// Supports straight (lerp), Catmull-Rom spline (smooth through
/// control points with optional sharp corners), and Bezier
/// (falls back to Catmull-Rom for now).
class TrajectoryCalculatorV2 {
  TrajectoryCalculatorV2._();

  /// Calculate path points from [startPosition] to [endPosition].
  ///
  /// If [trajectory] is null, disabled, or straight, returns a
  /// straight line. Otherwise computes a curved path through
  /// the trajectory's control points.
  ///
  /// Returns `frameCount + 1` points (inclusive of start and end).
  static List<Offset> calculatePath({
    required Offset startPosition,
    required Offset endPosition,
    TrajectoryPathV2? trajectory,
    int frameCount = 60,
  }) {
    if (trajectory == null ||
        !trajectory.enabled ||
        !trajectory.isCustomPath) {
      return _calculateStraightPath(
        start: startPosition,
        end: endPosition,
        frameCount: frameCount,
      );
    }

    switch (trajectory.pathType) {
      case PathType.straight:
        return _calculateStraightPath(
          start: startPosition,
          end: endPosition,
          frameCount: frameCount,
        );
      case PathType.catmullRom:
        return _calculateCatmullRomPath(
          start: startPosition,
          end: endPosition,
          controlPoints: trajectory.controlPoints,
          frameCount: frameCount,
          smoothness: trajectory.smoothness,
        );
      case PathType.bezier:
        // Falls back to Catmull-Rom (matches V1 behavior)
        return _calculateCatmullRomPath(
          start: startPosition,
          end: endPosition,
          controlPoints: trajectory.controlPoints,
          frameCount: frameCount,
          smoothness: trajectory.smoothness,
        );
    }
  }

  /// Get interpolated position at [time] (0.0–1.0) along a pre-computed [path].
  static Offset getPositionAtTime(List<Offset> path, double time) {
    if (path.isEmpty) return Offset.zero;
    if (path.length == 1) return path.first;

    final t = time.clamp(0.0, 1.0);
    final index = (t * (path.length - 1)).floor();
    final nextIndex = math.min(index + 1, path.length - 1);
    final localT = (t * (path.length - 1)) - index;

    final current = path[index];
    final next = path[nextIndex];

    return Offset(
      current.dx + (next.dx - current.dx) * localT,
      current.dy + (next.dy - current.dy) * localT,
    );
  }

  /// Calculate total arc length of a [path].
  static double calculatePathLength(List<Offset> path) {
    if (path.length < 2) return 0.0;

    double total = 0.0;
    for (int i = 0; i < path.length - 1; i++) {
      total += (path[i + 1] - path[i]).distance;
    }
    return total;
  }

  /// Generate default control points at even intervals along a straight line.
  static List<ControlPointV2> generateDefaultControlPoints({
    required Offset start,
    required Offset end,
    int count = 2,
  }) {
    final controlPoints = <ControlPointV2>[];
    for (int i = 1; i <= count; i++) {
      final t = i / (count + 1);
      controlPoints.add(ControlPointV2(
        position: Offset(
          start.dx + (end.dx - start.dx) * t,
          start.dy + (end.dy - start.dy) * t,
        ),
        type: ControlPointType.smooth,
        tension: 0.5,
      ));
    }
    return controlPoints;
  }

  // ---------------------------------------------------------------------------
  // Private path calculations
  // ---------------------------------------------------------------------------

  static List<Offset> _calculateStraightPath({
    required Offset start,
    required Offset end,
    required int frameCount,
  }) {
    final path = <Offset>[];
    for (int i = 0; i <= frameCount; i++) {
      final t = i / frameCount;
      path.add(Offset(
        start.dx + (end.dx - start.dx) * t,
        start.dy + (end.dy - start.dy) * t,
      ));
    }
    return path;
  }

  static List<Offset> _calculateCatmullRomPath({
    required Offset start,
    required Offset end,
    required List<ControlPointV2> controlPoints,
    required int frameCount,
    required double smoothness,
  }) {
    if (controlPoints.isEmpty) {
      return _calculateStraightPath(
        start: start,
        end: end,
        frameCount: frameCount,
      );
    }

    final path = <Offset>[];

    // Key points the path must pass through: start → control points → end
    final keyPoints = <Offset>[
      start,
      ...controlPoints.map((cp) => cp.position),
      end,
    ];

    // Point types for sharp/smooth detection
    final pointTypes = <ControlPointType>[
      ControlPointType.smooth, // start
      ...controlPoints.map((cp) => cp.type),
      ControlPointType.smooth, // end
    ];

    final segmentCount = keyPoints.length - 1;

    for (int segment = 0; segment < segmentCount; segment++) {
      final p1 = keyPoints[segment];
      final p2 = keyPoints[segment + 1];

      final isP1Sharp = pointTypes[segment] == ControlPointType.sharp;
      final isP2Sharp = pointTypes[segment + 1] == ControlPointType.sharp;

      final pointsPerSegment = frameCount ~/ segmentCount;

      if (isP1Sharp || isP2Sharp) {
        // Sharp corner: linear interpolation for this segment
        for (int i = 0; i <= pointsPerSegment; i++) {
          if (i == pointsPerSegment && segment < segmentCount - 1) continue;
          final t = i / pointsPerSegment;
          path.add(Offset(
            p1.dx + (p2.dx - p1.dx) * t,
            p1.dy + (p2.dy - p1.dy) * t,
          ));
        }
      } else {
        // Smooth curve: Catmull-Rom spline
        final p0 = segment > 0
            ? keyPoints[segment - 1]
            : Offset(
                keyPoints[0].dx * 2.0 - keyPoints[1].dx,
                keyPoints[0].dy * 2.0 - keyPoints[1].dy,
              );
        final p3 = segment < segmentCount - 1
            ? keyPoints[segment + 2]
            : Offset(
                keyPoints.last.dx * 2.0 -
                    keyPoints[keyPoints.length - 2].dx,
                keyPoints.last.dy * 2.0 -
                    keyPoints[keyPoints.length - 2].dy,
              );

        for (int i = 0; i <= pointsPerSegment; i++) {
          if (i == pointsPerSegment && segment < segmentCount - 1) continue;
          final t = i / pointsPerSegment;
          path.add(_catmullRomInterpolate(
            p0: p0,
            p1: p1,
            p2: p2,
            p3: p3,
            t: t,
            tension: smoothness,
          ));
        }
      }
    }

    return path;
  }

  /// Standard Catmull-Rom interpolation:
  ///
  /// P(t) = 0.5 * (2·P1 + (−P0+P2)·t + (2P0−5P1+4P2−P3)·t² + (−P0+3P1−3P2+P3)·t³)
  static Offset _catmullRomInterpolate({
    required Offset p0,
    required Offset p1,
    required Offset p2,
    required Offset p3,
    required double t,
    required double tension,
  }) {
    final t2 = t * t;
    final t3 = t2 * t;
    const c = 0.5;

    final x = c *
        ((2 * p1.dx) +
            (-p0.dx + p2.dx) * t +
            (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * t2 +
            (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * t3);

    final y = c *
        ((2 * p1.dy) +
            (-p0.dy + p2.dy) * t +
            (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * t2 +
            (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * t3);

    return Offset(x, y);
  }
}
