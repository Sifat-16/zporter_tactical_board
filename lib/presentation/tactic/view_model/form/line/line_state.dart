import 'package:equatable/equatable.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';

class LineState extends Equatable {
  final List<FormModel> availableLineForms;
  final bool isLineActiveToAddIntoGameField;
  final FormModel? activatedLineForm;

  const LineState({
    this.availableLineForms = const [],
    this.isLineActiveToAddIntoGameField = false,
    this.activatedLineForm,
  });

  LineState copyWith({
    List<FormModel>? availableLineForms,
    bool? isLineActiveToAddIntoGameField,
    FormModel? activatedLineForm,
    bool forceNullActivatedLine = false,
  }) {
    return LineState(
      availableLineForms: availableLineForms ?? this.availableLineForms,
      isLineActiveToAddIntoGameField:
          isLineActiveToAddIntoGameField ?? this.isLineActiveToAddIntoGameField,
      activatedLineForm:
          forceNullActivatedLine == true
              ? null
              : activatedLineForm ?? this.activatedLineForm,
    );
  }

  @override
  List<Object?> get props => [
    availableLineForms,
    isLineActiveToAddIntoGameField,
    activatedLineForm,
  ];
}
