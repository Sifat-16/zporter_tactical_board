import 'dart:async';
import 'dart:math' as math; // For math.pi, math.max, math.abs

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart'; // For Paint, Color, Offset
// Ensure this extension is available or replace firstWhereOrNull
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // If needed
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// Import your models
import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart';
// Import game and providers
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

// --- DraggableDot Class ---
// Using SquareRadiusDraggableDot name from user's code. Ensure this is accessible.
class SquareRadiusDraggableDot extends CircleComponent
    with DragCallbacks, TapCallbacks {
  final Function(Vector2, bool) onPositionChanged;
  final Function onDotDragEnd;
  final Vector2 initialPosition;
  final bool canModifyLine;
  final int dotIndex;

  SquareRadiusDraggableDot({
    required this.onPositionChanged,
    required this.initialPosition,
    required this.onDotDragEnd,
    required this.dotIndex,
    this.canModifyLine = true,
    super.radius = 8.0,
    Color color = Colors.blue,
  }) : super(
          position: initialPosition,
          anchor: Anchor.bottomLeft,
          paint: Paint()..color = color,
          priority: 2, // Render above the square
        );

  Vector2? _dragStartLocalPosition;
  final double extraTapRadius = 15.0; // Increased tap area tolerance

  @override
  void onTapDown(TapDownEvent event) {
    zlog(data: "Tapped down on the dots");
    super.onTapDown(event);
    event.handled = true; // Mark handled if dot handles tap
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragStartLocalPosition = event.localPosition;
    event.continuePropagation = false; // Dot handles drag start
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragStartLocalPosition != null) {
      // Pass potential new position based on delta
      // The position passed is relative to the dot's parent (the Square component)
      zlog(data: "New position updated before ${event.localDelta.x}");
      onPositionChanged(
        position + event.localDelta,
        event.localDelta.x < 0 ? true : false,
      );
    }
    event.continuePropagation = false; // Dot handles drag update
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _dragStartLocalPosition = null;
    onDotDragEnd();
    super.onDragEnd(event);
    event.continuePropagation = false; // Dot handles drag end
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _dragStartLocalPosition = null;
    super.onDragCancel(event);
    event.continuePropagation = true; // Allow cancel to propagate if needed
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Use squared distance for efficiency
    return point.length2 <= math.pow(radius + extraTapRadius, 2);
  }
}

// Constant for converting degrees to radians
const degrees2Radians = math.pi / 180.0;

