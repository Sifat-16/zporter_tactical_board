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
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
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

class LineDrawerComponentV2 extends PositionComponent
    with
        TapCallbacks,
        DragCallbacks,
        RiverpodComponentMixin,
        HasGameReference<TacticBoardGame> {
  // LineModel lineModel;
  LineModelV2 lineModelV2;
  late LineModelV2 _duplicateLine;
  final double circleRadius;
  List<DraggableDot> dots = [];
  bool isActive = false;
  bool _isDragging = false;

  // Store active/inactive paints
  late Paint _activePaint;
  late Paint _inactivePaint;

  LineDrawerComponentV2({
    // required this.lineModel,
    required this.lineModelV2,
    this.circleRadius = 8.0,
  }) : super(priority: 1) {
    // Initialize paints in the constructor
  }

  updatePaint() {
    _inactivePaint =
        Paint()
          ..color =
              _duplicateLine.color?.withValues(alpha: _duplicateLine.opacity) ??
              ColorManager.black.withValues(alpha: _duplicateLine.opacity)
          ..strokeWidth = _duplicateLine.thickness
          ..style = PaintingStyle.stroke;

    _activePaint =
        Paint()
          ..color =
              _duplicateLine.color?.withValues(alpha: _duplicateLine.opacity) ??
              ColorManager.black.withValues(alpha: _duplicateLine.opacity)
          ..strokeWidth = _duplicateLine.thickness
          ..strokeWidth =
              _duplicateLine.thickness +
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
    _createDots();

    zlog(data: "Line model data ${_duplicateLine.toJson()}");

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
        initialPosition: _duplicateLine.start,
        onPositionChanged: (newPos) {
          _duplicateLine.start = newPos;
          updateLine();
        },
      ),
      DraggableDot(
        initialPosition: _duplicateLine.end,
        onPositionChanged: (newPos) {
          _duplicateLine.end = newPos;
          updateLine();
        },
      ),
    ];
  }

  void updateLine() {
    dots[0].position = _duplicateLine.start;
    dots[1].position = _duplicateLine.end;
    lineModelV2 = _duplicateLine.copyWith(
      start:
          SizeHelper.getBoardRelativeVector(
            gameScreenSize: game.gameField.size,
            actualPosition: _duplicateLine.start,
          ).clone(),
      end:
          SizeHelper.getBoardRelativeVector(
            gameScreenSize: game.gameField.size,
            actualPosition: _duplicateLine.end,
          ).clone(),
    );
    ref.read(boardProvider.notifier).updateLine(line: lineModelV2);
    zlog(
      data:
          "Line model update called ${lineModelV2.start} - ${lineModelV2.end}",
    );
    // formModel.formItemModel = lineModel;
  }

  void updateEnd(Vector2 currentPoint) {
    _duplicateLine.end = currentPoint;
  }

  @override
  void render(Canvas canvas) {
    // Choose the correct paint based on isActive
    final paint = isActive ? _activePaint : _inactivePaint;

    if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_DASHED) {
      _drawDashedLine(canvas, _duplicateLine.start, _duplicateLine.end, paint);
    } else if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_ZIGZAG) {
      _drawZigZagLine(canvas, _duplicateLine.start, _duplicateLine.end, paint);
    } else if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_ZIGZAG_ARROW) {
      _drawZigZagLineWithArrow(
        canvas,
        _duplicateLine.start,
        _duplicateLine.end,
        paint,
      );
    } else if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_ARROW) {
      _drawStraightLineWithArrow(
        canvas,
        _duplicateLine.start,
        _duplicateLine.end,
        paint,
      );
    } else if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_ARROW_DOUBLE) {
      _drawStraightLineWithDoubleArrow(
        canvas,
        _duplicateLine.start,
        _duplicateLine.end,
        paint,
      );
    } else if (_duplicateLine.lineType == LineType.RIGHT_TURN_ARROW) {
      _drawRightTurnArrow(
        canvas,
        _duplicateLine.start,
        _duplicateLine.end,
        paint,
      );
    } else {
      canvas.drawLine(
        _duplicateLine.start.toOffset(),
        _duplicateLine.end.toOffset(),
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
    final arrowSize = _duplicateLine.thickness * 4;
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
    final arrowSize = _duplicateLine.thickness * 4;

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
    final arrowSize = _duplicateLine.thickness * 4;
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
    final arrowSize = _duplicateLine.thickness * 4;

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
      _duplicateLine.start += delta;
      _duplicateLine.end += delta;
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
        .toggleSelectItemEvent(fieldItemModel: _duplicateLine);
  }

  void _updateIsActive(FieldItemModel? item) {
    zlog(data: "Item type selected ${item.runtimeType}");
    if (item is LineModelV2 && item.id == _duplicateLine.id) {
      isActive = true;
      addAll(dots);
    } else {
      isActive = false;
      try {
        removeAll(dots);
      } catch (e) {}
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final start = _duplicateLine.start;
    final end = _duplicateLine.end;
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

class FreeDrawerComponentV2 extends PositionComponent
    with
        DragCallbacks,
        HasGameReference<TacticBoardGame>,
        RiverpodComponentMixin {
  FreeDrawModelV2 freeDrawModelV2;
  late FreeDrawModelV2 _duplicateDrawerModel;

  late final Paint _paint;

  FreeDrawerComponentV2({required this.freeDrawModelV2}) : super(priority: 3) {
    _paint =
        Paint()
          ..color = freeDrawModelV2.color ?? ColorManager.dark2
          ..strokeWidth = freeDrawModelV2.thickness
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
  }

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    _duplicateDrawerModel = freeDrawModelV2.clone();
    _duplicateDrawerModel.points =
        _duplicateDrawerModel.points
            .map(
              (e) => SizeHelper.getBoardActualVector(
                gameScreenSize: game.gameField.size,
                actualPosition: e,
              ),
            )
            .toList();
    return super.onLoad();
  }

  // Add a point to the drawing
  void addPoint(Vector2 point) {
    _duplicateDrawerModel.points.add(point);
    freeDrawModelV2.points.add(
      SizeHelper.getBoardRelativeVector(
        gameScreenSize: game.gameField.size,
        actualPosition: point,
      ),
    );

    zlog(data: "Free draw points ${freeDrawModelV2.points}");

    ref.read(boardProvider.notifier).updateFreeDraw(freeDraw: freeDrawModelV2);
  }

  @override
  void render(Canvas canvas) {
    // Draw the free-form line using the points in freeDrawModel
    for (int i = 0; i < _duplicateDrawerModel.points.length - 1; i++) {
      canvas.drawLine(
        _duplicateDrawerModel.points[i].toOffset(),
        _duplicateDrawerModel.points[i + 1].toOffset(),
        _paint,
      );
    }
  }
}
