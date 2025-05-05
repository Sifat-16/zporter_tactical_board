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
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!component.isSelected) return;
    Vector2 delta = event.localDelta;
    double angle = delta.screenAngle();
    component.angle += angle * rotationSpeed;
    component.onRotationUpdate();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!component.isSelected) return;
    super.onDragEnd(event);
    component.setRotationHandleDragged(false);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (!component.isSelected) return;
    super.onDragCancel(event);
    component.setRotationHandleDragged(false);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.length <=
        _effectiveHitRadius; // <-- Checks against the LARGER radius
  }
}
