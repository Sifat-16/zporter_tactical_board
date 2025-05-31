import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'field_component.dart';

class DraggableCircleComponent extends CircleComponent with DragCallbacks {
  final FieldComponent component;
  final double rotationSpeed;

  // --- Define visual size vs. hit area ---
  static const double _visualRadius =
      7.0; // Keep this as the desired visual size
  // Increase this padding value to make the tap/drag area larger
  static const double _hitRadiusPadding =
      12.0; // <-- INCREASED VALUE (e.g., from 8.0 to 12.0)
  static const double _effectiveHitRadius = _visualRadius + _hitRadiusPadding;

  DraggableCircleComponent({
    required this.component,
    required this.rotationSpeed,
    super.position,
  }) : super(
          radius: _visualRadius,
          paint: Paint()..color = const Color(0xFF00FF00),
          anchor: Anchor.center,
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
    Vector2 delta = event.localDelta;
    double angle = delta.screenAngle();
    component.angle += angle * rotationSpeed;
    component.onRotationUpdate();
    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!component.isSelected) return;
    super.onDragEnd(event);
    component.setRotationHandleDragged(false);
    event.continuePropagation = false;
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
    return point.length <=
        _effectiveHitRadius; // <-- Checks against the LARGER radius
  }
}

class DraggableRectangleComponent extends RectangleComponent
    with DragCallbacks {
  final FieldComponent component;
  final double rotationSpeed;

  // --- Define visual size vs. hit area ---
  // Visual size of the rectangle
  static final Vector2 _visualSize = Vector2(8.0, 8.0); // e.g., a 14x14 square
  // Radius for a circular hit area around the rectangle's anchor.
  // This provides a larger, circular tap/drag area.
  static const double _effectiveHitRadius = 20.0; // Adjust as needed

  DraggableRectangleComponent({
    required this.component,
    required this.rotationSpeed,
    super.position, // Position of the rectangle's anchor
    Color? color, // Optional color for the rectangle
  }) : super(
          size: _visualSize,
          paint: Paint()
            ..style = PaintingStyle.stroke
            ..color = color ?? const Color(0xFF00FF00), // Default to green
          anchor: Anchor.bottomCenter, // Center the rectangle on its position
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
    Vector2 delta = event.localDelta;
    // Using screenAngle from localDelta might be sensitive;
    // often, calculating angle relative to the component's center is more robust.
    // However, to keep logic identical to DraggableCircleComponent:
    double angleChange = delta.screenAngle();

    // The original code uses event.localDelta.screenAngle().
    // This angle is the direction of the drag movement in screen coordinates.
    // It might not be the most intuitive way to control rotation if the
    // draggable handle itself is rotating with the component.
    // A common alternative is to calculate the angle from the component's center
    // to the drag point.
    // For now, keeping it consistent with your DraggableCircleComponent:
    component.angle += angleChange * rotationSpeed;
    component.onRotationUpdate();
    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!component.isSelected) return;
    super.onDragEnd(event);
    component.setRotationHandleDragged(false);
    event.continuePropagation = false;
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
    // Checks against the circular effective hit radius centered on the rectangle's anchor.
    // 'point' is in local coordinates. Since anchor is Anchor.center,
    // (0,0) is the center of the rectangle.
    return point.length <= _effectiveHitRadius;
  }
}
