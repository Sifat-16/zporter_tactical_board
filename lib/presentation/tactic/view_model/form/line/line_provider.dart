import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart';

final lineProvider = StateNotifierProvider<LineController, LineState>(
  (ref) => LineController(ref),
);

class LineController extends StateNotifier<LineState> {
  LineController(this.ref) : super(LineState());

  Ref ref;

  loadActiveLineModelToAddIntoGameFieldEvent({required FormModel formModel}) {
    FormModel newForm = formModel.clone();
    newForm.id = RandomGenerator.generateId();
    state = state.copyWith(
      isLineActiveToAddIntoGameField: true,
      activatedLineForm: newForm,
      activatedFormId: formModel.id,
      isFreeDrawingActive: (formModel.formItemModel is FreeDrawModel),
    );
  }

  dismissActiveLineModelToAddIntoGameFieldEvent() {
    state = state.copyWith(
      isLineActiveToAddIntoGameField: false,
      activatedLineForm: null,
      isFreeDrawingActive: false,
    );
  }

  unLoadActiveLineModelToAddIntoGameFieldEvent({required FormModel formModel}) {
    List<FormModel> forms = state.availableLineForms;
    try {
      forms.add(formModel);
      zlog(
        data:
            "Problem adding unloaded forms ${formModel.formItemModel.runtimeType}",
      );
    } catch (e) {}

    // FormModel newForm = formModel.copyWith(formItemModel: null);
    // newForm.id = RandomGenerator.generateId();
    // FormItemModel? formItemModel = newForm.formItemModel?.clone();
    //
    // if (formItemModel is LineModel) {
    //   formItemModel.start = Vector2.zero();
    //   formItemModel.end = Vector2.zero();
    //   newForm.formItemModel = formItemModel;
    //
    //   zlog(
    //     data:
    //         "Activated new lineform ${(newForm.formItemModel as LineModel).start} - ${(newForm.formItemModel as LineModel).end}",
    //   );
    // }

    state = state.copyWith(
      isLineActiveToAddIntoGameField: false,
      availableLineForms: forms,
      activatedLineForm: null,
      activatedFormId: null,
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
}
