import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart' show Colors, TextPainter, TextSpan, TextStyle, FontWeight, TextAlign, Shadow;
import 'package:zporter_tactical_board/v2/core/coordinate_system.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/equipment_element.dart';
import 'package:zporter_tactical_board/v2/models/free_draw_element.dart';
import 'package:zporter_tactical_board/v2/models/line_element.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/models/shape_elements.dart';
import 'package:zporter_tactical_board/v2/models/text_element.dart';

// =============================================================================
// Base painter interface
// =============================================================================

/// Paints a single board element onto a canvas.
///
/// Each element type has its own painter that knows how to convert
/// relative coordinates to screen pixels and draw the element
/// center-anchored at its position.
abstract class ElementPainter {
  const ElementPainter();

  /// Paint the element onto the canvas.
  void paint(
    Canvas canvas,
    BoardElement element,
    CoordinateSystem coords, {
    bool isSelected = false,
    Color? homeTeamBorderColor,
    Color? awayTeamBorderColor,
  });

  /// Test if a screen-pixel point hits this element.
  bool hitTest(
    Offset screenPoint,
    BoardElement element,
    CoordinateSystem coords,
  );
}

// =============================================================================
// PlayerPainter
// =============================================================================

class PlayerPainter extends ElementPainter {
  const PlayerPainter();

  static const _cornerRadius = 6.0;

