import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'field_component.dart';

class DraggableCircleComponent extends CircleComponent with DragCallbacks {
  final FieldComponent component;
  final double rotationSpeed;

  DraggableCircleComponent({
    required this.component,
    required this.rotationSpeed,
    super.position,
  }) : super(
         radius: 8,
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
}
