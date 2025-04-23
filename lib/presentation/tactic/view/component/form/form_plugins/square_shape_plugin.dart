import 'dart:async';
import 'dart:math' as math; // For math.pi

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart'; // For Canvas, Paint, Color, Rect, Offset
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // If needed
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// Import your models
import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart'; // Import the specific model
// Import game and providers
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

// Constant for converting degrees to radians
const degrees2Radians = math.pi / 180.0;

class SquareShapeDrawerComponent extends PositionComponent
    with
        TapCallbacks,
        DragCallbacks,
        RiverpodComponentMixin,
        HasGameReference<TacticBoardGame> {
  final SquareShapeModel squareModel; // The initial model data
  late SquareShapeModel _internalSquare; // Internal mutable copy
  bool isActive = false;
  bool _isDragging = false; // For dragging the whole square

  // Paints for rendering
  late Paint _strokePaint;
  Paint? _fillPaint;
  late Paint _activeStrokePaint;

  // Tap area tolerance (expand hitbox slightly)
  final double _tapTolerance = 5.0;

  // Store actual pixel side length for rendering and hit detection
  double _actualSide = 0.0;

  SquareShapeDrawerComponent({required this.squareModel})
    : super(
        priority: 1, // Or appropriate layer
        anchor: Anchor.center, // Anchor at the logical center
      );

  @override
  FutureOr<void> onLoad() {
    zlog(
      data:
          "Square ${squareModel.id}: onLoad Start. Initial Model: ${squareModel.toJson()}",
    );

    addToGameWidgetBuild(() {
      ref.listen(boardProvider, (previous, current) {
        _updateIsActive(current.selectedItemOnTheBoard);
      });
    });

    _internalSquare = squareModel.clone();
    zlog(
      data:
          "Square ${squareModel.id}: Cloned internal model: ${_internalSquare.toJson()}",
    );

    // Set component position based on model's relative center
    position = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: _internalSquare.center, // offset is center
    );
    zlog(
      data: "Square ${squareModel.id}: Calculated actual position: $position",
    );

    // Convert relative side from model to actual pixel side length
    _actualSide = SizeHelper.getBoardActualDimension(
      gameScreenSize: game.gameField.size,
      relativeSize: _internalSquare.side, // Use relative side from model
    );
    zlog(
      data:
          "Square ${squareModel.id}: Converted to actual side length: $_actualSide",
    );

    // Update internal model's side to actual temporarily? No, keep internal model reflecting save state.
    // Use _actualSide variable directly for size/render/hit detection.

    _updatePaints();
    zlog(data: "Square ${squareModel.id}: Paints updated.");

    // Set component size (for Flame's bounding box)
    size = Vector2(_actualSide, _actualSide);
    // Set component angle from model's angle (converted to radians)
    angle = degrees2Radians * (_internalSquare.angle ?? 0.0);

    zlog(
      data:
          "Square ${squareModel.id}: Component size=$size, angle=$angle (rad)",
    );

    // Check initial active state
    final initialState = ref.read(boardProvider);
    _updateIsActive(initialState.selectedItemOnTheBoard);
    zlog(
      data: "Square ${squareModel.id}: Initial active state checked: $isActive",
    );

    zlog(data: "Square ${squareModel.id}: onLoad Finished.");
    return super.onLoad();
  }

  void _updatePaints() {
    final baseStrokeColor = _internalSquare.strokeColor ?? ColorManager.white;
    final baseFillColor = _internalSquare.fillColor;
    final baseStrokeWidth = _internalSquare.strokeWidth;
    final baseOpacity = _internalSquare.opacity ?? 1.0;

    _strokePaint =
        Paint()
          ..color = baseStrokeColor.withOpacity(baseOpacity)
          ..strokeWidth = baseStrokeWidth
          ..style = PaintingStyle.stroke;

    _activeStrokePaint =
        Paint()
          ..color = ColorManager.yellowLight.withOpacity(
            baseOpacity,
          ) // Selection color
          ..strokeWidth =
              baseStrokeWidth +
              2.0 // Thicker when active
          ..style = PaintingStyle.stroke;

    _fillPaint =
        baseFillColor != null
            ? (Paint()
              ..color = baseFillColor.withOpacity(baseOpacity)
              ..style = PaintingStyle.fill)
            : null;
    zlog(data: "Square ${squareModel.id}: _updatePaints completed.");
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Use the calculated actual side length
    final side = _actualSide;
    // Define the rectangle centered at Offset.zero because component is center-anchored
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: side,
      height: side,
    );
    final paintToUse = isActive ? _activeStrokePaint : _strokePaint;

    // Component's angle property handles rotation automatically

    // Draw fill first
    if (_fillPaint != null) {
      canvas.drawRect(rect, _fillPaint!);
    }
    // Draw stroke
    if (paintToUse.strokeWidth > 0) {
      canvas.drawRect(rect, paintToUse);
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Hit detection based on the component's current size (_actualSide)
    // This simple check is for the axis-aligned bounding box around the center anchor.
    // For rotated squares, this is an approximation. Use RectangleHitbox for precision if needed.
    final halfSide = _actualSide / 2;
    final tolerance =
        _tapTolerance +
        (_strokePaint.strokeWidth / 2); // Tolerance includes half stroke width
    bool contains =
        (point.x.abs() <= halfSide + tolerance) &&
        (point.y.abs() <= halfSide + tolerance);

    // zlog(data: "Square ${squareModel.id}: containsLocalPoint($point): $contains (HalfSide: $halfSide, Tol: $tolerance)");
    return contains;
  }

  // --- Tap Handling ---
  @override
  void onTapDown(TapDownEvent event) {
    zlog(data: "Square ${squareModel.id}: onTapDown at ${event.localPosition}");
    if (containsLocalPoint(event.localPosition)) {
      _toggleActive();
      event.handled = true; // Consume the event
    } else {
      event.handled = false;
    }
    zlog(data: "Square ${squareModel.id}: onTapDown handled: ${event.handled}");
  }

  void _toggleActive() {
    zlog(
      data:
          "Square ${squareModel.id}: _toggleActive called. Current isActive: $isActive",
    );
    // Use the *original* model instance's ID
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: squareModel);
  }

  // --- Drag Handling (Moving the Square) ---
  @override
  void onDragStart(DragStartEvent event) {
    zlog(
      data: "Square ${squareModel.id}: onDragStart at ${event.localPosition}",
    );
    if (isActive && containsLocalPoint(event.localPosition)) {
      _isDragging = true;
      event.continuePropagation = false; // Consume event
      zlog(
        data:
            "Square ${squareModel.id}: Component Drag Started (_isDragging = true)",
      );
    } else {
      _isDragging = false;
      super.onDragStart(event); // Allow propagation if miss
      event.continuePropagation = true;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isDragging) {
      position.add(event.localDelta);
      // Avoid updating provider on every frame - update only onDragEnd
      event.continuePropagation = false;
    } else {
      super.onDragUpdate(event);
      event.continuePropagation = true;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    zlog(
      data:
          "Square ${squareModel.id}: onDragEnd. Was dragging component: $_isDragging",
    );
    if (_isDragging) {
      _isDragging = false;
      _updateModelPosition(); // Update provider with final position
      event.continuePropagation = false;
      zlog(
        data:
            "Square ${squareModel.id}: Component Drag Ended. Final position saved.",
      );
    } else {
      super.onDragEnd(event);
      event.continuePropagation = true;
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    zlog(
      data:
          "Square ${squareModel.id}: onDragCancel. Was dragging component: $_isDragging",
    );
    if (_isDragging) {
      _isDragging = false;
      event.continuePropagation = false;
    } else {
      super.onDragCancel(event);
      event.continuePropagation = true;
    }
  }

  /// Updates the provider with the current position (center) and side length (all relative).
  void _updateModelPosition() {
    zlog(
      data:
          "Square ${squareModel.id}: _updateModelPosition (Center Update). Actual Pos: $position",
    );
    // Convert actual center position back to relative
    final relativeCenter = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
    // Convert actual side length back to relative
    final relativeSide = SizeHelper.getBoardRelativeDimension(
      gameScreenSize: game.gameField.size,
      actualSize: _actualSide,
    );
    // Convert actual angle (radians) back to degrees for saving
    final angleInDegrees = angle * (180 / math.pi);

    final updatedModel = squareModel.copyWith(
      offset: relativeCenter.clone(), // Relative center
      side: relativeSide, // Relative side
      angle: angleInDegrees, // Angle in degrees
      // Include other properties from internal model if they can be modified
      color: _internalSquare.strokeColor,
      fillColor: _internalSquare.fillColor,
      strokeWidth: _internalSquare.strokeWidth,
      opacity: _internalSquare.opacity,
    );
    zlog(
      data:
          "Square ${squareModel.id}: Notifying provider (Position Update): ${updatedModel.toJson()}",
    );
    ref
        .read(boardProvider.notifier)
        .updateShape(shape: updatedModel); // Assumes updateShape exists
  }

  // --- State Update from Provider ---
  void _updateIsActive(FieldItemModel? selectedItem) {
    zlog(
      data:
          "Square ${squareModel.id}: _updateIsActive check. Selected ID: ${selectedItem?.id}",
    );
    final newActiveState =
        selectedItem is SquareShapeModel && selectedItem.id == squareModel.id;

    if (isActive != newActiveState) {
      isActive = newActiveState;
      zlog(data: "Square ${squareModel.id}: isActive CHANGED to: $isActive");
      _updatePaints(); // Update paints for selection highlight change
    }
  }

  void updateSideAndSave(double newActualSide) {
    zlog(
      data:
          "Square ${squareModel.id}: updateSideAndSave called with newActualSide: $newActualSide",
    );
    // --- 1. Validate Side ---
    if (newActualSide < 0) newActualSide = 0; // Side cannot be negative

    // --- 2. Update Internal Actual Side and Component Size ---
    // Check if actual side changed significantly
    if ((_actualSide - newActualSide).abs() < 0.01) {
      // zlog(data: "Square ${squareModel.id}: Actual side unchanged ($newActualSide), skipping update.");
      return; // Exit if no significant change
    }

    _actualSide = newActualSide; // Update internal actual side length
    size = Vector2(newActualSide, newActualSide); // Update component size
    zlog(
      data:
          "Square ${squareModel.id}: Internal ACTUAL side updated to: ${_actualSide}. Size: $size",
    );
  }
}
