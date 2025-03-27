import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/draggable_circle_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/form_line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

import 'game_field.dart';

abstract class TacticBoardGame extends FlameGame
    with DragCallbacks, TapDetector, RiverpodGameMixin {
  late GameField gameField;
}

class TacticBoard extends TacticBoardGame {
  // Changed to DragDetector
  TacticBoard();

  // final LineBloc lineBloc;
  // final BoardBloc boardBloc;

  Vector2? lineStartPoint; // Start point of the line
  LineDrawerComponent? _currentLine; // Store the currently drawing line
  FreeDrawerComponent?
  _currentFreeDraw; // Store the current free drawing component

  @override
  FutureOr<void> onLoad() async {
    addToGameWidgetBuild(() {
      ref.listen(boardProvider, (previous, current) {
        _checkAndRemoveComponent(previous, current);
        if (current.copyItem != null) {
          _copyItem(current.copyItem);
        }
        if (current.moveDown == true) {
          _moveDownElement(current.selectedItemOnTheBoard);
          ref.read(boardProvider.notifier).moveDownComplete();
        }

        if (current.moveUp == true) {
          _moveUpElement(current.selectedItemOnTheBoard);
          ref.read(boardProvider.notifier).moveUpComplete();
        }
      });
    });
    _initiateField();
    return super.onLoad();
  }

  _initiateField() {
    gameField = GameField(size: Vector2(size.x - 20, size.y - 20));
    add(gameField);
  }

  @override
  Color backgroundColor() {
    return ColorManager.grey;
  }

  addItem(FieldItemModel item) {
    if (item is PlayerModel) {
      ref.read(boardProvider.notifier).addBoardComponent(fieldItemModel: item);
      add(PlayerComponent(object: item));
    } else if (item is EquipmentModel) {
      ref.read(boardProvider.notifier).addBoardComponent(fieldItemModel: item);
      add(EquipmentComponent(object: item));
    } else if (item is FormModel) {
      ref.read(boardProvider.notifier).addBoardComponent(fieldItemModel: item);
      add(FormComponent(object: item));
    }
  }

  @override
  bool get debugMode => false;

  @override
  void onDragStart(DragStartEvent info) {
    final lp = ref.read(lineProvider);
    // Start drawing the line only if the line is active to be added
    if (lp.isFreeDrawingActive) {
      _currentFreeDraw = FreeDrawerComponent(
        freeDrawModel: FreeDrawModel(
          points: [info.localPosition],
          color: ColorManager.black, // Get color from bloc
        ),
      );
      add(_currentFreeDraw!);
    } else if (lp.isLineActiveToAddIntoGameField) {
      lineStartPoint = info.localPosition; // Use game coordinates

      // Create the line component
      FormModel formModel = lp.activatedLineForm!;
      LineModel? lineModel = formModel.formItemModel as LineModel?;

      if (lineModel != null) {
        LineModel initialLineModel = lineModel.copyWith(
          start: lineStartPoint!,
          end: lineStartPoint!, // Start with end = start
          color: formModel.color,
        );

        formModel.formItemModel = initialLineModel;

        _currentLine = LineDrawerComponent(
          formModel: formModel,
          lineModel: initialLineModel,
        );
        add(_currentLine!); // Add to component tree
      }
    }
    super.onDragStart(info); // Call super *AFTER* your custom logic
  }

