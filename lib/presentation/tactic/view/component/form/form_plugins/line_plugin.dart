import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

// DraggableDot class remains the same
class DraggableDot extends CircleComponent with DragCallbacks {
  final Function(Vector2) onPositionChanged;
  final Vector2 initialPosition;
  final bool canModifyLine;
  final int dotIndex;
  Color color;

  DraggableDot({
    required this.onPositionChanged,
    required this.initialPosition,
    required this.dotIndex,
    this.canModifyLine = true,
    super.radius = 8.0,
    this.color = Colors.blue,
  }) : super(
         position: initialPosition,
         anchor: Anchor.center,
         paint: Paint()..color = color,
         priority: 2,
       );

  Vector2? _dragStartLocalPosition;

  @override
  void onDragStart(DragStartEvent event) {
    _dragStartLocalPosition = event.localPosition;
    event.continuePropagation = false;
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragStartLocalPosition != null) {
      onPositionChanged(position + event.localDelta);
    }
    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _dragStartLocalPosition = null;
    event.continuePropagation = false;
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _dragStartLocalPosition = null;
    event.continuePropagation = false;
    super.onDragCancel(event);
  }
}

class LineDrawerComponentV2 extends PositionComponent
    with
        TapCallbacks,
        DragCallbacks,
        RiverpodComponentMixin,
        HasGameReference<TacticBoardGame> {
  LineModelV2 lineModelV2;
  late LineModelV2 _duplicateLine;
  final double circleRadius;
  List<DraggableDot> dots = [];
  bool isActive = false;
  bool _isDragging = false;

  late Vector2 _controlPoint1;
  late Vector2 _controlPoint2;

  late Paint _activePaint;
  late Paint _inactivePaint;

  LineDrawerComponentV2({required this.lineModelV2, this.circleRadius = 8.0})
    : super(priority: 1);

  updatePaint() {
    _inactivePaint =
        Paint()
          ..color =
              lineModelV2.color?.withValues(alpha: lineModelV2.opacity) ??
              ColorManager.black.withValues(alpha: lineModelV2.opacity)
          ..strokeWidth = lineModelV2.thickness
          ..style = PaintingStyle.stroke;

    _activePaint =
        Paint()
          ..color =
              lineModelV2.color?.withValues(alpha: lineModelV2.opacity) ??
              ColorManager.black.withValues(alpha: lineModelV2.opacity)
          ..strokeWidth = lineModelV2.thickness
          ..style = PaintingStyle.stroke;
  }

  @override
  FutureOr<void> onLoad() {
    addToGameWidgetBuild(() {
      ref.listen(boardProvider, (previous, current) {
        _updateIsActive(current.selectedItemOnTheBoard);
      });
    });

    _duplicateLine = lineModelV2.clone();
    updatePaint();

    _duplicateLine.start = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: _duplicateLine.start,
    );
    _duplicateLine.end = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: _duplicateLine.end,
    );

    _initializeControlPoints();
    _createDots();

    zlog(data: "Line model data onLoad ${_duplicateLine.toJson()}");

    return super.onLoad();
  }

  void _initializeControlPoints() {
    final start = _duplicateLine.start;
    final end = _duplicateLine.end;

    final diff = end - start;
    if (_duplicateLine.controlPoint1 == null) {
      _controlPoint1 = start + diff / 3.0;
    } else {
      _controlPoint1 = SizeHelper.getBoardActualVector(
        gameScreenSize: game.gameField.size,
        actualPosition: _duplicateLine.controlPoint1!,
      );
    }

    if (_duplicateLine.controlPoint2 == null) {
      _controlPoint2 = start + diff * 2.0 / 3.0;
    } else {
      _controlPoint2 = SizeHelper.getBoardActualVector(
        gameScreenSize: game.gameField.size,
        actualPosition: _duplicateLine.controlPoint2!,
      );
    }

    zlog(
      data:
          "Initialized Control Points: CP1: $_controlPoint1, CP2: $_controlPoint2",
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    updatePaint();
  }

  // projectPointOnLineSegment (useful for hit detection)
  Vector2 projectPointOnLineSegment(
    Vector2 point,
    Vector2 lineStart,
    Vector2 lineEnd,
  ) {
    final segmentVector = lineEnd - lineStart;
    final segmentLengthSquared = segmentVector.length2;
    if (segmentLengthSquared < 0.000001) {
      return lineStart;
    }
    final pointVector = point - lineStart;
    double t = pointVector.dot(segmentVector) / segmentLengthSquared;
    t = t.clamp(0.0, 1.0);
    final closestPoint = lineStart + segmentVector * t;
    return closestPoint;
  }

  void _createDots() {
    // ... (check for control points initialization) ...
    dots.clear();
    dots = [
      // Start Dot (index 0)
      DraggableDot(
        dotIndex: 0,
        initialPosition: _duplicateLine.start,
        radius: circleRadius,
        onPositionChanged: (newPos) {
          _duplicateLine.start = newPos;
          // Call updateLine WITHOUT recalculating control points
          updateLine(); // Default recalculateControlPoints is false
        },
        canModifyLine: true,
        color: Colors.blue,
      ),
      // Control Point Dot 1 (index 1) - No change needed here
      DraggableDot(
        dotIndex: 1,
        initialPosition: _controlPoint1,
        // ... (rest is unchanged) ...
        onPositionChanged: (newPos) {
          _controlPoint1 = newPos;
          dots[1].position = _controlPoint1;
          updateLine();
        },
        // ...
      ),
      // Control Point Dot 2 (index 2) - No change needed here
      DraggableDot(
        dotIndex: 2,
        initialPosition: _controlPoint2,
        // ... (rest is unchanged) ...
        onPositionChanged: (newPos) {
          _controlPoint2 = newPos;
          dots[2].position = _controlPoint2;
          updateLine();
        },
        // ...
      ),
      // End Dot (index 3)
      DraggableDot(
        dotIndex: 3,
        initialPosition: _duplicateLine.end,
        radius: circleRadius,
        onPositionChanged: (newPos) {
          _duplicateLine.end = newPos;
          // Call updateLine WITHOUT recalculating control points
          updateLine(); // Default recalculateControlPoints is false
        },
        canModifyLine: true,
        color: Colors.blue,
      ),
    ];
    // ... (logging) ...
  }

  void updateLine({bool recalculateControlPoints = false}) {
    // Added parameter
    final start = _duplicateLine.start;
    final end = _duplicateLine.end;

    // --- Only recalculate if requested ---
    if (recalculateControlPoints) {
      final diff = end - start;
      // Update the internal state based on current start/end
      // This keeps them at 1/3 and 2/3 along the straight line during initial creation.
      _controlPoint1 = start + diff / 3.0;
      _controlPoint2 = start + diff * 2.0 / 3.0;
    }
    // --- End conditional recalculation ---

    // Existing checks and updates:
    if (dots.length != 4) {
      if (dots.isNotEmpty) {
        zlog(
          data:
              "updateLine called but dots list has unexpected length: ${dots.length}",
        );
      }
    }

    if (dots.length == 4) {
      // Update visual positions based on current state (which may or may not have been recalculated)
      dots[0].position = start;
      dots[3].position = end;
      dots[1].position = _controlPoint1; // Uses current _controlPoint1
      dots[2].position = _controlPoint2; // Uses current _controlPoint2
    }

    // Update the public line model
    lineModelV2 = _duplicateLine.copyWith(
      start:
          SizeHelper.getBoardRelativeVector(
            gameScreenSize: game.gameField.size,
            actualPosition: start,
          ).clone(),
      end:
          SizeHelper.getBoardRelativeVector(
            gameScreenSize: game.gameField.size,
            actualPosition: end,
          ).clone(),
      controlPoint1:
          SizeHelper.getBoardRelativeVector(
            gameScreenSize: game.gameField.size,
            actualPosition: _controlPoint1,
          ).clone(),
      controlPoint2:
          SizeHelper.getBoardRelativeVector(
            gameScreenSize: game.gameField.size,
            actualPosition: _controlPoint2,
          ).clone(),
    );

    // Notify provider
    ref.read(boardProvider.notifier).updateLine(line: lineModelV2);
  }

  // --- MODIFIED: render ---
  @override
  void render(Canvas canvas) {
    final paint = isActive ? _activePaint : _inactivePaint;
    final start = _duplicateLine.start;
    final end = _duplicateLine.end;
    final cp1 = _controlPoint1;
    final cp2 = _controlPoint2;

    // --- Render based on Line Type ---
    switch (_duplicateLine.lineType) {
      case LineType.STRAIGHT_LINE:
        // Keep the smooth Catmull-Rom spline for the basic straight line
        final path = Path();
        path.moveTo(start.x, start.y);
        final p0 = start;
        final p1 = cp1;
        final p2 = cp2;
        final p3 = end;
        final p_minus_1 = p0;
        final p_plus_1 = p3;
        final handle1a = p0 + (p1 - p_minus_1) / 6.0;
        final handle1b = p1 - (p2 - p0) / 6.0;
        path.cubicTo(
          handle1a.x,
          handle1a.y,
          handle1b.x,
          handle1b.y,
          p1.x,
          p1.y,
        );
        final handle2a = p1 + (p2 - p0) / 6.0;
        final handle2b = p2 - (p3 - p1) / 6.0;
        path.cubicTo(
          handle2a.x,
          handle2a.y,
          handle2b.x,
          handle2b.y,
          p2.x,
          p2.y,
        );
        final handle3a = p2 + (p3 - p1) / 6.0;
        final handle3b = p3 - (p_plus_1 - p2) / 6.0;
        path.cubicTo(
          handle3a.x,
          handle3a.y,
          handle3b.x,
          handle3b.y,
          p3.x,
          p3.y,
        );
        canvas.drawPath(path, paint);
        break;

      case LineType.STRAIGHT_LINE_DASHED:
        // Draw dashes along each segment: start->cp1, cp1->cp2, cp2->end
        _drawDashedLine(canvas, start, cp1, paint);
        _drawDashedLine(canvas, cp1, cp2, paint);
        _drawDashedLine(canvas, cp2, end, paint);
        break;

      case LineType.STRAIGHT_LINE_ARROW:
        // Draw plain lines for first two segments, arrow on the last
        canvas.drawLine(start.toOffset(), cp1.toOffset(), paint);
        canvas.drawLine(cp1.toOffset(), cp2.toOffset(), paint);
        _drawStraightLineWithArrow(
          canvas,
          cp2,
          end,
          paint,
        ); // Arrow on last segment
        break;

      case LineType.STRAIGHT_LINE_ARROW_DOUBLE:
        _drawArrowHead(
          canvas,
          start, // Tip of the arrow remains at 'start'
          start - cp1, // REVERSED Direction: from 'cp1' towards 'start'
          paint,
        );
        // --- PROPOSED CHANGE END ---

        canvas.drawLine(
          start.toOffset(),
          cp1.toOffset(),
          paint,
        ); // Line segment 1

        canvas.drawLine(
          cp1.toOffset(),
          cp2.toOffset(),
          paint,
        ); // Line segment 2

        // This part is correct as per your clarification
        _drawStraightLineWithArrow(canvas, cp2, end, paint);

        break;

      case LineType.STRAIGHT_LINE_ZIGZAG:
        // Draw zig-zag along each segment
        _drawZigZagLine(canvas, start, cp1, paint);
        _drawZigZagLine(canvas, cp1, cp2, paint);
        _drawZigZagLine(canvas, cp2, end, paint);
        break;

      case LineType.STRAIGHT_LINE_ZIGZAG_ARROW:
        // Draw zig-zag for first two segments, zig-zag+arrow on the last
        _drawZigZagLine(canvas, start, cp1, paint);
        _drawZigZagLine(canvas, cp1, cp2, paint);
        _drawZigZagLineWithArrow(
          canvas,
          cp2,
          end,
          paint,
        ); // ZigZag + Arrow on last segment
        break;

      case LineType.RIGHT_TURN_ARROW:
        // This type ignores control points and draws the original corner turn
        _drawRightTurnArrow(canvas, start, end, paint);
        break;

      default:
        // Fallback for unknown types: draw piecewise linear
        final path = Path();
        path.moveTo(start.x, start.y);
        path.lineTo(cp1.x, cp1.y);
        path.lineTo(cp2.x, cp2.y);
        path.lineTo(end.x, end.y);
        canvas.drawPath(path, paint);
        break;
    }
  }
  // --- End MODIFIED render ---

  // --- NEW HELPER: _drawArrowHead (for double arrow) ---
  // Draws just the arrowhead at a given point 'p', pointing in 'direction'
  void _drawArrowHead(
    Canvas canvas,
    Vector2 p,
    Vector2 direction,
    Paint basePaint,
  ) {
    if (direction.length2 < 0.001) return; // Avoid issues with zero direction

    final arrowSize = _duplicateLine.thickness * 4;
    final angle = math.atan2(direction.y, direction.x);

    final path = Path();
    path.moveTo(
      p.x - arrowSize * math.cos(angle - math.pi / 6),
      p.y - arrowSize * math.sin(angle - math.pi / 6),
    );
    path.lineTo(p.x, p.y); // Tip of the arrow
    path.lineTo(
      p.x - arrowSize * math.cos(angle + math.pi / 6),
      p.y - arrowSize * math.sin(angle + math.pi / 6),
    );

    final arrowPaint =
        Paint()
          ..color =
              basePaint
                  .color // Use base color
          ..style = PaintingStyle.fill; // Use fill for visibility
    canvas.drawPath(path, arrowPaint);
  }
  // --- End NEW HELPER ---

  // Drawing helper methods (_drawDashedLine, etc.) remain the same
  // EXCEPT potentially needing minor adjustments if they strictly assume
  // they draw the *entire* visual element. Here, they are used segmentally.
  // Assuming they draw correctly between the given start/end is likely okay.
  // ... (keep all your _draw... methods exactly as they were) ...
  void _drawDashedLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
    // Added check for zero distance
    final distance = start.distanceTo(end);
    if (distance < 0.1) return;

    const dashWidth = 10.0;
    const dashSpace = 5.0;
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final numDashes = (distance / (dashWidth + dashSpace)).floor();
    final normalizedDirection = Vector2(dx, dy).normalized();

    for (int i = 0; i < numDashes; i++) {
      final startOffset =
          start + normalizedDirection * (i * (dashWidth + dashSpace));
      final endOffset =
          start +
          normalizedDirection * (i * (dashWidth + dashSpace) + dashWidth);
      // Clamp endOffset to not overshoot the actual 'end' point for this segment
      if (start.distanceToSquared(endOffset) > start.distanceToSquared(end) &&
          i > 0) {
        canvas.drawLine(startOffset.toOffset(), end.toOffset(), paint);
        break;
      } else {
        canvas.drawLine(startOffset.toOffset(), endOffset.toOffset(), paint);
      }
    }
    final remainingDistance = distance - numDashes * (dashWidth + dashSpace);
    if (remainingDistance > dashSpace) {
      // Only draw last bit if it's reasonably long
      final startOffset =
          start + normalizedDirection * (numDashes * (dashWidth + dashSpace));
      // Draw remaining part, but ensure it doesn't exceed 'end'
      final endOffset =
          start + normalizedDirection * distance; // Go exactly to end
      canvas.drawLine(startOffset.toOffset(), endOffset.toOffset(), paint);
    }
  }

  void _drawZigZagLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
    final distance = start.distanceTo(end);
    if (distance < 0.1) return;

    const amplitude = 5.0;
    const frequency = 10.0;
    const dashLength =
        10.0; // Note: This dashLength might look odd at segment joins

    // Simplified: Apply zig-zag only if segment is long enough
    if (distance < frequency) {
      canvas.drawLine(start.toOffset(), end.toOffset(), paint);
      return;
    }

    // --- Simplified ZigZag application for segments ---
    final zigZagNumSegments = (distance / frequency).floor();
    final zigZagDirection = (end - start).normalized();
    final perpendicular = Vector2(-zigZagDirection.y, zigZagDirection.x);

    var currentPoint = start;
    final path = Path()..moveTo(start.x, start.y); // Use path for zig-zag
    for (int i = 0; i < zigZagNumSegments; i++) {
      final nextPointOnLine = currentPoint + zigZagDirection * frequency;
      final midPoint = (currentPoint + nextPointOnLine) / 2;
      final zigZagOffset = perpendicular * amplitude * (i.isEven ? 1 : -1);
      final zigZagPoint = midPoint + zigZagOffset;

      path.lineTo(zigZagPoint.x, zigZagPoint.y);
      path.lineTo(nextPointOnLine.x, nextPointOnLine.y);
      currentPoint = nextPointOnLine;
    }
    // Connect the last zig-zag point to the actual end point
    path.lineTo(end.x, end.y);
    canvas.drawPath(path, paint);
  }

  void _drawZigZagLineWithArrow(
    Canvas canvas,
    Vector2 start,
    Vector2 end,
    Paint paint,
  ) {
    final distance = start.distanceTo(end);
    if (distance < 0.1) return;

    final arrowSize = _duplicateLine.thickness * 4;

    // Draw the zig-zag part first for the whole segment length
    // (Leaving space conceptually, though _drawZigZagLine doesn't reserve it now)
    _drawZigZagLine(canvas, start, end, paint);

    // Add arrowhead at the end, oriented by the segment direction
    _drawArrowHead(canvas, end, end - start, paint);
  }

  void _drawStraightLineWithArrow(
    Canvas canvas,
    Vector2 start,
    Vector2 end,
    Paint paint,
  ) {
    final distance = start.distanceTo(end);
    if (distance < 0.1) return;

    // Draw the line segment
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
    // Add arrowhead at the end
    _drawArrowHead(canvas, end, end - start, paint);
  }

  void _drawRightTurnArrow(
    Canvas canvas,
    Vector2 start,
    Vector2 end,
    Paint paint,
  ) {
    // This function remains unchanged and uses only start/end
    final arrowSize = _duplicateLine.thickness * 4;
    final corner = Vector2(end.x, start.y);
    if (start.distanceTo(corner) < 0.1 || corner.distanceTo(end) < 0.1) {
      _drawStraightLineWithArrow(canvas, start, end, paint); // Fallback
      return;
    }
    canvas.drawLine(start.toOffset(), corner.toOffset(), paint);
    canvas.drawLine(corner.toOffset(), end.toOffset(), paint);
    _drawArrowHead(
      canvas,
      end,
      end - corner,
      paint,
    ); // Arrow based on last segment
  }

  // Dragging the whole line logic (should be fine)
  @override
  void onDragStart(DragStartEvent event) {
    if (isActive &&
        !dots.any((dot) => dot.containsPoint(event.localPosition))) {
      if (containsLocalPoint(event.localPosition)) {
        _isDragging = true;
        event.continuePropagation = false;
        return;
      }
    }
    event.continuePropagation = true;
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isDragging) {
      final delta = event.localDelta;
      _duplicateLine.start += delta;
      _duplicateLine.end += delta;
      _controlPoint1 += delta;
      _controlPoint2 += delta;
      updateLine();
      event.continuePropagation = false;
    } else {
      event.continuePropagation = true;
      super.onDragUpdate(event);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (_isDragging) {
      _isDragging = false;
      event.continuePropagation = false;
    } else {
      event.continuePropagation = true;
      super.onDragEnd(event);
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (_isDragging) {
      _isDragging = false;
      event.continuePropagation = false;
    } else {
      event.continuePropagation = true;
      super.onDragCancel(event);
    }
  }

  // Tapping and Activation logic remains the same
  @override
  void onTapDown(TapDownEvent event) {
    if (isActive && dots.any((dot) => dot.containsPoint(event.localPosition))) {
      event.handled = false;
      return;
    }
    if (containsLocalPoint(event.localPosition)) {
      _toggleActive();
      event.handled = true;
      return;
    }
    event.handled = false;
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    if (isActive && dots.any((dot) => dot.containsPoint(event.localPosition))) {
      event.handled = false;
      return;
    }
    if (containsLocalPoint(event.localPosition)) {
      _toggleActive();
      event.handled = true;
      return;
    }
    event.handled = false;
  }

  void _toggleActive() {
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: lineModelV2);
  }

  void _updateIsActive(FieldItemModel? item) {
    final previouslyActive = isActive;
    isActive = item is LineModelV2 && item.id == lineModelV2.id;

    if (isActive && !previouslyActive) {
      if (!(_controlPoint1 is Vector2 && _controlPoint2 is Vector2)) {
        zlog(data: "Control points null on activation, re-initializing.");
        _initializeControlPoints();
      }
      _createDots();
      addAll(dots);
      zlog(
        data:
            "Line ${lineModelV2.id} Activated. Added ${dots.length} dots. CP1: $_controlPoint1, CP2: $_controlPoint2",
      );
    } else if (!isActive && previouslyActive) {
      try {
        zlog(
          data:
              "Line ${lineModelV2.id} Deactivated. Removing ${dots.length} dots.",
        );
        if (dots.isNotEmpty) {
          removeAll(dots);
          dots.clear();
        }
      } catch (e, s) {
        zlog(data: "Error removing dots: $e \n$s");
      }
    }
  }

  // containsLocalPoint method (still checks distance to the conceptual segments)
  @override
  bool containsLocalPoint(Vector2 point) {
    // Right turn arrow has different geometry, handle it separately
    if (_duplicateLine.lineType == LineType.RIGHT_TURN_ARROW) {
      final hitAreaWidth = math.max(
        circleRadius * 1.5,
        _duplicateLine.thickness * 2.0,
      );
      final p1 = _duplicateLine.start;
      final p3 = _duplicateLine.end;
      final p2 = Vector2(p3.x, p1.y); // Corner point
      if (_distanceToSegment(point, p1, p2) < hitAreaWidth ||
          _distanceToSegment(point, p2, p3) < hitAreaWidth) {
        return true;
      }
      return false;
    }

    // For all other lines (including bent ones), check the 3 segments
    final hitAreaWidth = math.max(
      circleRadius * 1.5,
      _duplicateLine.thickness * 2.0,
    );
    final p1 = _duplicateLine.start;
    final p2 = _controlPoint1;
    final p3 = _controlPoint2;
    final p4 = _duplicateLine.end;
    if (_distanceToSegment(point, p1, p2) < hitAreaWidth ||
        _distanceToSegment(point, p2, p3) < hitAreaWidth ||
        _distanceToSegment(point, p3, p4) < hitAreaWidth) {
      return true;
    }
    return false;
  }

  double _distanceToSegment(Vector2 p, Vector2 a, Vector2 b) {
    final l2 = a.distanceToSquared(b);
    if (l2 == 0.0) return p.distanceTo(a);
    final t = ((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / l2;
    final clampedT = t.clamp(0.0, 1.0);
    final projection = a + (b - a) * clampedT;
    return p.distanceTo(projection);
  }

  // updateEnd function is kept as requested
  void updateEnd(Vector2 currentPoint) {
    _duplicateLine.end = currentPoint;
  }
}
