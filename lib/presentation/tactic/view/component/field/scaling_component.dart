import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

import 'field_component.dart';

class ScalingHandle extends CircleComponent with DragCallbacks {
  final FieldComponent component;
  final Anchor anchor;
  final Color color;

  ScalingHandle({
    required this.component,
    required this.anchor,
    this.color = const Color(0xFF00FF00),
  }) : super(radius: 6, paint: Paint()..color = color, anchor: anchor);

  @override
  void onDragUpdate(DragUpdateEvent event) {
    Vector2 delta = event.localDelta;
    zlog(data: "Dragging the scale ${delta}");

    // Calculate scaling factor based on drag direction and anchor
    double scaleX = 1.0;
    double scaleY = 1.0;

    if (anchor == Anchor.topLeft || anchor == Anchor.bottomLeft) {
      scaleX -= delta.x / component.size.x;
    } else {
      scaleX += delta.x / component.size.x;
    }

    if (anchor == Anchor.topLeft || anchor == Anchor.topRight) {
      scaleY -= delta.y / component.size.y;
    } else {
      scaleY += delta.y / component.size.y;
    }

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

    // Update handle positions
    component.selectionBorder?.updateHandlePositions();
  }
}
