// import 'dart:async';
// import 'dart:ui' as ui;
//
// import 'package:flame/components.dart';
// import 'package:flame_riverpod/flame_riverpod.dart';
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/app/manager/values_manager.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
//
// class GameField extends PositionComponent
//     with HasGameReference, RiverpodComponentMixin {
//   GameField({required Vector2 size, this.initialColor}) : super(size: size);
//   final Color? initialColor;
//   // Measurements
//   late double centerCircleRadius;
//   late double penaltyBoxWidth;
//   late double penaltyBoxHeight;
//   late double goalBoxWidth;
//   late double goalBoxHeight;
//   late double penaltySpotRadius;
//
//   ui.Image? _logoImage;
//
//   final Paint _borderPaint = Paint()
//     ..color = ColorManager.black
//     ..style = PaintingStyle.stroke
//     ..strokeWidth = 1;
//
//   final Paint _fillPaint = Paint()
//     ..color = ColorManager.black
//     ..style = PaintingStyle.fill
//     ..strokeWidth = 1;
//
//   final Paint _fieldPaint = Paint()..color = ColorManager.grey; // Green Field
//
//   @override
//   FutureOr<void> onLoad() async {
//     addToGameWidgetBuild(() {
//       ref.listen(boardProvider, (previous, current) {
//         _fieldPaint.color = current.boardColor;
//       });
//     });
//
//     _fieldPaint.color = initialColor ?? ColorManager.grey;
//
//     _initializePosition();
//     _initializeMeasurements();
//     size.y -= 20;
//     _logoImage = await game.images.load("logo.png");
//
//     return super.onLoad();
//   }
//
//   void _initializePosition() {
//     position = (game.size - size) / 2;
//   }
//
//   _initializeMeasurements() {
//     centerCircleRadius = size.y * 0.12;
//     penaltyBoxWidth = size.x * 0.15;
//     penaltyBoxHeight = size.y * 0.4;
//     goalBoxWidth = size.x * 0.06;
//     goalBoxHeight = size.y * 0.15;
//     penaltySpotRadius = 4;
//   }
//
//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//
//     _drawFieldBackground(canvas);
//     _drawFieldOutline(canvas);
//     _drawCenterCircle(canvas);
//     _drawHalfwayLine(canvas);
//     _drawPenaltyAreas(canvas);
//     _drawGoalBoxes(canvas);
//     _drawPenaltySpots(canvas);
//     // _drawCornerArcs(canvas);
//     _drawCenterSpots(canvas);
//     _drawLogo(canvas);
//   }
//
//   void _drawLogo(Canvas canvas) {
//     if (_logoImage != null) {
//       // Check if the image has been loaded
//       // Calculate desired logo dimensions (e.g., 20% of field width)
//       final double logoWidth = AppSize.s40; // Adjust size factor as needed
//       // Calculate height maintaining original aspect ratio
//       final double logoHeight = AppSize.s40;
//       // Find the center coordinates of the GameField component
//       final double centerX = size.x / 2;
//       final double centerY = size.y / 2;
//
//       // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//       // --- logoPosition is defined and calculated HERE ---
//       final Offset logoPosition = Offset(
//         centerX -
//             logoWidth / 2 +
//             5, // Calculate top-left X to center horizontally
//         centerY - logoHeight / 2, // Calculate top-left Y to center vertically
//       );
//       // --- End of logoPosition definition ---
//       // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//
//       // Define the source rectangle (the whole image)
//       final Rect sourceRect = Rect.fromLTWH(
//         0,
//         0,
//         _logoImage!.width.toDouble(),
//         _logoImage!.height.toDouble(),
//       );
//       // Define the destination rectangle on the canvas using calculated position and size
//       final Rect destinationRect = Rect.fromLTWH(
//         logoPosition.dx,
//         logoPosition.dy,
//         logoWidth,
//         logoHeight,
//       );
//
//       // Draw the image
//       canvas.drawImageRect(
//         _logoImage!,
//         sourceRect,
//         destinationRect,
//         Paint(), // Use a default Paint or customize if needed (e.g., for opacity)
//       );
//     }
//   }
//
//   /// Draws the green background of the field
//   void _drawFieldBackground(Canvas canvas) {
//     canvas.drawRect(size.toRect(), _fieldPaint);
//   }
//
//   /// Draws the outline of the football field
//   void _drawFieldOutline(Canvas canvas) {
//     canvas.drawRect(size.toRect(), _borderPaint);
//   }
//
//   /// Draws the center circle
//   void _drawCenterCircle(Canvas canvas) {
//     final Offset center = Offset(size.x / 2, size.y / 2);
//     canvas.drawCircle(center, centerCircleRadius, _borderPaint);
//   }
//
//   /// Draws the halfway line (midfield divider)
//   void _drawHalfwayLine(Canvas canvas) {
//     canvas.drawLine(
//       Offset(size.x / 2, 0),
//       Offset(size.x / 2, size.y),
//       _borderPaint,
//     );
//   }
//
//   /// Draws the penalty areas on both sides
//   void _drawPenaltyAreas(Canvas canvas) {
//     // Left Penalty Area
//     canvas.drawRect(
//       Rect.fromLTWH(
//         0,
//         (size.y - penaltyBoxHeight) / 2,
//         penaltyBoxWidth,
//         penaltyBoxHeight,
//       ),
//       _borderPaint,
//     );
//
//     // Right Penalty Area
//     canvas.drawRect(
//       Rect.fromLTWH(
//         size.x - penaltyBoxWidth,
//         (size.y - penaltyBoxHeight) / 2,
//         penaltyBoxWidth,
//         penaltyBoxHeight,
//       ),
//       _borderPaint,
//     );
//   }
//
//   /// Draws the goal boxes (small areas near the goals)
//   void _drawGoalBoxes(Canvas canvas) {
//     // Left Goal Box
//     canvas.drawRect(
//       Rect.fromLTWH(
//         0,
//         (size.y - goalBoxHeight) / 2,
//         goalBoxWidth,
//         goalBoxHeight,
//       ),
//       _borderPaint,
//     );
//
//     // Right Goal Box
//     canvas.drawRect(
//       Rect.fromLTWH(
//         size.x - goalBoxWidth,
//         (size.y - goalBoxHeight) / 2,
//         goalBoxWidth,
//         goalBoxHeight,
//       ),
//       _borderPaint,
//     );
//   }
//
//   /// Draws the penalty spots
//   void _drawPenaltySpots(Canvas canvas) {
//     // Left Penalty Spot
//     canvas.drawCircle(
//       Offset(
//         penaltyBoxWidth - (penaltyBoxWidth - goalBoxWidth) / 2,
//         size.y / 2,
//       ),
//       penaltySpotRadius,
//       _borderPaint,
//     );
//
//     // Right Penalty Spot
//     canvas.drawCircle(
//       Offset(
//         size.x - penaltyBoxWidth + (penaltyBoxWidth - goalBoxWidth) / 2,
//         size.y / 2,
//       ),
//       penaltySpotRadius,
//       _borderPaint,
//     );
//   }
//
//   /// Draws the Center spots
//   void _drawCenterSpots(Canvas canvas) {
//     canvas.drawCircle(
//       Offset(size.x / 2, size.y / 2),
//       penaltySpotRadius,
//       _fillPaint,
//     );
//   }
// }

