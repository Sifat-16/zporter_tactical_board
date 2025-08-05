// // lib/presentation/tactic/services/lineup_arrangement_service.dart
//
// import 'package:flame/components.dart';
// import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
//
// /// A data class to hold all the necessary inputs for the arrangement algorithm.
// /// This makes the service's method signature clean and easily extensible.
// class LineupArrangementInput {
//   /// The definitive list of players currently on the field. This is the
//   /// primary source of truth for who should be in the new formation.
//   final List<PlayerModel> currentPlayersOnField;
//
//   /// The definitive list of players currently on the bench for this team.
//   /// Used for substitutions if the new formation requires more players.
//   final List<PlayerModel> currentPlayersOnBench;
//
//   /// The formation template scene, which contains the target positions
//   /// (as PlayerModels with offsets and permanent jerseyNumbers).
//   final AnimationItemModel targetFormationTemplate;
//
//   LineupArrangementInput({
//     required this.currentPlayersOnField,
//     required this.currentPlayersOnBench,
//     required this.targetFormationTemplate,
//   });
// }
//
// /// A data class to hold the complete result of the arrangement calculation.
// /// This provides the UI layer with everything it needs to perform an atomic update.
// class LineupArrangementResult {
//   /// The final, calculated list of players with their new positions.
//   /// This is the list that should be rendered on the tactical board.
//   final List<PlayerModel> finalLineup;
//
//   LineupArrangementResult({
//     required this.finalLineup,
//   });
// }
//
// /// A service dedicated to calculating player lineup arrangements based on the
// /// "Player-First" and "Squad Identity" (`jerseyNumber`) principles.
// ///
// /// This service is stateless and its `arrange` method is a pure function,
// /// meaning for a given input, it will always produce the same output.
// class LineupArrangementService {
//   /// Calculates the new arrangement for a team's lineup.
//   ///
//   /// Takes a [LineupArrangementInput] containing the current state of the field
//   /// and the desired new formation.
//   ///
//   /// Returns a [LineupArrangementResult] containing the final list of players
//   /// with their updated positions.
//   ///
//   /// The algorithm follows these steps:
//   /// 1. Creates a map of target positions from the new formation template based on `jerseyNumber`.
//   /// 2. Prioritizes keeping players who are currently on the field.
//   /// 3. **Pass 1:** Assigns on-field players to their corresponding `jerseyNumber` slot in the new formation.
//   /// 4. **Pass 2:** Assigns any remaining on-field players to any remaining empty slots.
//   /// 5. **Pass 3:** If more players are needed, fills the last remaining slots from the bench.
//   LineupArrangementResult arrange(LineupArrangementInput input) {
//     // --- Step 1: Create a Target Position Map from the template ---
//     final positionMap = _createPositionMap(input.targetFormationTemplate);
//
//     // --- Step 2: Initialize lists ---
//     final List<PlayerModel> finalLineup = [];
//     final List<PlayerModel> unassignedFieldPlayers =
//         List.from(input.currentPlayersOnField);
//
//     // --- Step 3: Pass 1 - Assign players by jerseyNumber match ---
//     _assignPlayersBySquadNumber(
//       unassignedFieldPlayers: unassignedFieldPlayers,
//       positionMap: positionMap,
//       finalLineup: finalLineup,
//     );
//
//     // --- Step 4: Pass 2 - Assign remaining on-field players to remaining slots ---
//     _assignRemainingFieldPlayers(
//       unassignedFieldPlayers: unassignedFieldPlayers,
//       positionMap: positionMap,
//       finalLineup: finalLineup,
//     );
//
//     // --- Step 5: Pass 3 - Fill any last empty slots from the bench ---
//     _fillFromBench(
//       benchPlayers: input.currentPlayersOnBench,
//       positionMap: positionMap,
//       finalLineup: finalLineup,
//     );
//
//     return LineupArrangementResult(finalLineup: finalLineup);
//   }
//
//   /// Creates a map of {jerseyNumber: offset} from a formation template.
//   Map<int, Vector2> _createPositionMap(AnimationItemModel template) {
//     final Map<int, Vector2> map = {};
//     final templatePlayers = template.components.whereType<PlayerModel>();
//     for (final player in templatePlayers) {
//       if (player.offset != null) {
//         // The jerseyNumber from the template defines the slot number.
//         map[player.jerseyNumber] = player.offset!;
//       }
//     }
//     return map;
//   }
//
//   /// **Pass 1:** Iterates through on-field players and places them in the
//   /// new formation if their permanent `jerseyNumber` matches an empty slot.
//   void _assignPlayersBySquadNumber({
//     required List<PlayerModel> unassignedFieldPlayers,
//     required Map<int, Vector2> positionMap,
//     required List<PlayerModel> finalLineup,
//   }) {
//     // Iterate over a copy to safely remove items from the original list.
//     for (final player in List.from(unassignedFieldPlayers)) {
//       if (positionMap.containsKey(player.jerseyNumber)) {
//         final newOffset = positionMap[player.jerseyNumber]!;
//         finalLineup.add(player.copyWith(offset: newOffset));
//
//         // This player and this slot are now assigned. Remove them from consideration.
//         positionMap.remove(player.jerseyNumber);
//         unassignedFieldPlayers.remove(player);
//       }
//     }
//   }
//
//   /// **Pass 2:** Fills the remaining empty formation slots with the remaining
//   /// on-field players. This ensures the same XI stay on the field.
//   void _assignRemainingFieldPlayers({
//     required List<PlayerModel> unassignedFieldPlayers,
//     required Map<int, Vector2> positionMap,
//     required List<PlayerModel> finalLineup,
//   }) {
//     while (unassignedFieldPlayers.isNotEmpty && positionMap.isNotEmpty) {
//       // Get the next available player and the next available slot.
//       final playerToAssign = unassignedFieldPlayers.removeAt(0);
//       final slotJerseyNumber = positionMap.keys.first;
//       final newOffset = positionMap.remove(slotJerseyNumber)!;
//
//       finalLineup.add(playerToAssign.copyWith(offset: newOffset));
//     }
//   }
//
//   /// **Pass 3:** If the new formation requires more players than are currently
//   /// on the field, this method fills the last empty slots with players from the bench.
//   void _fillFromBench({
//     required List<PlayerModel> benchPlayers,
//     required Map<int, Vector2> positionMap,
//     required List<PlayerModel> finalLineup,
//   }) {
//     // We iterate through a copy of the map's keys to safely modify the map.
//     for (final int slotJerseyNumber in List.from(positionMap.keys)) {
//       // Find the specific player on the bench who matches the slot's required number.
//       // The `collection` package provides `firstWhereOrNull`.
//       final PlayerModel? playerForSlot = benchPlayers.firstWhereOrNull(
//         (p) => p.jerseyNumber == slotJerseyNumber,
//       );
//
//       if (playerForSlot != null) {
//         // Get the offset for this slot from the map.
//         final newOffset = positionMap[slotJerseyNumber]!;
//
//         // Add the correctly matched player with the correct offset to the lineup.
//         finalLineup.add(playerForSlot.copyWith(offset: newOffset));
//
//         // Remove the slot from the map as it is now filled.
//         positionMap.remove(slotJerseyNumber);
//       }
//     }
//   }
// }

