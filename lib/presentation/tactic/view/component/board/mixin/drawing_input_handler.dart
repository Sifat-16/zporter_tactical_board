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
  // Vector2?
  //     shapeCenterPoint; // FIXED Center point where circle drag starts (actual coords)
  // CircleShapeDrawerComponent?
  //     _currentCircleShape; // The circle component being drawn
  //
  // Vector2?
  //     squareCenterPoint; // FIXED Center where square drag starts (actual coords)
  // SquareShapeDrawerComponent? _currentSquareShape;
  //
  // PolygonShapeDrawerComponent?
  //     _currentPolygonComponent; // Ref to the component being drawn
  final double _polygonCloseThreshold =
      15.0; // Pixel distance to tap near start vertex to close

  @override
  void onDragStart(DragStartEvent event) {
    if (isAnimating) return;

    // Use ref directly as mixin is on TacticBoardGame which has RiverpodGameMixin
    final lp = ref.read(lineProvider);
    bool eventHandled = false;

    // --- PRIORITY 1: Straight Line Drawing ---
    if (lp.isLineActiveToAddIntoGameField) {
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

   

    // --- PRIORITY 3: Free Draw / Erase / Move within DrawingBoardComponent ---
    // This block only runs if a higher-priority tool was not active.
    if (!eventHandled &&
        children.contains(drawingBoard) &&
        drawingBoard.containsLocalPoint(event.localPosition)) {
      eventHandled = drawingBoard.handleDragStart(event);
    }

    // --- If not handled by any of the above, call super ---
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

   
    if (_currentStraightLine != null && !eventHandled) {
      // This check might be redundant now
      remove(_currentStraightLine!);
      _currentStraightLine = null;
      lineStartPoint = null;
      ref.read(lineProvider.notifier).dismissActiveFormItem();
    }
    
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

  
    if (!eventHandled) {
      super.onDragCancel(event);
    }
  }

  @override
  void onTapDown(TapDownEvent event) async {
    if (isAnimating) return;
    final lp = ref.read(lineProvider);
    bool eventHandled = false;

    if (!eventHandled) {
      super.onTapDown(event);
    }
  }
}
