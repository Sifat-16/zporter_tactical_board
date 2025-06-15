import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/extensions.dart'; // For Vector2 extensions
import 'package:flutter/foundation.dart'; // For listEquals, mapEquals
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust import path
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/mini/mixins/shape_painter_mixin.dart';

import 'mixins/equipment_painter_mixin.dart';
import 'mixins/line_painter_mixin.dart';
import 'mixins/player_painter_mixin.dart';
import 'mixins/static_field_painter_mixin.dart'; // Adjust import path

// --- Main CustomPainter Class using Mixins ---
class MiniGameFieldPainter extends CustomPainter
    with
        StaticFieldPainterMixin,
        PlayerPainterMixin,
        EquipmentPainterMixin,
        LinePainterMixin,
        ShapePainterMixin {
  final Color fieldColor;
  final Color borderColor;
  final List<FieldItemModel> items;
  @override // Implementing the abstract getter from _LinePainterMixin
  final Vector2 logicalFieldSize;
  final Map<String, ui.Image> loadedImages;

  final Paint _borderPaint;
  final Paint _fieldPaint;
  final Paint _spotPaint;
  final Paint _itemPaint; // Used by player and equipment mixins
  final Paint
  _linePaint; // Defined but not explicitly used by _LinePainterMixin as it creates its own
  final TextPainter _textPainter; // Used by player and equipment mixins

  MiniGameFieldPainter({
    required this.fieldColor,
    this.borderColor = ColorManager.black,
    required this.items,
    required this.logicalFieldSize,
    required this.loadedImages,
  }) : _fieldPaint = Paint()..color = fieldColor,
       _borderPaint =
           Paint()
             ..color = borderColor
             ..style = PaintingStyle.stroke,
       _spotPaint =
           Paint()
             ..color = borderColor
             ..style = PaintingStyle.fill,
       _itemPaint =
           Paint()
             ..color = Colors.white
             ..style = PaintingStyle.fill,
       _linePaint =
           Paint()
             ..style = PaintingStyle.stroke
             ..strokeCap = StrokeCap.round
             ..strokeJoin = StrokeJoin.round,
       _textPainter = TextPainter(
         textAlign: TextAlign.center,
         textDirection: TextDirection.ltr,
       );

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty ||
        size.width <= 0 ||
        size.height <= 0 ||
        logicalFieldSize.x <= 0 ||
        logicalFieldSize.y <= 0) {
      zlog(
        data:
            "MiniGameFieldPainter: Canvas size or logicalFieldSize is invalid, skipping paint.",
      );
      return;
    }

    // Set strokeWidth here as it depends on 'size'
    _borderPaint.strokeWidth = math.max(1.0, size.shortestSide * 0.005);

    // Call static field drawing method from mixin
    drawStaticField(
      canvas,
      size,
      fieldPaint: _fieldPaint,
      borderPaint: _borderPaint,
      spotPaint: _spotPaint,
    );

    if (items.isEmpty) {
      zlog(data: "MiniGameFieldPainter: No items to draw.");
      return;
    }

    final double scaleX = size.width / logicalFieldSize.x;
    final double scaleY = size.height / logicalFieldSize.y;
    final double uniformItemVisualScale = math.min(scaleX, scaleY);
    const double minAllowedVisualSize = 1.5;
    const double minimapItemEnlargementFactor = 1.5;
    final double overallItemScale =
        uniformItemVisualScale * minimapItemEnlargementFactor;

    for (FieldItemModel item in items) {
      final Vector2 itemLogicalOffset = item.offset ?? Vector2.zero();
      final Offset miniMapItemTopLeft = Offset(
        SizeHelper.getBoardActualVector(
              gameScreenSize: logicalFieldSize,
              actualPosition: itemLogicalOffset,
            ).x *
            scaleX, // Use pre-calculated scaleX
        SizeHelper.getBoardActualVector(
              gameScreenSize: logicalFieldSize,
              actualPosition: itemLogicalOffset,
            ).y *
            scaleY, // Use pre-calculated scaleY
      );

      final Vector2 itemLogicalSize =
          item.size ?? Vector2(AppSize.s32, AppSize.s32);
      final double visualWidth = math.max(
        minAllowedVisualSize,
        itemLogicalSize.x *
            uniformItemVisualScale *
            minimapItemEnlargementFactor,
      );
      final double visualHeight = math.max(
        minAllowedVisualSize,
        itemLogicalSize.y *
            uniformItemVisualScale *
            minimapItemEnlargementFactor,
      );
      final Size itemVisualSize = Size(visualWidth, visualHeight);

      if (item is LineModelV2) {
        // Delegate to _LinePainterMixin
        drawLineItem(
          object: item,
          canvas: canvas,
          visualLineSize: size,
          logicalFieldSize: size.toVector2(),
        );
      } else {
        // final Offset itemCenterOffsetForRotation = Offset(
        //   itemVisualSize.width / 2,
        //   itemVisualSize.height / 2,
        // );
        // final Offset finalDrawPosition = miniMapItemTopLeft;
        //
        // canvas.save();
        // canvas.translate(
        //   finalDrawPosition.dx + itemCenterOffsetForRotation.dx,
        //   finalDrawPosition.dy + itemCenterOffsetForRotation.dy,
        // );
        // if (item.angle != null && item.angle != 0.0) {
        //   canvas.rotate(item.angle!);
        // }
        // canvas.translate(
        //   -itemCenterOffsetForRotation.dx,
        //   -itemCenterOffsetForRotation.dy,
        // );

        if (item is PlayerModel) {
          // Delegate to _PlayerPainterMixin
          drawPlayerItem(
            player: item,
            canvas: canvas,
            visualPlayerSize: itemVisualSize,
            itemPaint: _itemPaint,
            textPainter: _textPainter,
            fieldSize: size,
          );
        } else if (item is EquipmentModel) {
          ui.Image? imageToDraw;
          if (item.imagePath != null && item.imagePath!.isNotEmpty) {
            imageToDraw = loadedImages["assets/images/${item.imagePath!}"];
          }
          // Delegate to _EquipmentPainterMixin
          drawEquipmentItem(
            equipment: item,
            canvas: canvas,
            fieldSize: size,
            loadedImage: imageToDraw,
            itemPaint: _itemPaint,
            textPainter: _textPainter,
          );
        } else if (item is ShapeModel) {
          drawShapeItem(
            shape: item,
            canvas: canvas,
            visualItemSize: itemVisualSize,
            itemPaint: _itemPaint, // Pass a general paint, mixin will configure
            overallItemScale:
                overallItemScale, // Pass the scale for polygon vertices
            fieldSize: size,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant MiniGameFieldPainter oldDelegate) {
    return oldDelegate.fieldColor != fieldColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.logicalFieldSize != logicalFieldSize ||
        !listEquals(oldDelegate.items, items) ||
        !mapEquals(oldDelegate.loadedImages, loadedImages);
  }
}
