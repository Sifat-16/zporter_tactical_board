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
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

// --- DraggableDot Class (Renamed to CircleRadiusDraggableDot as per user code) ---
// Make sure this class definition is accessible (either in this file or imported)
class CircleRadiusDraggableDot extends CircleComponent with DragCallbacks {
  final Function(Vector2) onPositionChanged;
  final Function onDotDragEnd; // Callback for when dot drag specifically ends
  final Vector2 initialPosition;
  final bool canModifyLine;
  final int dotIndex;

  static const double _hitRadiusPadding =
      15.0; // Extra space around dot for tapping/dragging

  CircleRadiusDraggableDot({
    required this.onPositionChanged,
    required this.initialPosition,
    required this.onDotDragEnd, // Added this callback
    required this.dotIndex,
    this.canModifyLine = true,
    super.radius = 8.0,
    Color color = Colors.blue,
  }) : super(
          position: initialPosition,
          anchor: Anchor.center,
          paint: Paint()..color = color,
          priority: 2, // Ensure dots render above main component (priority 1)
        );

  Vector2? _dragStartLocalPosition;

  @override
  void onDragStart(DragStartEvent event) {
    _dragStartLocalPosition = event.localPosition;
    event.continuePropagation = true;
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragStartLocalPosition != null) {
      // Pass potential new position based on delta
      onPositionChanged(position + event.localDelta / 2);
    }
    event.continuePropagation =
        true; // Allow parent potentially? Check if needed.
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _dragStartLocalPosition = null;
    onDotDragEnd(); // Call the specific callback for dot drag end
    super.onDragEnd(event);
    event.continuePropagation = true;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _dragStartLocalPosition = null;
    // Optionally call onDotDragEnd() or a specific cancel handler if needed
    super.onDragCancel(event);
    event.continuePropagation = true;
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Check distance against the visual radius PLUS the extra padding
    final double effectiveHitRadius = radius + _hitRadiusPadding;
    // point.length is the distance from the component's anchor (center)
    return point.length <= effectiveHitRadius;
  }
}

// --- CircleShapeDrawerComponent Class ---

