// Selection border for field components
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/rotation_handle_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/scaling_component.dart';

import 'field_component.dart';

class SelectionBorder extends RectangleComponent {
  FieldComponent component;
  final bool symmetrically; // Add this parameter

  SelectionBorder({required this.component, required this.symmetrically})
    : super(
        size: component.size,
        anchor: Anchor.center,
        position: Vector2(component.size.x / 2, component.size.y / 2),
        paint:
            Paint()
              ..color = const Color(0xFF00FF00)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5,
        priority: 2,
      ) {
    add(RotationHandle(component)..position = Vector2(size.x / 2, 0));

    // List<Vector2> vertices = getVertices();
    //
    // Vector2 topLeft = vertices[0];
    // Vector2 topRight = vertices[1];
    // Vector2 bottomLeft = vertices[2];
    // Vector2 bottomRight = vertices[3];
    //
    // add(
    //   ScalingHandle(
    //     component: component,
    //     anchor: Anchor.topLeft,
    //     color: Colors.black,
    //   )..position = topLeft,
    // );
    // add(
    //   ScalingHandle(
    //     component: component,
    //     anchor: Anchor.topRight,
    //     color: Colors.black,
    //   )..position = topRight,
    // );
    // add(
    //   ScalingHandle(
    //     component: component,
    //     anchor: Anchor.bottomLeft,
    //     color: Colors.black,
    //   )..position = bottomLeft,
    // );
    // add(
    //   ScalingHandle(
    //     component: component,
    //     anchor: Anchor.bottomRight,
    //     color: Colors.black,
    //   )..position = bottomRight,
    // );
  }

  @override
  update(double dt) {
    size = component.size;
    anchor = Anchor.center;
    position = Vector2(component.size.x / 2, component.size.y / 2);
    paint =
        Paint()
          ..color = const Color(0xFF00FF00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
    priority = 2;
  }

  List<Vector2> getVertices() {
    return [
      Vector2(-10, -10),
      Vector2(size.x + 10, -10),
      Vector2(-10, size.y + 10),
      Vector2(size.x + 10, size.y + 10),
    ];
  }

  void updateHandlePositions() {
    List<Vector2> vertices = getVertices();

    Vector2 topLeft = vertices[0];
    Vector2 topRight = vertices[1];
    Vector2 bottomLeft = vertices[2];
    Vector2 bottomRight = vertices[3];

    children.whereType<ScalingHandle>().toList()[0]
      ..position.setFrom(topLeft)
      ..anchor = Anchor.topLeft;
    children.whereType<ScalingHandle>().toList()[1]
      ..anchor = Anchor.topRight
      ..position.setFrom(topRight);
    children.whereType<ScalingHandle>().toList()[2]
      ..anchor = Anchor.bottomLeft
      ..position.setFrom(bottomLeft);
    children.whereType<ScalingHandle>().toList()[3]
      ..anchor = Anchor.bottomRight
      ..position.setFrom(bottomRight);

    children.whereType<RotationHandle>().first.position.setFrom(
      Vector2(size.x / 2, 0),
    );
  }
}