// lib/presentation/tactic/services/lineup_arrangement_service.dart

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';

// --- NEW: Enum to define the logical player categories ---
enum PlayerCategory { GOALKEEPER, DEFENDER, MIDFIELDER, FORWARD, UNKNOWN }

// The Input and Result classes remain unchanged.
class LineupArrangementInput {
  final List<PlayerModel> currentPlayersOnField;
  final List<PlayerModel> currentPlayersOnBench;
  final AnimationItemModel targetFormationTemplate;

  LineupArrangementInput({
    required this.currentPlayersOnField,
    required this.currentPlayersOnBench,
    required this.targetFormationTemplate,
  });
}

class LineupArrangementResult {
  final List<PlayerModel> finalLineup;

  LineupArrangementResult({
    required this.finalLineup,
  });
}

/// A service dedicated to calculating player lineup arrangements using a
/// role-aware, multi-pass algorithm.
class LineupArrangementService {
  /// --- NEW: Helper to determine a player's category from their role string ---
  PlayerCategory _getCategoryFromRole(String role) {
    switch (role.toUpperCase()) {
      case 'GK':
        return PlayerCategory.GOALKEEPER;
      case 'CB':
      case 'LB':
      case 'RB':
      case 'WB':
        return PlayerCategory.DEFENDER;
      case 'CDM':
      case 'CM':
      case 'CAM':
      case 'LM':
      case 'RM':
        return PlayerCategory.MIDFIELDER;
      case 'ST':
      case 'CF':
      case 'LW':
      case 'RW':
      case 'F':
      case 'W':
        return PlayerCategory.FORWARD;
      default:
        return PlayerCategory.UNKNOWN;
    }
  }

