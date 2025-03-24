import 'package:equatable/equatable.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';

class BoardState extends Equatable {
  final List<PlayerModel> players;
  final List<EquipmentModel> equipments;
  final List<FormModel> forms;
  final AnimationModel? animationModel;
  final bool showAnimation;

  const BoardState({
    this.players = const [],
    this.equipments = const [],
    this.forms = const [],
    this.animationModel,
    this.showAnimation = false,
  });

  BoardState copyWith({
    List<PlayerModel>? players,
    List<EquipmentModel>? equipments,
    List<FormModel>? forms,
    AnimationModel? animationModel,
    bool? showAnimation,
  }) {
    return BoardState(
      players: players ?? this.players,
      equipments: equipments ?? this.equipments,
      forms: forms ?? this.forms,
      animationModel: animationModel ?? this.animationModel,
      showAnimation: showAnimation ?? this.showAnimation,
    );
  }

  @override
  List<Object?> get props => [players, equipments, forms, animationModel];
}
