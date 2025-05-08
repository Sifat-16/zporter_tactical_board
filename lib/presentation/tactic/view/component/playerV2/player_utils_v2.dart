import 'dart:ui';

import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/datastructures/tuple.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/team_formation_config_model.dart';

class PlayerUtilsV2 {
  static List<Tuple3<String, String, int>> homePlayers = [
    Tuple3("GK", "660211dca1b2c3d4e5f6a810", 1), // Hex will vary
    Tuple3("RB", "660211dca1b2c3d4e5f6a811", 2), // Hex will vary
    Tuple3("LB", "660211dca1b2c3d4e5f6a812", 3), // Hex will vary
    Tuple3("CB", "660211dca1b2c3d4e5f6a813", 4), // Hex will vary
    Tuple3("CM", "660211dca1b2c3d4e5f6a814", 5), // Hex will vary
    Tuple3("AM", "660211dca1b2c3d4e5f6a815", 6), // Hex will vary
    Tuple3(
      "AM",
      "660211dca1b2c3d4e5f6a816",
      7,
    ), // Hex will vary (different from previous AM)
    Tuple3("S", "660211dca1b2c3d4e5f6a817", 8), // Hex will vary
    Tuple3("RW", "660211dca1b2c3d4e5f6a818", 9), // Hex will vary
    Tuple3("LW", "660211dca1b2c3d4e5f6a819", 10), // Hex will vary
    Tuple3("FW", "660211dca1b2c3d4e5f6a81a", 11), // Hex will vary
    Tuple3("CAM", "660211dca1b2c3d4e5f6a81b", 12), // Hex will vary
    Tuple3("CDM", "660211dca1b2c3d4e5f6a81c", 13), // Hex will vary
    Tuple3("RM", "660211dca1b2c3d4e5f6a81d", 14), // Hex will vary
    Tuple3(
      "GK",
      "660211dca1b2c3d4e5f6a81e",
      15,
    ), // Hex will vary (different from previous GK)
    Tuple3(
      "RB",
      "660211dca1b2c3d4e5f6a81f",
      16,
    ), // Hex will vary (different from previous RB)
    Tuple3(
      "LB",
      "660211dca1b2c3d4e5f6a820",
      17,
    ), // Hex will vary (different from previous LB)
    Tuple3(
      "CB",
      "660211dca1b2c3d4e5f6a821",
      18,
    ), // Hex will vary (different from previous CB)
    Tuple3(
      "CB",
      "660211dca1b2c3d4e5f6a822",
      19,
    ), // Hex will vary (different from previous CBs)
    Tuple3(
      "CM",
      "660211dca1b2c3d4e5f6a823",
      20,
    ), // Hex will vary (different from previous CM)
    Tuple3(
      "AM",
      "660211dca1b2c3d4e5f6a824",
      21,
    ), // Hex will vary (different from previous AMs)
    Tuple3(
      "AM",
      "660211dca1b2c3d4e5f6a825",
      22,
    ), // Hex will vary (different from previous AMs)
    Tuple3(
      "S",
      "660211dca1b2c3d4e5f6a826",
      23,
    ), // Hex will vary (different from previous S)
  ];

