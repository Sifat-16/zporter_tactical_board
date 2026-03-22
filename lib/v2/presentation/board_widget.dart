import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/v2/core/coordinate_system.dart';
import 'package:zporter_tactical_board/v2/engine/board_painter.dart';
import 'package:zporter_tactical_board/v2/engine/field_painter.dart';
import 'package:zporter_tactical_board/v2/engine/hit_tester.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';

/// The V2 tactical board widget.
///
/// Replaces V1's `GameWidget<TacticBoardGame>`. Uses two stacked
/// [CustomPaint] layers:
///   1. [FieldPainter] — pitch background (only repaints on color/layout change)
///   2. [BoardPainter] — all elements + guides + grid
///
/// Handles all pointer interaction via [GestureDetector]:
///   - Tap → select/deselect element
///   - Drag → move selected element (center-anchored)
///   - Double-tap → element edit (delegated via callback)
///
/// All positions are stored as ratios (0.0–1.0) and converted
/// to screen pixels at paint time, so the board works identically
/// on any screen size.
class TacticBoardV2 extends StatelessWidget {
  /// Current board state (provided by a state management solution).
  final BoardStateV2 state;

  /// Called when the user taps an element.
  final ValueChanged<BoardElement?>? onElementSelected;

  /// Called when the user drags an element to a new position.
  /// Provides the element ID and new relative offset.
  final void Function(String elementId, Offset newRelativeOffset)? onElementMoved;

  /// Called when the user double-taps an element.
  final ValueChanged<BoardElement>? onElementDoubleTap;

  /// Called when the user taps empty space (deselect).
  final VoidCallback? onBoardTap;

  /// Called when a drag starts on an element.
  final ValueChanged<String>? onDragStart;

  /// Called when a drag ends.
  final VoidCallback? onDragEnd;

  const TacticBoardV2({
    super.key,
    required this.state,
    this.onElementSelected,
    this.onElementMoved,
    this.onElementDoubleTap,
    this.onBoardTap,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: _BoardInteractionLayer(
            state: state,
            onElementSelected: onElementSelected,
            onElementMoved: onElementMoved,
            onElementDoubleTap: onElementDoubleTap,
            onBoardTap: onBoardTap,
            onDragStart: onDragStart,
            onDragEnd: onDragEnd,
          ),
        );
      },
    );
  }
}

class _BoardInteractionLayer extends StatefulWidget {
  final BoardStateV2 state;
  final ValueChanged<BoardElement?>? onElementSelected;
  final void Function(String elementId, Offset newRelativeOffset)? onElementMoved;
  final ValueChanged<BoardElement>? onElementDoubleTap;
  final VoidCallback? onBoardTap;
  final ValueChanged<String>? onDragStart;
  final VoidCallback? onDragEnd;

  const _BoardInteractionLayer({
    required this.state,
    this.onElementSelected,
    this.onElementMoved,
    this.onElementDoubleTap,
    this.onBoardTap,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  State<_BoardInteractionLayer> createState() => _BoardInteractionLayerState();
}

class _BoardInteractionLayerState extends State<_BoardInteractionLayer> {
  static const _hitTester = HitTester();

  String? _draggedElementId;
  Offset? _lastDragPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onDoubleTapDown: _onDoubleTapDown,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        // Layer 1: Field background (pitch markings)
        painter: FieldPainter(
          fieldColor: widget.state.boardColor,
          boardBackground: widget.state.boardBackground,
        ),
        // Layer 2: Board elements + guides + grid
        foregroundPainter: BoardPainter(state: widget.state),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tap handling
  // ---------------------------------------------------------------------------

  void _onTapDown(TapDownDetails details) {
    final size = context.size;
    if (size == null) return;

    final coords = CoordinateSystem(size);
    final hit = _hitTester.hitTest(
      details.localPosition,
      widget.state.components,
      coords,
    );

    if (hit != null) {
      widget.onElementSelected?.call(hit);
    } else {
      widget.onElementSelected?.call(null);
      widget.onBoardTap?.call();
    }
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final size = context.size;
    if (size == null) return;

    final coords = CoordinateSystem(size);
    final hit = _hitTester.hitTest(
      details.localPosition,
      widget.state.components,
      coords,
    );

    if (hit != null) {
      widget.onElementDoubleTap?.call(hit);
    }
  }

  // ---------------------------------------------------------------------------
  // Drag handling — center-anchored
  // ---------------------------------------------------------------------------

  void _onPanStart(DragStartDetails details) {
    final size = context.size;
    if (size == null) return;

    final coords = CoordinateSystem(size);
    final hit = _hitTester.hitTest(
      details.localPosition,
      widget.state.components,
      coords,
    );

    if (hit != null) {
      _draggedElementId = hit.id;
      _lastDragPosition = details.localPosition;
      widget.onDragStart?.call(hit.id);
      widget.onElementSelected?.call(hit);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggedElementId == null) return;

    final size = context.size;
    if (size == null) return;

    final coords = CoordinateSystem(size);

    // Convert the pointer's current position to relative coords.
    // This IS the new center of the element (center-anchored).
    final newRelative = coords.toRelative(details.localPosition);
    widget.onElementMoved?.call(_draggedElementId!, newRelative);

    _lastDragPosition = details.localPosition;
  }

  void _onPanEnd(DragEndDetails details) {
    if (_draggedElementId != null) {
      _draggedElementId = null;
      _lastDragPosition = null;
      widget.onDragEnd?.call();
    }
  }
}