// --- MODIFIED: SquareShapeDrawerComponent extends RectangleComponent ---
class SquareShapeDrawerComponent
    extends RectangleComponent // Changed base class
    with
        TapCallbacks,
        DragCallbacks,
        RiverpodComponentMixin,
        HasGameReference<TacticBoardGame> {
  SquareShapeModel squareModel;
  late SquareShapeModel _internalSquare;
  bool isActive = false;
  bool _isDragging = false; // For dragging the whole square
  final double _tapTolerance = 5.0;
  double _actualSide = 0.0; // Still useful for min/max checks maybe
  final double _minSide = 8.0;
  late Paint _strokePaint;
  Paint?
      _fillPaint; // Keep for data model consistency, but won't be used in render
  late Paint _activeStrokePaint;

  final List<SquareRadiusDraggableDot> _resizeDots = [];

  SquareShapeDrawerComponent({required this.squareModel})
      : super(priority: 1, anchor: Anchor.center);

  @override
  FutureOr<void> onLoad() {
    // ... (onLoad logic remains the same) ...
    zlog(data: "Square ${squareModel.id}: onLoad Start...");
    addToGameWidgetBuild(() {
      ref.listen(boardProvider, (previous, current) {
        _updateIsActive(current.selectedItemOnTheBoard);
      });
    });
    _internalSquare = squareModel.clone();
    // Set priority from model's zIndex for persistence across reloads
    if (squareModel.zIndex != null) {
      priority = squareModel.zIndex!;
    }
    position = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: _internalSquare.center,
    );
    _actualSide = SizeHelper.getBoardActualDimension(
      gameScreenSize: game.gameField.size,
      relativeSize: _internalSquare.side,
    );
    size = Vector2(_actualSide, _actualSide); // Set component size
    angle =
        degrees2Radians * (_internalSquare.angle ?? 0.0); // Set initial angle
    _updateComponentPaint();

    return super.onLoad();
  }

  // --- MODIFIED: Creates the four DraggableDot instances using component's size ---
  void _createResizeDots() {
    _removeAllResizeDots();
    if (size.x <= 0) return; // Use component's size property

    final dotRadius = 8.0;

    zlog(data: "Check the create dots issue ${size}");

    // Define the four corners relative to the center anchor (0,0)
    final cornerPositions = [
      Vector2(-_minSide, _minSide), // Top-left
      Vector2(size.x - _minSide, _minSide), // Top-right
      Vector2(-_minSide, size.y + _minSide), // Bottom-left
      Vector2(size.x - _minSide, size.y + _minSide), // Bottom-right
    ];

    for (int i = 0; i < cornerPositions.length; i++) {
      // Rotate the calculated corner position by the component's current angle
      final initialRotatedPosition = cornerPositions[i].clone()..rotate(angle);

      final cornerDot = SquareRadiusDraggableDot(
        dotIndex: 100 + i,
        initialPosition: initialRotatedPosition, // Set rotated position
        radius: dotRadius,
        color: Colors.blue,
        onPositionChanged: (newPos, isIncreasingFirstDot) {
          final cornerPositions = [
            Vector2(-_minSide, _minSide),
            Vector2(size.x - _minSide, _minSide),
            Vector2(-_minSide, size.y + _minSide),
            Vector2(size.x - _minSide, size.y + _minSide),
          ];
          // Need to adjust this based on which dot 'i' is being dragged.
          // Let's assume dotIndex maps directly for now (needs verification)
          final int draggedListIndex = i; // Use the loop index 'i'
          Vector2 previousDotPos = cornerPositions[draggedListIndex].clone()
            ..rotate(angle);

          // 2. Calculate the distance change: did the dot move further or closer to the center?
          double previousDist =
              previousDotPos.length; // Distance before this update
          double currentDist =
              newPos.length; // Current distance after this update

          double distanceChange = currentDist - previousDist;

          // 3. Calculate the new actual side length.
          //    The change in side length should be proportional to the change in distance.
          //    Since distance relates to halfSide * sqrt(2), the change in side should be roughly distanceChange * 2 / sqrt(2) = distanceChange * sqrt(2)
          //    Let's try a simpler direct scaling for now: add double the distance change to the side.
          double newActualSide = _actualSide +
              (distanceChange *
                  2.0); // Grow/shrink side by twice the distance change

          // 4. Apply minimum size constraint
          newActualSide = math.max(newActualSide, _minSide);

          // 5. Update the component's internal size.
          //    This calls _updateResizeDotPositions which uses YOUR corner logic to snap dots.

          if (i == 0) {
            if (isIncreasingFirstDot) {
              newActualSide = _actualSide +
                  (distanceChange *
                      2.0); // Grow/shrink side by twice the distance change
            } else {
              newActualSide = _actualSide -
                  (distanceChange *
                      2.0); // Grow/shrink side by twice the distance change
            }

            // 4. Apply minimum size constraint
            newActualSide = math.max(newActualSide, _minSide);
            updateSideInternally(newActualSide);
          } else {
            updateSideInternally(newActualSide);
          }
        },
        onDotDragEnd: () {
          _saveFinalStateToProvider();
        },
      );
      _resizeDots.add(cornerDot);
    }
    zlog(
      data: "Square ${squareModel.id}: 4 resize dots created using size $size.",
    );
  }
  // --- END MODIFICATION ---

  // --- MODIFIED: Repositions all four resize dots using component's size ---
  void _updateResizeDotPositions() {
    if (!isActive || _resizeDots.length != 4) return;
    // Use component's current size directly

    // Define the four corners relative to the center anchor (0,0)
    final cornerPositions = [
      Vector2(-_minSide, _minSide), // Top-left
      Vector2(size.x - _minSide, _minSide), // Top-right
      Vector2(-_minSide, size.y + _minSide), // Bottom-left
      Vector2(size.x - _minSide, size.y + _minSide), // Bottom-right
    ];

    for (int i = 0; i < 4; i++) {
      if (children.contains(_resizeDots[i])) {
        // Rotate the calculated corner position by the component's current angle
        _resizeDots[i].position = cornerPositions[i].clone()..rotate(angle);
      }
    }
  }
  // --- END MODIFICATION ---

  /// Updates internal side length state and component size. Does NOT notify provider.
  void updateSideInternally(double newActualSide) {
    if (newActualSide < _minSide) newActualSide = _minSide;
    // Compare against component's current size.x (since it's a square)
    if ((size.x - newActualSide).abs() < 0.01) return;

    _actualSide = newActualSide; // Still track actual side if needed elsewhere
    size = Vector2(
      newActualSide,
      newActualSide,
    ); // Update inherited size property

    zlog(data: "New position updated ${newActualSide} - ${size}");
    _updateResizeDotPositions(); // Update dot positions based on new size AND current angle
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _updateComponentPaint();
    // TODO: implement render
    final side = _actualSide;
    final rect = Rect.fromCenter(
      center: Vector2(0 + _actualSide / 2, 0 + _actualSide / 2).toOffset(),
      width: side,
      height: side,
    );
    final strokePaintToUse = isActive ? _activeStrokePaint : _strokePaint;
    canvas.drawRect(rect, strokePaintToUse);
  }

  /// Updates the component's 'paint' property
  void _updateComponentPaint() {
    final baseStrokeColor = squareModel.color ?? ColorManager.white;
    final baseFillColor = (squareModel.color ?? ColorManager.white).withValues(
      alpha: 0.1,
    ); // Still read fill color from model
    final baseStrokeWidth = squareModel.strokeWidth;
    final baseOpacity = squareModel.opacity ?? 1.0;

    // Configure Stroke Paint
    _strokePaint = Paint()
      ..color = baseStrokeColor.withOpacity(baseOpacity)
      ..strokeWidth = baseStrokeWidth
      ..style = PaintingStyle.stroke;

    // Configure Active Stroke Paint
    _activeStrokePaint = Paint()
      ..color = squareModel.color ?? ColorManager.white
      ..strokeWidth = baseStrokeWidth + 2.0
      ..style = PaintingStyle.stroke;

    // Configure Fill Paint (but it won't be used in render)
    _fillPaint = Paint()
      ..color = baseFillColor
      ..style = PaintingStyle.fill;

    paint = _fillPaint!;
  }

  // REMOVED: render(Canvas canvas) method override

  /// Contains local point check
  // @override
  // bool containsLocalPoint(Vector2 point) {
  //   if ((point.x >= 0 && point.x <= 5) ||
  //       (point.y >= 0 && point.y <= 5) ||
  //       ((point.x - size.x).abs() >= 0 && (point.x - size.x).abs() <= 5) ||
  //       ((point.y - size.y).abs() >= 0 && (point.y - size.y).abs() <= 5)) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  //   zlog(
  //     data: "Check the point is on the side of the square ${point} - ${size}",
  //   );
  //
  //   final bool contains = super.containsLocalPoint(point);
  //
  //   return contains;
  // }

  // --- ADD THIS ---
  @override
  bool containsLocalPoint(Vector2 point) {
    // This component's anchor is Anchor.center, so (0,0) is the center.
    // 'point' is the tap location relative to the center.

    // We check if the tap is inside the square's bounds,
    // including the _tapTolerance (which is 5.0 in your file).

    final halfWidth = (size.x) + _tapTolerance;
    final halfHeight = (size.y) + _tapTolerance;

    zlog(
        data:
            "data ${point.x} - ${point.y.abs()} - ${halfWidth} - ${halfHeight}",
        show: true);

    return point.x >= 0 &&
        point.x <= halfWidth &&
        point.y >= 0 &&
        point.y <= halfHeight;
  }

