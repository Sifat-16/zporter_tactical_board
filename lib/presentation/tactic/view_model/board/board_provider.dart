import 'package:bot_toast/bot_toast.dart';
import 'package:flame/components.dart';
import 'package:flame/src/game/notifying_vector2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

final boardProvider = StateNotifierProvider<BoardController, BoardState>(
  (ref) => BoardController(ref),
);

class BoardController extends StateNotifier<BoardState> {
  BoardController(this.ref) : super(BoardState());

  Ref ref;

  addBoardComponent({required FieldItemModel fieldItemModel}) {
    if (fieldItemModel is PlayerModel) {
      state = state.copyWith(players: [...state.players, fieldItemModel]);
    } else if (fieldItemModel is EquipmentModel) {
      state = state.copyWith(equipments: [...state.equipments, fieldItemModel]);
    }
    // else if (fieldItemModel is FreeDrawModelV2) {
    //   state = state.copyWith(freeDraws: [...state.freeDraw, fieldItemModel]);
    // }
    else if (fieldItemModel is LineModelV2) {
      state = state.copyWith(lines: [...state.lines, fieldItemModel]);
    } else if (fieldItemModel is ShapeModel) {
      state = state.copyWith(shapes: [...state.shapes, fieldItemModel]);
    }
  }

  List<FieldItemModel> allFieldItems() {
    return [
      ...state.players,
      ...state.equipments,
      ...state.freeDraw,
      ...state.lines,
      ...state.shapes,
    ];
  }

  List<FieldItemModel> onAnimationSave() {
    Vector2? gameSize = fetchFieldSize();

    return [
      ...state.players.map((e) => e.clone()),
      ...state.equipments.map((e) => e.clone()),
      ...state.freeDraw.map((e) {
        return e.clone();
      }),
      ...state.lines.map((e) {
        return e.clone();
      }),
      ...state.shapes.map((e) {
        return e.clone();
      }),
    ];
  }

  showAnimationEvent() {
    state = state.copyWith(showAnimation: true);
    BotToast.showText(text: "Playing animation");
  }

  completeAnimationEvent() {
    state = state.copyWith(showAnimation: false);
  }

  toggleSelectItemEvent({required FieldItemModel? fieldItemModel}) {
    FieldItemModel? previousSelectedModel = state.selectedItemOnTheBoard;
    if (fieldItemModel == null) {
      state = state.copyWith(forceItemModelNull: true);
    } else {
      if (fieldItemModel.id == previousSelectedModel?.id) {
        state = state.copyWith(forceItemModelNull: true);
      } else {
        state = state.copyWith(selectedItemOnTheBoard: fieldItemModel);
      }
    }
    zlog(
      data: "Selected item to work ${state.selectedItemOnTheBoard.runtimeType}",
    );
  }

  void removeElement() {
    state = state.copyWith(itemToDelete: state.selectedItemOnTheBoard);
  }

  void removeElementComplete() {
    FieldItemModel? selectedItem = state.selectedItemOnTheBoard;
    List<PlayerModel> players = state.players;
    List<EquipmentModel> equipments = state.equipments;
    List<FreeDrawModelV2> freeDraws = state.freeDraw;
    List<LineModelV2> lines = state.lines;
    List<ShapeModel> shapes = state.shapes;
    if (selectedItem is PlayerModel) {
      players.removeWhere((t) => t.id == selectedItem.id);
    } else if (selectedItem is EquipmentModel) {
      equipments.removeWhere((t) => t.id == selectedItem.id);
    } else if (selectedItem is FreeDrawModelV2) {
      freeDraws.removeWhere((t) => t.id == selectedItem.id);
    } else if (selectedItem is LineModelV2) {
      lines.removeWhere((t) => t.id == selectedItem.id);
    } else if (selectedItem is ShapeModel) {
      shapes.removeWhere((t) => t.id == selectedItem.id);
    }
    state = state.copyWith(
      forceItemToDeleteNull: true,
      forceItemModelNull: true,
      players: players,
      equipments: equipments,
      freeDraws: freeDraws,
      lines: lines,
    );
  }

  void copyElement() {
    state = state.copyWith(copyItem: state.selectedItemOnTheBoard);
  }

  void copyDone() {
    state = state.copyWith(copyItem: null);
  }

  void moveDown() {
    state = state.copyWith(moveDown: true);
  }

  void moveDownComplete() {
    state = state.copyWith(moveDown: false);
  }

  void moveUp() {
    state = state.copyWith(moveUp: true);
  }

  void moveUpComplete() {
    state = state.copyWith(moveUp: false);
  }

  void updateBoardColor(Color color) {
    state = state.copyWith(boardColor: color);
  }

  void clearItems() {
    state = state.copyWith(
      players: [],
      equipments: [],
      freeDraws: [],
      lines: [],
      shapes: [],
    );
  }

  Vector2? fetchFieldSize() {
    return state.fieldSize;
  }

  void updateFieldSize({required NotifyingVector2 size}) {
    state = state.copyWith(fieldSize: size);
  }

  void animateToDesignTab() {
    TabController? _controller = state.tabController;
    _controller?.animateTo(0);
  }

  void updateTabController({required TabController controller}) {
    state = state.copyWith(tabController: controller);
  }

  void updateGameBoard(TacticBoardGame? game) {
    state = state.copyWith(tacticBoardGame: game);
  }

  void rotateField() {
    int angle = state.boardAngle;
    if (angle == 0) {
      angle = 1;
    } else {
      angle = 0;
    }
    state = state.copyWith(boardAngle: angle);
  }

  void updateLine({required LineModelV2 line}) {
    List<LineModelV2> lines = state.lines;
    int index = lines.indexWhere((l) => l.id == line.id);
    if (index != -1) {
      lines[index] = line;
      state = state.copyWith(lines: lines);
    }
  }

  void updateShape({required ShapeModel shape}) {
    List<ShapeModel> shapes = state.shapes;
    int index = shapes.indexWhere((l) => l.id == shape.id);
    zlog(data: "Updating shape in ${index}");
    if (index != -1) {
      shapes[index] = shape;
      state = state.copyWith(shapes: shapes);
    } else {
      shapes.add(shape);
      state = state.copyWith(shapes: shapes);
    }
  }

  void toggleFullScreen() {
    boardComparator = null;
    state = state.copyWith(showFullScreen: !state.showFullScreen);
  }

  void updateFreeDraws({required List<FreeDrawModelV2> lines}) {
    zlog(data: "Update free draws called $lines");
    state = state.copyWith(freeDraws: [...lines]);
  }

  void updateDraggingToBoard({required bool isDragging}) {
    state = state.copyWith(isDraggingElementToBoard: isDragging);
  }
}
