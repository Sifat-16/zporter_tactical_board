// --- Mixin for Item Management (Adding, Removing, Copying) ---
import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/text_field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/circle_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/polygon_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/square_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

mixin ItemManagement on TacticBoardGame {
  // Public method moved from TacticBoard (Code inside unchanged)
  // This 'addItem' handles adding the COMPONENT based on the model TYPE
  @override
  addItem(FieldItemModel item, {bool save = true}) async {
    // --- Exact code from original TacticBoard.addItem ---
    // item = item.copyWith();
    if (item is PlayerModel) {
      add(PlayerComponent(object: item)); // add() is available via FlameGame
    } else if (item is EquipmentModel) {
      // item = item.copyWith(id: RandomGenerator.generateId());
      add(EquipmentComponent(object: item)); // add() is available via FlameGame
    } else if (item is LineModelV2) {
      await add(LineDrawerComponentV2(lineModelV2: item));
    } else if (item is CircleShapeModel) {
      await add(CircleShapeDrawerComponent(circleModel: item));
    } else if (item is SquareShapeModel) {
      await add(SquareShapeDrawerComponent(squareModel: item));
    } else if (item is PolygonShapeModel) {
      await add(PolygonShapeDrawerComponent(polygonModel: item));
    } else if (item is TextModel) {
      await add(TextFieldComponent(object: item));
    }
    // else if (item is FreeDrawModelV2) {
    //   await add(FreeDrawerComponentV2(freeDrawModelV2: item));
    // }
    if (save) {
      ref.read(boardProvider.notifier).addBoardComponent(fieldItemModel: item);

      // Phase 1: Trigger immediate save after adding component
      if (this is TacticBoard) {
        (this as TacticBoard).triggerImmediateSave(
            reason: 'Component added: ${item.runtimeType}');
      }
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

    duplicateLines = duplicateLines.map((l) {
      List<Vector2> points = l.points;
      points = points
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

  clearItems(List<FieldItemModel> items) {
    zlog(data: "Resetting now children is ${children}");

    // Only remove item components, keep GameField, DrawingBoard, Grid, etc.
    final componentsToRemove = children.where((component) {
      return component is PlayerComponent ||
          component is EquipmentComponent ||
          component is LineDrawerComponentV2 ||
          component is SquareShapeDrawerComponent ||
          component is CircleShapeDrawerComponent ||
          component is PolygonShapeDrawerComponent ||
          component is TextFieldComponent;
    }).toList();

    removeAll(componentsToRemove);

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
      } else if (t is SquareShapeDrawerComponent) {
        return t.squareModel.id == itemToDelete?.id;
      } else if (t is CircleShapeDrawerComponent) {
        return t.circleModel.id == itemToDelete?.id;
      } else if (t is PolygonShapeDrawerComponent) {
        return t.polygonModel.id == itemToDelete?.id;
      } else if (t is TextFieldComponent) {
        return t.object.id == itemToDelete?.id;
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

      // Phase 1: Trigger immediate save after removing component
      if (this is TacticBoard) {
        (this as TacticBoard).triggerImmediateSave(
            reason: 'Component removed: ${itemToDelete?.runtimeType}');
      }
    }
    // --- End of exact code ---
  }

  void copyItem(FieldItemModel? copyItem) {
    // --- Exact code from original TacticBoard._copyItem ---
    if (copyItem != null) {
      FieldItemModel newItem = copyItem.clone();
      newItem.id = RandomGenerator.generateId();
      // Original code used non-nullable offset. Add null check for safety if needed.
      newItem.offset = (newItem.offset ?? Vector2.zero()) +
          SizeHelper.getBoardRelativeVector(
              gameScreenSize: gameField.size, actualPosition: Vector2(8, 8));

      if (newItem is LineModelV2) {
        LineModelV2 updatedLine =
            newItem.clone(); // Clones the newItem FormModel
        zlog(
            data:
                "After copying status ${newItem.offset} - ${updatedLine.start}");

        updatedLine.start = newItem.start +
            SizeHelper.getBoardRelativeVector(
                gameScreenSize: gameField.size, actualPosition: Vector2(8, 8));

        updatedLine.end = newItem.end +
            SizeHelper.getBoardRelativeVector(
                gameScreenSize: gameField.size, actualPosition: Vector2(8, 8));

        updatedLine.controlPoint2 = (newItem.controlPoint2 ?? Vector2.zero()) +
            SizeHelper.getBoardRelativeVector(
                gameScreenSize: gameField.size, actualPosition: Vector2(8, 8));

        updatedLine.controlPoint1 = (newItem.controlPoint1 ?? Vector2.zero()) +
            SizeHelper.getBoardRelativeVector(
                gameScreenSize: gameField.size, actualPosition: Vector2(8, 8));

        LineDrawerComponentV2 newLine = LineDrawerComponentV2(
          lineModelV2: updatedLine,
        );
        // add(newLine);
        addItem(updatedLine);
      } else {
        // If it's not a FormModel (e.g., Player, Equipment)
        addItem(newItem); // Calls the public addItem in this mixin
      }

      ref.read(boardProvider.notifier).copyDone();
    }
    // --- End of exact code ---
  }

  void addInitialItems(List<FieldItemModel> initialItems) async {
    zlog(data: "Initial items ${initialItems}");

    // ref.read(boardProvider.notifier).clearItems();
    // for (var f in initialItems) {
    //   await addItem(f);
    // }

    final itemsToDraw =
        initialItems.where((t) => t is! FreeDrawModelV2).toList();

    for (FieldItemModel i in itemsToDraw) {
      await addItem(i, save: false); // <-- THIS IS THE FIX. Must be save: false
    }
    _addFreeDrawing(
      lines: initialItems
          .whereType<FreeDrawModelV2>()
          .map((e) => e.clone())
          .toList(),
    );
  }

  List<FieldComponent> findMatchingFieldComponents(
    List<FieldItemModel> itemsToMatch,
  ) {
    if (itemsToMatch.isEmpty) {
      return []; // Return an empty list if there's nothing to match.
    }

    // Create a set of IDs from the input list for efficient lookup.
    final Set<String> idsToMatch = itemsToMatch.map((item) => item.id).toSet();

    // Filter the children:
    // 1. Only consider components that are of type FieldComponent.
    // 2. From those, select ones where the component's object.id is in our set of IDs.
    final List<FieldComponent> matchingComponents = children
        .whereType<FieldComponent>() // Filters for FieldComponent instances
        .where((fieldComp) {
      // fieldComp.object is the FieldItemModel (e.g., PlayerModel, EquipmentModel)
      return idsToMatch.contains(fieldComp.object.id);
    }).toList(); // Convert the resulting Iterable to a List.

    return matchingComponents;
  }

  void removeFieldItems(List<FieldItemModel> items) {
    List<FieldComponent> itemsToRemove = findMatchingFieldComponents(items);

    removeAll(itemsToRemove);
    ref.read(boardProvider.notifier).removeFieldItems(items);
  }

  addNewTextOnTheField({required TextModel object}) {
    object = object.copyWith(
      offset: SizeHelper.getBoardRelativeVector(
        gameScreenSize: gameField.size,
        actualPosition: gameField.size / 2,
      ),
    );
    add(TextFieldComponent(object: object));
    ref.read(boardProvider.notifier).addBoardComponent(fieldItemModel: object);
  }
}