  @override
  void paint(
    Canvas canvas,
    BoardElement element,
    CoordinateSystem coords, {
    bool isSelected = false,
    Color? homeTeamBorderColor,
    Color? awayTeamBorderColor,
  }) {
    final player = element as PlayerElement;
    final center = coords.toScreen(player.offset ?? Offset.zero);
    final relSize = player.size ?? const Size(0.03, 0.045);
    final w = coords.dimensionToScreen(relSize.width);
    final h = coords.dimensionToScreen(relSize.height);
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_cornerRadius),
    );

    final baseOpacity = player.opacity.clamp(0.0, 1.0);

    canvas.save();

    // Rotation
    if (player.angle != null && player.angle != 0.0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(player.angle! * math.pi / 180);
      canvas.translate(-center.dx, -center.dy);
    }

    // Clip to rounded rect
    canvas.clipRRect(rrect);

    // Fill background with team color
    final Color fillColor;
    if (player.borderColor != null) {
      fillColor = player.borderColor!;
    } else {
      switch (player.playerType) {
        case PlayerType.HOME:
          fillColor = homeTeamBorderColor ?? Colors.blue;
        case PlayerType.AWAY:
          fillColor = awayTeamBorderColor ?? Colors.red;
        case PlayerType.OTHER:
        case PlayerType.UNKNOWN:
          fillColor = const Color(0xFF9E9E9E);
      }
    }

    final bgPaint = Paint()
      ..color = fillColor.withValues(alpha: baseOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // Role text (center of element)
    if (player.showRole && player.role != '-') {
      final fontSize = (w / 2) * 0.7;
      _paintCenteredText(
        canvas,
        player.role,
        center,
        fontSize,
        Colors.white.withValues(alpha: baseOpacity),
      );
    }

    canvas.restore();

    // Border stroke (drawn after clip restore)
    final Color teamBorderColor;
    if (player.borderColor != null) {
      teamBorderColor = player.borderColor!;
    } else {
      switch (player.playerType) {
        case PlayerType.HOME:
          teamBorderColor = homeTeamBorderColor ?? Colors.blue;
        case PlayerType.AWAY:
          teamBorderColor = awayTeamBorderColor ?? const Color(0xFF974AC8);
        case PlayerType.OTHER:
        case PlayerType.UNKNOWN:
          teamBorderColor = const Color(0xFF9E9E9E);
      }
    }
    final borderPaint = Paint()
      ..color = teamBorderColor.withValues(alpha: baseOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, borderPaint);

    // Jersey number (top-right)
    final numberStr = _getDisplayNumber(player);
    if (player.showNr && numberStr.isNotEmpty) {
      final jerseyFontSize = w * 0.3;
      final tp = TextPainter(
        text: TextSpan(
          text: numberStr,
          style: TextStyle(
            color: Colors.white.withValues(alpha: baseOpacity),
            fontSize: jerseyFontSize,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(rect.right - w * 0.1, rect.top - h * 0.15));
    }

    // Player name (below element)
    final playerName = player.name;
    if (player.showName &&
        playerName != null &&
        playerName.isNotEmpty &&
        playerName != '-') {
      final nameStyle = TextStyle(
        color: Colors.white.withValues(alpha: baseOpacity),
        fontSize: w * 0.25,
        fontWeight: FontWeight.w600,
        shadows: [
          Shadow(
            blurRadius: 2,
            color: Colors.black.withValues(alpha: 0.9),
          ),
        ],
      );

      String truncate(String s) => s.length > 9 ? s.substring(0, 9) : s;
      final parts =
          playerName.trim().split(' ').where((p) => p.isNotEmpty).toList();
      String textToRender;
      if (parts.length > 1) {
        textToRender = '${truncate(parts.first)}\n${truncate(parts.sublist(1).join(' '))}';
      } else {
        textToRender = truncate(playerName);
      }

      final nameTp = TextPainter(
        text: TextSpan(text: textToRender, style: nameStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 2,
      )..layout(maxWidth: w * 1.5);

      nameTp.paint(
        canvas,
        Offset(center.dx - nameTp.width / 2, rect.bottom + 4.0),
      );
    }

    // Selection highlight
    if (isSelected) {
      _paintSelectionBorder(canvas, rect);
    }
  }

  String _getDisplayNumber(PlayerElement player) {
    final num = player.displayNumber ?? player.jerseyNumber;
    final s = num.toString();
    return s == '-1' ? '' : s;
  }

  @override
  bool hitTest(Offset screenPoint, BoardElement element, CoordinateSystem coords) {
    final player = element as PlayerElement;
    final center = coords.toScreen(player.offset ?? Offset.zero);
    final relSize = player.size ?? const Size(0.03, 0.045);
    final w = coords.dimensionToScreen(relSize.width);
    final h = coords.dimensionToScreen(relSize.height);
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    return rect.contains(screenPoint);
  }
}

// =============================================================================
// EquipmentPainter
// =============================================================================

class EquipmentPainter extends ElementPainter {
  const EquipmentPainter();

  @override
  void paint(
    Canvas canvas,
    BoardElement element,
    CoordinateSystem coords, {
    bool isSelected = false,
    Color? homeTeamBorderColor,
    Color? awayTeamBorderColor,
  }) {
    final equip = element as EquipmentElement;
    final center = coords.toScreen(equip.offset ?? Offset.zero);
    final relSize = equip.size ?? const Size(0.02, 0.02);
    final w = coords.dimensionToScreen(relSize.width);
    final h = coords.dimensionToScreen(relSize.height);
    final rect = Rect.fromCenter(center: center, width: w, height: h);

    final baseOpacity = equip.opacity.clamp(0.0, 1.0);

    canvas.save();
    if (equip.angle != null && equip.angle != 0.0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(equip.angle! * math.pi / 180);
      canvas.translate(-center.dx, -center.dy);
    }

    // Equipment placeholder (colored circle)
    final color = equip.color ?? const Color(0xFFFFFFFF);
    final paint = Paint()
      ..color = color.withValues(alpha: baseOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawOval(rect, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: baseOpacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawOval(rect, borderPaint);

    // Name text centered
    if (equip.name.isNotEmpty) {
      final fontSize = math.min(w, h) * 0.3;
      _paintCenteredText(
        canvas,
        equip.name.length > 4 ? equip.name.substring(0, 4) : equip.name,
        center,
        fontSize,
        Colors.black.withValues(alpha: baseOpacity),
      );
    }

    canvas.restore();

    if (isSelected) {
      _paintSelectionBorder(canvas, rect);
    }
  }

  @override
  bool hitTest(Offset screenPoint, BoardElement element, CoordinateSystem coords) {
    final equip = element as EquipmentElement;
    final center = coords.toScreen(equip.offset ?? Offset.zero);
    final relSize = equip.size ?? const Size(0.02, 0.02);
    final w = coords.dimensionToScreen(relSize.width);
    final h = coords.dimensionToScreen(relSize.height);
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    return rect.contains(screenPoint);
  }
}

// =============================================================================
// LinePainter
// =============================================================================

class LinePainter extends ElementPainter {
  const LinePainter();

  static const _hitTolerance = 10.0;

  @override
  void paint(
    Canvas canvas,
    BoardElement element,
    CoordinateSystem coords, {
    bool isSelected = false,
    Color? homeTeamBorderColor,
    Color? awayTeamBorderColor,
  }) {
    final line = element as LineElement;
    final startPx = coords.toScreen(line.start);
    final endPx = coords.toScreen(line.end);

    final baseOpacity = line.opacity.clamp(0.0, 1.0);
    final color = line.color ?? Colors.white;
    final thickness = coords.dimensionToScreen(line.thickness / 1000);

    final paint = Paint()
      ..color = color.withValues(alpha: baseOpacity)
      ..strokeWidth = thickness.clamp(1.0, 20.0)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw based on line type
    switch (line.lineType) {
      case LineType.DRIBBLE:
        _drawZigzag(canvas, startPx, endPx, paint, thickness);
      case LineType.PASS_HIGH_CROSS:
      case LineType.JUMP:
        _drawDashed(canvas, startPx, endPx, paint);
      default:
        // Straight or curved line
        if (line.controlPoint1 != null || line.controlPoint2 != null) {
          _drawCurved(canvas, startPx, endPx, line, coords, paint);
        } else {
          canvas.drawLine(startPx, endPx, paint);
        }
    }

    // Arrow head for directional lines
    if (_hasArrow(line.lineType)) {
      _drawArrowHead(canvas, startPx, endPx, paint, thickness);
    }

    if (isSelected) {
      final rect = Rect.fromPoints(startPx, endPx).inflate(8);
      _paintSelectionBorder(canvas, rect);
    }
  }

  bool _hasArrow(LineType type) {
    switch (type) {
      case LineType.WALK_ONE_WAY:
      case LineType.JOG_ONE_WAY:
      case LineType.SPRINT_ONE_WAY:
      case LineType.PASS:
      case LineType.PASS_HIGH_CROSS:
      case LineType.SHOOT:
        return true;
      default:
        return false;
    }
  }

  void _drawDashed(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    const dashLength = 8.0;
    const gapLength = 4.0;

    double drawn = 0.0;
    while (drawn < length) {
      final t1 = drawn / length;
      final t2 = math.min((drawn + dashLength) / length, 1.0);
      canvas.drawLine(
        Offset.lerp(start, end, t1)!,
        Offset.lerp(start, end, t2)!,
        paint,
      );
      drawn += dashLength + gapLength;
    }
  }

  void _drawZigzag(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double amplitude,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    final perpX = -dy / length;
    final perpY = dx / length;

    const segments = 12;
    final path = Path()..moveTo(start.dx, start.dy);

    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final midPoint = Offset.lerp(start, end, t)!;
      final direction = (i % 2 == 0) ? 1.0 : -1.0;
      final zigAmplitude = amplitude * 2;
      path.lineTo(
        midPoint.dx + perpX * direction * zigAmplitude,
        midPoint.dy + perpY * direction * zigAmplitude,
      );
    }

    canvas.drawPath(path, paint);
  }

  void _drawCurved(
    Canvas canvas,
    Offset startPx,
    Offset endPx,
    LineElement line,
    CoordinateSystem coords,
    Paint paint,
  ) {
    final path = Path()..moveTo(startPx.dx, startPx.dy);

    if (line.controlPoint1 != null && line.controlPoint2 != null) {
      final cp1 = coords.toScreen(line.controlPoint1!);
      final cp2 = coords.toScreen(line.controlPoint2!);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, endPx.dx, endPx.dy);
    } else if (line.controlPoint1 != null) {
      final cp1 = coords.toScreen(line.controlPoint1!);
      path.quadraticBezierTo(cp1.dx, cp1.dy, endPx.dx, endPx.dy);
    } else {
      final cp2 = coords.toScreen(line.controlPoint2!);
      path.quadraticBezierTo(cp2.dx, cp2.dy, endPx.dx, endPx.dy);
    }

    canvas.drawPath(path, paint);
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double thickness,
  ) {
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final arrowSize = math.max(thickness * 3, 8.0);

    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx - arrowSize * math.cos(angle - 0.4),
      end.dy - arrowSize * math.sin(angle - 0.4),
    );
    path.lineTo(
      end.dx - arrowSize * math.cos(angle + 0.4),
      end.dy - arrowSize * math.sin(angle + 0.4),
    );
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = paint.color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool hitTest(Offset screenPoint, BoardElement element, CoordinateSystem coords) {
    final line = element as LineElement;
    final startPx = coords.toScreen(line.start);
    final endPx = coords.toScreen(line.end);

    return _distanceToSegment(screenPoint, startPx, endPx) <= _hitTolerance;
  }

  double _distanceToSegment(Offset point, Offset a, Offset b) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final lengthSq = dx * dx + dy * dy;

    if (lengthSq == 0) return (point - a).distance;

    var t = ((point.dx - a.dx) * dx + (point.dy - a.dy) * dy) / lengthSq;
    t = t.clamp(0.0, 1.0);

    final projection = Offset(a.dx + t * dx, a.dy + t * dy);
    return (point - projection).distance;
  }
}

// =============================================================================
// FreeDrawPainter
// =============================================================================

class FreeDrawPainter extends ElementPainter {
  const FreeDrawPainter();

  static const _hitTolerance = 12.0;

  @override
  void paint(
    Canvas canvas,
    BoardElement element,
    CoordinateSystem coords, {
    bool isSelected = false,
    Color? homeTeamBorderColor,
    Color? awayTeamBorderColor,
  }) {
    final draw = element as FreeDrawElement;
    if (draw.points.length < 2) return;

    final baseOpacity = draw.opacity.clamp(0.0, 1.0);
    final color = draw.color ?? Colors.white;
    final thickness = coords.dimensionToScreen(draw.thickness / 1000);

    final paint = Paint()
      ..color = color.withValues(alpha: baseOpacity)
      ..strokeWidth = thickness.clamp(1.0, 20.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final firstPoint = coords.toScreen(draw.points[0]);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < draw.points.length; i++) {
      final point = coords.toScreen(draw.points[i]);
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, paint);

    if (isSelected) {
      final bounds = path.getBounds().inflate(8);
      _paintSelectionBorder(canvas, bounds);
    }
  }

  @override
  bool hitTest(Offset screenPoint, BoardElement element, CoordinateSystem coords) {
    final draw = element as FreeDrawElement;
    if (draw.points.length < 2) return false;

    for (int i = 0; i < draw.points.length - 1; i++) {
      final a = coords.toScreen(draw.points[i]);
      final b = coords.toScreen(draw.points[i + 1]);
      if (_distanceToSegment(screenPoint, a, b) <= _hitTolerance) return true;
    }
    return false;
  }

  double _distanceToSegment(Offset point, Offset a, Offset b) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final lengthSq = dx * dx + dy * dy;
    if (lengthSq == 0) return (point - a).distance;
    var t = ((point.dx - a.dx) * dx + (point.dy - a.dy) * dy) / lengthSq;
    t = t.clamp(0.0, 1.0);
    final projection = Offset(a.dx + t * dx, a.dy + t * dy);
    return (point - projection).distance;
  }
}

