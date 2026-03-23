import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/v2/core/coordinate_system.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';

/// Interactive resize and rotation handles overlaid on the board.
///
/// Sits in a [Stack] above the [CustomPaint] board. When an element is
/// selected, renders draggable handles at the corners (resize) and a
/// handle above the top-center (rotation).
///
/// Uses its own [GestureDetector]s per handle, so they win the gesture
/// arena over the board's pan detector (higher z-order in the Stack).
class SelectionHandlesOverlay extends StatelessWidget {
  final BoardStateV2 state;
  final Size boardSize;

  /// Called during resize drag with element ID and new relative size.
  final void Function(String elementId, Size newRelativeSize)? onResizeLive;

  /// Called when resize starts.
  final ValueChanged<String>? onResizeStart;

  /// Called when resize ends.
  final ValueChanged<String>? onResizeEnd;

  /// Called during rotation drag with element ID and new angle (radians).
  final void Function(String elementId, double newAngle)? onRotateLive;

  /// Called when rotation starts.
  final ValueChanged<String>? onRotationStart;

  /// Called when rotation ends.
  final ValueChanged<String>? onRotationEnd;

  const SelectionHandlesOverlay({
    super.key,
    required this.state,
    required this.boardSize,
    this.onResizeLive,
    this.onResizeStart,
    this.onResizeEnd,
    this.onRotateLive,
    this.onRotationStart,
    this.onRotationEnd,
  });

  @override
  Widget build(BuildContext context) {
    final element = state.selectedElement;
    if (element == null || element.offset == null) {
      return const SizedBox.shrink();
    }

    // Don't show handles during drag or playback
    if (state.isDraggingItem) return const SizedBox.shrink();

    final coords = CoordinateSystem(boardSize);
    final defaultSize = element.size ?? const Size(0.04, 0.04);
    final rect = coords.elementRect(
      relativeCenter: element.offset!,
      relativeSize: defaultSize,
    );
    final inflated = rect.inflate(6); // Match canvas selection border inflation

    const handleSize = 20.0; // Touch target
    const visualSize = 10.0; // Visual square
    const rotLineLen = 20.0;

    return SizedBox.expand(
      child: Stack(
        children: [
          // Corner resize handles
          for (final entry in {
            'tl': inflated.topLeft,
            'tr': inflated.topRight,
            'bl': inflated.bottomLeft,
            'br': inflated.bottomRight,
          }.entries)
            _ResizeHandle(
              key: ValueKey('handle_${entry.key}'),
              position: entry.value,
              corner: entry.key,
              handleSize: handleSize,
              visualSize: visualSize,
              elementId: element.id,
              elementRect: inflated,
              coords: coords,
              currentRelativeSize: defaultSize,
              onResizeStart: onResizeStart,
              onResizeLive: onResizeLive,
              onResizeEnd: onResizeEnd,
            ),

          // Rotation handle (above top-center)
          _RotationHandle(
            position: Offset(
              inflated.center.dx,
              inflated.top - rotLineLen,
            ),
            handleSize: handleSize,
            visualSize: visualSize,
            elementId: element.id,
            elementCenter: inflated.center,
            onRotationStart: onRotationStart,
            onRotateLive: onRotateLive,
            onRotationEnd: onRotationEnd,
          ),
        ],
      ),
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  final Offset position;
  final String corner;
  final double handleSize;
  final double visualSize;
  final String elementId;
  final Rect elementRect;
  final CoordinateSystem coords;
  final Size currentRelativeSize;
  final ValueChanged<String>? onResizeStart;
  final void Function(String elementId, Size newRelativeSize)? onResizeLive;
  final ValueChanged<String>? onResizeEnd;

  const _ResizeHandle({
    super.key,
    required this.position,
    required this.corner,
    required this.handleSize,
    required this.visualSize,
    required this.elementId,
    required this.elementRect,
    required this.coords,
    required this.currentRelativeSize,
    this.onResizeStart,
    this.onResizeLive,
    this.onResizeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - handleSize / 2,
      top: position.dy - handleSize / 2,
      width: handleSize,
      height: handleSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => onResizeStart?.call(elementId),
        onPanUpdate: (details) {
          if (onResizeLive == null) return;

          // Convert screen delta to relative delta
          final deltaRel = coords.sizeToRelative(
            Size(details.delta.dx.abs(), details.delta.dy.abs()),
          );

          // Determine sign based on corner and drag direction
          double dw = deltaRel.width;
          double dh = deltaRel.height;

          if (corner == 'tl') {
            dw = details.delta.dx < 0 ? dw : -dw;
            dh = details.delta.dy < 0 ? dh : -dh;
          } else if (corner == 'tr') {
            dw = details.delta.dx > 0 ? dw : -dw;
            dh = details.delta.dy < 0 ? dh : -dh;
          } else if (corner == 'bl') {
            dw = details.delta.dx < 0 ? dw : -dw;
            dh = details.delta.dy > 0 ? dh : -dh;
          } else {
            // br
            dw = details.delta.dx > 0 ? dw : -dw;
            dh = details.delta.dy > 0 ? dh : -dh;
          }

          final newW = (currentRelativeSize.width + dw).clamp(0.01, 1.0);
          final newH = (currentRelativeSize.height + dh).clamp(0.01, 1.0);
          onResizeLive!(elementId, Size(newW, newH));
        },
        onPanEnd: (_) => onResizeEnd?.call(elementId),
        child: Center(
          child: Container(
            width: visualSize,
            height: visualSize,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF00FF00),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RotationHandle extends StatelessWidget {
  final Offset position;
  final double handleSize;
  final double visualSize;
  final String elementId;
  final Offset elementCenter;
  final ValueChanged<String>? onRotationStart;
  final void Function(String elementId, double newAngle)? onRotateLive;
  final ValueChanged<String>? onRotationEnd;

  const _RotationHandle({
    required this.position,
    required this.handleSize,
    required this.visualSize,
    required this.elementId,
    required this.elementCenter,
    this.onRotationStart,
    this.onRotateLive,
    this.onRotationEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - handleSize / 2,
      top: position.dy - handleSize / 2,
      width: handleSize,
      height: handleSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => onRotationStart?.call(elementId),
        onPanUpdate: (details) {
          if (onRotateLive == null) return;

          // Calculate angle from element center to drag point
          final dragPoint = Offset(
            position.dx + details.delta.dx,
            position.dy + details.delta.dy,
          );
          final angle = atan2(
            dragPoint.dy - elementCenter.dy,
            dragPoint.dx - elementCenter.dx,
          );
          // Adjust: 0 angle = pointing up (subtract pi/2)
          onRotateLive!(elementId, angle + pi / 2);
        },
        onPanEnd: (_) => onRotationEnd?.call(elementId),
        child: Center(
          child: Container(
            width: visualSize,
            height: visualSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF00FF00),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