  static List<Tuple3<String, String, int>> awayPlayers = [
    Tuple3(
      "GK",
      "660212e8a1b2c3d4e5f6a830",
      1,
    ), // Hex will vary & differ from home
    Tuple3(
      "RB",
      "660212e8a1b2c3d4e5f6a831",
      2,
    ), // Hex will vary & differ from home
    Tuple3(
      "LB",
      "660212e8a1b2c3d4e5f6a832",
      3,
    ), // Hex will vary & differ from home
    Tuple3(
      "CB",
      "660212e8a1b2c3d4e5f6a833",
      4,
    ), // Hex will vary & differ from home
    Tuple3(
      "CM",
      "660212e8a1b2c3d4e5f6a834",
      5,
    ), // Hex will vary & differ from home
    Tuple3(
      "AM",
      "660212e8a1b2c3d4e5f6a835",
      6,
    ), // Hex will vary & differ from home
    Tuple3(
      "AM",
      "660212e8a1b2c3d4e5f6a836",
      7,
    ), // Hex will vary & differ from home
    Tuple3(
      "S",
      "660212e8a1b2c3d4e5f6a837",
      8,
    ), // Hex will vary & differ from home
    Tuple3(
      "RW",
      "660212e8a1b2c3d4e5f6a838",
      9,
    ), // Hex will vary & differ from home
    Tuple3(
      "LW",
      "660212e8a1b2c3d4e5f6a839",
      10,
    ), // Hex will vary & differ from home
    Tuple3(
      "FW",
      "660212e8a1b2c3d4e5f6a83a",
      11,
    ), // Hex will vary & differ from home
    Tuple3(
      "CAM",
      "660212e8a1b2c3d4e5f6a83b",
      12,
    ), // Hex will vary & differ from home
    Tuple3(
      "CDM",
      "660212e8a1b2c3d4e5f6a83c",
      13,
    ), // Hex will vary & differ from home
    Tuple3(
      "RM",
      "660212e8a1b2c3d4e5f6a83d",
      14,
    ), // Hex will vary & differ from home
    Tuple3(
      "GK",
      "660212e8a1b2c3d4e5f6a83e",
      15,
    ), // Hex will vary & differ from home
    Tuple3(
      "RB",
      "660212e8a1b2c3d4e5f6a83f",
      16,
    ), // Hex will vary & differ from home
    Tuple3(
      "LB",
      "660212e8a1b2c3d4e5f6a840",
      17,
    ), // Hex will vary & differ from home
    Tuple3(
      "CB",
      "660212e8a1b2c3d4e5f6a841",
      18,
    ), // Hex will vary & differ from home
    Tuple3(
      "CB",
      "660212e8a1b2c3d4e5f6a842",
      19,
    ), // Hex will vary & differ from home
    Tuple3(
      "CM",
      "660212e8a1b2c3d4e5f6a843",
      20,
    ), // Hex will vary & differ from home
    Tuple3(
      "AM",
      "660212e8a1b2c3d4e5f6a844",
      21,
    ), // Hex will vary & differ from home
    Tuple3(
      "AM",
      "660212e8a1b2c3d4e5f6a845",
      22,
    ), // Hex will vary & differ from home
    Tuple3(
      "S",
      "660212e8a1b2c3d4e5f6a846",
      23,
    ), // Hex will vary & differ from home
  ];

  static List<Tuple3<String, String, int>> otherPlayers = [
    // Fixed, unique 24-character hex strings
    Tuple3("REF", "F1XED0THERPLAYERID00001", 1), // Referee 1
    Tuple3("REF", "F1XED0THERPLAYERID00002", 2), // Referee 2 (AR1)
    Tuple3("REF", "F1XED0THERPLAYERID00003", 3), // Referee 3 (AR2)
    Tuple3("REF", "F1XED0THERPLAYERID00004", 4), // Referee 4 (Fourth Official)
    Tuple3("REF", "F1XED0THERPLAYERID00005", 5), // Referee 5 (VAR)
    Tuple3("REF", "F1XED0THERPLAYERID00006", 6), // Referee 6 (AVAR)
    Tuple3("HC", "F1XED0THERPLAYERID00007", -1), // Head Coach
    Tuple3("AC", "F1XED0THERPLAYERID00008", -1), // Assistant Coach
    Tuple3("GKC", "F1XED0THERPLAYERID00009", -1), // Goalkeeper Coach
    Tuple3(
      "SPC",
      "F1XED0THERPLAYERID00010",
      -1,
    ), // Set Piece Coach / Specialist
    Tuple3("ANA", "F1XED0THERPLAYERID00011", -1), // Analyst
    Tuple3("TM", "F1XED0THERPLAYERID00012", -1), // Team Manager
    Tuple3("PHY", "F1XED0THERPLAYERID00013", -1), // Physio / Medical Staff
    Tuple3("DR", "F1XED0THERPLAYERID00014", -1), // Doctor
    Tuple3("SD", "F1XED0THERPLAYERID00015", -1), // Sporting Director / Other
  ];

