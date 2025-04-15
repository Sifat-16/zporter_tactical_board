///Line bending cubical

// import 'dart:async';
// import 'dart:math' as math;
//
// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flame_riverpod/flame_riverpod.dart';
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
//
// // DraggableDot class remains the same as your provided version
// class DraggableDot extends CircleComponent with DragCallbacks {
//   final Function(Vector2) onPositionChanged;
//   final Vector2 initialPosition;
//   final bool
//   canModifyLine; // This flag will now be used to differentiate handlers
//   final int dotIndex; // Added index for easier identification if needed
//
//   DraggableDot({
//     required this.onPositionChanged,
//     required this.initialPosition,
//     required this.dotIndex, // Pass index
//     this.canModifyLine = true,
//     super.radius = 8.0,
//     Color color = Colors.blue,
//   }) : super(
//          position: initialPosition,
//          anchor: Anchor.center,
//          paint: Paint()..color = color,
//          priority: 2, // Higher priority
//        );
//
//   Vector2? _dragStartLocalPosition; // To calculate delta reliably
//
//   @override
//   void onDragStart(DragStartEvent event) {
//     _dragStartLocalPosition = event.localPosition;
//     event.continuePropagation = true;
//     super.onDragStart(event);
//   }
//
//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     if (_dragStartLocalPosition != null) {
//       // Pass the potential new position based on delta
//       onPositionChanged(position + event.localDelta);
//     }
//     event.continuePropagation = true;
//   }
//
//   @override
//   void onDragEnd(DragEndEvent event) {
//     _dragStartLocalPosition = null;
//     event.continuePropagation = true;
//     super.onDragEnd(event);
//   }
//
//   @override
//   void onDragCancel(DragCancelEvent event) {
//     _dragStartLocalPosition = null;
//     event.continuePropagation = true;
//     super.onDragCancel(event);
//   }
// }
//
// class LineDrawerComponentV2 extends PositionComponent
//     with
//         TapCallbacks,
//         DragCallbacks,
//         RiverpodComponentMixin,
//         HasGameReference<TacticBoardGame> {
//   LineModelV2 lineModelV2;
//   late LineModelV2 _duplicateLine;
//   final double circleRadius;
//   List<DraggableDot> dots = [];
//   bool isActive = false;
//   bool _isDragging = false; // For dragging the whole line
//
//   // --- NEW: Control points for bending ---
//   // Use nullable to indicate they might not be "bent" yet or to reset.
//   // We will initialize them based on start/end.
//   late Vector2 _controlPoint1;
//   late Vector2 _controlPoint2;
//   // --- End NEW ---
//
//   late Paint _activePaint;
//   late Paint _inactivePaint;
//
//   LineDrawerComponentV2({required this.lineModelV2, this.circleRadius = 8.0})
//     : super(priority: 1);
//
//   // updatePaint method remains the same
//   updatePaint() {
//     _inactivePaint =
//         Paint()
//           ..color =
//               _duplicateLine.color?.withValues(alpha: _duplicateLine.opacity) ??
//               ColorManager.black.withValues(alpha: _duplicateLine.opacity)
//           ..strokeWidth = _duplicateLine.thickness
//           ..style = PaintingStyle.stroke;
//
//     _activePaint =
//         Paint()
//           ..color =
//               _duplicateLine.color?.withValues(alpha: _duplicateLine.opacity) ??
//               ColorManager.black.withValues(alpha: _duplicateLine.opacity)
//           ..strokeWidth = _duplicateLine.thickness
//           ..style = PaintingStyle.stroke;
//   }
//
//   @override
//   FutureOr<void> onLoad() {
//     addToGameWidgetBuild(() {
//       ref.listen(boardProvider, (previous, current) {
//         _updateIsActive(current.selectedItemOnTheBoard);
//       });
//     });
//
//     _duplicateLine = lineModelV2.clone();
//     updatePaint();
//
//     // Convert to absolute coordinates
//     _duplicateLine.start = SizeHelper.getBoardActualVector(
//       gameScreenSize: game.gameField.size,
//       actualPosition: _duplicateLine.start,
//     );
//     _duplicateLine.end = SizeHelper.getBoardActualVector(
//       gameScreenSize: game.gameField.size,
//       actualPosition: _duplicateLine.end,
//     );
//
//     // --- NEW: Initialize control points ---
//     _initializeControlPoints();
//     // --- End NEW ---
//
//     _createDots(); // Create dots using initial control points
//
//     zlog(data: "Line model data onLoad ${_duplicateLine.toJson()}");
//
//     return super.onLoad();
//   }
//
//   // --- NEW: Helper to initialize control points ---
//   void _initializeControlPoints() {
//     final start = _duplicateLine.start;
//     final end = _duplicateLine.end;
//     final diff = end - start;
//     // Default to 1/3 and 2/3 along the straight line
//     _controlPoint1 = start + diff / 3.0;
//     _controlPoint2 = start + diff * 2.0 / 3.0;
//     zlog(
//       data:
//           "Initialized Control Points: CP1: $_controlPoint1, CP2: $_controlPoint2",
//     );
//   }
//   // --- End NEW ---
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//     updatePaint(); // Keep updating paint if needed
//   }
//
//   // Project point function remains the same (unused by bending dots now)
//   Vector2 projectPointOnLineSegment(
//     Vector2 point,
//     Vector2 lineStart,
//     Vector2 lineEnd,
//   ) {
//     final segmentVector = lineEnd - lineStart;
//     final segmentLengthSquared = segmentVector.length2;
//     if (segmentLengthSquared < 0.000001) {
//       return lineStart;
//     }
//     final pointVector = point - lineStart;
//     double t = pointVector.dot(segmentVector) / segmentLengthSquared;
//     t = t.clamp(0.0, 1.0);
//     final closestPoint = lineStart + segmentVector * t;
//     return closestPoint;
//   }
//
//   void _createDots() {
//     // Ensure control points are initialized before creating dots
//     // They should be initialized in onLoad or _updateIsActive
//     if (!(_controlPoint1 is Vector2 && _controlPoint2 is Vector2)) {
//       zlog(
//         data:
//             "Warning: Control points not initialized in _createDots. Re-initializing.",
//       );
//       _initializeControlPoints();
//     }
//
//     dots.clear(); // Clear existing dots first
//
//     dots = [
//       // Start Dot (index 0) - Modifies line start
//       DraggableDot(
//         dotIndex: 0,
//         initialPosition: _duplicateLine.start,
//         radius: circleRadius,
//         onPositionChanged: (newPos) {
//           _duplicateLine.start = newPos;
//           // When start/end moves, control points currently stay fixed.
//           // If you want them to move proportionally, add logic here.
//           updateLine(); // Update line model and dot visual positions
//         },
//         canModifyLine: true,
//         color: Colors.blue,
//       ),
//
//       // --- MODIFIED: Control Point Dot 1 (index 1) ---
//       DraggableDot(
//         dotIndex: 1,
//         initialPosition: _controlPoint1, // Use control point position
//         radius: circleRadius * 0.8, // Smaller radius for control points
//         onPositionChanged: (newPos) {
//           // Update the internal control point state
//           _controlPoint1 = newPos;
//           // Directly update this dot's visual position
//           dots[1].position = _controlPoint1;
//           // *** DO NOT call updateLine() here ***
//           // Request redraw if needed, though Flame usually handles this
//           // markNeedsPaint(); // Or similar if available
//         },
//         canModifyLine: true,
//         color: Colors.red, // Different color for control points
//       ),
//
//       // --- MODIFIED: Control Point Dot 2 (index 2) ---
//       DraggableDot(
//         dotIndex: 2,
//         initialPosition: _controlPoint2, // Use control point position
//         radius: circleRadius * 0.8,
//         onPositionChanged: (newPos) {
//           // Update the internal control point state
//           _controlPoint2 = newPos;
//           // Directly update this dot's visual position
//           dots[2].position = _controlPoint2;
//           // *** DO NOT call updateLine() here ***
//         },
//         canModifyLine: true,
//         color: Colors.red, // Different color for control points
//       ),
//
//       // End Dot (index 3) - Modifies line end
//       DraggableDot(
//         dotIndex: 3,
//         initialPosition: _duplicateLine.end,
//         radius: circleRadius,
//         onPositionChanged: (newPos) {
//           _duplicateLine.end = newPos;
//           // When start/end moves, control points currently stay fixed.
//           updateLine(); // Update line model and dot visual positions
//         },
//         canModifyLine: true,
//         color: Colors.blue,
//       ),
//     ];
//     zlog(
//       data:
//           "Created ${dots.length} dots. CP1 Pos: ${dots[1].position}, CP2 Pos: ${dots[2].position}",
//     );
//   }
//
//   // --- MODIFIED: updateLine ---
//   // Called ONLY when start or end dots are moved, OR the whole line is dragged.
//   // It updates the visual positions of the dots based on the current state
//   // and notifies the provider about the start/end change.
//   void updateLine() {
//     if (dots.length != 4) {
//       zlog(
//         data:
//             "updateLine called but dots list has unexpected length: ${dots.length}",
//       );
//       return;
//     }
//
//     // 1. Update visual positions of start and end dots
//     dots[0].position = _duplicateLine.start;
//     dots[3].position = _duplicateLine.end;
//
//     // 2. Update visual positions of control point dots to match internal state
//     //    (Their internal state _controlPoint1/_controlPoint2 was updated directly on drag)
//     dots[1].position = _controlPoint1;
//     dots[2].position = _controlPoint2;
//
//     // 3. Update the public line model with relative coordinates (still only start/end)
//     lineModelV2 = _duplicateLine.copyWith(
//       start:
//           SizeHelper.getBoardRelativeVector(
//             gameScreenSize: game.gameField.size,
//             actualPosition: _duplicateLine.start,
//           ).clone(),
//       end:
//           SizeHelper.getBoardRelativeVector(
//             gameScreenSize: game.gameField.size,
//             actualPosition: _duplicateLine.end,
//           ).clone(),
//       // NOTE: We are NOT saving control point positions in LineModelV2
//       // If you need persistence, LineModelV2 would need to be extended.
//     );
//
//     // 4. Notify the provider
//     ref.read(boardProvider.notifier).updateLine(line: lineModelV2);
//     // zlog(data: "Line model updated via updateLine: ${lineModelV2.start} -> ${lineModelV2.end}");
//     // zlog(data: "Current Control Points: CP1: $_controlPoint1, CP2: $_controlPoint2");
//   }
//   // --- End MODIFIED ---
//
//   // --- MODIFIED: render ---
//   @override
//   void render(Canvas canvas) {
//     final paint = isActive ? _activePaint : _inactivePaint;
//     final start = _duplicateLine.start;
//     final end = _duplicateLine.end;
//
//     // --- Bending Logic ---
//     // Only apply bending render for specific line types (e.g., straight)
//     // For others, fall back to the original straight drawing logic for now.
//     bool canRenderBent = _duplicateLine.lineType == LineType.STRAIGHT_LINE;
//     // You could potentially add other types here if you implement curved drawing for them
//     // bool canRenderBent = [LineType.STRAIGHT_LINE, LineType.STRAIGHT_LINE_ARROW].contains(_duplicateLine.lineType);
//
//     if (canRenderBent) {
//       // Draw a cubic Bezier curve using the control points
//       final path = Path();
//       path.moveTo(start.x, start.y);
//       path.cubicTo(
//         _controlPoint1.x,
//         _controlPoint1.y, // Control point 1
//         _controlPoint2.x,
//         _controlPoint2.y, // Control point 2
//         end.x,
//         end.y, // End point
//       );
//       canvas.drawPath(path, paint);
//     } else {
//       // --- Fallback to original rendering for non-bendable types ---
//       // (Your existing logic for dashed, arrows, zig-zag, etc.)
//       // These will draw straight between start and end, ignoring control points.
//       if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_DASHED) {
//         _drawDashedLine(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_ZIGZAG) {
//         _drawZigZagLine(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType ==
//           LineType.STRAIGHT_LINE_ZIGZAG_ARROW) {
//         _drawZigZagLineWithArrow(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_ARROW) {
//         _drawStraightLineWithArrow(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType ==
//           LineType.STRAIGHT_LINE_ARROW_DOUBLE) {
//         _drawStraightLineWithDoubleArrow(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType == LineType.RIGHT_TURN_ARROW) {
//         _drawRightTurnArrow(canvas, start, end, paint);
//       } else {
//         // Default straight line (if type is unknown or basic straight but bending disabled)
//         canvas.drawLine(start.toOffset(), end.toOffset(), paint);
//       }
//     }
//
//     // Note: The DraggableDot components (children) are rendered automatically
//     // when isActive is true because they were added via addAll(dots).
//   }
//   // --- End MODIFIED ---
//
//   // Drawing helper methods (_drawDashedLine, etc.) remain the same
//   // ... (keep all your _draw... methods exactly as they were) ...
//   void _drawDashedLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
//     const dashWidth = 10.0;
//     const dashSpace = 5.0;
//
//     final dx = end.x - start.x;
//     final dy = end.y - start.y;
//     final distance = start.distanceTo(end);
//     if (distance == 0) return; // Avoid division by zero
//     final numDashes = (distance / (dashWidth + dashSpace)).floor();
//     final normalizedDirection = Vector2(dx, dy).normalized();
//
//     for (int i = 0; i < numDashes; i++) {
//       final startOffset =
//           start + normalizedDirection * (i * (dashWidth + dashSpace));
//       final endOffset =
//           start +
//           normalizedDirection * (i * (dashWidth + dashSpace) + dashWidth);
//       canvas.drawLine(startOffset.toOffset(), endOffset.toOffset(), paint);
//     }
//     // Optional: Draw a partial dash at the end if needed
//     final remainingDistance = distance - numDashes * (dashWidth + dashSpace);
//     if (remainingDistance > 0) {
//       final startOffset =
//           start + normalizedDirection * (numDashes * (dashWidth + dashSpace));
//       final endOffset =
//           start +
//           normalizedDirection *
//               (numDashes * (dashWidth + dashSpace) +
//                   math.min(remainingDistance, dashWidth));
//       canvas.drawLine(startOffset.toOffset(), endOffset.toOffset(), paint);
//     }
//   }
//
//   void _drawZigZagLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
//     const amplitude = 5.0; // Reduced for smaller zig-zags
//     const frequency = 10.0; // More frequent zig-zags
//     const dashLength = 10.0; // Length of the starting and ending dashes
//
//     final distance = start.distanceTo(end);
//     if (distance < 2 * dashLength) {
//       // Not enough space for dashes and zig-zag
//       canvas.drawLine(
//         start.toOffset(),
//         end.toOffset(),
//         paint,
//       ); // Draw straight line
//       return;
//     }
//
//     final lineDirection = (end - start).normalized();
//
//     // --- 1. Starting Dash ---
//     final startDashEnd = start + lineDirection * dashLength;
//     canvas.drawLine(start.toOffset(), startDashEnd.toOffset(), paint);
//
//     // --- 2. Zig-Zag ---
//     final zigZagStart = startDashEnd;
//     final zigZagEnd = end - lineDirection * dashLength;
//     final zigZagDistance = zigZagStart.distanceTo(zigZagEnd);
//
//     if (zigZagDistance < frequency) {
//       // Not enough space for even one zig-zag segment
//       canvas.drawLine(
//         zigZagStart.toOffset(),
//         zigZagEnd.toOffset(),
//         paint,
//       ); // Connect dashes
//     } else {
//       final zigZagNumSegments = (zigZagDistance / frequency).floor();
//       final zigZagDirection = (zigZagEnd - zigZagStart).normalized();
//       final perpendicular = Vector2(
//         -zigZagDirection.y,
//         zigZagDirection.x,
//       ); // Perpendicular
//
//       var currentPoint = zigZagStart;
//       for (int i = 0; i < zigZagNumSegments; i++) {
//         final nextPointOnLine = currentPoint + zigZagDirection * frequency;
//         final midPoint = (currentPoint + nextPointOnLine) / 2;
//         final zigZagOffset = perpendicular * amplitude * (i.isEven ? 1 : -1);
//         final zigZagPoint = midPoint + zigZagOffset;
//
//         canvas.drawLine(currentPoint.toOffset(), zigZagPoint.toOffset(), paint);
//         canvas.drawLine(
//           zigZagPoint.toOffset(),
//           nextPointOnLine.toOffset(),
//           paint,
//         );
//         currentPoint = nextPointOnLine;
//       }
//       // Connect the last zig-zag point to the end dash start point
//       canvas.drawLine(currentPoint.toOffset(), zigZagEnd.toOffset(), paint);
//     }
//
//     // --- 3. Ending Dash ---
//     canvas.drawLine(zigZagEnd.toOffset(), end.toOffset(), paint);
//   }
//
//   void _drawZigZagLineWithArrow(
//     Canvas canvas,
//     Vector2 start,
//     Vector2 end,
//     Paint paint,
//   ) {
//     const amplitude = 5.0;
//     const frequency = 10.0;
//     final arrowSize = _duplicateLine.thickness * 4;
//     const dashLength = 10.0;
//
//     final distance = start.distanceTo(end);
//     if (distance < (2 * dashLength + arrowSize)) {
//       // Not enough space
//       _drawStraightLineWithArrow(
//         canvas,
//         start,
//         end,
//         paint,
//       ); // Fallback to straight arrow
//       return;
//     }
//
//     final lineDirection = (end - start).normalized();
//
//     // --- 1. Starting Dash ---
//     final startDashEnd = start + lineDirection * dashLength;
//     canvas.drawLine(start.toOffset(), startDashEnd.toOffset(), paint);
//
//     // --- 2. Zig-Zag ---
//     final zigZagStart = startDashEnd;
//     // Adjust end point for zig-zag to leave space for end dash and arrow
//     final zigZagEnd = end - lineDirection * (dashLength + arrowSize);
//     final zigZagDistance = zigZagStart.distanceTo(zigZagEnd);
//
//     if (zigZagDistance < frequency) {
//       // Not enough space for zig-zag
//       canvas.drawLine(
//         zigZagStart.toOffset(),
//         zigZagEnd.toOffset(),
//         paint,
//       ); // Connect start dash end to where end dash starts
//     } else {
//       final zigZagNumSegments = (zigZagDistance / frequency).floor();
//       final zigZagDirection = (zigZagEnd - zigZagStart).normalized();
//       final perpendicular = Vector2(-zigZagDirection.y, zigZagDirection.x);
//
//       var currentPoint = zigZagStart;
//       for (int i = 0; i < zigZagNumSegments; i++) {
//         final nextPointOnLine = currentPoint + zigZagDirection * frequency;
//         final midPoint = (currentPoint + nextPointOnLine) / 2;
//         final zigZagOffset = perpendicular * amplitude * (i.isEven ? 1 : -1);
//         final zigZagPoint = midPoint + zigZagOffset;
//
//         canvas.drawLine(currentPoint.toOffset(), zigZagPoint.toOffset(), paint);
//         canvas.drawLine(
//           zigZagPoint.toOffset(),
//           nextPointOnLine.toOffset(),
//           paint,
//         );
//         currentPoint = nextPointOnLine;
//       }
//       // Connect the last zig-zag point to the end dash start point
//       canvas.drawLine(currentPoint.toOffset(), zigZagEnd.toOffset(), paint);
//     }
//
//     // --- 3. Ending Dash ---
//     final endDashStart = zigZagEnd; // Where the zig-zag ended
//     final endDashEnd =
//         end - lineDirection * arrowSize; // Where the arrow base will be
//     canvas.drawLine(endDashStart.toOffset(), endDashEnd.toOffset(), paint);
//
//     // --- 4. Arrowhead ---
//     final angle = math.atan2(
//       end.y - start.y,
//       end.x - start.x,
//     ); // Use overall direction for arrow angle
//     // final arrowBase = endDashEnd; // Arrow starts where the end dash finishes
//
//     final path = Path();
//     path.moveTo(
//       end.x - arrowSize * math.cos(angle - math.pi / 6),
//       end.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     path.lineTo(end.x, end.y); // Tip of the arrow at the final end point
//     path.lineTo(
//       end.x - arrowSize * math.cos(angle + math.pi / 6),
//       end.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//
//     // Use fill style for arrowhead for better visibility
//     final arrowPaint =
//         Paint()
//           ..color = paint.color
//           ..style = PaintingStyle.fill; // Changed to fill
//     canvas.drawPath(path, arrowPaint);
//   }
//
//   void _drawStraightLineWithArrow(
//     Canvas canvas,
//     Vector2 start,
//     Vector2 end,
//     Paint paint,
//   ) {
//     final arrowSize = _duplicateLine.thickness * 4;
//     final distance = start.distanceTo(end);
//
//     if (distance < arrowSize) {
//       // If line is shorter than arrow, just draw line
//       canvas.drawLine(start.toOffset(), end.toOffset(), paint);
//       return;
//     }
//
//     final dx = end.x - start.x;
//     final dy = end.y - start.y;
//     final angle = math.atan2(dy, dx);
//     // final lineDirection = Vector2(dx, dy).normalized();
//
//     // --- 1. Draw the line ---
//     // Shorten the line slightly so the arrowhead sits at the end
//     // final lineEnd = end - lineDirection * (arrowSize * 0.5); // Adjust slightly if needed or keep as is
//     canvas.drawLine(
//       start.toOffset(),
//       end.toOffset(),
//       paint,
//     ); // Draw full line for simplicity
//
//     // --- 2. Draw the Arrowhead ---
//     final path = Path();
//     path.moveTo(
//       end.x - arrowSize * math.cos(angle - math.pi / 6),
//       end.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     path.lineTo(end.x, end.y); // Tip of the arrow at the end point
//     path.lineTo(
//       end.x - arrowSize * math.cos(angle + math.pi / 6),
//       end.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//     // path.close(); // Closing might draw an extra line, often not needed for simple arrows
//
//     // Use fill style for arrowhead
//     final arrowPaint =
//         Paint()
//           ..color = paint.color
//           ..style = PaintingStyle.fill;
//     canvas.drawPath(path, arrowPaint);
//   }
//
//   void _drawStraightLineWithDoubleArrow(
//     Canvas canvas,
//     Vector2 start,
//     Vector2 end,
//     Paint paint,
//   ) {
//     final arrowSize = _duplicateLine.thickness * 4;
//     final distance = start.distanceTo(end);
//
//     if (distance < 2 * arrowSize) {
//       // Not enough space for two arrows
//       canvas.drawLine(
//         start.toOffset(),
//         end.toOffset(),
//         paint,
//       ); // Just draw line
//       return;
//     }
//
//     final dx = end.x - start.x;
//     final dy = end.y - start.y;
//     final angle = math.atan2(dy, dx);
//     // final lineDirection = Vector2(dx, dy).normalized();
//
//     // --- 1. Draw the line ---
//     // Shorten line from both ends to make space for arrows visually (optional)
//     // final lineStart = start + lineDirection * (arrowSize * 0.5);
//     // final lineEnd = end - lineDirection * (arrowSize * 0.5);
//     // For simplicity, draw the full line and overlay arrows
//     canvas.drawLine(start.toOffset(), end.toOffset(), paint);
//
//     // Use fill style for arrowheads
//     final arrowPaint =
//         Paint()
//           ..color = paint.color
//           ..style = PaintingStyle.fill;
//
//     // --- 2. Draw the Arrowhead at the end ---
//     final endPath = Path();
//     endPath.moveTo(
//       end.x - arrowSize * math.cos(angle - math.pi / 6),
//       end.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     endPath.lineTo(end.x, end.y);
//     endPath.lineTo(
//       end.x - arrowSize * math.cos(angle + math.pi / 6),
//       end.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//     // endPath.close();
//     canvas.drawPath(endPath, arrowPaint);
//
//     // --- 3. Draw the Arrowhead at the start ---
//     // Angle needs to be reversed for the start arrow
//     final startAngle = math.atan2(
//       start.y - end.y,
//       start.x - end.x,
//     ); // Angle pointing from end to start
//     final startPath = Path();
//     startPath.moveTo(
//       start.x - arrowSize * math.cos(startAngle - math.pi / 6),
//       start.y - arrowSize * math.sin(startAngle - math.pi / 6),
//     );
//     startPath.lineTo(start.x, start.y);
//     startPath.lineTo(
//       start.x - arrowSize * math.cos(startAngle + math.pi / 6),
//       start.y - arrowSize * math.sin(startAngle + math.pi / 6),
//     );
//     // startPath.close();
//     canvas.drawPath(startPath, arrowPaint);
//   }
//
//   void _drawRightTurnArrow(
//     Canvas canvas,
//     Vector2 start,
//     Vector2 end,
//     Paint paint,
//   ) {
//     final arrowSize = _duplicateLine.thickness * 4;
//
//     // Determine corner point C
//     final corner = Vector2(
//       end.x,
//       start.y,
//     ); // Assumes horizontal then vertical turn
//
//     // Handle case where start and corner are the same (vertical line)
//     // or corner and end are the same (horizontal line) -> Draw straight arrow instead
//     if (start.distanceTo(corner) < 0.1 || corner.distanceTo(end) < 0.1) {
//       // Use distance check
//       _drawStraightLineWithArrow(canvas, start, end, paint);
//       return;
//     }
//
//     // --- 1. Draw the line segments ---
//
//     // Draw first segment: start to corner
//     canvas.drawLine(start.toOffset(), corner.toOffset(), paint);
//
//     // Draw second segment: corner to end (leaving space for arrow)
//     // final secondSegmentDirection = (end - corner).normalized();
//     // final arrowBase = end - secondSegmentDirection * (arrowSize * 0.5); // Point before the arrow tip
//     // canvas.drawLine(corner.toOffset(), arrowBase.toOffset(), paint); // Draw up to arrow base
//     canvas.drawLine(
//       corner.toOffset(),
//       end.toOffset(),
//       paint,
//     ); // Draw full second segment
//
//     // --- 2. Draw Arrowhead at the end ---
//     final angle = math.atan2(
//       end.y - corner.y,
//       end.x - corner.x,
//     ); // Angle of the second segment
//
//     final path = Path();
//     path.moveTo(
//       end.x - arrowSize * math.cos(angle - math.pi / 6),
//       end.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     path.lineTo(end.x, end.y); // Tip of the arrow
//     path.lineTo(
//       end.x - arrowSize * math.cos(angle + math.pi / 6),
//       end.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//     // path.close();
//
//     // Use fill style for arrowhead
//     final arrowPaint =
//         Paint()
//           ..color = paint.color
//           ..style = PaintingStyle.fill;
//     canvas.drawPath(path, arrowPaint);
//   }
//
//   // Dragging the whole line logic
//   @override
//   void onDragStart(DragStartEvent event) {
//     // Check if the drag started on the line itself, not on any dot
//     if (isActive &&
//         !dots.any((dot) => dot.containsPoint(event.localPosition))) {
//       // Check if the tap is near the line path (using the modified containsLocalPoint)
//       if (containsLocalPoint(event.localPosition)) {
//         _isDragging = true;
//         event.continuePropagation =
//             false; // Consume event for the line drag ** CHANGED to false **
//         return; // Don't call super if we are handling the line drag
//       }
//     }
//     // If drag started on a dot, let the dot handle it (via its own DragCallbacks)
//     // If not active or not near the line, let propagation continue.
//     event.continuePropagation = true; // ** ENSURE this is true otherwise **
//     super.onDragStart(event); // Allows propagation if not handled here
//   }
//
//   // --- MODIFIED: onDragUpdate for whole line ---
//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     if (_isDragging) {
//       final delta = event.localDelta;
//       // Move start, end, AND control points
//       _duplicateLine.start += delta;
//       _duplicateLine.end += delta;
//       _controlPoint1 += delta;
//       _controlPoint2 += delta;
//       updateLine(); // This will update all dot visual positions
//       event.continuePropagation = false; // Consume event ** CHANGED to false **
//     } else {
//       // If not dragging the line, let the event propagate to children (dots)
//       event.continuePropagation = true; // ** ENSURE this is true otherwise **
//       super.onDragUpdate(event);
//     }
//   }
//   // --- End MODIFIED ---
//
//   @override
//   void onDragEnd(DragEndEvent event) {
//     if (_isDragging) {
//       _isDragging = false;
//       // No need to update state here, it was updated in onDragUpdate
//       event.continuePropagation = false; // Consume event ** CHANGED to false **
//     } else {
//       event.continuePropagation = true; // ** ENSURE this is true otherwise **
//       super.onDragEnd(event);
//     }
//   }
//
//   @override
//   void onDragCancel(DragCancelEvent event) {
//     if (_isDragging) {
//       _isDragging = false;
//       event.continuePropagation = false; // Consume event ** CHANGED to false **
//     } else {
//       event.continuePropagation = true; // ** ENSURE this is true otherwise **
//       super.onDragCancel(event);
//     }
//   }
//
//   // Tapping and Activation logic remains the same
//   @override
//   void onTapDown(TapDownEvent event) {
//     if (isActive && dots.any((dot) => dot.containsPoint(event.localPosition))) {
//       // If tap is on an active dot, let the dot handle it (or do nothing extra here)
//       event.handled = false; // Let dot handle drag start etc.
//       return;
//     }
//
//     // Only toggle active if the tap is on the line path itself, not on a dot
//     if (containsLocalPoint(event.localPosition)) {
//       _toggleActive();
//       event.handled = true; // Event handled by toggling selection
//       return;
//     }
//
//     // If the tap was not on the line or an active dot, let it propagate.
//     event.handled = false;
//   }
//
//   @override
//   void onLongTapDown(TapDownEvent event) {
//     // Similar logic to onTapDown for long press
//     if (isActive && dots.any((dot) => dot.containsPoint(event.localPosition))) {
//       event.handled = false;
//       return;
//     }
//     if (containsLocalPoint(event.localPosition)) {
//       _toggleActive(); // Or implement different long-press action
//       event.handled = true;
//       return;
//     }
//     event.handled = false;
//   }
//
//   void _toggleActive() {
//     ref
//         .read(boardProvider.notifier)
//         .toggleSelectItemEvent(fieldItemModel: lineModelV2);
//   }
//
//   // --- MODIFIED: _updateIsActive ---
//   void _updateIsActive(FieldItemModel? item) {
//     final previouslyActive = isActive;
//     isActive = item is LineModelV2 && item.id == lineModelV2.id;
//
//     if (isActive && !previouslyActive) {
//       // When activating, ensure control points reflect the current start/end
//       // (They might have been left in a bent state if we don't reset)
//       // Option 1: Reset to straight line 1/3, 2/3 (uncomment if desired)
//       // _initializeControlPoints();
//
//       // Option 2: Keep the bent state (current implementation assumes this)
//       // Make sure they exist if they were somehow null
//       if (!(_controlPoint1 is Vector2 && _controlPoint2 is Vector2)) {
//         zlog(data: "Control points null on activation, re-initializing.");
//         _initializeControlPoints();
//       }
//
//       // Ensure dot positions are correct based on the current state
//       _createDots(); // Recreate dots to place them correctly
//       addAll(dots); // Add all child components (dots)
//       zlog(
//         data:
//             "Line ${lineModelV2.id} Activated. Added ${dots.length} dots. CP1: $_controlPoint1, CP2: $_controlPoint2",
//       );
//     } else if (!isActive && previouslyActive) {
//       try {
//         zlog(
//           data:
//               "Line ${lineModelV2.id} Deactivated. Removing ${dots.length} dots.",
//         );
//         if (dots.isNotEmpty) {
//           removeAll(dots); // Use removeAll with the list of dots
//           dots.clear(); // Clear the list after removing
//         }
//       } catch (e, s) {
//         zlog(data: "Error removing dots: $e \n$s");
//       }
//     }
//   }
//   // --- End MODIFIED ---
//
//   // --- MODIFIED: containsLocalPoint ---
//   @override
//   bool containsLocalPoint(Vector2 point) {
//     final hitAreaWidth = math.max(
//       circleRadius * 1.5,
//       _duplicateLine.thickness * 2.0,
//     );
//
//     // Use the four points defining the shape: start, control1, control2, end
//     final p1 = _duplicateLine.start;
//     final p2 = _controlPoint1;
//     final p3 = _controlPoint2;
//     final p4 = _duplicateLine.end;
//
//     // Check distance to the three line segments (approximation for the curve)
//     if (_distanceToSegment(point, p1, p2) < hitAreaWidth ||
//         _distanceToSegment(point, p2, p3) < hitAreaWidth ||
//         _distanceToSegment(point, p3, p4) < hitAreaWidth) {
//       return true;
//     }
//
//     // Optional: Check distance to the points themselves if segments are very short
//     // if (point.distanceTo(p1) < hitAreaWidth || ...)
//
//     return false;
//   }
//
//   // Helper function for distance to a line segment
//   double _distanceToSegment(Vector2 p, Vector2 a, Vector2 b) {
//     final l2 = a.distanceToSquared(b);
//     if (l2 == 0.0) return p.distanceTo(a); // Segment is a point
//     // Project p onto the line defined by a,b
//     final t = ((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / l2;
//     final clampedT = t.clamp(0.0, 1.0);
//     // Find the closest point on the segment
//     final projection = a + (b - a) * clampedT;
//     return p.distanceTo(projection);
//   }
//   // --- End MODIFIED ---
//
//   // updateEnd function is kept as requested, although it's not called by the modified dot logic
//   void updateEnd(Vector2 currentPoint) {
//     _duplicateLine.end = currentPoint;
//     // If you intend this to be used, you might want it to call updateLine()
//     // updateLine();
//   }
// }