  @override
  void onDragUpdate(DragUpdateEvent info) {
    super.onDragUpdate(info);
    final lp = ref.read(lineProvider);
    // Keep updating the line if it's being drawn.
    if (_currentFreeDraw != null) {
      _currentFreeDraw!.addPoint(info.localStartPosition);
    } else if (lp.isLineActiveToAddIntoGameField && lineStartPoint != null) {
      final currentPoint = info.localStartPosition;
      if (_currentLine != null) {
        _currentLine!.lineModel.end = currentPoint;
        _currentLine!.updateLine();
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent info) {
    super.onDragEnd(info);
    final lp = ref.read(lineProvider);

    // Finalize the line drawing.
    if (_currentFreeDraw != null) {
      // Now we need to add finishing touch
      FormModel formModel = lp.activatedLineForm!;
      formModel.formItemModel = _currentFreeDraw!.freeDrawModel.copyWith();
      ref
          .read(boardProvider.notifier)
          .addBoardComponent(fieldItemModel: formModel);

      _currentFreeDraw =
          null; // Set _currentFreeDraw to null after the drag ends
    } else if (lp.isLineActiveToAddIntoGameField &&
        lineStartPoint != null &&
        _currentLine != null) {
      FormModel formModel = lp.activatedLineForm!;
      formModel.formItemModel = _currentLine!.lineModel.copyWith(
        color: Colors.black,
      );
      formModel.offset = _currentLine!.lineModel.start;
      ref
          .read(boardProvider.notifier)
          .addBoardComponent(fieldItemModel: formModel);

      _currentLine = null; // VERY IMPORTANT: Clear current line.
      lineStartPoint = null;
      ref
          .read(lineProvider.notifier)
          .unLoadActiveLineModelToAddIntoGameFieldEvent(formModel: formModel);
    }
  }

  @override
  void onDragCancel(DragCancelEvent info) {
    super.onDragCancel(info);
    final lp = ref.read(lineProvider);

    // Clean up if the drag is cancelled

    if (_currentFreeDraw != null) {
      remove(_currentFreeDraw!);
      _currentFreeDraw = null;
    }
    if (_currentLine != null) {
      remove(_currentLine!);
      _currentLine = null;
      lineStartPoint = null;
      if (lp.isLineActiveToAddIntoGameField) {
        ref
            .read(lineProvider.notifier)
            .unLoadActiveLineModelToAddIntoGameFieldEvent(
              formModel: lp.activatedLineForm!,
            );
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    // TODO: implement onTapDown
    super.onTapDown(info);
    final tapPosition = info.raw.localPosition; // Position in game coordinates
    final components = componentsAtPoint(tapPosition.toVector2());
    zlog(data: "Items tapped ${components.map((e) => e.runtimeType).toList()}");
    if (components.isNotEmpty) {
      if (!components.any((t) => t is FieldComponent) &&
          !components.any((t) => t is DraggableCircleComponent) &&
          !components.any((t) => t is LineDrawerComponent)) {
        ref
            .read(boardProvider.notifier)
            .toggleSelectItemEvent(fieldItemModel: null);
      }
    }
  }

  void _checkAndRemoveComponent(
    BoardState? previous,
    BoardState current,
  ) async {
    FieldItemModel? itemToDelete = current.itemToDelete;
    zlog(data: "Item to delete ${itemToDelete.runtimeType}");
    Component? component = children.firstWhereOrNull((t) {
      if (t is FieldComponent) {
        return t.object.id == itemToDelete?.id;
      } else if (t is LineDrawerComponent) {
        return t.formModel.id == itemToDelete?.id;
      } else {
        return false;
      }
    });
    if (component != null) {
      remove(component);
      ref.read(boardProvider.notifier).removeElementComplete();
    }
  }

  void _copyItem(FieldItemModel? copyItem) {
    if (copyItem != null) {
      FieldItemModel newItem = copyItem.clone();
      newItem.id = ObjectId();
      newItem.offset = newItem.offset! + Vector2(5, 5);
      if (newItem is FormModel) {
        FormItemModel? formItemModel = newItem.formItemModel;
        if (formItemModel is LineModel) {
          LineModel newLineModel = formItemModel.clone();
          newLineModel.start = Vector2(
            newLineModel.start.x + 10,
            newLineModel.start.y + 10,
          );
          newLineModel.end = Vector2(
            newLineModel.end.x + 10,
            newLineModel.end.y + 10,
          );
          LineDrawerComponent newLine = LineDrawerComponent(
            formModel: newItem,
            lineModel: newLineModel,
          );
          add(newLine); // Add to component tree
        }
      } else {
        addItem(newItem);
      }

      ref.read(boardProvider.notifier).copyDone();
    }
  }

  // --- Helper to find the Flame Component corresponding to the model ID ---
  // --- Helper to find the Flame Component corresponding to the model ID ---
  Component? _findComponentByModelId(ObjectId? modelId) {
    if (modelId == null) return null;

    // Use standard lastWhere with orElse to return null if not found
    try {
      return children.lastWhere((component) {
        // Your existing conditions to match the component
        if (component is FieldComponent && component.object.id == modelId) {
          return true;
        }
        if (component is LineDrawerComponent &&
            component.formModel.id == modelId) {
          return true;
        }
        if (component is FormComponent && component.object.id == modelId) {
          return true;
        }
        // Add other component type checks if necessary...
        return false;
      });
    } catch (e) {
      return null;
    }
  }

  // --- Helper to get a reasonable bounding box for different component types ---
  Rect? _getComponentBounds(Component component) {
    if (component is PositionComponent) {
      if (component.size.isZero()) return null;
      return component.toRect();
    }
    if (component is LineDrawerComponent) {
      if (component.lineModel.start == component.lineModel.end) {
        return Rect.fromCenter(
          center: component.lineModel.start.toOffset(),
          width: component.lineModel.thickness,
          height: component.lineModel.thickness,
        ).inflate(2.0);
      }
      return Rect.fromPoints(
        component.lineModel.start.toOffset(),
        component.lineModel.end.toOffset(),
      ).inflate(component.lineModel.thickness + 2.0);
    }
    // Add FreeDrawerComponent bounds if it persists and needs bounds check
    // if (component is FreeDrawerComponent && component.freeDrawModel.points.isNotEmpty) { ... }
    return null;
  }

  void _moveDownElement(FieldItemModel? selectedItem) {
    // 1. Find selectedComp and selectedBounds (same as before)
    if (selectedItem == null) {
      /*... return ...*/
    }
    final selectedComp = _findComponentByModelId(selectedItem!.id);
    if (selectedComp == null) {
      /*... return ...*/
    }
    final selectedBounds = _getComponentBounds(selectedComp!);
    if (selectedBounds == null || selectedBounds.isEmpty) {
      /*... return ...*/
    }
    final int currentSelectedPriority =
        selectedComp.priority; // Store original for logging
    zlog(
      data:
          "Move Down (Simple Prio): Processing ${selectedComp.runtimeType} current prio $currentSelectedPriority",
    );

    // 2. Find overlappingUnderlying components (same as before, but include those at same level)
    List<Component> overlapping =
        []; // Find ALL overlapping relevant items first
    for (final otherComp in children.toList().reversed) {
      if (otherComp == selectedComp) continue;
      // Check if 'otherComp' is a type relevant for layering
      bool isRelevant =
          (otherComp is FieldComponent ||
              otherComp is LineDrawerComponent ||
              otherComp is FormComponent /* Add other relevant types */ ) &&
          otherComp != gameField; // Exclude the background field

      // If not relevant, skip to the next component in the loop
      if (!isRelevant) continue;
      // Note: No priority check here yet, find all overlaps first
      final otherBounds = _getComponentBounds(otherComp);
      if (otherBounds == null ||
          otherBounds.isEmpty ||
          !selectedBounds!.overlaps(otherBounds)) {
        continue;
      }
      overlapping.add(otherComp);
    }

    if (overlapping.isEmpty) {
      zlog(
        data:
            "Move Down (Simple Prio): No overlapping components found. No change.",
      );
      return;
    }
    zlog(
      data:
          "Move Down (Simple Prio): Found ${overlapping.length} overlapping components.",
    );

    // 3. Apply fixed priorities based on user request
    zlog(
      data:
          "Move Down (Simple Prio): Setting selected component (${selectedComp.runtimeType}) priority to 1.",
    );
    selectedComp.priority = 1;

    for (final otherComp in overlapping) {
      // Check if the overlapping component was originally below or at the same level
      // Only modify those that the selected item should move behind
      if (otherComp.priority <= currentSelectedPriority) {
        zlog(
          data:
              "Move Down (Simple Prio): Setting overlapping component (${otherComp.runtimeType}, original prio ${otherComp.priority}) priority to 2.",
        );
        otherComp.priority = 2;
      } else {
        // Optional: If an overlapping component was originally ABOVE the selected one,
        // should its priority also be set to 2, or left alone?
        // Let's leave items that were originally above the selected one alone to avoid pulling them down.
        zlog(
          data:
              "Move Down (Simple Prio): Skipping overlapping component (${otherComp.runtimeType}, original prio ${otherComp.priority}) as it was already above selected.",
        );
      }
    }

    // Re-filter overlappingUnderlying based on original priority <= currentSelectedPriority
    // List<Component> overlappingUnderlying = overlapping.where((c) => c.priority <= currentSelectedPriority).toList();
    // if (overlappingUnderlying.isEmpty) { /* ... handle ... */ }
    // Set selectedComp.priority = 1;
    // for (final comp in overlappingUnderlying) { comp.priority = 2; }
  }

  void _moveUpElement(FieldItemModel? selectedItem) {
    // 1. Find selectedComp, selectedBounds, currentSelectedPriority
    if (selectedItem == null) {
      /*... return ...*/
    }
    final selectedComp = _findComponentByModelId(selectedItem!.id);
    if (selectedComp == null) {
      /*... return ...*/
    }
    final selectedBounds = _getComponentBounds(selectedComp!);
    if (selectedBounds == null || selectedBounds.isEmpty) {
      /*... return ...*/
    }
    final int currentSelectedPriority = selectedComp.priority;
    zlog(
      data:
          "Move Up: Processing ${selectedComp.runtimeType} prio $currentSelectedPriority",
    );

    // 2. Find overlapping components that are originally ABOVE or AT THE SAME LEVEL
    List<Component> overlappingAbove = [];
    for (final otherComp in children.toList()) {
      // Iterate normally or reversed, doesn't matter much here
      if (otherComp == selectedComp) continue;
      // Check if 'otherComp' is a type relevant for layering
      bool isRelevant =
          (otherComp is FieldComponent ||
              otherComp is LineDrawerComponent ||
              otherComp is FormComponent /* Add other relevant types */ ) &&
          otherComp != gameField; // Exclude the background field

      // If not relevant, skip to the next component in the loop
      if (!isRelevant) continue;

      // *** Key filter: Only consider items above or at the same level ***
      if (otherComp.priority < currentSelectedPriority) continue;

      final otherBounds = _getComponentBounds(otherComp);
      if (otherBounds == null ||
          otherBounds.isEmpty ||
          !selectedBounds!.overlaps(otherBounds))
        continue;
      overlappingAbove.add(otherComp);
    }

    // 3. Check if already on top of overlaps
    if (overlappingAbove.isEmpty) {
      zlog(
        data:
            "Move Up: No overlapping components found above or at same level.",
      );
      // Optional: Move up globally? e.g., selectedComp.priority++; capped at some max
      return;
    }
    zlog(
      data:
          "Move Up: Found ${overlappingAbove.length} overlapping components above or at same level.",
    );

    // 4. Find the maximum priority among them
    int maxAbovePriority = overlappingAbove.first.priority;
    for (final comp in overlappingAbove) {
      maxAbovePriority = max(maxAbovePriority, comp.priority);
    }
    zlog(
      data:
          "Move Up: Maximum priority above/at same level is $maxAbovePriority",
    );

    // 5. Set selected component's priority above the max found
    int newPriority = maxAbovePriority + 1;
    // Optional: Check against int.maxValue if needed, highly unlikely

    // Only change if the new priority is actually higher than the current one
    if (newPriority > currentSelectedPriority) {
      selectedComp.priority = newPriority;
      zlog(data: "Move Up: Moved selected component to priority $newPriority.");
    } else {
      zlog(
        data:
            "Move Up: Selected component already effectively above or at top of overlapping items (current: $currentSelectedPriority, target: $newPriority). No change.",
      );
      // This case might happen if selected was already prio X, max above was also X. newPriority is X+1.
      // If selected was X+1, max above was X, newPriority is X+1. No change needed.
      // If selected was X, max above was X-1 (shouldn't happen due to filter), newPriority is X. No change needed.
    }

    // Do NOT change priorities of overlappingAbove components.
  }
}
