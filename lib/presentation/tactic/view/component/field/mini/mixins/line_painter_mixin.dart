// // --- Mixin for Line Drawing ---
// import 'dart:math' as math;
// import 'dart:ui';
//
// import 'package:flame/components.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
//
// mixin LinePainterMixin {
//   // // This mixin will need access to logicalFieldSize from the class it's mixed into.
//   // // We assume 'this' refers to an instance of MiniGameFieldPainter or a class with similar properties.
//   // Vector2
//   // get logicalFieldSize; // Abstract getter to be implemented by the class using the mixin
//
//   void drawLineItem({
//     required LineModelV2 object,
//     required Canvas canvas,
//     required Size visualLineSize, // Full canvas size
//     required Vector2 logicalFieldSize,
//   }) {
//     final paint =
//         Paint()
//           ..color =
//               object.color ??
//               ColorManager.black.withAlpha(
//                 (object.opacity ?? 1 * 255).round().clamp(0, 255),
//               )
//           ..strokeWidth = object.thickness.clamp(0.5, 50.0)
//           ..style = PaintingStyle.stroke
//           ..strokeCap = StrokeCap.round
//           ..strokeJoin = StrokeJoin.round;
//
//     final Vector2 start =
//         SizeHelper.getBoardActualVector(
//           gameScreenSize: logicalFieldSize,
//           actualPosition: object.start,
//         ) *
//         (visualLineSize.width / logicalFieldSize.x);
//
//     final Vector2 end =
//         SizeHelper.getBoardActualVector(
//           gameScreenSize: logicalFieldSize,
//           actualPosition: object.end,
//         ) *
//         (visualLineSize.width / logicalFieldSize.x);
//
//     final Vector2 cp1, cp2;
//     final Vector2 diff = end - start;
//
//     if (object.controlPoint1 == null) {
//       cp1 = start + diff / 3.0;
//     } else {
//       cp1 =
//           SizeHelper.getBoardActualVector(
//             gameScreenSize: logicalFieldSize,
//             actualPosition: object.controlPoint1!,
//           ) *
//           (visualLineSize.width / logicalFieldSize.x);
//     }
//
//     if (object.controlPoint2 == null) {
//       cp2 = start + diff * 2.0 / 3.0;
//     } else {
//       cp2 =
//           SizeHelper.getBoardActualVector(
//             gameScreenSize: logicalFieldSize,
//             actualPosition: object.controlPoint2!,
//           ) *
//           (visualLineSize.width / logicalFieldSize.x);
//     }
//
//     switch (object.lineType) {
//       case LineType.STRAIGHT_LINE:
//         final path = Path();
//         path.moveTo(start.x, start.y);
//         final p0 = start;
//         final p1 = cp1;
//         final p2 = cp2;
//         final p3 = end;
//         final p_minus_1 = p0;
//         final p_plus_1 = p3;
//         final handle1a = p0 + (p1 - p_minus_1) / 6.0;
//         final handle1b = p1 - (p2 - p0) / 6.0;
//         path.cubicTo(
//           handle1a.x,
//           handle1a.y,
//           handle1b.x,
//           handle1b.y,
//           p1.x,
//           p1.y,
//         );
//         final handle2a = p1 + (p2 - p0) / 6.0;
//         final handle2b = p2 - (p3 - p1) / 6.0;
//         path.cubicTo(
//           handle2a.x,
//           handle2a.y,
//           handle2b.x,
//           handle2b.y,
//           p2.x,
//           p2.y,
//         );
//         final handle3a = p2 + (p3 - p1) / 6.0;
//         final handle3b = p3 - (p_plus_1 - p2) / 6.0;
//         path.cubicTo(
//           handle3a.x,
//           handle3a.y,
//           handle3b.x,
//           handle3b.y,
//           p3.x,
//           p3.y,
//         );
//         zlog(
//           data:
//               "Drew Catmull-Rom for STRAIGHT_LINE: Path defined, check visual output.",
//         );
//         canvas.drawPath(path, paint);
//         break;
//       case LineType.STRAIGHT_LINE_DASHED:
//         _drawDashedLine(canvas, start, cp1, paint);
//         _drawDashedLine(canvas, cp1, cp2, paint);
//         _drawDashedLine(canvas, cp2, end, paint);
//         break;
//       case LineType.STRAIGHT_LINE_ARROW:
//         canvas.drawLine(start.toOffset(), cp1.toOffset(), paint);
//         canvas.drawLine(cp1.toOffset(), cp2.toOffset(), paint);
//         _drawStraightLineWithArrow(canvas, object, cp2, end, paint);
//         break;
//       case LineType.STRAIGHT_LINE_ARROW_DOUBLE:
//         _drawArrowHead(canvas, object, start, start - cp1, paint);
//         canvas.drawLine(start.toOffset(), cp1.toOffset(), paint);
//         canvas.drawLine(cp1.toOffset(), cp2.toOffset(), paint);
//         _drawStraightLineWithArrow(canvas, object, cp2, end, paint);
//         break;
//       case LineType.STRAIGHT_LINE_ZIGZAG:
//         _drawZigZagLine(canvas, start, cp1, paint);
//         _drawZigZagLine(canvas, cp1, cp2, paint);
//         _drawZigZagLine(canvas, cp2, end, paint);
//         break;
//       case LineType.STRAIGHT_LINE_ZIGZAG_ARROW:
//         _drawZigZagLine(canvas, start, cp1, paint);
//         _drawZigZagLine(canvas, cp1, cp2, paint);
//         _drawZigZagLineWithArrow(canvas, object, cp2, end, paint);
//         break;
//       case LineType.RIGHT_TURN_ARROW:
//         _drawRightTurnArrow(canvas, object, start, end, paint);
//         break;
//       default:
//         final path = Path();
//         path.moveTo(start.x, start.y);
//         path.lineTo(cp1.x, cp1.y);
//         path.lineTo(cp2.x, cp2.y);
//         path.lineTo(end.x, end.y);
//         canvas.drawPath(path, paint);
//         break;
//     }
//   }
//
//   // Helper methods for line drawing (part of _LinePainterMixin)
//   void _drawArrowHead(
//     Canvas canvas,
//     LineModelV2 object,
//     Vector2 tip,
//     Vector2 direction,
//     Paint basePaint,
//   ) {
//     if (direction.length2 < 0.001) return;
//     final double arrowSize = object.thickness * 4;
//     final double angle = math.atan2(direction.y, direction.x);
//     final path = Path();
//     path.moveTo(
//       tip.x - arrowSize * math.cos(angle - math.pi / 6),
//       tip.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     path.lineTo(tip.x, tip.y);
//     path.lineTo(
//       tip.x - arrowSize * math.cos(angle + math.pi / 6),
//       tip.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//     final arrowPaint =
//         Paint()
//           ..color = basePaint.color
//           ..style = PaintingStyle.fill;
//     canvas.drawPath(path, arrowPaint);
//   }
//
//   void _drawDashedLine(
//     Canvas canvas,
//     Vector2 pStart,
//     Vector2 pEnd,
//     Paint paint,
//   ) {
//     final distance = pStart.distanceTo(pEnd);
//     if (distance < 0.1) {
//       if (distance > 0.01)
//         canvas.drawLine(pStart.toOffset(), pEnd.toOffset(), paint);
//       return;
//     }
//     const double dashWidth = 7.0;
//     const double dashSpace = 4.0;
//     final double segmentLength = dashWidth + dashSpace;
//     final dx = pEnd.x - pStart.x;
//     final dy = pEnd.y - pStart.y;
//     final int numDashes = (distance / segmentLength).floor();
//     final Vector2 normalizedDirection = Vector2(dx, dy).normalized();
//     for (int i = 0; i < numDashes; i++) {
//       final currentStart = pStart + normalizedDirection * (i * segmentLength);
//       final currentEnd = currentStart + normalizedDirection * dashWidth;
//       canvas.drawLine(currentStart.toOffset(), currentEnd.toOffset(), paint);
//     }
//     final double coveredDistance = numDashes * segmentLength;
//     if (distance - coveredDistance > 0.01) {
//       final lastDashStart = pStart + normalizedDirection * coveredDistance;
//       final remainingLength = distance - coveredDistance;
//       final lastDashEnd =
//           lastDashStart +
//           normalizedDirection * math.min(remainingLength, dashWidth);
//       canvas.drawLine(lastDashStart.toOffset(), lastDashEnd.toOffset(), paint);
//     }
//   }
//
//   void _drawZigZagLine(
//     Canvas canvas,
//     Vector2 pStart,
//     Vector2 pEnd,
//     Paint paint,
//   ) {
//     final distance = pStart.distanceTo(pEnd);
//     if (distance < 1.0) {
//       canvas.drawLine(pStart.toOffset(), pEnd.toOffset(), paint);
//       return;
//     }
//     const double amplitude = 4.0;
//     const double waveLength = 10.0;
//     final int numWaves = (distance / waveLength).floor();
//     if (numWaves < 1 && distance > 0.1) {
//       canvas.drawLine(pStart.toOffset(), pEnd.toOffset(), paint);
//       return;
//     }
//     if (numWaves == 0) return;
//     final Vector2 direction = (pEnd - pStart).normalized();
//     final Vector2 perpendicular = Vector2(-direction.y, direction.x);
//     final Path path = Path();
//     path.moveTo(pStart.x, pStart.y);
//     Vector2 currentPoint = pStart;
//     for (int i = 0; i < numWaves; i++) {
//       final p1 =
//           currentPoint +
//           direction * (waveLength / 2) +
//           perpendicular * amplitude * (i.isEven ? 1 : -1);
//       final p2 = currentPoint + direction * waveLength;
//       path.lineTo(p1.x, p1.y);
//       path.lineTo(p2.x, p2.y);
//       currentPoint = p2;
//     }
//     if (currentPoint.distanceToSquared(pEnd) > 0.01) {
//       path.lineTo(pEnd.x, pEnd.y);
//     }
//     canvas.drawPath(path, paint);
//   }
//
//   void _drawZigZagLineWithArrow(
//     Canvas canvas,
//     LineModelV2 object,
//     Vector2 pStart,
//     Vector2 pEnd,
//     Paint paint,
//   ) {
//     final distance = pStart.distanceTo(pEnd);
//     if (distance < 0.1) return;
//     _drawZigZagLine(canvas, pStart, pEnd, paint);
//     _drawArrowHead(canvas, object, pEnd, pEnd - pStart, paint);
//   }
//
//   void _drawStraightLineWithArrow(
//     Canvas canvas,
//     LineModelV2 object,
//     Vector2 pStart,
//     Vector2 pEnd,
//     Paint paint,
//   ) {
//     final distance = pStart.distanceTo(pEnd);
//     if (distance < 0.1) return;
//     canvas.drawLine(pStart.toOffset(), pEnd.toOffset(), paint);
//     _drawArrowHead(canvas, object, pEnd, pEnd - pStart, paint);
//   }
//
//   void _drawRightTurnArrow(
//     Canvas canvas,
//     LineModelV2 object,
//     Vector2 pStart,
//     Vector2 pEnd,
//     Paint paint,
//   ) {
//     final corner = Vector2(pEnd.x, pStart.y);
//     if (pStart.distanceTo(corner) < 1.0 || corner.distanceTo(pEnd) < 1.0) {
//       _drawStraightLineWithArrow(canvas, object, pStart, pEnd, paint);
//       return;
//     }
//     canvas.drawLine(pStart.toOffset(), corner.toOffset(), paint);
//     canvas.drawLine(corner.toOffset(), pEnd.toOffset(), paint);
//     _drawArrowHead(canvas, object, pEnd, pEnd - corner, paint);
//   }
// }

