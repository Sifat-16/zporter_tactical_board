// import 'dart:math' as math;
// import 'dart:ui' as ui;
//
// import 'package:flame/extensions.dart'; // For Vector2 extensions
// import 'package:flutter/foundation.dart'; // For listEquals, mapEquals
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust import path
// import 'package:zporter_tactical_board/app/manager/values_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/field/mini/mixins/shape_painter_mixin.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';
//
// import 'mixins/equipment_painter_mixin.dart';
// import 'mixins/line_painter_mixin.dart';
// import 'mixins/player_painter_mixin.dart';
// import 'mixins/static_field_painter_mixin.dart'; // Adjust import path
//
// // --- Main CustomPainter Class using Mixins ---
// class MiniGameFieldPainter extends CustomPainter
//     with
//         StaticFieldPainterMixin,
//         PlayerPainterMixin,
//         EquipmentPainterMixin,
//         LinePainterMixin,
//         ShapePainterMixin {
//   final Color fieldColor;
//   final Color borderColor;
//   final List<FieldItemModel> items;
//   @override // Implementing the abstract getter from _LinePainterMixin
//   final Vector2 logicalFieldSize;
//   final Map<String, ui.Image> loadedImages;
//
//   final BoardBackground boardBackground;
//
//   final Paint _borderPaint;
//   final Paint _fieldPaint;
//   final Paint _spotPaint;
//   final Paint _itemPaint; // Used by player and equipment mixins
//   final Paint
//       _linePaint; // Defined but not explicitly used by _LinePainterMixin as it creates its own
//   final TextPainter _textPainter; // Used by player and equipment mixins
//
//   MiniGameFieldPainter({
//     required this.fieldColor,
//     this.borderColor = ColorManager.black,
//     required this.items,
//     required this.logicalFieldSize,
//     required this.loadedImages,
//     required this.boardBackground,
//   })  : _fieldPaint = Paint()..color = fieldColor,
//         _borderPaint = Paint()
//           ..color = borderColor
//           ..style = PaintingStyle.stroke,
//         _spotPaint = Paint()
//           ..color = borderColor
//           ..style = PaintingStyle.fill,
//         _itemPaint = Paint()
//           ..color = Colors.white
//           ..style = PaintingStyle.fill,
//         _linePaint = Paint()
//           ..style = PaintingStyle.stroke
//           ..strokeCap = StrokeCap.round
//           ..strokeJoin = StrokeJoin.round,
//         _textPainter = TextPainter(
//           textAlign: TextAlign.center,
//           textDirection: TextDirection.ltr,
//         );
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (size.isEmpty ||
//         size.width <= 0 ||
//         size.height <= 0 ||
//         logicalFieldSize.x <= 0 ||
//         logicalFieldSize.y <= 0) {
//       zlog(
//         data:
//             "MiniGameFieldPainter: Canvas size or logicalFieldSize is invalid, skipping paint.",
//       );
//       return;
//     }
//
//     // Set strokeWidth here as it depends on 'size'
//     _borderPaint.strokeWidth = math.max(1.0, size.shortestSide * 0.005);
//
//     // Call static field drawing method from mixin
//     drawStaticField(
//       canvas,
//       size,
//       fieldPaint: _fieldPaint,
//       borderPaint: _borderPaint,
//       spotPaint: _spotPaint,
//     );
//
//     if (items.isEmpty) {
//       zlog(data: "MiniGameFieldPainter: No items to draw.");
//       return;
//     }
//
//     final double scaleX = size.width / logicalFieldSize.x;
//     final double scaleY = size.height / logicalFieldSize.y;
//     final double uniformItemVisualScale = math.min(scaleX, scaleY);
//     const double minAllowedVisualSize = 1.5;
//     const double minimapItemEnlargementFactor = 1.5;
//     final double overallItemScale =
//         uniformItemVisualScale * minimapItemEnlargementFactor;
//
//     for (FieldItemModel item in items) {
//       final Vector2 itemLogicalOffset = item.offset ?? Vector2.zero();
//       final Offset miniMapItemTopLeft = Offset(
//         SizeHelper.getBoardActualVector(
//               gameScreenSize: logicalFieldSize,
//               actualPosition: itemLogicalOffset,
//             ).x *
//             scaleX, // Use pre-calculated scaleX
//         SizeHelper.getBoardActualVector(
//               gameScreenSize: logicalFieldSize,
//               actualPosition: itemLogicalOffset,
//             ).y *
//             scaleY, // Use pre-calculated scaleY
//       );
//
//       final Vector2 itemLogicalSize =
//           item.size ?? Vector2(AppSize.s32, AppSize.s32);
//       final double visualWidth = math.max(
//         minAllowedVisualSize,
//         itemLogicalSize.x *
//             uniformItemVisualScale *
//             minimapItemEnlargementFactor,
//       );
//       final double visualHeight = math.max(
//         minAllowedVisualSize,
//         itemLogicalSize.y *
//             uniformItemVisualScale *
//             minimapItemEnlargementFactor,
//       );
//       final Size itemVisualSize = Size(visualWidth, visualHeight);
//
//       if (item is LineModelV2) {
//         // Delegate to _LinePainterMixin
//         drawLineItem(
//           object: item,
//           canvas: canvas,
//           visualLineSize: size,
//           logicalFieldSize: size.toVector2(),
//         );
//       } else {
//         // final Offset itemCenterOffsetForRotation = Offset(
//         //   itemVisualSize.width / 2,
//         //   itemVisualSize.height / 2,
//         // );
//         // final Offset finalDrawPosition = miniMapItemTopLeft;
//         //
//         // canvas.save();
//         // canvas.translate(
//         //   finalDrawPosition.dx + itemCenterOffsetForRotation.dx,
//         //   finalDrawPosition.dy + itemCenterOffsetForRotation.dy,
//         // );
//         // if (item.angle != null && item.angle != 0.0) {
//         //   canvas.rotate(item.angle!);
//         // }
//         // canvas.translate(
//         //   -itemCenterOffsetForRotation.dx,
//         //   -itemCenterOffsetForRotation.dy,
//         // );
//
//         if (item is PlayerModel) {
//           // Delegate to _PlayerPainterMixin
//           drawPlayerItem(
//             player: item,
//             canvas: canvas,
//             visualPlayerSize: itemVisualSize,
//             itemPaint: _itemPaint,
//             textPainter: _textPainter,
//             fieldSize: size,
//           );
//         } else if (item is EquipmentModel) {
//           ui.Image? imageToDraw;
//           if (item.imagePath != null && item.imagePath!.isNotEmpty) {
//             imageToDraw = loadedImages["assets/images/${item.imagePath!}"];
//           }
//           // Delegate to _EquipmentPainterMixin
//           drawEquipmentItem(
//             equipment: item,
//             canvas: canvas,
//             fieldSize: size,
//             loadedImage: imageToDraw,
//             itemPaint: _itemPaint,
//             textPainter: _textPainter,
//           );
//         } else if (item is ShapeModel) {
//           drawShapeItem(
//             shape: item,
//             canvas: canvas,
//             visualItemSize: itemVisualSize,
//             itemPaint: _itemPaint, // Pass a general paint, mixin will configure
//             overallItemScale:
//                 overallItemScale, // Pass the scale for polygon vertices
//             fieldSize: size,
//           );
//         }
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant MiniGameFieldPainter oldDelegate) {
//     return oldDelegate.fieldColor != fieldColor ||
//         oldDelegate.borderColor != borderColor ||
//         oldDelegate.logicalFieldSize != logicalFieldSize ||
//         !listEquals(oldDelegate.items, items) ||
//         !mapEquals(oldDelegate.loadedImages, loadedImages);
//   }
// }

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/mini/mixins/equipment_painter_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/mini/mixins/line_painter_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/mini/mixins/player_painter_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/mini/mixins/shape_painter_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

/// A CustomPainter that draws a miniature version of the tactical board,
/// including a selected background layout and all associated field items.
class MiniGameFieldPainter extends CustomPainter
    with
        PlayerPainterMixin,
        EquipmentPainterMixin,
        LinePainterMixin,
        ShapePainterMixin {
  final Color fieldColor;
  final Color borderColor;
  final List<FieldItemModel> items;
  @override
  final Vector2 logicalFieldSize;
  final Map<String, ui.Image> loadedImages;
  final BoardBackground
      boardBackground; // The selected background layout to draw

  // Reusable Paint objects
  final Paint _borderPaint;
  final Paint _fieldPaint;
  final Paint _itemPaint;
  final TextPainter _textPainter;

  MiniGameFieldPainter({
    required this.fieldColor,
    this.borderColor = ColorManager.black,
    required this.items,
    required this.logicalFieldSize,
    required this.loadedImages,
    required this.boardBackground, // Constructor requires the background type
  })  : _fieldPaint = Paint()..color = fieldColor,
        _borderPaint = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke,
        _itemPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
        _textPainter = TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

  @override
  void paint(Canvas canvas, Size size) {
    // Avoid painting if the canvas has no size
    if (size.isEmpty ||
        size.width <= 0 ||
        size.height <= 0 ||
        logicalFieldSize.x <= 0 ||
        logicalFieldSize.y <= 0) {
      return;
    }

    _borderPaint.strokeWidth = math.max(1.0, size.shortestSide * 0.005);

    // 1. Draw the background color
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fieldPaint);

    // 2. Use a switch to draw the correct field layout on top of the color
    switch (boardBackground) {
      case BoardBackground.full:
        _drawFullPitch(canvas, size, _borderPaint, withCentralLines: false);
        break;
      case BoardBackground.clean:
        canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height), _borderPaint);
        break;
      case BoardBackground.halfUp:
        _drawHalfPitch(canvas, size, _borderPaint, isTopHalf: true);
        break;
      case BoardBackground.halfDown:
        _drawHalfPitch(canvas, size, _borderPaint, isTopHalf: false);
        break;
      case BoardBackground.verticalCorridors:
        _drawFullPitch(canvas, size, _borderPaint, withCentralLines: true);
        break;
    }

    // 3. If there are no items, we are done
    if (items.isEmpty) {
      return;
    }

    // 4. Calculate scaling factors to map items from the main board to this mini-board
    final double scaleX = size.width / logicalFieldSize.x;
    final double scaleY = size.height / logicalFieldSize.y;
    final double uniformItemVisualScale = math.min(scaleX, scaleY);
    const double minAllowedVisualSize = 1.5;
    const double minimapItemEnlargementFactor = 1.5;
    final double overallItemScale =
        uniformItemVisualScale * minimapItemEnlargementFactor;

    // 5. Loop through all items and draw them using the appropriate mixin
    for (FieldItemModel item in items) {
      // Logic for positioning and scaling items...
      // This part remains the same as your original file
      final Vector2 itemLogicalOffset = item.offset ?? Vector2.zero();
      final Offset miniMapItemTopLeft = Offset(
        SizeHelper.getBoardActualVector(
              gameScreenSize: logicalFieldSize,
              actualPosition: itemLogicalOffset,
            ).x *
            scaleX,
        SizeHelper.getBoardActualVector(
              gameScreenSize: logicalFieldSize,
              actualPosition: itemLogicalOffset,
            ).y *
            scaleY,
      );

      final Vector2 itemLogicalSize =
          item.size ?? Vector2(AppSize.s32, AppSize.s32);
      final double visualWidth =
          math.max(minAllowedVisualSize, itemLogicalSize.x * overallItemScale);
      final double visualHeight =
          math.max(minAllowedVisualSize, itemLogicalSize.y * overallItemScale);
      final Size itemVisualSize = Size(visualWidth, visualHeight);

      // Delegate drawing to the correct mixin based on item type
      if (item is LineModelV2) {
        drawLineItem(
            object: item,
            canvas: canvas,
            visualLineSize: size,
            logicalFieldSize: size.toVector2());
      } else if (item is PlayerModel) {
        // The drawing logic for players, equipment, etc., is encapsulated in the mixins.
        // You would typically translate the canvas to the item's position, then call the drawing method.
        // This example assumes the mixins handle positioning internally for simplicity.
        // If they don't, you would do `canvas.save()` and `canvas.translate()` here.
        drawPlayerItem(
            player: item,
            canvas: canvas,
            visualPlayerSize: itemVisualSize,
            itemPaint: _itemPaint,
            textPainter: _textPainter,
            fieldSize: size);
      } else if (item is EquipmentModel) {
        ui.Image? imageToDraw =
            (item.imagePath != null && item.imagePath!.isNotEmpty)
                ? loadedImages["assets/images/${item.imagePath!}"]
                : null;
        drawEquipmentItem(
            equipment: item,
            canvas: canvas,
            fieldSize: size,
            loadedImage: imageToDraw,
            itemPaint: _itemPaint,
            textPainter: _textPainter);
      } else if (item is ShapeModel) {
        drawShapeItem(
            shape: item,
            canvas: canvas,
            visualItemSize: itemVisualSize,
            itemPaint: _itemPaint,
            overallItemScale: overallItemScale,
            fieldSize: size);
      }
    }
  }

  // --- DRAWING HELPER METHODS for field layouts ---

  void _drawFullPitch(Canvas canvas, Size size, Paint paint,
      {required bool withCentralLines}) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    final penaltyBoxWidth = size.width * 0.14;
    final penaltyBoxHeight = size.height * 0.6;
    final goalBoxWidth = size.width * 0.07;
    final goalBoxHeight = size.height * 0.3;
    final centerCircleRadius = size.height * 0.14;
    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), centerCircleRadius, paint);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(penaltyBoxWidth / 2, size.height / 2),
            width: penaltyBoxWidth,
            height: penaltyBoxHeight),
        paint);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(goalBoxWidth / 2, size.height / 2),
            width: goalBoxWidth,
            height: goalBoxHeight),
        paint);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(size.width - penaltyBoxWidth / 2, size.height / 2),
            width: penaltyBoxWidth,
            height: penaltyBoxHeight),
        paint);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(size.width - goalBoxWidth / 2, size.height / 2),
            width: goalBoxWidth,
            height: goalBoxHeight),
        paint);
    if (withCentralLines) {
      _drawCenterVerticalLines(canvas, size, paint);
    }
  }

  void _drawCenterVerticalLines(Canvas canvas, Size size, Paint paint) {
    final x1 = size.width * 0.3;
    final x2 = size.width * 0.7;
    canvas.drawLine(Offset(x1, 0), Offset(x1, size.height), paint);
    canvas.drawLine(Offset(x2, 0), Offset(x2, size.height), paint);
  }

  void _drawHalfPitch(Canvas canvas, Size size, Paint paint,
      {required bool isTopHalf}) {
    final fieldHeight = size.width;
    final fieldWidth = size.height;
    final penaltyBoxWidth = fieldWidth * 0.8;
    final penaltyBoxHeight = fieldHeight * 0.28;
    final goalBoxWidth = fieldWidth * 0.4;
    final goalBoxHeight = fieldHeight * 0.14;
    canvas.save();
    if (isTopHalf) {
      canvas.translate(size.width, 0);
      canvas.rotate(math.pi / 2);
    } else {
      canvas.translate(0, size.height);
      canvas.rotate(-math.pi / 2);
    }
    final rotatedSize = Size(size.height, size.width);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, rotatedSize.width, rotatedSize.height), paint);
    final halfwayLineX = rotatedSize.width;
    canvas.drawLine(Offset(halfwayLineX, 0),
        Offset(halfwayLineX, rotatedSize.height), paint);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(penaltyBoxHeight / 2, rotatedSize.height / 2),
            width: penaltyBoxHeight,
            height: penaltyBoxWidth),
        paint);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(goalBoxHeight / 2, rotatedSize.height / 2),
            width: goalBoxHeight,
            height: goalBoxWidth),
        paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MiniGameFieldPainter oldDelegate) {
    // Repaint if any of these properties change.
    return oldDelegate.fieldColor != fieldColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.logicalFieldSize != logicalFieldSize ||
        !listEquals(oldDelegate.items, items) ||
        !mapEquals(oldDelegate.loadedImages, loadedImages) ||
        oldDelegate.boardBackground != boardBackground; // Important check
  }
}
