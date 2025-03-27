import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    state = state.copyWith(
      isLineActiveToAddIntoGameField: true,
      activatedLineForm: formModel,
      isFreeDrawingActive: (formModel.formItemModel is FreeDrawModel),
    );
  }

  dismissActiveLineModelToAddIntoGameFieldEvent() {
    state = state.copyWith(
      isLineActiveToAddIntoGameField: false,
      forceNullActivatedLine: true,
      isFreeDrawingActive: false,
    );
  }

  unLoadActiveLineModelToAddIntoGameFieldEvent({required FormModel formModel}) {
    List<FormModel> forms = state.availableLineForms;
    try {
      forms.add(formModel);
    } catch (e) {
      zlog(data: "Problem adding unloaded forms ${e}");
    }

    state = state.copyWith(
      isLineActiveToAddIntoGameField: false,
      availableLineForms: forms,
      forceNullActivatedLine: true,
      isFreeDrawingActive: false,
    );
  }
}
