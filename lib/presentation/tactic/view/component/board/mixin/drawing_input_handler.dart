import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// Circle Integration here
import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
// Import models
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart';
// Import components
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// Circle Integration here
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/circle_shape_plugin.dart'; // Assuming CircleShapeDrawerComponent is here
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart'; // Keep if used
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart'; // Keep LineDrawerComponentV2
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/polygon_shape_plugin.dart';
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

  Vector2?
      squareCenterPoint; // FIXED Center where square drag starts (actual coords)
  SquareShapeDrawerComponent? _currentSquareShape;

  PolygonShapeDrawerComponent?
      _currentPolygonComponent; // Ref to the component being drawn
  final double _polygonCloseThreshold =
      15.0; // Pixel distance to tap near start vertex to close
  // --- End Polygon Integration ---

  @override
  void onDragStart(DragStartEvent event) {
    if (isAnimating) return;

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
      }
      // --- Square Integration here ---
      // Check for square moved inside the shape check
      // --- Square Integration here --- (Moved check inside shape block)
      else if (item is SquareShapeModel) {
        // Handle Square Start
        squareCenterPoint = event.localPosition; // Store FIXED actual center
        SquareShapeModel squareModel = item.copyWith(
          offset: SizeHelper.getBoardRelativeVector(
            // Set relative center
            gameScreenSize: gameField.size,
            actualPosition: squareCenterPoint!,
          ),
          side: 0.1, // Start tiny (relative side)
          angle: 0,
        );
        // Component's onLoad will set position based on model's offset
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
    if (isAnimating) return;
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
      final currentPoint = event
          .localStartPosition; // Current drag point (diametrically opposite)

      // Calculate diameter and radius
      double diameter = shapeCenterPoint!.distanceTo(currentPoint);
      double newRadius = diameter / 2.0;
      newRadius /= 3;

      // Calculate center as midpoint of the diameter line
      Vector2 actualCenter = (shapeCenterPoint! + currentPoint) / 2.0;

      // Update the component's position (center)
      _currentCircleShape!.position = actualCenter;
      _currentCircleShape!.circleModel.radius =
          SizeHelper.getBoardRelativeDimension(
        gameScreenSize: gameField.size,
        actualSize: newRadius,
      );

      // Update the component's radius
      _currentCircleShape!.updateRadiusAndSave(newRadius);

      eventHandled = true;
    }

    // --- Square Integration here ---
    // --- Priority 4: Square Shape Drawing (Center Fixed) --- (MODIFIED BLOCK)
    if (!eventHandled &&
        lp.isShapeActiveToAddIntoGameField &&
        squareCenterPoint != null &&
        _currentSquareShape != null) {
      // **** ENSURE THIS USES event.eventPosition.widget ****
      final currentPoint = event.localStartPosition;
      // ****************************************************

      // --- REPLACE LOGIC BELOW ---
      // Calculate dimensions relative to the fixed start corner
      final double dx = currentPoint.x - squareCenterPoint!.x;
      final double dy = currentPoint.y - squareCenterPoint!.y;
      final double width = dx.abs();
      final double height = dy.abs();

      // Side length is the max dimension to maintain square shape
      final double actualSide = math.max(width, height);

      // Calculate the center based on start corner and side length/direction
      final double signX = dx.sign; // Direction X (+1.0, -1.0, or 0.0)
      final double signY = dy.sign; // Direction Y (+1.0, -1.0, or 0.0)
      // Center is offset from the start corner by half the side, in the drag direction
      final Vector2 actualCenter = Vector2(
        squareCenterPoint!.x + (signX * actualSide / 2.0),
        squareCenterPoint!.y + (signY * actualSide / 2.0),
      );

      // Update the component's position (center)
      _currentSquareShape!.position = actualCenter;

      _currentSquareShape?.squareModel.side =
          SizeHelper.getBoardRelativeDimension(
        gameScreenSize: gameField.size,
        actualSize: actualSide,
      );
      _currentSquareShape?.squareModel.offset =
          SizeHelper.getBoardRelativeVector(
        gameScreenSize: gameField.size,
        actualPosition: actualCenter,
      );

      // Update the component's side length
      _currentSquareShape!.updateSideInternally(actualSide);
      // --- END OF LOGIC TO REPLACE/ADD ---

      eventHandled = true;
    }

    // --- If not handled, call super ---
    if (!eventHandled) {
      super.onDragUpdate(event);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (isAnimating) return;
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
      ref
          .read(lineProvider.notifier)
          .loadActiveLineModelToAddIntoGameFieldEvent(
            lineModelV2: finalLineModel,
          );
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
      ref
          .read(lineProvider.notifier)
          .loadActiveShapeModelToAddIntoGameFieldEvent(
            shapeModel: finalCircleModel,
          );
    }

    // --- Square Integration here ---
    // --- Priority 4: Square Shape Drawing (Fixed Corner) --- (MODIFIED BLOCK)
    if (!eventHandled &&
        lp.isShapeActiveToAddIntoGameField && // Assuming same flag
        squareCenterPoint != null && // Center is fixed
        _currentSquareShape != null) {
      SquareShapeModel finalSquareModel = _currentSquareShape!.squareModel;

      // Add component to board state
      ref
          .read(boardProvider.notifier)
          .addBoardComponent(fieldItemModel: finalSquareModel);
      // Unload the tool from the provider
      ref
          .read(lineProvider.notifier)
          .unLoadActiveShapeModelToAddIntoGameFieldEvent(
            shape: finalSquareModel,
          );

      // Clean up state
      _currentSquareShape = null;
      squareCenterPoint = null; // Clear fixed center point
      eventHandled = true;
      ref
          .read(lineProvider.notifier)
          .loadActiveShapeModelToAddIntoGameFieldEvent(
            shapeModel: finalSquareModel,
          );
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

    // --- Square Integration here ---
    if (_currentSquareShape != null && !eventHandled) {
      if (children.contains(_currentSquareShape!)) {
        remove(_currentSquareShape!);
      }
      _currentSquareShape = null;
      squareCenterPoint = null;
      ref.read(lineProvider.notifier).dismissActiveFormItem();
    }

    // --- If not handled, call super ---
    if (!eventHandled) {
      super.onDragEnd(event);
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (isAnimating) return;
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
    // --- Priority 4: Square Shape Drawing --- (MODIFIED BLOCK)
    if (!eventHandled && _currentSquareShape != null) {
      remove(_currentSquareShape!);
      _currentSquareShape = null;
      squareCenterPoint = null; // Clear fixed center point
      if (lp.isShapeActiveToAddIntoGameField &&
          lp.activeForm is SquareShapeModel) {
        ref
            .read(lineProvider.notifier)
            .unLoadActiveShapeModelToAddIntoGameFieldEvent(
              shape: lp.activeForm as SquareShapeModel,
            );
      }
      eventHandled = true;
    }

    // --- If not handled, call super ---
    if (!eventHandled) {
      super.onDragCancel(event);
    }
  }

  // Add this method inside your DrawingInputHandler mixin
  // Or replace the existing onTapDown if you have one at the TacticBoardGame level

  // @override
  // void onTapDown(TapDownInfo event) {
  //   final lp = ref.read(lineProvider);
  //   bool eventHandled = false;
  //
  //   if (!eventHandled &&
  //       lp.isShapeActiveToAddIntoGameField &&
  //       lp.activeForm is PolygonShapeModel) {
  //     final tapPosition =
  //         event.raw.localPosition
  //             .toVector2(); // Actual coordinate relative to game/board
  //     zlog(
  //       data:
  //           "Polygon Tool Active - Tap Detected. Vertices placed: ${_polygonVerticesInProgress.length} at $tapPosition",
  //     );
  //
  //     // Check if tapping near the first vertex to close the polygon
  //     if (_polygonVerticesInProgress.length >=
  //             3 && // Need at least 3 vertices to close
  //         _polygonVerticesInProgress[0].distanceTo(tapPosition) <
  //             _polygonCloseThreshold) {
  //       // --- Close Polygon ---
  //       zlog(data: "Polygon Tap: Closing polygon by tapping near start.");
  //
  //       // 1. Get all actual vertices (A, B, C... Last)
  //       List<Vector2> actualVertices = List.from(_polygonVerticesInProgress);
  //
  //       // 2. Calculate the final actual geometric center
  //       Vector2 finalActualCenter = Vector2.zero();
  //       for (var v in actualVertices) {
  //         finalActualCenter += v;
  //       }
  //       finalActualCenter /= actualVertices.length.toDouble();
  //
  //       // 3. Calculate final vertices relative to this final actual center
  //       List<Vector2> finalRelativeVertices =
  //           actualVertices.map((v) => v - finalActualCenter).toList();
  //
  //       // 4. Convert final center to relative coordinates for saving
  //       Vector2 finalRelativeCenter = SizeHelper.getBoardRelativeVector(
  //         gameScreenSize: gameField.size,
  //         actualPosition: finalActualCenter,
  //       );
  //
  //       // 5. Create the final model
  //       PolygonShapeModel finalModel = (lp.activeForm as PolygonShapeModel)
  //           .copyWith(
  //             id: _polygonModelInProgress!.id, // Use temp ID or generate new
  //             offset: finalRelativeCenter,
  //             relativeVertices: finalRelativeVertices,
  //             // Inherit style properties
  //           );
  //
  //       // 6. Remove the temporary component
  //       if (_currentPolygonComponent != null &&
  //           children.contains(_currentPolygonComponent!)) {
  //         remove(_currentPolygonComponent!);
  //       }
  //
  //       add(PolygonShapeDrawerComponent(initialModel: finalModel));
  //
  //       // 7. Add the final component via the board provider
  //       ref
  //           .read(boardProvider.notifier)
  //           .addBoardComponent(fieldItemModel: finalModel);
  //
  //       // 8. Reset state
  //       _polygonVerticesInProgress.clear();
  //       _polygonModelInProgress = null;
  //       _currentPolygonComponent = null;
  //       ref.read(lineProvider.notifier).dismissActiveFormItem();
  //
  //       zlog(
  //         data:
  //             "Polygon Finalized. Center: $finalActualCenter, Vertices: ${finalRelativeVertices.length} - ${finalRelativeVertices}",
  //       );
  //       eventHandled = true;
  //     } else {
  //       // --- Add a new vertex ---
  //       _polygonVerticesInProgress.add(tapPosition.clone());
  //
  //       if (_polygonVerticesInProgress.length == 1) {
  //         // --- First Tap: Create Temporary Component ---
  //         _polygonModelInProgress = (lp.activeForm as PolygonShapeModel)
  //             .copyWith(
  //               id: RandomGenerator.generateId(), // Temp ID
  //               offset: Vector2.zero(), // Position (0,0), anchor topLeft
  //               relativeVertices: [], // Vertices stored separately for now
  //             );
  //         _currentPolygonComponent = PolygonShapeDrawerComponent(
  //           initialModel: _polygonModelInProgress!,
  //           isCreating: true, // Set creation flag
  //         );
  //         _currentPolygonComponent!.addCreationVertex(tapPosition.clone());
  //         add(_currentPolygonComponent!);
  //         zlog(
  //           data:
  //               "Polygon Tap 1: Placed vertex A at $tapPosition. Temp Component added.",
  //         );
  //       } else {
  //         // --- Subsequent Taps (not closing): Add vertex to component ---
  //         _currentPolygonComponent?.addCreationVertex(tapPosition.clone());
  //         zlog(
  //           data:
  //               "Polygon Tap ${_polygonVerticesInProgress.length}: Placed vertex at $tapPosition.",
  //         );
  //       }
  //       eventHandled = true; // Consume the tap
  //     }
  //   }
  //   // --- End Polygon Integration ---
  //
  //   // --- If not handled by any drawing logic, call super ---
  //   if (!eventHandled) {
  //     super.onTapDown(event);
  //   }
  // }

  @override
  void onTapDown(TapDownInfo event) async {
    if (isAnimating) return;
    final lp = ref.read(lineProvider);
    bool eventHandled = false;

    if (!eventHandled &&
        lp.isShapeActiveToAddIntoGameField &&
        lp.activeForm is PolygonShapeModel) {
      final tapPosition = event.raw.localPosition
          .toVector2(); // Actual coordinate relative to game/board
      zlog(
        data:
            "Polygon Tool Active - Tap Detected. Vertices placed: at $tapPosition",
      );
      PolygonShapeModel shapeModel = lp.activeForm as PolygonShapeModel;

      if (_currentPolygonComponent == null ||
          shapeModel.id != _currentPolygonComponent?.polygonModel.id) {
        shapeModel = shapeModel.copyWith(relativeVertices: []);
        _currentPolygonComponent = PolygonShapeDrawerComponent(
          polygonModel: shapeModel,
        );
        await add(_currentPolygonComponent!);

        await Future.delayed(Duration(seconds: 0));
        _currentPolygonComponent?.insertVertex(
          SizeHelper.getBoardRelativeVector(
            gameScreenSize: gameField.size,
            actualPosition: tapPosition,
          ),
        );
      } else {
        _currentPolygonComponent?.insertVertex(
          SizeHelper.getBoardRelativeVector(
            gameScreenSize: gameField.size,
            actualPosition: tapPosition,
          ),
        );
      }
    }
    if (!eventHandled) {
      super.onTapDown(event);
    }
  }
}
