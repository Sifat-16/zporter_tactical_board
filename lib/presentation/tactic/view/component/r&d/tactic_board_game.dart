import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/form_line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

import 'game_field.dart';

abstract class TacticBoardGame extends FlameGame
    with DragCallbacks, TapDetector, RiverpodGameMixin {
  late GameField gameField;
}

class TacticBoard extends TacticBoardGame {
  // Changed to DragDetector
  TacticBoard();

  // final LineBloc lineBloc;
  // final BoardBloc boardBloc;

  Vector2? lineStartPoint; // Start point of the line
  LineDrawerComponent? _currentLine; // Store the currently drawing line
  FreeDrawerComponent?
  _currentFreeDraw; // Store the current free drawing component

  @override
  FutureOr<void> onLoad() async {
    _initiateField();
    return super.onLoad();
  }

  _initiateField() {
    gameField = GameField(size: Vector2(size.x - 20, size.y - 20));
    add(gameField);
  }

  @override
  Color backgroundColor() {
    return ColorManager.grey;
  }

  addItem(FieldItemModel item) {
    if (item is PlayerModel) {
      ref.read(boardProvider.notifier).addBoardComponent(fieldItemModel: item);
      add(PlayerComponent(object: item));
    } else if (item is EquipmentModel) {
      ref.read(boardProvider.notifier).addBoardComponent(fieldItemModel: item);
      add(EquipmentComponent(object: item));
    } else if (item is FormModel) {
      ref.read(boardProvider.notifier).addBoardComponent(fieldItemModel: item);
      add(FormComponent(object: item));
    }
  }

  @override
  bool get debugMode => false;

  @override
  void onDragStart(DragStartEvent info) {
    final lp = ref.read(lineProvider);
    // Start drawing the line only if the line is active to be added
    if (lp.isFreeDrawingActive) {
      _currentFreeDraw = FreeDrawerComponent(
        freeDrawModel: FreeDrawModel(
          points: [info.localPosition],
          color: ColorManager.black, // Get color from bloc
        ),
      );
      add(_currentFreeDraw!);
    } else if (lp.isLineActiveToAddIntoGameField) {
      lineStartPoint = info.localPosition; // Use game coordinates

      // Create the line component
      FormModel formModel = lp.activatedLineForm!;
      LineModel? lineModel = formModel.formItemModel as LineModel?;

      if (lineModel != null) {
        LineModel initialLineModel = lineModel.copyWith(
          start: lineStartPoint!,
          end: lineStartPoint!, // Start with end = start
          color: Colors.black,
        );

        _currentLine = LineDrawerComponent(
          lineModel: initialLineModel,
          lineColor: Colors.black,
        );
        add(_currentLine!); // Add to component tree
      }
    }
    super.onDragStart(info); // Call super *AFTER* your custom logic
  }

  @override
  void onDragUpdate(DragUpdateEvent info) {
    super.onDragUpdate(info);
    final lp = ref.read(lineProvider);
    // Keep updating the line if it's being drawn.
    if (_currentFreeDraw != null) {
      _currentFreeDraw!.addPoint(info.localStartPosition);
    } else if (lp.isLineActiveToAddIntoGameField && lineStartPoint != null) {
      final currentPoint = info.localStartPosition;
      if (_currentLine != null) {
        _currentLine!.lineModel.end = currentPoint;
        _currentLine!.updateLine();
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent info) {
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
        color: Colors.black,
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
  }

  @override
  void onDragCancel(DragCancelEvent info) {
    super.onDragCancel(info);
    final lp = ref.read(lineProvider);

    // Clean up if the drag is cancelled

    if (_currentFreeDraw != null) {
      remove(_currentFreeDraw!);
      _currentFreeDraw = null;
    }
    if (_currentLine != null) {
      remove(_currentLine!);
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
  }

  @override
  void onTapDown(TapDownInfo info) {
    // TODO: implement onTapDown
    super.onTapDown(info);
    final tapPosition = info.raw.localPosition; // Position in game coordinates
    final components = componentsAtPoint(tapPosition.toVector2());
    if (components.isNotEmpty) {
      zlog(
        data:
            "Components tap happened ${components.any((t) => t is FieldComponent)} - ${components.map((t) => t.runtimeType).toList()}",
      );
      if (!components.any((t) => t is FieldComponent)) {
        ref
            .read(boardProvider.notifier)
            .toggleSelectItemEvent(fieldItemModel: null);
      }
    }
  }
}