import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math'; // Needed for Pi

import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

/// A component that renders the main tactical board, including all its
/// different background layouts like full pitch, half pitch, etc.
class GameField extends PositionComponent
    with HasGameReference, RiverpodComponentMixin {
  GameField({required Vector2 size, this.initialColor}) : super(size: size);

  final Color? initialColor;

  // Measurements for drawing the field
  late double centerCircleRadius;
  late double penaltyBoxWidth;
  late double penaltyBoxHeight;
  late double goalBoxWidth;
  late double goalBoxHeight;
  late double penaltySpotRadius;

  ui.Image? _logoImage;

  final Paint _borderPaint = Paint()
    ..color = ColorManager.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.25;

  final Paint _fillPaint = Paint()
    ..color = ColorManager.black
    ..style = PaintingStyle.fill;

  final Paint _fieldPaint = Paint()..color = ColorManager.grey;

  @override
  FutureOr<void> onLoad() async {
    addToGameWidgetBuild(() {
      ref.listen(boardProvider, (previous, current) {
        if (previous?.boardColor != current.boardColor) {
          _fieldPaint.color = current.boardColor;
        }
      });
    });

    _fieldPaint.color = initialColor ?? ColorManager.grey;

    _initializePosition();
    _initializeMeasurements();

    size.y -= 20; // Keep space at the bottom

    _logoImage = await game.images.load("logo.png");

    return super.onLoad();
  }

  void _initializePosition() {
    position = (game.size - size) / 2;
  }

  void _initializeMeasurements() {
    // These proportions are primarily for the portrait-oriented half-field views
    centerCircleRadius = size.x * 0.14;
    penaltySpotRadius = 4;

    // --- UPDATED: Proportions for half-field boxes (Taller and Narrower) ---
    penaltyBoxWidth = size.x * 0.5; // Decreased from 0.6
    penaltyBoxHeight = size.y * 0.35; // Increased from 0.25
    goalBoxWidth = size.x * 0.25; // Decreased from 0.3
    goalBoxHeight = size.y * 0.15; // Increased from 0.12
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final background = ref.read(boardProvider).boardBackground;

    _drawFieldBackground(canvas);
    _drawFieldOutline(canvas);

    switch (background) {
      case BoardBackground.full:
        _drawFullPitchView(canvas);
        break;

      case BoardBackground.clean:
        break;

      case BoardBackground.halfUp:
        _drawTopHalfMarkings(canvas);
        break;

      case BoardBackground.halfDown:
        _drawBottomHalfMarkings(canvas);
        break;

      case BoardBackground.verticalCorridors:
        _drawFullPitchView(canvas);
        _drawCenterVerticalLines(canvas);
        break;
    }

    _drawLogo(canvas);
  }

  // --- DRAWING HELPER METHODS ---

  void _drawFieldBackground(Canvas canvas) {
    canvas.drawRect(size.toRect(), _fieldPaint);
  }

  void _drawFieldOutline(Canvas canvas) {
    canvas.drawRect(size.toRect(), _borderPaint);
  }

  void _drawFullPitchView(Canvas canvas) {
    // Use different, landscape-specific proportions for the full pitch view
    final landscapeCenterCircleRadius = size.y * 0.14;
    final landscapePenaltyBoxWidth = size.x * 0.14;
    final landscapePenaltyBoxHeight = size.y * 0.6;
    final landscapeGoalBoxWidth = size.x * 0.07;
    final landscapeGoalBoxHeight = size.y * 0.3;

    _drawHalfwayLine(canvas);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2),
        landscapeCenterCircleRadius, _borderPaint);
    canvas.drawCircle(
        Offset(size.x / 2, size.y / 2), penaltySpotRadius, _fillPaint);

    // Left Side
    canvas.drawRect(
        Rect.fromLTWH(0, (size.y - landscapePenaltyBoxHeight) / 2,
            landscapePenaltyBoxWidth, landscapePenaltyBoxHeight),
        _borderPaint);
    canvas.drawRect(
        Rect.fromLTWH(0, (size.y - landscapeGoalBoxHeight) / 2,
            landscapeGoalBoxWidth, landscapeGoalBoxHeight),
        _borderPaint);
    canvas.drawCircle(Offset(landscapePenaltyBoxWidth * 0.75, size.y / 2),
        penaltySpotRadius, _borderPaint);

    // Right Side
    canvas.drawRect(
        Rect.fromLTWH(
            size.x - landscapePenaltyBoxWidth,
            (size.y - landscapePenaltyBoxHeight) / 2,
            landscapePenaltyBoxWidth,
            landscapePenaltyBoxHeight),
        _borderPaint);
    canvas.drawRect(
        Rect.fromLTWH(
            size.x - landscapeGoalBoxWidth,
            (size.y - landscapeGoalBoxHeight) / 2,
            landscapeGoalBoxWidth,
            landscapeGoalBoxHeight),
        _borderPaint);
    canvas.drawCircle(
        Offset(size.x - landscapePenaltyBoxWidth * 0.75, size.y / 2),
        penaltySpotRadius,
        _borderPaint);
  }

  /// Draws the markings for the TOP half of a field (goal at the top).
  void _drawTopHalfMarkings(Canvas canvas) {
    // Halfway line is at the bottom
    canvas.drawLine(Offset(0, size.y), Offset(size.x, size.y), _borderPaint);

    // Penalty and Goal boxes at the top, using the adjusted measurements from _initializeMeasurements
    final topPenaltyBox = Rect.fromLTWH(
        (size.x - penaltyBoxWidth) / 2, 0, penaltyBoxWidth, penaltyBoxHeight);
    final topGoalBox = Rect.fromLTWH(
        (size.x - goalBoxWidth) / 2, 0, goalBoxWidth, goalBoxHeight);

    canvas.drawRect(topPenaltyBox, _borderPaint);
    canvas.drawRect(topGoalBox, _borderPaint);
  }

  /// Draws the markings for the BOTTOM half of a field (goal at the bottom).
  void _drawBottomHalfMarkings(Canvas canvas) {
    // Halfway line is at the top
    canvas.drawLine(Offset(0, 0), Offset(size.x, 0), _borderPaint);

    // Penalty and Goal boxes at the bottom, using the adjusted measurements from _initializeMeasurements
    final bottomPenaltyBox = Rect.fromLTWH((size.x - penaltyBoxWidth) / 2,
        size.y - penaltyBoxHeight, penaltyBoxWidth, penaltyBoxHeight);
    final bottomGoalBox = Rect.fromLTWH((size.x - goalBoxWidth) / 2,
        size.y - goalBoxHeight, goalBoxWidth, goalBoxHeight);

    canvas.drawRect(bottomPenaltyBox, _borderPaint);
    canvas.drawRect(bottomGoalBox, _borderPaint);
  }

  void _drawCenterVerticalLines(Canvas canvas) {
    final x1 = size.x * 0.3;
    final x2 = size.x * 0.7;
    canvas.drawLine(Offset(x1, 0), Offset(x1, size.y), _borderPaint);
    canvas.drawLine(Offset(x2, 0), Offset(x2, size.y), _borderPaint);
  }

  void _drawHalfwayLine(Canvas canvas) {
    canvas.drawLine(
        Offset(size.x / 2, 0), Offset(size.x / 2, size.y), _borderPaint);
  }

  void _drawLogo(Canvas canvas) {
    if (_logoImage != null) {
      final double logoWidth = AppSize.s40;
      final double logoHeight = AppSize.s40;
      final double centerX = size.x / 2;
      final double centerY = size.y / 2;

      final Offset logoPosition =
          Offset((centerX - logoWidth / 2) + 4, centerY - logoHeight / 2);
      final Rect sourceRect = Rect.fromLTWH(
          0, 0, _logoImage!.width.toDouble(), _logoImage!.height.toDouble());
      final Rect destinationRect = Rect.fromLTWH(
          logoPosition.dx, logoPosition.dy, logoWidth, logoHeight);

      canvas.drawImageRect(_logoImage!, sourceRect, destinationRect, Paint());
    }
  }
}
