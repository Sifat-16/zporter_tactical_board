// import 'package:bot_toast/bot_toast.dart';
// import 'package:flame/components.dart';
// import 'package:flame/src/game/notifying_vector2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/mixin/animation_playback_mixin.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/model/guide_line.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';
//
// final boardProvider = StateNotifierProvider<BoardController, BoardState>(
//   (ref) => BoardController(ref),
// );
//
// class BoardController extends StateNotifier<BoardState> {
//   BoardController(this.ref) : super(BoardState());
//
//   Ref ref;
//
//   addBoardComponent({required FieldItemModel fieldItemModel}) async {
//     if (fieldItemModel is PlayerModel) {
//       state = state.copyWith(players: [...state.players, fieldItemModel]);
//     } else if (fieldItemModel is EquipmentModel) {
//       zlog(
//           data:
//               "Executed the id generation process got - ${fieldItemModel.id}");
//       state = state.copyWith(equipments: [...state.equipments, fieldItemModel]);
//     }
//     // else if (fieldItemModel is FreeDrawModelV2) {
//     //   state = state.copyWith(freeDraws: [...state.freeDraw, fieldItemModel]);
//     // }
//     else if (fieldItemModel is LineModelV2) {
//       state = state.copyWith(lines: [...state.lines, fieldItemModel]);
//     } else if (fieldItemModel is ShapeModel) {
//       state = state.copyWith(shapes: [...state.shapes, fieldItemModel]);
//     } else if (fieldItemModel is TextModel) {
//       state = state.copyWith(texts: [...state.texts, fieldItemModel]);
//     }
//   }
//
//   List<FieldItemModel> allFieldItems() {
//     return [
//       ...state.players,
//       ...state.equipments,
//       ...state.freeDraw,
//       ...state.lines,
//       ...state.shapes,
//       ...state.texts,
//     ];
//   }
//
//   List<FieldItemModel> onAnimationSave() {
//     Vector2? gameSize = fetchFieldSize();
//
//     return [
//       ...state.players.map((e) => e.clone()),
//       ...state.equipments.map((e) => e.clone()),
//       ...state.freeDraw.map((e) {
//         return e.clone();
//       }),
//       ...state.lines.map((e) {
//         return e.clone();
//       }),
//       ...state.shapes.map((e) {
//         return e.clone();
//       }),
//       ...state.texts.map((e) {
//         return e.clone();
//       }),
//     ];
//   }
//
//   void initializeFromScene(AnimationItemModel? scene) {
//     if (scene == null) {
//       // If the scene is null, clear the board state.
//       state = state.copyWith(
//         players: [],
//         equipments: [],
//         freeDraws: [],
//         lines: [],
//         shapes: [],
//         texts: [],
//         boardColor: ColorManager.grey, // or your default color
//         forceItemModelNull: true,
//       );
//       return;
//     }
//
//     // If a scene is provided, categorize its components and update the state.
//     final List<PlayerModel> players = [];
//     final List<EquipmentModel> equipments = [];
//     final List<FreeDrawModelV2> freeDraws = [];
//     final List<LineModelV2> lines = [];
//     final List<ShapeModel> shapes = [];
//     final List<TextModel> texts = [];
//
//     for (final item in scene.components) {
//       if (item is PlayerModel) {
//         players.add(item);
//       } else if (item is EquipmentModel)
//         equipments.add(item);
//       else if (item is FreeDrawModelV2)
//         freeDraws.add(item);
//       else if (item is LineModelV2)
//         lines.add(item);
//       else if (item is ShapeModel)
//         shapes.add(item);
//       else if (item is TextModel) texts.add(item);
//     }
//
//     // Use copyWith to update the state in a single, immutable operation.
//     state = state.copyWith(
//       players: players,
//       equipments: equipments,
//       freeDraws: freeDraws,
//       lines: lines,
//       shapes: shapes,
//       texts: texts,
//       boardColor: scene.fieldColor,
//       forceItemModelNull: true, // Deselect any previously selected item
//     );
//     zlog(data: "BoardProvider state has been seeded from scene: ${scene.id}");
//   }
//
//   showAnimationEvent() {
//     state = state.copyWith(showAnimation: true);
//     BotToast.showText(text: "Playing animation");
//   }
//
//   completeAnimationEvent() {
//     state = state.copyWith(showAnimation: false);
//   }
//
//   toggleSelectItemEvent({
//     required FieldItemModel? fieldItemModel,
//     String? camefrom,
//   }) {
//     FieldItemModel? previousSelectedModel = state.selectedItemOnTheBoard;
//     if (fieldItemModel == null) {
//       state = state.copyWith(forceItemModelNull: true);
//     } else {
//       if (fieldItemModel.id == previousSelectedModel?.id) {
//         state = state.copyWith(forceItemModelNull: true);
//       } else {
//         state = state.copyWith(selectedItemOnTheBoard: fieldItemModel);
//         zlog(
//           data:
//               "Selected item to work ${state.selectedItemOnTheBoard.runtimeType} - ${camefrom}",
//         );
//       }
//     }
//   }
//
//   void removeElement() {
//     state = state.copyWith(itemToDelete: state.selectedItemOnTheBoard);
//   }
//
//   void removeElementComplete() {
//     FieldItemModel? selectedItem = state.selectedItemOnTheBoard;
//     List<PlayerModel> players = state.players;
//     List<EquipmentModel> equipments = state.equipments;
//     List<FreeDrawModelV2> freeDraws = state.freeDraw;
//     List<LineModelV2> lines = state.lines;
//     List<ShapeModel> shapes = state.shapes;
//     List<TextModel> texts = state.texts;
//     if (selectedItem is PlayerModel) {
//       players.removeWhere((t) => t.id == selectedItem.id);
//     } else if (selectedItem is EquipmentModel) {
//       equipments.removeWhere((t) => t.id == selectedItem.id);
//     } else if (selectedItem is FreeDrawModelV2) {
//       freeDraws.removeWhere((t) => t.id == selectedItem.id);
//     } else if (selectedItem is LineModelV2) {
//       lines.removeWhere((t) => t.id == selectedItem.id);
//     } else if (selectedItem is ShapeModel) {
//       shapes.removeWhere((t) => t.id == selectedItem.id);
//     } else if (selectedItem is TextModel) {
//       texts.removeWhere((t) => t.id == selectedItem.id);
//     }
//     state = state.copyWith(
//       forceItemToDeleteNull: true,
//       forceItemModelNull: true,
//       players: players,
//       equipments: equipments,
//       freeDraws: freeDraws,
//       lines: lines,
//       texts: texts,
//     );
//     BotToast.showText(text: "Item removed successfully");
//   }
//
//   void copyElement() {
//     state = state.copyWith(copyItem: state.selectedItemOnTheBoard);
//   }
//
//   void copyDone() {
//     state = state.copyWith(copyItem: null);
//   }
//
//   void moveDown() {
//     state = state.copyWith(moveDown: true);
//   }
//
//   void moveDownComplete() {
//     state = state.copyWith(moveDown: false);
//   }
//
//   void moveUp() {
//     state = state.copyWith(moveUp: true);
//   }
//
//   void moveUpComplete() {
//     state = state.copyWith(moveUp: false);
//   }
//
//   void updateBoardColor(Color color) {
//     state = state.copyWith(boardColor: color);
//   }
//
//   void clearItems() {
//     state = state.copyWith(
//       players: [],
//       equipments: [],
//       freeDraws: [],
//       lines: [],
//       shapes: [],
//       texts: [],
//     );
//   }
//
//   Vector2? fetchFieldSize() {
//     return state.fieldSize;
//   }
//
//   void updateFieldSize({required NotifyingVector2 size}) {
//     state = state.copyWith(fieldSize: size);
//   }
//
//   // void animateToDesignTab() {
//   //   TabController? _controller = state.tabController;
//   //   _controller?.animateTo(0);
//   // }
//
//   // void updateTabController({required TabController controller}) {
//   //   state = state.copyWith(tabController: controller);
//   // }
//
//   void updateGameBoard(TacticBoardGame? game) {
//     state = state.copyWith(tacticBoardGame: game);
//   }
//
//   void rotateField() {
//     int angle = state.boardAngle;
//     if (angle == 0) {
//       angle = 1;
//     } else {
//       angle = 0;
//     }
//     state = state.copyWith(boardAngle: angle);
//   }
//
//   void updateLine({required LineModelV2 line}) {
//     List<LineModelV2> lines = state.lines;
//     int index = lines.indexWhere((l) => l.id == line.id);
//     if (index != -1) {
//       lines[index] = line;
//       state = state.copyWith(lines: lines);
//     }
//   }
//
//   void updateShape({required ShapeModel shape}) {
//     List<ShapeModel> shapes = state.shapes;
//     int index = shapes.indexWhere((l) => l.id == shape.id);
//     zlog(data: "Updating shape in ${index}");
//     if (index != -1) {
//       shapes[index] = shape;
//       state = state.copyWith(shapes: shapes);
//     } else {
//       shapes.add(shape);
//       state = state.copyWith(shapes: shapes);
//     }
//   }
//
//   // void toggleFullScreen() {
//   //   state = state.copyWith(showFullScreen: !state.showFullScreen);
//   // }
//
//   Future<void> toggleFullScreen() async {
//     // 1. Turn the spinner ON immediately.
//     state = state.copyWith(isTogglingFullscreen: true);
//     final game = state.tacticBoardGame;
//
//     try {
//       // --- THIS IS THE OPTIMIZATION ---
//       // Only force a save IF the game instance reports it has unsaved changes.
//       if (game is TacticBoard && game.isDirty) {
//         zlog(data: "Toggle: Data is dirty, forcing save...");
//
//         // 2. Run our robust save logic
//         await ref
//             .read(animationProvider.notifier)
//             .updateDatabaseOnChange(saveToDb: true);
//
//         // 3. Reset the auto-save timer
//         game.forceUpdateComparator();
//       } else {
//         zlog(data: "Toggle: Data is clean, skipping save.");
//         // Data is clean. Do nothing.
//       }
//       // --- END OF OPTIMIZATION ---
//     } catch (e) {
//       zlog(data: "Failed during fullscreen toggle save check: $e");
//     }
//
//     // 4. NOW toggle the screen and turn the spinner OFF.
//     state = state.copyWith(
//       showFullScreen: !state.showFullScreen,
//       isTogglingFullscreen: false,
//     );
//   }
//
//   void updateFreeDraws({required List<FreeDrawModelV2> lines}) {
//     zlog(data: "Update free draws called $lines");
//     state = state.copyWith(freeDraws: [...lines]);
//   }
//
//   void updateDraggingToBoard({required bool isDragging}) {
//     state = state.copyWith(isDraggingElementToBoard: isDragging);
//   }
//
//   void toggleRefreshBoard(bool refresh) {
//     state = state.copyWith(refreshBoard: refresh);
//   }
//
//   void removeFieldItems(List<FieldItemModel> itemsToRemove) {
//     if (itemsToRemove.isEmpty) {
//       zlog(
//         data:
//             'BoardController.removeFieldItems called with an empty list. No state change needed.',
//       );
//       return;
//     }
//
//     // 1. Create a set of IDs from the input list for efficient lookup.
//     final Set<String> idsToRemove =
//         itemsToRemove.map((item) => item.id).toSet();
//
//     // 2. Filter State Lists: Create new lists for each type by excluding items
//     //    whose IDs are present in the `idsToRemove` set.
//     final List<PlayerModel> updatedPlayers = state.players
//         .where((player) => !idsToRemove.contains(player.id))
//         .toList();
//     final List<EquipmentModel> updatedEquipments =
//         state.equipments.where((eq) => !idsToRemove.contains(eq.id)).toList();
//     final List<LineModelV2> updatedLines =
//         state.lines.where((line) => !idsToRemove.contains(line.id)).toList();
//     final List<ShapeModel> updatedShapes =
//         state.shapes.where((shape) => !idsToRemove.contains(shape.id)).toList();
//     // Assuming FreeDrawModelV2 instances also have a unique 'id' property.
//     final List<FreeDrawModelV2> updatedFreeDraws = state.freeDraw
//         .where(
//           (draw) => !idsToRemove.contains(draw.id),
//         ) // Ensure FreeDrawModelV2 has an 'id'
//         .toList();
//
//     final List<TextModel> updatedTexts = state.texts
//         .where(
//           (text) => !idsToRemove.contains(text.id),
//         ) // Ensure FreeDrawModelV2 has an 'id'
//         .toList();
//
//     // Calculate if any items were actually removed from the state to avoid unnecessary updates.
//     int removedCount = (state.players.length - updatedPlayers.length) +
//         (state.equipments.length - updatedEquipments.length) +
//         (state.lines.length - updatedLines.length) +
//         (state.shapes.length - updatedShapes.length) +
//         (state.freeDraw.length - updatedFreeDraws.length) +
//         (state.texts.length - updatedTexts.length);
//
//     if (removedCount > 0) {
//       zlog(
//         data:
//             "$removedCount item(s) removed from BoardState based on the provided list of models.",
//       );
//
//       state = state.copyWith(
//         players: updatedPlayers,
//         equipments: updatedEquipments,
//         lines: updatedLines,
//         shapes: updatedShapes,
//         freeDraws: updatedFreeDraws,
//         texts: updatedTexts,
//       );
//     } else {
//       zlog(
//         data:
//             "No items from the provided list were found in the current BoardState for removal. State remains unchanged regarding item lists.",
//       );
//     }
//   }
//
//   void toggleAnimating({required AnimatingObj? animatingObj}) {
//     state = state.copyWith(animatingObj: animatingObj);
//   }
//
//   void updatePlayerModel({required PlayerModel newModel}) {
//     List<PlayerModel> players = state.players;
//     int index = players.indexWhere((p) => p.id == newModel.id);
//     if (index != -1) {
//       players[index] = newModel;
//     }
//     state = state.copyWith(players: players);
//     ref.read(animationProvider.notifier).updatePlayerModel(newModel: newModel);
//   }
//
//   void updateBoardBackground(BoardBackground newBackground) {
//     state = state.copyWith(boardBackground: newBackground);
//   }
//
//   void editTextComponent({required TextModel textModel}) {
//     /// here we will remove and then add the text model
//     try {
//       TacticBoardGame tacticBoard = state.tacticBoardGame!;
//       tacticBoard.remove(tacticBoard.children.firstWhere((e) {
//         if (e is FieldComponent) {
//           return e.object.id == textModel.id;
//         } else {
//           return false;
//         }
//       }));
//       List<TextModel> texts = state.texts;
//       texts.removeWhere((t) => t.id == textModel.id);
//
//       state = state.copyWith(texts: texts);
//       if (tacticBoard is TacticBoard) {
//         tacticBoard.updateDatabase();
//         tacticBoard.addItem(textModel);
//       }
//     } catch (e) {}
//   }
//
//   void toggleItemDrag(bool isDragging) {
//     state = state.copyWith(isDraggingItem: isDragging);
//   }
//
//   void updateGuides(List<GuideLine> guides) {
//     state = state.copyWith(activeGuides: guides);
//   }
//
//   void clearGuides() {
//     state = state.copyWith(activeGuides: const []);
//   }
//
//   void updateGridSize(double newSize) {
//     state = state.copyWith(gridSize: newSize);
//   }
// }

