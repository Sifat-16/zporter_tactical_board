// --- Mixin for Item Management (Adding, Removing, Copying) ---
import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/form_line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

mixin ItemManagement on TacticBoardGame {
  // Public method moved from TacticBoard (Code inside unchanged)
  // This 'addItem' handles adding the COMPONENT based on the model TYPE
  addItem(FieldItemModel item, {bool save = true}) async {
    // --- Exact code from original TacticBoard.addItem ---
    if (item is PlayerModel) {
      add(PlayerComponent(object: item)); // add() is available via FlameGame
    } else if (item is EquipmentModel) {
      add(EquipmentComponent(object: item)); // add() is available via FlameGame
    } else if (item is LineModelV2) {
      await add(LineDrawerComponentV2(lineModelV2: item));
    }
    // else if (item is FreeDrawModelV2) {
    //   await add(FreeDrawerComponentV2(freeDrawModelV2: item));
    // }
    if (save) {
      ref.read(boardProvider.notifier).addBoardComponent(fieldItemModel: item);
    }
    // --- End of exact code ---
  }

  _addFreeDrawing({required List<FreeDrawModelV2> lines}) {
    try {
      resetDrawings();
    } catch (e) {}

    zlog(data: "Initial lines before ${lines}");

    ref.read(boardProvider.notifier).updateFreeDraws(lines: lines);
    List<FreeDrawModelV2> duplicateLines = lines.map((e) => e.clone()).toList();

    duplicateLines =
        duplicateLines.map((l) {
          List<Vector2> points = l.points;
          points =
              points
                  .map(
                    (p) => SizeHelper.getBoardActualVector(
                      gameScreenSize: gameField.size,
                      actualPosition: p,
                    ),
                  )
                  .toList();
          l.points = points;
          return l;
        }).toList();

    zlog(data: "Initial lines after ${duplicateLines}");
    drawingBoard = DrawingBoardComponent(
      position: gameField.position,
      initialLines: duplicateLines,
      size: gameField.size,
      eraserStrokeWidth: 20.0,
    );
    // Add the component to the game tree
    add(drawingBoard);
  }

  resetItems(List<FieldItemModel> items) {
    zlog(data: "Resetting now children is ${children}");
    removeAll(children);
    items = items.where((t) => t is! FreeDrawModelV2).toList();
    for (FieldItemModel i in items) {
      addItem(i, save: false);
    }
  }

  void resetDrawings() {
    drawingBoard.resetDrawing();
  }

  // Private/Helper methods moved from TacticBoard (Code inside unchanged)
  // Note: These methods are now accessible within any class that uses this mixin.
  // Consider renaming with leading underscores if truly intended to be "private" to the mixin's role.
  // For now, keeping original names as requested.
  void checkAndRemoveComponent(BoardState? previous, BoardState current) async {
    // --- Exact code from original TacticBoard._checkAndRemoveComponent ---
    FieldItemModel? itemToDelete = current.itemToDelete;
    zlog(data: "Item to delete ${itemToDelete.runtimeType}");
    // children and firstWhereOrNull are available via FlameGame/Component
    Component? component = children.firstWhereOrNull((t) {
      if (t is FieldComponent) {
        return t.object.id == itemToDelete?.id;
      } else if (t is LineDrawerComponentV2) {
        // Assuming LineDrawerComponent has formModel.id
        return t.lineModelV2.id == itemToDelete?.id;
      }
      // Add check for FreeDrawerComponent if it was handled previously
      // else if (t is FreeDrawerComponent) { return t.freeDrawModel.id == itemToDelete?.id }
      else {
        return false;
      }
    });
    if (component != null) {
      remove(component); // remove() is available via FlameGame
      ref.read(boardProvider.notifier).removeElementComplete();
    }
    // --- End of exact code ---
  }

  void copyItem(FieldItemModel? copyItem) {
    // --- Exact code from original TacticBoard._copyItem ---
    if (copyItem != null) {
      FieldItemModel newItem = copyItem.clone();
      newItem.id = RandomGenerator.generateId();
      // Original code used non-nullable offset. Add null check for safety if needed.
      newItem.offset = (newItem.offset ?? Vector2.zero()) + Vector2(5, 5);

      if (newItem is LineModelV2) {
        LineModelV2 updatedLine =
            newItem.clone(); // Clones the newItem FormModel
        updatedLine.start = Vector2(newItem.start.x + 10, newItem.start.y + 10);

        updatedLine.end = Vector2(newItem.end.x + 10, newItem.end.y + 10);

        LineDrawerComponentV2 newLine = LineDrawerComponentV2(
          lineModelV2: updatedLine,
        );
        add(newLine);
      } else {
        // If it's not a FormModel (e.g., Player, Equipment)
        addItem(newItem); // Calls the public addItem in this mixin
      }

      ref.read(boardProvider.notifier).copyDone();
    }
    // --- End of exact code ---
  }

  void addInitialItems(List<FieldItemModel> initialItems) {
    zlog(data: "Initial items ${initialItems}");
    ref.read(boardProvider.notifier).clearItems();
    for (var f in initialItems) {
      addItem(f);
    }
    _addFreeDrawing(
      lines:
          initialItems
              .whereType<FreeDrawModelV2>()
              .map((e) => e.clone())
              .toList(),
    );
  }
}
