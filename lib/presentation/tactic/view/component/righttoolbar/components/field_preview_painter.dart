import 'package:flutter/material.dart';
import 'dart:math'; // Needed for Pi
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart'; // Ensure this path is correct

/// A custom painter for drawing precise, landscape-oriented field previews,
/// including correctly rotated half-field views.
class FieldPreviewPainter extends CustomPainter {
  final BoardBackground backgroundType;
  final Color fieldColor;
  final Color lineColor;

  FieldPreviewPainter({
    required this.backgroundType,
    required this.fieldColor,
    this.lineColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (fieldColor != Colors.transparent) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = fieldColor);
    }

    switch (backgroundType) {
      case BoardBackground.full:
        // case BoardBackground.fullDuplicate:
        _drawFullPitch(canvas, size, linePaint, withCentralLines: false);
        break;
      case BoardBackground.clean:
        canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height), linePaint);
        break;
      case BoardBackground.halfUp:
        _drawHalfPitch(canvas, size, linePaint, isTopHalf: true);
        break;
      case BoardBackground.halfDown:
        _drawHalfPitch(canvas, size, linePaint, isTopHalf: false);
        break;
      case BoardBackground.verticalCorridors:
        _drawFullPitch(canvas, size, linePaint, withCentralLines: false);
        _drawCenterVerticalLines(canvas, size, linePaint);
        break;
      // case BoardBackground.horizontalZones:
      //   _drawFullPitch(canvas, size, linePaint, withCentralLines: false);
      //   _drawHorizontalZones(canvas, size, linePaint);
      //   break;
      // case BoardBackground.goalNetFront:
      //   _drawGoalNetFront(canvas, size, linePaint);
      //   break;
      // case BoardBackground.goalNetAngle:
      //   _drawGoalNetAngle(canvas, size, linePaint);
      //   break;
    }
  }

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

  // --- THIS IS THE CORRECTED METHOD ---
  void _drawHalfPitch(Canvas canvas, Size size, Paint paint,
      {required bool isTopHalf}) {
    // Proportions for a standard half-pitch (which is taller than it is wide)
    final fieldHeight = size.width; // The preview's width is our field's height
    final fieldWidth = size.height; // The preview's height is our field's width

    final penaltyBoxWidth = fieldWidth * 0.8;
    final penaltyBoxHeight = fieldHeight * 0.28;
    final goalBoxWidth = fieldWidth * 0.4;
    final goalBoxHeight = fieldHeight * 0.14;

    canvas.save();

    if (isTopHalf) {
      // Rotate 90 degrees to make the goal appear at the top
      canvas.translate(size.width, 0);
      canvas.rotate(pi / 2);
    } else {
      // Rotate -90 degrees to make the goal appear at the bottom
      canvas.translate(0, size.height);
      canvas.rotate(-pi / 2);
    }

    // After rotation, the canvas size is effectively swapped.
    // We draw as if we're drawing the "left" half of a portrait-oriented field.
    final rotatedSize = Size(size.height, size.width);

    // Draw the rotated outline and halfway line
    canvas.drawRect(
        Rect.fromLTWH(0, 0, rotatedSize.width, rotatedSize.height), paint);
    final halfwayLineX = rotatedSize.width;
    canvas.drawLine(Offset(halfwayLineX, 0),
        Offset(halfwayLineX, rotatedSize.height), paint);

    // Draw the goal and penalty boxes
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

  void _drawCenterVerticalLines(Canvas canvas, Size size, Paint paint) {
    // The first line is in the center of the left half (at 1/4 of the total width).
    final x1 = size.width * 0.3; // or (1 / 4.0)

    // The second line is in the center of the right half (at 3/4 of the total width).
    final x2 = size.width * 0.7; // or (3 / 4.0)

    canvas.drawLine(Offset(x1, 0), Offset(x1, size.height), paint);
    canvas.drawLine(Offset(x2, 0), Offset(x2, size.height), paint);
  }

  void _drawVerticalCorridors(Canvas canvas, Size size, Paint paint) {
    for (int i = 1; i <= 4; i++) {
      final x = size.width * (i / 5.0);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawHorizontalZones(Canvas canvas, Size size, Paint paint) {
    for (int i = 1; i <= 2; i++) {
      final y = size.height * (i / 3.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawGoalNetFront(Canvas canvas, Size size, Paint paint) {
    final frameWidth = size.width * 0.9;
    final frameHeight = size.height * 0.9;
    final frameRect = Rect.fromCenter(
        center: size.center(Offset.zero),
        width: frameWidth,
        height: frameHeight);
    canvas.drawRect(frameRect, paint);

    const int horizontalLines = 8;
    const int verticalLines = 12;

    for (int i = 1; i < horizontalLines; i++) {
      final y = frameRect.top + (frameRect.height * i / horizontalLines);
      canvas.drawLine(
          Offset(frameRect.left, y), Offset(frameRect.right, y), paint);
    }
    for (int i = 1; i < verticalLines; i++) {
      final x = frameRect.left + (frameRect.width * i / verticalLines);
      canvas.drawLine(
          Offset(x, frameRect.top), Offset(x, frameRect.bottom), paint);
    }
  }

  void _drawGoalNetAngle(Canvas canvas, Size size, Paint paint) {
    final frontX = size.width * 0.1;
    final backX = size.width * 0.9;
    final topY = size.height * 0.1;
    final bottomY = size.height * 0.9;

    final frontTop = Offset(frontX, topY);
    final frontBottom = Offset(frontX, bottomY);
    final backTop = Offset(backX, topY);
    final backBottom = Offset(backX, bottomY);

    canvas.drawLine(frontTop, frontBottom, paint);
    canvas.drawLine(frontTop, backTop, paint);
    canvas.drawLine(frontBottom, backBottom, paint);
  }

  @override
  bool shouldRepaint(covariant FieldPreviewPainter oldDelegate) {
    return oldDelegate.backgroundType != backgroundType ||
        oldDelegate.fieldColor != fieldColor;
  }
}
