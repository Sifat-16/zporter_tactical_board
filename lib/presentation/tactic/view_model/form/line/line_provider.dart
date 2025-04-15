import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
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
      activatedLineForm: newLine,
      activatedLineId: newLine.id,
      // isFreeDrawingActive: (formModel.formItemModel is FreeDrawModel),
    );
  }

  dismissActiveLineModelToAddIntoGameFieldEvent() {
    state = state.copyWith(
      isLineActiveToAddIntoGameField: false,
      activatedLineForm: null,
      isFreeDrawingActive: false,
    );
  }

  unLoadActiveLineModelToAddIntoGameFieldEvent({required LineModelV2 line}) {
    List<LineModelV2> lines = state.availableLines;
    try {
      lines.add(line);
      zlog(data: "Problem adding unloaded forms ${line.runtimeType}");
    } catch (e) {}
    state = state.copyWith(
      isLineActiveToAddIntoGameField: false,
      availableLines: lines,
      activatedLineForm: null,
      activatedLineId: null,
      // activatedLineForm: null,
      // isFreeDrawingActive: false,
    );
  }

  void toggleEraser() {
    bool isEraserActivated = state.isEraserActivated;
    zlog(data: "Is eraser activated ${isEraserActivated}");

    if (isEraserActivated) {
      state = state.copyWith(isEraserActivated: false);
    } else {
      dismissActiveLineModelToAddIntoGameFieldEvent();
      state = state.copyWith(isEraserActivated: true);
    }
  }

  void loadActiveFreeDrawModelToAddIntoGameFieldEvent() {
    state = state.copyWith(
      isLineActiveToAddIntoGameField: false,
      activatedLineForm: null,
      activatedLineId: null,
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
      activatedLineForm: null,
      activatedLineId: null,
      isFreeDrawingActive: false,
      availableFreeDraws: freeDraws,
      // isFreeDrawingActive: (formModel.formItemModel is FreeDrawModel),
    );
  }
}