  static double _getKickoffX(double originalFullFieldX) {
    const double gkPos = 0.05;
    // Define the typical range of outfield players in your *original* full-field layouts
    const double minOrigOutfieldX =
        0.15; // Adjust if your deepest player is different
    const double maxOrigOutfieldX =
        0.75; // Adjust if your most advanced player is different

    // Define the target range for outfield players at kick-off
    const double halfWayLine = 0.5;
    const double margin = 0.005;
    const double maxKickoffX =
        halfWayLine - margin; // Target max X (e.g., 0.495)
    const double minKickoffOutfieldX =
        0.15; // Keep deepest players around X=0.20

    if (originalFullFieldX <= gkPos) {
      return gkPos;
    }
    if (originalFullFieldX <= minOrigOutfieldX) {
      return minKickoffOutfieldX;
    }
    if (originalFullFieldX >= maxOrigOutfieldX) {
      return maxKickoffX;
    }

    if ((maxOrigOutfieldX - minOrigOutfieldX).abs() < 0.01) {
      return minKickoffOutfieldX;
    }
    final double scaleFactor =
        (maxKickoffX - minKickoffOutfieldX) /
        (maxOrigOutfieldX - minOrigOutfieldX);
    final double kickoffX =
        minKickoffOutfieldX +
        (originalFullFieldX - minOrigOutfieldX) * scaleFactor;

    return kickoffX.clamp(minKickoffOutfieldX, maxKickoffX);
  }

  /// Calculates the final away player's position for kick-off.
  /// Takes the HOME player's KICK-OFF position as input.
  /// Ensures Away X is exactly opposite Home X relative to the midline (X=0.5).
  /// Away Y is identical to Home Y.
  static Vector2 _getProcessedAwayPosition(
    Vector2
    homePlayerKickoffPos, // Input is the KICK-OFF position of the home player
    String roleInFormation,
  ) {
    double finalAwayX = 0.5 + (0.5 - homePlayerKickoffPos.x) + 0.015;
    double finalAwayY = homePlayerKickoffPos.y;
    finalAwayX = finalAwayX.clamp(0.0, 1.0);
    finalAwayY = finalAwayY.clamp(0.0, 1.0);

    return Vector2(finalAwayX, finalAwayY);
  }