class CircleShapeDrawerComponent extends PositionComponent
    with
        TapCallbacks,
        DragCallbacks,
        RiverpodComponentMixin,
        HasGameReference<TacticBoardGame> {
  CircleShapeModel circleModel; // The initial model data
  late CircleShapeModel _internalCircle; // Internal mutable copy
  bool isActive = false;
  bool _isDragging = false; // For dragging the whole circle

  // Paints for rendering
  late Paint _strokePaint;
  Paint? _fillPaint;
  late Paint _activeStrokePaint;

  // Tap area tolerance
  final double _tapTolerance = 8.0;

  // --- State for the resize dot ---
  CircleRadiusDraggableDot? _resizeDot;
  // --- Offset for the resize dot ---
  final double _dotOffsetAbove = 10.0; // Pixels above the circle edge

  CircleShapeDrawerComponent({required this.circleModel})
      : super(priority: 1, anchor: Anchor.topLeft);

  @override
  FutureOr<void> onLoad() {
    zlog(
      data:
          "Circle ${circleModel.id}: onLoad Start. Initial Model: ${circleModel.toJson()}",
    );

    addToGameWidgetBuild(() {
      ref.listen(boardProvider, (previous, current) {
        _updateIsActive(current.selectedItemOnTheBoard);
      });
    });

    _internalCircle = circleModel.clone();
    zlog(
      data:
          "Circle ${circleModel.id}: Cloned internal model: ${_internalCircle.toJson()}",
    );

    // Set priority from model's zIndex for persistence across reloads
    if (circleModel.zIndex != null) {
      priority = circleModel.zIndex!;
    }

    position = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: _internalCircle.center,
    );
    zlog(
      data: "Circle ${circleModel.id}: Calculated actual position: $position",
    );

    // Convert relative radius from model to actual for internal use
    _internalCircle.radius = SizeHelper.getBoardActualDimension(
      gameScreenSize: game.gameField.size,
      relativeSize: circleModel.radius, // Use original model's relative radius
    );
    zlog(
      data:
          "Circle ${circleModel.id}: Converted to actual internal radius: ${_internalCircle.radius}",
    );

    _updatePaints();
    zlog(data: "Circle ${circleModel.id}: Paints updated.");

    size = Vector2(_internalCircle.radius * 2, _internalCircle.radius * 2);
    zlog(data: "Circle ${circleModel.id}: Component size set to: $size");

    _createResizeDot(); // Create dot instance

    zlog(data: "Circle ${circleModel.id}: onLoad Finished.");
    return super.onLoad();
  }

  /// Creates the DraggableDot instance used for resizing.
  void _createResizeDot() {
    _resizeDot = CircleRadiusDraggableDot(
      dotIndex: 99,
      // Position slightly above the top edge
      initialPosition: Vector2(0, -_internalCircle.radius - _dotOffsetAbove),
      radius: 6.0, // Fixed size handle
      color: Colors.blue,
      canModifyLine: true, // Flag might not be relevant here
      onDotDragEnd: () {
        // --- Save final state AFTER dot drag ends ---
        zlog(
          data:
              "Circle ${circleModel.id}: Resize Dot Drag Ended. Saving final position and radius.",
        );
        _updateModelPositionAndRadius(); // Use combined method for final save
      },
      onPositionChanged: (newPos) {
        // Calculate new radius based on vertical distance from center, accounting for offset
        double newActualRadius = (newPos.y + _dotOffsetAbove).abs();

        // Min radius constraint
        if (newActualRadius < 5.0) newActualRadius = 5.0;

        updateRadiusAndSave(newActualRadius);

        _resizeDot?.position = Vector2(
          0,
          -_internalCircle.radius - _dotOffsetAbove,
        );
      },
    );
    zlog(data: "Circle ${circleModel.id}: Resize dot created instance.");
  }

  void _updatePaints() {
    // Uses _internalCircle which holds ACTUAL radius after onLoad adjustment
    final baseStrokeColor = _internalCircle.strokeColor ?? ColorManager.black;
    final baseFillColor = _internalCircle.fillColor;
    final baseStrokeWidth = _internalCircle.strokeWidth;
    final baseOpacity = _internalCircle.opacity ?? 1.0;

    _strokePaint = Paint()
      ..color = baseStrokeColor.withValues(alpha: baseOpacity)
      ..strokeWidth = baseStrokeWidth
      ..style = PaintingStyle.stroke;

    _activeStrokePaint = Paint()
      ..color = baseStrokeColor.withValues(alpha: baseOpacity)
      ..strokeWidth = baseStrokeWidth + 2.0
      ..style = PaintingStyle.stroke;

    _fillPaint = Paint()
      ..color = baseStrokeColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    zlog(data: "Circle ${circleModel.id}: _updatePaints completed...");
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Use the ACTUAL radius stored in _internalCircle for rendering
    _strokePaint.color = circleModel.color ?? ColorManager.black;
    _activeStrokePaint.color = circleModel.color ?? ColorManager.black;
    _fillPaint?.color = circleModel.color?.withValues(alpha: 0.1) ??
        ColorManager.black.withValues(alpha: 0.1);

    final radius = _internalCircle.radius;
    final paintToUse = isActive ? _activeStrokePaint : _strokePaint;

    if (_fillPaint != null) {
      canvas.drawCircle(Offset.zero, radius, _fillPaint!);
    }
    if (paintToUse.strokeWidth > 0) {
      canvas.drawCircle(Offset.zero, radius, paintToUse);
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // // Use ACTUAL radius for hit testing
    // final double radius = _internalCircle.radius;
    // final double strokeWidth = _internalCircle.strokeWidth;
    //
    // if (radius <= 0 || strokeWidth <= 0) return false;
    //
    // final double distance = point.length;
    // final double hitThreshold = (strokeWidth / 2) + _tapTolerance;
    // final bool isOnEdge = (distance - radius).abs() <= hitThreshold;
    //
    // // zlog(data: "Circle ${circleModel.id}: containsLocalPoint($point): isOnEdge=$isOnEdge (Dist: $distance, Radius: $radius, Thresh: $hitThreshold)");
    // return isOnEdge;
    return point.length <= _internalCircle.radius + _tapTolerance;
  }

  // --- Tap Handling ---
  @override
  void onTapDown(TapDownEvent event) {
    zlog(data: "Circle ${circleModel.id}: onTapDown at ${event.localPosition}");
    // Check resize dot first ONLY if active
    if (isActive &&
        _resizeDot != null &&
        _resizeDot!.containsPoint(event.localPosition)) {
      zlog(data: "Circle ${circleModel.id}: Tap handled by resize dot.");
      event.handled = true; // Let dot handle its events, prevent circle toggle
      return;
    }

    // If not handled by dot, check circle edge
    if (containsLocalPoint(event.localPosition)) {
      _toggleActive();
      event.handled = true;
    } else {
      event.handled = false;
    }
    zlog(data: "Circle ${circleModel.id}: onTapDown handled: ${event.handled}");
  }

  void _toggleActive() {
    zlog(data: "Circle ${circleModel.id}: _toggleActive called.");
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: circleModel);
  }

  // --- Drag Handling ---
  // @override
  // void onDragStart(DragStartEvent event) {
  //   zlog(
  //     data: "Circle ${circleModel.id}: onDragStart at ${event.localPosition}",
  //   );
  //
  //   // Check if drag started on the resize dot first (only if active)
  //   if (isActive &&
  //       _resizeDot != null &&
  //       _resizeDot!.containsPoint(event.localPosition)) {
  //     zlog(data: "Circle ${circleModel.id}: Drag started on resize dot.");
  //     // Let the dot handle the drag via its own callbacks
  //     event.continuePropagation = true;
  //     super.onDragStart(event); // Pass event down to children (the dot)
  //     return; // Prevent component drag start
  //   }
  //
  //   // If not on resize dot, check if drag starts on the circle edge (for moving)
  //   if (isActive && containsLocalPoint(event.localPosition)) {
  //     _isDragging = true; // Start component drag
  //     event.continuePropagation = false; // Consume event for component move
  //     zlog(
  //       data:
  //           "Circle ${circleModel.id}: Component Drag Started (_isDragging = true)",
  //     );
  //   } else {
  //     _isDragging = false;
  //     super.onDragStart(event); // Allow propagation if miss
  //     event.continuePropagation = true;
  //   }
  // }

  @override
  void onDragStart(DragStartEvent event) {
    zlog(
      data: "Circle ${circleModel.id}: onDragStart at ${event.localPosition}",
    );

    // Check if drag started on the resize dot first (only if active)
    if (isActive &&
        _resizeDot != null &&
        _resizeDot!.containsPoint(event.localPosition)) {
      zlog(data: "Circle ${circleModel.id}: Drag started on resize dot.");
      // Let the dot handle the drag
      event.continuePropagation = true;
      super.onDragStart(event);
      return;
    }

    // Check for "drag from inside"
    if (isActive && containsLocalPoint(event.localPosition)) {
      // --- NEW LOGIC ---
      // Check if an item (Player/Equipment) is on top of us
      if (_isItemOnTop(event.localPosition)) {
        // An item is on top. Do NOT drag this shape.
        // Let the event fall through to the item.
        zlog(data: "Circle ${circleModel.id}: Drag ignored, item on top.");
        return;
      }
      // --- END NEW LOGIC ---

      // No item on top, we can drag this shape.
      _isDragging = true;
      event.continuePropagation = false; // Consume the event
      zlog(
        data:
            "Circle ${circleModel.id}: Component Drag Started (_isDragging = true)",
      );
    } else {
      // Drag started outside the circle
      _isDragging = false;
      super.onDragStart(event);
      event.continuePropagation = true;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Dragging the whole circle
    if (_isDragging) {
      position.add(event.localDelta);
      // Update position continuously BUT maybe only save final position on end?
      // Let's move the save call to onDragEnd for performance.
      // _updateModelPosition(); // REMOVED FROM HERE
      event.continuePropagation = false;
    } else {
      // Allow propagation so the resize dot receives its updates
      super.onDragUpdate(event);
      event.continuePropagation = true;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    zlog(
      data:
          "Circle ${circleModel.id}: onDragEnd. Was dragging component: $_isDragging",
    );
    // Dragging the whole circle ended
    if (_isDragging) {
      _isDragging = false;
      _updateModelPosition(); // Call final position update ONLY HERE
      event.continuePropagation = false;
      zlog(
        data:
            "Circle ${circleModel.id}: Component Drag Ended. Final position saved.",
      );
    } else {
      // Allow propagation (e.g., for dot's drag end, handled by dot's onDotDragEnd callback)
      super.onDragEnd(event);
      event.continuePropagation = true;
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    zlog(
      data:
          "Circle ${circleModel.id}: onDragCancel. Was dragging component: $_isDragging",
    );
    // Dragging the whole circle cancelled
    if (_isDragging) {
      _isDragging = false;
      event.continuePropagation = false;
    } else {
      // Allow propagation if not dragging component
      super.onDragCancel(event);
      event.continuePropagation = true;
    }
  }

  /// Updates ONLY the provider with the current POSITION (center - relative).
  /// Includes current internal radius (converted to relative).
  void _updateModelPosition() {
    zlog(
      data:
          "Circle ${circleModel.id}: _updateModelPosition (Center Update). Actual Pos: $position",
    );
    final relativeCenter = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
    final relativeRadius = SizeHelper.getBoardRelativeDimension(
      gameScreenSize: game.gameField.size,
      actualSize: _internalCircle.radius,
    );
    final updatedModel = circleModel.copyWith(
      offset: relativeCenter.clone(),
      radius: relativeRadius,
      color: _internalCircle.strokeColor,
      fillColor: _internalCircle.fillColor,
      strokeWidth: _internalCircle.strokeWidth,
      opacity: _internalCircle.opacity,
    );
    zlog(
      data:
          "Circle ${circleModel.id}: Notifying provider (Position Update): ${updatedModel.toJson()}",
    );
    ref.read(boardProvider.notifier).updateShape(shape: updatedModel);

    // Trigger immediate save after circle shape update
    try {
      final tacticBoard = game as dynamic;
      if (tacticBoard.triggerImmediateSave != null) {
        tacticBoard.triggerImmediateSave(
            reason: "Circle shape update: ${circleModel.id}");
      }
    } catch (e) {
      // Fallback if method not available
    }
  }

  /// Updates the provider with the final POSITION and RADIUS.
  /// Called only on the drag end event of the resize dot.
  void _updateModelPositionAndRadius() {
    zlog(
      data:
          "Circle ${circleModel.id}: _updateModelPositionAndRadius (Final Save). Actual Pos: $position, Actual Radius: ${_internalCircle.radius}",
    );
    // Convert current actual position (center) to relative
    final relativeCenter = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition:
          position, // Position should be correct (not moved by dot drag)
    );
    // Convert internal ACTUAL radius back to RELATIVE
    final relativeRadius = SizeHelper.getBoardRelativeDimension(
      gameScreenSize: game.gameField.size,
      actualSize: _internalCircle.radius, // Use final internal actual radius
    );
    // Use copyWith on the original model ref to preserve ID etc.
    final updatedModelForProvider = circleModel.copyWith(
      offset: relativeCenter.clone(), // Final relative center
      radius: relativeRadius, // Final relative radius
      // Include other current properties
      color: _internalCircle.strokeColor,
      fillColor: _internalCircle.fillColor,
      strokeWidth: _internalCircle.strokeWidth,
      opacity: _internalCircle.opacity,
    );
    zlog(
      data:
          "Circle ${circleModel.id}: Notifying provider (Final Radius/Pos Save): ${updatedModelForProvider.toJson()}",
    );
    ref
        .read(boardProvider.notifier)
        .updateShape(shape: updatedModelForProvider);
  }

  // --- State Update from Provider ---
  void _updateIsActive(FieldItemModel? selectedItem) {
    zlog(
      data:
          "Circle ${circleModel.id}: _updateIsActive check. Selected ID: ${selectedItem?.id}",
    );
    final newActiveState =
        selectedItem is CircleShapeModel && selectedItem.id == circleModel.id;

    if (isActive != newActiveState) {
      isActive = newActiveState;
      zlog(data: "Circle ${circleModel.id}: isActive CHANGED to: $isActive");
      _updatePaints();

      // Add/Remove Resize Dot based on active state
      if (isActive) {
        if (_resizeDot != null && !children.contains(_resizeDot!)) {
          // Set position based on current ACTUAL radius and offset
          _resizeDot!.position = Vector2(
            0,
            -_internalCircle.radius - _dotOffsetAbove,
          );
          add(_resizeDot!);
          zlog(
            data:
                "Circle ${circleModel.id}: Added resize dot at ${_resizeDot!.position}",
          );
        } else if (_resizeDot == null) {
          zlog(
            data:
                "Circle ${circleModel.id}: Resize dot is null during activation!",
          );
          _createResizeDot();
          if (_resizeDot != null) {
            _resizeDot!.position = Vector2(
              0,
              -_internalCircle.radius - _dotOffsetAbove,
            );
            add(_resizeDot!);
          }
        }
      } else {
        if (_resizeDot != null && children.contains(_resizeDot!)) {
          remove(_resizeDot!);
          zlog(data: "Circle ${circleModel.id}: Removed resize dot");
        }
      }
      // Optional: Sync internal state if model could change externally
      // if(isActive && selectedItem != null) { ... sync logic ... }
    }
  }

  void updateRadiusAndSave(double newRadius) {
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
          "Circle ${circleModel.id}: Internal radius updated to: ${_internalCircle.radius}. Component size set to: $size ${newRadius}",
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
  }

  bool _isItemOnTop(Vector2 tapPosition) {
    // Find all Player and Equipment components
    final items = game.children
        .where((c) => c is PlayerComponent || c is EquipmentComponent);

    // Check if any of them contain the tap point
    for (final item in items) {
      if (item is PositionComponent) {
        // Convert the tap position (from game space) to the item's local space
        final itemLocalTap = item.toLocal(tapPosition);
        if (item.containsLocalPoint(itemLocalTap)) {
          // Found an item on top!
          return true;
        }
      }
    }
    // No items found at this spot
    return false;
  }
}
