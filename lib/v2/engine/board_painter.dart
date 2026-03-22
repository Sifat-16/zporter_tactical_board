import 'dart:ui';

import 'package:flutter/material.dart' show Colors, CustomPainter;
import 'package:zporter_tactical_board/v2/core/coordinate_system.dart';
import 'package:zporter_tactical_board/v2/engine/element_painters.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';

/// Main CustomPainter for the V2 tactical board.
///
/// Replaces V1's Flame game loop. Only repaints when [BoardStateV2]
/// changes (shouldRepaint compares state references), so CPU usage
/// is zero when the board is static.
///
/// Render order:
///   1. Elements sorted by zIndex (lowest first)
///   2. Smart-alignment guide lines (on top)
///   3. Grid overlay (when active)
class BoardPainter extends CustomPainter {
  final BoardStateV2 state;

  const BoardPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final coords = CoordinateSystem(size);

    // -------------------------------------------------------------------------
    // 1. Paint elements sorted by zIndex
    // -------------------------------------------------------------------------
    final elements = List.of(state.components);
    elements.sort((a, b) {
      final za = a.zIndex ?? 0;
      final zb = b.zIndex ?? 0;
      return za.compareTo(zb);
    });

    for (final element in elements) {
      final painter = getPainterForElement(element);
      painter.paint(
        canvas,
        element,
        coords,
        isSelected: element.id == state.selectedElementId,
        homeTeamBorderColor: state.homeTeamBorderColor,
        awayTeamBorderColor: state.awayTeamBorderColor,
      );
    }

    // -------------------------------------------------------------------------
    // 2. Smart guides
    // -------------------------------------------------------------------------
    if (state.activeGuides.isNotEmpty) {
      final guidePaint = Paint()
        ..color = Colors.cyan.withValues(alpha: 0.6)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      for (final guide in state.activeGuides) {
        canvas.drawLine(guide.start, guide.end, guidePaint);
      }
    }

    // -------------------------------------------------------------------------
    // 3. Grid overlay
    // -------------------------------------------------------------------------
    if (state.gridSize > 0 && state.isDraggingItem) {
      _paintGrid(canvas, size, state.gridSize);
    }
  }

  void _paintGrid(Canvas canvas, Size size, double gridSize) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;

    // Vertical lines
    for (double x = gridSize; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines
    for (double y = gridSize; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    // Only repaint when state actually changes.
    // This is what gives V2 zero-CPU when static — the key advantage
    // over V1's Flame 60fps loop.
    return state != oldDelegate.state;
  }
}
