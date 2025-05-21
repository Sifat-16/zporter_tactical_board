// Selection border for field components
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/rotation_handle_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/scaling_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/text_field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';

import 'field_component.dart';

class SelectionBorder extends RectangleComponent {
  FieldComponent component;
  final bool symmetrically; // Add this parameter

  SelectionBorder({required this.component, required this.symmetrically})
    : super(
        size: component.size + Vector2.all(10),
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

    // Add the four scaling handles (dots) at the corners
    // Assuming ScalingHandle takes the parent FieldComponent

    zlog(
      data:
          "Check the element type of the field component ${component.runtimeType}",
    );

    if (component is EquipmentComponent ||
        component is PlayerComponent ||
        component is TextFieldComponent) {
      add(
        ScalingHandle(
          component: component,
          anchor: Anchor.center,
          scalingHandlePosition: ScalingHandlePosition.TOP_LEFT,
        )..position = Vector2(-0, -0), // Top-Left
        // Assuming the dot should be centered on the corner
      );
      add(
        ScalingHandle(
          component: component,
          anchor: Anchor.center,
          scalingHandlePosition: ScalingHandlePosition.TOP_RIGHT,
        )..position = Vector2(size.x, -0), // Top-Right
      );
      add(
        ScalingHandle(
          component: component,
          anchor: Anchor.center,
          scalingHandlePosition: ScalingHandlePosition.BOTTOM_LEFT,
        )..position = Vector2(-0, size.y), // Bottom-Left
      );
      add(
        ScalingHandle(
          component: component,
          anchor: Anchor.center,
          scalingHandlePosition: ScalingHandlePosition.BOTTOM_RIGHT,
        )..position = Vector2(size.x, size.y), // Bottom-Right
      );
    }
  }

  @override
  update(double dt) {
    size = component.size + Vector2.all(10);
    anchor = Anchor.center;
    position = Vector2(component.size.x / 2, component.size.y / 2);
    paint =
        Paint()
          ..color = const Color(0xFF00FF00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
    priority = 2;
    if (component is EquipmentComponent ||
        component is PlayerComponent ||
        component is TextFieldComponent) {
      updateHandlePositions();
    }
  }

  void updateHandlePositions() {
    // Get all scaling handles and the rotation handle
    final scalingHandles = children.whereType<ScalingHandle>().toList();
    final rotationHandle =
        children
            .whereType<RotationHandle>()
            .firstOrNull; // Use firstOrNull for safety

    // Ensure we have the expected number of scaling handles
    if (scalingHandles.length == 4) {
      // Update positions relative to the parent's center anchor.
      // We assume the order they were added is TL, TR, BL, BR.
      // Keep their own anchor as Anchor.center (set during creation).
      scalingHandles[0].position.setValues(-0, -0); // Top-Left
      scalingHandles[1].position.setValues(size.x, -0); // Top-Right
      scalingHandles[2].position.setValues(-0, size.y); // Bottom-Left
      scalingHandles[3].position.setValues(size.x, size.y); // Bottom-Right
    } else {
      // Optional: Log an error or handle the case where handles are missing
      print(
        "Warning: Expected 4 ScalingHandles, found ${scalingHandles.length}",
      );
    }
  }
}
