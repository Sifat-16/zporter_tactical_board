import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart';

final lineProvider = StateNotifierProvider<LineController, LineState>(
  (ref) => LineController(ref),
);

class LineController extends StateNotifier<LineState> {
  LineController(this.ref)
      : super(
          const LineState(activeTool: ActiveTool.pointer),
        ); // Default to pointer

  final Ref ref;

  void setActiveTool(ActiveTool newTool) {
    // If tapping the currently active tool (that isn't pointer), deactivate it and switch to pointer.
    if (state.activeTool == newTool && newTool != ActiveTool.pointer) {
      state = state.copyWith(
        activeTool: ActiveTool.pointer,
        isFreeDrawingActive: false,
        isEraserActivated: false,
        isTrashActive: false,
        activeForm: null, // Clear form when deactivating a specific tool
        activatedFormId: null,
        isLineActiveToAddIntoGameField: false, // Reset these flags
        isShapeActiveToAddIntoGameField: false,
      );
      return;
    }
    // If trying to activate the same tool that's already active (and it's not the toggle case above), do nothing.
    if (state.activeTool == newTool) {
      return;
    }

    // When switching to a new tool, generally clear any active form unless
    // the new tool is pointer AND an item is already meant to be placed by the pointer.
    // The `isLineActiveToAddIntoGameField` or `isShapeActiveToAddIntoGameField` flags
    // along with `activeForm` indicate this specific "pointer-for-placement" state.
    bool preserveActiveFormForPointerPlacement =
        newTool == ActiveTool.pointer &&
            state.activeForm != null &&
            (state.isLineActiveToAddIntoGameField ||
                state.isShapeActiveToAddIntoGameField);

    state = state.copyWith(
      activeTool: newTool,
      // Boolean flags are now directly derived from activeTool
      isFreeDrawingActive: newTool == ActiveTool.freeDraw,
      isEraserActivated: newTool == ActiveTool.eraser,
      isTrashActive: newTool == ActiveTool.trash,
      // Manage activeForm and related flags
      activeForm:
          preserveActiveFormForPointerPlacement ? state.activeForm : null,
      activatedFormId:
          preserveActiveFormForPointerPlacement ? state.activatedFormId : null,
      isLineActiveToAddIntoGameField: preserveActiveFormForPointerPlacement &&
          state.isLineActiveToAddIntoGameField,
      isShapeActiveToAddIntoGameField: preserveActiveFormForPointerPlacement &&
          state.isShapeActiveToAddIntoGameField,
    );
    zlog(
      data:
          "Set active tool to: $newTool. Current form: ${state.activeForm?.id}",
    );
  }

  // --- Methods for selecting an item from the grid to add to the field ---
  // These methods set up the state for the "pointer" tool to place the selected item.
  void loadActiveLineModelToAddIntoGameFieldEvent({
    required LineModelV2 lineModelV2,
  }) {
    zlog(data: "Came here to add line");
    LineModelV2 newLine = lineModelV2.clone();
    newLine.id = RandomGenerator.generateId();
    state = state.copyWith(
      activeTool: ActiveTool.pointer, // Pointer tool will be used for placement
      isLineActiveToAddIntoGameField:
          true, // Mark that a line is ready for placement
      activeForm: newLine,
      activeId: lineModelV2.id,
      activatedFormId: newLine.id,
      isFreeDrawingActive: false,
      isEraserActivated: false,
      isTrashActive: false,
      isShapeActiveToAddIntoGameField: false,
    );
    zlog(data: "Loaded line ${newLine.id} to add with pointer tool.");
  }

