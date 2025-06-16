// --- Mixin for Layering Management ---
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart';

mixin LayeringManagement on TacticBoardGame {
  // Helper methods moved from TacticBoard (Code inside unchanged)
  Component? _findComponentByModelId(String? modelId) {
    // --- Exact code from original TacticBoard._findComponentByModelId ---
    if (modelId == null) return null;

    // Use standard lastWhere with orElse to return null if not found
    try {
      // children is available via FlameGame/Component
      return children.lastWhere((component) {
        // Your existing conditions to match the component
        if (component is FieldComponent && component.object.id == modelId) {
          return true;
        }
        if (component is LineDrawerComponentV2 &&
            component.lineModelV2.id == modelId) {
          return true;
        }
        // if (component is FreeDrawerComponentV2 &&
        //     component.freeDrawModelV2.id == modelId) {
        //   return true;
        // }
        // Add other component type checks if necessary...
        // e.g., FreeDrawerComponent
        return false;
      });
    } catch (e) {
      // lastWhere throws StateError if no element found
      return null;
    }
    // --- End of exact code ---
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
    // --- Exact code from original TacticBoard._moveDownElement ---
    // 1. Find selectedComp and selectedBounds (same as before)
    if (selectedItem == null) {
      /*... return ...*/ // Keep original comment style if desired
      return; // Add explicit return for clarity
    }
    final selectedComp = _findComponentByModelId(
      selectedItem.id,
    ); // Uses mixin's method
    if (selectedComp == null) {
      /*... return ...*/
      return; // Add explicit return
    }
    final selectedBounds = _getComponentBounds(
      selectedComp,
    ); // Uses mixin's method
    if (selectedBounds == null || selectedBounds.isEmpty) {
      /*... return ...*/
      return; // Add explicit return
    }
    final int currentSelectedPriority =
        selectedComp.priority; // priority is available via Component
    zlog(
      data:
          "Move Down (Simple Prio): Processing ${selectedComp.runtimeType} current prio $currentSelectedPriority",
    );

    // 2. Find overlappingUnderlying components (same as before, but include those at same level)
    List<Component> overlapping =
        []; // Find ALL overlapping relevant items first
    // children is available via FlameGame/Component
    for (final otherComp in children.toList().reversed) {
      if (otherComp == selectedComp) continue;
      // Check if 'otherComp' is a type relevant for layering
      bool isRelevant =
          (otherComp is FieldComponent || otherComp is LineDrawerComponentV2
          /* Add other relevant types */ ) &&
          otherComp != gameField; // gameField is available via TacticBoardGame

      // If not relevant, skip to the next component in the loop
      if (!isRelevant) continue;
      // Note: No priority check here yet, find all overlaps first
      final otherBounds = _getComponentBounds(otherComp); // Uses mixin's method
      if (otherBounds == null ||
          otherBounds.isEmpty ||
          !selectedBounds.overlaps(otherBounds)) {
        // overlaps is from Rect
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
    selectedComp.priority = 1; // priority is available via Component

    for (final otherComp in overlapping) {
      // Check if the overlapping component was originally below or at the same level
      // Only modify those that the selected item should move behind
      if (otherComp.priority <= currentSelectedPriority) {
        zlog(
          data:
              "Move Down (Simple Prio): Setting overlapping component (${otherComp.runtimeType}, original prio ${otherComp.priority}) priority to 2.",
        );
        otherComp.priority = 2; // priority is available via Component
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
    // --- End of exact code ---
  }

  void moveUpElement(FieldItemModel? selectedItem) {
    // --- Exact code from original TacticBoard._moveUpElement ---
    // 1. Find selectedComp, selectedBounds, currentSelectedPriority
    if (selectedItem == null) {
      /*... return ...*/
      return; // Add explicit return
    }
    final selectedComp = _findComponentByModelId(
      selectedItem.id,
    ); // Uses mixin's method
    if (selectedComp == null) {
      /*... return ...*/
      return; // Add explicit return
    }
    final selectedBounds = _getComponentBounds(
      selectedComp,
    ); // Uses mixin's method
    if (selectedBounds == null || selectedBounds.isEmpty) {
      /*... return ...*/
      return; // Add explicit return
    }
    final int currentSelectedPriority =
        selectedComp.priority; // priority is available via Component
    zlog(
      data:
          "Move Up: Processing ${selectedComp.runtimeType} prio $currentSelectedPriority",
    );

    // 2. Find overlapping components that are originally ABOVE or AT THE SAME LEVEL
    List<Component> overlappingAbove = [];
    // children is available via FlameGame/Component
    for (final otherComp in children.toList()) {
      // Iterate normally or reversed, doesn't matter much here
      if (otherComp == selectedComp) continue;
      // Check if 'otherComp' is a type relevant for layering
      bool isRelevant =
          (otherComp is FieldComponent ||
              otherComp
                  is LineDrawerComponentV2 /* Add other relevant types */ ) &&
          otherComp != gameField; // gameField is available via TacticBoardGame

      // If not relevant, skip to the next component in the loop
      if (!isRelevant) continue;

      // *** Key filter: Only consider items above or at the same level ***
      if (otherComp.priority < currentSelectedPriority) continue;

      final otherBounds = _getComponentBounds(otherComp); // Uses mixin's method
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
      selectedComp.priority =
          newPriority; // priority is available via Component
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
    // --- End of exact code ---
  }
}
