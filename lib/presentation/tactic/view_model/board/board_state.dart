import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';

class BoardState {
  final List<PlayerModel> players;
  final List<EquipmentModel> equipments;
  final List<FormModel> forms;
  final AnimationModel? animationModel;
  final bool showAnimation;
  final FieldItemModel? selectedItemOnTheBoard;
  final bool forceItemModelNull;

  const BoardState({
    this.players = const [],
    this.equipments = const [],
    this.forms = const [],
    this.animationModel,
    this.showAnimation = false,
    this.selectedItemOnTheBoard,
    this.forceItemModelNull = false,
  });

  BoardState copyWith({
    List<PlayerModel>? players,
    List<EquipmentModel>? equipments,
    List<FormModel>? forms,
    AnimationModel? animationModel,
    bool? showAnimation,
    FieldItemModel? selectedItemOnTheBoard,
    bool forceItemModelNull = false,
  }) {
    return BoardState(
      players: players ?? this.players,
      equipments: equipments ?? this.equipments,
      forms: forms ?? this.forms,
      animationModel: animationModel ?? this.animationModel,
      showAnimation: showAnimation ?? this.showAnimation,
      selectedItemOnTheBoard:
          forceItemModelNull == true
              ? null
              : selectedItemOnTheBoard ?? this.selectedItemOnTheBoard,
    );
  }
}
