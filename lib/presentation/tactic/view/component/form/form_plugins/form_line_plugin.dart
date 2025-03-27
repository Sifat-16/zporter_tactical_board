import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class DraggableDot extends CircleComponent with DragCallbacks {
  final Function(Vector2) onPositionChanged;
  final Vector2 initialPosition;

  DraggableDot({
    required this.onPositionChanged,
    required this.initialPosition,
    super.radius = 8.0,
    Color color = Colors.blue,
  }) : super(
         position: initialPosition,
         anchor: Anchor.center,
         paint: Paint()..color = color,
         priority: 2, // Higher priority
       );

  @override
  void onDragStart(DragStartEvent event) {
    event.continuePropagation = true;
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.add(event.localDelta);
    onPositionChanged(position);
    event.continuePropagation = true;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    event.continuePropagation = true;
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    event.continuePropagation = true;
    super.onDragCancel(event);
  }
}

class LineDrawerComponent extends PositionComponent
    with TapCallbacks, DragCallbacks, RiverpodComponentMixin {
  final LineModel lineModel;
  final FormModel formModel;
  final double circleRadius;
  List<DraggableDot> dots = [];
  bool isActive = false;
  bool _isDragging = false;

  // Store active/inactive paints
  late Paint _activePaint;
  late Paint _inactivePaint;

  LineDrawerComponent({
    required this.lineModel,
    required this.formModel,
    this.circleRadius = 8.0,
  }) : super(priority: 1) {
    _createDots();

    updatePaint();
    // Initialize paints in the constructor
  }

  updatePaint() {
    _inactivePaint =
        Paint()
          ..color =
              formModel.color?.withValues(alpha: formModel.opacity) ??
              ColorManager.black.withValues(alpha: formModel.opacity)
          ..strokeWidth = lineModel.thickness
          ..style = PaintingStyle.stroke;

    _activePaint =
        Paint()
          ..color =
              formModel.color?.withValues(alpha: formModel.opacity) ??
              ColorManager.black.withValues(alpha: formModel.opacity)
          ..strokeWidth = lineModel.thickness
          ..strokeWidth =
              lineModel.thickness +
              2.0 // Active thickness
          ..style = PaintingStyle.stroke;
  }

  @override
  FutureOr<void> onLoad() {
    addToGameWidgetBuild(() {
      ref.listen(boardProvider, (previous, current) {
        _updateIsActive(current.selectedItemOnTheBoard);
      });
    });

    // TODO: implement onLoad
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);

    updatePaint();
  }

  void _createDots() {
    dots = [
      DraggableDot(
        initialPosition: lineModel.start,
        onPositionChanged: (newPos) {
          lineModel.start = newPos;
          updateLine();
        },
      ),
      DraggableDot(
        initialPosition: lineModel.end,
        onPositionChanged: (newPos) {
          lineModel.end = newPos;
          updateLine();
        },
      ),
    ];
  }

  void updateLine() {
    dots[0].position = lineModel.start;
    dots[1].position = lineModel.end;
  }

  @override
  void render(Canvas canvas) {
    // Choose the correct paint based on isActive
    final paint = isActive ? _activePaint : _inactivePaint;

    if (lineModel.lineType == LineType.STRAIGHT_LINE_DASHED) {
      _drawDashedLine(canvas, lineModel.start, lineModel.end, paint);
    } else if (lineModel.lineType == LineType.STRAIGHT_LINE_ZIGZAG) {
      _drawZigZagLine(canvas, lineModel.start, lineModel.end, paint);
    } else if (lineModel.lineType == LineType.STRAIGHT_LINE_ZIGZAG_ARROW) {
      _drawZigZagLineWithArrow(canvas, lineModel.start, lineModel.end, paint);
    } else if (lineModel.lineType == LineType.STRAIGHT_LINE_ARROW) {
      _drawStraightLineWithArrow(canvas, lineModel.start, lineModel.end, paint);
    } else if (lineModel.lineType == LineType.STRAIGHT_LINE_ARROW_DOUBLE) {
      _drawStraightLineWithDoubleArrow(
        canvas,
        lineModel.start,
        lineModel.end,
        paint,
      );
    } else if (lineModel.lineType == LineType.RIGHT_TURN_ARROW) {
      _drawRightTurnArrow(canvas, lineModel.start, lineModel.end, paint);
    } else {
      canvas.drawLine(
        lineModel.start.toOffset(),
        lineModel.end.toOffset(),
        paint,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 5.0;

    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final distance = start.distanceTo(end);
    final numDashes = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < numDashes; i++) {
      final startOffset =
          start + Vector2(dx, dy) * (i * (dashWidth + dashSpace) / distance);
      final endOffset =
          start +
          Vector2(dx, dy) *
              ((i * (dashWidth + dashSpace) + dashWidth) / distance);
      canvas.drawLine(startOffset.toOffset(), endOffset.toOffset(), paint);
    }
  }

  void _drawZigZagLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
    const amplitude = 5.0; // Reduced for smaller zig-zags
    const frequency = 10.0; // More frequent zig-zags
    const dashLength = 10.0; // Length of the starting and ending dashes

    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final distance = start.distanceTo(end);

    // --- 1. Starting Dash ---
    final lineDirection = Vector2(dx, dy).normalized();
    final startDashEnd = start + lineDirection * dashLength;
    canvas.drawLine(start.toOffset(), startDashEnd.toOffset(), paint);

    // --- 2. Zig-Zag ---

    // Adjust the starting point and distance for the zig-zag
    final zigZagStart = startDashEnd;
    final zigZagEnd = end - lineDirection * dashLength;
    final zigZagDistance = zigZagStart.distanceTo(zigZagEnd);
    final zigZagNumSegments = (zigZagDistance / frequency).floor();
    final zigZagDx = zigZagEnd.x - zigZagStart.x;
    final zigZagDy = zigZagEnd.y - zigZagStart.y;

    var currentPoint = zigZagStart;

    for (int i = 0; i < zigZagNumSegments; i++) {
      final nextPoint =
          zigZagStart +
          Vector2(zigZagDx, zigZagDy) * ((i + 1) * frequency / zigZagDistance);
      final midPoint = (currentPoint + nextPoint) / 2;
      final perpendicular =
          Vector2(-zigZagDy, zigZagDx).normalized(); // Perpendicular to zig-zag
      final zigZagOffset = perpendicular * amplitude * (i.isEven ? 1 : -1);
      final zigZagPoint = midPoint + zigZagOffset;

      canvas.drawLine(currentPoint.toOffset(), zigZagPoint.toOffset(), paint);
      canvas.drawLine(zigZagPoint.toOffset(), nextPoint.toOffset(), paint);
      currentPoint = nextPoint;
    }
    // Connect to the end dash start point
    canvas.drawLine(currentPoint.toOffset(), zigZagEnd.toOffset(), paint);

    // --- 3. Ending Dash ---
    final endDashStart = end - lineDirection * dashLength;
    canvas.drawLine(endDashStart.toOffset(), end.toOffset(), paint);
  }

  void _drawZigZagLineWithArrow(
    Canvas canvas,
    Vector2 start,
    Vector2 end,
    Paint paint,
  ) {
    const amplitude = 5.0; // Reduced for smaller zig-zags
    const frequency = 10.0; // More frequent zig-zags
    final arrowSize = lineModel.thickness * 4;
    const dashLength = 10.0; // Length of the starting and ending dashes

    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final distance = start.distanceTo(end);

    // --- 1. Starting Dash ---
    final lineDirection = Vector2(dx, dy).normalized();
    final startDashEnd = start + lineDirection * dashLength;
    canvas.drawLine(start.toOffset(), startDashEnd.toOffset(), paint);

    // --- 2. Zig-Zag ---

    // Adjust the starting point and distance for the zig-zag
    final zigZagStart = startDashEnd;
    final zigZagEnd =
        end -
        lineDirection * (dashLength + arrowSize); //  Arrow size + end dash
    final zigZagDistance = zigZagStart.distanceTo(zigZagEnd);
    final zigZagNumSegments = (zigZagDistance / frequency).floor();
    final zigZagDx = zigZagEnd.x - zigZagStart.x;
    final zigZagDy = zigZagEnd.y - zigZagStart.y;

    var currentPoint = zigZagStart;

    for (int i = 0; i < zigZagNumSegments; i++) {
      final nextPoint =
          zigZagStart +
          Vector2(zigZagDx, zigZagDy) * ((i + 1) * frequency / zigZagDistance);
      final midPoint = (currentPoint + nextPoint) / 2;
      final perpendicular =
          Vector2(
            -zigZagDy,
            zigZagDx,
          ).normalized(); // Perpendicular to zig-zag segment
      final zigZagOffset = perpendicular * amplitude * (i.isEven ? 1 : -1);
      final zigZagPoint = midPoint + zigZagOffset;

      canvas.drawLine(currentPoint.toOffset(), zigZagPoint.toOffset(), paint);
      canvas.drawLine(zigZagPoint.toOffset(), nextPoint.toOffset(), paint);
      currentPoint = nextPoint;
    }
    // Connect the last zig-zag point to where the ending dash will start
    canvas.drawLine(currentPoint.toOffset(), zigZagEnd.toOffset(), paint);

    // --- 3. Ending Dash ---
    final endDashStart =
        end -
        lineDirection *
            (dashLength + arrowSize); // Calculate where dash should start
    canvas.drawLine(
      endDashStart.toOffset(),
      (end - lineDirection * arrowSize).toOffset(),
      paint,
    );

    // --- 4. Arrowhead ---
    final angle = math.atan2(dy, dx);
    final path = Path();

    // Adjust arrowhead position to be at the very end
    final arrowBase = end - lineDirection * arrowSize;

    path.moveTo(
      arrowBase.x - arrowSize * math.cos(angle - math.pi / 6),
      arrowBase.y - arrowSize * math.sin(angle - math.pi / 6),
    );
    path.lineTo(arrowBase.x, arrowBase.y); // Tip of the arrow at arrowBase
    path.lineTo(
      arrowBase.x - arrowSize * math.cos(angle + math.pi / 6),
      arrowBase.y - arrowSize * math.sin(angle + math.pi / 6),
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawStraightLineWithArrow(
    Canvas canvas,
    Vector2 start,
    Vector2 end,
    Paint paint,
  ) {
    final arrowSize = lineModel.thickness * 4;

    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final angle = math.atan2(dy, dx);

    // --- 1. Draw the line ---
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);

    // --- 2. Draw the Arrowhead ---
    final path = Path();
    // Adjust arrowhead position to be at the very end
    path.moveTo(
      end.x - arrowSize * math.cos(angle - math.pi / 6),
      end.y - arrowSize * math.sin(angle - math.pi / 6),
    );
    path.lineTo(end.x, end.y); // Tip of the arrow at the end point
    path.lineTo(
      end.x - arrowSize * math.cos(angle + math.pi / 6),
      end.y - arrowSize * math.sin(angle + math.pi / 6),
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawStraightLineWithDoubleArrow(
    Canvas canvas,
    Vector2 start,
    Vector2 end,
    Paint paint,
  ) {
    final arrowSize = lineModel.thickness * 4;
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final angle = math.atan2(dy, dx);

    // --- 1. Draw the line ---
    // Adjust line start and end points to accommodate arrowheads
    final lineDirection = Vector2(dx, dy).normalized();
    final lineStart = start + lineDirection * arrowSize;
    final lineEnd = end - lineDirection * arrowSize;
    canvas.drawLine(lineStart.toOffset(), lineEnd.toOffset(), paint);

    // --- 2. Draw the Arrowhead at the end ---
    final endPath = Path();
    endPath.moveTo(
      end.x - arrowSize * math.cos(angle - math.pi / 6),
      end.y - arrowSize * math.sin(angle - math.pi / 6),
    );
    endPath.lineTo(end.x, end.y);
    endPath.lineTo(
      end.x - arrowSize * math.cos(angle + math.pi / 6),
      end.y - arrowSize * math.sin(angle + math.pi / 6),
    );
    endPath.close();
    canvas.drawPath(endPath, paint);

    // --- 3. Draw the Arrowhead at the start ---
    final startPath = Path();
    startPath.moveTo(
      start.x + arrowSize * math.cos(angle - math.pi / 6),
      start.y + arrowSize * math.sin(angle - math.pi / 6),
    );
    startPath.lineTo(start.x, start.y);
    startPath.lineTo(
      start.x + arrowSize * math.cos(angle + math.pi / 6),
      start.y + arrowSize * math.sin(angle + math.pi / 6),
    );
    startPath.close();
    canvas.drawPath(startPath, paint);
  }

  void _drawRightTurnArrow(
    Canvas canvas,
    Vector2 start,
    Vector2 end,
    Paint paint,
  ) {
    final arrowSize = lineModel.thickness * 4;

    // 1.  Determine the direction of the corner point.
    final dx = end.x - start.x;
    final dy = end.y - start.y;

    // 2. Calculate the corner point (C) of the right-angled triangle
    final corner = Vector2(end.x, start.y);

    // 3. Draw the two line segments.

    // Draw the line from start to the corner.
    canvas.drawLine(start.toOffset(), corner.toOffset(), paint);

    // Calculate a point just before the end point to leave room for the arrowhead
    final lineDirection = (end - corner).normalized();
    final arrowBase = end - (lineDirection * arrowSize);
    // Draw the line from the corner to just before the arrowhead
    canvas.drawLine(corner.toOffset(), arrowBase.toOffset(), paint);

    // 4. Arrowhead Calculation and Drawing
    // Calculate angle for the arrowhead. We use the angle of the *second* line segment.
    final angle = math.atan2(end.y - corner.y, end.x - corner.x);

    final path = Path();
    path.moveTo(
      end.x - arrowSize * math.cos(angle - math.pi / 6),
      end.y - arrowSize * math.sin(angle - math.pi / 6),
    );
    path.lineTo(end.x, end.y); // Tip of the arrow
    path.lineTo(
      end.x - arrowSize * math.cos(angle + math.pi / 6),
      end.y - arrowSize * math.sin(angle + math.pi / 6),
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (isActive &&
        !dots.any((dot) => dot.containsPoint(event.localPosition))) {
      _isDragging = true;
      event.continuePropagation = true;
    }
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isDragging) {
      final delta = event.localDelta;
      lineModel.start += delta;
      lineModel.end += delta;
      updateLine();
      event.continuePropagation = true;
    }
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (_isDragging) {
      _isDragging = false;
      event.continuePropagation = true;
    }
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (_isDragging) {
      _isDragging = false;
      event.continuePropagation = true;
    }
    super.onDragCancel(event);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!children.any(
      (child) =>
          child is DraggableDot && child.containsPoint(event.localPosition),
    )) {
      _toggleActive();
    }
    event.handled = true;
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    if (!children.any(
      (child) =>
          child is DraggableDot && child.containsPoint(event.localPosition),
    )) {
      _toggleActive();
    }
    event.handled = true;
  }

  void _toggleActive() {
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: formModel);
  }

  void _updateIsActive(FieldItemModel? item) {
    zlog(data: "Item type selected ${item.runtimeType}");
    if (item is FormModel && item.id == formModel.id) {
      isActive = true;
      addAll(dots);
    } else {
      isActive = false;
      removeAll(dots);
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final start = lineModel.start;
    final end = lineModel.end;
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final t =
        ((point.x - start.x) * dx + (point.y - start.y) * dy) /
        (dx * dx + dy * dy);
    final clampT = t.clamp(0.0, 1.0).toDouble();
    final closestX = start.x + clampT * dx;
    final closestY = start.y + clampT * dy;
    final distance = Vector2(closestX, closestY).distanceTo(point);
    return distance < (circleRadius * 1.5);
  }
}

// --- FreeDrawerComponent ---

class FreeDrawerComponent extends Component with DragCallbacks {
  final FreeDrawModel freeDrawModel;
  late final Paint _paint; // Declare _paint here

  FreeDrawerComponent({required this.freeDrawModel}) : super(priority: 3) {
    // Initialize Paint object in constructor
    _paint =
        Paint()
          ..color = freeDrawModel.color
          ..strokeWidth = freeDrawModel.thickness
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
  }

  // Add a point to the drawing
  void addPoint(Vector2 point) {
    freeDrawModel.points.add(point);
  }

  // Update Free Draw model, if needed
  void updateLine() {
    //Currently no need of update for free draw
  }

  @override
  void render(Canvas canvas) {
    // Draw the free-form line using the points in freeDrawModel
    for (int i = 0; i < freeDrawModel.points.length - 1; i++) {
      canvas.drawLine(
        freeDrawModel.points[i].toOffset(),
        freeDrawModel.points[i + 1].toOffset(),
        _paint,
      );
    }
  }
}
