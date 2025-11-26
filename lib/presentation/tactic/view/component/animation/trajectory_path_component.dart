import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/helper/trajectory_calculator.dart';
import 'package:zporter_tactical_board/data/animation/model/trajectory_path_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';

/// Renders the trajectory path between two animation scenes
///
/// PRO FEATURE: Shows curved path with control points
/// FREE FEATURE: Shows simple straight line between start and end
///
/// Visual appearance:
/// - Dashed line following the path
/// - Color: Customizable (default yellow for selected, gray for others)
/// - Arrow at the end to indicate direction
/// - Thicker line when selected (3px vs 2px)
///
/// PHASE 5A: Now supports double-tap to open context menu
class TrajectoryPathComponent extends Component
    with HasGameReference<TacticBoardGame>, TapCallbacks {
  /// The trajectory path model
  final TrajectoryPathModel pathModel;

  /// Start position of the path
  final Vector2 startPosition;

  /// End position of the path (mutable for real-time updates)
  Vector2 endPosition;

  /// Whether this path is currently selected
  bool isSelected;

  /// Number of points to generate for smooth curve rendering
  final int smoothnessPoints;

  /// Callback when trajectory path is double-tapped
  final Function(Vector2 tapPosition)? onDoubleTap;

  /// Double-tap detection
  DateTime? _lastTapTime;
  static const Duration _doubleTapWindow = Duration(milliseconds: 300);

  /// Paint for the path line
  final Paint _pathPaint = Paint()..style = PaintingStyle.stroke;

  /// Paint for the arrow
  final Paint _arrowPaint = Paint()..style = PaintingStyle.fill;

  /// Cached calculated path points
  List<Vector2>? _cachedPathPoints;

  TrajectoryPathComponent({
    required this.pathModel,
    required this.startPosition,
    required this.endPosition,
    this.isSelected = false,
    this.smoothnessPoints = 50,
    this.onDoubleTap,
    super.priority = 1, // Render above ghost but below real components
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _calculatePath();
  }

  /// Calculate the path points using the trajectory calculator
  void _calculatePath() {
    // Convert logical coordinates to screen coordinates
    final fieldSize = game.gameField.size;
    final fieldPosition = game.gameField.position;

    final startScreen = SizeHelper.getBoardActualVector(
          gameScreenSize: fieldSize,
          actualPosition: startPosition,
        ) +
        fieldPosition; // Add field offset

    final endScreen = SizeHelper.getBoardActualVector(
          gameScreenSize: fieldSize,
          actualPosition: endPosition,
        ) +
        fieldPosition; // Add field offset

    // Convert control points to screen coordinates
    final screenControlPoints = pathModel.controlPoints.map((cp) {
      final screenPos = SizeHelper.getBoardActualVector(
            gameScreenSize: fieldSize,
            actualPosition: cp.position,
          ) +
          fieldPosition; // Add field offset
      return ControlPoint(
        id: cp.id,
        position: screenPos,
        type: cp.type,
        tension: cp.tension,
      );
    }).toList();

    // Create a screen-space trajectory model
    final screenTrajectory = TrajectoryPathModel(
      id: pathModel.id,
      pathType: pathModel.pathType,
      controlPoints: screenControlPoints,
      enabled: pathModel.enabled,
      smoothness: pathModel.smoothness,
    );

    _cachedPathPoints = TrajectoryCalculator.calculatePath(
      startPosition: startScreen,
      endPosition: endScreen,
      trajectory: screenTrajectory,
      frameCount: smoothnessPoints,
    );
  }

  /// Recalculate path when model changes
  void updatePath({
    TrajectoryPathModel? newPathModel,
    Vector2? newStartPosition,
    Vector2? newEndPosition,
  }) {
    if (newPathModel != null) {
      // Would need to recreate component with new model
      // For now, just note this would require rebuild
    }
    if (newStartPosition != null) {
      // Update start position (not commonly used)
    }
    if (newEndPosition != null) {
      // Update end position (used when component is dragged)
      endPosition = newEndPosition;
    }
    _calculatePath();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Configure paint based on selection state and trajectory type
    _pathPaint.color = pathModel.pathColor.withOpacity(isSelected ? 0.9 : 0.6);
    _pathPaint.strokeWidth = isSelected ? 3.0 : pathModel.pathWidth;

    _arrowPaint.color = pathModel.pathColor.withOpacity(isSelected ? 0.9 : 0.6);

    // Draw the path with the appropriate style
    _drawStyledPath(canvas);

    // Draw arrow at the end
    _drawArrowHead(canvas);

    // // Draw control points if enabled
    // if (pathModel.showControlPoints && pathModel.controlPoints.isNotEmpty) {
    //   _drawControlPointMarkers(canvas);
    // }
  }

  /// Draw the path with appropriate line style (solid, dashed, dotted)
  void _drawStyledPath(Canvas canvas) {
    if (_cachedPathPoints == null || _cachedPathPoints!.isEmpty) return;

    // Build the full path
    final path = Path();
    path.moveTo(_cachedPathPoints![0].x, _cachedPathPoints![0].y);

    for (int i = 1; i < _cachedPathPoints!.length; i++) {
      path.lineTo(_cachedPathPoints![i].x, _cachedPathPoints![i].y);
    }

    // Draw based on line style
    switch (pathModel.lineStyle) {
      case LineStyle.solid:
        // Draw solid line
        canvas.drawPath(path, _pathPaint);
        break;

      case LineStyle.dashed:
        // Draw dashed line
        _drawDashedLine(canvas, path, dashLength: 6.0, gapLength: 4.0);
        break;

      case LineStyle.dotted:
        // Draw dotted line
        _drawDashedLine(canvas, path, dashLength: 2.0, gapLength: 3.0);
        break;
    }
  }

  /// Draw a dashed or dotted line
  void _drawDashedLine(
    Canvas canvas,
    Path path, {
    required double dashLength,
    required double gapLength,
  }) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;

      while (distance < metric.length) {
        final nextDistance = distance + (draw ? dashLength : gapLength);
        if (nextDistance > metric.length) {
          // Draw the remaining segment if we're drawing
          if (draw) {
            final extractPath = metric.extractPath(distance, metric.length);
            canvas.drawPath(extractPath, _pathPaint);
          }
          break;
        }

        if (draw) {
          final extractPath = metric.extractPath(distance, nextDistance);
          canvas.drawPath(extractPath, _pathPaint);
        }

        distance = nextDistance;
        draw = !draw;
      }
    }
  }

  /// Draw arrow head at the end of the path to indicate direction
  void _drawArrowHead(Canvas canvas) {
    if (_cachedPathPoints == null || _cachedPathPoints!.length < 2) return;

    // Get the last two points to calculate direction
    final lastPoint = _cachedPathPoints!.last;
    final secondLastPoint = _cachedPathPoints![_cachedPathPoints!.length - 2];

    // Calculate direction vector
    final direction = (lastPoint - secondLastPoint).normalized();
    final perpendicular = Vector2(-direction.y, direction.x);

    // Arrow dimensions
    const arrowLength = 12.0;
    const arrowWidth = 8.0;

    // Calculate arrow points
    final arrowTip = lastPoint;
    final arrowBase = lastPoint - (direction * arrowLength);
    final arrowLeft = arrowBase + (perpendicular * (arrowWidth / 2));
    final arrowRight = arrowBase - (perpendicular * (arrowWidth / 2));

    // Draw filled arrow
    final arrowPath = Path()
      ..moveTo(arrowTip.x, arrowTip.y)
      ..lineTo(arrowLeft.x, arrowLeft.y)
      ..lineTo(arrowRight.x, arrowRight.y)
      ..close();

    canvas.drawPath(arrowPath, _arrowPaint);
  }

  /// Draw small markers at control points for visualization
  // void _drawControlPointMarkers(Canvas canvas) {
  //   // Convert logical control point positions to screen coordinates for rendering
  //   final fieldSize = game.gameField.size;
  //   final fieldPosition = game.gameField.position;

  //   final markerPaint = Paint()
  //     ..color = Colors.yellow.withOpacity(0.5)
  //     ..style = PaintingStyle.fill;

  //   final markerBorderPaint = Paint()
  //     ..color = Colors.white.withOpacity(0.8)
  //     ..style = PaintingStyle.stroke
  //     ..strokeWidth = 1.5;

  //   for (final controlPoint in pathModel.controlPoints) {
  //     // Convert logical position to screen position
  //     final screenPos = SizeHelper.getBoardActualVector(
  //           gameScreenSize: fieldSize,
  //           actualPosition: controlPoint.position,
  //         ) +
  //         fieldPosition; // Add field offset

  //     // // Draw filled circle at screen position
  //     // canvas.drawCircle(
  //     //   Offset(screenPos.x, screenPos.y),
  //     //   4.0, // Small marker radius
  //     //   markerPaint,
  //     // );

  //     // // Draw border
  //     // canvas.drawCircle(
  //     //   Offset(screenPos.x, screenPos.y),
  //     //   4.0,
  //     //   markerBorderPaint,
  //     // );
  //   }
  // }

  /// Update selection state
  void setSelected(bool selected) {
    isSelected = selected;
  }

  /// Get the calculated path points (useful for other components)
  List<Vector2>? get pathPoints => _cachedPathPoints;

  /// Calculate the total length of the path
  double calculatePathLength() {
    if (_cachedPathPoints == null || _cachedPathPoints!.length < 2) {
      return 0.0;
    }

    return TrajectoryCalculator.calculatePathLength(_cachedPathPoints!);
  }

  /// Get position at a specific time/progress along the path (0.0 to 1.0)
  Vector2? getPositionAtProgress(double progress) {
    if (_cachedPathPoints == null || _cachedPathPoints!.isEmpty) {
      return null;
    }

    return TrajectoryCalculator.getPositionAtTime(
      _cachedPathPoints!,
      progress,
    );
  }

  // ========== Tap Detection for Context Menu ==========

  @override
  bool containsLocalPoint(Vector2 point) {
    // Check if tap is near the trajectory path
    if (_cachedPathPoints == null || _cachedPathPoints!.length < 2) {
      return false;
    }

    const double hitThreshold = 20.0; // Pixels - make it easy to tap

    // Check distance from tap point to each segment of the path
    for (int i = 0; i < _cachedPathPoints!.length - 1; i++) {
      final p1 = _cachedPathPoints![i];
      final p2 = _cachedPathPoints![i + 1];

      // Calculate distance from point to line segment
      final distance = _distanceToLineSegment(point, p1, p2);

      if (distance <= hitThreshold) {
        return true;
      }
    }

    return false;
  }

  /// Calculate distance from point to line segment
  double _distanceToLineSegment(
      Vector2 point, Vector2 lineStart, Vector2 lineEnd) {
    final lineLength = lineStart.distanceTo(lineEnd);

    if (lineLength == 0) {
      return point.distanceTo(lineStart);
    }

    // Project point onto line segment
    final t = ((point.x - lineStart.x) * (lineEnd.x - lineStart.x) +
            (point.y - lineStart.y) * (lineEnd.y - lineStart.y)) /
        (lineLength * lineLength);

    final tClamped = t.clamp(0.0, 1.0);

    // Find nearest point on segment
    final nearestPoint = Vector2(
      lineStart.x + tClamped * (lineEnd.x - lineStart.x),
      lineStart.y + tClamped * (lineEnd.y - lineStart.y),
    );

    return point.distanceTo(nearestPoint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < _doubleTapWindow) {
      // Double-tap detected - open context menu
      onDoubleTap?.call(event.localPosition);
      _lastTapTime = null;
    } else {
      // Single tap - just record time
      _lastTapTime = now;
    }
  }
}
