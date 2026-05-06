// --- Mixin for Layering Management ---
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/circle_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/square_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/polygon_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

mixin LayeringManagement on TacticBoardGame {
  // Helper methods moved from TacticBoard (Code inside unchanged)
  Component? _findComponentByModelId(String? modelId) {
    if (modelId == null) return null;

    try {
      // children is available via FlameGame/Component
      return children.lastWhere((component) {
        // FieldComponent covers PlayerComponent and EquipmentComponent
        // since they extend FieldComponent<PlayerModel> and FieldComponent<EquipmentModel>
        if (component is FieldComponent && component.object.id == modelId) {
          return true;
        }
        // Lines
        if (component is LineDrawerComponentV2 &&
            component.lineModelV2.id == modelId) {
          return true;
        }
        // Shapes - Circle
        if (component is CircleShapeDrawerComponent &&
            component.circleModel.id == modelId) {
          return true;
        }
        // Shapes - Square
        if (component is SquareShapeDrawerComponent &&
            component.squareModel.id == modelId) {
          return true;
        }
        // Shapes - Polygon
        if (component is PolygonShapeDrawerComponent &&
            component.polygonModel.id == modelId) {
          return true;
        }
        // Text - TextFieldComponent extends FieldComponent<TextModel>
        // Already covered by FieldComponent check above
        return false;
      });
    } catch (e) {
      // lastWhere throws StateError if no element found
      return null;
    }
  }

  /// Check if a component is relevant for layering operations
  bool _isRelevantForLayering(Component component) {
    if (component == gameField) return false; // Never include the game field

    return component is FieldComponent || // Players, Equipment, Text
        component is LineDrawerComponentV2 || // Lines
        component is CircleShapeDrawerComponent || // Circle shapes
        component is SquareShapeDrawerComponent || // Square shapes
        component is PolygonShapeDrawerComponent; // Polygon shapes
  }

  Rect? _getComponentBounds(Component component) {
    // --- Exact code from original TacticBoard._getComponentBounds ---
    if (component is PositionComponent) {
      if (component.size.isZero()) return null;
      return component.toRect();
    }
    if (component is LineDrawerComponentV2) {
      // Assuming lineModel and thickness are accessible
      final lineModel =
          component.lineModelV2; // Need getter on LineDrawerComponent
      final thickness = lineModel.thickness; // Need thickness on LineModel

      if (lineModel.start == lineModel.end) {
        return Rect.fromCenter(
          center: lineModel.start.toOffset(),
          width: thickness, // Use thickness from model
          height: thickness,
        ).inflate(2.0);
      }
      return Rect.fromPoints(
        lineModel.start.toOffset(),
        lineModel.end.toOffset(),
      ).inflate(thickness + 2.0); // Use thickness from model
    }
    // Add FreeDrawerComponent bounds if it persists and needs bounds check
    // if (component is FreeDrawerComponent && component.freeDrawModel.points.isNotEmpty) { ... }
    return null;
    // --- End of exact code ---
  }

  void moveDownElement(FieldItemModel? selectedItem) {
    // 1. Find selectedComp and selectedBounds
    if (selectedItem == null) {
      return;
    }
    final selectedComp = _findComponentByModelId(selectedItem.id);
    if (selectedComp == null) {
      zlog(data: "Move Down: Could not find component for ${selectedItem.id}");
      return;
    }
    final selectedBounds = _getComponentBounds(selectedComp);
    if (selectedBounds == null || selectedBounds.isEmpty) {
      return;
    }
    final int currentSelectedPriority = selectedComp.priority;
    zlog(
      data:
          "Move Down: Processing ${selectedComp.runtimeType} current prio $currentSelectedPriority",
    );

    // 2. Find overlapping components using the helper method
    List<Component> overlapping = [];
    for (final otherComp in children.toList().reversed) {
      if (otherComp == selectedComp) continue;

      // Use the centralized helper method for relevancy check
      if (!_isRelevantForLayering(otherComp)) continue;

      // Note: No priority check here yet, find all overlaps first
      final otherBounds = _getComponentBounds(otherComp);
      if (otherBounds == null ||
          otherBounds.isEmpty ||
          !selectedBounds.overlaps(otherBounds)) {
        continue;
      }
      overlapping.add(otherComp);
    }

    if (overlapping.isEmpty) {
      zlog(
        data: "Move Down: No overlapping components found. No change.",
      );
      return;
    }
    zlog(
      data: "Move Down: Found ${overlapping.length} overlapping components.",
    );

    // 3. Apply fixed priorities based on user request
    zlog(
      data:
          "Move Down: Setting selected component (${selectedComp.runtimeType}) priority to 1.",
    );
    selectedComp.priority = 1;

    for (final otherComp in overlapping) {
      // Check if the overlapping component was originally below or at the same level
      // Only modify those that the selected item should move behind
      if (otherComp.priority <= currentSelectedPriority) {
        zlog(
          data:
              "Move Down: Setting overlapping component (${otherComp.runtimeType}, original prio ${otherComp.priority}) priority to 2.",
        );
        otherComp.priority = 2;
      } else {
        // Leave items that were originally above the selected one alone
        zlog(
          data:
              "Move Down: Skipping overlapping component (${otherComp.runtimeType}, original prio ${otherComp.priority}) as it was already above selected.",
        );
      }
    }
  }

  void moveUpElement(FieldItemModel? selectedItem) {
    // 1. Find selectedComp, selectedBounds, currentSelectedPriority
    if (selectedItem == null) {
      return;
    }
    final selectedComp = _findComponentByModelId(selectedItem.id);
    if (selectedComp == null) {
      zlog(data: "Move Up: Could not find component for ${selectedItem.id}");
      return;
    }
    final selectedBounds = _getComponentBounds(selectedComp);
    if (selectedBounds == null || selectedBounds.isEmpty) {
      return;
    }
    final int currentSelectedPriority = selectedComp.priority;
    zlog(
      data:
          "Move Up: Processing ${selectedComp.runtimeType} prio $currentSelectedPriority",
    );

    // 2. Find overlapping components that are originally ABOVE or AT THE SAME LEVEL
    List<Component> overlappingAbove = [];
    for (final otherComp in children.toList()) {
      if (otherComp == selectedComp) continue;

      // Use the centralized helper method for relevancy check
      if (!_isRelevantForLayering(otherComp)) continue;

      // *** Key filter: Only consider items above or at the same level ***
      if (otherComp.priority < currentSelectedPriority) continue;

      final otherBounds = _getComponentBounds(otherComp);
      if (otherBounds == null ||
          otherBounds.isEmpty ||
          !selectedBounds.overlaps(otherBounds)) // overlaps is from Rect
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
      maxAbovePriority = max(
        maxAbovePriority,
        comp.priority,
      ); // max is from dart:math
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
            "Move Up: Selected component already at top of overlapping items (current: $currentSelectedPriority, target: $newPriority). No change.",
      );
    }
  }

  /// Move element to absolute front (highest priority among all relevant components)
  void moveElementToFront(FieldItemModel? selectedItem) {
    if (selectedItem == null) return;

    final selectedComp = _findComponentByModelId(selectedItem.id);
    if (selectedComp == null) {
      zlog(
          data:
              "Move to Front: Could not find component for ${selectedItem.id}");
      return;
    }

    // Find max priority among all relevant components
    int maxPriority = 0;
    for (final comp in children) {
      if (_isRelevantForLayering(comp)) {
        maxPriority = max(maxPriority, comp.priority);
      }
    }

    // Set to max + 1 (but cap at 999 to leave room for drop zone at 1000)
    final newPriority = min(maxPriority + 1, 999);
    if (newPriority > selectedComp.priority) {
      // Update the Flame component's priority
      selectedComp.priority = newPriority;

      // Update the model's zIndex so it persists
      selectedItem.zIndex = newPriority;

      // Update the model in provider to trigger save
      _updateModelInProvider(selectedItem);

      // Trigger immediate save to local database
      if (this is TacticBoard) {
        (this as TacticBoard).triggerImmediateSave(reason: 'Move to front');
      }

      zlog(
          data:
              "Move to Front: Set ${selectedComp.runtimeType} to priority $newPriority");
    } else {
      zlog(
          data:
              "Move to Front: ${selectedComp.runtimeType} already at front (priority ${selectedComp.priority})");
    }
  }

  /// Move element to absolute back (priority 1, lowest among field items)
  void moveElementToBack(FieldItemModel? selectedItem) {
    if (selectedItem == null) return;

    final selectedComp = _findComponentByModelId(selectedItem.id);
    if (selectedComp == null) {
      zlog(
          data:
              "Move to Back: Could not find component for ${selectedItem.id}");
      return;
    }

    // Find all relevant components with priority 1 or 2, we need to push them up
    final componentsToAdjust = <Component>[];
    for (final comp in children) {
      if (comp == selectedComp) continue;
      if (_isRelevantForLayering(comp) && comp.priority <= 2) {
        componentsToAdjust.add(comp);
      }
    }

    // Set selected to priority 1 (back)
    selectedComp.priority = 1;

    // Update the model's zIndex so it persists
    selectedItem.zIndex = 1;

    // Push other low-priority items up by 1 to make room
    for (final comp in componentsToAdjust) {
      comp.priority = comp.priority + 1;
      // Also update the model's zIndex for these components
      _updateComponentModelZIndex(comp, comp.priority);
    }

    // Update the model in provider to trigger save
    _updateModelInProvider(selectedItem);

    // Trigger immediate save to local database
    if (this is TacticBoard) {
      (this as TacticBoard).triggerImmediateSave(reason: 'Move to back');
    }

    zlog(
        data:
            "Move to Back: Set ${selectedComp.runtimeType} to priority 1, adjusted ${componentsToAdjust.length} other components");
  }

  /// Helper to update a component's model zIndex
  void _updateComponentModelZIndex(Component comp, int newZIndex) {
    if (comp is FieldComponent) {
      comp.object.zIndex = newZIndex;
      _updateModelInProvider(comp.object);
    } else if (comp is LineDrawerComponentV2) {
      comp.lineModelV2.zIndex = newZIndex;
      ref.read(boardProvider.notifier).updateLine(line: comp.lineModelV2);
    }
    // Shape zIndex updates can be added when shape update methods are available
  }

  /// Helper to update a model in the provider to trigger persistence
  void _updateModelInProvider(FieldItemModel item) {
    if (item is PlayerModel) {
      ref.read(boardProvider.notifier).updatePlayerModel(newModel: item);
    } else if (item is EquipmentModel) {
      ref.read(boardProvider.notifier).updateEquipmentModel(newModel: item);
    }
    // Lines are handled by updateLine method
  }
}
