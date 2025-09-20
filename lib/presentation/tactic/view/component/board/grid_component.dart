// import 'package:flame/components.dart';
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
//
// class GridComponent extends PositionComponent {
//   GridComponent({
//     this.gridSize = 50.0,
//     this.gridColor = ColorManager.yellow,
//     this.gridOpacity = 0.4,
//   }) : super(
//           priority: -1,
//           anchor: Anchor.topLeft,
//           position: Vector2.zero(),
//         );
//
//   final double gridSize;
//   final Color gridColor;
//   final double gridOpacity;
//   late Paint _paint;
//
//   // --- THIS IS THE FIX ---
//   // We are adding the isHidden property that was missing.
//   // It defaults to true, so the grid is hidden initially.
//   bool isHidden = true;
//   // --- END FIX ---
//
//   @override
//   Future<void> onLoad() async {
//     _paint = Paint()
//       ..color = gridColor.withOpacity(gridOpacity)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.0;
//   }
//
//   // @override
//   // void render(Canvas canvas) {
//   //   // --- THIS IS THE OTHER PART OF THE FIX ---
//   //   // If the component is hidden, we stop the render method immediately.
//   //   if (isHidden) {
//   //     return;
//   //   }
//   //   // --- END FIX ---
//   //
//   //   if (size.isZero()) return;
//   //
//   //   // Draw vertical lines
//   //   for (double x = 0; x <= size.x; x += gridSize) {
//   //     canvas.drawLine(Offset(x, 0), Offset(x, size.y), _paint);
//   //   }
//   //
//   //   // Draw horizontal lines
//   //   for (double y = 0; y <= size.y; y += gridSize) {
//   //     canvas.drawLine(Offset(0, y), Offset(size.x, y), _paint);
//   //   }
//   // }
//
//   @override
//   void render(Canvas canvas) {
//     if (isHidden) {
//       return;
//     }
//     if (size.isZero()) return;
//
//     final double centerX = size.x / 2;
//     final double centerY = size.y / 2;
//
//     // Draw vertical lines
//     // Draw lines to the right of center
//     for (double x = centerX; x <= size.x; x += gridSize) {
//       canvas.drawLine(Offset(x, 0), Offset(x, size.y), _paint);
//     }
//     // Draw lines to the left of center
//     for (double x = centerX - gridSize; x >= 0; x -= gridSize) {
//       canvas.drawLine(Offset(x, 0), Offset(x, size.y), _paint);
//     }
//
//     // Draw horizontal lines
//     // Draw lines below center
//     for (double y = centerY; y <= size.y; y += gridSize) {
//       canvas.drawLine(Offset(0, y), Offset(size.x, y), _paint);
//     }
//     // Draw lines above center
//     for (double y = centerY - gridSize; y >= 0; y -= gridSize) {
//       canvas.drawLine(Offset(0, y), Offset(size.x, y), _paint);
//     }
//   }
//
//   @override
//   bool get isRepaintBoundary => true;
// }

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart'; // <-- ADD IMPORT
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart'; // <-- ADD IMPORT
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart'; // <-- ADD IMPORT

class GridComponent extends PositionComponent with RiverpodComponentMixin {
  // <-- ADD MIXIN
  GridComponent({
    // REMOVE gridSize from constructor
    this.gridColor = ColorManager.yellow,
    this.gridOpacity = 0.4,
  }) : super(
          priority: -1,
          anchor: Anchor.topLeft,
          position: Vector2.zero(),
        );

  bool isHidden = true;

  // REMOVE final double gridSize;
  final Color gridColor;
  final double gridOpacity;
  late Paint _paint;

  @override
  Future<void> onLoad() async {
    _paint = Paint()
      ..color = gridColor.withOpacity(gridOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
  }

  @override
  void render(Canvas canvas) {
    if (isHidden) {
      return;
    }

    // --- ADD THIS LOGIC ---
    // Read the gridSize directly from the provider every frame.
    final double gridSize = ref.watch(boardProvider.select((s) => s.gridSize));
    // --- END ADD ---

    if (size.isZero() || gridSize <= 0) return;

    final double centerX = size.x / 2;
    final double centerY = size.y / 2;

    // Draw vertical lines
    for (double x = centerX; x <= size.x; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _paint);
    }
    for (double x = centerX - gridSize; x >= 0; x -= gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _paint);
    }

    // Draw horizontal lines
    for (double y = centerY; y <= size.y; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _paint);
    }
    for (double y = centerY - gridSize; y >= 0; y -= gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _paint);
    }
  }

  @override
  bool get isRepaintBoundary => true;
}
