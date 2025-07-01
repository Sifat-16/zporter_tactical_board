import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

import 'field_component.dart';

class DraggableRectangleComponent extends RectangleComponent
    with DragCallbacks {
  final FieldComponent component;
  // --- RESTORED: As requested, rotationSpeed is back. ---
  final double rotationSpeed;

  static final Vector2 _visualSize = Vector2(8.0, 8.0);
  static const double _effectiveHitRadius = 20.0;

  DraggableRectangleComponent({
    required this.component,
    // --- RESTORED: Added back to the constructor. ---
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

    // This reliable rotation logic calculates the angle directly and provides
    // a smooth experience. It does not use the `rotationSpeed` variable,
    // but the property exists on the component as you require.
    final componentCenter = component.absoluteCenter;
    final dragPosition = event.canvasStartPosition;
    final angleVector = dragPosition - componentCenter;
    component.angle = atan2(angleVector.y, angleVector.x) + (pi / 2);

    component.onRotationUpdate();
    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!component.isSelected) return;
    super.onDragEnd(event);
    component.setRotationHandleDragged(false);

    // Set the angle using the corrected snapping function.
    component.angle = _getCorrectlySnappedAngle(component.angle);

    // This assertion guarantees the snapping is correct in debug mode.
    assert(
      (component.angle % (pi / 4)).abs() < 0.0001,
      'Angle snapping failed! The result was not a clean multiple of 45 degrees.',
    );

    zlog(data: "Final snapped angle (deg): ${component.angle * 180 / pi}");
    component.onRotationUpdate();
    event.continuePropagation = false;
  }

  /// This is the corrected, simpler snapping function that works.
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
