import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';

const Object _sentinel = Object();

class BoardState {
  final List<PlayerModel> players;
  final List<EquipmentModel> equipments;
  final FieldItemModel? itemToDelete;
  final List<FormModel> forms;
  final AnimationModel? animationModel;
  final Map<String, dynamic> animationModelJson;
  final bool showAnimation;
  final FieldItemModel? selectedItemOnTheBoard;
  final bool forceItemModelNull;
  final FieldItemModel? copyItem;
  final bool moveDown;
  final Color boardColor;
  final bool moveUp;
  final TabController? tabController;
  final TacticBoardGame? tacticBoardGame;
  final int boardAngle;
  final Vector2? fieldSize;

  const BoardState({
    this.players = const [],
    this.equipments = const [],
    this.itemToDelete,
    this.forms = const [],
    this.animationModelJson = const {},
    this.animationModel,
    this.showAnimation = false,
    this.selectedItemOnTheBoard,
    this.forceItemModelNull = false,
    this.moveDown = false,
    this.moveUp = false,
    this.copyItem,
    this.boardColor = ColorManager.grey,
    this.fieldSize,
    this.tabController,
    this.tacticBoardGame,
    this.boardAngle = 0,
  });

  BoardState copyWith({
    List<PlayerModel>? players,
    List<EquipmentModel>? equipments,
    List<FormModel>? forms,
    AnimationModel? animationModel,
    bool? showAnimation,
    FieldItemModel? selectedItemOnTheBoard,
    bool forceItemModelNull = false,
    FieldItemModel? itemToDelete,
    bool forceItemToDeleteNull = false,
    FieldItemModel? copyItem,
    bool? moveDown,
    bool? moveUp,
    Color? boardColor,
    Map<String, dynamic>? animationModelJson,
    Vector2? fieldSize,
    TabController? tabController,
    Object? tacticBoardGame = _sentinel,
    int? boardAngle,
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
      itemToDelete:
          forceItemToDeleteNull == true
              ? null
              : itemToDelete ?? this.itemToDelete,
      copyItem: copyItem,
      moveDown: moveDown ?? this.moveDown,
      moveUp: moveUp ?? this.moveUp,
      boardColor: boardColor ?? this.boardColor,
      animationModelJson: animationModelJson ?? this.animationModelJson,
      fieldSize: fieldSize ?? this.fieldSize,
      tabController: tabController ?? this.tabController,
      tacticBoardGame:
          tacticBoardGame == _sentinel
              ? this.tacticBoardGame
              : tacticBoardGame as TacticBoardGame?,
      boardAngle: boardAngle ?? this.boardAngle,
    );
  }

  // --- CORRECTED Equality and HashCode ---
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // Use listEquals for comparing lists
    return other is BoardState &&
        runtimeType == other.runtimeType &&
        tacticBoardGame == other.tacticBoardGame;
  }

  @override
  int get hashCode {
    // Use Object.hash to combine hash codes of all fields checked in ==
    return Object.hash(tacticBoardGame, itemToDelete);
  }
}