// =============================================================================
// TextPainterElement
// =============================================================================

class TextElementPainter extends ElementPainter {
  const TextElementPainter();

  @override
  void paint(
    Canvas canvas,
    BoardElement element,
    CoordinateSystem coords, {
    bool isSelected = false,
    Color? homeTeamBorderColor,
    Color? awayTeamBorderColor,
  }) {
    final textEl = element as TextElement;
    final center = coords.toScreen(textEl.offset ?? Offset.zero);
    final relSize = textEl.size ?? const Size(0.1, 0.03);
    final w = coords.dimensionToScreen(relSize.width);
    final h = coords.dimensionToScreen(relSize.height);
    final rect = Rect.fromCenter(center: center, width: w, height: h);

    final baseOpacity = textEl.opacity.clamp(0.0, 1.0);
    final color = textEl.color ?? Colors.black;

    canvas.save();
    if (textEl.angle != null && textEl.angle != 0.0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textEl.angle! * math.pi / 180);
      canvas.translate(-center.dx, -center.dy);
    }

    // Fit text into rect
    final fontSize = _fitFontSize(textEl.text, w, h);
    final tp = TextPainter(
      text: TextSpan(
        text: textEl.text,
        style: TextStyle(
          color: color.withValues(alpha: baseOpacity),
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: w);

    tp.paint(
      canvas,
      Offset(
        center.dx - tp.width / 2,
        center.dy - tp.height / 2,
      ),
    );

    canvas.restore();

    if (isSelected) {
      _paintSelectionBorder(canvas, rect);
    }
  }

  double _fitFontSize(String text, double maxWidth, double maxHeight) {
    double lo = 4.0, hi = maxHeight;
    while (hi - lo > 1.0) {
      final mid = (lo + hi) / 2;
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: mid),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);

      if (tp.height <= maxHeight && tp.width <= maxWidth) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  @override
  bool hitTest(Offset screenPoint, BoardElement element, CoordinateSystem coords) {
    final textEl = element as TextElement;
    final center = coords.toScreen(textEl.offset ?? Offset.zero);
    final relSize = textEl.size ?? const Size(0.1, 0.03);
    final w = coords.dimensionToScreen(relSize.width);
    final h = coords.dimensionToScreen(relSize.height);
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    return rect.contains(screenPoint);
  }
}

// =============================================================================
// CirclePainter
// =============================================================================

class CirclePainter extends ElementPainter {
  const CirclePainter();