import 'package:bot_toast/bot_toast.dart';
import 'package:flame/components.dart';
import 'package:flame/src/game/notifying_vector2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/app/services/user_preferences_service.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
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
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

final boardProvider = StateNotifierProvider<BoardController, BoardState>(
  (ref) => BoardController(ref),
);

class BoardController extends StateNotifier<BoardState> {
  BoardController(this.ref) : super(BoardState()) {
    _loadTeamColorsFromPreferences();
  }

  Ref ref;

  /// Load team border colors from user preferences on initialization
  Future<void> _loadTeamColorsFromPreferences() async {
    final prefsService = sl.get<UserPreferencesService>();
    final homeColor = await prefsService.getHomeTeamBorderColor();
    final awayColor = await prefsService.getAwayTeamBorderColor();

    state = state.copyWith(
      homeTeamBorderColor: homeColor,
      awayTeamBorderColor: awayColor,
    );
  }

  addBoardComponent({required FieldItemModel fieldItemModel}) async {
    if (fieldItemModel is PlayerModel) {
      state = state.copyWith(players: [...state.players, fieldItemModel]);
    } else if (fieldItemModel is EquipmentModel) {
      zlog(
          data:
              "Executed the id generation process got - ${fieldItemModel.id}");
      state = state.copyWith(equipments: [...state.equipments, fieldItemModel]);
    } else if (fieldItemModel is LineModelV2) {
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

  void initializeFromScene(AnimationItemModel? scene) {
    if (scene == null) {
      state = state.copyWith(
        players: [],
        equipments: [],
        freeDraws: [],
        lines: [],
        shapes: [],
        texts: [],
        boardColor: ColorManager.grey,
        forceItemModelNull: true,
      );
      return;
    }

    final List<PlayerModel> players = [];
    final List<EquipmentModel> equipments = [];
    final List<FreeDrawModelV2> freeDraws = [];
    final List<LineModelV2> lines = [];
    final List<ShapeModel> shapes = [];
    final List<TextModel> texts = [];

    for (final item in scene.components) {
      if (item is PlayerModel) {
        players.add(item);
      } else if (item is EquipmentModel)
        equipments.add(item);
      else if (item is FreeDrawModelV2)
        freeDraws.add(item);
      else if (item is LineModelV2)
        lines.add(item);
      else if (item is ShapeModel)
        shapes.add(item);
      else if (item is TextModel) texts.add(item);
    }

    state = state.copyWith(
      players: players,
      equipments: equipments,
      freeDraws: freeDraws,
      lines: lines,
      shapes: shapes,
      texts: texts,
      boardColor: scene.fieldColor,
      forceItemModelNull: true,
    );
    zlog(data: "BoardProvider state has been seeded from scene: ${scene.id}");
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

  Future<void> toggleFullScreen() async {
    state = state.copyWith(isTogglingFullscreen: true);
    final game = state.tacticBoardGame;

    try {
      if (game is TacticBoard && game.isDirty) {
        zlog(data: "Toggle: Data is dirty, forcing save...");
        await ref.read(animationProvider.notifier).updateDatabaseOnChange(
            saveToDb: true,
            isAutoSave: false); // Manual save on fullscreen toggle
        game.forceUpdateComparator();
      } else {
        zlog(data: "Toggle: Data is clean, skipping save.");
      }
    } catch (e) {
      zlog(data: "Failed during fullscreen toggle save check: $e");
    }

    state = state.copyWith(
      showFullScreen: !state.showFullScreen,
      isTogglingFullscreen: false,
    );
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

  // NEW: Toggle the "Apply to All Similar Items" setting
  void toggleApplyDesignToAll(bool value) {
    state = state.copyWith(applyDesignToAll: value);
    zlog(data: "Apply design to all similar items: $value");
  }

  // NEW: Toggle trajectory editing mode
  void toggleTrajectoryEditing(bool value) {
    state = state.copyWith(trajectoryEditingEnabled: value);
    zlog(data: "Trajectory editing enabled: $value");
  }

  // NEW: Get all similar items to the currently selected item
  List<FieldItemModel> getSimilarItems() {
    final selectedItem = state.selectedItemOnTheBoard;
    if (selectedItem == null) return [];

    if (selectedItem is PlayerModel) {
      // Return all players of the same team
      return state.players
          .where((p) =>
              p.playerType == selectedItem.playerType &&
              p.id != selectedItem.id)
          .cast<FieldItemModel>()
          .toList();
    } else if (selectedItem is EquipmentModel) {
      // Return all equipment of the same type (same name)
      return state.equipments
          .where((e) => e.name == selectedItem.name && e.id != selectedItem.id)
          .cast<FieldItemModel>()
          .toList();
    }

    return [];
  }

  // NEW: Update multiple players at once (bulk update)
  void updateMultiplePlayers({required List<PlayerModel> updatedPlayers}) {
    if (updatedPlayers.isEmpty) return;

    // Create a map of updated players by ID for efficient lookup
    final Map<String, PlayerModel> updatedMap = {
      for (var player in updatedPlayers) player.id: player
    };

    // Update the players list - create a completely new list to ensure state change detection
    List<PlayerModel> players = [
      ...state.players.map((p) {
        return updatedMap.containsKey(p.id) ? updatedMap[p.id]! : p;
      })
    ];

    state = state.copyWith(players: players);

    // Also update in animation provider for each player
    for (var player in updatedPlayers) {
      ref.read(animationProvider.notifier).updatePlayerModel(newModel: player);
    }

    zlog(data: "Updated ${updatedPlayers.length} players in bulk");
  }

  // NEW: Update multiple equipments at once (bulk update)
  void updateMultipleEquipments(
      {required List<EquipmentModel> updatedEquipments}) {
    if (updatedEquipments.isEmpty) return;

    // Create a map of updated equipment by ID for efficient lookup
    final Map<String, EquipmentModel> updatedMap = {
      for (var equipment in updatedEquipments) equipment.id: equipment
    };

    // Update the equipments list - create a completely new list to ensure state change detection
    List<EquipmentModel> equipments = [
      ...state.equipments.map((e) {
        return updatedMap.containsKey(e.id) ? updatedMap[e.id]! : e;
      })
    ];

    state = state.copyWith(equipments: equipments);
    zlog(data: "Updated ${updatedEquipments.length} equipments in bulk");
  }

  void removeFieldItems(List<FieldItemModel> itemsToRemove) {
    if (itemsToRemove.isEmpty) {
      zlog(
        data:
            'BoardController.removeFieldItems called with an empty list. No state change needed.',
      );
      return;
    }

    final Set<String> idsToRemove =
        itemsToRemove.map((item) => item.id).toSet();
    final List<PlayerModel> updatedPlayers = state.players
        .where((player) => !idsToRemove.contains(player.id))
        .toList();
    final List<EquipmentModel> updatedEquipments =
        state.equipments.where((eq) => !idsToRemove.contains(eq.id)).toList();
    final List<LineModelV2> updatedLines =
        state.lines.where((line) => !idsToRemove.contains(line.id)).toList();
    final List<ShapeModel> updatedShapes =
        state.shapes.where((shape) => !idsToRemove.contains(shape.id)).toList();
    final List<FreeDrawModelV2> updatedFreeDraws = state.freeDraw
        .where(
          (draw) => !idsToRemove.contains(draw.id),
        )
        .toList();

    final List<TextModel> updatedTexts = state.texts
        .where(
          (text) => !idsToRemove.contains(text.id),
        )
        .toList();

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

  void toggleItemDrag(bool isDragging) {
    state = state.copyWith(isDraggingItem: isDragging);
  }

  void updateGuides(List<GuideLine> guides) {
    state = state.copyWith(activeGuides: guides);
  }

  void clearGuides() {
    state = state.copyWith(activeGuides: const []);
  }

  void updateGridSize(double newSize) {
    state = state.copyWith(gridSize: newSize);
  }

  // Update global home team border color
  void updateHomeTeamBorderColor(Color color) {
    state = state.copyWith(homeTeamBorderColor: color);
    // Save to user preferences
    sl.get<UserPreferencesService>().setHomeTeamBorderColor(color);
  }

  // Update global away team border color
  void updateAwayTeamBorderColor(Color color) {
    state = state.copyWith(awayTeamBorderColor: color);
    // Save to user preferences
    sl.get<UserPreferencesService>().setAwayTeamBorderColor(color);
  }

  // NEW: Method to update an equipment model in the state
  void updateEquipmentModel({required EquipmentModel newModel}) {
    // Create a mutable copy of the current list of equipments
    final equipments = List<EquipmentModel>.from(state.equipments);

    // Find the index of the model we need to update
    final index = equipments.indexWhere((e) => e.id == newModel.id);

    // If it exists, replace it with the new version
    if (index != -1) {
      equipments[index] = newModel;
      // Update the state with the new list
      state = state.copyWith(equipments: equipments);
    }
  }
}
