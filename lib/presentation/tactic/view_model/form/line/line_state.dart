import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';

const Object _sentinel = Object();

class LineState {
  final List<FormModel> availableLineForms;
  final bool isLineActiveToAddIntoGameField;
  final FormModel? activatedLineForm;
  final bool isFreeDrawingActive;
  final String? activatedFormId;

  final bool isEraserActivated;

  const LineState({
    this.availableLineForms = const [],
    this.isLineActiveToAddIntoGameField = false,
    this.activatedLineForm,
    this.isFreeDrawingActive = false,
    this.activatedFormId,
    this.isEraserActivated = false,
  });

  LineState copyWith({
    List<FormModel>? availableLineForms,
    bool? isLineActiveToAddIntoGameField,
    Object? activatedLineForm = _sentinel,
    bool? isFreeDrawingActive,
    Object? activatedFormId = _sentinel,
    bool? isEraserActivated,
  }) {
    return LineState(
      availableLineForms: availableLineForms ?? this.availableLineForms,
      isLineActiveToAddIntoGameField:
          isLineActiveToAddIntoGameField ?? this.isLineActiveToAddIntoGameField,
      activatedLineForm:
          activatedLineForm == _sentinel
              ? this.activatedLineForm
              : activatedLineForm as FormModel?,

      isFreeDrawingActive: isFreeDrawingActive ?? this.isFreeDrawingActive,
      activatedFormId:
          activatedFormId == _sentinel
              ? this.activatedFormId
              : activatedFormId as String?,
      isEraserActivated: isEraserActivated ?? this.isEraserActivated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // Use listEquals for comparing lists
    return other is LineState &&
        runtimeType == other.runtimeType &&
        activatedFormId == other.activatedFormId;
  }

  @override
  // TODO: implement hashCode
  int get hashCode {
    return Object.hash(activatedFormId, activatedLineForm);
  }
}