  @override
  void paint(
    Canvas canvas,
    BoardElement element,
    CoordinateSystem coords, {
    bool isSelected = false,
    Color? homeTeamBorderColor,
    Color? awayTeamBorderColor,
  }) {
    final circle = element as CircleElement;
    final center = coords.toScreen(circle.center);
    final radiusPx = coords.dimensionToScreen(circle.radius);

    final baseOpacity = circle.opacity.clamp(0.0, 1.0);

    // Fill
    if (circle.fillColor != null) {
      final fillPaint = Paint()
        ..color = circle.fillColor!.withValues(alpha: baseOpacity * 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radiusPx, fillPaint);
    }

    // Stroke
    final strokeColor = circle.strokeColor ?? Colors.white;
    final strokePaint = Paint()
      ..color = strokeColor.withValues(alpha: baseOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = coords.dimensionToScreen(circle.strokeWidth / 1000);
    canvas.drawCircle(center, radiusPx, strokePaint);

    if (isSelected) {
      final rect = Rect.fromCircle(center: center, radius: radiusPx);
      _paintSelectionBorder(canvas, rect);
    }
  }

  @override
  bool hitTest(Offset screenPoint, BoardElement element, CoordinateSystem coords) {
    final circle = element as CircleElement;
    final center = coords.toScreen(circle.center);
    final radiusPx = coords.dimensionToScreen(circle.radius);
    final tapTolerance = 8.0;
    return (screenPoint - center).distance <= radiusPx + tapTolerance;
  }
}

// =============================================================================
// SquarePainter
// =============================================================================

class SquarePainter extends ElementPainter {
  const SquarePainter();

