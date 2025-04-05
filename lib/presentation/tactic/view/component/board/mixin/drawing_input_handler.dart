// --- Mixin for Drawing Input Handling ---
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/form_line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

mixin DrawingInputHandler on TacticBoardGame {
  // State variables moved from TacticBoard
  Vector2? lineStartPoint;
  LineDrawerComponent? _currentLine;
  FreeDrawerComponent? _currentFreeDraw;

  // Methods moved from TacticBoard (Code inside unchanged)
  @override
  void onDragStart(DragStartEvent info) {
    // --- Exact code from original TacticBoard.onDragStart ---
    final lp = ref.read(lineProvider);
    // Start drawing the line only if the line is active to be added
    if (lp.isFreeDrawingActive) {
      // Create the free draw component
      FormModel formModel = lp.activatedLineForm!;
      FreeDrawModel? freeDrawModel = formModel.formItemModel as FreeDrawModel?;

      if (freeDrawModel != null) {
        FreeDrawModel initialFreeDrawerModel = freeDrawModel.copyWith(
          points: [info.localPosition],
          color: ColorManager.black, // Get color from bloc
        );

        formModel.formItemModel = initialFreeDrawerModel;

        _currentFreeDraw = FreeDrawerComponent(
          formModel: formModel,
          // lineModel: initialLineModel,
        );
        add(_currentFreeDraw!); // Add to component tree
      }
    } else if (lp.isLineActiveToAddIntoGameField) {
      lineStartPoint = info.localPosition; // Use game coordinates

      // Create the line component
      FormModel formModel = lp.activatedLineForm!;
      LineModel? lineModel = formModel.formItemModel as LineModel?;

      if (lineModel != null) {
        LineModel initialLineModel = lineModel.copyWith(
          start: lineStartPoint!,
          end: lineStartPoint!, // Start with end = start
          color: formModel.color,
        );

        formModel.formItemModel = initialLineModel;

        _currentLine = LineDrawerComponent(
          formModel: formModel,
          // lineModel: initialLineModel,
        );
        add(_currentLine!); // Add to component tree
      }
    }
    super.onDragStart(
      info,
    ); // Call super *AFTER* your custom logic (as in original)
    // --- End of exact code ---
  }

  @override
  void onDragUpdate(DragUpdateEvent info) {
    // --- Exact code from original TacticBoard.onDragUpdate ---
    super.onDragUpdate(info);
    final lp = ref.read(lineProvider);
    // Keep updating the line if it's being drawn.
    if (_currentFreeDraw != null) {
      _currentFreeDraw!.addPoint(info.localStartPosition);
    } else if (lp.isLineActiveToAddIntoGameField && lineStartPoint != null) {
      final currentPoint = info.localStartPosition;
      if (_currentLine != null) {
        _currentLine!.lineModel.end = currentPoint;
        _currentLine!
            .updateLine(); // Assuming updateLine exists on LineDrawerComponent
      }
    }
    // --- End of exact code ---
  }

  @override
  void onDragEnd(DragEndEvent info) {
    // --- Exact code from original TacticBoard.onDragEnd ---
    super.onDragEnd(info);
    final lp = ref.read(lineProvider);

    // Finalize the line drawing.
    if (_currentFreeDraw != null) {
      // Now we need to add finishing touch
      FormModel formModel = lp.activatedLineForm!;
      formModel.formItemModel = _currentFreeDraw!.freeDrawModel.copyWith();
      ref
          .read(boardProvider.notifier)
          .addBoardComponent(fieldItemModel: formModel);

      _currentFreeDraw =
          null; // Set _currentFreeDraw to null after the drag ends
    } else if (lp.isLineActiveToAddIntoGameField &&
        lineStartPoint != null &&
        _currentLine != null) {
      FormModel formModel = lp.activatedLineForm!;
      formModel.formItemModel = _currentLine!.lineModel.copyWith(
        color: ColorManager.black,
      );
      formModel.offset = _currentLine!.lineModel.start;
      ref
          .read(boardProvider.notifier)
          .addBoardComponent(fieldItemModel: formModel);

      _currentLine = null; // VERY IMPORTANT: Clear current line.
      lineStartPoint = null;
      ref
          .read(lineProvider.notifier)
          .unLoadActiveLineModelToAddIntoGameFieldEvent(formModel: formModel);
    }
    // --- End of exact code ---
  }

  @override
  void onDragCancel(DragCancelEvent info) {
    // --- Exact code from original TacticBoard.onDragCancel ---
    super.onDragCancel(info);
    final lp = ref.read(lineProvider);

    // Clean up if the drag is cancelled

    if (_currentFreeDraw != null) {
      remove(_currentFreeDraw!); // remove() is available via FlameGame
      _currentFreeDraw = null;
    }
    if (_currentLine != null) {
      remove(_currentLine!); // remove() is available via FlameGame
      _currentLine = null;
      lineStartPoint = null;
      if (lp.isLineActiveToAddIntoGameField) {
        ref
            .read(lineProvider.notifier)
            .unLoadActiveLineModelToAddIntoGameFieldEvent(
              formModel: lp.activatedLineForm!,
            );
      }
    }
    // --- End of exact code ---
  }
}
