import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart' show Colors, Color;
import 'package:uuid/uuid.dart';
import 'package:zporter_tactical_board/app/config/feature_flags.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart';

class DrawnLine {
  /* ... same as before ... */
  List<Offset> points;
  final Color baseColor;
  bool isSelected;
  DrawnLine({
    required this.points,
    required this.baseColor,
    this.isSelected = false,
  });
}

// --- Component ---
enum DrawingTool { draw, erase }

class DrawingBoardComponent extends PositionComponent
    // REMOVE DragCallbacks
    with
        TapCallbacks,
        RiverpodComponentMixin,
        HasGameReference<TacticBoardGame> {
  // ----- Public Getter for Selection State -----
  bool get isLineSelected => _selectedLineIndex != null;
  int? get selectedLineIndex =>
      _selectedLineIndex; // Allow reading index if needed externally
  // -------------------------------------------

  // ... (Keep all settings, state variables, paints, initialLines, uuid) ...
  final Color defaultDrawingColor;
  final double defaultDrawingStrokeWidth;
  final Color eraserColor;
  final double eraserStrokeWidth;
  final Color selectedColor;
  final double selectionHitTolerance;
  DrawingTool? currentTool;
  final List<FreeDrawModelV2> _drawnLines = [];
  int? _selectedLineIndex;
  List<Offset>? _currentLine;
  bool _isMovingLine = false;
  Offset? _lineMoveStartPos;
  List<Vector2>? _originalMovingLinePoints;
  late final Paint _drawingPaint;
  late final Paint _selectedPaint;
  late final Paint _eraserPaint;
  late Rect _componentBounds;
  final List<FreeDrawModelV2>? initialLines;
  final Uuid _uuid = const Uuid();

  bool get isMovingLine => _isMovingLine;

  // Constructor remains the same
  DrawingBoardComponent({
    this.defaultDrawingColor = ColorManager.dark2,
    this.defaultDrawingStrokeWidth = 3.0,
    this.eraserColor = Colors.white,
    this.eraserStrokeWidth = 10.0,
    this.selectedColor = Colors.green,
    this.selectionHitTolerance = 20.0,
    this.initialLines,
    super.position,
    required Vector2 super.size,
  });

  // _notifyDrawingChanged - triggers immediate save
  void _notifyDrawingChanged(String operation) {
    /* ... same as before ... */
    try {
      List<FreeDrawModelV2> clones = getLines();
      List<FreeDrawModelV2> relativeClones = clones.map((e) {
        e.points = e.points
            .map(
              (p) => SizeHelper.getBoardRelativeVector(
                gameScreenSize: game.gameField.size,
                actualPosition: p,
              ),
            )
            .toList();
        return e;
      }).toList();
      ref.read(boardProvider.notifier).updateFreeDraws(lines: relativeClones);

      // Trigger immediate save after drawing changes
      if (FeatureFlags.enableEventDrivenSave) {
        try {
          // Access the game instance - it's a TacticBoard which has triggerImmediateSave
          final tacticBoard = game as dynamic;
          if (tacticBoard.triggerImmediateSave != null) {
            tacticBoard.triggerImmediateSave(reason: "Drawing: $operation");
          }
        } catch (e) {
          // Fallback if method not available
          print("Could not trigger immediate save for drawing: $e");
        }
      }

      print(
        "Drawing Changed: [$operation]. Total lines: ${_drawnLines.length}",
      );
    } catch (e, stackTrace) {
      print("Error in _notifyDrawingChanged: $e \n $stackTrace");
    }
  }

  // onLoad remains the same
  @override
  Future<void> onLoad() async {
    /* ... same as before ... */
    super.onLoad();
    addToGameWidgetBuild(() {
      ref.listen<LineState>(lineProvider, (previous, current) {
        _deselectLine();
        if (current.isFreeDrawingActive) {
          setTool(DrawingTool.draw);
        } else if (current.isEraserActivated) {
          setTool(DrawingTool.erase);
        } else {
          setTool(null);
        }
      });
      final initialState = ref.read(lineProvider);
      currentTool = initialState.isFreeDrawingActive
          ? DrawingTool.draw
          : initialState.isEraserActivated
              ? DrawingTool.erase
              : null;

      ref.listen<BoardState>((boardProvider), (previous, current) {
        _checkAndDeleteLine(previous, current);
      });
    });
    assert(
      size.x > 0 && size.y > 0,
      'DrawingBoardComponent must have a valid size.',
    );
    _componentBounds = Rect.fromLTWH(0, 0, size.x, size.y);
    zlog(data: "Component bound size ${_componentBounds}");
    _drawingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    _selectedPaint = Paint()
      ..color = selectedColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    _eraserPaint = Paint()
      ..color = eraserColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = eraserStrokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final List<FreeDrawModelV2>? initialLinesToLoad =
        initialLines?.map((m) => m.clone()).toList();
    if (initialLinesToLoad != null && initialLinesToLoad.isNotEmpty) {
      loadLines(initialLinesToLoad, suppressNotification: true);
      print("Initial drawing data loaded.");
    }
  }

  // render remains the same
  @override
  void render(Canvas canvas) {
    /* ... same as before ... */
    canvas.save();
    canvas.clipRect(_componentBounds);
    for (int i = 0; i < _drawnLines.length; i++) {
      final model = _drawnLines[i];
      final points = _toOffsetList(model.points);
      if (points.length < 2) continue;
      final isSelected = (i == _selectedLineIndex);
      final paintToUse = isSelected ? _selectedPaint : _drawingPaint;
      paintToUse.color =
          isSelected ? selectedColor : (model.color ?? defaultDrawingColor);
      paintToUse.strokeWidth =
          isSelected ? (model.thickness + 1.0) : model.thickness;
      _drawPath(canvas, points, paintToUse);
    }
    _drawingPaint.color = defaultDrawingColor;
    if (_currentLine != null && _currentLine!.length > 1) {
      if (currentTool == DrawingTool.draw) {
        _drawingPaint.strokeWidth = defaultDrawingStrokeWidth;
        _drawPath(canvas, _currentLine!, _drawingPaint);
      } else if (currentTool == DrawingTool.erase) {
        _drawPath(canvas, _currentLine!, _eraserPaint);
      }
    }
    canvas.restore();
  }

  // _drawPath, _toOffsetList, _toVector2List remain the same
  void _drawPath(Canvas canvas, List<Offset> points, Paint paint) {
    /* ... */
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  List<Offset> _toOffsetList(List<Vector2> vectors) =>
      vectors.map((v) => v.toOffset()).toList();
  List<Vector2> _toVector2List(List<Offset> offsets) =>
      offsets.map((o) => o.toVector2()).toList();

  // onTapDown and related helpers remain the same
  @override
  bool onTapDown(TapDownEvent event) {
    if (currentTool != null || _isMovingLine) return false;
    final tapPosition = event.localPosition.toOffset();
    int? newlySelectedLineIndex;
    for (int i = _drawnLines.length - 1; i >= 0; i--) {
      if (_isTapOnLine(
        tapPosition,
        _drawnLines[i].points,
        _drawnLines[i].thickness,
      )) {
        newlySelectedLineIndex = i;
        break;
      }
    }
    if (newlySelectedLineIndex != null) {
      if (newlySelectedLineIndex == _selectedLineIndex) {
        _deselectLine();
      } else {
        _deselectLine();
        _selectLine(newlySelectedLineIndex);
      }
      return true;
    } else {
      if (_selectedLineIndex != null) {
        _deselectLine();
        return true;
      }
    }
    return false;
  }

  bool _isTapOnLine(
    Offset tapPosition,
    List<Vector2> linePoints,
    double lineThickness,
  ) {
    /* ... */
    if (linePoints.length < 2) return false;
    final double tolerance = (lineThickness / 2.0) + selectionHitTolerance;
    final double toleranceSq = tolerance * tolerance;
    for (int i = 0; i < linePoints.length - 1; i++) {
      if (_pointSegmentDistanceSq(
            tapPosition,
            linePoints[i].toOffset(),
            linePoints[i + 1].toOffset(),
          ) <
          toleranceSq) {
        return true;
      }
    }
    return false;
  }

  void _selectLine(int index) {
    if (index >= 0 && index < _drawnLines.length) {
      _selectedLineIndex = index;
      ref.read(boardProvider.notifier).toggleSelectItemEvent(
            fieldItemModel: _drawnLines[_selectedLineIndex!],
            camefrom: "Drawing board select",
          );
      print("Selected line index: $index");
    }
  }

  void _deselectLine() {
    _isMovingLine = false;
    _lineMoveStartPos = null;
    _originalMovingLinePoints = null;
    if (_selectedLineIndex != null) {
      print("Deselected line index: $_selectedLineIndex");
      ref.read(boardProvider.notifier).toggleSelectItemEvent(
            fieldItemModel: _drawnLines[_selectedLineIndex!],
            camefrom: "Drawing board deselect",
          );
      _selectedLineIndex = null;
    }
  }

  // --- ADD Public Handlers for Drag Events ---
  // bool handleDragStart(DragStartEvent event) {
  //   final startPosOffset = event.localPosition.toOffset();
  //   bool consumed = false;
  //
  //   // Logic moved from old onDragStart
  //   if (currentTool == null && _selectedLineIndex != null) {
  //     final selectedModel = _drawnLines[_selectedLineIndex!];
  //     if (_isTapOnLine(
  //       startPosOffset,
  //       selectedModel.points,
  //       selectedModel.thickness,
  //     )) {
  //       _isMovingLine = true;
  //       _lineMoveStartPos = startPosOffset;
  //       _originalMovingLinePoints = List<Vector2>.from(selectedModel.points);
  //       print("Component started moving line: $_selectedLineIndex");
  //       consumed = true;
  //     } else {
  //       _deselectLine();
  //       // Don't consume yet, maybe game wants the drag
  //     }
  //   } else if (currentTool != null) {
  //     _deselectLine();
  //     if (_componentBounds.contains(startPosOffset)) {
  //       _currentLine = [startPosOffset];
  //       print("Component started drawing/erasing");
  //       consumed = true;
  //     } else {
  //       _currentLine = null;
  //     }
  //   } else {
  //     _isMovingLine = false;
  //   }
  //   return consumed;
  // }

  bool handleDragStart(DragStartEvent event) {
    final startPosOffset = event.localPosition.toOffset();
    bool consumed = false;

    // Case 1: A drawing or erasing tool is active.
    if (currentTool != null) {
      _deselectLine(); // A new drawing action should always deselect any line.
      if (_componentBounds.contains(startPosOffset)) {
        _currentLine = [startPosOffset];
        print("Component started drawing/erasing");
        consumed = true;
      } else {
        _currentLine = null;
      }
      return consumed;
    }

    // Case 2: No tool is active (currentTool == null). We might be moving a line.
    // We need to find if the drag started on ANY line.
    int? lineIndexUnderDrag;
    for (int i = _drawnLines.length - 1; i >= 0; i--) {
      if (_isTapOnLine(
        startPosOffset,
        _drawnLines[i].points,
        _drawnLines[i].thickness,
      )) {
        lineIndexUnderDrag = i;
        break;
      }
    }

    // Subcase 2.1: A line was found under the drag-start point.
    if (lineIndexUnderDrag != null) {
      // If this line isn't already the selected one, select it now.
      if (_selectedLineIndex != lineIndexUnderDrag) {
        _deselectLine(); // Clear any previous selection.
        _selectLine(lineIndexUnderDrag);
      }

      // Now that the line is definitely selected, initiate the move.
      _isMovingLine = true;
      _lineMoveStartPos = startPosOffset;
      _originalMovingLinePoints =
          List<Vector2>.from(_drawnLines[lineIndexUnderDrag].points);
      print("Component started moving line: $lineIndexUnderDrag");
      consumed = true;
    }
    // Subcase 2.2: The drag started on an empty area of the board.
    else {
      // If a line was previously selected, this drag on an empty area deselects it.
      if (_selectedLineIndex != null) {
        _deselectLine();
        // We consume the event to prevent other game components from reacting
        // to a drag that was meant to deselect something on this component.
        consumed = true;
      }
    }

    return consumed;
  }

  bool handleDragUpdate(DragUpdateEvent event) {
    bool consumed = false;
    // Logic moved from old onDragUpdate
    if (_isMovingLine &&
        _selectedLineIndex != null &&
        _lineMoveStartPos != null) {
      final currentPosOffset = event.localStartPosition.toOffset();
      final dragDeltaOffset = currentPosOffset - _lineMoveStartPos!;
      final dragDeltaVector = dragDeltaOffset.toVector2();
      final List<Vector2> newPoints = _originalMovingLinePoints!
          .map((originalPoint) => originalPoint + dragDeltaVector)
          .toList();
      _drawnLines[_selectedLineIndex!].points = newPoints;
      consumed = true;
    } else if (currentTool != null && _currentLine != null) {
      _currentLine!.add(event.localStartPosition.toOffset());
      consumed = true;
    }
    return consumed;
  }

  bool handleDragCancel(DragCancelEvent event) {
    bool consumed = false;
    // Logic moved from old onDragCancel
    if (_isMovingLine &&
        _selectedLineIndex != null &&
        _originalMovingLinePoints != null) {
      _drawnLines[_selectedLineIndex!].points = List<Vector2>.from(
        _originalMovingLinePoints!,
      );
      print("Component cancelled moving line: $_selectedLineIndex");
      _isMovingLine = false;
      _lineMoveStartPos = null;
      _originalMovingLinePoints = null;
      consumed = true;
    } else if (currentTool != null && _currentLine != null) {
      _currentLine = null;
      print("Component cancelled drawing/erasing");
      consumed = true;
    } else {
      _isMovingLine = false;
      _lineMoveStartPos = null;
      _originalMovingLinePoints = null;
    }
    return consumed;
  }

  bool handleDragEnd(DragEndEvent event) {
    bool dataChanged = false;
    bool consumed = false;
    bool wasMoving = _isMovingLine;
    String changeOperation = "Unknown";

    // Logic moved from old onDragEnd
    if (_isMovingLine && _selectedLineIndex != null) {
      changeOperation = "Move Line (Index: $_selectedLineIndex)";
      dataChanged = true;
      consumed = true;
    } else if (currentTool != null &&
        _currentLine != null &&
        _currentLine!.length > 1) {
      if (currentTool == DrawingTool.draw) {
        final newModel = FreeDrawModelV2(
          id: _uuid.v4(),
          points: _toVector2List(_currentLine!),
          color: defaultDrawingColor,
          thickness: defaultDrawingStrokeWidth,
          offset: _toVector2List(_currentLine!).first,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _drawnLines.add(newModel);
        changeOperation = "Draw Line (ID: ${newModel.id})";
        dataChanged = true;
      } else {
        // currentTool == DrawingTool.erase
        dataChanged = _performErase(_currentLine!);
        if (dataChanged) {
          changeOperation = "Erase Drawing";
        }
      }
      consumed = true;
    }

    _currentLine = null;

    if (consumed) {
      if (dataChanged) {
        _notifyDrawingChanged(changeOperation);
      }
      if (wasMoving) {
        _isMovingLine = false;
        _lineMoveStartPos = null;
        _originalMovingLinePoints = null;
      }
    } else {
      _isMovingLine = false;
      _lineMoveStartPos = null;
      _originalMovingLinePoints = null;
    }
    return consumed; // Return if handled
  }
  // -----------------------------------------

  // _performErase, _isPointErased, _pointSegmentDistanceSq remain the same
  bool _performErase(List<Offset> eraserOffsetPath) {
    /* ... same as before ... */
    if (eraserOffsetPath.length < 2) return false;
    final List<FreeDrawModelV2> nextDrawnLines = [];
    bool changed = false;
    final double eraseRadius = eraserStrokeWidth / 2.0;
    final double eraseRadiusSq = eraseRadius * eraseRadius;
    int? currentSelectedIndex = _selectedLineIndex;
    int newSelectedIndex = -1;
    int nextListIndex = 0;
    for (int lineIdx = 0; lineIdx < _drawnLines.length; lineIdx++) {
      final model = _drawnLines[lineIdx];
      final List<Vector2> originalPoints = model.points;
      List<Vector2> currentSegmentPoints = [];
      bool lineSurvivedInPart = false;
      for (int i = 0; i < originalPoints.length; i++) {
        final pointVec = originalPoints[i];
        if (_isPointErased(
          pointVec.toOffset(),
          eraserOffsetPath,
          eraseRadiusSq,
        )) {
          changed = true;
          if (currentSegmentPoints.length > 1) {
            final newSegmentModel = model.copyWith(
              id: _uuid.v4(),
              points: List<Vector2>.from(currentSegmentPoints),
              updatedAt: DateTime.now(),
            );
            nextDrawnLines.add(newSegmentModel);
            if (lineIdx == currentSelectedIndex)
              newSelectedIndex = nextListIndex;
            nextListIndex++;
            lineSurvivedInPart = true;
          }
          currentSegmentPoints = [];
        } else {
          currentSegmentPoints.add(pointVec);
        }
      }
      if (currentSegmentPoints.length > 1) {
        final lastSegmentModel = model.copyWith(
          id: _uuid.v4(),
          points: List<Vector2>.from(currentSegmentPoints),
          updatedAt: DateTime.now(),
        );
        nextDrawnLines.add(lastSegmentModel);
        if (lineIdx == currentSelectedIndex) newSelectedIndex = nextListIndex;
        nextListIndex++;
        lineSurvivedInPart = true;
      }
      if (lineIdx == currentSelectedIndex && !lineSurvivedInPart) {
        newSelectedIndex = -1;
      }
    }
    if (changed) {
      _drawnLines.clear();
      _drawnLines.addAll(nextDrawnLines);
      if (newSelectedIndex != -1) {
        _selectLine(newSelectedIndex);
      } else {
        _deselectLine();
      }
    }
    return changed;
  }

  bool _isPointErased(
    Offset point,
    List<Offset> eraserPath,
    double eraseRadiusSq,
  ) {
    /* ... */
    if (eraserPath.length < 2) return false;
    for (int i = 0; i < eraserPath.length - 1; i++) {
      if (_pointSegmentDistanceSq(point, eraserPath[i], eraserPath[i + 1]) <
          eraseRadiusSq) {
        return true;
      }
    }
    return false;
  }

  double _pointSegmentDistanceSq(Offset p, Offset p1, Offset p2) {
    /* ... */
    final double l2 = (p1 - p2).distanceSquared;
    if (l2 == 0.0) return (p - p1).distanceSquared;
    final double t = max(
      0,
      min(
        1,
        ((p.dx - p1.dx) * (p2.dx - p1.dx) + (p.dy - p1.dy) * (p2.dy - p1.dy)) /
            l2,
      ),
    );
    final Offset projection = p1 + (p2 - p1) * t;
    return (p - projection).distanceSquared;
  }

  // setTool, clearDrawing remain the same
  void setTool(DrawingTool? tool) {
    /* ... same as before ... */
    if (currentTool != tool) {
      _deselectLine();
      currentTool = tool;
      _currentLine = null;
      print("Drawing tool set to: $currentTool");
    }
  }

  void clearDrawing() {
    /* ... same as before ... */
    bool hadLines = _drawnLines.isNotEmpty;
    _deselectLine();
    _drawnLines.clear();
    _currentLine = null;
    if (hadLines) {
      _notifyDrawingChanged("Clear All");
    }
    _isMovingLine = false;
    _lineMoveStartPos = null;
    _originalMovingLinePoints = null;
  }

  // resetDrawing remains the same
  void resetDrawing() {
    /* ... same as before ... */
    print("Resetting drawing (Clearing all current lines)...");
    clearDrawing();
  }

  // getLines, loadLines remain the same
  List<FreeDrawModelV2> getLines() {
    /* ... same as before ... */
    return _drawnLines.map((model) => model.clone()).toList();
  }

  void loadLines(
    List<FreeDrawModelV2> lines, {
    bool suppressNotification = false,
  }) {
    /* ... same as before ... */
    _deselectLine();
    _drawnLines.clear();
    bool loadedAny = false;
    _drawnLines.addAll(
      lines.map((model) {
        if (model.points.length < 2) {
          print(
            "Warning: Skipping loaded line ${model.id} with less than 2 points.",
          );
          return null;
        }
        loadedAny = true;
        return model.clone();
      }).whereType<FreeDrawModelV2>(),
    );
    _currentLine = null;
    if ((loadedAny || lines.isEmpty) && !suppressNotification) {
      _notifyDrawingChanged("Load Lines");
    } else if (loadedAny && suppressNotification) {
      print(
        "Drawing data loaded with ${_drawnLines.length} lines (notification suppressed).",
      );
    }
  }

  void _checkAndDeleteLine(BoardState? previous, BoardState current) {
    FieldItemModel? c = current.itemToDelete;
    if (c is FreeDrawModelV2) {
      int index = _drawnLines.indexWhere((t) => t.id == c.id);
      zlog(
        data:
            "Items to delete here check delete line ${current.itemToDelete.runtimeType} - $index - ${_drawnLines} -${current.itemToDelete?.id}",
      );
      if (index == -1) return;
      final lineToRemove =
          _drawnLines[index]; // Get a reference for logging, if needed.
      _drawnLines.removeAt(index);
      _selectedLineIndex = null;
      _notifyDrawingChanged(
        "Remove Line (ID: ${lineToRemove.id} via tap-select-delete)",
      );
    }
  }
}