  @override
  void paint(
    Canvas canvas,
    BoardElement element,
    CoordinateSystem coords, {
    bool isSelected = false,
    Color? homeTeamBorderColor,
    Color? awayTeamBorderColor,
  }) {
    final square = element as SquareElement;
    final center = coords.toScreen(square.center);
    final sidePx = coords.dimensionToScreen(square.side);
    final rect = Rect.fromCenter(center: center, width: sidePx, height: sidePx);

    final baseOpacity = square.opacity.clamp(0.0, 1.0);

    canvas.save();
    if (square.angle != null && square.angle != 0.0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(square.angle! * math.pi / 180);
      canvas.translate(-center.dx, -center.dy);
    }

    // Fill
    if (square.fillColor != null) {
      final fillPaint = Paint()
        ..color = square.fillColor!.withValues(alpha: baseOpacity * 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, fillPaint);
    }

    // Stroke
    final strokeColor = square.strokeColor ?? Colors.white;
    final strokePaint = Paint()
      ..color = strokeColor.withValues(alpha: baseOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = coords.dimensionToScreen(square.strokeWidth / 1000);
    canvas.drawRect(rect, strokePaint);

    canvas.restore();

    if (isSelected) {
      _paintSelectionBorder(canvas, rect);
    }
  }

  @override
  bool hitTest(Offset screenPoint, BoardElement element, CoordinateSystem coords) {
    final square = element as SquareElement;
    final center = coords.toScreen(square.center);
    final sidePx = coords.dimensionToScreen(square.side);
    final rect = Rect.fromCenter(center: center, width: sidePx, height: sidePx);
    return rect.contains(screenPoint);
  }
}

// =============================================================================
// TrianglePainter
// =============================================================================

class TrianglePainter extends ElementPainter {
  const TrianglePainter();

