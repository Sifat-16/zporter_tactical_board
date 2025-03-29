import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

import 'mini_game_field_painter.dart';

class MiniGameFieldWidget extends StatelessWidget {
  // Removed width and height, added aspectRatio
  final double aspectRatio;
  final Color fieldColor;
  final Color borderColor;

  // Standard field aspect ratio (e.g., ~105m x 68m = ~1.54)
  // You can adjust this default or pass a specific one when creating the widget
  static const double defaultAspectRatio = 105 / 68;

  const MiniGameFieldWidget({
    super.key,
    this.aspectRatio = defaultAspectRatio,
    this.fieldColor = ColorManager.grey,
    this.borderColor = ColorManager.black,
  });

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder gives us the constraints from the parent widget
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if the parent provided a bounded width
        if (!constraints.hasBoundedWidth || constraints.maxWidth.isInfinite) {
          // If width is infinite (e.g., directly in a Row without Expanded/Flexible),
          // AspectRatio doesn't know what size to be. We must provide a fallback
          // or let it potentially cause an error. Let's provide a fallback SizedBox.
          print(
            "Warning: MiniGameFieldWidget parent has unconstrained width. Using fallback width 100.",
          );
          const fallbackWidth = 100.0;
          final fallbackHeight = fallbackWidth / aspectRatio;
          // Return a SizedBox containing the CustomPaint with calculated fallback size
          return SizedBox(
            width: fallbackWidth,
            height: fallbackHeight,
            child: CustomPaint(
              painter: MiniGameFieldPainter(
                fieldColor: fieldColor,
                borderColor: borderColor,
              ),
            ),
          );
        }

        // If width is bounded, AspectRatio will use the maxWidth
        // and calculate the height to maintain the specified ratio.
        return AspectRatio(
          aspectRatio: aspectRatio,
          // CustomPaint will automatically fill the size provided by AspectRatio
          child: CustomPaint(
            painter: MiniGameFieldPainter(
              // Painter now only needs colors
              fieldColor: fieldColor,
              borderColor: borderColor,
            ),
          ),
        );
      },
    );
  }
}
