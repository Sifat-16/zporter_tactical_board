import 'dart:ui';

import 'package:flutter/material.dart' show Colors, CustomPainter;
import 'package:zporter_tactical_board/v2/models/enums.dart';

/// Paints the soccer pitch markings onto the canvas.
///
/// Matches V1's [GameField] visual output:
/// - Black lines (stroke width 1.25)
/// - Full pitch is landscape (goals left/right, vertical halfway line)
/// - Half pitch views have goals top/bottom
/// - No penalty arcs, no corner arcs (matching V1)
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

    // V1 uses black lines with strokeWidth 1.25
    final linePaint = Paint()
      ..color = const Color(0xFF030405) // ColorManager.black
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF030405)
      ..style = PaintingStyle.fill;

    switch (boardBackground) {
      case BoardBackground.full:
        _drawFullPitch(canvas, size, linePaint, fillPaint);
      case BoardBackground.halfUp:
        _drawHalfPitchUp(canvas, size, linePaint);
      case BoardBackground.halfDown:
        _drawHalfPitchDown(canvas, size, linePaint);
      case BoardBackground.verticalCorridors:
        _drawFullPitch(canvas, size, linePaint, fillPaint);
        _drawVerticalCorridors(canvas, size, linePaint);
      case BoardBackground.clean:
        break;
    }

    // Outer boundary
    if (boardBackground != BoardBackground.clean) {
      canvas.drawRect(Offset.zero & size, linePaint);
    }
  }

  /// Full pitch: LANDSCAPE orientation (goals left/right, vertical halfway line)
  /// Matches V1's _drawFullPitchView exactly.
  void _drawFullPitch(
      Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final w = size.width;
    final h = size.height;

    // Proportions matching V1's landscape full-pitch view
    final centerCircleRadius = h * 0.14;
    final penaltyBoxW = w * 0.14;
    final penaltyBoxH = h * 0.6;
    final goalBoxW = w * 0.07;
    final goalBoxH = h * 0.3;
    const penaltySpotRadius = 4.0;

    // Vertical halfway line
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), paint);

    // Center circle
    canvas.drawCircle(Offset(w / 2, h / 2), centerCircleRadius, paint);

    // Center dot (filled)
    canvas.drawCircle(Offset(w / 2, h / 2), penaltySpotRadius, fillPaint);

    // Left penalty area
    canvas.drawRect(
      Rect.fromLTWH(0, (h - penaltyBoxH) / 2, penaltyBoxW, penaltyBoxH),
      paint,
    );

    // Left goal box
    canvas.drawRect(
      Rect.fromLTWH(0, (h - goalBoxH) / 2, goalBoxW, goalBoxH),
      paint,
    );

    // Left penalty spot
    canvas.drawCircle(
      Offset(penaltyBoxW * 0.75, h / 2),
      penaltySpotRadius,
      paint,
    );

    // Right penalty area
    canvas.drawRect(
      Rect.fromLTWH(
          w - penaltyBoxW, (h - penaltyBoxH) / 2, penaltyBoxW, penaltyBoxH),
      paint,
    );

    // Right goal box
    canvas.drawRect(
      Rect.fromLTWH(
          w - goalBoxW, (h - goalBoxH) / 2, goalBoxW, goalBoxH),
      paint,
    );

    // Right penalty spot
    canvas.drawCircle(
      Offset(w - penaltyBoxW * 0.75, h / 2),
      penaltySpotRadius,
      paint,
    );
  }

  /// Half pitch UP: goal at top, halfway line at bottom.
  /// Matches V1's _drawTopHalfMarkings.
  void _drawHalfPitchUp(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // Halfway line at bottom
    canvas.drawLine(Offset(0, h), Offset(w, h), paint);

    // Penalty area at top (V1 proportions)
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
  }

  /// Half pitch DOWN: goal at bottom, halfway line at top.
  /// Matches V1's _drawBottomHalfMarkings.
  void _drawHalfPitchDown(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // Halfway line at top
    canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);

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
  }

  /// Vertical corridor lines for the corridors background.
  /// Matches V1's _drawCenterVerticalLines.
  void _drawVerticalCorridors(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    canvas.drawLine(Offset(w * 0.3, 0), Offset(w * 0.3, h), paint);
    canvas.drawLine(Offset(w * 0.7, 0), Offset(w * 0.7, h), paint);
  }

  @override
  bool shouldRepaint(FieldPainter oldDelegate) {
    return fieldColor != oldDelegate.fieldColor ||
        boardBackground != oldDelegate.boardBackground;
  }
}
