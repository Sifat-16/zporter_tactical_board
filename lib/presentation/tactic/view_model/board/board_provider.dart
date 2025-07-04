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
import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/mixin/animation_playback_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

final boardProvider = StateNotifierProvider<BoardController, BoardState>(
  (ref) => BoardController(ref),
);

class BoardController extends StateNotifier<BoardState> {
  BoardController(this.ref) : super(BoardState());

  Ref ref;

  addBoardComponent({required FieldItemModel fieldItemModel}) async {
    if (fieldItemModel is PlayerModel) {
      state = state.copyWith(players: [...state.players, fieldItemModel]);
    } else if (fieldItemModel is EquipmentModel) {
      zlog(
          data:
              "Executed the id generation process got - ${fieldItemModel.id}");
      state = state.copyWith(equipments: [...state.equipments, fieldItemModel]);
    }
    // else if (fieldItemModel is FreeDrawModelV2) {
    //   state = state.copyWith(freeDraws: [...state.freeDraw, fieldItemModel]);
    // }
    else if (fieldItemModel is LineModelV2) {
      state = state.copyWith(lines: [...state.lines, fieldItemModel]);
    } else if (fieldItemModel is ShapeModel) {
      state = state.copyWith(shapes: [...state.shapes, fieldItemModel]);
    } else if (fieldItemModel is TextModel) {
      state = state.copyWith(texts: [...state.texts, fieldItemModel]);
    }
  }

  List<FieldItemModel> allFieldItems() {
    return [
      ...state.players,
      ...state.equipments,
      ...state.freeDraw,
      ...state.lines,
      ...state.shapes,
      ...state.texts,
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
      ...state.texts.map((e) {
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

  toggleSelectItemEvent({
    required FieldItemModel? fieldItemModel,
    String? camefrom,
  }) {
    FieldItemModel? previousSelectedModel = state.selectedItemOnTheBoard;
    if (fieldItemModel == null) {
      state = state.copyWith(forceItemModelNull: true);
    } else {
      if (fieldItemModel.id == previousSelectedModel?.id) {
        state = state.copyWith(forceItemModelNull: true);
      } else {
        state = state.copyWith(selectedItemOnTheBoard: fieldItemModel);
        zlog(
          data:
              "Selected item to work ${state.selectedItemOnTheBoard.runtimeType} - ${camefrom}",
        );
      }
    }
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
    List<TextModel> texts = state.texts;
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
    } else if (selectedItem is TextModel) {
      texts.removeWhere((t) => t.id == selectedItem.id);
    }
    state = state.copyWith(
      forceItemToDeleteNull: true,
      forceItemModelNull: true,
      players: players,
      equipments: equipments,
      freeDraws: freeDraws,
      lines: lines,
      texts: texts,
    );
    BotToast.showText(text: "Item removed successfully");
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
      texts: [],
    );
  }

  Vector2? fetchFieldSize() {
    return state.fieldSize;
  }

  void updateFieldSize({required NotifyingVector2 size}) {
    state = state.copyWith(fieldSize: size);
  }

  // void animateToDesignTab() {
  //   TabController? _controller = state.tabController;
  //   _controller?.animateTo(0);
  // }

  // void updateTabController({required TabController controller}) {
  //   state = state.copyWith(tabController: controller);
  // }

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
    state = state.copyWith(showFullScreen: !state.showFullScreen);
  }

  void updateFreeDraws({required List<FreeDrawModelV2> lines}) {
    zlog(data: "Update free draws called $lines");
    state = state.copyWith(freeDraws: [...lines]);
  }

  void updateDraggingToBoard({required bool isDragging}) {
    state = state.copyWith(isDraggingElementToBoard: isDragging);
  }

  void toggleRefreshBoard(bool refresh) {
    state = state.copyWith(refreshBoard: refresh);
  }

  void removeFieldItems(List<FieldItemModel> itemsToRemove) {
    if (itemsToRemove.isEmpty) {
      zlog(
        data:
            'BoardController.removeFieldItems called with an empty list. No state change needed.',
      );
      return;
    }

    // 1. Create a set of IDs from the input list for efficient lookup.
    final Set<String> idsToRemove =
        itemsToRemove.map((item) => item.id).toSet();

    // 2. Filter State Lists: Create new lists for each type by excluding items
    //    whose IDs are present in the `idsToRemove` set.
    final List<PlayerModel> updatedPlayers = state.players
        .where((player) => !idsToRemove.contains(player.id))
        .toList();
    final List<EquipmentModel> updatedEquipments =
        state.equipments.where((eq) => !idsToRemove.contains(eq.id)).toList();
    final List<LineModelV2> updatedLines =
        state.lines.where((line) => !idsToRemove.contains(line.id)).toList();
    final List<ShapeModel> updatedShapes =
        state.shapes.where((shape) => !idsToRemove.contains(shape.id)).toList();
    // Assuming FreeDrawModelV2 instances also have a unique 'id' property.
    final List<FreeDrawModelV2> updatedFreeDraws = state.freeDraw
        .where(
          (draw) => !idsToRemove.contains(draw.id),
        ) // Ensure FreeDrawModelV2 has an 'id'
        .toList();

    final List<TextModel> updatedTexts = state.texts
        .where(
          (text) => !idsToRemove.contains(text.id),
        ) // Ensure FreeDrawModelV2 has an 'id'
        .toList();

    // Calculate if any items were actually removed from the state to avoid unnecessary updates.
    int removedCount = (state.players.length - updatedPlayers.length) +
        (state.equipments.length - updatedEquipments.length) +
        (state.lines.length - updatedLines.length) +
        (state.shapes.length - updatedShapes.length) +
        (state.freeDraw.length - updatedFreeDraws.length) +
        (state.texts.length - updatedTexts.length);

    if (removedCount > 0) {
      zlog(
        data:
            "$removedCount item(s) removed from BoardState based on the provided list of models.",
      );

      state = state.copyWith(
        players: updatedPlayers,
        equipments: updatedEquipments,
        lines: updatedLines,
        shapes: updatedShapes,
        freeDraws: updatedFreeDraws,
        texts: updatedTexts,
      );
    } else {
      zlog(
        data:
            "No items from the provided list were found in the current BoardState for removal. State remains unchanged regarding item lists.",
      );
    }
  }

  void toggleAnimating({required AnimatingObj? animatingObj}) {
    state = state.copyWith(animatingObj: animatingObj);
  }

  void updatePlayerModel({required PlayerModel newModel}) {
    List<PlayerModel> players = state.players;
    int index = players.indexWhere((p) => p.id == newModel.id);
    if (index != -1) {
      players[index] = newModel;
    }
    state = state.copyWith(players: players);
    ref.read(animationProvider.notifier).updatePlayerModel(newModel: newModel);
  }

  void updateBoardBackground(BoardBackground newBackground) {
    state = state.copyWith(boardBackground: newBackground);
  }

  void editTextComponent({required TextModel textModel}) {
    /// here we will remove and then add the text model
    try {
      TacticBoardGame tacticBoard = state.tacticBoardGame!;
      tacticBoard.remove(tacticBoard.children.firstWhere((e) {
        if (e is FieldComponent) {
          return e.object.id == textModel.id;
        } else {
          return false;
        }
      }));
      List<TextModel> texts = state.texts;
      texts.removeWhere((t) => t.id == textModel.id);

      state = state.copyWith(texts: texts);
      if (tacticBoard is TacticBoard) {
        tacticBoard.updateDatabase();
        tacticBoard.addItem(textModel);
      }
    } catch (e) {}
  }
}
