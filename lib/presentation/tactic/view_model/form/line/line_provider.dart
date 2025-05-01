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
  LineController(this.ref) : super(LineState());

  Ref ref;

  loadActiveLineModelToAddIntoGameFieldEvent({
    required LineModelV2 lineModelV2,
  }) {
    LineModelV2 newLine = lineModelV2.clone();
    newLine.id = RandomGenerator.generateId();
    state = state.copyWith(
      isLineActiveToAddIntoGameField: true,
      activeForm: newLine,
      activatedFormId: newLine.id,
      // isFreeDrawingActive: (formModel.formItemModel is FreeDrawModel),
    );
  }

  void dismissActiveFormItem() {
    state = state.copyWith(
      isLineActiveToAddIntoGameField: false,
      isShapeActiveToAddIntoGameField: false, // Reset shape flag too
      isFreeDrawingActive: false,
      isEraserActivated: false, // Also turn off eraser if dismissing
      activeForm: null,
      activatedFormId: null, // Use generic ID field
    );
    zlog(data: "Dismissed active form item.");
  }

  // dismissActiveLineModelToAddIntoGameFieldEvent() {
  //   state = state.copyWith(
  //     isLineActiveToAddIntoGameField: false,
  //     activeForm: null,
  //     isFreeDrawingActive: false,
  //   );
  // }

  unLoadActiveLineModelToAddIntoGameFieldEvent({required LineModelV2 line}) {
    List<LineModelV2> lines = state.availableLines;
    try {
      lines.add(line);
      zlog(data: "Problem adding unloaded forms ${line.runtimeType}");
    } catch (e) {}
    state = state.copyWith(
      isLineActiveToAddIntoGameField: false,
      availableLines: lines,
      activeForm: null,
      activatedFormId: null,
    );
  }

  void toggleEraser() {
    bool isEraserActivated = state.isEraserActivated;
    zlog(data: "Is eraser activated ${isEraserActivated}");

    if (isEraserActivated) {
      state = state.copyWith(isEraserActivated: false);
    } else {
      dismissActiveFormItem();
      state = state.copyWith(isEraserActivated: true);
    }
  }

  void loadActiveFreeDrawModelToAddIntoGameFieldEvent() {
    state = state.copyWith(
      isLineActiveToAddIntoGameField: false,
      activeForm: null,
      activatedFormId: null,
      isFreeDrawingActive: true,
      // isFreeDrawingActive: (formModel.formItemModel is FreeDrawModel),
    );
  }

  void unLoadActiveFreeDrawModelToAddIntoGameFieldEvent({
    required FreeDrawModelV2 freeDraw,
  }) {
    List<FreeDrawModelV2> freeDraws = state.availableFreeDraws;
    try {
      freeDraws.add(freeDraw);
      zlog(data: "Problem adding unloaded forms ${freeDraw.runtimeType}");
    } catch (e) {}
    state = state.copyWith(
      isLineActiveToAddIntoGameField: false,
      activeForm: null,
      activatedFormId: null,
      isFreeDrawingActive: false,
      availableFreeDraws: freeDraws,
      // isFreeDrawingActive: (formModel.formItemModel is FreeDrawModel),
    );
  }

  void loadActiveShapeModelToAddIntoGameFieldEvent({
    required ShapeModel shapeModel,
  }) {
    dismissActiveFormItem();

    ShapeModel newShape = shapeModel.clone(); // Assuming ShapeModel has clone()
    newShape.id = RandomGenerator.generateId(); // Ensure unique ID
    state = state.copyWith(
      isShapeActiveToAddIntoGameField: true, // Set shape flag
      activeForm: newShape, // Set generic form
      activatedFormId: newShape.id, // Set generic ID
    );
    zlog(data: "Loaded active Shape: ${newShape.id}");
  }

  /// Call this when a shape drawing is completed and added to the board
  void unLoadActiveShapeModelToAddIntoGameFieldEvent({
    required ShapeModel shape,
  }) {
    dismissActiveFormItem();
  }

  void toggleTrash() {
    bool isActive = state.isTrashActive;
    if (isActive) {
      state = state.copyWith(isTrashActive: false);
    } else {
      state = state.copyWith(
        isTrashActive: true,
        isFreeDrawingActive: false,
        isShapeActiveToAddIntoGameField: false,
        isEraserActivated: false,
        isLineActiveToAddIntoGameField: false,
      );
    }
  }
}
