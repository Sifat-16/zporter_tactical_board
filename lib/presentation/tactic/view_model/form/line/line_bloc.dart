import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_event.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart';

class LineBloc extends Bloc<LineEvent, LineState> {
  LineBloc() : super(LineState()) {
    on<LoadActiveLineModelToAddIntoGameFieldEvent>(
      _loadActiveLineModelToAddIntoGameFieldEvent,
    );

    on<DismissActiveLineModelToAddIntoGameFieldEvent>(
      _dismissActiveLineModelToAddIntoGameFieldEvent,
    );

    on<UnLoadActiveLineModelToAddIntoGameFieldEvent>(
      _unLoadActiveLineModelToAddIntoGameFieldEvent,
    );
  }

  FutureOr<void> _loadActiveLineModelToAddIntoGameFieldEvent(
    LoadActiveLineModelToAddIntoGameFieldEvent event,
    Emitter<LineState> emit,
  ) {
    emit(
      state.copyWith(
        isLineActiveToAddIntoGameField: true,
        activatedLineForm: event.formModel,
      ),
    );
  }

  FutureOr<void> _dismissActiveLineModelToAddIntoGameFieldEvent(
    DismissActiveLineModelToAddIntoGameFieldEvent event,
    Emitter<LineState> emit,
  ) {
    emit(
      state.copyWith(
        isLineActiveToAddIntoGameField: false,
        forceNullActivatedLine: true,
      ),
    );
  }

  FutureOr<void> _unLoadActiveLineModelToAddIntoGameFieldEvent(
    UnLoadActiveLineModelToAddIntoGameFieldEvent event,
    Emitter<LineState> emit,
  ) {
    List<FormModel> forms = state.availableLineForms;
    try {
      forms.add(event.formModel);
    } catch (e) {
      zlog(data: "Problem adding unloaded forms ${e}");
    }

    emit(
      state.copyWith(
        isLineActiveToAddIntoGameField: false,
        availableLineForms: forms,
        forceNullActivatedLine: true,
      ),
    );
  }
}