///Line bending dots on the curve

// import 'dart:async';
// import 'dart:math' as math;
//
// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flame_riverpod/flame_riverpod.dart';
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
//
// // DraggableDot class remains the same
// class DraggableDot extends CircleComponent with DragCallbacks {
//   final Function(Vector2) onPositionChanged;
//   final Vector2 initialPosition;
//   final bool canModifyLine;
//   final int dotIndex;
//
//   DraggableDot({
//     required this.onPositionChanged,
//     required this.initialPosition,
//     required this.dotIndex,
//     this.canModifyLine = true,
//     super.radius = 8.0,
//     Color color = Colors.blue,
//   }) : super(
//          position: initialPosition,
//          anchor: Anchor.center,
//          paint: Paint()..color = color,
//          priority: 2,
//        );
//
//   Vector2? _dragStartLocalPosition;
//
//   @override
//   void onDragStart(DragStartEvent event) {
//     _dragStartLocalPosition = event.localPosition;
//     event.continuePropagation = true;
//     super.onDragStart(event);
//   }
//
//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     if (_dragStartLocalPosition != null) {
//       onPositionChanged(position + event.localDelta);
//     }
//     event.continuePropagation = true;
//   }
//
//   @override
//   void onDragEnd(DragEndEvent event) {
//     _dragStartLocalPosition = null;
//     event.continuePropagation = true;
//     super.onDragEnd(event);
//   }
//
//   @override
//   void onDragCancel(DragCancelEvent event) {
//     _dragStartLocalPosition = null;
//     event.continuePropagation = true;
//     super.onDragCancel(event);
//   }
// }
//
// class LineDrawerComponentV2 extends PositionComponent
//     with
//         TapCallbacks,
//         DragCallbacks,
//         RiverpodComponentMixin,
//         HasGameReference<TacticBoardGame> {
//   LineModelV2 lineModelV2;
//   late LineModelV2 _duplicateLine;
//   final double circleRadius;
//   List<DraggableDot> dots = [];
//   bool isActive = false;
//   bool _isDragging = false;
//
//   late Vector2 _controlPoint1;
//   late Vector2 _controlPoint2;
//
//   late Paint _activePaint;
//   late Paint _inactivePaint;
//
//   // NOTE: Removed the maxPerpendicularDistance constraint
//
//   LineDrawerComponentV2({required this.lineModelV2, this.circleRadius = 8.0})
//     : super(priority: 1);
//
//   updatePaint() {
//     _inactivePaint =
//         Paint()
//           ..color =
//               _duplicateLine.color?.withValues(alpha: _duplicateLine.opacity) ??
//               ColorManager.black.withValues(alpha: _duplicateLine.opacity)
//           ..strokeWidth = _duplicateLine.thickness
//           ..style = PaintingStyle.stroke;
//
//     _activePaint =
//         Paint()
//           ..color =
//               _duplicateLine.color?.withValues(alpha: _duplicateLine.opacity) ??
//               ColorManager.black.withValues(alpha: _duplicateLine.opacity)
//           ..strokeWidth = _duplicateLine.thickness
//           ..style = PaintingStyle.stroke;
//   }
//
//   @override
//   FutureOr<void> onLoad() {
//     addToGameWidgetBuild(() {
//       ref.listen(boardProvider, (previous, current) {
//         _updateIsActive(current.selectedItemOnTheBoard);
//       });
//     });
//
//     _duplicateLine = lineModelV2.clone();
//     updatePaint();
//
//     _duplicateLine.start = SizeHelper.getBoardActualVector(
//       gameScreenSize: game.gameField.size,
//       actualPosition: _duplicateLine.start,
//     );
//     _duplicateLine.end = SizeHelper.getBoardActualVector(
//       gameScreenSize: game.gameField.size,
//       actualPosition: _duplicateLine.end,
//     );
//
//     _initializeControlPoints();
//     _createDots();
//
//     zlog(data: "Line model data onLoad ${_duplicateLine.toJson()}");
//
//     return super.onLoad();
//   }
//
//   void _initializeControlPoints() {
//     final start = _duplicateLine.start;
//     final end = _duplicateLine.end;
//     final diff = end - start;
//     _controlPoint1 = start + diff / 3.0;
//     _controlPoint2 = start + diff * 2.0 / 3.0;
//     zlog(
//       data:
//           "Initialized Control Points: CP1: $_controlPoint1, CP2: $_controlPoint2",
//     );
//   }
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//     updatePaint();
//   }
//
//   // projectPointOnLineSegment - Still useful for hit detection later
//   Vector2 projectPointOnLineSegment(
//     Vector2 point,
//     Vector2 lineStart,
//     Vector2 lineEnd,
//   ) {
//     final segmentVector = lineEnd - lineStart;
//     final segmentLengthSquared = segmentVector.length2;
//     if (segmentLengthSquared < 0.000001) {
//       return lineStart; // Treat as a point
//     }
//     final pointVector = point - lineStart;
//     double t = pointVector.dot(segmentVector) / segmentLengthSquared;
//     t = t.clamp(0.0, 1.0);
//     final closestPoint = lineStart + segmentVector * t;
//     return closestPoint;
//   }
//
//   void _createDots() {
//     if (!(_controlPoint1 is Vector2 && _controlPoint2 is Vector2)) {
//       zlog(
//         data:
//             "Warning: Control points not initialized in _createDots. Re-initializing.",
//       );
//       _initializeControlPoints();
//     }
//
//     dots.clear();
//
//     dots = [
//       // Start Dot (index 0)
//       DraggableDot(
//         dotIndex: 0,
//         initialPosition: _duplicateLine.start,
//         radius: circleRadius,
//         onPositionChanged: (newPos) {
//           _duplicateLine.start = newPos;
//           updateLine();
//         },
//         canModifyLine: true,
//         color: Colors.blue,
//       ),
//
//       // Control Point Dot 1 (index 1) - FREE MOVEMENT (NO CONSTRAINT)
//       DraggableDot(
//         dotIndex: 1,
//         initialPosition: _controlPoint1,
//         radius: circleRadius * 0.8,
//         onPositionChanged: (newPos) {
//           // Update internal state and dot position freely
//           _controlPoint1 = newPos;
//           dots[1].position = _controlPoint1;
//           // No updateLine() call needed here
//         },
//         canModifyLine: true,
//         color: Colors.red,
//       ),
//
//       // Control Point Dot 2 (index 2) - FREE MOVEMENT (NO CONSTRAINT)
//       DraggableDot(
//         dotIndex: 2,
//         initialPosition: _controlPoint2,
//         radius: circleRadius * 0.8,
//         onPositionChanged: (newPos) {
//           // Update internal state and dot position freely
//           _controlPoint2 = newPos;
//           dots[2].position = _controlPoint2;
//           // No updateLine() call needed here
//         },
//         canModifyLine: true,
//         color: Colors.red,
//       ),
//
//       // End Dot (index 3)
//       DraggableDot(
//         dotIndex: 3,
//         initialPosition: _duplicateLine.end,
//         radius: circleRadius,
//         onPositionChanged: (newPos) {
//           _duplicateLine.end = newPos;
//           updateLine();
//         },
//         canModifyLine: true,
//         color: Colors.blue,
//       ),
//     ];
//     zlog(
//       data:
//           "Created ${dots.length} dots. CP1 Pos: ${dots[1].position}, CP2 Pos: ${dots[2].position}",
//     );
//   }
//
//   void updateLine() {
//     if (dots.length != 4) {
//       zlog(
//         data:
//             "updateLine called but dots list has unexpected length: ${dots.length}",
//       );
//       return;
//     }
//
//     dots[0].position = _duplicateLine.start;
//     dots[3].position = _duplicateLine.end;
//     dots[1].position = _controlPoint1; // Ensure visual position matches state
//     dots[2].position = _controlPoint2; // Ensure visual position matches state
//
//     lineModelV2 = _duplicateLine.copyWith(
//       start:
//           SizeHelper.getBoardRelativeVector(
//             gameScreenSize: game.gameField.size,
//             actualPosition: _duplicateLine.start,
//           ).clone(),
//       end:
//           SizeHelper.getBoardRelativeVector(
//             gameScreenSize: game.gameField.size,
//             actualPosition: _duplicateLine.end,
//           ).clone(),
//       // NOTE: Control point positions (_controlPoint1, _controlPoint2)
//       // are NOT part of LineModelV2 and won't be saved unless model is changed.
//     );
//
//     ref.read(boardProvider.notifier).updateLine(line: lineModelV2);
//   }
//
//   // --- MODIFIED: render ---
//   @override
//   void render(Canvas canvas) {
//     final paint = isActive ? _activePaint : _inactivePaint;
//     final start = _duplicateLine.start;
//     final end = _duplicateLine.end;
//
//     // Use the current control points which are updated freely
//     final cp1 = _controlPoint1;
//     final cp2 = _controlPoint2;
//
//     // Determine if we should render bent (only for STRAIGHT_LINE for now)
//     bool canRenderBent = _duplicateLine.lineType == LineType.STRAIGHT_LINE;
//
//     if (canRenderBent) {
//       // --- Render as Piecewise Linear Segments ---
//       final path = Path();
//       path.moveTo(start.x, start.y);
//       path.lineTo(cp1.x, cp1.y); // Line to first control point
//       path.lineTo(cp2.x, cp2.y); // Line to second control point
//       path.lineTo(end.x, end.y); // Line to end point
//       canvas.drawPath(path, paint);
//       // --- End Piecewise Linear Rendering ---
//     } else {
//       // Fallback to original rendering (straight line) for non-bendable types
//       if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_DASHED) {
//         _drawDashedLine(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_ZIGZAG) {
//         _drawZigZagLine(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType ==
//           LineType.STRAIGHT_LINE_ZIGZAG_ARROW) {
//         _drawZigZagLineWithArrow(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_ARROW) {
//         _drawStraightLineWithArrow(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType ==
//           LineType.STRAIGHT_LINE_ARROW_DOUBLE) {
//         _drawStraightLineWithDoubleArrow(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType == LineType.RIGHT_TURN_ARROW) {
//         _drawRightTurnArrow(canvas, start, end, paint);
//       } else {
//         // Default straight line
//         canvas.drawLine(start.toOffset(), end.toOffset(), paint);
//       }
//     }
//   }
//   // --- End MODIFIED render ---
//
//   // Drawing helper methods (_drawDashedLine, etc.) remain the same
//   // ... (keep all your _draw... methods exactly as they were) ...
//   void _drawDashedLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
//     const dashWidth = 10.0;
//     const dashSpace = 5.0;
//
//     final dx = end.x - start.x;
//     final dy = end.y - start.y;
//     final distance = start.distanceTo(end);
//     if (distance == 0) return; // Avoid division by zero
//     final numDashes = (distance / (dashWidth + dashSpace)).floor();
//     final normalizedDirection = Vector2(dx, dy).normalized();
//
//     for (int i = 0; i < numDashes; i++) {
//       final startOffset =
//           start + normalizedDirection * (i * (dashWidth + dashSpace));
//       final endOffset =
//           start +
//           normalizedDirection * (i * (dashWidth + dashSpace) + dashWidth);
//       canvas.drawLine(startOffset.toOffset(), endOffset.toOffset(), paint);
//     }
//     // Optional: Draw a partial dash at the end if needed
//     final remainingDistance = distance - numDashes * (dashWidth + dashSpace);
//     if (remainingDistance > 0) {
//       final startOffset =
//           start + normalizedDirection * (numDashes * (dashWidth + dashSpace));
//       final endOffset =
//           start +
//           normalizedDirection *
//               (numDashes * (dashWidth + dashSpace) +
//                   math.min(remainingDistance, dashWidth));
//       canvas.drawLine(startOffset.toOffset(), endOffset.toOffset(), paint);
//     }
//   }
//
//   void _drawZigZagLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
//     const amplitude = 5.0; // Reduced for smaller zig-zags
//     const frequency = 10.0; // More frequent zig-zags
//     const dashLength = 10.0; // Length of the starting and ending dashes
//
//     final distance = start.distanceTo(end);
//     if (distance < 2 * dashLength) {
//       // Not enough space for dashes and zig-zag
//       canvas.drawLine(
//         start.toOffset(),
//         end.toOffset(),
//         paint,
//       ); // Draw straight line
//       return;
//     }
//
//     final lineDirection = (end - start).normalized();
//
//     // --- 1. Starting Dash ---
//     final startDashEnd = start + lineDirection * dashLength;
//     canvas.drawLine(start.toOffset(), startDashEnd.toOffset(), paint);
//
//     // --- 2. Zig-Zag ---
//     final zigZagStart = startDashEnd;
//     final zigZagEnd = end - lineDirection * dashLength;
//     final zigZagDistance = zigZagStart.distanceTo(zigZagEnd);
//
//     if (zigZagDistance < frequency) {
//       // Not enough space for even one zig-zag segment
//       canvas.drawLine(
//         zigZagStart.toOffset(),
//         zigZagEnd.toOffset(),
//         paint,
//       ); // Connect dashes
//     } else {
//       final zigZagNumSegments = (zigZagDistance / frequency).floor();
//       final zigZagDirection = (zigZagEnd - zigZagStart).normalized();
//       final perpendicular = Vector2(
//         -zigZagDirection.y,
//         zigZagDirection.x,
//       ); // Perpendicular
//
//       var currentPoint = zigZagStart;
//       for (int i = 0; i < zigZagNumSegments; i++) {
//         final nextPointOnLine = currentPoint + zigZagDirection * frequency;
//         final midPoint = (currentPoint + nextPointOnLine) / 2;
//         final zigZagOffset = perpendicular * amplitude * (i.isEven ? 1 : -1);
//         final zigZagPoint = midPoint + zigZagOffset;
//
//         canvas.drawLine(currentPoint.toOffset(), zigZagPoint.toOffset(), paint);
//         canvas.drawLine(
//           zigZagPoint.toOffset(),
//           nextPointOnLine.toOffset(),
//           paint,
//         );
//         currentPoint = nextPointOnLine;
//       }
//       // Connect the last zig-zag point to the end dash start point
//       canvas.drawLine(currentPoint.toOffset(), zigZagEnd.toOffset(), paint);
//     }
//
//     // --- 3. Ending Dash ---
//     canvas.drawLine(zigZagEnd.toOffset(), end.toOffset(), paint);
//   }
//
//   void _drawZigZagLineWithArrow(
//     Canvas canvas,
//     Vector2 start,
//     Vector2 end,
//     Paint paint,
//   ) {
//     const amplitude = 5.0;
//     const frequency = 10.0;
//     final arrowSize = _duplicateLine.thickness * 4;
//     const dashLength = 10.0;
//
//     final distance = start.distanceTo(end);
//     if (distance < (2 * dashLength + arrowSize)) {
//       // Not enough space
//       _drawStraightLineWithArrow(
//         canvas,
//         start,
//         end,
//         paint,
//       ); // Fallback to straight arrow
//       return;
//     }
//
//     final lineDirection = (end - start).normalized();
//
//     // --- 1. Starting Dash ---
//     final startDashEnd = start + lineDirection * dashLength;
//     canvas.drawLine(start.toOffset(), startDashEnd.toOffset(), paint);
//
//     // --- 2. Zig-Zag ---
//     final zigZagStart = startDashEnd;
//     // Adjust end point for zig-zag to leave space for end dash and arrow
//     final zigZagEnd = end - lineDirection * (dashLength + arrowSize);
//     final zigZagDistance = zigZagStart.distanceTo(zigZagEnd);
//
//     if (zigZagDistance < frequency) {
//       // Not enough space for zig-zag
//       canvas.drawLine(
//         zigZagStart.toOffset(),
//         zigZagEnd.toOffset(),
//         paint,
//       ); // Connect start dash end to where end dash starts
//     } else {
//       final zigZagNumSegments = (zigZagDistance / frequency).floor();
//       final zigZagDirection = (zigZagEnd - zigZagStart).normalized();
//       final perpendicular = Vector2(-zigZagDirection.y, zigZagDirection.x);
//
//       var currentPoint = zigZagStart;
//       for (int i = 0; i < zigZagNumSegments; i++) {
//         final nextPointOnLine = currentPoint + zigZagDirection * frequency;
//         final midPoint = (currentPoint + nextPointOnLine) / 2;
//         final zigZagOffset = perpendicular * amplitude * (i.isEven ? 1 : -1);
//         final zigZagPoint = midPoint + zigZagOffset;
//
//         canvas.drawLine(currentPoint.toOffset(), zigZagPoint.toOffset(), paint);
//         canvas.drawLine(
//           zigZagPoint.toOffset(),
//           nextPointOnLine.toOffset(),
//           paint,
//         );
//         currentPoint = nextPointOnLine;
//       }
//       // Connect the last zig-zag point to the end dash start point
//       canvas.drawLine(currentPoint.toOffset(), zigZagEnd.toOffset(), paint);
//     }
//
//     // --- 3. Ending Dash ---
//     final endDashStart = zigZagEnd; // Where the zig-zag ended
//     final endDashEnd =
//         end - lineDirection * arrowSize; // Where the arrow base will be
//     canvas.drawLine(endDashStart.toOffset(), endDashEnd.toOffset(), paint);
//
//     // --- 4. Arrowhead ---
//     final angle = math.atan2(
//       end.y - start.y,
//       end.x - start.x,
//     ); // Use overall direction for arrow angle
//     // final arrowBase = endDashEnd; // Arrow starts where the end dash finishes
//
//     final path = Path();
//     path.moveTo(
//       end.x - arrowSize * math.cos(angle - math.pi / 6),
//       end.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     path.lineTo(end.x, end.y); // Tip of the arrow at the final end point
//     path.lineTo(
//       end.x - arrowSize * math.cos(angle + math.pi / 6),
//       end.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//
//     // Use fill style for arrowhead for better visibility
//     final arrowPaint =
//         Paint()
//           ..color = paint.color
//           ..style = PaintingStyle.fill; // Changed to fill
//     canvas.drawPath(path, arrowPaint);
//   }
//
//   void _drawStraightLineWithArrow(
//     Canvas canvas,
//     Vector2 start,
//     Vector2 end,
//     Paint paint,
//   ) {
//     final arrowSize = _duplicateLine.thickness * 4;
//     final distance = start.distanceTo(end);
//
//     if (distance < arrowSize) {
//       // If line is shorter than arrow, just draw line
//       canvas.drawLine(start.toOffset(), end.toOffset(), paint);
//       return;
//     }
//
//     final dx = end.x - start.x;
//     final dy = end.y - start.y;
//     final angle = math.atan2(dy, dx);
//     // final lineDirection = Vector2(dx, dy).normalized();
//
//     // --- 1. Draw the line ---
//     // Shorten the line slightly so the arrowhead sits at the end
//     // final lineEnd = end - lineDirection * (arrowSize * 0.5); // Adjust slightly if needed or keep as is
//     canvas.drawLine(
//       start.toOffset(),
//       end.toOffset(),
//       paint,
//     ); // Draw full line for simplicity
//
//     // --- 2. Draw the Arrowhead ---
//     final path = Path();
//     path.moveTo(
//       end.x - arrowSize * math.cos(angle - math.pi / 6),
//       end.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     path.lineTo(end.x, end.y); // Tip of the arrow at the end point
//     path.lineTo(
//       end.x - arrowSize * math.cos(angle + math.pi / 6),
//       end.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//     // path.close(); // Closing might draw an extra line, often not needed for simple arrows
//
//     // Use fill style for arrowhead
//     final arrowPaint =
//         Paint()
//           ..color = paint.color
//           ..style = PaintingStyle.fill;
//     canvas.drawPath(path, arrowPaint);
//   }
//
//   void _drawStraightLineWithDoubleArrow(
//     Canvas canvas,
//     Vector2 start,
//     Vector2 end,
//     Paint paint,
//   ) {
//     final arrowSize = _duplicateLine.thickness * 4;
//     final distance = start.distanceTo(end);
//
//     if (distance < 2 * arrowSize) {
//       // Not enough space for two arrows
//       canvas.drawLine(
//         start.toOffset(),
//         end.toOffset(),
//         paint,
//       ); // Just draw line
//       return;
//     }
//
//     final dx = end.x - start.x;
//     final dy = end.y - start.y;
//     final angle = math.atan2(dy, dx);
//     // final lineDirection = Vector2(dx, dy).normalized();
//
//     // --- 1. Draw the line ---
//     // Shorten line from both ends to make space for arrows visually (optional)
//     // final lineStart = start + lineDirection * (arrowSize * 0.5);
//     // final lineEnd = end - lineDirection * (arrowSize * 0.5);
//     // For simplicity, draw the full line and overlay arrows
//     canvas.drawLine(start.toOffset(), end.toOffset(), paint);
//
//     // Use fill style for arrowheads
//     final arrowPaint =
//         Paint()
//           ..color = paint.color
//           ..style = PaintingStyle.fill;
//
//     // --- 2. Draw the Arrowhead at the end ---
//     final endPath = Path();
//     endPath.moveTo(
//       end.x - arrowSize * math.cos(angle - math.pi / 6),
//       end.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     endPath.lineTo(end.x, end.y);
//     endPath.lineTo(
//       end.x - arrowSize * math.cos(angle + math.pi / 6),
//       end.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//     // endPath.close();
//     canvas.drawPath(endPath, arrowPaint);
//
//     // --- 3. Draw the Arrowhead at the start ---
//     // Angle needs to be reversed for the start arrow
//     final startAngle = math.atan2(
//       start.y - end.y,
//       start.x - end.x,
//     ); // Angle pointing from end to start
//     final startPath = Path();
//     startPath.moveTo(
//       start.x - arrowSize * math.cos(startAngle - math.pi / 6),
//       start.y - arrowSize * math.sin(startAngle - math.pi / 6),
//     );
//     startPath.lineTo(start.x, start.y);
//     startPath.lineTo(
//       start.x - arrowSize * math.cos(startAngle + math.pi / 6),
//       start.y - arrowSize * math.sin(startAngle + math.pi / 6),
//     );
//     // startPath.close();
//     canvas.drawPath(startPath, arrowPaint);
//   }
//
//   void _drawRightTurnArrow(
//     Canvas canvas,
//     Vector2 start,
//     Vector2 end,
//     Paint paint,
//   ) {
//     final arrowSize = _duplicateLine.thickness * 4;
//
//     // Determine corner point C
//     final corner = Vector2(
//       end.x,
//       start.y,
//     ); // Assumes horizontal then vertical turn
//
//     // Handle case where start and corner are the same (vertical line)
//     // or corner and end are the same (horizontal line) -> Draw straight arrow instead
//     if (start.distanceTo(corner) < 0.1 || corner.distanceTo(end) < 0.1) {
//       // Use distance check
//       _drawStraightLineWithArrow(canvas, start, end, paint);
//       return;
//     }
//
//     // --- 1. Draw the line segments ---
//
//     // Draw first segment: start to corner
//     canvas.drawLine(start.toOffset(), corner.toOffset(), paint);
//
//     // Draw second segment: corner to end (leaving space for arrow)
//     // final secondSegmentDirection = (end - corner).normalized();
//     // final arrowBase = end - secondSegmentDirection * (arrowSize * 0.5); // Point before the arrow tip
//     // canvas.drawLine(corner.toOffset(), arrowBase.toOffset(), paint); // Draw up to arrow base
//     canvas.drawLine(
//       corner.toOffset(),
//       end.toOffset(),
//       paint,
//     ); // Draw full second segment
//
//     // --- 2. Draw Arrowhead at the end ---
//     final angle = math.atan2(
//       end.y - corner.y,
//       end.x - corner.x,
//     ); // Angle of the second segment
//
//     final path = Path();
//     path.moveTo(
//       end.x - arrowSize * math.cos(angle - math.pi / 6),
//       end.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     path.lineTo(end.x, end.y); // Tip of the arrow
//     path.lineTo(
//       end.x - arrowSize * math.cos(angle + math.pi / 6),
//       end.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//     // path.close();
//
//     // Use fill style for arrowhead
//     final arrowPaint =
//         Paint()
//           ..color = paint.color
//           ..style = PaintingStyle.fill;
//     canvas.drawPath(path, arrowPaint);
//   }
//
//   // Dragging the whole line logic (should be fine as is)
//   @override
//   void onDragStart(DragStartEvent event) {
//     if (isActive &&
//         !dots.any((dot) => dot.containsPoint(event.localPosition))) {
//       if (containsLocalPoint(event.localPosition)) {
//         _isDragging = true;
//         event.continuePropagation = false;
//         return;
//       }
//     }
//     event.continuePropagation = true;
//     super.onDragStart(event);
//   }
//
//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     if (_isDragging) {
//       final delta = event.localDelta;
//       _duplicateLine.start += delta;
//       _duplicateLine.end += delta;
//       _controlPoint1 += delta;
//       _controlPoint2 += delta;
//       updateLine();
//       event.continuePropagation = false;
//     } else {
//       event.continuePropagation = true;
//       super.onDragUpdate(event);
//     }
//   }
//
//   @override
//   void onDragEnd(DragEndEvent event) {
//     if (_isDragging) {
//       _isDragging = false;
//       event.continuePropagation = false;
//     } else {
//       event.continuePropagation = true;
//       super.onDragEnd(event);
//     }
//   }
//
//   @override
//   void onDragCancel(DragCancelEvent event) {
//     if (_isDragging) {
//       _isDragging = false;
//       event.continuePropagation = false;
//     } else {
//       event.continuePropagation = true;
//       super.onDragCancel(event);
//     }
//   }
//
//   // Tapping and Activation logic remains the same
//   @override
//   void onTapDown(TapDownEvent event) {
//     if (isActive && dots.any((dot) => dot.containsPoint(event.localPosition))) {
//       event.handled = false;
//       return;
//     }
//     if (containsLocalPoint(event.localPosition)) {
//       _toggleActive();
//       event.handled = true;
//       return;
//     }
//     event.handled = false;
//   }
//
//   @override
//   void onLongTapDown(TapDownEvent event) {
//     if (isActive && dots.any((dot) => dot.containsPoint(event.localPosition))) {
//       event.handled = false;
//       return;
//     }
//     if (containsLocalPoint(event.localPosition)) {
//       _toggleActive();
//       event.handled = true;
//       return;
//     }
//     event.handled = false;
//   }
//
//   void _toggleActive() {
//     ref
//         .read(boardProvider.notifier)
//         .toggleSelectItemEvent(fieldItemModel: lineModelV2);
//   }
//
//   void _updateIsActive(FieldItemModel? item) {
//     final previouslyActive = isActive;
//     isActive = item is LineModelV2 && item.id == lineModelV2.id;
//
//     if (isActive && !previouslyActive) {
//       if (!(_controlPoint1 is Vector2 && _controlPoint2 is Vector2)) {
//         zlog(data: "Control points null on activation, re-initializing.");
//         _initializeControlPoints();
//       }
//       _createDots();
//       addAll(dots);
//       zlog(
//         data:
//             "Line ${lineModelV2.id} Activated. Added ${dots.length} dots. CP1: $_controlPoint1, CP2: $_controlPoint2",
//       );
//     } else if (!isActive && previouslyActive) {
//       try {
//         zlog(
//           data:
//               "Line ${lineModelV2.id} Deactivated. Removing ${dots.length} dots.",
//         );
//         if (dots.isNotEmpty) {
//           removeAll(dots);
//           dots.clear();
//         }
//       } catch (e, s) {
//         zlog(data: "Error removing dots: $e \n$s");
//       }
//     }
//   }
//
//   // containsLocalPoint method (checks distance to segments, which now matches rendering)
//   @override
//   bool containsLocalPoint(Vector2 point) {
//     final hitAreaWidth = math.max(
//       circleRadius * 1.5,
//       _duplicateLine.thickness * 2.0,
//     );
//
//     final p1 = _duplicateLine.start;
//     final p2 = _controlPoint1; // Use the freely moved control points
//     final p3 = _controlPoint2;
//     final p4 = _duplicateLine.end;
//
//     // Check distance to the three line segments that are now being rendered
//     if (_distanceToSegment(point, p1, p2) < hitAreaWidth ||
//         _distanceToSegment(point, p2, p3) < hitAreaWidth ||
//         _distanceToSegment(point, p3, p4) < hitAreaWidth) {
//       return true;
//     }
//     return false;
//   }
//
//   double _distanceToSegment(Vector2 p, Vector2 a, Vector2 b) {
//     final l2 = a.distanceToSquared(b);
//     if (l2 == 0.0) return p.distanceTo(a);
//     final t = ((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / l2;
//     final clampedT = t.clamp(0.0, 1.0);
//     final projection = a + (b - a) * clampedT;
//     return p.distanceTo(projection);
//   }
//
//   // updateEnd function is kept as requested
//   void updateEnd(Vector2 currentPoint) {
//     _duplicateLine.end = currentPoint;
//     // updateLine();
//   }
// }