// --- Mixin for Line Drawing ---
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';

mixin LinePainterMixin {
  void drawLineItem({
    required LineModelV2 object,
    required Canvas canvas,
    required Size visualLineSize,
    required Vector2 logicalFieldSize,
  }) {
    final paint = Paint()
      ..color = object.color ??
          ColorManager.black.withAlpha(
            (object.opacity ?? 1 * 255).round().clamp(0, 255),
          )
      ..strokeWidth = object.thickness.clamp(0.5, 50.0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // This coordinate transformation logic is correct and remains unchanged
    final Vector2 start = SizeHelper.getBoardActualVector(
          gameScreenSize: logicalFieldSize,
          actualPosition: object.start,
        ) *
        (visualLineSize.width / logicalFieldSize.x);

    final Vector2 end = SizeHelper.getBoardActualVector(
          gameScreenSize: logicalFieldSize,
          actualPosition: object.end,
        ) *
        (visualLineSize.width / logicalFieldSize.x);

    final Vector2 cp1, cp2;
    final Vector2 diff = end - start;

    if (object.controlPoint1 == null) {
      cp1 = start + diff / 3.0;
    } else {
      cp1 = SizeHelper.getBoardActualVector(
            gameScreenSize: logicalFieldSize,
            actualPosition: object.controlPoint1!,
          ) *
          (visualLineSize.width / logicalFieldSize.x);
    }

    if (object.controlPoint2 == null) {
      cp2 = start + diff * 2.0 / 3.0;
    } else {
      cp2 = SizeHelper.getBoardActualVector(
            gameScreenSize: logicalFieldSize,
            actualPosition: object.controlPoint2!,
          ) *
          (visualLineSize.width / logicalFieldSize.x);
    }

    // The Catmull-Rom path is used for solid, curved lines
    final splinePath = Path()
      ..moveTo(start.x, start.y)
      ..cubicTo(cp1.x, cp1.y, cp2.x, cp2.y, end.x, end.y);

    // --- NEW: Updated switch statement for semantic LineType enum ---
    switch (object.lineType) {
      case LineType.WALK_ONE_WAY:
      case LineType.JOG_ONE_WAY:
      case LineType.SPRINT_ONE_WAY:
        final dashPattern = _getDashPatternForType(object.lineType);
        _drawDashedLine(canvas, start, cp1, paint, dashPattern);
        _drawDashedLine(canvas, cp1, cp2, paint, dashPattern);
        _drawDashedLineWithArrow(canvas, object, cp2, end, paint, dashPattern);
        break;

      case LineType.WALK_TWO_WAY:
      case LineType.JOG_TWO_WAY:
      case LineType.SPRINT_TWO_WAY:
        final dashPattern = _getDashPatternForType(object.lineType);
        _drawDashedLineWithArrow(canvas, object, cp1, start, paint, dashPattern,
            isReversed: true);
        _drawDashedLine(canvas, cp1, cp2, paint, dashPattern);
        _drawDashedLineWithArrow(canvas, object, cp2, end, paint, dashPattern);
        break;

      case LineType.JUMP:
        final dashPattern = [4.0, 4.0]; // Jump specific dash pattern
        _drawDashedLine(canvas, start, cp1, paint, dashPattern);
        _drawDashedLine(canvas, cp1, cp2, paint, dashPattern);
        _drawDashedLineWithArrow(canvas, object, cp2, end, paint, dashPattern);
        break;

      case LineType.PASS:
      case LineType.PASS_HIGH_CROSS:
        canvas.drawPath(splinePath, paint);
        _drawArrowHead(canvas, object, end, end - cp2, paint);
        break;

      case LineType.SHOOT:
        final shootPaint = Paint.from(paint)..strokeWidth = object.thickness;
        canvas.drawPath(splinePath, shootPaint);
        _drawArrowHead(canvas, object, end, end - cp2, shootPaint);
        break;

      case LineType.DRIBBLE:
        _drawZigZagLine(canvas, start, cp1, paint);
        _drawZigZagLine(canvas, cp1, cp2, paint);
        _drawZigZagLineWithArrow(canvas, object, cp2, end, paint);
        break;

      default: // Handles UNKNOWN and any legacy types
        canvas.drawPath(splinePath, paint);
        break;
    }
  }

  // --- HELPER METHODS ---

  // New helper to get dash patterns, specific to this mixin
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
        return [5, 5]; // Default fallback
    }
  }

  void _drawDashedLineWithArrow(Canvas canvas, LineModelV2 object,
      Vector2 pStart, Vector2 pEnd, Paint paint, List<double> dashPattern,
      {bool isReversed = false}) {
    _drawDashedLine(canvas, pStart, pEnd, paint, dashPattern);
    final direction = isReversed ? (pStart - pEnd) : (pEnd - pStart);
    _drawArrowHead(
        canvas, object, isReversed ? pStart : pEnd, direction, paint);
  }

  // Your existing helper methods are used below. They are mostly fine but
  // I've added the dashPattern parameter to _drawDashedLine.

  void _drawArrowHead(
    Canvas canvas,
    LineModelV2 object,
    Vector2 tip,
    Vector2 direction,
    Paint basePaint,
  ) {
    if (direction.length2 < 0.001) return;
    final double arrowSize = basePaint.strokeWidth * 3.0; // Adjusted size
    final double angle = math.atan2(direction.y, direction.x);
    final double arrowAngle = 25 * (math.pi / 180);

    final path = Path()
      ..moveTo(tip.x, tip.y)
      ..lineTo(tip.x - arrowSize * math.cos(angle - arrowAngle),
          tip.y - arrowSize * math.sin(angle - arrowAngle))
      ..moveTo(tip.x, tip.y)
      ..lineTo(tip.x - arrowSize * math.cos(angle + arrowAngle),
          tip.y - arrowSize * math.sin(angle + arrowAngle));

    canvas.drawPath(path, basePaint); // Draw with the line's paint
  }

  void _drawDashedLine(
    Canvas canvas,
    Vector2 pStart,
    Vector2 pEnd,
    Paint paint,
    List<double> dashPattern, // Now takes a pattern
  ) {
    final distance = pStart.distanceTo(pEnd);
    if (distance < 0.1) return;

    final double dashWidth = dashPattern[0];
    final double dashSpace = dashPattern[1];
    final double segmentLength = dashWidth + dashSpace;
    if (segmentLength <= 0) return;

    final int numDashes = (distance / segmentLength).floor();
    final Vector2 normalizedDirection = (pEnd - pStart).normalized();

    for (int i = 0; i < numDashes; i++) {
      final currentStart = pStart + normalizedDirection * (i * segmentLength);
      final currentEnd = currentStart + normalizedDirection * dashWidth;
      canvas.drawLine(currentStart.toOffset(), currentEnd.toOffset(), paint);
    }
    // Draw any remaining partial dash
    final double coveredDistance = numDashes * segmentLength;
    if (distance > coveredDistance) {
      final lastDashStart = pStart + normalizedDirection * coveredDistance;
      canvas.drawLine(lastDashStart.toOffset(), pEnd.toOffset(), paint);
    }
  }

  void _drawZigZagLine(
    Canvas canvas,
    Vector2 pStart,
    Vector2 pEnd,
    Paint paint,
  ) {
    // This helper remains the same as your provided code
    final distance = pStart.distanceTo(pEnd);
    if (distance < 1.0) {
      canvas.drawLine(pStart.toOffset(), pEnd.toOffset(), paint);
      return;
    }
    const double amplitude = 4.0;
    const double waveLength = 10.0;
    final int numWaves = (distance / waveLength).floor();
    if (numWaves < 1 && distance > 0.1) {
      canvas.drawLine(pStart.toOffset(), pEnd.toOffset(), paint);
      return;
    }
    if (numWaves == 0) return;
    final Vector2 direction = (pEnd - pStart).normalized();
    final Vector2 perpendicular = Vector2(-direction.y, direction.x);
    final Path path = Path();
    path.moveTo(pStart.x, pStart.y);
    Vector2 currentPoint = pStart;
    for (int i = 0; i < numWaves; i++) {
      final p1 = currentPoint +
          direction * (waveLength / 2) +
          perpendicular * amplitude * (i.isEven ? 1 : -1);
      final p2 = currentPoint + direction * waveLength;
      path.lineTo(p1.x, p1.y);
      path.lineTo(p2.x, p2.y);
      currentPoint = p2;
    }
    if (currentPoint.distanceToSquared(pEnd) > 0.01) {
      path.lineTo(pEnd.x, pEnd.y);
    }
    canvas.drawPath(path, paint);
  }

  void _drawZigZagLineWithArrow(
    Canvas canvas,
    LineModelV2 object,
    Vector2 pStart,
    Vector2 pEnd,
    Paint paint,
  ) {
    final distance = pStart.distanceTo(pEnd);
    if (distance < 0.1) return;
    _drawZigZagLine(canvas, pStart, pEnd, paint);
    _drawArrowHead(canvas, object, pEnd, pEnd - pStart, paint);
  }

// The straight line with arrow helper is no longer needed with the new structure
// and the right turn arrow is also deprecated.
}