  /// --- REWRITTEN: The new, more intelligent multi-pass arrangement algorithm ---
  LineupArrangementResult arrange(LineupArrangementInput input) {
    final List<PlayerModel> finalLineup = [];

    // --- SETUP: Create a map of all target positions from the template ---
    // The value is a Tuple of (Offset, RoleCategory)
    final Map<int, (Vector2, PlayerCategory)> positionMap = {};
    for (final player
        in input.targetFormationTemplate.components.whereType<PlayerModel>()) {
      if (player.offset != null) {
        positionMap[player.jerseyNumber] =
            (player.offset!, _getCategoryFromRole(player.role));
      }
    }

    // --- PASS 1: THE GOALKEEPER RULE ---
    // The GK position is sacred and must be handled first.
    final gkSlotNumber = positionMap.keys.firstWhereOrNull(
        (k) => positionMap[k]!.$2 == PlayerCategory.GOALKEEPER);

    if (gkSlotNumber != null) {
      final gkOnField = input.currentPlayersOnField.firstWhereOrNull(
          (p) => _getCategoryFromRole(p.role) == PlayerCategory.GOALKEEPER);
      final gkOnBench = input.currentPlayersOnBench.firstWhereOrNull(
          (p) => _getCategoryFromRole(p.role) == PlayerCategory.GOALKEEPER);

      final gkToPlace = gkOnField ?? gkOnBench;

      if (gkToPlace != null) {
        final gkPosition = positionMap.remove(gkSlotNumber)!;
        finalLineup.add(gkToPlace.copyWith(offset: gkPosition.$1));
      }
    }

    // --- SETUP FOR OUTFIELD PLAYERS ---
    final List<PlayerModel> unassignedFieldPlayers = input.currentPlayersOnField
        .where((p) => _getCategoryFromRole(p.role) != PlayerCategory.GOALKEEPER)
        .toList();

    List<PlayerModel> fullBench = List.from(input.currentPlayersOnBench.where(
        (p) => _getCategoryFromRole(p.role) != PlayerCategory.GOALKEEPER));

    // --- PASS 2: PERFECT FIT (jerseyNumber Match) ---
    // Assign on-field players who perfectly match an open slot number.
    _assignPlayersByJerseyNumber(
        unassignedFieldPlayers: unassignedFieldPlayers,
        positionMap: positionMap,
        finalLineup: finalLineup);

    // --- PASS 3: SMART FILL (Role Category Match) ---
    // Assign remaining on-field players to an open slot OF THE SAME CATEGORY.
    _assignPlayersByCategory(
        unassignedFieldPlayers: unassignedFieldPlayers,
        positionMap: positionMap,
        finalLineup: finalLineup);

    // --- PASS 4: BEST EFFORT FILL (Last Resort for On-Field Players) ---
    // Assign any remaining on-field players to any remaining open slot.
    _assignRemainingFieldPlayers(
        unassignedFieldPlayers: unassignedFieldPlayers,
        positionMap: positionMap,
        finalLineup: finalLineup);

    // --- PASS 5: INTELLIGENT BENCH FILLING ---
    // Fill any finally remaining slots from the bench, using the same smart logic.
    _fillFromBench(
        benchPlayers: fullBench,
        positionMap: positionMap,
        finalLineup: finalLineup);

    return LineupArrangementResult(finalLineup: finalLineup);
  }

