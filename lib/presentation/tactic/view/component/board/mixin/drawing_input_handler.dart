import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// Circle Integration here
import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
// Import models
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart';
// Import components
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// Circle Integration here
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/circle_shape_plugin.dart'; // Assuming CircleShapeDrawerComponent is here
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart'; // Keep if used
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart'; // Keep LineDrawerComponentV2
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/square_shape_plugin.dart';
// Import providers
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart'; // Assuming this handles all forms now

mixin DrawingInputHandler on TacticBoardGame {
  // Line drawing state
  Vector2? lineStartPoint;
  LineDrawerComponentV2? _currentStraightLine;

  // Circle Integration here
  // State variables for drawing circle (center fixed, drag sets radius)
  Vector2?
  shapeCenterPoint; // FIXED Center point where circle drag starts (actual coords)
  CircleShapeDrawerComponent?
  _currentCircleShape; // The circle component being drawn

  // --- Square Integration here ---
  // State variables for drawing square (drag defines diagonal)
  Vector2? squareStartPoint; // Corner where square drag starts (actual coords)
  SquareShapeDrawerComponent? _currentSquareShape;

  // --- Centralized Drag Handlers ---

  @override
  void onDragStart(DragStartEvent event) {
    // Use ref directly as mixin is on TacticBoardGame which has RiverpodGameMixin
    final lp = ref.read(lineProvider);
    bool eventHandled = false;

    // --- Priority 1: Free Draw / Erase / Move --- (Keep Existing Logic)
    // Assumes 'drawingBoard' is accessible from TacticBoardGame
    if (children.contains(drawingBoard) &&
        drawingBoard.containsLocalPoint(event.localPosition)) {
      final tool = drawingBoard.currentTool;
      final isSelected = drawingBoard.isLineSelected;
      if (tool == DrawingTool.draw ||
          tool == DrawingTool.erase ||
          (tool == null && isSelected)) {
        eventHandled = drawingBoard.handleDragStart(event);
      }
    }

    // --- Priority 2: Straight Line Drawing --- (Keep Existing Logic)
    if (!eventHandled && lp.isLineActiveToAddIntoGameField) {
      FieldItemModel? item = lp.activeForm;
      if (item is LineModelV2) {
        lineStartPoint = event.localPosition;
        LineModelV2 lineModelV2 = item.copyWith(
          start: SizeHelper.getBoardRelativeVector(
            gameScreenSize: gameField.size,
            actualPosition: lineStartPoint!,
          ),
          end: SizeHelper.getBoardRelativeVector(
            gameScreenSize: gameField.size,
            actualPosition: lineStartPoint!,
          ),
          controlPoint1: null,
          controlPoint2: null,
          clearControlPoints: true,
        );
        _currentStraightLine = LineDrawerComponentV2(lineModelV2: lineModelV2);
        add(_currentStraightLine!);
        eventHandled = true;
      }
    }

    // Circle Integration here
    // --- Priority 3: Circle Shape Drawing ---
    if (!eventHandled && lp.isShapeActiveToAddIntoGameField) {
      FieldItemModel? item = lp.activeForm;

      if (item is CircleShapeModel) {
        shapeCenterPoint =
            event.localPosition; // Store FIXED actual center point
        CircleShapeModel circleModel = item.copyWith(
          offset: SizeHelper.getBoardRelativeVector(
            // Set relative center (offset)
            gameScreenSize: gameField.size,
            actualPosition: shapeCenterPoint!,
          ),
          radius: 0.1, // Start tiny
        );
        // The CircleShapeDrawerComponent's onLoad will use circleModel.offset
        // to set its initial actual position.
        _currentCircleShape = CircleShapeDrawerComponent(
          circleModel: circleModel,
        );
        add(_currentCircleShape!);
        eventHandled = true;
      } else if (item is SquareShapeModel) {
        // Check if it's a Square
        squareStartPoint =
            event.localPosition; // Store drag start corner (actual coords)
        SquareShapeModel squareModel = item.copyWith(
          // Initial center and side don't matter much yet
          offset: SizeHelper.getBoardRelativeVector(
            gameScreenSize: gameField.size,
            actualPosition: squareStartPoint!, // Temp center
          ),
          side: 0.1, // Start tiny (relative side)
          angle: 0, // Start unrotated
        );
        _currentSquareShape = SquareShapeDrawerComponent(
          squareModel: squareModel,
        );
        add(_currentSquareShape!);
        eventHandled = true;
      }
    }

    // --- If not handled, call super ---
    if (!eventHandled) {
      super.onDragStart(event);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Use ref directly
    final lp = ref.read(lineProvider);
    bool eventHandled = false;

    // --- Priority 1: Free Draw / Erase / Move --- (Keep Existing Logic)
    if (children.contains(drawingBoard) &&
        (drawingBoard.currentTool != null || drawingBoard.isMovingLine)) {
      eventHandled = drawingBoard.handleDragUpdate(event);
    }

    // --- Priority 2: Straight Line Drawing --- (Keep Existing Logic)
    if (!eventHandled &&
        lp.isLineActiveToAddIntoGameField &&
        lineStartPoint != null &&
        _currentStraightLine != null) {
      final currentPoint = event.localStartPosition; // User's current version
      _currentStraightLine!.updateEnd(currentPoint);
      _currentStraightLine!.updateLine(recalculateControlPoints: true);
      eventHandled = true;
    }

    // Circle Integration here
    // --- Priority 3: Circle Shape Drawing ---
    if (!eventHandled &&
        lp.isShapeActiveToAddIntoGameField &&
        shapeCenterPoint != null && // Center point is fixed
        _currentCircleShape != null) {
      final currentPoint =
          event
              .localStartPosition; // Current drag point (diametrically opposite)

      // Calculate diameter and radius
      double diameter = shapeCenterPoint!.distanceTo(currentPoint);
      double newRadius = diameter / 2.0;
      newRadius /= 3;

      // Calculate center as midpoint of the diameter line
      Vector2 actualCenter = (shapeCenterPoint! + currentPoint) / 2.0;

      // Update the component's position (center)
      _currentCircleShape!.position = actualCenter;
      _currentCircleShape!
          .circleModel
          .radius = SizeHelper.getBoardRelativeDimension(
        gameScreenSize: gameField.size,
        actualSize: newRadius,
      );

      // Update the component's radius
      _currentCircleShape!.updateRadiusAndSave(newRadius);

      eventHandled = true;
    }

    // --- Square Integration here ---
    // --- Priority 4: Square Shape Drawing ---
    if (!eventHandled &&
        lp.isShapeActiveToAddIntoGameField && // Assuming same flag
        squareStartPoint != null &&
        _currentSquareShape != null) {
      zlog(data: "Item type check coming here");
      final currentPoint = event.localStartPosition; // Use current position

      // Calculate properties based on bounding box defined by diagonal
      final double width = (squareStartPoint!.x - currentPoint.x).abs();
      final double height = (squareStartPoint!.y - currentPoint.y).abs();
      final double actualSide = math.max(width, height); // Side of the square
      final Vector2 actualCenter =
          (squareStartPoint! + currentPoint) / 2.0; // Center of diagonal

      // Update the component's position (center)
      _currentSquareShape!.position = actualCenter;
      // Update the component's side length (needs method in SquareShapeDrawerComponent)
      // *** Assumes updateSideAndSave exists in SquareShapeDrawerComponent ***
      _currentSquareShape!.updateSideAndSave(actualSide);

      eventHandled = true;
    }

    // --- If not handled, call super ---
    if (!eventHandled) {
      super.onDragUpdate(event);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    // Use ref directly
    final lp = ref.read(lineProvider);
    bool eventHandled = false;

    // --- Priority 1: Free Draw / Erase / Move --- (Keep Existing Logic)
    if (children.contains(drawingBoard) &&
        (drawingBoard.currentTool != null || drawingBoard.isMovingLine)) {
      eventHandled = drawingBoard.handleDragEnd(event);
    }

    // --- Priority 2: Straight Line Drawing --- (Keep Existing Logic)
    if (!eventHandled &&
        lp.isLineActiveToAddIntoGameField &&
        lineStartPoint != null &&
        _currentStraightLine != null) {
      LineModelV2 finalLineModel = _currentStraightLine!.lineModelV2;
      ref
          .read(boardProvider.notifier)
          .addBoardComponent(fieldItemModel: finalLineModel);
      ref
          .read(lineProvider.notifier)
          .unLoadActiveLineModelToAddIntoGameFieldEvent(line: finalLineModel);
      // Cleanup was moved below eventHandled check in user's code
      _currentStraightLine = null;
      lineStartPoint = null;
      eventHandled = true;
    }

    // Circle Integration here
    // --- Priority 3: Circle Shape Drawing ---
    if (!eventHandled &&
        lp.isShapeActiveToAddIntoGameField &&
        shapeCenterPoint != null && // Fixed center point
        _currentCircleShape != null) {
      CircleShapeModel finalCircleModel = _currentCircleShape!.circleModel;
      finalCircleModel.offset = SizeHelper.getBoardRelativeVector(
        gameScreenSize: gameField.size,
        actualPosition: _currentCircleShape?.position ?? Vector2.zero(),
      );
      ref
          .read(boardProvider.notifier)
          .addBoardComponent(fieldItemModel: finalCircleModel);
      // Unload the tool from the provider
      ref
          .read(lineProvider.notifier)
          .unLoadActiveShapeModelToAddIntoGameFieldEvent(
            shape: finalCircleModel,
          );

      // Clean up temporary component reference and state
      _currentCircleShape = null; // Always clear the reference
      shapeCenterPoint = null; // Clear the fixed center point
      eventHandled = true;
    }

    // --- Square Integration here ---
    // --- Priority 4: Square Shape Drawing ---
    if (!eventHandled &&
        lp.isShapeActiveToAddIntoGameField && // Assuming same flag
        squareStartPoint != null &&
        _currentSquareShape != null) {
      // Retrieve final model state
      SquareShapeModel finalSquareModel = _currentSquareShape!.squareModel;

      // Add component to board state
      ref
          .read(boardProvider.notifier)
          .addBoardComponent(fieldItemModel: finalSquareModel);
      // Unload the tool from the provider
      // *** Assumes specific unload method exists, or use generic dismiss ***
      ref
          .read(lineProvider.notifier)
          .unLoadActiveShapeModelToAddIntoGameFieldEvent(
            shape: finalSquareModel,
          );

      // Clean up state
      _currentSquareShape = null;
      squareStartPoint = null;
      eventHandled = true;
    }

    // --- Cleanup temporary components if drag ended unexpectedly --- (User's version structure)
    // NOTE: The line cleanup was moved *inside* the main Priority 2 block in user's code,
    // but cleanup logic is usually placed *after* all handlers.
    // Replicating user structure exactly:
    if (_currentStraightLine != null && !eventHandled) {
      // This check might be redundant now
      remove(_currentStraightLine!);
      _currentStraightLine = null;
      lineStartPoint = null;
      ref.read(lineProvider.notifier).dismissActiveFormItem();
    }
    // Circle Integration here
    if (_currentCircleShape != null && !eventHandled) {
      if (children.contains(_currentCircleShape!)) {
        remove(_currentCircleShape!);
      }
      _currentCircleShape = null;
      shapeCenterPoint = null;
      ref.read(lineProvider.notifier).dismissActiveFormItem();
    }

    // --- Cleanup temporary components if drag ended unexpectedly ---
    // ... existing cleanup logic for lines and circles ...
    // --- Square Integration here ---
    if (_currentSquareShape != null && !eventHandled) {
      // Add cleanup for square
      if (children.contains(_currentSquareShape!)) {
        remove(_currentSquareShape!);
      }
      _currentSquareShape = null;
      squareStartPoint = null;
      ref.read(lineProvider.notifier).dismissActiveFormItem();
    }

    // --- If not handled, call super ---
    if (!eventHandled) {
      super.onDragEnd(event);
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    // Use ref directly
    final lp = ref.read(lineProvider);
    bool eventHandled = false;

    // --- Priority 1: Free Draw / Erase / Move --- (Keep Existing Logic)
    if (children.contains(drawingBoard) &&
        (drawingBoard.currentTool != null || drawingBoard.isMovingLine)) {
      eventHandled = drawingBoard.handleDragCancel(event);
    }

    // --- Priority 2: Straight Line Drawing --- (Keep Existing Logic)
    if (!eventHandled && _currentStraightLine != null) {
      remove(_currentStraightLine!);
      _currentStraightLine = null;
      lineStartPoint = null;
      if (lp.isLineActiveToAddIntoGameField && lp.activeForm is LineModelV2) {
        ref
            .read(lineProvider.notifier)
            .unLoadActiveLineModelToAddIntoGameFieldEvent(
              line: lp.activeForm as LineModelV2,
            );
      }
      eventHandled = true;
    }

    // Circle Integration here
    // --- Priority 3: Circle Shape Drawing ---
    if (!eventHandled && _currentCircleShape != null) {
      remove(_currentCircleShape!);
      _currentCircleShape = null;
      shapeCenterPoint = null;
      if (lp.isShapeActiveToAddIntoGameField &&
          lp.activeForm is CircleShapeModel) {
        ref
            .read(lineProvider.notifier)
            .unLoadActiveShapeModelToAddIntoGameFieldEvent(
              shape: lp.activeForm as CircleShapeModel,
            );
      }
      eventHandled = true;
    }

    // --- Square Integration here ---
    // --- Priority 4: Square Shape Drawing ---
    if (!eventHandled && _currentSquareShape != null) {
      remove(_currentSquareShape!);
      _currentSquareShape = null;
      squareStartPoint = null;
      // Reset provider state if the cancelled shape was the active one
      if (lp.isShapeActiveToAddIntoGameField &&
          lp.activeForm is SquareShapeModel) {
        // Check type
        // *** Assumes specific unload method exists, or use generic dismiss ***
        ref
            .read(lineProvider.notifier)
            .unLoadActiveShapeModelToAddIntoGameFieldEvent(
              shape: lp.activeForm as SquareShapeModel, // Cast needed
            );
      }
      eventHandled = true;
    }

    // --- If not handled, call super ---
    if (!eventHandled) {
      super.onDragCancel(event);
    }
  }
}