  @override
  void paint(
    Canvas canvas,
    BoardElement element,
    CoordinateSystem coords, {
    bool isSelected = false,
    Color? homeTeamBorderColor,
    Color? awayTeamBorderColor,
  }) {
    final tri = element as TriangleElement;
    if (tri.vertexA == null || tri.vertexB == null || tri.vertexC == null) {
      return;
    }

    final a = coords.toScreen(tri.vertexA!);
    final b = coords.toScreen(tri.vertexB!);
    final c = coords.toScreen(tri.vertexC!);

    final baseOpacity = tri.opacity.clamp(0.0, 1.0);

    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();

    // Fill
    if (tri.fillColor != null) {
      final fillPaint = Paint()
        ..color = tri.fillColor!.withValues(alpha: baseOpacity * 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    // Stroke
    final strokeColor = tri.strokeColor ?? Colors.white;
    final strokePaint = Paint()
      ..color = strokeColor.withValues(alpha: baseOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = coords.dimensionToScreen(tri.strokeWidth / 1000);
    canvas.drawPath(path, strokePaint);

    if (isSelected) {
      _paintSelectionBorder(canvas, path.getBounds());
    }
  }

  @override
  bool hitTest(Offset screenPoint, BoardElement element, CoordinateSystem coords) {
    final tri = element as TriangleElement;
    if (tri.vertexA == null || tri.vertexB == null || tri.vertexC == null) {
      return false;
    }

    final a = coords.toScreen(tri.vertexA!);
    final b = coords.toScreen(tri.vertexB!);
    final c = coords.toScreen(tri.vertexC!);

    // Point-in-triangle test using barycentric coordinates
    return _pointInTriangle(screenPoint, a, b, c);
  }

  bool _pointInTriangle(Offset p, Offset a, Offset b, Offset c) {
    final d1 = _sign(p, a, b);
    final d2 = _sign(p, b, c);
    final d3 = _sign(p, c, a);
    final hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    final hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
    return !(hasNeg && hasPos);
  }

  double _sign(Offset p1, Offset p2, Offset p3) {
    return (p1.dx - p3.dx) * (p2.dy - p3.dy) -
        (p2.dx - p3.dx) * (p1.dy - p3.dy);
  }
}

// =============================================================================
// PolygonPainter
// =============================================================================

class PolygonPainter extends ElementPainter {
  const PolygonPainter();

  @override
  void paint(
    Canvas canvas,
    BoardElement element,
    CoordinateSystem coords, {
    bool isSelected = false,
    Color? homeTeamBorderColor,
    Color? awayTeamBorderColor,
  }) {
    final poly = element as PolygonElement;
    if (poly.relativeVertices.length < 2) return;

    final baseOpacity = poly.opacity.clamp(0.0, 1.0);

    final path = Path();
    final firstVertex = coords.toScreen(poly.relativeVertices[0]);
    path.moveTo(firstVertex.dx, firstVertex.dy);
    for (int i = 1; i < poly.relativeVertices.length; i++) {
      final v = coords.toScreen(poly.relativeVertices[i]);
      path.lineTo(v.dx, v.dy);
    }
    path.close();

    // Fill
    if (poly.fillColor != null) {
      final fillPaint = Paint()
        ..color = poly.fillColor!.withValues(alpha: baseOpacity * 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    // Stroke
    final strokeColor = poly.strokeColor ?? Colors.white;
    final strokePaint = Paint()
      ..color = strokeColor.withValues(alpha: baseOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = coords.dimensionToScreen(poly.strokeWidth / 1000);
    canvas.drawPath(path, strokePaint);

    // Vertex dots (when selected)
    if (isSelected) {
      for (final v in poly.relativeVertices) {
        final vPx = coords.toScreen(v);
        canvas.drawCircle(
          vPx,
          4.0,
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill,
        );
      }
      _paintSelectionBorder(canvas, path.getBounds());
    }
  }

  @override
  bool hitTest(Offset screenPoint, BoardElement element, CoordinateSystem coords) {
    final poly = element as PolygonElement;
    if (poly.relativeVertices.length < 3) return false;

    final path = Path();
    final first = coords.toScreen(poly.relativeVertices[0]);
    path.moveTo(first.dx, first.dy);
    for (int i = 1; i < poly.relativeVertices.length; i++) {
      final v = coords.toScreen(poly.relativeVertices[i]);
      path.lineTo(v.dx, v.dy);
    }
    path.close();

    return path.contains(screenPoint);
  }
}

// =============================================================================
// Shared helpers
// =============================================================================

void _paintCenteredText(
  Canvas canvas,
  String text,
  Offset center,
  double fontSize,
  Color color,
) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(
    canvas,
    Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
  );
}

void _paintSelectionBorder(Canvas canvas, Rect rect) {
  final selPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  canvas.drawRect(rect.inflate(4), selPaint);

  // Corner handles
  const handleSize = 6.0;
  final handlePaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;
  final inflated = rect.inflate(4);
  for (final corner in [
    inflated.topLeft,
    inflated.topRight,
    inflated.bottomLeft,
    inflated.bottomRight,
  ]) {
    canvas.drawRect(
      Rect.fromCenter(
        center: corner,
        width: handleSize,
        height: handleSize,
      ),
      handlePaint,
    );
  }
}

// =============================================================================
// Painter registry — maps element type to its painter
// =============================================================================

/// Returns the correct painter for a given element type.
ElementPainter getPainterForElement(BoardElement element) {
  switch (element.fieldItemType) {
    case FieldItemType.PLAYER:
      return const PlayerPainter();
    case FieldItemType.EQUIPMENT:
      return const EquipmentPainter();
    case FieldItemType.LINE:
      return const LinePainter();
    case FieldItemType.FREEDRAW:
      return const FreeDrawPainter();
    case FieldItemType.TEXT:
      return const TextElementPainter();
    case FieldItemType.CIRCLE:
      return const CirclePainter();
    case FieldItemType.SQUARE:
      return const SquarePainter();
    case FieldItemType.TRIANGLE:
      return const TrianglePainter();
    case FieldItemType.POLYGON:
      return const PolygonPainter();
  }
}
