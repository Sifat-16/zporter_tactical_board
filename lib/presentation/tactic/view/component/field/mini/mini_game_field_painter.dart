import 'dart:math' as math;

import 'package:flame/extensions.dart'; // For Vector2 extensions
import 'package:flutter/foundation.dart'; // For listEquals
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust import path
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart'; // Adjust import path
// Import models needed for drawing logic
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart'; // Adjust import path
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart'; // Adjust import path
// Import specific FormItemModels

class MiniGameFieldPainter extends CustomPainter {
  final Color fieldColor;
  final Color borderColor;
  final List<FieldItemModel> items;
  final Vector2 logicalFieldSize; // The size of the main board (world size)

  // --- Paints (Cached for performance) ---
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
             ..strokeCap = StrokeCap.round,
       _textPainter = TextPainter(
         textAlign: TextAlign.center,
         textDirection: TextDirection.ltr,
       );

  @override
  void paint(Canvas canvas, Size size) {
    // 'size' is the actual drawing area size
    // Avoid division by zero or drawing in invalid area
    if (size.isEmpty ||
        size.width <= 0 ||
        size.height <= 0 ||
        logicalFieldSize.x <= 0 ||
        logicalFieldSize.y <= 0) {
      return;
    }

    // --- 1. Draw Static Field (relative to 'size') ---
    _borderPaint.strokeWidth = math.max(1.0, size.shortestSide * 0.005);
    final double centerCircleRadius = size.height * 0.12;
    final double penaltyBoxWidth = size.width * 0.15;
    final double penaltyBoxHeight = size.height * 0.4;
    final double goalBoxWidth = size.width * 0.06;
    final double goalBoxHeight = size.height * 0.15;
    final double penaltySpotRadius = math.max(1.0, size.shortestSide * 0.01);
    final Offset center = size.center(Offset.zero);
    final double penaltyDistX = size.width * 0.11;

    canvas.drawRect(Offset.zero & size, _fieldPaint); // Background
    canvas.drawRect(Offset.zero & size, _borderPaint); // Outline
    canvas.drawCircle(
      center,
      centerCircleRadius,
      _borderPaint,
    ); // Center Circle
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      _borderPaint,
    ); // Halfway
    // Penalty Areas
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
    // Goal Boxes
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
    // Spots
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
    canvas.drawCircle(center, penaltySpotRadius, _spotPaint); // Center Spot
    // --- End Static Field Drawing ---

    // --- 2. Draw Items (Scaled to fit 'size') ---
    final double scaleX = size.width / logicalFieldSize.x;
    final double scaleY = size.height / logicalFieldSize.y;
    final double uniformItemScale = math.min(
      scaleX,
      scaleY,
    ); // Use this for item *sizes*
    const double minVisualSize = 3.0; // Min pixels for item representation

    // --- Draw Players and Equipment ---
    for (final item in items) {
      final Vector2 itemOffset = item.offset ?? Vector2.zero(); // World offset
      final Vector2 itemSize =
          item.size ?? Vector2(10, 10); // Logical default size
      final double itemAngle = item.angle ?? 0.0;

      // Calculate position on the mini-map canvas using scaling factors
      final Offset miniMapCenter = Offset(
        itemOffset.x * scaleX,
        itemOffset.y * scaleY,
      );
      // Calculate visual size on the mini-map using uniform scale
      final double visualWidth = math.max(
        minVisualSize,
        itemSize.x * uniformItemScale,
      );
      final double visualHeight = math.max(
        minVisualSize,
        itemSize.y * uniformItemScale,
      );
      final Size visualItemSize = Size(visualWidth, visualHeight);

      // --- Prepare to draw centered & rotated item ---
      canvas.save();
      canvas.translate(
        miniMapCenter.dx,
        miniMapCenter.dy,
      ); // Move canvas origin to item center
      if (itemAngle != 0.0) {
        canvas.rotate(itemAngle); // Rotate canvas around new origin
      }

      // Draw based on type (drawing happens relative to Offset.zero now)
      if (item is PlayerModel) {
        _drawPlayer(canvas, visualItemSize, item);
      } else if (item is EquipmentModel) {
        _drawEquipment(canvas, visualItemSize, item);
      } else {
        // Fallback for unknown FieldItemModel types (excluding Forms)
        _itemPaint.color = Colors.purple.withOpacity(item.opacity ?? 1.0);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: visualWidth,
            height: visualHeight,
          ),
          _itemPaint,
        );
      }

      canvas.restore(); // Restore canvas state (removes rotation/translation)
      // --- End Player/Equipment Item ---
    }
  }

  // --- Helper Drawing Functions ---

  // Draws a player (e.g., circle with role initial) centered at Offset.zero
  void _drawPlayer(Canvas canvas, Size itemSize, PlayerModel player) {
    final paint =
        _itemPaint
          ..color = (player.color ?? _getPlayerColor(player.playerType))
              .withOpacity(player.opacity ?? 1.0);
    // Base radius on the smaller dimension for circle representation
    final radius = math.min(itemSize.width, itemSize.height) / 2;

    canvas.drawCircle(Offset.zero, radius, paint);

    // Optionally draw role initial if size permits
    final double fontSize = radius * 0.7; // Adjust relative size
    if (player.role.isNotEmpty && fontSize >= 2.5) {
      // Draw if likely visible
      _textPainter.text = TextSpan(
        text: player.role[0], // Show first initial
        style: TextStyle(
          color: Colors.white.withOpacity(
            player.opacity ?? 1.0,
          ), // Contrasting color
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      );
      _textPainter.layout(
        minWidth: 0,
        maxWidth: itemSize.width * 2,
      ); // Allow slightly wider layout
      _textPainter.paint(
        canvas,
        Offset(-_textPainter.width / 2, -_textPainter.height / 2),
      );
    }
  }

  // Gets default player color
  Color _getPlayerColor(PlayerType playerType) {
    switch (playerType) {
      case PlayerType.HOME:
        return ColorManager.blue;
      case PlayerType.AWAY:
        return ColorManager.red;
      case PlayerType.OTHER:
        return ColorManager.yellow;
      case PlayerType.UNKNOWN:
      default:
        return Colors.grey;
    }
  }

  // Draws equipment (e.g., square) centered at Offset.zero
  void _drawEquipment(Canvas canvas, Size itemSize, EquipmentModel equipment) {
    final paint =
        _itemPaint
          ..color = (equipment.color ?? Colors.orange).withOpacity(
            equipment.opacity ?? 1.0,
          );
    // Draw a small square centered at origin
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: itemSize.width,
      height: itemSize.height,
    );
    canvas.drawRect(rect, paint);
    // TODO: Consider drawing a specific icon/shape based on equipment.name or imagePath if needed
  }

  @override
  bool shouldRepaint(covariant MiniGameFieldPainter oldDelegate) {
    // Repaint if colors, logical size, or the items list change identity or content
    // Using listEquals requires FieldItemModel to have correct == operator override
    return oldDelegate.fieldColor != fieldColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.logicalFieldSize != logicalFieldSize ||
        !listEquals(oldDelegate.items, items);
  }
}
