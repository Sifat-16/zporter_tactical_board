// --- Mixin for Equipment Drawing ---
import 'dart:ui' as ui;

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';

mixin EquipmentPainterMixin {
  void drawEquipmentItem({
    required EquipmentModel equipment,
    required Canvas canvas,
    required Size fieldSize,
    required ui.Image? loadedImage,
    required Paint itemPaint, // For placeholder background
    required TextPainter textPainter, // For placeholder text
  }) {
    Vector2 size = (equipment.size ?? Vector2(32, 32)) * .2;
    Offset centerOfEquipment = SizeHelper.getBoardActualVector(
      gameScreenSize: fieldSize.toVector2(),
      actualPosition: equipment.offset ?? Vector2.zero(),
    ).toOffset();
    final Rect equipmentDestRect = Rect.fromCenter(
      center: centerOfEquipment,
      height: size.y,
      width: size.x,
    );

    if (loadedImage != null) {
      final Paint imagePaint = Paint()..filterQuality = FilterQuality.low;
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
    }
  }
}
