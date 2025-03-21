import 'dart:async';

import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';

import 'game_field.dart';

class TacticBoardGame extends FlameGame {
  late GameField gameField;
  List<PlayerModel> players = [];
  List<EquipmentModel> equipments = [];
  List<FormModel> forms = [];

  // @override
  // update(double dt) {
  //   super.update(dt);
  //   zlog(data: children.toString());
  // }

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
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
    print("On Drag end ${item.offset}");
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
}
