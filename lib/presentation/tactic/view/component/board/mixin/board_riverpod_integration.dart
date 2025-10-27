import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart'; // Base class/interface
// Import the other mixins to make their types known for casting

import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart'; // Needed for method signatures
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';

import 'item_management.dart';
import 'layering_management.dart'; // Needed for method signatures

// Assuming the base class TacticBoardGame provides RiverpodGameMixin features
mixin BoardRiverpodIntegration on TacticBoardGame {
  // Method to setup listeners, moved from TacticBoard.onLoad
  void setupBoardListeners() {
    // addToGameWidgetBuild is available via RiverpodGameMixin applied to TacticBoardGame or TacticBoard
    addToGameWidgetBuild(() {
      // ref is available via RiverpodGameMixin
      ref.listen(boardProvider, (BoardState? previous, BoardState current) {
        // Explicit types might help analyzer

        // Cast 'this' to ItemManagement to call its methods
        (this as ItemManagement).checkAndRemoveComponent(previous, current);

        if (current.copyItem != null) {
          // Cast 'this' to ItemManagement to call its method
          (this as ItemManagement).copyItem(current.copyItem);
        }

        if (current.moveDown == true) {
          // Cast 'this' to LayeringManagement to call its method
          (this as LayeringManagement).moveDownElement(
            current.selectedItemOnTheBoard,
          );
          ref.read(boardProvider.notifier).moveDownComplete();
        }

        if (current.moveUp == true) {
          // Cast 'this' to LayeringManagement to call its method
          (this as LayeringManagement).moveUpElement(
            current.selectedItemOnTheBoard,
          );
          ref.read(boardProvider.notifier).moveUpComplete();
        }

        // NEW: Update PlayerComponent objects when players list changes (for bulk updates)
        if (previous != null && current.players != previous.players) {
          _updatePlayerComponentsFromState(current.players);
        }

        // NEW: Update EquipmentComponent objects when equipments list changes (for bulk updates)
        if (previous != null && current.equipments != previous.equipments) {
          _updateEquipmentComponentsFromState(current.equipments);
        }
      });

      ref.listen<bool>(
        boardProvider.select((state) => state.isDraggingItem),
        (previous, isDragging) {
          // When the flag changes, show/hide the grid
          (this as TacticBoard).grid.isHidden = !isDragging;
        },
      );
    });
  }

  /// Update PlayerComponent objects on the canvas to match the state
  void _updatePlayerComponentsFromState(List<PlayerModel> players) {
    // Create a map of players by ID for efficient lookup
    final Map<String, PlayerModel> playerMap = {
      for (var player in players) player.id: player
    };

    // Find all PlayerComponent instances in the game
    final playerComponents = children.whereType<PlayerComponent>();

    // Update each component's object property if it has changed
    for (var component in playerComponents) {
      final updatedPlayer = playerMap[component.object.id];
      if (updatedPlayer != null && updatedPlayer != component.object) {
        component.object = updatedPlayer;
      }
    }
  }

  /// Update EquipmentComponent objects on the canvas to match the state
  void _updateEquipmentComponentsFromState(List<EquipmentModel> equipments) {
    // Create a map of equipments by ID for efficient lookup
    final Map<String, EquipmentModel> equipmentMap = {
      for (var equipment in equipments) equipment.id: equipment
    };

    // Find all EquipmentComponent instances in the game
    final equipmentComponents = children.whereType<EquipmentComponent>();

    // Update each component's object property if it has changed
    for (var component in equipmentComponents) {
      final updatedEquipment = equipmentMap[component.object.id];
      if (updatedEquipment != null && updatedEquipment != component.object) {
        component.object = updatedEquipment;
      }
    }
  }
}
