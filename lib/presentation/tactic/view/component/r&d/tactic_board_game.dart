import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/form_line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_bloc.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_event.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart';

import 'game_field.dart';

class TacticBoardGame extends FlameGame with DragCallbacks, TapDetector {
  // Changed to DragDetector
  TacticBoardGame({required this.lineBloc});

  late GameField gameField;
  final LineBloc lineBloc;
  List<PlayerModel> players = [];
  List<EquipmentModel> equipments = [];
  List<FormModel> forms = [];
  Vector2? lineStartPoint; // Start point of the line
  LineDrawerComponent? _currentLine; // Store the currently drawing line
  FreeDrawerComponent?
  _currentFreeDraw; // Store the current free drawing component

  @override
  FutureOr<void> onLoad() async {
    await add(
      FlameMultiBlocProvider(
        providers: [
          FlameBlocProvider<LineBloc, LineState>.value(value: lineBloc),
        ],
      ),
    );

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
      players.add(item);
      add(PlayerComponent(object: item));
    } else if (item is EquipmentModel) {
      equipments.add(item);
      add(EquipmentComponent(object: item));
    } else if (item is FormModel) {
      forms.add(item);
      add(FormComponent(object: item));
    }
  }

  @override
  bool get debugMode => false;

  @override
  void onDragStart(DragStartEvent info) {
    // Start drawing the line only if the line is active to be added
    if (lineBloc.state.isFreeDrawingActive) {
      _currentFreeDraw = FreeDrawerComponent(
        freeDrawModel: FreeDrawModel(
          points: [info.localPosition],
          color: ColorManager.black, // Get color from bloc
        ),
      );
      add(_currentFreeDraw!);
    } else if (lineBloc.state.isLineActiveToAddIntoGameField) {
      lineStartPoint = info.localPosition; // Use game coordinates

      // Create the line component
      FormModel formModel = lineBloc.state.activatedLineForm!;
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
    // Keep updating the line if it's being drawn.
    if (_currentFreeDraw != null) {
      _currentFreeDraw!.addPoint(info.localStartPosition);
    } else if (lineBloc.state.isLineActiveToAddIntoGameField &&
        lineStartPoint != null) {
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
    // Finalize the line drawing.
    if (_currentFreeDraw != null) {
      // Now we need to add finishing touch
      FormModel formModel = lineBloc.state.activatedLineForm!;
      formModel.formItemModel = _currentFreeDraw!.freeDrawModel.copyWith();
      forms.add(formModel);

      _currentFreeDraw =
          null; // Set _currentFreeDraw to null after the drag ends
    } else if (lineBloc.state.isLineActiveToAddIntoGameField &&
        lineStartPoint != null &&
        _currentLine != null) {
      FormModel formModel = lineBloc.state.activatedLineForm!;
      formModel.formItemModel = _currentLine!.lineModel.copyWith(
        color: Colors.black,
      );
      formModel.offset = _currentLine!.lineModel.start;
      forms.add(formModel);

      _currentLine = null; // VERY IMPORTANT: Clear current line.
      lineStartPoint = null;

      lineBloc.add(
        UnLoadActiveLineModelToAddIntoGameFieldEvent(formModel: formModel),
      );
    }
  }

  @override
  void onDragCancel(DragCancelEvent info) {
    super.onDragCancel(info);
    // Clean up if the drag is cancelled

    if (_currentFreeDraw != null) {
      remove(_currentFreeDraw!);
      _currentFreeDraw = null;
    }
    if (_currentLine != null) {
      remove(_currentLine!);
      _currentLine = null;
      lineStartPoint = null;
      if (lineBloc.state.isLineActiveToAddIntoGameField) {
        lineBloc.add(
          UnLoadActiveLineModelToAddIntoGameFieldEvent(
            formModel: lineBloc.state.activatedLineForm!,
          ),
        );
      }
    }
  }
}
