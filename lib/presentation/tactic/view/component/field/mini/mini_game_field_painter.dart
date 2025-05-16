import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/extensions.dart'; // For Vector2 extensions
import 'package:flutter/foundation.dart'; // For listEquals
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust import path
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
// Import models needed for drawing logic
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart'; // Adjust import path

class MiniGameFieldPainter extends CustomPainter {
  final Color fieldColor;
  final Color borderColor;
  final List<FieldItemModel> items;
  final Vector2 logicalFieldSize;
  final Map<String, ui.Image> loadedImages; // <-- Accepts pre-loaded images

  final Paint _borderPaint;
  final Paint _fieldPaint;
  final Paint _spotPaint;
  final Paint _itemPaint;
  final Paint _linePaint;
  final TextPainter _textPainter;

  MiniGameFieldPainter({
    required this.fieldColor,
    this.borderColor = ColorManager.black,
    required this.items,
    required this.logicalFieldSize,
    required this.loadedImages, // <-- New constructor parameter
  }) : _fieldPaint = Paint()..color = fieldColor,
       _borderPaint =
           Paint()
             ..color = borderColor
             ..style = PaintingStyle.stroke,
       _spotPaint =
           Paint()
             ..color = borderColor
             ..style = PaintingStyle.fill,
       _itemPaint = Paint()..style = PaintingStyle.fill,
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
      return;
    }

    // --- 1. Draw Static Field ---
    // ... (Static field drawing code remains the same) ...
    _borderPaint.strokeWidth = math.max(1.0, size.shortestSide * 0.005);
    final double centerCircleRadius = size.height * 0.12;
    final double penaltyBoxWidth = size.width * 0.15;
    final double penaltyBoxHeight = size.height * 0.4;
    final double goalBoxWidth = size.width * 0.06;
    final double goalBoxHeight = size.height * 0.15;
    final double penaltySpotRadius = math.max(1.0, size.shortestSide * 0.01);
    final Offset center = size.center(Offset.zero);
    final double penaltyDistX = size.width * 0.11;

    canvas.drawRect(Offset.zero & size, _fieldPaint);
    canvas.drawRect(Offset.zero & size, _borderPaint);
    canvas.drawCircle(center, centerCircleRadius, _borderPaint);
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      _borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        center.dy - penaltyBoxHeight / 2,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      _borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - penaltyBoxWidth,
        center.dy - penaltyBoxHeight / 2,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      _borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        center.dy - goalBoxHeight / 2,
        goalBoxWidth,
        goalBoxHeight,
      ),
      _borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - goalBoxWidth,
        center.dy - goalBoxHeight / 2,
        goalBoxWidth,
        goalBoxHeight,
      ),
      _borderPaint,
    );
    canvas.drawCircle(
      Offset(penaltyDistX, center.dy),
      penaltySpotRadius,
      _spotPaint,
    );
    canvas.drawCircle(
      Offset(size.width - penaltyDistX, center.dy),
      penaltySpotRadius,
      _spotPaint,
    );
    canvas.drawCircle(center, penaltySpotRadius, _spotPaint);
    // --- End Static Field ---

    if (items.isEmpty) return;

    final double scaleX = size.width / logicalFieldSize.x;
    final double scaleY = size.height / logicalFieldSize.y;
    final double uniformItemVisualScale = math.min(scaleX, scaleY);
    const double minAllowedVisualSize = 1.5;
    const double minimapItemEnlargementFactor = 1.5;

    for (FieldItemModel item in items) {
      final Vector2 itemLogicalOffset = item.offset ?? Vector2.zero();
      final Offset miniMapItemTopLeft = Offset(
        SizeHelper.getBoardActualVector(
              gameScreenSize: logicalFieldSize, // This is the logical size
              actualPosition: itemLogicalOffset,
            ).x *
            (size.width / logicalFieldSize.x), // Scale to current canvas size
        SizeHelper.getBoardActualVector(
              gameScreenSize: logicalFieldSize,
              actualPosition: itemLogicalOffset,
            ).y *
            (size.height / logicalFieldSize.y),
      );

      // --- Calculate visual size for the item on the minimap ---
      // final Vector2 itemLogicalSize =
      //     item.size ??
      //     Vector2(AppSize.s32, AppSize.s32); // Default logical size
      // final double visualWidth = math.max(
      //   minAllowedVisualSize,
      //   itemLogicalSize.x * uniformItemVisualScale,
      // );
      // final double visualHeight = math.max(
      //   minAllowedVisualSize,
      //   itemLogicalSize.y * uniformItemVisualScale,
      // );
      // final Size itemVisualSize = Size(visualWidth, visualHeight);

      final Vector2 itemLogicalSize =
          item.size ??
          Vector2(AppSize.s32, AppSize.s32); // Default logical size

      final double visualWidth = math.max(
        minAllowedVisualSize,
        itemLogicalSize.x *
            uniformItemVisualScale *
            minimapItemEnlargementFactor, // <<-- MODIFY HERE
      );
      final double visualHeight = math.max(
        minAllowedVisualSize,
        itemLogicalSize.y *
            uniformItemVisualScale *
            minimapItemEnlargementFactor, // <<-- MODIFY HERE
      );

      final Size itemVisualSize = Size(visualWidth, visualHeight);

      // --- Prepare canvas for item drawing (translate to top-left, then rotate around center) ---
      // To draw items at their top-left and then rotate around their center:
      final Offset itemCenterOffsetForRotation = Offset(
        itemVisualSize.width / 2,
        itemVisualSize.height / 2,
      );
      final Offset finalDrawPosition =
          miniMapItemTopLeft; // This is already top-left

      canvas.save();
      canvas.translate(
        finalDrawPosition.dx + itemCenterOffsetForRotation.dx,
        finalDrawPosition.dy + itemCenterOffsetForRotation.dy,
      );
      if (item.angle != null && item.angle != 0.0) {
        canvas.rotate(item.angle!);
      }
      // After rotation, translate back so drawing is from (0,0) of the item's visual box
      canvas.translate(
        -itemCenterOffsetForRotation.dx,
        -itemCenterOffsetForRotation.dy,
      );

      if (item is PlayerModel) {
        _drawPlayer(
          object: item,
          canvas: canvas,
          visualPlayerSize: itemVisualSize,
        );
      } else if (item is EquipmentModel) {
        // Retrieve the pre-loaded image
        ui.Image? imageToDraw;
        if (item.imagePath != null && item.imagePath!.isNotEmpty) {
          imageToDraw = loadedImages["assets/images/${item.imagePath!}"];
        }
        _drawEquipment(
          object: item,
          canvas: canvas,
          visualEquipmentSize:
              itemVisualSize, // Pass the calculated visual size
          loadedImage: imageToDraw,
        );
      }
      // else if (item is FormModel) { ... }

      canvas.restore();
    }
  }

  // --- _drawPlayer (Modified to take visualPlayerSize) ---
  void _drawPlayer({
    required PlayerModel object,
    required Canvas canvas,
    required Size visualPlayerSize, // Takes pre-calculated visual size
  }) {
    final double baseOpacity = (object.opacity ?? 1.0).clamp(0.0, 1.0);
    final Color baseColor =
        object.color ??
        (object.playerType == PlayerType.HOME
            ? ColorManager.blue
            : (object.playerType == PlayerType.AWAY
                ? ColorManager.red
                : ColorManager.grey));
    final Color effectiveColor = baseColor.withOpacity(baseOpacity);

    _itemPaint.color = effectiveColor;
    _itemPaint.style = PaintingStyle.fill;

    final double cornerRadiusValue =
        math.min(visualPlayerSize.width, visualPlayerSize.height) * 0.2;
    final Radius cornerRadius = Radius.circular(
      cornerRadiusValue.clamp(1.0, 4.0),
    );
    // Draw relative to current canvas origin (0,0) which is item's top-left
    final Rect playerRect = Rect.fromLTWH(
      0,
      0,
      visualPlayerSize.width,
      visualPlayerSize.height,
    );
    final RRect roundedRect = RRect.fromRectAndRadius(playerRect, cornerRadius);
    canvas.drawRRect(roundedRect, _itemPaint);

    // Role Text
    final double roleFontSize =
        math.min(visualPlayerSize.width, visualPlayerSize.height) * 0.6;
    if (object.role.isNotEmpty && roleFontSize >= 1.5) {
      final roleTextColor =
          ThemeData.estimateBrightnessForColor(baseColor) == Brightness.dark
              ? Colors.white.withOpacity(baseOpacity)
              : Colors.black.withOpacity(baseOpacity);
      _textPainter.text = TextSpan(
        text: object.role.isNotEmpty ? object.role[0].toUpperCase() : "?",
        style: TextStyle(
          color: roleTextColor,
          fontSize: roleFontSize,
          fontWeight: FontWeight.bold,
        ),
      );
      _textPainter.layout(minWidth: 0, maxWidth: visualPlayerSize.width);
      _textPainter.paint(
        canvas,
        Offset(
          (visualPlayerSize.width - _textPainter.width) / 2,
          (visualPlayerSize.height - _textPainter.height) / 2,
        ),
      );
    }

    // Jersey Number
    String jerseyNumber = object.jerseyNumber.toString();
    if (jerseyNumber == "-1" || jerseyNumber == "0") jerseyNumber = "";
    if (jerseyNumber.isNotEmpty) {
      final double jerseyFontSize = visualPlayerSize.width * 0.35;
      if (jerseyFontSize >= 1.0) {
        final jerseyTextColor = Colors.white.withOpacity(baseOpacity * 0.85);
        _textPainter.text = TextSpan(
          text: jerseyNumber,
          style: TextStyle(
            color: jerseyTextColor,
            fontSize: jerseyFontSize,
            fontWeight: FontWeight.w900,
          ),
        );
        _textPainter.layout();
        final double nudge = visualPlayerSize.width * 0.05;
        // Position relative to top-right of the playerRect (which starts at 0,0)
        final Offset numberTextDrawOffset = Offset(
          visualPlayerSize.width - _textPainter.width + nudge,
          0 - _textPainter.height + nudge + (jerseyFontSize * 0.2),
        );
        _textPainter.paint(canvas, numberTextDrawOffset);
      }
    }
  }

  // --- _drawEquipment (Modified to take visualEquipmentSize and loadedImage) ---
  void _drawEquipment({
    required EquipmentModel object,
    required Canvas canvas,
    required Size visualEquipmentSize, // Takes pre-calculated visual size
    ui.Image? loadedImage,
  }) {
    final double baseOpacity = 1;

    // Define the destination rectangle relative to current canvas origin (0,0)
    final Rect equipmentDestRect = Rect.fromLTWH(
      0,
      0,
      visualEquipmentSize.width,
      visualEquipmentSize.height,
    );
    zlog(data: "Loaded images here  ${loadedImage}");
    if (loadedImage != null) {
      final Paint imagePaint =
          Paint()
            ..colorFilter = ColorFilter.mode(Colors.white, BlendMode.srcIn)
            ..filterQuality = FilterQuality.low;
      canvas.drawImageRect(
        loadedImage,
        Rect.fromLTWH(
          0,
          0,
          loadedImage.width.toDouble(),
          loadedImage.height.toDouble(),
        ),
        equipmentDestRect,
        imagePaint,
      );
    } else {
      // Draw placeholder
      final Color baseColorForPlaceholder = Colors.white;
      final Color effectivePlaceholderColor = baseColorForPlaceholder
          .withOpacity(baseOpacity);
      _itemPaint.color = effectivePlaceholderColor;
      _itemPaint.style = PaintingStyle.fill;
      canvas.drawRect(equipmentDestRect, _itemPaint);

      final double nameFontSize =
          math.min(visualEquipmentSize.width, visualEquipmentSize.height) * 0.5;
      if (object.name.isNotEmpty && nameFontSize >= 1.5) {
        _textPainter.text = TextSpan(
          text: object.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color:
                ThemeData.estimateBrightnessForColor(baseColorForPlaceholder) ==
                        Brightness.dark
                    ? Colors.white.withOpacity(baseOpacity)
                    : Colors.black.withOpacity(baseOpacity),
            fontSize: nameFontSize,
            fontWeight: FontWeight.bold,
          ),
        );
        _textPainter.layout(minWidth: 0, maxWidth: visualEquipmentSize.width);
        _textPainter.paint(
          canvas,
          Offset(
            (visualEquipmentSize.width - _textPainter.width) / 2,
            (visualEquipmentSize.height - _textPainter.height) / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant MiniGameFieldPainter oldDelegate) {
    return oldDelegate.fieldColor != fieldColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.logicalFieldSize != logicalFieldSize ||
        !listEquals(oldDelegate.items, oldDelegate.items) ||
        !mapEquals(
          oldDelegate.loadedImages,
          loadedImages,
        ); // Compare loaded images map
  }
}
