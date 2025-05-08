import 'dart:async';
import 'dart:math' as math; // For math.pi

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart'; // For Canvas, Paint, Color, Path, Offset
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // If needed
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// Import your models
import 'package:zporter_tactical_board/data/tactic/model/triangle_shape_model.dart'; // Import the specific model
// Import game and providers
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

// Constant for converting degrees to radians
const degrees2Radians = math.pi / 180.0;

// --- DraggableDot Class (Keep as provided by user) ---
class SquareRadiusDraggableDot extends CircleComponent
    with DragCallbacks, TapCallbacks {
  final Function(Vector2) onPositionChanged;
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
         anchor: Anchor.center, // Changed back to center for consistency
         paint: Paint()..color = color,
         priority: 2,
       );

  Vector2? _dragStartLocalPosition;
  final double extraTapRadius = 4.0;

  @override
  void onTapDown(TapDownEvent event) {
    zlog(data: "Tapped down on the dots");
    super.onTapDown(event);
    event.handled = true;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragStartLocalPosition = event.localPosition;
    event.continuePropagation = false;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragStartLocalPosition != null) {
      onPositionChanged(position + event.localDelta);
    }
    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _dragStartLocalPosition = null;
    onDotDragEnd();
    super.onDragEnd(event);
    event.continuePropagation = false;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _dragStartLocalPosition = null;
    super.onDragCancel(event);
    event.continuePropagation = true;
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.length2 <= math.pow(radius + extraTapRadius, 2);
  }
}
// --- End DraggableDot Class ---

