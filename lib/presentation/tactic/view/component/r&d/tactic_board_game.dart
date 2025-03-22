import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
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

class TacticBoardGame extends FlameGame with PanDetector {
  TacticBoardGame({required this.lineBloc});

  late GameField gameField;
  final LineBloc lineBloc;
  List<PlayerModel> players = [];
  List<EquipmentModel> equipments = [];
  List<FormModel> forms = [];
  Vector2? lineStartPoint; // Start point of the line

  // @override
  // update(double dt) {
  //   super.update(dt);
  //   zlog(data: children.toString());
  // }

  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad
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
    // TODO: implement backgroundColor
    return ColorManager.grey;
  }

  addItem(FieldItemModel item) {
    zlog(data: "On Drag end ${item.offset}");
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
  // TODO: implement debugMode
  bool get debugMode => false;

  @override
  void onPanStart(DragStartInfo info) {
    super.onPanStart(info);
    if (lineBloc.state.isLineActiveToAddIntoGameField) {
      lineStartPoint = info.raw.localPosition.toVector2();
    }
    zlog(data: "Line start ${info.raw.localPosition.toVector2()}");
  }

  @override
  void onPanEnd(DragEndInfo info) {
    super.onPanEnd(info);
    if (lineBloc.state.isLineActiveToAddIntoGameField &&
        lineStartPoint != null) {
      final lineEndPoint = info.raw.localPosition.toVector2();

      final lineModel = LineModel(
        formType: FormType.TEXT, // Or create a new FormType.LINE
        start: lineStartPoint!,
        end: lineEndPoint,
        color:
            Colors
                .black, // Or use a color from lineBloc.state.activatedLineForm
      );

      FormModel formModel = lineBloc.state.activatedLineForm!;
      formModel.formItemModel = lineModel;
      formModel.offset = lineStartPoint;

      forms.add(formModel);

      // Add the line to the game
      // addItem(formModel);

      add(
        LineDrawerComponent(
          lineModel: lineModel,
          lineColor:
              Colors
                  .black, // Or use a color from lineBloc.state.activatedLineForm
        ),
      );

      // Reset start point and line drawing mode
      lineStartPoint = null;
      lineBloc.add(
        UnLoadActiveLineModelToAddIntoGameFieldEvent(formModel: formModel),
      );
    }
    zlog(data: "Line end ${info.raw.localPosition.toVector2()}");
  }
}
