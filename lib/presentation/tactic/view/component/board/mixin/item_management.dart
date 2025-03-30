// --- Mixin for Item Management (Adding, Removing, Copying) ---
import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/form_line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

mixin ItemManagement on TacticBoardGame {
  // Public method moved from TacticBoard (Code inside unchanged)
  // This 'addItem' handles adding the COMPONENT based on the model TYPE
  addItem(FieldItemModel item) async {
    // --- Exact code from original TacticBoard.addItem ---
    if (item is PlayerModel) {
      ref.read(boardProvider.notifier).addBoardComponent(fieldItemModel: item);
      add(PlayerComponent(object: item)); // add() is available via FlameGame
    } else if (item is EquipmentModel) {
      ref.read(boardProvider.notifier).addBoardComponent(fieldItemModel: item);
      add(EquipmentComponent(object: item)); // add() is available via FlameGame
    } else if (item is FormModel) {
      if (item.formItemModel is LineModel) {
        await add(
          LineDrawerComponent(
            // lineModel: (item.formItemModel as LineModel),
            formModel: item,
          ),
        );
      } else {
        await add(FormComponent(object: item));
      }
      ref.read(boardProvider.notifier).addBoardComponent(fieldItemModel: item);
      // add(FormComponent(object: item)); // add() is available via FlameGame
    }
    // --- End of exact code ---
  }

  resetItems(List<FieldItemModel> items) {
    removeAll(children);
    for (FieldItemModel i in items) {
      addItem(i);
    }
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
      } else if (t is LineDrawerComponent) {
        // Assuming LineDrawerComponent has formModel.id
        return t.formModel.id == itemToDelete?.id;
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

      if (newItem is FormModel) {
        // Check if formItemModel exists before cloning
        FormItemModel? formItemModel = newItem.formItemModel?.clone();
        // Re-create the FormModel to ensure we have a distinct object if needed,
        // or just update the formItemModel on the cloned newItem.
        // Original code cloned the FormModel again, let's stick to that for now.
        FormModel updatedForm = newItem.clone(); // Clones the newItem FormModel
        updatedForm.formItemModel =
            formItemModel; // Assign the cloned item model

        if (formItemModel is LineModel) {
          // Clone the line model again to modify it (as per original logic)
          LineModel newLineModel = formItemModel.clone();
          newLineModel.start = Vector2(
            newLineModel.start.x + 10,
            newLineModel.start.y + 10,
          );
          newLineModel.end = Vector2(
            newLineModel.end.x + 10,
            newLineModel.end.y + 10,
          );

          // Update the form model reference on the 'updatedForm'
          updatedForm.formItemModel =
              newLineModel
                  .clone(); // Clone again before assigning? Original did this.

          // Add the specific component for the line
          LineDrawerComponent newLine = LineDrawerComponent(
            formModel: updatedForm,
          );
          add(newLine); // add() is available via FlameGame
          // NOTE: The original code here adds a *LineDrawerComponent*
          // but doesn't seem to call the general 'addItem' which adds a *FormComponent*.
          // Stick to the original logic: add LineDrawerComponent directly.
        }
        // Add handling for FreeDrawModel if it was part of the original logic
        // else if (formItemModel is FreeDrawModel) { ... add(FreeDrawerComponent(...)) ... }
        else {
          // If it's a FormModel but not a LineModel (and not FreeDraw if handled)
          // what should happen? Original code falls through to the 'else' below.
          // This implies non-line/non-free-draw FormModels are handled by the general `addItem`. Let's replicate.
          addItem(newItem); // Calls the public addItem in this mixin
        }
      } else {
        // If it's not a FormModel (e.g., Player, Equipment)
        addItem(newItem); // Calls the public addItem in this mixin
      }

      ref.read(boardProvider.notifier).copyDone();
    }
    // --- End of exact code ---
  }

  void addInitialItems(List<FieldItemModel> initialItems) {
    ref.read(boardProvider.notifier).clearItems();
    for (var f in initialItems) {
      addItem(f);
    }
  }
}
