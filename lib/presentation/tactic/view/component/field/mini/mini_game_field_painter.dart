// mini_game_field_painter.dart (Updated)

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class MiniGameFieldPainter extends CustomPainter {
  // Removed fieldSize from constructor
  final Color fieldColor;
  final Color borderColor;

  final Paint _borderPaint;
  final Paint _fieldPaint;
  final Paint _spotPaint;

  MiniGameFieldPainter({
    required this.fieldColor,
    this.borderColor = ColorManager.black,
  }) : _fieldPaint = Paint()..color = fieldColor,
       _borderPaint =
           Paint()
             ..color = borderColor
             ..style = PaintingStyle.stroke,
       // Stroke width will be set dynamically in paint() based on actual size
       _spotPaint =
           Paint()
             ..color = borderColor
             ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    // Use the 'size' parameter passed here
    if (size.isEmpty || size.width <= 0 || size.height <= 0)
      return; // Check for valid size

    // Set stroke width dynamically based on actual size
    _borderPaint.strokeWidth = math.max(1.0, size.shortestSide * 0.005);

    // Measurements are now based on the 'size' parameter
    final double centerCircleRadius = size.height * 0.12;
    final double penaltyBoxWidth = size.width * 0.15;
    final double penaltyBoxHeight = size.height * 0.4;
    final double goalBoxWidth = size.width * 0.06;
    final double goalBoxHeight = size.height * 0.15;
    final double penaltySpotRadius = math.max(1.0, size.shortestSide * 0.015);
    final Offset center = size.center(Offset.zero);
    final double penaltyDistX = size.width * 0.11; // Approx proportion

    // --- Drawing Methods (No change in logic, just use 'size') ---
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
    ); // Halfway Line
    // Penalty Areas
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        (size.height - penaltyBoxHeight) / 2,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      _borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - penaltyBoxWidth,
        (size.height - penaltyBoxHeight) / 2,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      _borderPaint,
    );
    // Goal Boxes
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        (size.height - goalBoxHeight) / 2,
        goalBoxWidth,
        goalBoxHeight,
      ),
      _borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - goalBoxWidth,
        (size.height - goalBoxHeight) / 2,
        goalBoxWidth,
        goalBoxHeight,
      ),
      _borderPaint,
    );
    // Penalty Spots
    canvas.drawCircle(
      Offset(penaltyDistX, size.height / 2),
      penaltySpotRadius,
      _spotPaint,
    );
    canvas.drawCircle(
      Offset(size.width - penaltyDistX, size.height / 2),
      penaltySpotRadius,
      _spotPaint,
    );
    // Center Spot
    canvas.drawCircle(center, penaltySpotRadius, _spotPaint);
  }

  @override
  bool shouldRepaint(covariant MiniGameFieldPainter oldDelegate) {
    // Repaint only if colors change (size changes trigger repaint automatically)
    return oldDelegate.fieldColor != fieldColor ||
        oldDelegate.borderColor != borderColor;
  }
}