/// free bending smooth curve

// import 'dart:async';
// import 'dart:math' as math;
//
// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flame_riverpod/flame_riverpod.dart';
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
//
// // DraggableDot class remains the same
// class DraggableDot extends CircleComponent with DragCallbacks {
//   final Function(Vector2) onPositionChanged;
//   final Vector2 initialPosition;
//   final bool canModifyLine;
//   final int dotIndex;
//
//   DraggableDot({
//     required this.onPositionChanged,
//     required this.initialPosition,
//     required this.dotIndex,
//     this.canModifyLine = true,
//     super.radius = 8.0,
//     Color color = Colors.blue,
//   }) : super(
//          position: initialPosition,
//          anchor: Anchor.center,
//          paint: Paint()..color = color,
//          priority: 2,
//        );
//
//   Vector2? _dragStartLocalPosition;
//
//   @override
//   void onDragStart(DragStartEvent event) {
//     _dragStartLocalPosition = event.localPosition;
//     event.continuePropagation = true;
//     super.onDragStart(event);
//   }
//
//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     if (_dragStartLocalPosition != null) {
//       onPositionChanged(position + event.localDelta);
//     }
//     event.continuePropagation = true;
//   }
//
//   @override
//   void onDragEnd(DragEndEvent event) {
//     _dragStartLocalPosition = null;
//     event.continuePropagation = true;
//     super.onDragEnd(event);
//   }
//
//   @override
//   void onDragCancel(DragCancelEvent event) {
//     _dragStartLocalPosition = null;
//     event.continuePropagation = true;
//     super.onDragCancel(event);
//   }
// }
//
// class LineDrawerComponentV2 extends PositionComponent
//     with
//         TapCallbacks,
//         DragCallbacks,
//         RiverpodComponentMixin,
//         HasGameReference<TacticBoardGame> {
//   LineModelV2 lineModelV2;
//   late LineModelV2 _duplicateLine;
//   final double circleRadius;
//   List<DraggableDot> dots = [];
//   bool isActive = false;
//   bool _isDragging = false;
//
//   late Vector2 _controlPoint1;
//   late Vector2 _controlPoint2;
//
//   late Paint _activePaint;
//   late Paint _inactivePaint;
//
//   LineDrawerComponentV2({required this.lineModelV2, this.circleRadius = 8.0})
//     : super(priority: 1);
//
//   updatePaint() {
//     _inactivePaint =
//         Paint()
//           ..color =
//               _duplicateLine.color?.withValues(alpha: _duplicateLine.opacity) ??
//               ColorManager.black.withValues(alpha: _duplicateLine.opacity)
//           ..strokeWidth = _duplicateLine.thickness
//           ..style = PaintingStyle.stroke;
//
//     _activePaint =
//         Paint()
//           ..color =
//               _duplicateLine.color?.withValues(alpha: _duplicateLine.opacity) ??
//               ColorManager.black.withValues(alpha: _duplicateLine.opacity)
//           ..strokeWidth = _duplicateLine.thickness
//           ..style = PaintingStyle.stroke;
//   }
//
//   @override
//   FutureOr<void> onLoad() {
//     addToGameWidgetBuild(() {
//       ref.listen(boardProvider, (previous, current) {
//         _updateIsActive(current.selectedItemOnTheBoard);
//       });
//     });
//
//     _duplicateLine = lineModelV2.clone();
//     updatePaint();
//
//     _duplicateLine.start = SizeHelper.getBoardActualVector(
//       gameScreenSize: game.gameField.size,
//       actualPosition: _duplicateLine.start,
//     );
//     _duplicateLine.end = SizeHelper.getBoardActualVector(
//       gameScreenSize: game.gameField.size,
//       actualPosition: _duplicateLine.end,
//     );
//
//     _initializeControlPoints();
//     _createDots();
//
//     zlog(data: "Line model data onLoad ${_duplicateLine.toJson()}");
//
//     return super.onLoad();
//   }
//
//   void _initializeControlPoints() {
//     final start = _duplicateLine.start;
//     final end = _duplicateLine.end;
//     final diff = end - start;
//     _controlPoint1 = start + diff / 3.0;
//     _controlPoint2 = start + diff * 2.0 / 3.0;
//     zlog(
//       data:
//           "Initialized Control Points: CP1: $_controlPoint1, CP2: $_controlPoint2",
//     );
//   }
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//     updatePaint();
//   }
//
//   // projectPointOnLineSegment (useful for hit detection)
//   Vector2 projectPointOnLineSegment(
//     Vector2 point,
//     Vector2 lineStart,
//     Vector2 lineEnd,
//   ) {
//     final segmentVector = lineEnd - lineStart;
//     final segmentLengthSquared = segmentVector.length2;
//     if (segmentLengthSquared < 0.000001) {
//       return lineStart;
//     }
//     final pointVector = point - lineStart;
//     double t = pointVector.dot(segmentVector) / segmentLengthSquared;
//     t = t.clamp(0.0, 1.0);
//     final closestPoint = lineStart + segmentVector * t;
//     return closestPoint;
//   }
//
//   // _createDots remains the same as the previous (piecewise linear) version
//   // with free movement for control points.
//   void _createDots() {
//     if (!(_controlPoint1 is Vector2 && _controlPoint2 is Vector2)) {
//       zlog(
//         data:
//             "Warning: Control points not initialized in _createDots. Re-initializing.",
//       );
//       _initializeControlPoints();
//     }
//
//     dots.clear();
//
//     dots = [
//       // Start Dot (index 0)
//       DraggableDot(
//         dotIndex: 0,
//         initialPosition: _duplicateLine.start,
//         radius: circleRadius,
//         onPositionChanged: (newPos) {
//           _duplicateLine.start = newPos;
//           updateLine();
//         },
//         canModifyLine: true,
//         color: Colors.blue,
//       ),
//
//       // Control Point Dot 1 (index 1) - FREE MOVEMENT
//       DraggableDot(
//         dotIndex: 1,
//         initialPosition: _controlPoint1,
//         radius: circleRadius * 0.8,
//         onPositionChanged: (newPos) {
//           _controlPoint1 = newPos;
//           dots[1].position = _controlPoint1;
//         },
//         canModifyLine: true,
//         color: Colors.red,
//       ),
//
//       // Control Point Dot 2 (index 2) - FREE MOVEMENT
//       DraggableDot(
//         dotIndex: 2,
//         initialPosition: _controlPoint2,
//         radius: circleRadius * 0.8,
//         onPositionChanged: (newPos) {
//           _controlPoint2 = newPos;
//           dots[2].position = _controlPoint2;
//         },
//         canModifyLine: true,
//         color: Colors.red,
//       ),
//
//       // End Dot (index 3)
//       DraggableDot(
//         dotIndex: 3,
//         initialPosition: _duplicateLine.end,
//         radius: circleRadius,
//         onPositionChanged: (newPos) {
//           _duplicateLine.end = newPos;
//           updateLine();
//         },
//         canModifyLine: true,
//         color: Colors.blue,
//       ),
//     ];
//     zlog(
//       data:
//           "Created ${dots.length} dots. CP1 Pos: ${dots[1].position}, CP2 Pos: ${dots[2].position}",
//     );
//   }
//
//   // updateLine remains the same as the previous (piecewise linear) version
//   void updateLine() {
//     if (dots.length != 4) {
//       zlog(
//         data:
//             "updateLine called but dots list has unexpected length: ${dots.length}",
//       );
//       return;
//     }
//
//     dots[0].position = _duplicateLine.start;
//     dots[3].position = _duplicateLine.end;
//     dots[1].position = _controlPoint1;
//     dots[2].position = _controlPoint2;
//
//     lineModelV2 = _duplicateLine.copyWith(
//       start:
//           SizeHelper.getBoardRelativeVector(
//             gameScreenSize: game.gameField.size,
//             actualPosition: _duplicateLine.start,
//           ).clone(),
//       end:
//           SizeHelper.getBoardRelativeVector(
//             gameScreenSize: game.gameField.size,
//             actualPosition: _duplicateLine.end,
//           ).clone(),
//     );
//
//     ref.read(boardProvider.notifier).updateLine(line: lineModelV2);
//   }
//
//   // --- MODIFIED: render ---
//   @override
//   void render(Canvas canvas) {
//     final paint = isActive ? _activePaint : _inactivePaint;
//     final start = _duplicateLine.start;
//     final end = _duplicateLine.end;
//     final cp1 = _controlPoint1;
//     final cp2 = _controlPoint2;
//
//     bool canRenderBent = _duplicateLine.lineType == LineType.STRAIGHT_LINE;
//
//     if (canRenderBent) {
//       // --- Render using Catmull-Rom spline (converted to Beziers) ---
//       final path = Path();
//       path.moveTo(start.x, start.y);
//
//       // Define the points for Catmull-Rom calculation
//       // Need points before start and after end - double the endpoints
//       final p0 = start; // Point 0 (Actual Start)
//       final p1 = cp1; // Point 1 (Control Point 1)
//       final p2 = cp2; // Point 2 (Control Point 2)
//       final p3 = end; // Point 3 (Actual End)
//
//       final p_minus_1 = p0; // Point before p0 (doubled start)
//       final p_plus_1 = p3; // Point after p3 (doubled end)
//
//       // Calculate Bezier handles for segment 1 (p0 to p1)
//       // Uses (p_minus_1, p0, p1, p2)
//       final handle1a = p0 + (p1 - p_minus_1) / 6.0;
//       final handle1b = p1 - (p2 - p0) / 6.0;
//       path.cubicTo(handle1a.x, handle1a.y, handle1b.x, handle1b.y, p1.x, p1.y);
//
//       // Calculate Bezier handles for segment 2 (p1 to p2)
//       // Uses (p0, p1, p2, p3)
//       final handle2a = p1 + (p2 - p0) / 6.0;
//       final handle2b = p2 - (p3 - p1) / 6.0;
//       path.cubicTo(handle2a.x, handle2a.y, handle2b.x, handle2b.y, p2.x, p2.y);
//
//       // Calculate Bezier handles for segment 3 (p2 to p3)
//       // Uses (p1, p2, p3, p_plus_1)
//       final handle3a = p2 + (p3 - p1) / 6.0;
//       final handle3b = p3 - (p_plus_1 - p2) / 6.0;
//       path.cubicTo(handle3a.x, handle3a.y, handle3b.x, handle3b.y, p3.x, p3.y);
//
//       canvas.drawPath(path, paint);
//       // --- End Catmull-Rom Rendering ---
//     } else {
//       // Fallback to original rendering (straight line) for non-bendable types
//       if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_DASHED) {
//         _drawDashedLine(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_ZIGZAG) {
//         _drawZigZagLine(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType ==
//           LineType.STRAIGHT_LINE_ZIGZAG_ARROW) {
//         _drawZigZagLineWithArrow(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType == LineType.STRAIGHT_LINE_ARROW) {
//         _drawStraightLineWithArrow(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType ==
//           LineType.STRAIGHT_LINE_ARROW_DOUBLE) {
//         _drawStraightLineWithDoubleArrow(canvas, start, end, paint);
//       } else if (_duplicateLine.lineType == LineType.RIGHT_TURN_ARROW) {
//         _drawRightTurnArrow(canvas, start, end, paint);
//       } else {
//         // Default straight line
//         canvas.drawLine(start.toOffset(), end.toOffset(), paint);
//       }
//     }
//   }
//   // --- End MODIFIED render ---
//
//   // Drawing helper methods (_drawDashedLine, etc.) remain the same
//   // ... (keep all your _draw... methods exactly as they were) ...
//   void _drawDashedLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
//     const dashWidth = 10.0;
//     const dashSpace = 5.0;
//
//     final dx = end.x - start.x;
//     final dy = end.y - start.y;
//     final distance = start.distanceTo(end);
//     if (distance == 0) return; // Avoid division by zero
//     final numDashes = (distance / (dashWidth + dashSpace)).floor();
//     final normalizedDirection = Vector2(dx, dy).normalized();
//
//     for (int i = 0; i < numDashes; i++) {
//       final startOffset =
//           start + normalizedDirection * (i * (dashWidth + dashSpace));
//       final endOffset =
//           start +
//           normalizedDirection * (i * (dashWidth + dashSpace) + dashWidth);
//       canvas.drawLine(startOffset.toOffset(), endOffset.toOffset(), paint);
//     }
//     // Optional: Draw a partial dash at the end if needed
//     final remainingDistance = distance - numDashes * (dashWidth + dashSpace);
//     if (remainingDistance > 0) {
//       final startOffset =
//           start + normalizedDirection * (numDashes * (dashWidth + dashSpace));
//       final endOffset =
//           start +
//           normalizedDirection *
//               (numDashes * (dashWidth + dashSpace) +
//                   math.min(remainingDistance, dashWidth));
//       canvas.drawLine(startOffset.toOffset(), endOffset.toOffset(), paint);
//     }
//   }
//
//   void _drawZigZagLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
//     const amplitude = 5.0; // Reduced for smaller zig-zags
//     const frequency = 10.0; // More frequent zig-zags
//     const dashLength = 10.0; // Length of the starting and ending dashes
//
//     final distance = start.distanceTo(end);
//     if (distance < 2 * dashLength) {
//       // Not enough space for dashes and zig-zag
//       canvas.drawLine(
//         start.toOffset(),
//         end.toOffset(),
//         paint,
//       ); // Draw straight line
//       return;
//     }
//
//     final lineDirection = (end - start).normalized();
//
//     // --- 1. Starting Dash ---
//     final startDashEnd = start + lineDirection * dashLength;
//     canvas.drawLine(start.toOffset(), startDashEnd.toOffset(), paint);
//
//     // --- 2. Zig-Zag ---
//     final zigZagStart = startDashEnd;
//     final zigZagEnd = end - lineDirection * dashLength;
//     final zigZagDistance = zigZagStart.distanceTo(zigZagEnd);
//
//     if (zigZagDistance < frequency) {
//       // Not enough space for even one zig-zag segment
//       canvas.drawLine(
//         zigZagStart.toOffset(),
//         zigZagEnd.toOffset(),
//         paint,
//       ); // Connect dashes
//     } else {
//       final zigZagNumSegments = (zigZagDistance / frequency).floor();
//       final zigZagDirection = (zigZagEnd - zigZagStart).normalized();
//       final perpendicular = Vector2(
//         -zigZagDirection.y,
//         zigZagDirection.x,
//       ); // Perpendicular
//
//       var currentPoint = zigZagStart;
//       for (int i = 0; i < zigZagNumSegments; i++) {
//         final nextPointOnLine = currentPoint + zigZagDirection * frequency;
//         final midPoint = (currentPoint + nextPointOnLine) / 2;
//         final zigZagOffset = perpendicular * amplitude * (i.isEven ? 1 : -1);
//         final zigZagPoint = midPoint + zigZagOffset;
//
//         canvas.drawLine(currentPoint.toOffset(), zigZagPoint.toOffset(), paint);
//         canvas.drawLine(
//           zigZagPoint.toOffset(),
//           nextPointOnLine.toOffset(),
//           paint,
//         );
//         currentPoint = nextPointOnLine;
//       }
//       // Connect the last zig-zag point to the end dash start point
//       canvas.drawLine(currentPoint.toOffset(), zigZagEnd.toOffset(), paint);
//     }
//
//     // --- 3. Ending Dash ---
//     canvas.drawLine(zigZagEnd.toOffset(), end.toOffset(), paint);
//   }
//
//   void _drawZigZagLineWithArrow(
//     Canvas canvas,
//     Vector2 start,
//     Vector2 end,
//     Paint paint,
//   ) {
//     const amplitude = 5.0;
//     const frequency = 10.0;
//     final arrowSize = _duplicateLine.thickness * 4;
//     const dashLength = 10.0;
//
//     final distance = start.distanceTo(end);
//     if (distance < (2 * dashLength + arrowSize)) {
//       // Not enough space
//       _drawStraightLineWithArrow(
//         canvas,
//         start,
//         end,
//         paint,
//       ); // Fallback to straight arrow
//       return;
//     }
//
//     final lineDirection = (end - start).normalized();
//
//     // --- 1. Starting Dash ---
//     final startDashEnd = start + lineDirection * dashLength;
//     canvas.drawLine(start.toOffset(), startDashEnd.toOffset(), paint);
//
//     // --- 2. Zig-Zag ---
//     final zigZagStart = startDashEnd;
//     // Adjust end point for zig-zag to leave space for end dash and arrow
//     final zigZagEnd = end - lineDirection * (dashLength + arrowSize);
//     final zigZagDistance = zigZagStart.distanceTo(zigZagEnd);
//
//     if (zigZagDistance < frequency) {
//       // Not enough space for zig-zag
//       canvas.drawLine(
//         zigZagStart.toOffset(),
//         zigZagEnd.toOffset(),
//         paint,
//       ); // Connect start dash end to where end dash starts
//     } else {
//       final zigZagNumSegments = (zigZagDistance / frequency).floor();
//       final zigZagDirection = (zigZagEnd - zigZagStart).normalized();
//       final perpendicular = Vector2(-zigZagDirection.y, zigZagDirection.x);
//
//       var currentPoint = zigZagStart;
//       for (int i = 0; i < zigZagNumSegments; i++) {
//         final nextPointOnLine = currentPoint + zigZagDirection * frequency;
//         final midPoint = (currentPoint + nextPointOnLine) / 2;
//         final zigZagOffset = perpendicular * amplitude * (i.isEven ? 1 : -1);
//         final zigZagPoint = midPoint + zigZagOffset;
//
//         canvas.drawLine(currentPoint.toOffset(), zigZagPoint.toOffset(), paint);
//         canvas.drawLine(
//           zigZagPoint.toOffset(),
//           nextPointOnLine.toOffset(),
//           paint,
//         );
//         currentPoint = nextPointOnLine;
//       }
//       // Connect the last zig-zag point to the end dash start point
//       canvas.drawLine(currentPoint.toOffset(), zigZagEnd.toOffset(), paint);
//     }
//
//     // --- 3. Ending Dash ---
//     final endDashStart = zigZagEnd; // Where the zig-zag ended
//     final endDashEnd =
//         end - lineDirection * arrowSize; // Where the arrow base will be
//     canvas.drawLine(endDashStart.toOffset(), endDashEnd.toOffset(), paint);
//
//     // --- 4. Arrowhead ---
//     final angle = math.atan2(
//       end.y - start.y,
//       end.x - start.x,
//     ); // Use overall direction for arrow angle
//     // final arrowBase = endDashEnd; // Arrow starts where the end dash finishes
//
//     final path = Path();
//     path.moveTo(
//       end.x - arrowSize * math.cos(angle - math.pi / 6),
//       end.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     path.lineTo(end.x, end.y); // Tip of the arrow at the final end point
//     path.lineTo(
//       end.x - arrowSize * math.cos(angle + math.pi / 6),
//       end.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//
//     // Use fill style for arrowhead for better visibility
//     final arrowPaint =
//         Paint()
//           ..color = paint.color
//           ..style = PaintingStyle.fill; // Changed to fill
//     canvas.drawPath(path, arrowPaint);
//   }
//
//   void _drawStraightLineWithArrow(
//     Canvas canvas,
//     Vector2 start,
//     Vector2 end,
//     Paint paint,
//   ) {
//     final arrowSize = _duplicateLine.thickness * 4;
//     final distance = start.distanceTo(end);
//
//     if (distance < arrowSize) {
//       // If line is shorter than arrow, just draw line
//       canvas.drawLine(start.toOffset(), end.toOffset(), paint);
//       return;
//     }
//
//     final dx = end.x - start.x;
//     final dy = end.y - start.y;
//     final angle = math.atan2(dy, dx);
//     // final lineDirection = Vector2(dx, dy).normalized();
//
//     // --- 1. Draw the line ---
//     // Shorten the line slightly so the arrowhead sits at the end
//     // final lineEnd = end - lineDirection * (arrowSize * 0.5); // Adjust slightly if needed or keep as is
//     canvas.drawLine(
//       start.toOffset(),
//       end.toOffset(),
//       paint,
//     ); // Draw full line for simplicity
//
//     // --- 2. Draw the Arrowhead ---
//     final path = Path();
//     path.moveTo(
//       end.x - arrowSize * math.cos(angle - math.pi / 6),
//       end.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     path.lineTo(end.x, end.y); // Tip of the arrow at the end point
//     path.lineTo(
//       end.x - arrowSize * math.cos(angle + math.pi / 6),
//       end.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//     // path.close(); // Closing might draw an extra line, often not needed for simple arrows
//
//     // Use fill style for arrowhead
//     final arrowPaint =
//         Paint()
//           ..color = paint.color
//           ..style = PaintingStyle.fill;
//     canvas.drawPath(path, arrowPaint);
//   }
//
//   void _drawStraightLineWithDoubleArrow(
//     Canvas canvas,
//     Vector2 start,
//     Vector2 end,
//     Paint paint,
//   ) {
//     final arrowSize = _duplicateLine.thickness * 4;
//     final distance = start.distanceTo(end);
//
//     if (distance < 2 * arrowSize) {
//       // Not enough space for two arrows
//       canvas.drawLine(
//         start.toOffset(),
//         end.toOffset(),
//         paint,
//       ); // Just draw line
//       return;
//     }
//
//     final dx = end.x - start.x;
//     final dy = end.y - start.y;
//     final angle = math.atan2(dy, dx);
//     // final lineDirection = Vector2(dx, dy).normalized();
//
//     // --- 1. Draw the line ---
//     // Shorten line from both ends to make space for arrows visually (optional)
//     // final lineStart = start + lineDirection * (arrowSize * 0.5);
//     // final lineEnd = end - lineDirection * (arrowSize * 0.5);
//     // For simplicity, draw the full line and overlay arrows
//     canvas.drawLine(start.toOffset(), end.toOffset(), paint);
//
//     // Use fill style for arrowheads
//     final arrowPaint =
//         Paint()
//           ..color = paint.color
//           ..style = PaintingStyle.fill;
//
//     // --- 2. Draw the Arrowhead at the end ---
//     final endPath = Path();
//     endPath.moveTo(
//       end.x - arrowSize * math.cos(angle - math.pi / 6),
//       end.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     endPath.lineTo(end.x, end.y);
//     endPath.lineTo(
//       end.x - arrowSize * math.cos(angle + math.pi / 6),
//       end.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//     // endPath.close();
//     canvas.drawPath(endPath, arrowPaint);
//
//     // --- 3. Draw the Arrowhead at the start ---
//     // Angle needs to be reversed for the start arrow
//     final startAngle = math.atan2(
//       start.y - end.y,
//       start.x - end.x,
//     ); // Angle pointing from end to start
//     final startPath = Path();
//     startPath.moveTo(
//       start.x - arrowSize * math.cos(startAngle - math.pi / 6),
//       start.y - arrowSize * math.sin(startAngle - math.pi / 6),
//     );
//     startPath.lineTo(start.x, start.y);
//     startPath.lineTo(
//       start.x - arrowSize * math.cos(startAngle + math.pi / 6),
//       start.y - arrowSize * math.sin(startAngle + math.pi / 6),
//     );
//     // startPath.close();
//     canvas.drawPath(startPath, arrowPaint);
//   }
//
//   void _drawRightTurnArrow(
//     Canvas canvas,
//     Vector2 start,
//     Vector2 end,
//     Paint paint,
//   ) {
//     final arrowSize = _duplicateLine.thickness * 4;
//
//     // Determine corner point C
//     final corner = Vector2(
//       end.x,
//       start.y,
//     ); // Assumes horizontal then vertical turn
//
//     // Handle case where start and corner are the same (vertical line)
//     // or corner and end are the same (horizontal line) -> Draw straight arrow instead
//     if (start.distanceTo(corner) < 0.1 || corner.distanceTo(end) < 0.1) {
//       // Use distance check
//       _drawStraightLineWithArrow(canvas, start, end, paint);
//       return;
//     }
//
//     // --- 1. Draw the line segments ---
//
//     // Draw first segment: start to corner
//     canvas.drawLine(start.toOffset(), corner.toOffset(), paint);
//
//     // Draw second segment: corner to end (leaving space for arrow)
//     // final secondSegmentDirection = (end - corner).normalized();
//     // final arrowBase = end - secondSegmentDirection * (arrowSize * 0.5); // Point before the arrow tip
//     // canvas.drawLine(corner.toOffset(), arrowBase.toOffset(), paint); // Draw up to arrow base
//     canvas.drawLine(
//       corner.toOffset(),
//       end.toOffset(),
//       paint,
//     ); // Draw full second segment
//
//     // --- 2. Draw Arrowhead at the end ---
//     final angle = math.atan2(
//       end.y - corner.y,
//       end.x - corner.x,
//     ); // Angle of the second segment
//
//     final path = Path();
//     path.moveTo(
//       end.x - arrowSize * math.cos(angle - math.pi / 6),
//       end.y - arrowSize * math.sin(angle - math.pi / 6),
//     );
//     path.lineTo(end.x, end.y); // Tip of the arrow
//     path.lineTo(
//       end.x - arrowSize * math.cos(angle + math.pi / 6),
//       end.y - arrowSize * math.sin(angle + math.pi / 6),
//     );
//     // path.close();
//
//     // Use fill style for arrowhead
//     final arrowPaint =
//         Paint()
//           ..color = paint.color
//           ..style = PaintingStyle.fill;
//     canvas.drawPath(path, arrowPaint);
//   }
//
//   // Dragging the whole line logic (should be fine)
//   @override
//   void onDragStart(DragStartEvent event) {
//     if (isActive &&
//         !dots.any((dot) => dot.containsPoint(event.localPosition))) {
//       if (containsLocalPoint(event.localPosition)) {
//         _isDragging = true;
//         event.continuePropagation = false;
//         return;
//       }
//     }
//     event.continuePropagation = true;
//     super.onDragStart(event);
//   }
//
//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     if (_isDragging) {
//       final delta = event.localDelta;
//       _duplicateLine.start += delta;
//       _duplicateLine.end += delta;
//       _controlPoint1 += delta;
//       _controlPoint2 += delta;
//       updateLine();
//       event.continuePropagation = false;
//     } else {
//       event.continuePropagation = true;
//       super.onDragUpdate(event);
//     }
//   }
//
//   @override
//   void onDragEnd(DragEndEvent event) {
//     if (_isDragging) {
//       _isDragging = false;
//       event.continuePropagation = false;
//     } else {
//       event.continuePropagation = true;
//       super.onDragEnd(event);
//     }
//   }
//
//   @override
//   void onDragCancel(DragCancelEvent event) {
//     if (_isDragging) {
//       _isDragging = false;
//       event.continuePropagation = false;
//     } else {
//       event.continuePropagation = true;
//       super.onDragCancel(event);
//     }
//   }
//
//   // Tapping and Activation logic remains the same
//   @override
//   void onTapDown(TapDownEvent event) {
//     if (isActive && dots.any((dot) => dot.containsPoint(event.localPosition))) {
//       event.handled = false;
//       return;
//     }
//     if (containsLocalPoint(event.localPosition)) {
//       _toggleActive();
//       event.handled = true;
//       return;
//     }
//     event.handled = false;
//   }
//
//   @override
//   void onLongTapDown(TapDownEvent event) {
//     if (isActive && dots.any((dot) => dot.containsPoint(event.localPosition))) {
//       event.handled = false;
//       return;
//     }
//     if (containsLocalPoint(event.localPosition)) {
//       _toggleActive();
//       event.handled = true;
//       return;
//     }
//     event.handled = false;
//   }
//
//   void _toggleActive() {
//     ref
//         .read(boardProvider.notifier)
//         .toggleSelectItemEvent(fieldItemModel: lineModelV2);
//   }
//
//   void _updateIsActive(FieldItemModel? item) {
//     final previouslyActive = isActive;
//     isActive = item is LineModelV2 && item.id == lineModelV2.id;
//
//     if (isActive && !previouslyActive) {
//       if (!(_controlPoint1 is Vector2 && _controlPoint2 is Vector2)) {
//         zlog(data: "Control points null on activation, re-initializing.");
//         _initializeControlPoints();
//       }
//       _createDots();
//       addAll(dots);
//       zlog(
//         data:
//             "Line ${lineModelV2.id} Activated. Added ${dots.length} dots. CP1: $_controlPoint1, CP2: $_controlPoint2",
//       );
//     } else if (!isActive && previouslyActive) {
//       try {
//         zlog(
//           data:
//               "Line ${lineModelV2.id} Deactivated. Removing ${dots.length} dots.",
//         );
//         if (dots.isNotEmpty) {
//           removeAll(dots);
//           dots.clear();
//         }
//       } catch (e, s) {
//         zlog(data: "Error removing dots: $e \n$s");
//       }
//     }
//   }
//
//   // containsLocalPoint method (still checks distance to the conceptual segments)
//   // This is now an approximation, but likely sufficient for interaction.
//   @override
//   bool containsLocalPoint(Vector2 point) {
//     final hitAreaWidth = math.max(
//       circleRadius * 1.5,
//       _duplicateLine.thickness * 2.0,
//     );
//
//     final p1 = _duplicateLine.start;
//     final p2 = _controlPoint1;
//     final p3 = _controlPoint2;
//     final p4 = _duplicateLine.end;
//
//     // Check distance to the three line segments (approximation for the curve)
//     if (_distanceToSegment(point, p1, p2) < hitAreaWidth ||
//         _distanceToSegment(point, p2, p3) < hitAreaWidth ||
//         _distanceToSegment(point, p3, p4) < hitAreaWidth) {
//       return true;
//     }
//     return false;
//   }
//
//   double _distanceToSegment(Vector2 p, Vector2 a, Vector2 b) {
//     final l2 = a.distanceToSquared(b);
//     if (l2 == 0.0) return p.distanceTo(a);
//     final t = ((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / l2;
//     final clampedT = t.clamp(0.0, 1.0);
//     final projection = a + (b - a) * clampedT;
//     return p.distanceTo(projection);
//   }
//
//   // updateEnd function is kept as requested
//   void updateEnd(Vector2 currentPoint) {
//     _duplicateLine.end = currentPoint;
//     // updateLine();
//   }
// }

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

  DraggableDot({
    required this.onPositionChanged,
    required this.initialPosition,
    required this.dotIndex,
    this.canModifyLine = true,
    super.radius = 8.0,
    Color color = Colors.blue,
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
    event.continuePropagation = true;
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragStartLocalPosition != null) {
      onPositionChanged(position + event.localDelta);
    }
    event.continuePropagation = true;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _dragStartLocalPosition = null;
    event.continuePropagation = true;
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _dragStartLocalPosition = null;
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
    _controlPoint1 = start + diff / 3.0;
    _controlPoint2 = start + diff * 2.0 / 3.0;
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

  // _createDots remains the same (free movement for control points)
  // void _createDots() {
  //   if (!(_controlPoint1 is Vector2 && _controlPoint2 is Vector2)) {
  //     zlog(
  //       data:
  //           "Warning: Control points not initialized in _createDots. Re-initializing.",
  //     );
  //     _initializeControlPoints();
  //   }
  //   dots.clear();
  //   dots = [
  //     DraggableDot(
  //       dotIndex: 0,
  //       initialPosition: _duplicateLine.start,
  //       radius: circleRadius,
  //       onPositionChanged: (newPos) {
  //         _duplicateLine.start = newPos;
  //         updateLine();
  //       },
  //       canModifyLine: true,
  //       color: Colors.blue,
  //     ),
  //     DraggableDot(
  //       dotIndex: 1,
  //       initialPosition: _controlPoint1,
  //       radius: circleRadius * 0.8,
  //       onPositionChanged: (newPos) {
  //         _controlPoint1 = newPos;
  //         dots[1].position = _controlPoint1;
  //       },
  //       canModifyLine: true,
  //       color: Colors.red,
  //     ),
  //     DraggableDot(
  //       dotIndex: 2,
  //       initialPosition: _controlPoint2,
  //       radius: circleRadius * 0.8,
  //       onPositionChanged: (newPos) {
  //         _controlPoint2 = newPos;
  //         dots[2].position = _controlPoint2;
  //       },
  //       canModifyLine: true,
  //       color: Colors.red,
  //     ),
  //     DraggableDot(
  //       dotIndex: 3,
  //       initialPosition: _duplicateLine.end,
  //       radius: circleRadius,
  //       onPositionChanged: (newPos) {
  //         _duplicateLine.end = newPos;
  //         updateLine();
  //       },
  //       canModifyLine: true,
  //       color: Colors.blue,
  //     ),
  //   ];
  //   zlog(
  //     data:
  //         "Created ${dots.length} dots. CP1 Pos: ${dots[1].position}, CP2 Pos: ${dots[2].position}",
  //   );
  // }

  // Inside LineDrawerComponentV2 class -> _createDots method

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

  // updateLine remains the same
  // void updateLine() {
  //   if (dots.length != 4) {
  //     zlog(
  //       data:
  //           "updateLine called but dots list has unexpected length: ${dots.length}",
  //     );
  //     return;
  //   }
  //   dots[0].position = _duplicateLine.start;
  //   dots[3].position = _duplicateLine.end;
  //   dots[1].position = _controlPoint1;
  //   dots[2].position = _controlPoint2;
  //   lineModelV2 = _duplicateLine.copyWith(
  //     start:
  //         SizeHelper.getBoardRelativeVector(
  //           gameScreenSize: game.gameField.size,
  //           actualPosition: _duplicateLine.start,
  //         ).clone(),
  //     end:
  //         SizeHelper.getBoardRelativeVector(
  //           gameScreenSize: game.gameField.size,
  //           actualPosition: _duplicateLine.end,
  //         ).clone(),
  //   );
  //   ref.read(boardProvider.notifier).updateLine(line: lineModelV2);
  // }

  // Inside LineDrawerComponentV2 class

  // Inside LineDrawerComponentV2 class

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
        // Draw plain middle segment, arrows on first and last
        // Need a helper to draw arrow at the *start* of a segment
        _drawArrowHead(
          canvas,
          start,
          cp1 - start,
          paint,
        ); // Arrow head at start
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
        _drawStraightLineWithArrow(
          canvas,
          cp2,
          end,
          paint,
        ); // Line segment 3 + Arrow head at end
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

  // _drawStraightLineWithDoubleArrow is now handled differently in main render method
  // We keep the helper just in case, but it's not directly used for bent lines.
  void _drawStraightLineWithDoubleArrow(
    Canvas canvas,
    Vector2 start,
    Vector2 end,
    Paint paint,
  ) {
    final distance = start.distanceTo(end);
    if (distance < 0.1) return;

    final arrowSize = _duplicateLine.thickness * 4;

    if (distance < 2 * arrowSize) {
      canvas.drawLine(start.toOffset(), end.toOffset(), paint);
      return;
    }
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
    _drawArrowHead(canvas, end, end - start, paint);
    _drawArrowHead(
      canvas,
      start,
      start - end,
      paint,
    ); // Arrow pointing backward
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
    // updateLine();
  }
}
