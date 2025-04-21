import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart'; // For Canvas, Paint, Color
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // If needed
// Import your models - Ensure CircleShapeModel is included correctly
import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// Import game and providers
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class CircleShapeDrawerComponent extends PositionComponent
    with
        TapCallbacks,
        DragCallbacks,
        RiverpodComponentMixin,
        HasGameReference<TacticBoardGame> {
  final CircleShapeModel circleModel; // The initial model data
  late CircleShapeModel _internalCircle; // Internal mutable copy
  bool isActive = false;
  bool _isDragging = false;

  // Paints for rendering
  late Paint _strokePaint;
  Paint? _fillPaint; // Nullable if no fill
  late Paint _activeStrokePaint; // For selection highlight

  // Tap area tolerance
  final double _tapTolerance = 8.0;

  CircleShapeDrawerComponent({required this.circleModel})
    : super(priority: 1, anchor: Anchor.center);

  @override
  FutureOr<void> onLoad() {
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: onLoad Start. Initial Model: ${circleModel.toJson()}",
    );

    // Listen for selection changes
    addToGameWidgetBuild(() {
      ref.listen(boardProvider, (previous, current) {
        _updateIsActive(current.selectedItemOnTheBoard);
      });
    });

    // Clone the model for internal state management
    _internalCircle = circleModel.clone();
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: Cloned internal model: ${_internalCircle.toJson()}",
    );

    // Convert relative center from model to actual position for the component
    position = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: _internalCircle.center, // Use center (offset)
    );
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: Calculated actual position: $position",
    );

    _updatePaints();
    zlog(data: "Circle ${circleModel.id}: Paints updated."); // MODIFIED

    // Set initial size based on loaded radius
    size = Vector2(_internalCircle.radius * 2, _internalCircle.radius * 2);
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: Component size set to: $size",
    );

    return super.onLoad();
  }

  void _updatePaints() {
    final baseStrokeColor =
        _internalCircle.strokeColor ?? ColorManager.white; // Default stroke
    final baseFillColor = _internalCircle.fillColor;
    final baseStrokeWidth = _internalCircle.strokeWidth;
    final baseOpacity = _internalCircle.opacity ?? 1.0;

    _strokePaint =
        Paint()
          ..color = baseStrokeColor.withOpacity(baseOpacity)
          ..strokeWidth = baseStrokeWidth
          ..style = PaintingStyle.stroke;

    _activeStrokePaint =
        Paint()
          ..color = ColorManager.yellowLight.withOpacity(baseOpacity)
          ..strokeWidth = baseStrokeWidth + 2.0
          ..style = PaintingStyle.stroke;

    if (baseFillColor != null) {
      _fillPaint =
          Paint()
            ..color = baseFillColor.withOpacity(baseOpacity)
            ..style = PaintingStyle.fill;
    } else {
      _fillPaint = null;
    }
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: _updatePaints completed. Fill: ${_fillPaint != null}, Stroke Width: ${baseStrokeWidth}, Active Stroke Width: ${_activeStrokePaint.strokeWidth}",
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final radius = _internalCircle.radius;
    final paintToUse = isActive ? _activeStrokePaint : _strokePaint;

    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: render called. Radius: $radius, IsActive: $isActive, StrokeW: ${paintToUse.strokeWidth}, Fill: ${_fillPaint != null}",
    );

    if (_fillPaint != null) {
      canvas.drawCircle(Offset.zero, radius, _fillPaint!);
    }

    if (paintToUse.strokeWidth > 0) {
      canvas.drawCircle(Offset.zero, radius, paintToUse);
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final bool contains =
        point.length <= _internalCircle.radius + _tapTolerance;
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: containsLocalPoint($point): $contains (Radius: ${_internalCircle.radius})",
    );
    return contains;
  }

  // --- Tap Handling ---
  @override
  void onTapDown(TapDownEvent event) {
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: onTapDown at ${event.localPosition}",
    );
    if (containsLocalPoint(event.localPosition)) {
      _toggleActive();
      event.handled = true;
    } else {
      event.handled = false;
    }
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: onTapDown handled: ${event.handled}",
    );
  }

  void _toggleActive() {
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: _toggleActive called. Current isActive: $isActive",
    );
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: circleModel);
  }

  // --- Drag Handling ---
  @override
  void onDragStart(DragStartEvent event) {
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: onDragStart at ${event.localPosition}",
    );
    if (isActive && containsLocalPoint(event.localPosition)) {
      _isDragging = true;
      event.continuePropagation = false;
      zlog(
        data: // MODIFIED: Removed key, prepended ID
            "Circle ${circleModel.id}: Drag Started (_isDragging = true)",
      );
    } else {
      _isDragging = false;
      super.onDragStart(event);
      event.continuePropagation = true;
      zlog(
        data: // MODIFIED: Removed key, prepended ID
            "Circle ${circleModel.id}: Drag Not Started Here (isActive: $isActive)",
      );
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isDragging) {
      final oldPosition = position.clone();
      position.add(event.localDelta);
      zlog(
        data: // MODIFIED: Removed key, prepended ID
            "Circle ${circleModel.id}: Dragging: Delta ${event.localDelta}, Pos ${oldPosition} -> ${position}",
      );
      _updateModelPosition();
      event.continuePropagation = false;
    } else {
      super.onDragUpdate(event);
      event.continuePropagation = true;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: onDragEnd. Was dragging: $_isDragging",
    );
    if (_isDragging) {
      _isDragging = false;
      _updateModelPosition(); // Call final update on drag end
      event.continuePropagation = false;
      zlog(
        data: // MODIFIED: Removed key, prepended ID
            "Circle ${circleModel.id}: Drag Ended. Final position saved.",
      );
    } else {
      super.onDragEnd(event);
      event.continuePropagation = true;
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: onDragCancel. Was dragging: $_isDragging",
    );
    if (_isDragging) {
      _isDragging = false;
      event.continuePropagation = false;
    } else {
      super.onDragCancel(event);
      event.continuePropagation = true;
    }
  }

  /// Updates the provider with the current position (converted to relative).
  void _updateModelPosition() {
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: _updateModelPosition called. Current actual position: $position",
    );
    final relativeCenter = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: Calculated relativeCenter: $relativeCenter",
    );

    final updatedModel = circleModel.copyWith(
      offset: relativeCenter.clone(),
      radius: _internalCircle.radius,
      color: _internalCircle.strokeColor,
      fillColor: _internalCircle.fillColor,
      strokeWidth: _internalCircle.strokeWidth,
      opacity: _internalCircle.opacity,
    );
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: Notifying provider with updated model: ${updatedModel.toJson()}",
    );

    // Notify the provider
    ref.read(boardProvider.notifier).updateShape(shape: updatedModel);

    // Sync internal model ?
    _internalCircle = updatedModel.clone();
  }

  // --- State Update from Provider ---
  void _updateIsActive(FieldItemModel? selectedItem) {
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: _updateIsActive called. SelectedItem ID: ${selectedItem?.id} Type: ${selectedItem?.runtimeType}",
    );
    final newActiveState =
        selectedItem is CircleShapeModel && selectedItem.id == circleModel.id;
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: Calculated newActiveState: $newActiveState. Current isActive: $isActive",
    );

    if (isActive != newActiveState) {
      isActive = newActiveState;
      zlog(
        data: // MODIFIED: Removed key, prepended ID
            "Circle ${circleModel.id}: isActive CHANGED to: $isActive",
      );
      _updatePaints(); // Update paints to reflect active/inactive style
    }
  }

  /// Updates the radius and saves the model state via the provider.
  void updateRadiusAndSave(double newRadius) {
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: updateRadiusAndSave called with newRadius: $newRadius. Current internal radius: ${_internalCircle.radius}",
    );
    // --- 1. Validate Radius ---
    if (newRadius < 0) newRadius = 0;

    // --- 2. Update Internal State used for Rendering ---
    if ((_internalCircle.radius - newRadius).abs() < 0.01) {
      zlog(
        data: // MODIFIED: Removed key, prepended ID
            "Circle ${circleModel.id}: Radius unchanged ($newRadius), skipping update.",
      );
      return;
    }

    _internalCircle = _internalCircle.copyWith(radius: newRadius);
    size = Vector2(newRadius * 2, newRadius * 2); // Update component size
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: Internal radius updated to: ${_internalCircle.radius}. Component size set to: $size",
    );

    // --- 3. Prepare Updated Model for Provider ---
    final relativeCenter = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );

    final updatedModelForProvider = circleModel.copyWith(
      offset: relativeCenter.clone(),
      radius: newRadius,
      color: _internalCircle.strokeColor,
      fillColor: _internalCircle.fillColor,
      strokeWidth: _internalCircle.strokeWidth,
      opacity: _internalCircle.opacity,
    );
    zlog(
      data: // MODIFIED: Removed key, prepended ID
          "Circle ${circleModel.id}: Notifying provider with radius update: ${updatedModelForProvider.toJson()}",
    );

    // --- 4. Notify Provider ---
    ref
        .read(boardProvider.notifier)
        .updateShape(shape: updatedModelForProvider);
  }
}
