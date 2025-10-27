import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/constants/board_constant.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/mixin/animation_playback_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/model/guide_line.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';

const Object _sentinel = Object();

enum BoardBackground {
  full,
  halfUp,
  // fullDuplicate, // This is for the duplicate full pitch in the layout
  halfDown,
  verticalCorridors,
  clean,
  // horizontalZones,
  // goalNetFront,
  // goalNetAngle,
}

class BoardState {
  final List<PlayerModel> players;
  final List<EquipmentModel> equipments;
  final List<LineModelV2> lines;
  final List<ShapeModel> shapes;
  final List<TextModel> texts;
  final FieldItemModel? itemToDelete;
  final List<FreeDrawModelV2> freeDraw;
  final AnimationModel? animationModel;
  final Map<String, dynamic> animationModelJson;
  final bool showAnimation;
  final FieldItemModel? selectedItemOnTheBoard;
  final bool forceItemModelNull;
  final FieldItemModel? copyItem;
  final bool moveDown;
  final Color boardColor;
  final bool moveUp;
  // final TabController? tabController;
  final TacticBoardGame? tacticBoardGame;
  final int boardAngle;
  final Vector2? fieldSize;
  final bool showFullScreen;
  final bool isDraggingElementToBoard;
  final bool refreshBoard;
  final AnimatingObj? animatingObj;
  final BoardBackground boardBackground;

  final bool isTogglingFullscreen;

  final bool isDraggingItem;

  final List<GuideLine> activeGuides;

  final double gridSize;

  // Global team border colors (default colors for all players)
  final Color homeTeamBorderColor;
  final Color awayTeamBorderColor;

  // Toggle to apply design changes to all similar items (same team for players, same type for equipment)
  final bool applyDesignToAll;

  const BoardState(
      {this.players = const [],
      this.equipments = const [],
      this.lines = const [],
      this.texts = const [],
      this.shapes = const [],
      this.itemToDelete,
      this.freeDraw = const [],
      this.animationModelJson = const {},
      this.animationModel,
      this.showAnimation = false,
      this.selectedItemOnTheBoard,
      this.forceItemModelNull = false,
      this.moveDown = false,
      this.moveUp = false,
      this.copyItem,
      this.boardColor = BoardConstant.field_color,
      this.fieldSize,
      // this.tabController,
      this.tacticBoardGame,
      this.refreshBoard = false,
      this.boardAngle = 0,
      this.showFullScreen = false,
      this.isDraggingElementToBoard = false,
      this.boardBackground = BoardBackground.full,
      this.isTogglingFullscreen = false,
      this.isDraggingItem = false,
      this.activeGuides = const [],
      this.gridSize = 50.0,
      this.homeTeamBorderColor = Colors.blue,
      this.awayTeamBorderColor = Colors.red,
      this.applyDesignToAll = false,
      this.animatingObj});

  BoardState copyWith({
    List<PlayerModel>? players,
    List<EquipmentModel>? equipments,
    List<LineModelV2>? lines,
    List<ShapeModel>? shapes,
    List<TextModel>? texts,
    List<FreeDrawModelV2>? freeDraws,
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
    // TabController? tabController,
    Object? tacticBoardGame = _sentinel,
    int? boardAngle,
    bool? refreshBoard,
    bool? showFullScreen,
    bool? isDraggingElementToBoard,
    bool? isAnimating,
    Object? animatingObj = _sentinel,
    BoardBackground? boardBackground,
    bool? isTogglingFullscreen,
    bool? isDraggingItem,
    List<GuideLine>? activeGuides,
    double? gridSize,
    Color? homeTeamBorderColor,
    Color? awayTeamBorderColor,
    bool? applyDesignToAll,
  }) {
    return BoardState(
        players: players ?? this.players,
        equipments: equipments ?? this.equipments,
        shapes: shapes ?? this.shapes,
        freeDraw: freeDraws ?? freeDraw,
        texts: texts ?? this.texts,
        animationModel: animationModel ?? this.animationModel,
        showAnimation: showAnimation ?? this.showAnimation,
        selectedItemOnTheBoard: forceItemModelNull == true
            ? null
            : selectedItemOnTheBoard ?? this.selectedItemOnTheBoard,
        itemToDelete: forceItemToDeleteNull == true
            ? null
            : itemToDelete ?? this.itemToDelete,
        copyItem: copyItem,
        moveDown: moveDown ?? this.moveDown,
        moveUp: moveUp ?? this.moveUp,
        boardColor: boardColor ?? this.boardColor,
        animationModelJson: animationModelJson ?? this.animationModelJson,
        fieldSize: fieldSize ?? this.fieldSize,
        // tabController: tabController ?? this.tabController,
        tacticBoardGame: tacticBoardGame == _sentinel
            ? this.tacticBoardGame
            : tacticBoardGame as TacticBoardGame?,
        boardAngle: boardAngle ?? this.boardAngle,
        lines: lines ?? this.lines,
        showFullScreen: showFullScreen ?? this.showFullScreen,
        isDraggingElementToBoard:
            isDraggingElementToBoard ?? this.isDraggingElementToBoard,
        refreshBoard: refreshBoard ?? this.refreshBoard,
        boardBackground: boardBackground ?? this.boardBackground,
        isTogglingFullscreen: isTogglingFullscreen ?? this.isTogglingFullscreen,
        isDraggingItem: isDraggingItem ?? this.isDraggingItem,
        activeGuides: activeGuides ?? this.activeGuides,
        gridSize: gridSize ?? this.gridSize,
        homeTeamBorderColor: homeTeamBorderColor ?? this.homeTeamBorderColor,
        awayTeamBorderColor: awayTeamBorderColor ?? this.awayTeamBorderColor,
        applyDesignToAll: applyDesignToAll ?? this.applyDesignToAll,
        animatingObj: animatingObj == _sentinel
            ? this.animatingObj
            : animatingObj as AnimatingObj?);
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
