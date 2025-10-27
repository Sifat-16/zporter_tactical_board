import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/data/animation/model/trajectory_path_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';

/// Draggable control point component for editing trajectory paths
///
/// PRO FEATURE: Interactive handles for editing Catmull-Rom spline curves
///
/// Visual appearance:
/// - Circular handle (12px diameter)
/// - Different icons based on type:
///   - Sharp (square icon): Creates sharp angle at control point
///   - Smooth (circle icon): Creates smooth curve at control point
///   - Symmetric (diamond icon): Maintains symmetry on both sides
/// - Larger and highlighted when selected or dragged
/// - Semi-transparent when not interacting
class ControlPointComponent extends PositionComponent
    with DragCallbacks, TapCallbacks, HasGameReference<TacticBoardGame> {
  /// The control point data model
  final ControlPoint controlPoint;

  /// Callback when control point is dragged
  final Function(String id, Vector2 newPosition) onDrag;

  /// Callback when control point is tapped (for type cycling)
  final Function(String id)? onTap;

  /// Whether this control point is currently selected
  bool isSelected;

  /// Whether this control point is being dragged
  bool _isDragging = false;

  /// Visual properties
  static const double _normalRadius =
      12.0; // Increased from 6.0 for easier dragging
  static const double _selectedRadius = 14.0; // Increased from 8.0
  static const double _dragRadius = 16.0; // Increased from 9.0
  static const double _hitboxRadius =
      24.0; // Large hitbox for easier interaction

  /// Paint for the control point circle
  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;

  /// Paint for the border
  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..color = Colors.white;

  /// Paint for the icon inside
  final Paint _iconPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..color = Colors.white;

  ControlPointComponent({
    required this.controlPoint,
    required this.onDrag,
    this.onTap,
    this.isSelected = false,
    super.priority = 10, // Render on top of everything
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Convert logical coordinates to screen coordinates
    final fieldSize = game.gameField.size;
    final fieldPosition = game.gameField.position;

    final screenPos = SizeHelper.getBoardActualVector(
      gameScreenSize: fieldSize,
      actualPosition: controlPoint.position,
    );

    // Validate position before setting
    if (screenPos.x.isNaN ||
        screenPos.y.isNaN ||
        screenPos.x.isInfinite ||
        screenPos.y.isInfinite) {
      print(
          '⚠️ Invalid control point position: $screenPos from logical ${controlPoint.position}');
      // Set to field center as fallback
      position = fieldPosition + (fieldSize / 2);
    } else {
      position = screenPos + fieldPosition; // Add field offset
    }

    // Set size to match VISUAL size (not hitbox size)
    // We'll override containsLocalPoint for larger hit detection
    final radius = _getCurrentRadius();
    size = Vector2.all(radius * 2);

    // Center anchor
    anchor = Anchor.topLeft;

    print(
        '🔵 ControlPoint ${controlPoint.id} loaded at position: $position, visual size: ${size.x}');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final radius = _getCurrentRadius();
    // Since anchor is Anchor.center, render at origin (0,0)
    final center = Offset.zero;

    // Determine color based on control point type
    final fillColor = _getColorForType();
    _fillPaint.color = fillColor;

    // Draw filled circle
    canvas.drawCircle(center, radius, _fillPaint);

    // Draw border
    canvas.drawCircle(center, radius, _borderPaint);

    // Draw icon based on type
    _drawTypeIcon(canvas, center, radius * 0.5);
  }

  /// Get the current radius based on state
  double _getCurrentRadius() {
    if (_isDragging) return _dragRadius;
    if (isSelected) return _selectedRadius;
    return _normalRadius;
  }

  /// Get color based on control point type
  Color _getColorForType() {
    final opacity = _isDragging ? 1.0 : (isSelected ? 0.9 : 0.7);

    switch (controlPoint.type) {
      case ControlPointType.sharp:
        return Colors.orange.withOpacity(opacity);
      case ControlPointType.smooth:
        return Colors.blue.withOpacity(opacity);
      case ControlPointType.symmetric:
        return Colors.purple.withOpacity(opacity);
    }
  }

  /// Draw icon inside the control point based on type
  void _drawTypeIcon(Canvas canvas, Offset center, double iconSize) {
    switch (controlPoint.type) {
      case ControlPointType.sharp:
        // Draw small square
        final rect = Rect.fromCenter(
          center: center,
          width: iconSize,
          height: iconSize,
        );
        canvas.drawRect(rect, _iconPaint);
        break;

      case ControlPointType.smooth:
        // Draw small circle
        canvas.drawCircle(center, iconSize / 2, _iconPaint);
        break;

      case ControlPointType.symmetric:
        // Draw diamond (rotated square)
        final path = Path()
          ..moveTo(center.dx, center.dy - iconSize / 2) // Top
          ..lineTo(center.dx + iconSize / 2, center.dy) // Right
          ..lineTo(center.dx, center.dy + iconSize / 2) // Bottom
          ..lineTo(center.dx - iconSize / 2, center.dy) // Left
          ..close();
        canvas.drawPath(path, _iconPaint);
        break;
    }
  }

  // ========== Drag Callbacks ==========

  @override
  bool containsLocalPoint(Vector2 point) {
    // Use large hitbox for easier interaction
    final hitboxRadius = _hitboxRadius;
    final distance = point.length;
    return distance <= hitboxRadius;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
    print('🎯 Drag START on control point ${controlPoint.id}');
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    // Update position with drag delta (in screen coordinates)
    position.add(event.canvasDelta);

    // Convert screen coordinates back to logical coordinates for callback
    final fieldSize = game.gameField.size;
    final fieldPosition = game.gameField.position;

    // Remove field offset before converting to logical coordinates
    final relativeToField = position - fieldPosition;

    final logicalPosition = SizeHelper.getBoardRelativeVector(
      gameScreenSize: fieldSize,
      actualPosition: relativeToField,
    );

    // Validate logical position
    if (logicalPosition.x.isNaN ||
        logicalPosition.y.isNaN ||
        logicalPosition.x.isInfinite ||
        logicalPosition.y.isInfinite) {
      print('⚠️ Invalid logical position during drag: $logicalPosition');
      return;
    }

    // Notify parent about the drag with logical coordinates
    onDrag(controlPoint.id, logicalPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
    print('🎯 Drag END on control point ${controlPoint.id}');
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _isDragging = false;
    print('🎯 Drag CANCEL on control point ${controlPoint.id}');
  }

  // ========== Tap Callbacks ==========

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // Visual feedback on tap
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    // Notify parent about tap (cycle control point type)
    onTap?.call(controlPoint.id);
  }

  // ========== Public Methods ==========

  /// Update selection state
  void setSelected(bool selected) {
    if (isSelected != selected) {
      isSelected = selected;
      final radius = _getCurrentRadius();
      size = Vector2.all(radius * 2);
    }
  }

  /// Update position programmatically
  void updatePosition(Vector2 newPosition) {
    position = newPosition.clone();
  }

  /// Get the control point ID
  String get id => controlPoint.id;

  /// Get the control point type
  ControlPointType get type => controlPoint.type;
}
