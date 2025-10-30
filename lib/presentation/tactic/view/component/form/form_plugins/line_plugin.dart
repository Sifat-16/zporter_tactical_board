

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

// UNCHANGED from your working code
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

  // UNCHANGED from your working code
  updatePaint() {
    _inactivePaint = Paint()
      ..color = lineModelV2.color?.withValues(alpha: lineModelV2.opacity) ??
          ColorManager.black.withValues(alpha: lineModelV2.opacity)
      ..strokeWidth = lineModelV2.thickness
      ..style = PaintingStyle.stroke;

    _activePaint = Paint()
      ..color = lineModelV2.color?.withValues(alpha: lineModelV2.opacity) ??
          ColorManager.black.withValues(alpha: lineModelV2.opacity)
      ..strokeWidth = lineModelV2.thickness
      ..style = PaintingStyle.stroke;
  }

  // UNCHANGED from your working code
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

    return super.onLoad();
  }

  // UNCHANGED from your working code
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
  }

  // UNCHANGED from your working code
  @override
  void update(double dt) {
    super.update(dt);
    updatePaint();
  }

  @override
  void render(Canvas canvas) {
    final paint = isActive ? _activePaint : _inactivePaint;
    final start = _duplicateLine.start;
    final end = _duplicateLine.end;
    final cp1 = _controlPoint1;
    final cp2 = _controlPoint2;

    // Using the Catmull-Rom logic from your original code for smooth curves
    final splinePath = Path();
    splinePath.moveTo(start.x, start.y);
    final p0 = start;
    final p1 = cp1;
    final p2 = cp2;
    final p3 = end;
    final p_minus_1 = p0;
    final p_plus_1 = p3;
    final handle1a = p0 + (p1 - p_minus_1) / 6.0;
    final handle1b = p1 - (p2 - p0) / 6.0;
    splinePath.cubicTo(
        handle1a.x, handle1a.y, handle1b.x, handle1b.y, p1.x, p1.y);
    final handle2a = p1 + (p2 - p0) / 6.0;
    final handle2b = p2 - (p3 - p1) / 6.0;
    splinePath.cubicTo(
        handle2a.x, handle2a.y, handle2b.x, handle2b.y, p2.x, p2.y);
    final handle3a = p2 + (p3 - p1) / 6.0;
    final handle3b = p3 - (p_plus_1 - p2) / 6.0;
    splinePath.cubicTo(
        handle3a.x, handle3a.y, handle3b.x, handle3b.y, p3.x, p3.y);

    switch (_duplicateLine.lineType) {
      case LineType.WALK_ONE_WAY:
      case LineType.JOG_ONE_WAY:
      case LineType.SPRINT_ONE_WAY:
        final dashPattern = _getDashPatternForType(_duplicateLine.lineType);
        _drawDashedLine(canvas, start, cp1, paint, dashPattern);
        _drawDashedLine(canvas, cp1, cp2, paint, dashPattern);
        _drawDashedLine(canvas, cp2, end, paint, dashPattern);
        _drawArrowHead(canvas, end, end - cp2, paint);
        break;

      case LineType.WALK_TWO_WAY:
      case LineType.JOG_TWO_WAY:
      case LineType.SPRINT_TWO_WAY:
        final dashPattern = _getDashPatternForType(_duplicateLine.lineType);
        _drawDashedLine(canvas, start, cp1, paint, dashPattern);
        _drawDashedLine(canvas, cp1, cp2, paint, dashPattern);
        _drawDashedLine(canvas, cp2, end, paint, dashPattern);
        _drawArrowHead(canvas, end, end - cp2, paint);
        _drawArrowHead(canvas, start, start - cp1, paint);
        break;

      case LineType.JUMP:
        final dashPattern = [4.0, 4.0];
        _drawDashedPath(canvas, splinePath, paint, dashPattern);
        _drawArrowHead(canvas, end, end - cp2, paint);
        break;

      case LineType
            .PASS: // MODIFIED: This now renders on its own as a solid line
        canvas.drawPath(splinePath, paint);
        _drawArrowHead(canvas, end, end - cp2, paint);
        break;

      case LineType
            .PASS_HIGH_CROSS: // NEW: This now has its own custom rendering logic
        // 1. Define the shadow's appearance
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.3) // Semi-transparent black
          ..strokeWidth = paint.strokeWidth // Same thickness as the line
          ..style = PaintingStyle.stroke;

        // 2. Draw the shadow path first, with a slight offset
        canvas.save();
        canvas.translate(2.0, 2.0); // Offset the shadow down and to the right
        _drawDashedPath(canvas, splinePath, shadowPaint, [8.0, 6.0]);
        canvas.restore();

        // 3. Draw the main dashed line on top of the shadow
        _drawDashedPath(canvas, splinePath, paint, [8.0, 6.0]);
        _drawArrowHead(canvas, end, end - cp2, paint);
        break;

      case LineType.SHOOT:
        final shootPaint = Paint.from(paint)
          ..strokeWidth = _duplicateLine.thickness;
        canvas.drawPath(splinePath, shootPaint);
        _drawArrowHead(canvas, end, end - cp2, shootPaint);
        break;

      case LineType.DRIBBLE:
        _drawZigZagLine(canvas, start, cp1, paint);
        _drawZigZagLine(canvas, cp1, cp2, paint);
        _drawZigZagLineWithArrow(canvas, cp2, end, paint);
        break;

      default:
        canvas.drawPath(splinePath, paint);
        break;
    }
  }

  // All helper methods below this point are unchanged
  List<double> _getDashPatternForType(LineType lineType) {
    switch (lineType) {
      case LineType.WALK_ONE_WAY:
      case LineType.WALK_TWO_WAY:
        return [5, 5];
      case LineType.JOG_ONE_WAY:
      case LineType.JOG_TWO_WAY:
        return [10, 5];
      case LineType.SPRINT_ONE_WAY:
      case LineType.SPRINT_TWO_WAY:
        return [2, 3];
      default:
        return [5, 5];
    }
  }

  void _drawDashedPath(
      Canvas canvas, Path path, Paint paint, List<double> dashArray) {
    final dest = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final len = dashArray[draw ? 0 : 1];
        if (draw) {
          dest.addPath(
              metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
      }
    }
    canvas.drawPath(dest, paint);
  }

  void _drawArrowHead(
      Canvas canvas, Vector2 p, Vector2 direction, Paint basePaint) {
    if (direction.length2 < 0.001) return;
    final arrowSize = _duplicateLine.thickness * 4;
    final angle = math.atan2(direction.y, direction.x);
    final path = Path()
      ..moveTo(p.x, p.y)
      ..lineTo(p.x - arrowSize * math.cos(angle - math.pi / 6),
          p.y - arrowSize * math.sin(angle - math.pi / 6))
      ..moveTo(p.x, p.y)
      ..lineTo(p.x - arrowSize * math.cos(angle + math.pi / 6),
          p.y - arrowSize * math.sin(angle + math.pi / 6));
    canvas.drawPath(path, basePaint..style = PaintingStyle.stroke);
  }

  void _drawDashedLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint,
      [List<double> dashPattern = const [10.0, 5.0]]) {
    final distance = start.distanceTo(end);
    if (distance < 0.1) return;
    final dashWidth = dashPattern[0];
    final dashSpace = dashPattern[1];
    final totalDashLength = dashWidth + dashSpace;
    if (totalDashLength <= 0) return;
    final numDashes = (distance / totalDashLength).floor();
    final normalizedDirection = (end - start).normalized();
    for (int i = 0; i < numDashes; i++) {
      final startOffset = start + normalizedDirection * (i * totalDashLength);
      final endOffset = startOffset + normalizedDirection * dashWidth;
      canvas.drawLine(startOffset.toOffset(), endOffset.toOffset(), paint);
    }
    final remainingDistance = distance - numDashes * totalDashLength;
    if (remainingDistance > 0.01) {
      final startOffset =
          start + normalizedDirection * (numDashes * totalDashLength);
      canvas.drawLine(startOffset.toOffset(), end.toOffset(), paint);
    }
  }

  void _drawZigZagLineWithArrow(
      Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
    _drawZigZagLine(canvas, start, end, paint);
    _drawArrowHead(canvas, end, end - start, paint);
  }

  void _drawZigZagLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
    final distance = start.distanceTo(end);
    if (distance < 10) {
      canvas.drawLine(start.toOffset(), end.toOffset(), paint);
      return;
    }
    const amplitude = 5.0;
    const frequency = 15.0;
    final zigZagCount = (distance / frequency).floor();
    final direction = (end - start).normalized();
    final perpendicular = Vector2(-direction.y, direction.x);
    var currentPoint = start;
    final path = Path()..moveTo(start.x, start.y);
    for (int i = 0; i < zigZagCount; i++) {
      final nextPointOnLine = currentPoint + direction * frequency;
      final midPoint = (currentPoint + nextPointOnLine) / 2;
      final zigZagOffset = perpendicular * amplitude * (i.isEven ? 1 : -1);
      final zigZagPoint = midPoint + zigZagOffset;
      path.lineTo(zigZagPoint.x, zigZagPoint.y);
      path.lineTo(nextPointOnLine.x, nextPointOnLine.y);
      currentPoint = nextPointOnLine;
    }
    path.lineTo(end.x, end.y);
    canvas.drawPath(path, paint);
  }

  void _createDots() {
    dots.clear();
    dots = [
      DraggableDot(
          dotIndex: 0,
          initialPosition: _duplicateLine.start,
          radius: circleRadius,
          onPositionChanged: (newPos) {
            _duplicateLine.start = newPos;
            updateLine();
          },
          canModifyLine: true,
          color: Colors.blue),
      DraggableDot(
          dotIndex: 1,
          initialPosition: _controlPoint1,
          onPositionChanged: (newPos) {
            _controlPoint1 = newPos;
            dots[1].position = _controlPoint1;
            updateLine();
          },
          color: Colors.blue,
          radius: circleRadius * .8),
      DraggableDot(
          dotIndex: 2,
          initialPosition: _controlPoint2,
          onPositionChanged: (newPos) {
            _controlPoint2 = newPos;
            dots[2].position = _controlPoint2;
            updateLine();
          },
          color: Colors.blue,
          radius: circleRadius * .8),
      DraggableDot(
          dotIndex: 3,
          initialPosition: _duplicateLine.end,
          radius: circleRadius,
          onPositionChanged: (newPos) {
            _duplicateLine.end = newPos;
            updateLine();
          },
          canModifyLine: true,
          color: Colors.blue),
    ];
  }

  void updateLine({bool recalculateControlPoints = false}) {
    final start = _duplicateLine.start;
    final end = _duplicateLine.end;

    if (recalculateControlPoints) {
      final diff = end - start;

      // Check if the line should be curved by default
      if (_duplicateLine.lineType == LineType.PASS_HIGH_CROSS ||
          _duplicateLine.lineType == LineType.JUMP) {
        // --- NEW & IMPROVED LOGIC for a smooth parabolic curve ---
        final midPoint = start + diff * 0.5;
        final perpendicular = Vector2(diff.y, -diff.x).normalized();
        final arcHeight = diff.length * 0.15;
        final quadraticControlPoint = midPoint + perpendicular * arcHeight;
        _controlPoint1 = start + (quadraticControlPoint - start) * (2 / 3);
        _controlPoint2 = end + (quadraticControlPoint - end) * (2 / 3);
      } else {
        // Original logic for all other straight lines
        _controlPoint1 = start + diff / 3.0;
        _controlPoint2 = start + diff * 2.0 / 3.0;
      }
    }

    if (dots.length == 4) {
      dots[0].position = start;
      dots[3].position = end;
      dots[1].position = _controlPoint1;
      dots[2].position = _controlPoint2;
    }

    lineModelV2 = _duplicateLine.copyWith(
      start: SizeHelper.getBoardRelativeVector(
          gameScreenSize: game.gameField.size, actualPosition: start),
      end: SizeHelper.getBoardRelativeVector(
          gameScreenSize: game.gameField.size, actualPosition: end),
      controlPoint1: SizeHelper.getBoardRelativeVector(
          gameScreenSize: game.gameField.size, actualPosition: _controlPoint1),
      controlPoint2: SizeHelper.getBoardRelativeVector(
          gameScreenSize: game.gameField.size, actualPosition: _controlPoint2),
    );

    WidgetsBinding.instance.addPostFrameCallback((t) {
      try {
        if (isMounted && ref.exists(boardProvider)) {
          ref.read(boardProvider.notifier).updateLine(line: lineModelV2);
        }
      } catch (e) {}
    });
  }

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
        _initializeControlPoints();
      }
      _createDots();
      addAll(dots);
    } else if (!isActive && previouslyActive) {
      try {
        if (dots.isNotEmpty) {
          removeAll(dots);
          dots.clear();
        }
      } catch (e, s) {
        zlog(data: "Error removing dots: $e \n$s");
      }
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
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

  void updateEnd(Vector2 currentPoint) {
    _duplicateLine.end = currentPoint;
  }
}
