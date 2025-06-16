import 'package:flutter/foundation.dart'; // For listEquals if you compare lists of complex objects
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';

// Define ActiveTool enum here or ensure it's imported if defined elsewhere
enum ActiveTool {
  pointer,
  freeDraw,
  eraser,
  trash,
  // Add more tools if needed, e.g., specific shape tools, text tool
}

const Object _sentinel = Object();

class LineState {
  final List<LineModelV2> availableLines;
  final List<FreeDrawModelV2> availableFreeDraws;
  // Flags indicating if a specific item type is ready to be added/drawn AFTER selection
  final bool isLineActiveToAddIntoGameField;
  final bool isShapeActiveToAddIntoGameField;
  final FieldItemModel?
      activeForm; // The specific item model selected from grid/tool
  // Flags indicating if a tool that involves continuous drawing/action is active
  final bool isFreeDrawingActive; // Directly tied to ActiveTool.freeDraw
  final bool isEraserActivated; // Directly tied to ActiveTool.eraser
  final bool isTrashActive; // Directly tied to ActiveTool.trash

  final String? activatedFormId; // ID of the activeForm, if any

  final ActiveTool activeTool; // The primary selected tool
  final String? activeId;

  const LineState({
    this.availableLines = const [],
    this.availableFreeDraws = const [],
    this.isLineActiveToAddIntoGameField = false,
    this.isShapeActiveToAddIntoGameField = false,
    this.activeForm,
    this.isFreeDrawingActive = false,
    this.activatedFormId,
    this.isEraserActivated = false,
    this.isTrashActive = false,
    this.activeId,
    this.activeTool = ActiveTool.pointer, // Default tool
  });

  LineState copyWith({
    List<LineModelV2>? availableLines,
    List<FreeDrawModelV2>? availableFreeDraws,
    bool? isLineActiveToAddIntoGameField,
    bool? isShapeActiveToAddIntoGameField,
    Object? activeForm = _sentinel, // Use sentinel for nullable fields
    bool? isFreeDrawingActive,
    Object? activatedFormId = _sentinel, // Use sentinel for nullable fields
    bool? isEraserActivated,
    bool? isTrashActive,
    ActiveTool? activeTool,
    Object? activeId = _sentinel,
  }) {
    return LineState(
        availableLines: availableLines ?? this.availableLines,
        availableFreeDraws: availableFreeDraws ?? this.availableFreeDraws,
        isLineActiveToAddIntoGameField: isLineActiveToAddIntoGameField ??
            this.isLineActiveToAddIntoGameField,
        isShapeActiveToAddIntoGameField: isShapeActiveToAddIntoGameField ??
            this.isShapeActiveToAddIntoGameField,
        activeForm: activeForm == _sentinel
            ? this.activeForm
            : activeForm as FieldItemModel?,
        isFreeDrawingActive: isFreeDrawingActive ?? this.isFreeDrawingActive,
        activatedFormId: activatedFormId == _sentinel
            ? this.activatedFormId
            : activatedFormId as String?,
        isEraserActivated: isEraserActivated ?? this.isEraserActivated,
        isTrashActive: isTrashActive ?? this.isTrashActive,
        activeTool: activeTool ?? this.activeTool,
        activeId: activeId == _sentinel ? this.activeId : activeId as String?);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LineState &&
        listEquals(
          other.availableLines,
          availableLines,
        ) && // Use listEquals for lists
        listEquals(other.availableFreeDraws, availableFreeDraws) &&
        other.isLineActiveToAddIntoGameField ==
            isLineActiveToAddIntoGameField &&
        other.isShapeActiveToAddIntoGameField ==
            isShapeActiveToAddIntoGameField &&
        other.activeForm == activeForm &&
        other.isFreeDrawingActive == isFreeDrawingActive &&
        other.activatedFormId == activatedFormId &&
        other.isEraserActivated == isEraserActivated &&
        other.isTrashActive == isTrashActive &&
        other.activeTool == activeTool;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(availableLines), // Use Object.hashAll for lists
      Object.hashAll(availableFreeDraws),
      isLineActiveToAddIntoGameField,
      isShapeActiveToAddIntoGameField,
      activeForm,
      isFreeDrawingActive,
      activatedFormId,
      isEraserActivated,
      isTrashActive,
      activeTool,
    );
  }
}