  // --- HELPER METHODS FOR EACH PASS ---

  void _assignPlayersByJerseyNumber({
    required List<PlayerModel> unassignedFieldPlayers,
    required Map<int, (Vector2, PlayerCategory)> positionMap,
    required List<PlayerModel> finalLineup,
  }) {
    for (final player in List.from(unassignedFieldPlayers)) {
      if (positionMap.containsKey(player.jerseyNumber)) {
        final position = positionMap.remove(player.jerseyNumber)!;
        finalLineup.add(player.copyWith(offset: position.$1));
        unassignedFieldPlayers.remove(player);
      }
    }
  }

  void _assignPlayersByCategory({
    required List<PlayerModel> unassignedFieldPlayers,
    required Map<int, (Vector2, PlayerCategory)> positionMap,
    required List<PlayerModel> finalLineup,
  }) {
    for (final player in List.from(unassignedFieldPlayers)) {
      final playerCategory = _getCategoryFromRole(player.role);
      final matchingCategorySlot = positionMap.keys
          .firstWhereOrNull((k) => positionMap[k]!.$2 == playerCategory);

      if (matchingCategorySlot != null) {
        final position = positionMap.remove(matchingCategorySlot)!;
        finalLineup.add(player.copyWith(offset: position.$1));
        unassignedFieldPlayers.remove(player);
      }
    }
  }

  void _assignRemainingFieldPlayers({
    required List<PlayerModel> unassignedFieldPlayers,
    required Map<int, (Vector2, PlayerCategory)> positionMap,
    required List<PlayerModel> finalLineup,
  }) {
    while (unassignedFieldPlayers.isNotEmpty && positionMap.isNotEmpty) {
      final player = unassignedFieldPlayers.removeAt(0);
      final slotKey = positionMap.keys.first;
      final position = positionMap.remove(slotKey)!;
      finalLineup.add(player.copyWith(offset: position.$1));
    }
  }

  void _fillFromBench({
    required List<PlayerModel> benchPlayers,
    required Map<int, (Vector2, PlayerCategory)> positionMap,
    required List<PlayerModel> finalLineup,
  }) {
    // Pass 1 for bench: Perfect jerseyNumber match
    for (final int slotNumber in List.from(positionMap.keys)) {
      final playerForSlot =
          benchPlayers.firstWhereOrNull((p) => p.jerseyNumber == slotNumber);
      if (playerForSlot != null) {
        final position = positionMap.remove(slotNumber)!;
        finalLineup.add(playerForSlot.copyWith(offset: position.$1));
        benchPlayers.remove(playerForSlot);
      }
    }

    // Pass 2 for bench: Category match
    for (final int slotNumber in List.from(positionMap.keys)) {
      final slotCategory = positionMap[slotNumber]!.$2;
      final playerForSlot = benchPlayers.firstWhereOrNull(
          (p) => _getCategoryFromRole(p.role) == slotCategory);
      if (playerForSlot != null) {
        final position = positionMap.remove(slotNumber)!;
        finalLineup.add(playerForSlot.copyWith(offset: position.$1));
        benchPlayers.remove(playerForSlot);
      }
    }
  }
}