// --- END ADD ---
  // --- Tap Handling ---
  @override
  void onTapDown(TapDownEvent event) {
    // ... (Tap logic remains the same) ...
    zlog(data: "Square ${squareModel.id}: onTapDown at ${event.localPosition}");

    bool handledByDot = false;
    if (isActive && _resizeDots.isNotEmpty) {
      handledByDot = _resizeDots.any(
        (dot) => dot.containsLocalPoint(event.localPosition),
      );
    }
    if (handledByDot) {
      zlog(data: "Square ${squareModel.id}: Tap handled by a resize dot.");
      event.handled = true;
      return;
    }
    if (containsLocalPoint(event.localPosition)) {
      _toggleActive();
      event.handled = true;
    } else {
      event.handled = false;
    }
    zlog(data: "Square ${squareModel.id}: onTapDown handled: ${event.handled}");
  }

  void _toggleActive() {
    zlog(data: "Square ${squareModel.id}: _toggleActive called.");
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: squareModel);
  }

  // --- Drag Handling ---
  // @override
  // void onDragStart(DragStartEvent event) {
  //   // ... (Drag start logic remains the same) ...
  //   zlog(
  //     data: "Square ${squareModel.id}: onDragStart at ${event.localPosition}",
  //   );
  //   bool handledByDot = false;
  //   if (isActive && _resizeDots.isNotEmpty) {
  //     final hitResizeDot = _resizeDots.firstWhereOrNull(
  //       (dot) => dot.containsLocalPoint(event.localPosition),
  //     );
  //     if (hitResizeDot != null) {
  //       handledByDot = true;
  //       zlog(data: "Square ${squareModel.id}: Drag started on RESIZE dot.");
  //     }
  //   }
  //   if (handledByDot) {
  //     event.continuePropagation = true;
  //     super.onDragStart(event);
  //     return;
  //   }
  //   if (isActive && containsLocalPoint(event.localPosition)) {
  //     // Uses super.containsLocalPoint now
  //     _isDragging = true;
  //     event.continuePropagation = false;
  //     zlog(
  //       data:
  //           "Square ${squareModel.id}: Component Drag Started (_isDragging = true)",
  //     );
  //   } else {
  //     _isDragging = false;
  //     super.onDragStart(event);
  //     event.continuePropagation = true;
  //   }
  // }

  @override
  void onDragStart(DragStartEvent event) {
    zlog(
      data: "Square ${squareModel.id}: onDragStart at ${event.localPosition}",
    );

    // Check if drag started on a resize dot
    bool handledByDot = false;
    if (isActive && _resizeDots.isNotEmpty) {
      final hitResizeDot = _resizeDots.firstWhereOrNull(
        (dot) => dot.containsLocalPoint(event.localPosition),
      );
      if (hitResizeDot != null) {
        handledByDot = true;
        zlog(data: "Square ${squareModel.id}: Drag started on RESIZE dot.");
      }
    }
    if (handledByDot) {
      event.continuePropagation = true;
      super.onDragStart(event);
      return;
    }

    // Check for "drag from inside" (using the corrected containsLocalPoint)
    if (isActive && containsLocalPoint(event.localPosition)) {
      // --- NEW LOGIC ---
      // Check if an item (Player/Equipment) is on top of us
      if (_isItemOnTop(event.localPosition)) {
        // An item is on top. Do NOT drag this shape.
        // Let the event fall through to the item.
        zlog(data: "Square ${squareModel.id}: Drag ignored, item on top.");
        return;
      }
      // --- END NEW LOGIC ---

      // No item on top, we can drag this shape.
      _isDragging = true;
      event.continuePropagation = false;
      zlog(
        data:
            "Square ${squareModel.id}: Component Drag Started (_isDragging = true)",
      );
    } else {
      _isDragging = false;
      super.onDragStart(event);
      event.continuePropagation = true;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // ... (Drag update logic remains the same) ...
    if (_isDragging) {
      position.add(event.localDelta);
      event.continuePropagation = false;
    } else {
      super.onDragUpdate(event);
      event.continuePropagation = true;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    // ... (Drag end logic remains the same) ...
    zlog(
      data:
          "Square ${squareModel.id}: onDragEnd. Was dragging component: $_isDragging",
    );
    if (_isDragging) {
      _isDragging = false;
      _saveFinalStateToProvider();
      event.continuePropagation = false;
      zlog(
        data:
            "Square ${squareModel.id}: Component Drag Ended. Final state saved.",
      );
    } else {
      super.onDragEnd(event);
      event.continuePropagation = true;
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    // ... (Drag cancel logic remains the same) ...
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

  /// Updates the provider with the final position, side, and angle.
  void _saveFinalStateToProvider() {
    // --- MODIFIED: Use component's size directly for actual side ---
    final currentActualSide =
        size.x; // Since it's a square, x and y are the same
    zlog(
      data:
          "Square ${squareModel.id}: _saveFinalStateToProvider. Pos: $position, Side: $currentActualSide, Angle: $angle (rad)",
    );

    final relativeCenter = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
    final relativeSide = SizeHelper.getBoardRelativeDimension(
      gameScreenSize: game.gameField.size,
      actualSize: currentActualSide,
    ); // Use size.x
    final angleInDegrees = angle * (180 / math.pi);

    final updatedModel = squareModel.copyWith(
      offset: relativeCenter.clone(),
      side: relativeSide,
      angle: angleInDegrees,
      color: _internalSquare.strokeColor,
      fillColor: _internalSquare.fillColor,
      strokeWidth: _internalSquare.strokeWidth,
      opacity: _internalSquare.opacity,
    );
    zlog(
      data:
          "Square ${squareModel.id}: Notifying provider (Final Save): ${updatedModel.toJson()}",
    );
    ref.read(boardProvider.notifier).updateShape(shape: updatedModel);

    // Trigger immediate save after square shape update
    try {
      final tacticBoard = game as dynamic;
      if (tacticBoard.triggerImmediateSave != null) {
        tacticBoard.triggerImmediateSave(
            reason: "Square shape update: ${squareModel.id}");
      }
    } catch (e) {
      // Fallback if method not available
    }
    // --- END MODIFICATION ---
  }

  /// State Update from Provider
  void _updateIsActive(FieldItemModel? selectedItem) {
    // ... (Update active logic remains the same) ...
    zlog(
      data:
          "Square ${squareModel.id}: _updateIsActive check. Selected ID: ${selectedItem?.id}",
    );
    final newActiveState =
        selectedItem is SquareShapeModel && selectedItem.id == squareModel.id;
    if (isActive != newActiveState) {
      isActive = newActiveState;
      zlog(data: "Square ${squareModel.id}: isActive CHANGED to: $isActive");
      _updateComponentPaint(); // Use updated paint method
      if (isActive) {
        _removeAllResizeDots();
        _createResizeDots();
        addAll(_resizeDots);
      } else {
        _removeAllResizeDots();
      }
    }
  }

  /// Helper to remove list of dots
  void _removeAllResizeDots() {
    // ... (Remove logic remains the same) ...
    try {
      if (_resizeDots.isNotEmpty) {
        removeAll(_resizeDots);
        _resizeDots.clear();
        zlog(data: "Square ${squareModel.id}: Removed resize dots");
      }
    } catch (e) {
      zlog(data: "Error removing resize dots: $e");
    }
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
