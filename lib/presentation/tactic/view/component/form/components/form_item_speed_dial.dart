import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

// This is the CustomPainter logic copied from FormLineItem.
// It's needed here to draw the active line icon.
// In a real project, you would move this to a shared file `line_painter_utils.dart`.

CustomPainter _getPainterForType(LineModelV2 model, Color color) {
  switch (model.lineType) {
    case LineType.WALK_ONE_WAY:
      return _LinePainter(color: color, dashPattern: [4, 4]);
    case LineType.WALK_TWO_WAY:
      return _LinePainter(color: color, dashPattern: [4, 4], arrows: 2);
    case LineType.JOG_ONE_WAY:
      return _LinePainter(color: color, dashPattern: [8, 4]);
    case LineType.JOG_TWO_WAY:
      return _LinePainter(color: color, dashPattern: [8, 4], arrows: 2);
    case LineType.SPRINT_ONE_WAY:
      return _LinePainter(color: color, dashPattern: [2, 2]);
    case LineType.SPRINT_TWO_WAY:
      return _LinePainter(color: color, dashPattern: [2, 2], arrows: 2);
    case LineType.JUMP:
      return _LinePainter(color: color, isCurved: true, dashPattern: [3, 3]);
    case LineType.PASS:
      return _LinePainter(color: color);
    case LineType.PASS_HIGH_CROSS:
      return _LinePainter(color: color, isCurved: true);
    case LineType.DRIBBLE:
      return _LinePainter(color: color, isZigzag: true);
    case LineType.SHOOT:
      return _LinePainter(color: color, thickness: 3.5);
    default:
      return _LinePainter(color: color);
  }
}

class _LinePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final int arrows;
  final List<double>? dashPattern;
  final bool isCurved;
  final bool isZigzag;

  _LinePainter({
    required this.color,
    this.thickness = 1.5,
    this.arrows = 1,
    this.dashPattern,
    this.isCurved = false,
    this.isZigzag = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final start = Offset(0, size.height / 2);
    final end = Offset(size.width, size.height / 2);

    Offset arrowheadTip = end;
    double endAngle = isCurved ? 0.3 : 0;

    if (isCurved) {
      path.moveTo(start.dx, start.dy);
      path.quadraticBezierTo(size.width / 2, -size.height / 4, end.dx, end.dy);
    } else if (isZigzag) {
      path.moveTo(start.dx, start.dy);
      const zigzags = 7;
      final segmentWidth = size.width / zigzags;
      Offset p1 = start;
      Offset p2 = start;
      for (var i = 0; i < zigzags; i++) {
        p1 = p2;
        final nextX = start.dx + (i + 1) * segmentWidth;
        final nextY =
            start.dy + (i.isEven ? -size.height / 2.5 : size.height / 2.5);
        p2 = Offset(nextX, nextY);
        path.lineTo(p2.dx, p2.dy);
      }
      arrowheadTip = p2;
      final delta = p2 - p1;
      endAngle = delta.direction;
    } else {
      path.moveTo(start.dx, start.dy);
      path.lineTo(end.dx, end.dy);
    }

    if (dashPattern != null) {
      canvas.drawPath(dashPath(path, dashArray: dashPattern!), paint);
    } else {
      canvas.drawPath(path, paint);
    }

    if (arrows >= 1) {
      _drawArrowhead(canvas, paint, arrowheadTip, endAngle);
    }
    if (arrows == 2) {
      _drawArrowhead(canvas, paint, start, pi);
    }
  }

  void _drawArrowhead(Canvas canvas, Paint paint, Offset p, double angle) {
    const arrowSize = 6.0;
    final arrowPath = Path()
      ..moveTo(p.dx, p.dy)
      ..lineTo(p.dx - arrowSize, p.dy + arrowSize / 2)
      ..moveTo(p.dx, p.dy)
      ..lineTo(p.dx - arrowSize, p.dy - arrowSize / 2);
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(angle);
    canvas.translate(-p.dx, -p.dy);
    canvas.drawPath(arrowPath, paint);
    canvas.restore();
  }

  Path dashPath(Path source, {required List<double> dashArray}) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final len = dashArray[draw ? 0 : 1];
        if (draw) {
          dest.addPath(
              metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.arrows != arrows ||
        oldDelegate.dashPattern != dashPattern ||
        oldDelegate.isCurved != isCurved ||
        oldDelegate.isZigzag != isZigzag;
  }
}

// --- MAIN WIDGET ---

class FormItemSpeedDial extends ConsumerStatefulWidget {
  const FormItemSpeedDial({super.key, required this.formItem});
  final FieldItemModel formItem;

  @override
  ConsumerState<FormItemSpeedDial> createState() => _FormItemSpeedDialState();
}

class _FormItemSpeedDialState extends ConsumerState<FormItemSpeedDial> {
  @override
  Widget build(BuildContext context) {
    final lp = ref.watch(lineProvider);
    // This widget only appears when an item is active, so isFocused is always true.
    final bool isActiveItem = lp.activeForm?.id == widget.formItem.id;

    return GestureDetector(
      onTap: () {
        // When tapped, it always dismisses the active item.
        ref.read(lineProvider.notifier).dismissActiveFormItem();
      },
      child: _buildItemComponent(isFocused: isActiveItem),
    );
  }

  // UPDATED: This method now correctly renders Lines and Shapes.
  Widget _buildItemComponent({required bool isFocused}) {
    // The icon color is always the "active" color in this widget.
    final Color activeColor = ColorManager.red;

    final item = widget.formItem;

    if (item is LineModelV2) {
      // --- NEW: Use CustomPainter for LineModelV2 ---
      return SizedBox(
        width: AppSize.s32, // Consistent sizing
        height: AppSize.s32,
        child: CustomPaint(
          painter: _getPainterForType(item, activeColor),
        ),
      );
    } else if (item is ShapeModel) {
      // --- OLD: Continue using Image.asset for ShapeModel ---
      return Image.asset(
        "assets/images/${item.imagePath}",
        color: activeColor,
        height: AppSize.s24,
        width: AppSize.s24,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.error, color: activeColor, size: AppSize.s24),
      );
    }

    // Fallback for any other unexpected item type
    return Icon(Icons.error, color: activeColor, size: AppSize.s24);
  }
}
