import 'package:flame/extensions.dart'; // For Vector2
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust import path
// Import models
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart'; // Adjust import path

// Import painter
import 'mini_game_field_painter.dart'; // Adjust import path

class MiniGameFieldWidget extends StatelessWidget {
  final double aspectRatio;
  final Color fieldColor;
  final Color borderColor;
  // --- NEW PROPERTIES ---
  /// The list of items (players, equipment, forms) to display.
  final List<FieldItemModel> items;

  /// The logical "world" size of the main tactical board these items relate to.
  final Vector2 logicalFieldSize;

  static const double defaultAspectRatio = 105 / 68; // Example default

  const MiniGameFieldWidget({
    super.key,
    this.aspectRatio = defaultAspectRatio,
    this.fieldColor =
        ColorManager.grey, // Ensure ColorManager is defined/imported
    this.borderColor =
        ColorManager.black, // Ensure ColorManager is defined/imported
    required this.items, // Items are required
    required this.logicalFieldSize, // Reference size is required
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate actual dimensions based on constraints and aspect ratio
        double actualWidth;
        double actualHeight;

        // Prioritize using parent's width if available and bounded
        if (constraints.hasBoundedWidth && !constraints.maxWidth.isInfinite) {
          actualWidth = constraints.maxWidth;
          actualHeight = actualWidth / aspectRatio;
          // Adjust if height becomes too large for parent's height constraint
          if (constraints.hasBoundedHeight &&
              actualHeight > constraints.maxHeight) {
            actualHeight = constraints.maxHeight;
            actualWidth = actualHeight * aspectRatio;
          }
        }
        // Else if parent's height is bounded, calculate width from height
        else if (constraints.hasBoundedHeight &&
            !constraints.maxHeight.isInfinite) {
          actualHeight = constraints.maxHeight;
          actualWidth = actualHeight * aspectRatio;
        }
        // Fallback if both width and height are unconstrained
        else {
          print(
            "Warning: MiniGameFieldWidget parent has unconstrained dimensions. Using fallback width 100.",
          );
          actualWidth = 100.0;
          actualHeight = actualWidth / aspectRatio;
        }

        // Use SizedBox to enforce the calculated size for the CustomPaint
        return SizedBox(
          width: actualWidth,
          height: actualHeight,
          child: CustomPaint(
            // Pass all necessary data to the painter
            painter: MiniGameFieldPainter(
              fieldColor: fieldColor,
              borderColor: borderColor,
              items: items, // Pass the items
              logicalFieldSize: logicalFieldSize, // Pass the reference size
            ),
          ),
        );
      },
    );
  }
}
