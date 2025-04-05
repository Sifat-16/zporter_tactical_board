import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';

class LineState {
  final List<FormModel> availableLineForms;
  final bool isLineActiveToAddIntoGameField;
  final FormModel? activatedLineForm;
  final bool isFreeDrawingActive;

  const LineState({
    this.availableLineForms = const [],
    this.isLineActiveToAddIntoGameField = false,
    this.activatedLineForm,
    this.isFreeDrawingActive = false,
  });

  LineState copyWith({
    List<FormModel>? availableLineForms,
    bool? isLineActiveToAddIntoGameField,
    FormModel? activatedLineForm,
    bool forceNullActivatedLine = false,
    bool? isFreeDrawingActive,
  }) {
    return LineState(
      availableLineForms: availableLineForms ?? this.availableLineForms,
      isLineActiveToAddIntoGameField:
          isLineActiveToAddIntoGameField ?? this.isLineActiveToAddIntoGameField,
      activatedLineForm:
          forceNullActivatedLine == true
              ? null
              : activatedLineForm ?? this.activatedLineForm,
      isFreeDrawingActive: isFreeDrawingActive ?? this.isFreeDrawingActive,
    );
  }

  @override
  List<Object?> get props => [
    availableLineForms,
    isLineActiveToAddIntoGameField,
    activatedLineForm,
  ];
}
