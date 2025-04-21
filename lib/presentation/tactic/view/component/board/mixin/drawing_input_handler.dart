// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// // Import the DrawingBoardComponent itself to call methods
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';
//
// mixin DrawingInputHandler on TacticBoardGame {
//   // TacticBoardGame should have drawingBoard instance
//   Vector2? lineStartPoint; // For straight lines
//   LineDrawerComponentV2? _currentStraightLine; // Renamed for clarity
//
//   // --- Centralized Drag Handlers ---
//
//   @override
//   void onDragStart(DragStartEvent event) {
//     final lp = ref.read(lineProvider);
//     bool eventHandled = false;
//
//     // --- Priority 1: Free Draw / Erase / Move (Delegate to Component) ---
//     // Check if the component exists and if the event is within its bounds
//     // Note: Assumes 'drawingBoard' is accessible via TacticBoardGame or ItemManagement mixin
//     if (this.contains(drawingBoard) &&
//         drawingBoard.containsLocalPoint(event.localPosition)) {
//       // Check component's internal state via getter/tool state
//       final tool = drawingBoard.currentTool;
//       final isSelected = drawingBoard.isLineSelected;
//
//       if (tool == DrawingTool.draw ||
//           tool == DrawingTool.erase ||
//           (tool == null && isSelected)) {
//         // Let the component handle it
//         eventHandled = drawingBoard.handleDragStart(event);
//       }
//     }
//
//     // --- Priority 2: Straight Line Drawing ---
//     if (!eventHandled && lp.isLineActiveToAddIntoGameField) {
//       lineStartPoint = event.localPosition;
//       FieldItemModel? item = lp.activeForm;
//       if (item is LineModelV2) {
//         LineModelV2 lineModelV2 = item;
//         lineModelV2 = lineModelV2.copyWith(
//           start: SizeHelper.getBoardRelativeVector(
//             gameScreenSize: gameField.size,
//             actualPosition: lineStartPoint!,
//           ),
//           end: SizeHelper.getBoardRelativeVector(
//             gameScreenSize: gameField.size,
//             actualPosition: lineStartPoint!,
//           ),
//         );
//         _currentStraightLine = LineDrawerComponentV2(lineModelV2: lineModelV2);
//         add(_currentStraightLine!);
//         eventHandled = true; // Mark as handled
//       }
//     }
//
//     // --- If not handled, call super ---
//     if (!eventHandled) {
//       super.onDragStart(event);
//     }
//   }
//
//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     final lp = ref.read(lineProvider);
//     bool eventHandled = false;
//
//     // --- Priority 1: Free Draw / Erase / Move (Delegate to Component) ---
//     // Check component's internal state (isMoving, isDrawing/Erasing)
//     if (drawingBoard.currentTool != null || drawingBoard.isMovingLine) {
//       // Access internal state needed or add getter
//       // Let the component handle it, assuming it only returns true if active
//       eventHandled = drawingBoard.handleDragUpdate(event);
//     }
//
//     if (!eventHandled &&
//         lp.isLineActiveToAddIntoGameField &&
//         lineStartPoint != null &&
//         _currentStraightLine != null) {
//       final currentPoint = event.localStartPosition; // Use current position
//       _currentStraightLine!.updateEnd(currentPoint);
//       // *** Tell updateLine to recalculate control points during creation: ***
//       _currentStraightLine!.updateLine(recalculateControlPoints: true);
//
//       eventHandled = true;
//     }
//
//     // --- If not handled, call super ---
//     if (!eventHandled) {
//       super.onDragUpdate(event);
//     }
//   }
//
//   @override
//   void onDragEnd(DragEndEvent event) {
//     final lp = ref.read(lineProvider);
//     bool eventHandled = false;
//
//     // --- Priority 1: Free Draw / Erase / Move (Delegate to Component) ---
//     if (drawingBoard.currentTool != null || drawingBoard.isMovingLine) {
//       eventHandled = drawingBoard.handleDragEnd(event);
//       // Reset component's internal moving state is handled within handleDragEnd now
//     }
//
//     // --- Priority 2: Straight Line Drawing ---
//     if (!eventHandled &&
//         lp.isLineActiveToAddIntoGameField &&
//         lineStartPoint != null &&
//         _currentStraightLine != null) {
//       LineModelV2 lineModelV2 = _currentStraightLine!.lineModelV2;
//       ref
//           .read(boardProvider.notifier)
//           .addBoardComponent(fieldItemModel: lineModelV2);
//       ref
//           .read(lineProvider.notifier)
//           .unLoadActiveLineModelToAddIntoGameFieldEvent(line: lineModelV2);
//
//       _currentStraightLine = null; // VERY IMPORTANT: Clear current line.
//       lineStartPoint = null;
//       eventHandled = true;
//     }
//     // Clear temporary straight line variable if it exists but wasn't handled above
//     // (e.g., if drag ended prematurely without meeting conditions)
//     if (_currentStraightLine != null && !eventHandled) {
//       remove(_currentStraightLine!); // Ensure partial straight line is removed
//       _currentStraightLine = null;
//       lineStartPoint = null;
//     }
//
//     // --- If not handled, call super ---
//     if (!eventHandled) {
//       super.onDragEnd(event);
//     }
//   }
//
//   @override
//   void onDragCancel(DragCancelEvent event) {
//     final lp = ref.read(lineProvider);
//     bool eventHandled = false;
//
//     // --- Priority 1: Free Draw / Erase / Move (Delegate to Component) ---
//     if (drawingBoard.currentTool != null || drawingBoard.isMovingLine) {
//       eventHandled = drawingBoard.handleDragCancel(event);
//     }
//
//     // --- Priority 2: Straight Line Drawing ---
//     // Use _currentStraightLine to check if we were drawing one
//     if (!eventHandled && _currentStraightLine != null) {
//       remove(_currentStraightLine!);
//       _currentStraightLine = null;
//       lineStartPoint = null;
//       // Reset provider state if the cancelled line was the active one
//       if (lp.isLineActiveToAddIntoGameField && lp.activeForm != null) {
//         FieldItemModel? item = lp.activeForm;
//         if (item is LineModelV2) {
//           ref
//               .read(lineProvider.notifier)
//               .unLoadActiveLineModelToAddIntoGameFieldEvent(line: item);
//         }
//       }
//       eventHandled = true;
//     }
//
//     // --- If not handled, call super ---
//     if (!eventHandled) {
//       super.onDragCancel(event);
//     }
//   }
// }

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
// Import your models, including ShapeModel and CircleShapeModel
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// Import components
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart'; // Keep if used
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart'; // Keep LineDrawerComponentV2
// Circle Integration here
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/shape_plugin.dart'; // Assuming CircleShapeDrawerComponent is here
// Import providers
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart'; // Assuming this handles all forms now

