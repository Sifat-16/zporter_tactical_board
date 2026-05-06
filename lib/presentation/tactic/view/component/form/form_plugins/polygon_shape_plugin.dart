import 'dart:async';
import 'dart:math' as math; // For math.pi

import 'package:flame/components.dart';
import 'package:flame/events.dart'; // DragCallbacks, TapCallbacks
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart'; // For Color, WidgetsBinding
import 'package:zporter_tactical_board/app/helper/logger.dart'; // For zlog (optional)
import 'package:zporter_tactical_board/app/helper/size_helper.dart'; // For coordinate conversion
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// Import your models
import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
// Import game and providers
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

class PolygonVertexDotComponent extends CircleComponent
    with DragCallbacks, TapCallbacks, HasGameReference<TacticBoardGame> {
  final int index;
  void Function(int index, Vector2 newRelativePosition) onDragUpdateCallback;
  VoidCallback onDragStartCallback;
  VoidCallback onDragEndCallback;
  late Vector2 _gameSize;

  PolygonVertexDotComponent({
    required this.index,
    required this.onDragUpdateCallback,
    required this.onDragStartCallback,
    required this.onDragEndCallback,
    required Vector2 position,
    required double radius,
    required Paint paint,
  }) : super(
          position: position,
          radius: radius,
          paint: paint,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      if (game.isMounted) {
        _gameSize = game.gameField.size;
      } else {
        await WidgetsBinding.instance.endOfFrame;
        if (game.isMounted) {
          _gameSize = game.gameField.size;
        } else {
          zlog(
            data:
                "Error: Game reference still not ready after waiting in PolygonVertexDotComponent onLoad.",
          );
          _gameSize = Vector2.zero();
        }
      }
    } catch (e) {}
  }

  @override
  void onTapDown(TapDownEvent event) {
    // TODO: implement onTapDown
    super.onTapDown(event);
    zlog(data: "Tapped on the polygon shape vertex");
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    onDragStartCallback();
    event.continuePropagation = false;
    zlog(data: "Dot $index DragStart");
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (parent == null || _gameSize == Vector2.zero()) return;
    position += event.localDelta;
    final newRelativePosition = SizeHelper.getBoardRelativeVector(
      gameScreenSize: _gameSize,
      actualPosition: position,
    );
    onDragUpdateCallback(index, newRelativePosition);
    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    onDragEndCallback();
    zlog(data: "Dot $index DragEnd final Abs Pos: $position");
    event.continuePropagation = false;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    onDragEndCallback();
    zlog(data: "Dot $index DragCancel at Abs Pos: $position");
    event.continuePropagation = false;
  }
}

const degrees2Radians = math.pi / 180.0;

