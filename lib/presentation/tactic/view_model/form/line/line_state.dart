import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';

const Object _sentinel = Object();

class LineState {
  final List<LineModelV2> availableLines;
  final List<FreeDrawModelV2> availableFreeDraws;
  final bool isLineActiveToAddIntoGameField;
  final bool isShapeActiveToAddIntoGameField;
  final FieldItemModel? activeForm;
  final bool isFreeDrawingActive;
  final String? activatedFormId;

  final bool isEraserActivated;

  const LineState({
    this.availableLines = const [],
    this.availableFreeDraws = const [],
    this.isLineActiveToAddIntoGameField = false,
    this.activeForm,
    this.isFreeDrawingActive = false,
    this.activatedFormId,
    this.isEraserActivated = false,
    this.isShapeActiveToAddIntoGameField = false,
  });

  LineState copyWith({
    List<LineModelV2>? availableLines,
    List<FreeDrawModelV2>? availableFreeDraws,
    bool? isLineActiveToAddIntoGameField,
    Object? activeForm = _sentinel,
    bool? isFreeDrawingActive,
    Object? activatedFormId = _sentinel,
    bool? isEraserActivated,
    bool? isShapeActiveToAddIntoGameField,
  }) {
    return LineState(
      availableLines: availableLines ?? this.availableLines,
      availableFreeDraws: availableFreeDraws ?? this.availableFreeDraws,
      isLineActiveToAddIntoGameField:
          isLineActiveToAddIntoGameField ?? this.isLineActiveToAddIntoGameField,
      activeForm:
          activeForm == _sentinel
              ? this.activeForm
              : activeForm as FieldItemModel?,

      isFreeDrawingActive: isFreeDrawingActive ?? this.isFreeDrawingActive,
      activatedFormId:
          activatedFormId == _sentinel
              ? this.activatedFormId
              : activatedFormId as String?,
      isEraserActivated: isEraserActivated ?? this.isEraserActivated,
      isShapeActiveToAddIntoGameField:
          isShapeActiveToAddIntoGameField ??
          this.isShapeActiveToAddIntoGameField,
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
    return Object.hash(activatedFormId, activeForm);
  }
}
