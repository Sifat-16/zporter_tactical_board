// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/generator/random_generator.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart';
//
// final lineProvider = StateNotifierProvider<LineController, LineState>(
//   (ref) => LineController(ref),
// );
//
// class LineController extends StateNotifier<LineState> {
//   LineController(this.ref) : super(LineState());
//
//   Ref ref;
//
//   void setActiveTool(ActiveTool? newTool) {
//     state = state.copyWith(activeTool: newTool);
//
//     // if (state.activeTool == newTool && newTool != ActiveTool.pointer) {
//     //   state = state.copyWith(
//     //     activeTool: ActiveTool.pointer,
//     //     isFreeDrawingActive: false,
//     //     isEraserActivated: false,
//     //     isTrashActive: false,
//     //     activeForm: null,
//     //     activatedFormId: null,
//     //     isLineActiveToAddIntoGameField: false,
//     //     isShapeActiveToAddIntoGameField: false,
//     //   );
//     //   return;
//     // }
//     // // If trying to activate the same tool that's already active, do nothing.
//     // // (Except for the toggle case above for non-pointer tools)
//     // if (state.activeTool == newTool) {
//     //   return;
//     // }
//     //
//     // state = state.copyWith(
//     //   activeTool: newTool,
//     //   isFreeDrawingActive: newTool == ActiveTool.freeDraw,
//     //   isEraserActivated: newTool == ActiveTool.eraser,
//     //   isTrashActive: newTool == ActiveTool.trash,
//     //   // When a tool (not pointer for item placement) is selected, clear any active form.
//     //   activeForm:
//     //       (newTool == ActiveTool.pointer && state.activeForm != null)
//     //           ? state.activeForm
//     //           : null,
//     //   activatedFormId:
//     //       (newTool == ActiveTool.pointer && state.activeForm != null)
//     //           ? state.activatedFormId
//     //           : null,
//     //   isLineActiveToAddIntoGameField:
//     //       (newTool == ActiveTool.pointer &&
//     //           state
//     //               .isLineActiveToAddIntoGameField), // Preserve if pointer is for placement
//     //   isShapeActiveToAddIntoGameField:
//     //       (newTool == ActiveTool.pointer &&
//     //           state
//     //               .isShapeActiveToAddIntoGameField), // Preserve if pointer is for placement
//     // );
//   }
//
//   loadActiveLineModelToAddIntoGameFieldEvent({
//     required LineModelV2 lineModelV2,
//   }) {
//     LineModelV2 newLine = lineModelV2.clone();
//     newLine.id = RandomGenerator.generateId();
//     state = state.copyWith(
//       activeTool: ActiveTool.pointer,
//       // isLineActiveToAddIntoGameField: true,
//       activeForm: newLine,
//       activatedFormId: newLine.id,
//       // isFreeDrawingActive: (formModel.formItemModel is FreeDrawModel),
//     );
//   }
//
//   void dismissActiveFormItem() {
//     state = state.copyWith(
//       activeTool: null,
//       // isLineActiveToAddIntoGameField: false,
//       // isShapeActiveToAddIntoGameField: false, // Reset shape flag too
//       // isFreeDrawingActive: false,
//       // isEraserActivated: false, // Also turn off eraser if dismissing
//       activeForm: null,
//       activatedFormId: null, // Use generic ID field
//     );
//     zlog(data: "Dismissed active form item.");
//   }
//
//   // dismissActiveLineModelToAddIntoGameFieldEvent() {
//   //   state = state.copyWith(
//   //     isLineActiveToAddIntoGameField: false,
//   //     activeForm: null,
//   //     isFreeDrawingActive: false,
//   //   );
//   // }
//
//   unLoadActiveLineModelToAddIntoGameFieldEvent({required LineModelV2 line}) {
//     List<LineModelV2> lines = state.availableLines;
//     try {
//       lines.add(line);
//       zlog(data: "Problem adding unloaded forms ${line.runtimeType}");
//     } catch (e) {}
//     state = state.copyWith(
//       activeTool: null,
//       // isLineActiveToAddIntoGameField: false,
//       availableLines: lines,
//       activeForm: null,
//       activatedFormId: null,
//     );
//   }
//
//   void toggleEraser() {
//     bool isEraserActivated = state.activeTool == ActiveTool.eraser;
//     zlog(data: "Is eraser activated ${isEraserActivated}");
//
//     if (isEraserActivated) {
//       state = state.copyWith(activeTool: null);
//     } else {
//       dismissActiveFormItem();
//       state = state.copyWith(activeTool: ActiveTool.eraser);
//     }
//   }
//
//   void loadActiveFreeDrawModelToAddIntoGameFieldEvent() {
//     state = state.copyWith(
//       // isLineActiveToAddIntoGameField: false,
//       activeTool: ActiveTool.freeDraw,
//       activeForm: null,
//       activatedFormId: null,
//       // isFreeDrawingActive: true,
//       // isFreeDrawingActive: (formModel.formItemModel is FreeDrawModel),
//     );
//   }
//
//   void unLoadActiveFreeDrawModelToAddIntoGameFieldEvent({
//     required FreeDrawModelV2 freeDraw,
//   }) {
//     List<FreeDrawModelV2> freeDraws = state.availableFreeDraws;
//     try {
//       freeDraws.add(freeDraw);
//       zlog(data: "Problem adding unloaded forms ${freeDraw.runtimeType}");
//     } catch (e) {}
//     state = state.copyWith(
//       activeTool: null,
//       // isLineActiveToAddIntoGameField: false,
//       activeForm: null,
//       activatedFormId: null,
//       // isFreeDrawingActive: false,
//       availableFreeDraws: freeDraws,
//       // isFreeDrawingActive: (formModel.formItemModel is FreeDrawModel),
//     );
//   }
//
//   void loadActiveShapeModelToAddIntoGameFieldEvent({
//     required ShapeModel shapeModel,
//   }) {
//     zlog(data: "Loaded the shape model here ${shapeModel.runtimeType}");
//     dismissActiveFormItem();
//
//     ShapeModel newShape = shapeModel.clone(); // Assuming ShapeModel has clone()
//     newShape.id = RandomGenerator.generateId(); // Ensure unique ID
//     state = state.copyWith(
//       // isShapeActiveToAddIntoGameField: true, // Set shape flag
//       activeTool: ActiveTool.pointer,
//       activeForm: newShape, // Set generic form
//       activatedFormId: newShape.id, // Set generic ID
//     );
//     zlog(data: "Loaded active Shape: ${newShape.id}");
//   }
//
//   /// Call this when a shape drawing is completed and added to the board
//   void unLoadActiveShapeModelToAddIntoGameFieldEvent({
//     required ShapeModel shape,
//   }) {
//     dismissActiveFormItem();
//   }
//
//   void toggleTrash() {
//     bool isActive = state.activeTool == ActiveTool.trash;
//     if (isActive) {
//       state = state.copyWith(activeTool: null);
//     } else {
//       state = state.copyWith(
//         activeTool: ActiveTool.trash,
//         // isTrashActive: true,
//         // isFreeDrawingActive: false,
//         // isShapeActiveToAddIntoGameField: false,
//         // isEraserActivated: false,
//         // isLineActiveToAddIntoGameField: false,
//       );
//     }
//   }
//
//   void toggleFreeDraw() {
//     bool isActive = state.activeTool == ActiveTool.freeDraw;
//     if (isActive) {
//       state = state.copyWith(activeTool: null);
//     } else {
//       state = state.copyWith(
//         activeTool: ActiveTool.trash,
//         // isTrashActive: true,
//         // isFreeDrawingActive: false,
//         // isShapeActiveToAddIntoGameField: false,
//         // isEraserActivated: false,
//         // isLineActiveToAddIntoGameField: false,
//       );
//     }
//   }
// }

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
      isLineActiveToAddIntoGameField:
          preserveActiveFormForPointerPlacement &&
          state.isLineActiveToAddIntoGameField,
      isShapeActiveToAddIntoGameField:
          preserveActiveFormForPointerPlacement &&
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
    LineModelV2 newLine = lineModelV2.clone();
    newLine.id = RandomGenerator.generateId();
    state = state.copyWith(
      activeTool: ActiveTool.pointer, // Pointer tool will be used for placement
      isLineActiveToAddIntoGameField:
          true, // Mark that a line is ready for placement
      activeForm: newLine,
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
    );
    zlog(data: "Unloaded/Committed shape ${shape.id}. State reset.");
  }
}