  void loadActiveShapeModelToAddIntoGameFieldEvent({
    required ShapeModel shapeModel,
  }) {
    ShapeModel newShape = shapeModel.clone();
    newShape.id = RandomGenerator.generateId();
    state = state.copyWith(
      activeTool: ActiveTool.pointer, // Pointer tool for placement
      isShapeActiveToAddIntoGameField:
          true, // Mark that a shape is ready for placement
      activeForm: newShape,
      activatedFormId: newShape.id,
      // Reset other tool states
      isFreeDrawingActive: false,
      isEraserActivated: false,
      isTrashActive: false,
      activeId: shapeModel.id,
      isLineActiveToAddIntoGameField: false,
    );
    zlog(data: "Loaded shape ${newShape.id} to add with pointer tool.");
  }

  // --- Methods for direct tool toggling ---
  void toggleFreeDraw() {
    setActiveTool(ActiveTool.freeDraw);
  }

  void toggleEraser() {
    setActiveTool(ActiveTool.eraser);
  }

  void toggleTrash() {
    setActiveTool(ActiveTool.trash);
  }

  // --- Dismissing active items/forms (e.g., user cancels adding an item) ---
  void dismissActiveFormItem() {
    // This action reverts to the basic pointer tool, clearing any item that was ready for placement.
    state = state.copyWith(
      activeTool: ActiveTool.pointer,
      isLineActiveToAddIntoGameField: false,
      isShapeActiveToAddIntoGameField: false,
      activeForm: null,
      activeId: null,
      activatedFormId: null,
      // The specific tool flags (freeDraw, eraser, trash) should already be false
      // if an item was being placed, as placing an item implies pointer tool.
      // If not, setActiveTool(ActiveTool.pointer) handles resetting them.
      isFreeDrawingActive: false,
      isEraserActivated: false,
      // isTrashActive is managed by its own toggle and setActiveTool logic.
    );
    zlog(
      data: "Dismissed active form item. Tool set to pointer, form cleared.",
    );
  }

  // --- Methods called when an item has been successfully added/drawn on the board ---
  // These should also reset the state, typically back to the idle pointer tool.

  void unLoadActiveLineModelToAddIntoGameFieldEvent({
    required LineModelV2 line,
  }) {
    // This method is called AFTER a line (activeForm) has been drawn/committed.
    // You might add it to a list of drawn lines elsewhere.
    // Here, we reset the state for adding a new line.
    List<LineModelV2> lines = List.from(state.availableLines)
      ..add(line); // Example: adding to a list
    state = state.copyWith(
      availableLines: lines,
      activeId: null,
      activeTool: ActiveTool.pointer, // Revert to pointer tool
      isLineActiveToAddIntoGameField:
          false, // No longer actively adding this specific line
      activeForm: null, // Clear the completed form
      activatedFormId: null,
    );
    zlog(data: "Unloaded/Committed line ${line.id}. State reset.");
  }

  void unLoadActiveFreeDrawModelToAddIntoGameFieldEvent({
    required FreeDrawModelV2 freeDraw,
  }) {
    // Called AFTER a free draw session is completed and the drawing is on the board.
    List<FreeDrawModelV2> freeDraws = List.from(state.availableFreeDraws)
      ..add(freeDraw); // Example
    state = state.copyWith(
      availableFreeDraws: freeDraws,

      activeTool:
          ActiveTool.pointer, // Revert to pointer after free draw completion
      isFreeDrawingActive: false, // Free draw session ends
      // activeForm for free draw is typically null or a temporary path, clear it.
      activeForm: null,
      activatedFormId: null,
    );
    zlog(data: "Unloaded/Committed free draw. State reset.");
  }

  void unLoadActiveShapeModelToAddIntoGameFieldEvent({
    required ShapeModel shape,
  }) {
    // Called AFTER a shape (activeForm) has been drawn/committed.
    // Example: add to a list of drawn shapes, not explicitly done here.
    state = state.copyWith(
        activeTool: ActiveTool.pointer, // Revert to pointer
        isShapeActiveToAddIntoGameField:
            false, // No longer actively adding this specific shape
        activeForm: null, // Clear the completed form
        activatedFormId: null,
        activeId: null);
    zlog(data: "Unloaded/Committed shape ${shape.id}. State reset.");
  }
}