  static final List<TeamFormationConfig> _homeConfigurations = [
    TeamFormationConfig(
      numberOfPlayers: 11,
      defaultLineupName: "4-3-3",
      availableLineups: [
        LineupDetails(
          name: "4-3-3",
          playerSlots: [
            // Kick-off positions calculated using _getKickoffX logic
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ), // K: 0.05
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.85),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ), // O: 0.25 -> K: 0.223
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.60),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ), // O: 0.20 -> K: 0.200
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.40),
              designatedPlayerId: "660211dca1b2c3d4e5f6a821",
            ), // O: 0.20 -> K: 0.200
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.15),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ), // O: 0.25 -> K: 0.223
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.70),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ), // O: 0.50 -> K: 0.336
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.45), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81c",
            ), // O: 0.45 -> K: 0.314
            PlayerFormationSlot(
              roleInFormation: "AM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.30),
              designatedPlayerId: "660211dca1b2c3d4e5f6a815",
            ), // O: 0.50 -> K: 0.336
            PlayerFormationSlot(
              roleInFormation: "RW",
              relativePosition: Vector2(_getKickoffX(0.75), 0.80),
              designatedPlayerId: "660211dca1b2c3d4e5f6a818",
            ), // O: 0.75 -> K: 0.450
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.80), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ), // O: 0.80 -> K: 0.472
            PlayerFormationSlot(
              roleInFormation: "LW",
              relativePosition: Vector2(_getKickoffX(0.75), 0.20),
              designatedPlayerId: "660211dca1b2c3d4e5f6a819",
            ), // O: 0.75 -> K: 0.450
          ],
        ),
        LineupDetails(
          name: "4-4-2",
          playerSlots: [
            // Recalculated Kick-off positions
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.90),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.60),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.40),
              designatedPlayerId: "660211dca1b2c3d4e5f6a821",
            ),
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.10),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ),
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.85),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81d",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.60),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.40),
              designatedPlayerId: "660211dca1b2c3d4e5f6a823",
            ),
            PlayerFormationSlot(
              roleInFormation: "AM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.15),
              designatedPlayerId: "660211dca1b2c3d4e5f6a816",
            ),
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.80), 0.60),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ),
            PlayerFormationSlot(
              roleInFormation: "FW",
              relativePosition: Vector2(_getKickoffX(0.80), 0.40),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81a",
            ),
          ],
        ),
        LineupDetails(
          // Existing + Adjusted Kickoff X
          name: "4-2-3-1",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.90),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.60),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.40),
              designatedPlayerId: "660211dca1b2c3d4e5f6a821",
            ),
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.10),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.40), 0.65),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81c",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.40), 0.35),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ),
            PlayerFormationSlot(
              roleInFormation: "RW",
              relativePosition: Vector2(_getKickoffX(0.65), 0.80),
              designatedPlayerId: "660211dca1b2c3d4e5f6a818",
            ),
            PlayerFormationSlot(
              roleInFormation: "CAM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81b",
            ),
            PlayerFormationSlot(
              roleInFormation: "LW",
              relativePosition: Vector2(_getKickoffX(0.65), 0.20),
              designatedPlayerId: "660211dca1b2c3d4e5f6a819",
            ),
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.85), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ),
          ],
        ),
        LineupDetails(
          // Existing + Adjusted Kickoff X
          name: "3-5-2",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.70),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.18), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.30),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ),
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.90),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81d",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.65),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.45), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81c",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.35),
              designatedPlayerId: "660211dca1b2c3d4e5f6a823",
            ),
            PlayerFormationSlot(
              roleInFormation: "AM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.10),
              designatedPlayerId: "660211dca1b2c3d4e5f6a816",
            ),
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.80), 0.60),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ),
            PlayerFormationSlot(
              roleInFormation: "FW",
              relativePosition: Vector2(_getKickoffX(0.80), 0.40),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81a",
            ),
          ],
        ),
        // --- NEW 11v11 FORMATIONS ---
        LineupDetails(
          name: "4-5-1",
          playerSlots: [
            // GK, 4 DEF, 5 MID (CDM, LM, RM, 2 CM), 1 S
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.90),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.60),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.40),
              designatedPlayerId: "660211dca1b2c3d4e5f6a821",
            ),
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.10),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.40), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81c",
            ), // K: ~0.29
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.85),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81d",
            ), // O: 0.60 -> K: ~0.38
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.65),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ), // O: 0.60 -> K: ~0.38
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.35),
              designatedPlayerId: "660211dca1b2c3d4e5f6a823",
            ), // O: 0.60 -> K: ~0.38
            PlayerFormationSlot(
              roleInFormation: "AM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.15),
              designatedPlayerId: "660211dca1b2c3d4e5f6a816",
            ), // AM as LM, O: 0.60 -> K: ~0.38
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.80), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ), // O: 0.80 -> K: ~0.47
          ],
        ),
        LineupDetails(
          name: "3-4-3",
          playerSlots: [
            // GK, 3 CB, 4 MID (RM, LM, 2 CM), 3 FWD (RW, LW, S)
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.75),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ), // RB as RCB
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.18), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ), // K: 0.20 (Min)
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.25),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ), // LB as LCB
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.90),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81d",
            ), // K: ~0.34
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.60),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ), // K: ~0.34
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.40),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81c",
            ), // CDM as CM, K: ~0.34
            PlayerFormationSlot(
              roleInFormation: "AM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.10),
              designatedPlayerId: "660211dca1b2c3d4e5f6a816",
            ), // AM as LM, K: ~0.34
            PlayerFormationSlot(
              roleInFormation: "RW",
              relativePosition: Vector2(_getKickoffX(0.70), 0.80),
              designatedPlayerId: "660211dca1b2c3d4e5f6a818",
            ), // K: ~0.42
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.75), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ), // K: ~0.45
            PlayerFormationSlot(
              roleInFormation: "LW",
              relativePosition: Vector2(_getKickoffX(0.70), 0.20),
              designatedPlayerId: "660211dca1b2c3d4e5f6a819",
            ), // K: ~0.42
          ],
        ),
        // Note: 4-1-4-1 is essentially the same structure as 4-5-1, just terminology.
        // Adding it for completeness if the user wants the explicit name.
        LineupDetails(
          name:
              "4-1-4-1", // Same structure as 4-5-1 but potentially different player types/positioning nuance
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.90),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.60),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.40),
              designatedPlayerId: "660211dca1b2c3d4e5f6a821",
            ),
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.10),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.38), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81c",
            ), // K: ~0.28 (Slightly deeper than 4-5-1)
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.85),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81d",
            ), // K: ~0.38
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.58), 0.65),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ), // K: ~0.37
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.58), 0.35),
              designatedPlayerId: "660211dca1b2c3d4e5f6a823",
            ), // K: ~0.37
            PlayerFormationSlot(
              roleInFormation: "AM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.15),
              designatedPlayerId: "660211dca1b2c3d4e5f6a816",
            ), // K: ~0.38
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.80), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ), // K: ~0.47
          ],
        ),
      ],
    ),
    TeamFormationConfig(
      numberOfPlayers: 7,
      defaultLineupName: "2-3-1",
      availableLineups: [
        LineupDetails(
          name: "2-3-1",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.70),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ),
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.30),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ),
            PlayerFormationSlot(
              roleInFormation: "RW",
              relativePosition: Vector2(_getKickoffX(0.55), 0.85),
              designatedPlayerId: "660211dca1b2c3d4e5f6a818",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ),
            PlayerFormationSlot(
              roleInFormation: "LW",
              relativePosition: Vector2(_getKickoffX(0.55), 0.15),
              designatedPlayerId: "660211dca1b2c3d4e5f6a819",
            ),
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.85), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ),
          ],
        ),
        LineupDetails(
          name: "3-2-1",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.75),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ),
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.25),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.65),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81c",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.35),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ),
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.80), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ),
          ],
        ),
        // --- NEW 7v7 FORMATIONS ---
        LineupDetails(
          name: "3-1-2", // GK, 3 DEF, 1 MID, 2 FWD
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.80),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ), // RB as RCB
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ), // Central CB
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.20),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ), // LB as LCB
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81c",
            ), // Single Mid (CDM) K:~0.34
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.75), 0.65),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ), // K:~0.45
            PlayerFormationSlot(
              roleInFormation: "FW",
              relativePosition: Vector2(_getKickoffX(0.75), 0.35),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81a",
            ), // K:~0.45
          ],
        ),
        LineupDetails(
          name: "2-1-3", // GK, 2 DEF, 1 MID, 3 FWD
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.70),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ), // R Def
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.30),
              designatedPlayerId: "660211dca1b2c3d4e5f6a821",
            ), // L Def
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.45), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ), // Single Mid (CM) K:~0.31
            PlayerFormationSlot(
              roleInFormation: "RW",
              relativePosition: Vector2(_getKickoffX(0.70), 0.80),
              designatedPlayerId: "660211dca1b2c3d4e5f6a818",
            ), // K:~0.42
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.75), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ), // K:~0.45
            PlayerFormationSlot(
              roleInFormation: "LW",
              relativePosition: Vector2(_getKickoffX(0.70), 0.20),
              designatedPlayerId: "660211dca1b2c3d4e5f6a819",
            ), // K:~0.42
          ],
        ),
      ],
    ),
    TeamFormationConfig(
      numberOfPlayers: 9,
      defaultLineupName: "3-3-2",
      availableLineups: [
        LineupDetails(
          name: "3-3-2",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.75),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.25),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ),
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.70),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81d",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.48), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81c",
            ),
            PlayerFormationSlot(
              roleInFormation: "AM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.30),
              designatedPlayerId: "660211dca1b2c3d4e5f6a816",
            ),
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.72), 0.60),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ),
            PlayerFormationSlot(
              roleInFormation: "FW",
              relativePosition: Vector2(_getKickoffX(0.72), 0.40),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81a",
            ),
          ],
        ),
        // --- NEW 9v9 FORMATIONS ---
        LineupDetails(
          name: "2-4-2", // GK, 2 DEF, 4 MID, 2 FWD
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.70),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ), // R Def
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.30),
              designatedPlayerId: "660211dca1b2c3d4e5f6a821",
            ), // L Def
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.90),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81d",
            ), // K:~0.36
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.60),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ), // K:~0.34
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.40),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81c",
            ), // CDM as CM, K:~0.34
            PlayerFormationSlot(
              roleInFormation: "AM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.10),
              designatedPlayerId: "660211dca1b2c3d4e5f6a816",
            ), // AM as LM, K:~0.36
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.78), 0.65),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ), // K:~0.46
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.78), 0.35),
              designatedPlayerId: "660211dca1b2c3d4e5f6a826",
            ), // K:~0.46
          ],
        ),
        LineupDetails(
          name: "4-3-1", // GK, 4 DEF, 3 MID, 1 FWD
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.90),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.65),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.35),
              designatedPlayerId: "660211dca1b2c3d4e5f6a821",
            ),
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.10),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.70),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.48), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81c",
            ), // K:~0.33
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.30),
              designatedPlayerId: "660211dca1b2c3d4e5f6a823",
            ),
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.75), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ),
          ],
        ),
        LineupDetails(
          name: "3-2-3", // GK, 3 DEF, 2 MID, 3 FWD
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.75),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.18), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.25),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.45), 0.65),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81c",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.45), 0.35),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ),
            PlayerFormationSlot(
              roleInFormation: "RW",
              relativePosition: Vector2(_getKickoffX(0.70), 0.85),
              designatedPlayerId: "660211dca1b2c3d4e5f6a818",
            ),
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.75), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ),
            PlayerFormationSlot(
              roleInFormation: "LW",
              relativePosition: Vector2(_getKickoffX(0.70), 0.15),
              designatedPlayerId: "660211dca1b2c3d4e5f6a819",
            ),
          ],
        ),
      ],
    ),
    TeamFormationConfig(
      numberOfPlayers: 5,
      defaultLineupName: "2-1-1",
      availableLineups: [
        LineupDetails(
          name: "2-1-1",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.30), 0.70),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ),
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.30), 0.30),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ),
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.75), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ),
          ],
        ),
        // --- NEW 5v5 FORMATIONS ---
        LineupDetails(
          name: "1-2-1", // GK, 1 DEF, 2 MID, 1 FWD
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ), // K:~0.22
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.75),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ), // K:~0.36
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.25),
              designatedPlayerId: "660211dca1b2c3d4e5f6a823",
            ), // K:~0.36
            PlayerFormationSlot(
              roleInFormation: "S",
              relativePosition: Vector2(_getKickoffX(0.78), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a817",
            ), // K:~0.46
          ],
        ),
        LineupDetails(
          name: "1-3", // GK, 1 DEF, 3 MID
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ), // K:~0.22
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.80),
              designatedPlayerId: "660211dca1b2c3d4e5f6a81d",
            ), // K:~0.38
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ), // K:~0.38
            PlayerFormationSlot(
              roleInFormation: "AM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.20),
              designatedPlayerId: "660211dca1b2c3d4e5f6a816",
            ), // AM as LM, K:~0.38
          ],
        ),
        LineupDetails(
          name: "3-1", // GK, 3 DEF, 1 MID
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "660211dca1b2c3d4e5f6a810",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.30), 0.80),
              designatedPlayerId: "660211dca1b2c3d4e5f6a811",
            ), // K:~0.25
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a813",
            ), // K:~0.22
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.30), 0.20),
              designatedPlayerId: "660211dca1b2c3d4e5f6a812",
            ), // K:~0.25
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.65), 0.50),
              designatedPlayerId: "660211dca1b2c3d4e5f6a814",
            ), // K:~0.40
          ],
        ),
      ],
    ),
  ];

  // --- AWAY PLAYER KICK-OFF CONFIGURATIONS ---
  // Generated by processing the *home* kick-off configurations
  static final List<TeamFormationConfig> _awayConfigurations = [
    // Configuration for 11 players
    TeamFormationConfig(
      numberOfPlayers: 11,
      defaultLineupName: "4-3-3",
      availableLineups:
          _homeConfigurations
              .firstWhere((c) => c.numberOfPlayers == 11)
              .availableLineups
              .map(
                (homeLineup) => LineupDetails(
                  name: homeLineup.name,
                  playerSlots:
                      homeLineup.playerSlots
                          .map(
                            (homeKickoffSlot) => PlayerFormationSlot(
                              roleInFormation: homeKickoffSlot.roleInFormation,
                              relativePosition: _getProcessedAwayPosition(
                                homeKickoffSlot.relativePosition,
                                homeKickoffSlot.roleInFormation,
                              ),
                              designatedPlayerId:
                                  _getAwayPlayerIdForHomeEquivalent_11(
                                    homeKickoffSlot.roleInFormation,
                                    homeKickoffSlot.relativePosition,
                                  ) ??
                                  awayPlayers
                                      .first
                                      .item2, // Placeholder mapping
                            ),
                          )
                          .toList(),
                ),
              )
              .toList(),
    ),
    // Configuration for 7 players
    TeamFormationConfig(
      numberOfPlayers: 7,
      defaultLineupName: "2-3-1",
      availableLineups:
          _homeConfigurations
              .firstWhere((c) => c.numberOfPlayers == 7)
              .availableLineups
              .map(
                (homeLineup) => LineupDetails(
                  name: homeLineup.name,
                  playerSlots:
                      homeLineup.playerSlots
                          .map(
                            (homeKickoffSlot) => PlayerFormationSlot(
                              roleInFormation: homeKickoffSlot.roleInFormation,
                              relativePosition: _getProcessedAwayPosition(
                                homeKickoffSlot.relativePosition,
                                homeKickoffSlot.roleInFormation,
                              ),
                              // WARNING: Placeholder ID assignment - replace with specific choices
                              designatedPlayerId:
                                  awayPlayers[(homeLineup.playerSlots.indexOf(
                                                homeKickoffSlot,
                                              ) +
                                              homeLineup
                                                  .name
                                                  .hashCode) % // Basic attempt at variety
                                          awayPlayers.length]
                                      .item2,
                            ),
                          )
                          .toList(),
                ),
              )
              .toList(),
    ),
    // Configuration for 9 players
    TeamFormationConfig(
      numberOfPlayers: 9,
      defaultLineupName: "3-3-2",
      availableLineups:
          _homeConfigurations
              .firstWhere((c) => c.numberOfPlayers == 9)
              .availableLineups
              .map(
                (homeLineup) => LineupDetails(
                  name: homeLineup.name,
                  playerSlots:
                      homeLineup.playerSlots
                          .map(
                            (homeKickoffSlot) => PlayerFormationSlot(
                              roleInFormation: homeKickoffSlot.roleInFormation,
                              relativePosition: _getProcessedAwayPosition(
                                homeKickoffSlot.relativePosition,
                                homeKickoffSlot.roleInFormation,
                              ),
                              // WARNING: Placeholder ID assignment - replace with specific choices
                              designatedPlayerId:
                                  awayPlayers[(homeLineup.playerSlots.indexOf(
                                                homeKickoffSlot,
                                              ) +
                                              homeLineup
                                                  .name
                                                  .hashCode) % // Basic attempt at variety
                                          awayPlayers.length]
                                      .item2,
                            ),
                          )
                          .toList(),
                ),
              )
              .toList(),
    ),
    // Configuration for 5 players
    TeamFormationConfig(
      numberOfPlayers: 5,
      defaultLineupName: "2-1-1",
      availableLineups:
          _homeConfigurations
              .firstWhere((c) => c.numberOfPlayers == 5)
              .availableLineups
              .map(
                (homeLineup) => LineupDetails(
                  name: homeLineup.name,
                  playerSlots:
                      homeLineup.playerSlots
                          .map(
                            (homeKickoffSlot) => PlayerFormationSlot(
                              roleInFormation: homeKickoffSlot.roleInFormation,
                              relativePosition: _getProcessedAwayPosition(
                                homeKickoffSlot.relativePosition,
                                homeKickoffSlot.roleInFormation,
                              ),
                              // WARNING: Placeholder ID assignment - replace with specific choices
                              designatedPlayerId:
                                  awayPlayers[(homeLineup.playerSlots.indexOf(
                                                homeKickoffSlot,
                                              ) +
                                              homeLineup
                                                  .name
                                                  .hashCode) % // Basic attempt at variety
                                          awayPlayers.length]
                                      .item2,
                            ),
                          )
                          .toList(),
                ),
              )
              .toList(),
    ),
  ];

  static String? _getAwayPlayerIdForHomeEquivalent_11(
    String role,
    Vector2 homeKickoffPos,
  ) {
    try {
      return awayPlayers.firstWhere((p) => p.item1 == role).item2;
    } catch (e) {
      return awayPlayers.first.item2;
    }
  }

  static List<PlayerModel> generatePlayerModelList({
    required PlayerType playerType,
  }) {
    List<PlayerModel> generatedPlayers = [];
    List<Tuple3<String, String, int>> players =
        (playerType == PlayerType.HOME)
            ? homePlayers
            : (playerType == PlayerType.AWAY)
            ? awayPlayers
            : otherPlayers;

    for (Tuple3 p in players) {
      String id = p.item2;

      Color color;
      switch (playerType) {
        case PlayerType.HOME:
          color = ColorManager.blueAccent;
          break;

        case PlayerType.OTHER:
          // TODO: Handle this case.
          if (p.item3 == -1) {
            color = ColorManager.blue;
          } else {
            color = ColorManager.black;
          }
          break;
        case PlayerType.AWAY:
          color = ColorManager.red;
          break;
        case PlayerType.UNKNOWN:
          // TODO: Handle this case.
          color = ColorManager.black;
          break;
      }

      PlayerModel playerModelV2 = PlayerModel(
        id: id,
        role: p.item1,
        jerseyNumber: p.item3,
        color: color,
        playerType: playerType,
        offset: Vector2(0, 0),
        size: Vector2(32, 32),
      );
      generatedPlayers.add(playerModelV2);
    }
    return generatedPlayers;
  }

  static List<TeamFormationConfig> getAllConfigurations({
    required PlayerType playerType,
  }) {
    if (playerType == PlayerType.HOME) {
      return List.unmodifiable(_homeConfigurations);
    } else if (playerType == PlayerType.AWAY) {
      return List.unmodifiable(_awayConfigurations);
    } else {
      return [];
    }
  }
}
