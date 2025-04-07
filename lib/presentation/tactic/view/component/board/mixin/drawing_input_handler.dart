// --- Mixin for Drawing Input Handling ---
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/eraser/eraser_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/form_line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

mixin DrawingInputHandler on TacticBoardGame {
  // State variables moved from TacticBoard
  Vector2? lineStartPoint;
  LineDrawerComponent? _currentLine;
  FreeDrawerComponent? _currentFreeDraw;

  EraserComponent? _currentEraserVisual;
  // Define eraser size consistently
  static const double _eraserSize = 20.0;

  // Methods moved from TacticBoard (Code inside unchanged)
  @override
  void onDragStart(DragStartEvent info) {
    // --- Exact code from original TacticBoard.onDragStart ---
    final lp = ref.read(lineProvider);

    if (lp.isEraserActivated) {
      // --- Create and add the eraser visual ---
      // Remove any lingering visual first (safety check)
      if (_currentEraserVisual != null) {
        remove(_currentEraserVisual!);
      }
      _currentEraserVisual = EraserComponent(
        radius: _eraserSize / 2.0, // Visual radius matches erase radius
        position: info.localPosition,
      );
      add(_currentEraserVisual!); // Add the visual to the game
      // ----------------------------------------

      _eraseAtPoint(info.localPosition); // Erase at the starting point
      super.onDragStart(info); // Allow other handlers
      return; // Prevent drawing logic
    }

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

    if (lp.isEraserActivated) {
      // --- Move the eraser visual ---
      // Update the position of the existing visual component
      // Use localStartPosition for smoother updates during drag
      _currentEraserVisual?.position = info.localStartPosition;
      // -----------------------------

      // Erase points at the new position
      _eraseAtPoint(info.localStartPosition);

      super.onDragUpdate(info); // Allow other handlers
      return; // Prevent drawing logic
    }
    // Keep updating the line if it's being drawn.
    else if (_currentFreeDraw != null) {
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

    if (lp.isEraserActivated) {
      // --- Remove the eraser visual ---
      if (_currentEraserVisual != null) {
        remove(_currentEraserVisual!); // Remove the visual from the game
        _currentEraserVisual = null; // Clear the reference
      }
      // -------------------------------

      // Optional: Erase at the final point (might be redundant)
      // Vector2? finalPosition = info.localPosition; // Might not be available or reliable
      // if (finalPosition != null) _eraseAtPoint(finalPosition);

      super.onDragEnd(info); // Allow other handlers
      return; // Prevent drawing logic
    }

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

      ref
          .read(lineProvider.notifier)
          .unLoadActiveLineModelToAddIntoGameFieldEvent(formModel: formModel);
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

    if (lp.isEraserActivated) {
      // --- Remove the eraser visual ---
      if (_currentEraserVisual != null) {
        remove(_currentEraserVisual!); // Remove the visual from the game
        _currentEraserVisual = null; // Clear the reference
      }
      // -------------------------------

      super.onDragCancel(info); // Allow other handlers
      return; // Prevent drawing logic
    }

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

  void _eraseAtPoint(Vector2 point) {
    final componentsToRemove = <FreeDrawerComponent>[];
    // Query potentially erasable components. This queries all direct children.
    // If components are nested, you might need a recursive query or broadphase.
    final potentiallyErasable = children.query<FreeDrawerComponent>();
    for (final component in potentiallyErasable) {
      List<Vector2> points = component.freeDrawModel.points;

      for (var p in points) {
        double distance = p.taxicabDistanceTo(point);
        zlog(data: "Found intersect ${distance} - ${p} - ${point}");
        if (distance <= 15) {
          componentsToRemove.add(component);
        }
      }

      // if (eraserRect.ov) {
      //   zlog(data: "Eraser rect ${component.freeDrawModel.points}");
      //   componentsToRemove.add(component);
      // }
    }

    // Remove the identified components from the game tree
    for (final component in componentsToRemove) {
      ref.read(boardProvider.notifier).clearFreeDrawItem(component.formModel);
      remove(component); // Remove from Flame game visualization
    }
  }
}
