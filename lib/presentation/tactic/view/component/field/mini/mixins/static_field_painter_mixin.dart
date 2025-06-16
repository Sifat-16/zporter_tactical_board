// --- Mixin for Static Field Drawing ---
import 'dart:math' as math;
import 'dart:ui';

mixin StaticFieldPainterMixin {
  void drawStaticField(
    Canvas canvas,
    Size size, {
    required Paint fieldPaint,
    required Paint borderPaint,
    required Paint spotPaint,
  }) {
    // borderPaint.strokeWidth is set in the main class based on size
    final double centerCircleRadius = size.height * 0.12;
    final double penaltyBoxWidth = size.width * 0.15;
    final double penaltyBoxHeight = size.height * 0.4;
    final double goalBoxWidth = size.width * 0.06;
    final double goalBoxHeight = size.height * 0.15;
    final double penaltySpotRadius = math.max(1.0, size.shortestSide * 0.01);
    final Offset center = size.center(Offset.zero);
    final double penaltyDistX = size.width * 0.11;

    canvas.drawRect(Offset.zero & size, fieldPaint);
    canvas.drawRect(Offset.zero & size, borderPaint);
    canvas.drawCircle(center, centerCircleRadius, borderPaint);
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        center.dy - penaltyBoxHeight / 2,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - penaltyBoxWidth,
        center.dy - penaltyBoxHeight / 2,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        center.dy - goalBoxHeight / 2,
        goalBoxWidth,
        goalBoxHeight,
      ),
      borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - goalBoxWidth,
        center.dy - goalBoxHeight / 2,
        goalBoxWidth,
        goalBoxHeight,
      ),
      borderPaint,
    );
    canvas.drawCircle(
      Offset(penaltyDistX, center.dy),
      penaltySpotRadius,
      spotPaint,
    );
    canvas.drawCircle(
      Offset(size.width - penaltyDistX, center.dy),
      penaltySpotRadius,
      spotPaint,
    );
    canvas.drawCircle(center, penaltySpotRadius, spotPaint);
  }
}
