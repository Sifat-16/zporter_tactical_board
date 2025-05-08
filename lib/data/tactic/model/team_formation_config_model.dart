import 'package:flame/components.dart'; // For Vector2
import 'package:flutter/foundation.dart'; // For listEquals if you implement ==

class PlayerFormationSlot {
  final String roleInFormation;
  final String designatedPlayerId;
  final Vector2 relativePosition;

  PlayerFormationSlot({
    required this.roleInFormation,
    required this.relativePosition,
    required this.designatedPlayerId,
  }) : assert(
         relativePosition.x >= 0.0 && relativePosition.x <= 1.0,
         'Relative X (length) must be between 0.0 and 1.0',
       ),
       assert(
         relativePosition.y >= 0.0 && relativePosition.y <= 1.0,
         'Relative Y (width) must be between 0.0 and 1.0',
       );

  @override
  String toString() {
    return 'PlayerFormationSlot(role: $roleInFormation, relativePos: $relativePosition)';
  }
}

// Describes a specific lineup (e.g., "4-3-3") with all its player slots.
class LineupDetails {
  /// The name of the lineup (e.g., "4-3-3", "4-4-2").
  final String name;

  /// List of [PlayerFormationSlot] defining each player's role and relative position.
  /// The number of slots should match the `numberOfPlayers` in `TeamFormationConfig`.
  final List<PlayerFormationSlot> playerSlots;

  LineupDetails({required this.name, required this.playerSlots});

  @override
  String toString() {
    return 'LineupDetails(name: $name, slots: ${playerSlots.length})';
  }

  // Optional: Implement == and hashCode if needed
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LineupDetails &&
        other.name == name &&
        listEquals(other.playerSlots, playerSlots);
  }

  @override
  int get hashCode => name.hashCode ^ playerSlots.hashCode;
}

// Modified TeamFormationConfig to use the new detailed lineup structures.
class TeamFormationConfig {
  final int numberOfPlayers;
  final List<LineupDetails> availableLineups;
  final String defaultLineupName;
  TeamFormationConfig({
    required this.numberOfPlayers,
    required this.availableLineups,
    required this.defaultLineupName,
  }) : assert(availableLineups.isNotEmpty, 'availableLineups cannot be empty'),
       assert(
         availableLineups.any((lineup) => lineup.name == defaultLineupName),
         'defaultLineupName must match one of the names in availableLineups.',
       ),
       assert(
         availableLineups.every(
           (lineup) => lineup.playerSlots.length == numberOfPlayers,
         ),
         'Each lineup must have a number of player slots equal to numberOfPlayers.',
       );

  /// Gets the [LineupDetails] for the [defaultLineupName].
  LineupDetails get effectiveDefaultLineup {
    return availableLineups.firstWhere(
      (lineup) => lineup.name == defaultLineupName,
      // This orElse should not be reached due to the assert in the constructor.
      orElse: () => availableLineups.first,
    );
  }

  @override
  String toString() {
    return 'TeamFormationConfig(players: $numberOfPlayers, default: $defaultLineupName, lineups: ${availableLineups.map((e) => e.name).toList()})';
  }

  // Optional: Implement == and hashCode if needed
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamFormationConfig &&
        other.numberOfPlayers == numberOfPlayers &&
        listEquals(other.availableLineups, availableLineups) &&
        other.defaultLineupName == defaultLineupName;
  }

  @override
  int get hashCode =>
      numberOfPlayers.hashCode ^
      availableLineups.hashCode ^
      defaultLineupName.hashCode;
}
