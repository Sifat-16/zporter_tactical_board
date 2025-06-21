// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/app/manager/values_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart';
//
// class FormLineItem extends ConsumerStatefulWidget {
//   const FormLineItem({
//     super.key,
//     required this.lineModelV2,
//     required this.onTap,
//   });
//   final LineModelV2 lineModelV2;
//   final VoidCallback onTap;
//
//   @override
//   ConsumerState<FormLineItem> createState() => _FormLineItemState();
// }
//
// class _FormLineItemState extends ConsumerState<FormLineItem> {
//   @override
//   Widget build(BuildContext context) {
//     final lp = ref.watch(lineProvider);
//     return GestureDetector(
//       onTap: () {
//         if (lp.isLineActiveToAddIntoGameField) {
//           String? activeId = ref.read(lineProvider).activeId;
//           if (activeId == widget.lineModelV2.id) {
//             ref.read(lineProvider.notifier).dismissActiveFormItem();
//           } else {
//             ref.read(lineProvider.notifier).dismissActiveFormItem();
//             ref
//                 .read(lineProvider.notifier)
//                 .loadActiveLineModelToAddIntoGameFieldEvent(
//                   lineModelV2: widget.lineModelV2,
//                 );
//           }
//         } else {
//           ref
//               .read(lineProvider.notifier)
//               .loadActiveLineModelToAddIntoGameFieldEvent(
//                 lineModelV2: widget.lineModelV2,
//               );
//         }
//
//         widget.onTap();
//       },
//       child: _buildLineComponent(isFocused: isFocusedWidget(lp)),
//     );
//   }
//
//   bool isFocusedWidget(LineState lsp) {
//     if (lsp.isLineActiveToAddIntoGameField) {
//       FieldItemModel? fim = lsp.activeForm;
//
//       if (fim is LineModelV2) {
//         if (fim.lineType == widget.lineModelV2.lineType) {
//           return true;
//         }
//       }
//     }
//     return false;
//   }
//
//   Widget _buildLineComponent({required bool isFocused}) {
//     return RepaintBoundary(
//       key: UniqueKey(),
//       child: Center(
//         child: Image.asset(
//           "assets/images/${widget.lineModelV2.imagePath}",
//           color: isFocused ? ColorManager.yellowLight : ColorManager.white,
//           height: AppSize.s32,
//           width: AppSize.s32,
//         ),
//       ),
//     );
//   }
// }

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart';

class FormLineItem extends ConsumerStatefulWidget {
  const FormLineItem({
    super.key,
    required this.lineModelV2,
    required this.onTap,
  });
  final LineModelV2 lineModelV2;
  final VoidCallback onTap;

  @override
  ConsumerState<FormLineItem> createState() => _FormLineItemState();
}

class _FormLineItemState extends ConsumerState<FormLineItem> {
  @override
  Widget build(BuildContext context) {
    final lp = ref.watch(lineProvider);
    final isFocused = _isFocusedWidget(lp);

    return GestureDetector(
      onTap: () {
        if (lp.isLineActiveToAddIntoGameField) {
          String? activeId = ref.read(lineProvider).activeId;
          if (activeId == widget.lineModelV2.id) {
            ref.read(lineProvider.notifier).dismissActiveFormItem();
          } else {
            ref.read(lineProvider.notifier).dismissActiveFormItem();
            ref
                .read(lineProvider.notifier)
                .loadActiveLineModelToAddIntoGameFieldEvent(
                  lineModelV2: widget.lineModelV2,
                );
          }
        } else {
          ref
              .read(lineProvider.notifier)
              .loadActiveLineModelToAddIntoGameFieldEvent(
                lineModelV2: widget.lineModelV2,
              );
        }

        widget.onTap();
      },
      child: _buildLineComponent(isFocused: isFocused),
    );
  }

  bool _isFocusedWidget(LineState lsp) {
    if (lsp.isLineActiveToAddIntoGameField) {
      FieldItemModel? fim = lsp.activeForm;
      if (fim is LineModelV2) {
        // Compare the lineType instead of the ID.
        if (fim.lineType == widget.lineModelV2.lineType) {
          return true;
        }
      }
    }
    return false;
  }

  Widget _buildLineComponent({required bool isFocused}) {
    final color = isFocused ? ColorManager.yellowLight : Colors.white;

    return SizedBox(
      width: 80,
      height: 24,
      child: CustomPaint(
        painter: _getPainterForType(widget.lineModelV2, color),
      ),
    );
  }
}

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

    // Default values for arrowhead position and angle
    Offset arrowheadTip = end;
    double endAngle = isCurved ? 0.3 : 0;

    // Build the path and calculate final angle if needed
    if (isCurved) {
      path.moveTo(start.dx, start.dy);
      path.quadraticBezierTo(size.width / 2, -size.height / 4, end.dx, end.dy);
    } else if (isZigzag) {
      // --- START OF FIX FOR DRIBBLE ARROW ---
      path.moveTo(start.dx, start.dy);
      const zigzags = 7;
      final segmentWidth = size.width / zigzags;

      Offset p1 = start; // The point before the last one
      Offset p2 = start; // The last point

      for (var i = 0; i < zigzags; i++) {
        p1 = p2; // Store the previous point
        final nextX = start.dx + (i + 1) * segmentWidth;
        final nextY =
            start.dy + (i.isEven ? -size.height / 2.5 : size.height / 2.5);
        p2 = Offset(nextX, nextY); // Calculate the new point
        path.lineTo(p2.dx, p2.dy);
      }

      // The tip of the arrow should be at the end of the zigzag
      arrowheadTip = p2;

      // Calculate the angle of the last segment
      final delta = p2 - p1;
      endAngle = delta.direction; // This gets the angle in radians
      // --- END OF FIX FOR DRIBBLE ARROW ---
    } else {
      path.moveTo(start.dx, start.dy);
      path.lineTo(end.dx, end.dy);
    }

    // Draw the main path (solid or dashed)
    if (dashPattern != null) {
      canvas.drawPath(dashPath(path, dashArray: dashPattern!), paint);
    } else {
      canvas.drawPath(path, paint);
    }

    // Draw arrowheads using the calculated positions and angles
    if (arrows >= 1) {
      _drawArrowhead(canvas, paint, arrowheadTip, endAngle);
    }
    if (arrows == 2) {
      // Reversed arrow always points left from the start
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
    final Path dest = Path();
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
