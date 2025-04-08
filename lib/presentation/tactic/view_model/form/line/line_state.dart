import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';

const Object _sentinel = Object();

class LineState {
  final List<LineModelV2> availableLines;
  final List<FreeDrawModelV2> availableFreeDraws;
  final bool isLineActiveToAddIntoGameField;
  final LineModelV2? activatedLineForm;
  final bool isFreeDrawingActive;
  final String? activatedLineId;

  final bool isEraserActivated;

  const LineState({
    this.availableLines = const [],
    this.availableFreeDraws = const [],
    this.isLineActiveToAddIntoGameField = false,
    this.activatedLineForm,
    this.isFreeDrawingActive = false,
    this.activatedLineId,
    this.isEraserActivated = false,
  });

  LineState copyWith({
    List<LineModelV2>? availableLines,
    List<FreeDrawModelV2>? availableFreeDraws,
    bool? isLineActiveToAddIntoGameField,
    Object? activatedLineForm = _sentinel,
    bool? isFreeDrawingActive,
    Object? activatedLineId = _sentinel,
    bool? isEraserActivated,
  }) {
    return LineState(
      availableLines: availableLines ?? this.availableLines,
      availableFreeDraws: availableFreeDraws ?? this.availableFreeDraws,
      isLineActiveToAddIntoGameField:
          isLineActiveToAddIntoGameField ?? this.isLineActiveToAddIntoGameField,
      activatedLineForm:
          activatedLineForm == _sentinel
              ? this.activatedLineForm
              : activatedLineForm as LineModelV2?,

      isFreeDrawingActive: isFreeDrawingActive ?? this.isFreeDrawingActive,
      activatedLineId:
          activatedLineId == _sentinel
              ? this.activatedLineId
              : activatedLineId as String?,
      isEraserActivated: isEraserActivated ?? this.isEraserActivated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // Use listEquals for comparing lists
    return other is LineState &&
        runtimeType == other.runtimeType &&
        activatedLineId == other.activatedLineId;
  }

  @override
  // TODO: implement hashCode
  int get hashCode {
    return Object.hash(activatedLineId, activatedLineForm);
  }
}