class PolygonShapeDrawerComponent extends PositionComponent
    with
        HasGameReference<TacticBoardGame>,
        RiverpodComponentMixin,
        TapCallbacks,
        DragCallbacks {
  PolygonShapeModel
      polygonModel; // This model can be pre-populated with the first vertex
  late PolygonShapeModel _internalModel;
  List<Vector2> actualVertices = [];
  late Paint _strokePaint;
  late Paint _fillPaint;
  final double _vertexDotRadius = 8.0;
  final Paint _vertexDotPaint = Paint()
    ..color = Colors.blueAccent
    ..style = PaintingStyle.fill;
  final List<PolygonVertexDotComponent> _vertexDots = [];

  bool _isActive = false; // Initialized in onLoad
  bool get isActive => _isActive;

  final Path _polygonPath = Path();

  bool _isDraggingVertex = false;
  bool _isDraggingPolygon = false;

  PolygonShapeDrawerComponent({
    required this.polygonModel,
    // Default to false
  }) : super(priority: 1, anchor: Anchor.topLeft, position: Vector2.zero());

  @override
  FutureOr<void> onLoad() async {
    addToGameWidgetBuild(() {
      ref.listen(boardProvider, (previous, current) {
        _updateIsActive(current.selectedItemOnTheBoard);
      });
    });

    _internalModel =
        polygonModel.clone(); // Clone the potentially pre-populated model

    // Set priority from model's zIndex for persistence across reloads
    if (polygonModel.zIndex != null) {
      priority = polygonModel.zIndex!;
    }

    zlog(
      data:
          "Polygon ${polygonModel.id}: onLoad. Initial state: ${_isActive ? 'active (creating)' : 'inactive'}. Vertices in model: ${polygonModel.relativeVertices.length}",
    );

    // Update drawing properties. If active and model has vertices, dots will be created.
    if (game.isMounted) {
      _updateDrawingProperties(polygon: _internalModel);
    } else {
      await WidgetsBinding.instance.endOfFrame; // Wait for game to be ready
      if (game.isMounted) {
        _updateDrawingProperties(polygon: _internalModel);
      } else {
        zlog(
          data:
              "Error: Game reference still not ready after waiting in PolygonShapeDrawerComponent onLoad.",
        );
      }
    }
    await super.onLoad();
  }

  /// Updates internal model, calculates actual vertices, configures paints, and updates the hit path.
  void _updateDrawingProperties({required PolygonShapeModel polygon}) {
    _internalModel = polygon.clone();

    if (!game.isMounted) {
      zlog(
        data:
            "Warning: Game reference not ready in _updateDrawingProperties. Skipping update.",
      );
      actualVertices = [];
      return;
    }

    actualVertices = _internalModel.relativeVertices
        .map(
          (relativePos) => SizeHelper.getBoardActualVector(
            gameScreenSize: game.gameField.size,
            actualPosition: relativePos,
          ),
        )
        .toList();

    _updatePaint();
    _polygonPath.reset();
    if (actualVertices.length >= 2) {
      _polygonPath.moveTo(actualVertices[0].x, actualVertices[0].y);
      for (int i = 1; i < actualVertices.length; i++) {
        _polygonPath.lineTo(actualVertices[i].x, actualVertices[i].y);
      }
      if (actualVertices.length >= 3) {
        _polygonPath.close();
      }
    }

    // If active, synchronize the visual dots. This is where dots are created/updated.
    if (_isActive) {
      _synchronizeVertexDots();
    }
  }

  _updatePaint() {
    final baseStrokeColor = polygonModel.strokeColor ?? Colors.white;
    final baseStrokeWidth = polygonModel.strokeWidth;
    final baseOpacity = polygonModel.opacity ?? 1.0;
    _strokePaint = Paint()
      ..color = baseStrokeColor.withValues(alpha: baseOpacity)
      ..strokeWidth = baseStrokeWidth
      ..style = PaintingStyle.stroke;

    final baseFillColor = polygonModel.color ?? ColorManager.white;
    _fillPaint = Paint()
      ..color = baseFillColor.withValues(alpha: baseOpacity * 0.1)
      ..style = PaintingStyle.fill;
  }

  /// Adds/Updates vertex dot components ONLY if the polygon is active.
  void _synchronizeVertexDots() {
    if (!_isActive || !isMounted) {
      _removeAllDots();
      return;
    }

    while (_vertexDots.length > actualVertices.length) {
      final removedDot = _vertexDots.removeLast();
      if (removedDot.isMounted) {
        remove(removedDot);
      }
    }

    for (int i = 0; i < actualVertices.length; i++) {
      if (i >= actualVertices.length) {
        // Safety check
        zlog(
          data:
              "Warning: Index out of bounds in _synchronizeVertexDots loop (i=$i, length=${actualVertices.length})",
        );
        break;
      }
      final vertexPos = actualVertices[i];

      if (i < _vertexDots.length) {
        _vertexDots[i].position = vertexPos;
        _vertexDots[i].onDragStartCallback = _handleVertexDragStart;
        _vertexDots[i].onDragEndCallback = _handleVertexDragEnd;
        _vertexDots[i].onDragUpdateCallback = _handleVertexDragUpdate;
      } else {
        final newDot = PolygonVertexDotComponent(
          index: i,
          onDragUpdateCallback: _handleVertexDragUpdate,
          onDragStartCallback: _handleVertexDragStart,
          onDragEndCallback: _handleVertexDragEnd,
          position: vertexPos,
          radius: _vertexDotRadius,
          paint: _vertexDotPaint,
        );
        _vertexDots.add(newDot);
        add(newDot); // Add child dot to this component
      }
    }
  }

  /// Removes all vertex dot components from the tree and the list.
  void _removeAllDots() {
    if (_vertexDots.isNotEmpty) {
      final dotsToRemove = List<PolygonVertexDotComponent>.from(_vertexDots);
      _vertexDots.clear();
      removeAll(dotsToRemove);
    }
  }

  /// Sets the active state and updates dot visibility.
  void setActive(bool active) {
    if (_isActive == active || !isMounted) return;

    _isActive = active;
    zlog(
      data: "Polygon ${polygonModel.id}: Setting active state to: $_isActive",
    );

    if (_isActive) {
      _updateDrawingProperties(polygon: _internalModel);
    } else {
      _removeAllDots();
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    if (actualVertices.length < 3 || !isMounted) return false;
    return _polygonPath.contains(point.toOffset());
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (containsLocalPoint(event.localPosition)) {
      _toggleActive();
      event.handled = true;
    }
  }

  void _toggleActive() {
    // ... (Toggle logic remains the same) ...
    zlog(data: "Polygon ${polygonModel.id}: _toggleActive called.");
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: polygonModel);
  }

  // --- Drag Handlers for the Polygon itself ---
  // @override
  // void onDragStart(DragStartEvent event) {
  //   super.onDragStart(event);
  //   if (_isActive &&
  //       !_isDraggingVertex &&
  //       containsLocalPoint(event.localPosition)) {
  //     _isDraggingPolygon = true;
  //     event.handled = true;
  //     zlog(data: "Polygon ${polygonModel.id}: Started dragging polygon.");
  //   }
  // }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event); // Let children (dots) get the event first

    // Check if drag started on a vertex dot
    if (_isDraggingVertex) {
      // The dot's onDragStart already set this to true
      event.handled = true;
      return;
    }

    // Check for "drag from inside"
    if (isActive && containsLocalPoint(event.localPosition)) {
      // --- NEW LOGIC ---
      // Check if an item (Player/Equipment) is on top of us
      if (_isItemOnTop(event.localPosition)) {
        // An item is on top. Do NOT drag this shape.
        // Let the event fall through to the item.
        zlog(data: "Polygon ${polygonModel.id}: Drag ignored, item on top.");
        return;
      }
      // --- END NEW LOGIC ---

      // No item on top, we can drag this shape.
      _isDraggingPolygon = true;
      event.handled = true; // Polygon component consumes it
      zlog(data: "Polygon ${polygonModel.id}: Started dragging polygon.");
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isDraggingPolygon && !_isDraggingVertex && game.isMounted) {
      final gameSize = game.gameField.size;
      if (gameSize.x <= 0 || gameSize.y <= 0) return;

      final screenDelta = event.localDelta;
      final relativeDelta = screenDelta.clone()..divide(gameSize);

      for (int i = 0; i < polygonModel.relativeVertices.length; i++) {
        polygonModel.relativeVertices[i] += relativeDelta;
      }
      _updateDrawingProperties(polygon: polygonModel);
      _updateModel();
      event.handled = true;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_isDraggingPolygon) {
      _isDraggingPolygon = false;
      // Trigger immediate save after polygon drag
      try {
        final tacticBoard = game as dynamic;
        if (tacticBoard.triggerImmediateSave != null) {
          tacticBoard.triggerImmediateSave(
              reason: "Polygon drag end: ${polygonModel.id}");
        }
      } catch (e) {
        // Fallback if method not available
      }
      event.handled = true;
      zlog(data: "Polygon ${polygonModel.id}: Ended dragging polygon.");
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (_isDraggingPolygon) {
      _isDraggingPolygon = false;
      event.handled = true;
      zlog(data: "Polygon ${polygonModel.id}: Cancelled dragging polygon.");
    }
  }
  // --- End Drag Handlers ---

  @override
  void render(Canvas canvas) {
    _updatePaint();
    if (!isMounted || !game.isMounted || actualVertices.isEmpty) return;
    if (actualVertices.length >= 3 && _fillPaint.color != Colors.transparent) {
      canvas.drawPath(_polygonPath, _fillPaint);
    }
    if (actualVertices.length >= 2 && _strokePaint.strokeWidth > 0) {
      canvas.drawPath(_polygonPath, _strokePaint);
    }
  }

  /// Inserts a new vertex (typically for subsequent vertices after initial creation).
  /// Assumes the component is already part of the game.
  void insertVertex(Vector2 relativeTapPosition) async {
    while (!isMounted) {
      zlog(
        data:
            "Polygon ${polygonModel.id}: insertVertex called but component not mounted. Waiting...",
      );
      // Yield execution to allow other tasks (like mounting) to proceed.
      // A short delay is usually sufficient.
      await Future.delayed(const Duration(milliseconds: 16)); // approx 1 frame
    }

    // Add to the model used by this component instance
    _internalModel.relativeVertices.add(relativeTapPosition);
    // Also update the original model reference if it's intended to be shared/mutated
    if (polygonModel.relativeVertices.length <
        _internalModel.relativeVertices.length) {
      polygonModel.relativeVertices.add(relativeTapPosition);
    }

    // Ensure active and update visuals
    if (!_isActive) {
      _toggleActive();
    } else {
      // If already active, just update properties to show the new dot
      _updateDrawingProperties(polygon: _internalModel);
    }

    _updateModel(); // Notify provider

    zlog(
      data:
          "Polygon ${polygonModel.id}: Inserted vertex. New count: ${_internalModel.relativeVertices.length}. State Active: $_isActive",
    );
  }

  /// Notifies the board provider about model changes.
  void _updateModel() {
    if (isMounted && _internalModel.relativeVertices.isNotEmpty) {
      // Use _internalModel

      if (_internalModel.relativeVertices.length >=
          _internalModel.minVertices) {
        try {
          // Pass the _internalModel or a clone of it
          ref
              .read(boardProvider.notifier)
              .updateShape(shape: _internalModel.clone());
        } catch (e) {
          zlog(data: "Error accessing ref or provider in _updateModel: $e");
        }
        int? maxVertices = _internalModel.maxVertices;
        if (maxVertices != null) {
          if (_internalModel.relativeVertices.length >= maxVertices) {
            ref.read(lineProvider.notifier).dismissActiveFormItem();
          }
        }
      }
    } else if (!isMounted) {
      zlog(
        data:
            "Warning: Attempted to update model before component was mounted.",
      );
    }
  }

  /// Updates the component based on a new model provided externally.
  void updatePolygon(PolygonShapeModel newModel) {
    if (!isMounted) return;
    zlog(data: "Polygon ${polygonModel.id}: Updating polygon externally.");
    // Update internal model and refresh visuals
    // This will also call _synchronizeVertexDots if the component is active.
    _updateDrawingProperties(polygon: newModel);
  }

  // --- Callback handler for INDIVIDUAL vertex drag updates ---
  void _handleVertexDragUpdate(int index, Vector2 newRelativePosition) {
    if (!_isActive || _isDraggingPolygon || !isMounted) return;
    if (index >= 0 && index < _internalModel.relativeVertices.length) {
      // Use _internalModel
      _internalModel.relativeVertices[index] = newRelativePosition;
      // Also update the original model reference
      if (index < polygonModel.relativeVertices.length) {
        polygonModel.relativeVertices[index] = newRelativePosition;
      }
    } else {
      zlog(data: "Error: Invalid index $index received from dragged dot.");
      return;
    }
    _updateDrawingProperties(polygon: _internalModel); // Use _internalModel
    _updateModel();
  }

  // --- Callbacks to track vertex dragging state ---
  void _handleVertexDragStart() {
    if (!isMounted) return;
    _isDraggingVertex = true;
    zlog(data: "Polygon ${polygonModel.id}: Vertex drag started.");
  }

  void _handleVertexDragEnd() {
    if (!isMounted) return;
    _isDraggingVertex = false;
    // Trigger immediate save after polygon vertex drag
    try {
      final tacticBoard = game as dynamic;
      if (tacticBoard.triggerImmediateSave != null) {
        tacticBoard.triggerImmediateSave(
            reason: "Polygon vertex drag end: ${polygonModel.id}");
      }
    } catch (e) {
      // Fallback if method not available
    }
    zlog(data: "Polygon ${polygonModel.id}: Vertex drag ended.");
  }

  void _updateIsActive(FieldItemModel? selectedItem) {
    // ... (Update active logic remains the same) ...
    zlog(
      data:
          "Square ${polygonModel.id}: _updateIsActive check. Selected ID: ${selectedItem?.id}",
    );
    final newActiveState =
        selectedItem is PolygonShapeModel && selectedItem.id == polygonModel.id;
    if (isActive != newActiveState) {
      setActive(newActiveState);
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

  // --- END ADDED ---
}
