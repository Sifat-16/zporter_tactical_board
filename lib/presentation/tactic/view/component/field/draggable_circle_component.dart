// import 'dart:math';
// import 'dart:ui';
//
// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
//
// import 'field_component.dart';
//
// class DraggableRectangleComponent extends RectangleComponent
//     with DragCallbacks {
//   final FieldComponent component;
//   // --- RESTORED: As requested, rotationSpeed is back. ---
//   final double rotationSpeed;
//
//   static final Vector2 _visualSize = Vector2(8.0, 8.0);
//   static const double _effectiveHitRadius = 20.0;
//
//   DraggableRectangleComponent({
//     required this.component,
//     // --- RESTORED: Added back to the constructor. ---
//     required this.rotationSpeed,
//     super.position,
//     Color? color,
//   }) : super(
//           size: _visualSize,
//           paint: Paint()
//             ..style = PaintingStyle.stroke
//             ..color = color ?? const Color(0xFF00FF00),
//           anchor: Anchor.bottomCenter,
//         );
//
//   @override
//   void onDragStart(DragStartEvent event) {
//     if (!component.isSelected) return;
//     super.onDragStart(event);
//     component.setRotationHandleDragged(true);
//     event.continuePropagation = false;
//   }
//
//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     if (!component.isSelected) return;
//
//     // This reliable rotation logic calculates the angle directly and provides
//     // a smooth experience. It does not use the `rotationSpeed` variable,
//     // but the property exists on the component as you require.
//     final componentCenter = component.absoluteCenter;
//     final dragPosition = event.canvasStartPosition;
//     final angleVector = dragPosition - componentCenter;
//     component.angle = atan2(angleVector.y, angleVector.x) + (pi / 2);
//
//     component.onRotationUpdate();
//     event.continuePropagation = false;
//   }
//
//   @override
//   void onDragEnd(DragEndEvent event) {
//     if (!component.isSelected) return;
//     super.onDragEnd(event);
//     component.setRotationHandleDragged(false);
//
//     // Set the angle using the corrected snapping function.
//     component.angle = _getCorrectlySnappedAngle(component.angle);
//
//     // This assertion guarantees the snapping is correct in debug mode.
//     assert(
//       (component.angle % (pi / 4)).abs() < 0.0001,
//       'Angle snapping failed! The result was not a clean multiple of 45 degrees.',
//     );
//
//     zlog(data: "Final snapped angle (deg): ${component.angle * 180 / pi}");
//     component.onRotationUpdate();
//     event.continuePropagation = false;
//   }
//
//   /// This is the corrected, simpler snapping function that works.
//   double _getCorrectlySnappedAngle(double currentAngleInRadians) {
//     const double snapAngle = pi / 4; // 45 degrees
//     final double snappedAngle =
//         (currentAngleInRadians / snapAngle).round() * snapAngle;
//     return snappedAngle;
//   }
//
//   @override
//   void onDragCancel(DragCancelEvent event) {
//     if (!component.isSelected) return;
//     super.onDragCancel(event);
//     component.setRotationHandleDragged(false);
//     event.continuePropagation = false;
//   }
//
//   @override
//   bool containsLocalPoint(Vector2 point) {
//     return point.length <= _effectiveHitRadius;
//   }
// }

import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'field_component.dart'; // Ensure FieldComponent has the onRotationUpdate method

class DraggableRectangleComponent extends RectangleComponent
    with DragCallbacks {
  final FieldComponent component;
  final double rotationSpeed;

  static final Vector2 _visualSize = Vector2(8.0, 8.0);
  static const double _effectiveHitRadius = 20.0;

  DraggableRectangleComponent({
    required this.component,
    required this.rotationSpeed,
    super.position,
    Color? color,
  }) : super(
          size: _visualSize,
          paint: Paint()
            ..style = PaintingStyle.stroke
            ..color = color ?? const Color(0xFF00FF00),
          anchor: Anchor.bottomCenter,
        );

  @override
  void onDragStart(DragStartEvent event) {
    if (!component.isSelected) return;
    super.onDragStart(event);
    component.setRotationHandleDragged(true);
    event.continuePropagation = false;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!component.isSelected) return;

    final componentCenter = component.absoluteCenter;
    final dragPosition = event.canvasStartPosition;
    final angleVector = dragPosition - componentCenter;
    // Visually update the component's angle during the drag
    component.angle = atan2(angleVector.y, angleVector.x) + (pi / 2);

    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!component.isSelected) return;
    super.onDragEnd(event);
    component.setRotationHandleDragged(false);

    // Snap the angle to the nearest 45 degrees
    final double snappedAngle = _getCorrectlySnappedAngle(component.angle);
    component.angle = snappedAngle;

    // Notify the parent component of the final rotation, which then notifies the provider
    final angleInDegrees = snappedAngle * 180 / pi;
    component.onRotationUpdate(angleInDegrees);

    zlog(data: "Final snapped angle (deg): $angleInDegrees");
    event.continuePropagation = false;
  }

  double _getCorrectlySnappedAngle(double currentAngleInRadians) {
    const double snapAngle = pi / 4; // 45 degrees
    final double snappedAngle =
        (currentAngleInRadians / snapAngle).round() * snapAngle;
    return snappedAngle;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (!component.isSelected) return;
    super.onDragCancel(event);
    component.setRotationHandleDragged(false);
    event.continuePropagation = false;
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.length <= _effectiveHitRadius;
  }
}

// --- RotationHandle and other helpers in this file ---
// These are mostly containers and require no changes.

class RotationHandle extends PositionComponent {
  final FieldComponent component;
  final double rotationSpeed = 0.08;

  RotationHandle(this.component)
      : super(anchor: Anchor.bottomCenter, priority: 3) {
    add(
      CustomPaintComponent(
        painter: LinePainter(),
        size: Vector2(0, 20),
        anchor: Anchor.bottomCenter,
      ),
    );
    add(
      DraggableRectangleComponent(
        component: component,
        rotationSpeed: rotationSpeed,
        position: Vector2(0, -20),
      ),
    );
  }

  @override
  void update(double dt) {
    position = Vector2((component.size.x / 2) + 5, 0);
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(0, 0), Offset(0, -size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CustomPaintComponent extends Component {
  final CustomPainter painter;
  final Vector2 size;
  final Anchor anchor;

  CustomPaintComponent({
    required this.painter,
    required this.size,
    required this.anchor,
  });

  @override
  void render(Canvas canvas) {
    final offset = anchor.toVector2();
    canvas.save();
    canvas.translate(offset.x, offset.y);
    painter.paint(canvas, Size(size.x, size.y));
    canvas.restore();
  }
}
