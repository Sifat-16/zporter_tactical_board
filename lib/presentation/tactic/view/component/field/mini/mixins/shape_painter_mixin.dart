import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart'; // Assuming you use zlog
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart'; // Make sure this is correctly imported
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart';

mixin ShapePainterMixin {
  void _drawCircleShape(
    Canvas canvas,
    CircleShapeModel circle,
    Size
    visualItemSize, // This parameter is now less directly used for drawing if we recalculate
    Paint paintInstance,
    Size fieldSize, // Overall canvas size
  ) {
    // 1. Calculate actual screen radius
    double actualRadius = SizeHelper.getBoardActualDimension(
      gameScreenSize: fieldSize.toVector2(),
      relativeSize: circle.radius, // Logical radius
    );

    // 2. Calculate absolute screen center of the circle
    Vector2 centerOfCircle = SizeHelper.getBoardActualVector(
      gameScreenSize: fieldSize.toVector2(),
      actualPosition:
          circle.offset ?? Vector2.zero(), // Logical offset (center)
    );

    if (actualRadius <= 0) {
      zlog(
        data:
            "Circle ${circle.id}: Skipping drawing, actualRadius is $actualRadius",
      );
      return;
    }
    zlog(
      data:
          "Circle ${circle.id}: Drawing at ${centerOfCircle.toOffset()} with radius $actualRadius. Fill: ${circle.fillColor}, Stroke: ${circle.strokeColor}",
    );

    // Save canvas state if we are applying local rotation for this item
    bool didRotate = false;
    if (circle.angle != null && circle.angle != 0.0) {
      canvas.save();
      canvas.translate(centerOfCircle.x, centerOfCircle.y);
      canvas.rotate(
        circle.angle! * (math.pi / 180.0),
      ); // Assuming angle is in degrees
      canvas.translate(-centerOfCircle.x, -centerOfCircle.y);
      didRotate = true;
    }

    paintInstance
      ..color =
          circle.color?.withValues(alpha: circle.opacity ?? 1.0) ??
          ColorManager.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(centerOfCircle.toOffset(), actualRadius, paintInstance);
  }

  void _drawSquareShape(
    Canvas canvas,
    SquareShapeModel square,
    Size visualItemSize, // This parameter is now less directly used for drawing
    Paint paintInstance,
    Size fieldSize, // Overall canvas size
  ) {
    // 1. Calculate actual screen side length
    double sz = SizeHelper.getBoardActualDimension(
      gameScreenSize: fieldSize.toVector2(),
      relativeSize: square.side, // Logical side
    );

    // 2. Calculate absolute screen center of the square
    Vector2 centerOfSquare = SizeHelper.getBoardActualVector(
      gameScreenSize: fieldSize.toVector2(),
      actualPosition:
          square.offset ?? Vector2.zero(), // Logical offset (center)
    );

    if (sz <= 0) {
      zlog(
        data: "Square ${square.id}: Skipping drawing, actual side (sz) is $sz",
      );
      return;
    }
    zlog(
      data:
          "Square ${square.id}: Drawing at ${centerOfSquare.toOffset()} with side $sz. Fill: ${square.fillColor}, Stroke: ${square.strokeColor}",
    );

    final Rect rect = Rect.fromCenter(
      center: centerOfSquare.toOffset(),
      width: sz,
      height: sz,
    );

    // Save canvas state if we are applying local rotation for this item
    bool didRotate = false;
    if (square.angle != null && square.angle != 0.0) {
      canvas.save();
      canvas.translate(centerOfSquare.x, centerOfSquare.y);
      canvas.rotate(
        square.angle! * (math.pi / 180.0),
      ); // Assuming angle is in degrees
      canvas.translate(
        -centerOfSquare.x,
        -centerOfSquare.y,
      ); // Translate back after rotating around origin
      didRotate = true;
    }

    // Fill
    if (square.fillColor != null) {
      paintInstance
        ..color = square.fillColor!.withOpacity(
          square.opacity ?? 1.0,
        ) // Corrected: use withOpacity
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, paintInstance);
    }

    // Stroke (using square.strokeColor accessor for square.color)
    if (square.strokeColor != null && square.strokeWidth > 0) {
      paintInstance
        ..color = square.strokeColor!.withOpacity(
          square.opacity ?? 1.0,
        ) // Corrected: use withOpacity
        ..style = PaintingStyle.stroke
        ..strokeWidth = square.strokeWidth;
      canvas.drawRect(rect, paintInstance);
    }
  }

  void _drawPolygonShape(
    Canvas canvas,
    PolygonShapeModel polygon, // Strongly typed
    Size
    visualItemSize, // This parameter is now less directly used for path construction
    Paint paintInstance,
    Size fieldSize, // Overall canvas size
    double
    overallItemScale, // For scaling relative vertices (logical size to screen size)
  ) {
    final List<Vector2> relativeLogicalVertices = polygon.relativeVertices;
    if (relativeLogicalVertices.isEmpty) {
      zlog(data: "Polygon ${polygon.id}: No vertices to draw.");
      return;
    }

    // 1. Calculate the absolute screen position of the polygon's anchor/offset
    Vector2 absoluteAnchorPoint = SizeHelper.getBoardActualVector(
      gameScreenSize: fieldSize.toVector2(),
      actualPosition:
          polygon.offset ?? Vector2.zero(), // Logical offset of the polygon
    );
    zlog(
      data:
          "Polygon ${polygon.id}: Drawing with anchor ${absoluteAnchorPoint}. Vertices count: ${relativeLogicalVertices.length}. Fill: ${polygon.fillColor}, Stroke: ${polygon.strokeColor}",
    );

    // Save canvas state if we are applying local rotation for this item
    // Rotation will be around the absoluteAnchorPoint
    bool didRotate = false;
    if (polygon.angle != null && polygon.angle != 0.0) {
      canvas.save();
      canvas.translate(absoluteAnchorPoint.x, absoluteAnchorPoint.y);
      canvas.rotate(
        polygon.angle! * (math.pi / 180.0),
      ); // Assuming angle is in degrees
      // Note: Vertices will be drawn relative to this new rotated origin (which was absoluteAnchorPoint)
      // So, they should NOT have absoluteAnchorPoint added to them again after this transform.
      didRotate = true;
    }

    // 2. Scale logical relative vertices to screen pixel offsets *from the anchor*
    // If rotated, these are now offsets from the *new (0,0)* which is the rotated anchor point
    final Path path = Path();
    if (relativeLogicalVertices.isNotEmpty) {
      // First vertex
      double startX = relativeLogicalVertices[0].x * overallItemScale;
      double startY = relativeLogicalVertices[0].y * overallItemScale;
      if (didRotate) {
        // If rotated, path is relative to new origin (the anchor point)
        path.moveTo(startX, startY);
      } else {
        // If not rotated, path is relative to original canvas, so add anchor point
        path.moveTo(
          absoluteAnchorPoint.x + startX,
          absoluteAnchorPoint.y + startY,
        );
      }

      // Subsequent vertices
      for (int i = 1; i < relativeLogicalVertices.length; i++) {
        double pointX = relativeLogicalVertices[i].x * overallItemScale;
        double pointY = relativeLogicalVertices[i].y * overallItemScale;
        if (didRotate) {
          path.lineTo(pointX, pointY);
        } else {
          path.lineTo(
            absoluteAnchorPoint.x + pointX,
            absoluteAnchorPoint.y + pointY,
          );
        }
      }

      if (relativeLogicalVertices.length >= 3) {
        path.close();
      }
    } else {}

    paintInstance
      ..color =
          polygon.color?.withValues(alpha: polygon.opacity ?? 1.0) ??
          ColorManager.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintInstance);
  }

  void drawShapeItem({
    required ShapeModel shape,
    required Canvas canvas,
    required Size
    visualItemSize, // Primarily for the transformation block in MiniGameFieldPainter, less so here
    required Paint itemPaint, // General paint instance
    required double
    overallItemScale, // For scaling logical units (like polygon vertices)
    required Size
    fieldSize, // Full canvas size for absolute positioning calculations
  }) {
    // The main canvas transformations in MiniGameFieldPainter (save/translate/rotate/restore for items)
    // are now effectively bypassed for positioning and rotation by these methods if they handle it themselves.
    // If these methods implement their own rotation based on shape.angle, then the MiniGameFieldPainter's
    // rotation for shape items might become redundant or could be removed for shapes.

    if (shape is CircleShapeModel) {
      _drawCircleShape(canvas, shape, visualItemSize, itemPaint, fieldSize);
    } else if (shape is SquareShapeModel) {
      _drawSquareShape(canvas, shape, visualItemSize, itemPaint, fieldSize);
    } else if (shape is PolygonShapeModel) {
      _drawPolygonShape(
        canvas,
        shape,
        visualItemSize,
        itemPaint,
        fieldSize,
        overallItemScale,
      );
    }
    // Add other shape types as needed
  }
}