mixin DrawingInputHandler on TacticBoardGame {
  // TacticBoardGame should have drawingBoard instance
  Vector2? lineStartPoint; // For straight lines
  LineDrawerComponentV2? _currentStraightLine; // Renamed for clarity

  // Circle Integration here
  // State variables for drawing circles
  Vector2?
  shapeCenterPoint; // Center point where circle drag starts (actual coords)
  CircleShapeDrawerComponent?
  _currentCircleShape; // The circle component being drawn

  // --- Centralized Drag Handlers ---

  @override
  void onDragStart(DragStartEvent event) {
    // Use ref directly as mixin is on TacticBoardGame which has RiverpodGameMixin
    final formToolState = ref.read(
      lineProvider,
    ); // Use consistent naming if provider was renamed
    bool eventHandled = false;

    // --- Priority 1: Free Draw / Erase / Move (Delegate to Component) ---
    // Check if drawingBoard exists and contains the point before accessing properties
    // Assuming 'drawingBoard' is a late variable initialized elsewhere or nullable
    // Also ensure drawingBoard is added to the component tree first
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

    // --- Priority 2: Straight Line Drawing ---
    if (!eventHandled && formToolState.isLineActiveToAddIntoGameField) {
      FieldItemModel? item = formToolState.activeForm;
      if (item is LineModelV2) {
        lineStartPoint = event.localPosition;
        LineModelV2 lineModelV2 = item; // Use the template from provider
        lineModelV2 = lineModelV2.copyWith(
          // Create instance for the board
          start: SizeHelper.getBoardRelativeVector(
            gameScreenSize: gameField.size,
            actualPosition: lineStartPoint!,
          ),
          end: SizeHelper.getBoardRelativeVector(
            gameScreenSize: gameField.size,
            actualPosition: lineStartPoint!,
          ),
          // Ensure CPs are cleared for a fresh line drag operation
          controlPoint1: null,
          controlPoint2: null,
          clearControlPoints: true,
        );
        _currentStraightLine = LineDrawerComponentV2(lineModelV2: lineModelV2);
        add(_currentStraightLine!);
        eventHandled = true; // Mark as handled
      }
    }

    // Circle Integration here
    // --- Priority 3: Circle Shape Drawing ---
    if (!eventHandled && formToolState.isShapeActiveToAddIntoGameField) {
      FieldItemModel? item = formToolState.activeForm;
      if (item is CircleShapeModel) {
        // Check if the active form is a Circle
        shapeCenterPoint = event.localPosition; // Store actual center point
        CircleShapeModel circleModel = item.copyWith(
          // Create instance from template
          offset: SizeHelper.getBoardRelativeVector(
            // Set relative center (offset)
            gameScreenSize: gameField.size,
            actualPosition: shapeCenterPoint!,
          ),
          radius: 0.1, // Start with a tiny radius
        );
        _currentCircleShape = CircleShapeDrawerComponent(
          circleModel: circleModel,
        );
        add(_currentCircleShape!);
        eventHandled = true; // Mark as handled
      }
      // Add 'else if (item is RectangleShapeModel)' etc. for other shapes here
    }

    // --- If not handled, call super ---
    if (!eventHandled) {
      super.onDragStart(event);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Use ref directly
    final formToolState = ref.read(lineProvider);
    bool eventHandled = false;

    // --- Priority 1: Free Draw / Erase / Move (Delegate to Component) ---
    // Assuming drawingBoard state checks are correct
    if (children.contains(drawingBoard) &&
        (drawingBoard.currentTool != null || drawingBoard.isMovingLine)) {
      eventHandled = drawingBoard.handleDragUpdate(event);
    }

    // --- Priority 2: Straight Line Drawing ---
    if (!eventHandled &&
        formToolState.isLineActiveToAddIntoGameField &&
        lineStartPoint != null &&
        _currentStraightLine != null) {
      final currentPoint =
          event.localStartPosition; // Use current local position
      _currentStraightLine!.updateEnd(currentPoint);
      _currentStraightLine!.updateLine(recalculateControlPoints: true);
      eventHandled = true;
    }

    // Circle Integration here
    // --- Priority 3: Circle Shape Drawing ---
    if (!eventHandled &&
        formToolState.isShapeActiveToAddIntoGameField &&
        shapeCenterPoint != null &&
        _currentCircleShape != null) {
      final currentPoint =
          event.localStartPosition; // Current drag position (actual coords)
      // Calculate radius based on distance from center (actual coords)
      double newRadius = shapeCenterPoint!.distanceTo(currentPoint);
      // Update the component (which updates internal state and notifies provider)
      // *** Assumes updateRadiusAndSave exists in CircleShapeDrawerComponent ***
      _currentCircleShape!.updateRadiusAndSave(newRadius);
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
    final formToolState = ref.read(lineProvider);
    bool eventHandled = false;

    // --- Priority 1: Free Draw / Erase / Move (Delegate to Component) ---
    if (children.contains(drawingBoard) &&
        (drawingBoard.currentTool != null || drawingBoard.isMovingLine)) {
      eventHandled = drawingBoard.handleDragEnd(event);
    }

    // --- Priority 2: Straight Line Drawing ---
    if (!eventHandled &&
        formToolState.isLineActiveToAddIntoGameField &&
        lineStartPoint != null &&
        _currentStraightLine != null) {
      LineModelV2 lineModelV2 = _currentStraightLine!.lineModelV2;
      ref
          .read(boardProvider.notifier)
          .addBoardComponent(fieldItemModel: lineModelV2);
      ref
          .read(lineProvider.notifier)
          .unLoadActiveLineModelToAddIntoGameFieldEvent(line: lineModelV2);

      _currentStraightLine = null; // VERY IMPORTANT: Clear current line.
      lineStartPoint = null;
      eventHandled = true;
    }
    // Clear temporary straight line variable if it exists but wasn't handled above
    // (e.g., if drag ended prematurely without meeting conditions)
    if (_currentStraightLine != null && !eventHandled) {
      remove(_currentStraightLine!); // Ensure partial straight line is removed
      _currentStraightLine = null;
      lineStartPoint = null;
    }

    // Circle Integration here
    // --- Priority 3: Circle Shape Drawing ---
    if (!eventHandled &&
        formToolState.isShapeActiveToAddIntoGameField &&
        shapeCenterPoint != null &&
        _currentCircleShape != null) {
      // Retrieve final model state FROM THE COMPONENT as updated by the last onDragUpdate
      CircleShapeModel finalCircleModel = _currentCircleShape!.circleModel;

      // Check if the radius (set by last onDragUpdate) is reasonably large
      if (finalCircleModel.radius < 2.0) {
        // Avoid tiny circles on just a tap
        remove(_currentCircleShape!); // Remove the temporary visual component
        ref
            .read(lineProvider.notifier)
            .dismissActiveFormItem(); // Dismiss tool generically
      } else {
        // Radius is valid, add component to board state using the model
        ref
            .read(boardProvider.notifier)
            .addBoardComponent(fieldItemModel: finalCircleModel);
        // Unload the tool from the provider
        // *** Assumes specific unload method exists, or use generic dismiss ***
        ref
            .read(lineProvider.notifier)
            .unLoadActiveShapeModelToAddIntoGameFieldEvent(
              shape: finalCircleModel,
            );
      }

      // Clean up temporary component reference and state
      _currentCircleShape = null; // Always clear the reference
      shapeCenterPoint = null;
      eventHandled = true;
    }

    // --- Cleanup temporary components if drag ended unexpectedly ---
    if (_currentStraightLine != null && !eventHandled) {
      remove(_currentStraightLine!);
      _currentStraightLine = null;
      lineStartPoint = null;
      // Also potentially dismiss provider state if needed
      ref.read(lineProvider.notifier).dismissActiveFormItem();
    }
    // Circle Integration here
    if (_currentCircleShape != null && !eventHandled) {
      // If we reach here, it means the circle drag didn't complete normally
      if (children.contains(_currentCircleShape!)) {
        remove(_currentCircleShape!);
      }
      _currentCircleShape = null;
      shapeCenterPoint = null;
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
    final formToolState = ref.read(lineProvider);
    bool eventHandled = false;

    // --- Priority 1: Free Draw / Erase / Move (Delegate to Component) ---
    if (children.contains(drawingBoard) &&
        (drawingBoard.currentTool != null || drawingBoard.isMovingLine)) {
      eventHandled = drawingBoard.handleDragCancel(event);
    }

    // --- Priority 2: Straight Line Drawing ---
    if (!eventHandled && _currentStraightLine != null) {
      remove(_currentStraightLine!);
      _currentStraightLine = null;
      lineStartPoint = null;
      // Reset provider state if the cancelled line was the active one
      if (formToolState.isLineActiveToAddIntoGameField &&
          formToolState.activeForm is LineModelV2) {
        // *** Assumes specific unload method exists, or use generic dismiss ***
        ref
            .read(lineProvider.notifier)
            .unLoadActiveLineModelToAddIntoGameFieldEvent(
              line: formToolState.activeForm as LineModelV2,
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
      // Reset provider state if the cancelled shape was the active one
      if (formToolState.isShapeActiveToAddIntoGameField &&
          formToolState.activeForm is CircleShapeModel) {
        // *** Assumes specific unload method exists, or use generic dismiss ***
        ref
            .read(lineProvider.notifier)
            .unLoadActiveShapeModelToAddIntoGameFieldEvent(
              shape: formToolState.activeForm as CircleShapeModel,
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
