import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:zporter_tactical_board/data/animation/model/trajectory_path_model.dart';

/// Utility class for calculating interpolated positions along trajectory paths
/// Handles different path types: straight, Catmull-Rom spline, Bezier curves
class TrajectoryCalculator {
  /// Calculate a list of interpolated positions along the path
  ///
  /// [startPosition]: Starting point of the animation
  /// [endPosition]: Ending point of the animation
  /// [trajectory]: Optional trajectory path model (null = straight line)
  /// [frameCount]: Number of intermediate positions to calculate (higher = smoother)
  ///
  /// Returns a list of Vector2 positions representing the path
  static List<Vector2> calculatePath({
    required Vector2 startPosition,
    required Vector2 endPosition,
    TrajectoryPathModel? trajectory,
    int frameCount = 60, // 60 frames for 1 second at 60fps
  }) {
    // If no trajectory or not enabled, return straight line (FREE tier behavior)
    if (trajectory == null || !trajectory.enabled || !trajectory.isCustomPath) {
      return _calculateStraightPath(
        start: startPosition,
        end: endPosition,
        frameCount: frameCount,
      );
    }

    // PRO feature: Calculate custom trajectory path
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
        // Future implementation for Bezier curves
        return _calculateBezierPath(
          start: startPosition,
          end: endPosition,
          controlPoints: trajectory.controlPoints,
          frameCount: frameCount,
        );
    }
  }

  /// Calculate straight line path (default FREE tier behavior)
  static List<Vector2> _calculateStraightPath({
    required Vector2 start,
    required Vector2 end,
    required int frameCount,
  }) {
    final path = <Vector2>[];

    for (int i = 0; i <= frameCount; i++) {
      final t = i / frameCount;
      final x = start.x + (end.x - start.x) * t;
      final y = start.y + (end.y - start.y) * t;
      path.add(Vector2(x, y));
    }

    return path;
  }

  /// Calculate Catmull-Rom spline path (PRO feature)
  ///
  /// Catmull-Rom creates smooth curves that pass through all control points
  /// Perfect for natural-looking movements in sports animations
  static List<Vector2> _calculateCatmullRomPath({
    required Vector2 start,
    required Vector2 end,
    required List<ControlPoint> controlPoints,
    required int frameCount,
    required double smoothness,
  }) {
    // If no control points, fall back to straight line
    if (controlPoints.isEmpty) {
      return _calculateStraightPath(
        start: start,
        end: end,
        frameCount: frameCount,
      );
    }

    final path = <Vector2>[];

    // Build the key points that the path MUST pass through: start -> control points -> end
    final keyPoints = <Vector2>[
      start,
      ...controlPoints.map((cp) => cp.position),
      end,
    ];

    // For Catmull-Rom spline, we need virtual points for the tangent calculation
    // But the curve will interpolate between the actual key points
    final allPoints = <Vector2>[];

    // Add virtual start point (for tangent calculation at start)
    final virtualStart = keyPoints[0] * 2.0 - keyPoints[1];
    allPoints.add(virtualStart);

    // Add all key points
    allPoints.addAll(keyPoints);

    // Add virtual end point (for tangent calculation at end)
    final virtualEnd =
        keyPoints[keyPoints.length - 1] * 2.0 - keyPoints[keyPoints.length - 2];
    allPoints.add(virtualEnd);

    // Calculate interpolated points along the curve
    // The curve goes through keyPoints, using virtual points only for tangent calculation
    final segmentCount =
        keyPoints.length - 1; // Number of segments between key points

    for (int segment = 0; segment < segmentCount; segment++) {
      // Get 4 points for Catmull-Rom: P0 (before), P1 (start), P2 (end), P3 (after)
      final p0 = allPoints[segment]; // Virtual or previous key point
      final p1 = allPoints[segment + 1]; // Segment start (key point)
      final p2 = allPoints[segment + 2]; // Segment end (key point)
      final p3 = allPoints[segment + 3]; // Next key point or virtual

      // Calculate points within this segment
      final pointsPerSegment = frameCount ~/ segmentCount;

      for (int i = 0; i <= pointsPerSegment; i++) {
        // Skip the last point of each segment (except the final segment) to avoid duplicates
        if (i == pointsPerSegment && segment < segmentCount - 1) {
          continue;
        }

        final t = i / pointsPerSegment;

        // Catmull-Rom spline: interpolates between P1 and P2
        final position = _catmullRomInterpolate(
          p0: p0,
          p1: p1,
          p2: p2,
          p3: p3,
          t: t,
          tension: smoothness,
        );

        path.add(position);
      }
    }

    return path;
  }

  /// Catmull-Rom interpolation formula
  ///
  /// Standard Formula: P(t) = 0.5 * (
  ///   2*P1 +
  ///   (-P0 + P2) * t +
  ///   (2*P0 - 5*P1 + 4*P2 - P3) * t^2 +
  ///   (-P0 + 3*P1 - 3*P2 + P3) * t^3
  /// )
  ///
  /// The tension parameter (0.0 to 1.0) controls curve tightness by scaling tangent vectors
  static Vector2 _catmullRomInterpolate({
    required Vector2 p0,
    required Vector2 p1,
    required Vector2 p2,
    required Vector2 p3,
    required double t,
    required double tension,
  }) {
    final t2 = t * t;
    final t3 = t2 * t;

    // Standard Catmull-Rom formula
    // The tension parameter scales the influence of neighboring points (0.0 = loose, 1.0 = tight)
    final c = 0.5;

    final x = c *
        ((2 * p1.x) +
            (-p0.x + p2.x) * t +
            (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * t2 +
            (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * t3);

    final y = c *
        ((2 * p1.y) +
            (-p0.y + p2.y) * t +
            (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * t2 +
            (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * t3);

    return Vector2(x, y);
  }

  /// Calculate cubic Bezier curve path (PRO feature - future implementation)
  ///
  /// Bezier curves use control handles that don't necessarily pass through
  /// the control points, giving more control over curve shape
  static List<Vector2> _calculateBezierPath({
    required Vector2 start,
    required Vector2 end,
    required List<ControlPoint> controlPoints,
    required int frameCount,
  }) {
    // TODO: Implement Bezier curve calculation in future update
    // For now, fall back to Catmull-Rom behavior
    return _calculateCatmullRomPath(
      start: start,
      end: end,
      controlPoints: controlPoints,
      frameCount: frameCount,
      smoothness: 0.5,
    );
  }

  /// Calculate the total length of a path
  /// Useful for determining animation speed
  static double calculatePathLength(List<Vector2> path) {
    if (path.length < 2) return 0.0;

    double totalLength = 0.0;

    for (int i = 0; i < path.length - 1; i++) {
      totalLength += path[i].distanceTo(path[i + 1]);
    }

    return totalLength;
  }

  /// Get position at specific time along path (0.0 to 1.0)
  /// Used for animation playback
  static Vector2 getPositionAtTime(List<Vector2> path, double time) {
    if (path.isEmpty) return Vector2.zero();
    if (path.length == 1) return path.first.clone();

    // Clamp time to valid range
    final t = time.clamp(0.0, 1.0);

    // Calculate index in path
    final index = (t * (path.length - 1)).floor();
    final nextIndex = math.min(index + 1, path.length - 1);

    // Interpolate between two points
    final localT = (t * (path.length - 1)) - index;
    final current = path[index];
    final next = path[nextIndex];

    return Vector2(
      current.x + (next.x - current.x) * localT,
      current.y + (next.y - current.y) * localT,
    );
  }

  /// Generate default control points for a path
  /// Places points at 1/3 and 2/3 distance along straight line
  static List<ControlPoint> generateDefaultControlPoints({
    required Vector2 start,
    required Vector2 end,
    int count = 2,
  }) {
    final controlPoints = <ControlPoint>[];

    for (int i = 1; i <= count; i++) {
      final t = i / (count + 1);
      final position = Vector2(
        start.x + (end.x - start.x) * t,
        start.y + (end.y - start.y) * t,
      );

      controlPoints.add(ControlPoint(
        position: position,
        type: ControlPointType.smooth,
        tension: 0.5,
      ));
    }

    return controlPoints;
  }
}
