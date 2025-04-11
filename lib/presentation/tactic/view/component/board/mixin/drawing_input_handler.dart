import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// Import the DrawingBoardComponent itself to call methods
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/form_line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

mixin DrawingInputHandler on TacticBoardGame {
  // TacticBoardGame should have drawingBoard instance
  Vector2? lineStartPoint; // For straight lines
  LineDrawerComponentV2? _currentStraightLine; // Renamed for clarity

  // --- Centralized Drag Handlers ---

  @override
  void onDragStart(DragStartEvent event) {
    final lp = ref.read(lineProvider);
    bool eventHandled = false;

    // --- Priority 1: Free Draw / Erase / Move (Delegate to Component) ---
    // Check if the component exists and if the event is within its bounds
    // Note: Assumes 'drawingBoard' is accessible via TacticBoardGame or ItemManagement mixin
    if (this.contains(drawingBoard) &&
        drawingBoard.containsLocalPoint(event.localPosition)) {
      // Check component's internal state via getter/tool state
      final tool = drawingBoard.currentTool;
      final isSelected = drawingBoard.isLineSelected;

      if (tool == DrawingTool.draw ||
          tool == DrawingTool.erase ||
          (tool == null && isSelected)) {
        // Let the component handle it
        eventHandled = drawingBoard.handleDragStart(event);
      }
    }

    // --- Priority 2: Straight Line Drawing ---
    if (!eventHandled && lp.isLineActiveToAddIntoGameField) {
      lineStartPoint = event.localPosition;
      LineModelV2? lineModelV2 = lp.activatedLineForm;
      if (lineModelV2 != null) {
        lineModelV2 = lineModelV2.copyWith(
          start: SizeHelper.getBoardRelativeVector(
            gameScreenSize: gameField.size,
            actualPosition: lineStartPoint!,
          ),
          end: SizeHelper.getBoardRelativeVector(
            gameScreenSize: gameField.size,
            actualPosition: lineStartPoint!,
          ),
        );
        _currentStraightLine = LineDrawerComponentV2(lineModelV2: lineModelV2);
        add(_currentStraightLine!);
        eventHandled = true; // Mark as handled
      }
    }

    // --- If not handled, call super ---
    if (!eventHandled) {
      super.onDragStart(event);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final lp = ref.read(lineProvider);
    bool eventHandled = false;

    // --- Priority 1: Free Draw / Erase / Move (Delegate to Component) ---
    // Check component's internal state (isMoving, isDrawing/Erasing)
    if (drawingBoard.currentTool != null || drawingBoard.isMovingLine) {
      // Access internal state needed or add getter
      // Let the component handle it, assuming it only returns true if active
      eventHandled = drawingBoard.handleDragUpdate(event);
    }

    // --- Priority 2: Straight Line Drawing ---
    if (!eventHandled &&
        lp.isLineActiveToAddIntoGameField &&
        lineStartPoint != null &&
        _currentStraightLine != null) {
      final currentPoint = event.localStartPosition;
      _currentStraightLine!.updateEnd(currentPoint);
      _currentStraightLine!.updateLine();
      eventHandled = true;
    }

    // --- If not handled, call super ---
    if (!eventHandled) {
      super.onDragUpdate(event);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    final lp = ref.read(lineProvider);
    bool eventHandled = false;

    // --- Priority 1: Free Draw / Erase / Move (Delegate to Component) ---
    if (drawingBoard.currentTool != null || drawingBoard.isMovingLine) {
      eventHandled = drawingBoard.handleDragEnd(event);
      // Reset component's internal moving state is handled within handleDragEnd now
    }

    // --- Priority 2: Straight Line Drawing ---
    if (!eventHandled &&
        lp.isLineActiveToAddIntoGameField &&
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

    // --- If not handled, call super ---
    if (!eventHandled) {
      super.onDragEnd(event);
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    final lp = ref.read(lineProvider);
    bool eventHandled = false;

    // --- Priority 1: Free Draw / Erase / Move (Delegate to Component) ---
    if (drawingBoard.currentTool != null || drawingBoard.isMovingLine) {
      eventHandled = drawingBoard.handleDragCancel(event);
    }

    // --- Priority 2: Straight Line Drawing ---
    // Use _currentStraightLine to check if we were drawing one
    if (!eventHandled && _currentStraightLine != null) {
      remove(_currentStraightLine!);
      _currentStraightLine = null;
      lineStartPoint = null;
      // Reset provider state if the cancelled line was the active one
      if (lp.isLineActiveToAddIntoGameField && lp.activatedLineForm != null) {
        ref
            .read(lineProvider.notifier)
            .unLoadActiveLineModelToAddIntoGameFieldEvent(
              line: lp.activatedLineForm!,
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