class TriangleShapeDrawerComponent extends PositionComponent
    with
        TapCallbacks,
        DragCallbacks,
        RiverpodComponentMixin,
        HasGameReference<TacticBoardGame> {
  // --- MODIFIED: Use late for definitive model ---
  late TriangleShapeModel triangleModel;
  // --- END MODIFICATION ---

  bool isActive = false;
  bool _isDragging = false; // For dragging the completed triangle

  // Paints for rendering
  late Paint _strokePaint;
  Paint? _fillPaint;
  late Paint _activeStrokePaint;
  late Paint _vertexDotPaint;

  // --- MODIFIED: Store ACTUAL world coordinates during creation ---
  final List<Vector2> _creationVertices = []; // Stores actual tap points
  bool _isCreating; // Flag to indicate creation phase (set by constructor)
  // --- END MODIFICATION ---

  // Store actual vertex positions relative to the component's center anchor (for finalized state)
  Vector2? _actualVertexA;
  Vector2? _actualVertexB;
  Vector2? _actualVertexC;

  // Path used for rendering the final triangle
  Path _trianglePath = Path();

  final double _tapTolerance = 5.0;

  // --- MODIFIED: Constructor takes initial model AND indicates creation ---
  TriangleShapeDrawerComponent({
    required TriangleShapeModel initialModel,
    bool isCreating = false,
  }) : triangleModel = initialModel.clone(), // Store initial clone
       _isCreating = isCreating,
       super(
         priority: 1,
         // Set anchor/position based on phase
         anchor: isCreating ? Anchor.topLeft : Anchor.center,
         position:
             isCreating ? Vector2.zero() : null, // Set later if not creating
       );
  // --- END MODIFICATION ---

  @override
  FutureOr<void> onLoad() {
    zlog(
      data:
          "Triangle ${triangleModel.id}: onLoad Start. IsCreating: $_isCreating",
    );

    // Only listen to provider if NOT in creation mode initially
    // (The final component added by the provider will listen)
    if (!_isCreating) {
      addToGameWidgetBuild(() {
        ref.listen(boardProvider, (previous, current) {
          _updateIsActive(current.selectedItemOnTheBoard);
        });
      });
    }

    // Set initial state based on the provided model
    _updateFromModel(triangleModel, isInitialLoad: true);

    // Check initial active state only if not creating
    if (!_isCreating) {
      // final initialState = ref.read(boardProvider);
      // _updateIsActive(initialState.selectedItemOnTheBoard);
      // zlog(
      //   data:
      //       "Triangle ${triangleModel.id}: Initial active state checked: $isActive",
      // );
    } else {
      zlog(data: "Triangle ${triangleModel.id}: In creation mode.");
      // If created with vertex A already (from handler), add it
      if (_creationVertices.isEmpty && triangleModel.offset != null) {
        Vector2 actualVertexA = SizeHelper.getBoardActualVector(
          gameScreenSize: game.gameField.size,
          actualPosition:
              triangleModel.offset!, // Handler sets offset to first tap pos
        );
        addCreationVertex(actualVertexA);
      }
    }

    zlog(data: "Triangle ${triangleModel.id}: onLoad Finished.");
    return super.onLoad();
  }

  /// Updates the component's internal state from a TriangleShapeModel.
  /// Handles both initial setup and updates (e.g., from provider).
  void _updateFromModel(
    TriangleShapeModel model, {
    bool isInitialLoad = false,
  }) {
    // Only update if the model is actually different or it's the initial load
    if (!isInitialLoad && triangleModel == model) {
      zlog(
        data:
            "Triangle ${triangleModel.id}: _updateFromModel skipped, model unchanged.",
      );
      return;
    }

    triangleModel = model.clone(); // Update the definitive model reference
    zlog(
      data:
          "Triangle ${triangleModel.id}: Updating component from model (isCreating: $_isCreating).",
    );

    if (!_isCreating) {
      // --- Update state for existing/finalized triangle ---
      anchor = Anchor.center; // Ensure anchor is center
      position = SizeHelper.getBoardActualVector(
        gameScreenSize: game.gameField.size,
        actualPosition: triangleModel.center,
      );
      angle = degrees2Radians * (triangleModel.angle ?? 0.0);
      _calculateActualVerticesRelative(); // Calculate relative vertices
      _updatePath(); // Update the final path
      _updateComponentSize(); // Update bounding box
      _updatePaints();
      zlog(
        data:
            "Triangle ${triangleModel.id}: Synced state for finalized triangle. Pos: $position, Angle: $angle",
      );
    } else {
      // --- State update during creation phase ---
      // Position remains (0,0), anchor topLeft. Vertices are in _creationVertices.
      // Ensure paints are updated based on the template model's style.
      _updatePaints();
      zlog(
        data: "Triangle ${triangleModel.id}: Updated paints during creation.",
      );
    }
  }

  /// Calculates vertices relative to the component's center anchor (for finalized state).
  void _calculateActualVerticesRelative() {
    if (_isCreating) return;
    _actualVertexA = triangleModel.vertexA?.clone();
    _actualVertexB = triangleModel.vertexB?.clone();
    _actualVertexC = triangleModel.vertexC?.clone();
    // zlog(data: "Triangle ${triangleModel.id}: Calculated Relative Vertices: A:$_actualVertexA, B:$_actualVertexB, C:$_actualVertexC");
  }

  /// Updates the component's size based on the bounding box of the RELATIVE vertices (for finalized state).
  void _updateComponentSize() {
    if (_isCreating) {
      size =
          game.size; // Cover whole screen during creation to receive taps anywhere
      return;
    }
    // Use relative vertices for size calculation
    final List<Vector2> vertices = [];
    if (_actualVertexA != null) vertices.add(_actualVertexA!);
    if (_actualVertexB != null) vertices.add(_actualVertexB!);
    if (_actualVertexC != null) vertices.add(_actualVertexC!);

    if (vertices.isEmpty) {
      size = Vector2.zero();
      return;
    }

    double minX = vertices[0].x, maxX = vertices[0].x;
    double minY = vertices[0].y, maxY = vertices[0].y;
    for (int i = 1; i < vertices.length; i++) {
      minX = math.min(minX, vertices[i].x);
      maxX = math.max(maxX, vertices[i].x);
      minY = math.min(minY, vertices[i].y);
      maxY = math.max(maxY, vertices[i].y);
    }
    size = Vector2(maxX - minX, maxY - minY);
    // zlog(data: "Triangle ${triangleModel.id}: Updated component size to $size");
  }

  /// Configures the Paint objects based on the current triangle model.
  void _updatePaints() {
    final baseStrokeColor = triangleModel.strokeColor ?? ColorManager.white;
    final baseFillColor = triangleModel.fillColor;
    final baseStrokeWidth = triangleModel.strokeWidth;
    final baseOpacity = triangleModel.opacity ?? 1.0;

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

    _fillPaint =
        baseFillColor != null
            ? (Paint()
              ..color = baseFillColor.withOpacity(baseOpacity)
              ..style = PaintingStyle.fill)
            : null;

    _vertexDotPaint =
        Paint()
          ..color = Colors.red.withOpacity(0.9)
          ..style = PaintingStyle.fill;

    // zlog(data: "Triangle ${triangleModel.id}: _updatePaints completed.");
  }

  /// Rebuilds the Path object *only* if all three relative vertices are defined (finalized state).
  void _updatePath() {
    _trianglePath = Path();
    if (!_isCreating &&
        _actualVertexA != null &&
        _actualVertexB != null &&
        _actualVertexC != null) {
      _trianglePath.moveTo(_actualVertexA!.x, _actualVertexA!.y);
      _trianglePath.lineTo(_actualVertexB!.x, _actualVertexB!.y);
      _trianglePath.lineTo(_actualVertexC!.x, _actualVertexC!.y);
      _trianglePath.close();
      // zlog(data: "Triangle ${triangleModel.id}: Closed Path updated.");
    }
  }

  // --- MODIFIED: Render method handles creation phase ---
  @override
  void render(Canvas canvas) {
    // --- Render during creation phase (using actual world coords) ---
    if (_isCreating) {
      final strokePaintToUse =
          _strokePaint; // Use normal stroke during creation
      final double vertexDotRadius = 4.0;

      // Draw dots at placed vertices (world coordinates)
      for (final vertex in _creationVertices) {
        canvas.drawCircle(vertex.toOffset(), vertexDotRadius, _vertexDotPaint);
      }
      // Draw line between first two vertices if they exist
      if (_creationVertices.length >= 2 && strokePaintToUse.strokeWidth > 0) {
        canvas.drawLine(
          _creationVertices[0].toOffset(),
          _creationVertices[1].toOffset(),
          strokePaintToUse,
        );
      }
    }
    // --- Render finalized triangle (using relative coords and component transforms) ---
    else {
      // Apply component transforms (position, angle) BEFORE drawing
      canvas.save();
      canvas.translate(position.x, position.y);
      canvas.rotate(angle);
      // Now local origin (0,0) is the component's center

      final strokePaintToUse = isActive ? _activeStrokePaint : _strokePaint;
      bool canDraw =
          _actualVertexA != null &&
          _actualVertexB != null &&
          _actualVertexC != null;

      // 1. Draw Fill (if complete and fill paint exists)
      if (_fillPaint != null && canDraw) {
        canvas.drawPath(_trianglePath, _fillPaint!);
      }
      // 2. Draw Stroke Outline (if complete and stroke width > 0)
      if (strokePaintToUse.strokeWidth > 0 && canDraw) {
        canvas.drawPath(_trianglePath, strokePaintToUse);
      }
      // 3. Optionally draw dots/handles when active and complete
      // if (isActive && canDraw) { ... draw dots at _actualVertexX ... }

      canvas.restore(); // Restore canvas state
    }
  }
  // --- END MODIFICATION ---

  @override
  bool containsLocalPoint(Vector2 point) {
    // Only allow interaction if the triangle is finalized
    if (!_isCreating &&
        _actualVertexA != null &&
        _actualVertexB != null &&
        _actualVertexC != null) {
      // Transform the world point to local space considering position and angle
      final localPoint = absoluteToLocal(point);
      final contains = _trianglePath.contains(localPoint.toOffset());
      return contains;
    }
    return false;
  }

  // --- Tap Handling (Only works on complete triangle) ---
  @override
  void onTapDown(TapDownEvent event) {
    if (_isCreating) {
      event.handled = false;
      return;
    } // Ignore taps during creation

    zlog(
      data: "Triangle ${triangleModel.id}: onTapDown at ${event.localPosition}",
    );
    if (containsLocalPoint(event.localPosition)) {
      // Check using world position
      _toggleActive();
      event.handled = true;
    } else {
      event.handled = false;
    }
    zlog(
      data: "Triangle ${triangleModel.id}: onTapDown handled: ${event.handled}",
    );
  }

  void _toggleActive() {
    zlog(data: "Triangle ${triangleModel.id}: _toggleActive called.");
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: triangleModel);
  }

  // --- Drag Handling (Only works on complete triangle) ---
  @override
  void onDragStart(DragStartEvent event) {
    if (_isCreating) {
      event.continuePropagation = true;
      super.onDragStart(event);
      return;
    }
    zlog(
      data:
          "Triangle ${triangleModel.id}: onDragStart at ${event.localPosition}",
    );
    if (isActive && containsLocalPoint(event.localPosition)) {
      // Check using world position
      _isDragging = true;
      event.continuePropagation = false;
      zlog(
        data:
            "Triangle ${triangleModel.id}: Component Drag Started (_isDragging = true)",
      );
    } else {
      _isDragging = false;
      super.onDragStart(event);
      event.continuePropagation = true;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isCreating) {
      super.onDragUpdate(event);
      event.continuePropagation = true;
      return;
    }
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
    if (_isCreating) {
      super.onDragEnd(event);
      event.continuePropagation = true;
      return;
    }
    zlog(
      data:
          "Triangle ${triangleModel.id}: onDragEnd. Was dragging component: $_isDragging",
    );
    if (_isDragging) {
      _isDragging = false;
      _updateModelPosition(); // Update provider with final position
      event.continuePropagation = false;
      zlog(
        data:
            "Triangle ${triangleModel.id}: Component Drag Ended. Final position saved.",
      );
    } else {
      super.onDragEnd(event);
      event.continuePropagation = true;
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (_isCreating) {
      super.onDragCancel(event);
      event.continuePropagation = true;
      return;
    }
    zlog(
      data:
          "Triangle ${triangleModel.id}: onDragCancel. Was dragging component: $_isDragging",
    );
    if (_isDragging) {
      _isDragging = false;
      event.continuePropagation = false;
    } else {
      super.onDragCancel(event);
      event.continuePropagation = true;
    }
  }

  /// Updates the provider with the current position (center) and potentially other properties.
  void _updateModelPosition() {
    // ... (logic remains the same) ...
    zlog(
      data:
          "Triangle ${triangleModel.id}: _updateModelPosition (Center Update). Actual Pos: $position",
    );
    final relativeCenter = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
    final angleInDegrees = angle * (180 / math.pi);
    final relativeVertexA = _actualVertexA;
    final relativeVertexB = _actualVertexB;
    final relativeVertexC = _actualVertexC;
    final updatedModel = triangleModel.copyWith(
      offset: relativeCenter.clone(),
      angle: angleInDegrees,
      vertexA: relativeVertexA?.clone(),
      vertexB: relativeVertexB?.clone(),
      vertexC: relativeVertexC?.clone(),
      color: triangleModel.strokeColor,
      fillColor: triangleModel.fillColor,
      strokeWidth: triangleModel.strokeWidth,
      opacity: triangleModel.opacity,
    );
    zlog(
      data:
          "Triangle ${triangleModel.id}: Notifying provider (Position Update): ${updatedModel.toJson()}",
    );
    ref.read(boardProvider.notifier).updateShape(shape: updatedModel);
  }

  // --- State Update from Provider ---
  void _updateIsActive(FieldItemModel? selectedItem) {
    if (_isCreating)
      return; // Don't handle active state changes during creation

    zlog(
      data:
          "Triangle ${triangleModel.id}: _updateIsActive check. Selected ID: ${selectedItem?.id}",
    );
    final newActiveState =
        selectedItem is TriangleShapeModel &&
        selectedItem.id == triangleModel.id;

    if (isActive != newActiveState) {
      isActive = newActiveState;
      zlog(
        data: "Triangle ${triangleModel.id}: isActive CHANGED to: $isActive",
      );
      _updatePaints(); // Update paint styles

      // Sync internal state if activated and model changed externally
      if (isActive &&
          selectedItem != null &&
          selectedItem is TriangleShapeModel) {
        if (triangleModel != selectedItem) {
          zlog(
            data:
                "Triangle ${triangleModel.id}: Syncing internal state from provider.",
          );
          _updateFromModel(selectedItem); // Use helper to update all state
        }
      }
    }
  }

  /// Updates the component's state based on a new model.
  /// Called externally (e.g., by DrawingInputHandler) ONLY for the initial temporary component.
  /// Final components are created fresh by ItemManagement.addItem.
  void updateTriangleModel(TriangleShapeModel newModel) {
    if (!_isCreating) {
      zlog(
        data:
            "Triangle ${triangleModel.id}: updateTriangleModel called on non-creating component. Ignoring.",
      );
      return; // Should only be called on the temporary creation component
    }
    zlog(
      data:
          "Triangle ${triangleModel.id}: updateTriangleModel called (creation). Vertices: A:${newModel.vertexA} B:${newModel.vertexB} C:${newModel.vertexC}",
    );
    // Update the model reference for paint configuration etc.
    triangleModel = newModel.clone();
    // Update paints based on template style
    _updatePaints();
    // Vertices are handled by addCreationVertex and render directly
  }

  // Placeholder for saving final state if vertices were modified by dots
  void _saveFinalStateToProvider() {
    _updateModelPosition();
  }

  // --- NEW: Method to add a vertex during creation ---
  /// Adds an actual world coordinate vertex during the creation phase.
  void addCreationVertex(Vector2 actualVertex) {
    if (!_isCreating) return; // Only works during creation
    _creationVertices.add(actualVertex);
    zlog(
      data:
          "Triangle ${triangleModel.id}: Added creation vertex ${_creationVertices.length} at $actualVertex",
    );
  }

  // --- END NEW ---
} // End of TriangleShapeDrawerComponent class
