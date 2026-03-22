import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart' show Colors, CustomPainter;
import 'package:zporter_tactical_board/v2/models/enums.dart';

/// Paints the soccer pitch markings (lines, arcs, boxes) onto the canvas.
///
/// Replaces V1's [GameField] Flame component. Renders using proportional
/// measurements so the pitch looks correct at any size.
///
/// Drawn entirely with Canvas calls — no image assets required.
class FieldPainter extends CustomPainter {
  final Color fieldColor;
  final BoardBackground boardBackground;

  const FieldPainter({
    required this.fieldColor,
    required this.boardBackground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = fieldColor,
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    switch (boardBackground) {
      case BoardBackground.full:
        _drawFullPitch(canvas, size, linePaint);
      case BoardBackground.halfUp:
        _drawHalfPitchUp(canvas, size, linePaint);
      case BoardBackground.halfDown:
        _drawHalfPitchDown(canvas, size, linePaint);
      case BoardBackground.verticalCorridors:
        _drawFullPitch(canvas, size, linePaint);
        _drawVerticalCorridors(canvas, size, linePaint);
      case BoardBackground.clean:
        // Just the colored background, no markings
        break;
    }

    // Outer boundary
    if (boardBackground != BoardBackground.clean) {
      canvas.drawRect(Offset.zero & size, linePaint);
    }
  }

  void _drawFullPitch(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // Center line (horizontal)
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), paint);

    // Center circle
    final centerCircleRadius = h * 0.14;
    canvas.drawCircle(Offset(w / 2, h / 2), centerCircleRadius, paint);

    // Center dot
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      3,
      Paint()
        ..color = paint.color
        ..style = PaintingStyle.fill,
    );

    // Top penalty area
    final penaltyW = w * 0.6;
    final penaltyH = h * 0.14;
    canvas.drawRect(
      Rect.fromLTWH((w - penaltyW) / 2, 0, penaltyW, penaltyH),
      paint,
    );

    // Top goal box
    final goalBoxW = w * 0.3;
    final goalBoxH = h * 0.07;
    canvas.drawRect(
      Rect.fromLTWH((w - goalBoxW) / 2, 0, goalBoxW, goalBoxH),
      paint,
    );

    // Top penalty arc
    final penaltySpotY = penaltyH * 0.85;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(w / 2, penaltySpotY),
        radius: centerCircleRadius * 0.7,
      ),
      0.3,
      math.pi - 0.6,
      false,
      paint,
    );

    // Bottom penalty area
    canvas.drawRect(
      Rect.fromLTWH((w - penaltyW) / 2, h - penaltyH, penaltyW, penaltyH),
      paint,
    );

    // Bottom goal box
    canvas.drawRect(
      Rect.fromLTWH((w - goalBoxW) / 2, h - goalBoxH, goalBoxW, goalBoxH),
      paint,
    );

    // Bottom penalty arc
    final bottomPenaltySpotY = h - penaltySpotY;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(w / 2, bottomPenaltySpotY),
        radius: centerCircleRadius * 0.7,
      ),
      math.pi + 0.3,
      math.pi - 0.6,
      false,
      paint,
    );

    // Corner arcs
    const cornerRadius = 8.0;
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: cornerRadius),
      0,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w, 0), radius: cornerRadius),
      math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, h), radius: cornerRadius),
      -math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w, h), radius: cornerRadius),
      math.pi,
      math.pi / 2,
      false,
      paint,
    );
  }

  void _drawHalfPitchUp(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // Halfway line at bottom
    canvas.drawLine(Offset(0, h), Offset(w, h), paint);

    // Half center circle at bottom
    final centerCircleRadius = w * 0.14;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w / 2, h), radius: centerCircleRadius),
      math.pi,
      math.pi,
      false,
      paint,
    );

    // Penalty area at top
    final penaltyW = w * 0.5;
    final penaltyH = h * 0.35;
    canvas.drawRect(
      Rect.fromLTWH((w - penaltyW) / 2, 0, penaltyW, penaltyH),
      paint,
    );

    // Goal box at top
    final goalBoxW = w * 0.25;
    final goalBoxH = h * 0.15;
    canvas.drawRect(
      Rect.fromLTWH((w - goalBoxW) / 2, 0, goalBoxW, goalBoxH),
      paint,
    );

    // Penalty arc
    final penaltySpotY = penaltyH * 0.85;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(w / 2, penaltySpotY),
        radius: centerCircleRadius * 0.7,
      ),
      0.3,
      math.pi - 0.6,
      false,
      paint,
    );
  }

  void _drawHalfPitchDown(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // Halfway line at top
    canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);

    // Half center circle at top
    final centerCircleRadius = w * 0.14;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w / 2, 0), radius: centerCircleRadius),
      0,
      math.pi,
      false,
      paint,
    );

    // Penalty area at bottom
    final penaltyW = w * 0.5;
    final penaltyH = h * 0.35;
    canvas.drawRect(
      Rect.fromLTWH((w - penaltyW) / 2, h - penaltyH, penaltyW, penaltyH),
      paint,
    );

    // Goal box at bottom
    final goalBoxW = w * 0.25;
    final goalBoxH = h * 0.15;
    canvas.drawRect(
      Rect.fromLTWH((w - goalBoxW) / 2, h - goalBoxH, goalBoxW, goalBoxH),
      paint,
    );

    // Penalty arc
    final penaltySpotY = h - penaltyH * 0.85;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(w / 2, penaltySpotY),
        radius: centerCircleRadius * 0.7,
      ),
      math.pi + 0.3,
      math.pi - 0.6,
      false,
      paint,
    );
  }

  void _drawVerticalCorridors(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    final corridorPaint = Paint()
      ..color = paint.color.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Vertical thirds lines
    canvas.drawLine(Offset(w * 0.3, 0), Offset(w * 0.3, h), corridorPaint);
    canvas.drawLine(Offset(w * 0.7, 0), Offset(w * 0.7, h), corridorPaint);
  }

  @override
  bool shouldRepaint(FieldPainter oldDelegate) {
    return fieldColor != oldDelegate.fieldColor ||
        boardBackground != oldDelegate.boardBackground;
  }
}
