import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';

import 'field_component.dart';

enum ScalingHandlePosition { TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT }

class ScalingHandle extends CircleComponent with DragCallbacks {
  final FieldComponent component;

  final ScalingHandlePosition scalingHandlePosition;

  final Color color;
  final double interactionRadius = 15.0;

  ScalingHandle({
    required this.component,
    required super.anchor,
    required this.scalingHandlePosition,
    this.color = const Color(0xFF00FF00),
  }) : super(radius: 6.0, paint: Paint()..color = color) {
    // add(
    //   CircleHitbox(
    //     radius: interactionRadius,
    //     anchor: Anchor.center,
    //     isSolid: true,
    //   ),
    // );
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.length <= interactionRadius;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    Vector2 delta = event.localDelta;

    // Calculate scaling factor based on drag direction and anchor
    double scaleX = 1.0;
    double scaleY = 1.0;

    if (scalingHandlePosition == ScalingHandlePosition.TOP_RIGHT) {
      delta.y *= -1;
    } else if (scalingHandlePosition == ScalingHandlePosition.BOTTOM_LEFT) {
      delta.x *= -1;
    } else if (scalingHandlePosition == ScalingHandlePosition.TOP_LEFT) {
      delta *= -1;
    }

    scaleX += delta.x / component.size.x;
    scaleY += delta.y / component.size.y;

    // Apply scaling to the player component
    component.size.x *= scaleX;
    component.size.y *= scaleY;

    // Ensure size doesn't become negative or too small
    component.size.x = component.size.x.clamp(10, double.infinity);
    component.size.y = component.size.y.clamp(10, double.infinity);

    // Update the selection border size
    component.selectionBorder?.size = component.size + Vector2.all(20);

    // Update the selection border's position
    component.selectionBorder?.position.setFrom(
      Vector2(component.size.x / 2, component.size.y / 2),
    );
    component.onComponentScale(component.size);
  }
}
