import 'dart:ui';

import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/datastructures/tuple.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/team_formation_config_model.dart';

class PlayerUtilsV2 {
  static List<Tuple3<String, String, int>> homePlayers = [
    Tuple3("GK", "663b8a00a1b2c3d4e5f6a001", 1), // GK Goal Keeper
    Tuple3("RB", "663b8a00a1b2c3d4e5f6a002", 2), // RB Right Back
    Tuple3("LB", "663b8a00a1b2c3d4e5f6a003", 3), // LB Left Back
    Tuple3("CB", "663b8a00a1b2c3d4e5f6a004", 4), // CB Center Back
    Tuple3("CB", "663b8a00a1b2c3d4e5f6a005", 5), // CB Center Back
    Tuple3(
      "CDM",
      "663b8a00a1b2c3d4e5f6a006",
      6,
    ), // CDM Central Defending Midfielder
    Tuple3("RW", "663b8a00a1b2c3d4e5f6a007", 7), // RW Right Wing
    Tuple3("CM", "663b8a00a1b2c3d4e5f6a008", 8), // CM Central Midfield
    Tuple3("ST", "663b8a00a1b2c3d4e5f6a009", 9), // ST Striker
    Tuple3(
      "CAM",
      "663b8a00a1b2c3d4e5f6a010",
      10,
    ), // CAM Central Attacking Midfield
    Tuple3("LW", "663b8a00a1b2c3d4e5f6a011", 11), // LW Left Wing
    Tuple3("WB", "663b8a00a1b2c3d4e5f6a012", 12), // WB Wing Back (Right?)
    Tuple3("WB", "663b8a00a1b2c3d4e5f6a013", 13), // WB Wing Back (Left?)
    Tuple3("CB", "663b8a00a1b2c3d4e5f6a014", 14), // CB Center Back
    Tuple3("CB", "663b8a00a1b2c3d4e5f6a015", 15), // CB Center Back
    Tuple3(
      "CDM",
      "663b8a00a1b2c3d4e5f6a016",
      16,
    ), // CDM Central Defending Midfielder
    Tuple3("RM", "663b8a00a1b2c3d4e5f6a017", 17), // RM Right Midfield
    Tuple3("LM", "663b8a00a1b2c3d4e5f6a018", 18), // LM Left Midfield
    Tuple3("CF", "663b8a00a1b2c3d4e5f6a019", 19), // CF Center Forward
    Tuple3("F", "663b8a00a1b2c3d4e5f6a020", 20), // F Forward
    Tuple3("GK", "663b8a00a1b2c3d4e5f6a021", 21), // GK Goalkeeper
    Tuple3("W", "663b8a00a1b2c3d4e5f6a022", 22), // W Winger (Right?)
    Tuple3("W", "663b8a00a1b2c3d4e5f6a023", 23), // W Winger (Left?)
  ];

  static List<Tuple3<String, String, int>> awayPlayers = [
    Tuple3("GK", "663b8a99a1b2c3d4e5f6b001", 1), // GK Goal Keeper
    Tuple3("RB", "663b8a99a1b2c3d4e5f6b002", 2), // RB Right Back
    Tuple3("LB", "663b8a99a1b2c3d4e5f6b003", 3), // LB Left Back
    Tuple3("CB", "663b8a99a1b2c3d4e5f6b004", 4), // CB Center Back
    Tuple3("CB", "663b8a99a1b2c3d4e5f6b005", 5), // CB Center Back
    Tuple3(
      "CDM",
      "663b8a99a1b2c3d4e5f6b006",
      6,
    ), // CDM Central Defending Midfielder
    Tuple3("RW", "663b8a99a1b2c3d4e5f6b007", 7), // RW Right Wing
    Tuple3("CM", "663b8a99a1b2c3d4e5f6b008", 8), // CM Central Midfield
    Tuple3("ST", "663b8a99a1b2c3d4e5f6b009", 9), // ST Striker
    Tuple3(
      "CAM",
      "663b8a99a1b2c3d4e5f6b010",
      10,
    ), // CAM Central Attacking Midfield
    Tuple3("LW", "663b8a99a1b2c3d4e5f6b011", 11), // LW Left Wing
    Tuple3("WB", "663b8a99a1b2c3d4e5f6b012", 12), // WB Wing Back (Right?)
    Tuple3("WB", "663b8a99a1b2c3d4e5f6b013", 13), // WB Wing Back (Left?)
    Tuple3("CB", "663b8a99a1b2c3d4e5f6b014", 14), // CB Center Back
    Tuple3("CB", "663b8a99a1b2c3d4e5f6b015", 15), // CB Center Back
    Tuple3(
      "CDM",
      "663b8a99a1b2c3d4e5f6b016",
      16,
    ), // CDM Central Defending Midfielder
    Tuple3("RM", "663b8a99a1b2c3d4e5f6b017", 17), // RM Right Midfield
    Tuple3("LM", "663b8a99a1b2c3d4e5f6b018", 18), // LM Left Midfield
    Tuple3("CF", "663b8a99a1b2c3d4e5f6b019", 19), // CF Center Forward
    Tuple3("F", "663b8a99a1b2c3d4e5f6b020", 20), // F Forward
    Tuple3("GK", "663b8a99a1b2c3d4e5f6b021", 21), // GK Goalkeeper
    Tuple3("W", "663b8a99a1b2c3d4e5f6b022", 22), // W Winger (Right?)
    Tuple3("W", "663b8a99a1b2c3d4e5f6b023", 23), // W Winger (Left?)
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

  static getKickoffX(double originalFullFieldX) =>
      _getKickoffX(originalFullFieldX);

  static double _getKickoffX(double originalFullFieldX) {
    const double gkPos = 0.05;
    // Define the typical range of outfield players in your *original* full-field layouts
    const double minOrigOutfieldX =
        0.18; // Adjust if your deepest player is different
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
            // Roles and IDs updated
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ), // GK #1
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.85),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a002",
            ), // RB #2 -> K: 0.223
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.60),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ), // CB #4 -> K: 0.200
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.40),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ), // CB #5 -> K: 0.200
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.15),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a003",
            ), // LB #3 -> K: 0.223
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.70),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ), // CM #8 -> K: 0.336
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.45), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ), // CDM #6 -> K: 0.314
            PlayerFormationSlot(
              roleInFormation: "CAM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.30),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a010",
            ), // CAM #10 -> K: 0.336
            PlayerFormationSlot(
              roleInFormation: "RW",
              relativePosition: Vector2(_getKickoffX(0.75), 0.80),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a007",
            ), // RW #7 -> K: 0.450
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.80), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ), // ST #9 -> K: 0.472
            PlayerFormationSlot(
              roleInFormation: "LW",
              relativePosition: Vector2(_getKickoffX(0.75), 0.20),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a011",
            ), // LW #11 -> K: 0.450
          ],
        ),
        LineupDetails(
          name: "4-4-2",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.90),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a002",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.60),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.40),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.10),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a003",
            ),
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.85),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a017",
            ), // RM #17 -> K: 0.359
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.60),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ), // CM #8
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.40),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ), // CDM #6 as other CM
            PlayerFormationSlot(
              roleInFormation: "LM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.15),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a018",
            ), // LM #18 -> K: 0.359
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.80), 0.60),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ), // ST #9
            PlayerFormationSlot(
              roleInFormation: "CF",
              relativePosition: Vector2(_getKickoffX(0.80), 0.40),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a019",
            ), // CF #19
          ],
        ),
        LineupDetails(
          name: "4-2-3-1",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.90),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a002",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.60),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.40),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.10),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a003",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.40), 0.65),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.40), 0.35),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a016",
            ), // CDM #16
            PlayerFormationSlot(
              roleInFormation: "RW",
              relativePosition: Vector2(_getKickoffX(0.65), 0.80),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a007",
            ), // RW #7 as RAM -> K: 0.404
            PlayerFormationSlot(
              roleInFormation: "CAM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a010",
            ), // CAM #10 -> K: 0.381
            PlayerFormationSlot(
              roleInFormation: "LW",
              relativePosition: Vector2(_getKickoffX(0.65), 0.20),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a011",
            ), // LW #11 as LAM -> K: 0.404
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.85), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ), // ST #9 -> Max K: 0.495
          ],
        ),
        LineupDetails(
          name: "3-5-2",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.70),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.18), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.30),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a014",
            ), // CB #14
            PlayerFormationSlot(
              roleInFormation: "WB",
              relativePosition: Vector2(_getKickoffX(0.50), 0.90),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a012",
            ), // WB #12 as RWB -> K: 0.336
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.65),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.45), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.35),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a010",
            ), // CAM #10 as CM
            PlayerFormationSlot(
              roleInFormation: "WB",
              relativePosition: Vector2(_getKickoffX(0.50), 0.10),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a013",
            ), // WB #13 as LWB -> K: 0.336
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.80), 0.60),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ),
            PlayerFormationSlot(
              roleInFormation: "CF",
              relativePosition: Vector2(_getKickoffX(0.80), 0.40),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a019",
            ), // CF #19
          ],
        ),
        // --- NEW 11v11 FORMATIONS ---
        LineupDetails(
          name: "4-5-1",
          playerSlots: [
            // GK, 4 DEF, 5 MID (CDM, LM, RM, CM, CAM), 1 ST
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.90),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a002",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.60),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.40),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.10),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a003",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.40), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ),
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.85),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a017",
            ), // K: 0.381
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.58), 0.65),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ), // K: 0.372
            PlayerFormationSlot(
              roleInFormation: "CAM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a010",
            ), // K: 0.381
            PlayerFormationSlot(
              roleInFormation: "LM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.15),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a018",
            ), // K: 0.381
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.80), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ), // K: 0.472
          ],
        ),
        LineupDetails(
          name: "3-4-3",
          playerSlots: [
            // GK, 3 CB, 4 MID (RM, LM, CM, CDM), 3 FWD (RW, LW, ST)
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.75),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.18), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.25),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a014",
            ),
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.90),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a017",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.60),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.40),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ),
            PlayerFormationSlot(
              roleInFormation: "LM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.10),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a018",
            ),
            PlayerFormationSlot(
              roleInFormation: "RW",
              relativePosition: Vector2(_getKickoffX(0.70), 0.80),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a007",
            ),
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.75), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ),
            PlayerFormationSlot(
              roleInFormation: "LW",
              relativePosition: Vector2(_getKickoffX(0.70), 0.20),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a011",
            ),
          ],
        ),
        LineupDetails(
          name: "4-1-4-1", // GK, 4 DEF, 1 CDM, 4 MID (RM, LM, CM, CAM), 1 ST
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(_getKickoffX(0.05), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ), // K: 0.05
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.90),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a002",
            ), // O: 0.25 -> K: 0.223
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.65),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ), // O: 0.22 -> K: 0.209
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.35),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ), // O: 0.22 -> K: 0.209
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.10),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a003",
            ), // O: 0.25 -> K: 0.223
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.38), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ), // O: 0.38 -> K: 0.281
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.85),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a017",
            ), // O: 0.60 -> K: 0.381
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.58), 0.65),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ), // O: 0.58 -> K: 0.372
            PlayerFormationSlot(
              roleInFormation: "CAM",
              relativePosition: Vector2(_getKickoffX(0.58), 0.35),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a010",
            ), // CAM as 2nd CM -> K: 0.372
            PlayerFormationSlot(
              roleInFormation: "LM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.15),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a018",
            ), // O: 0.60 -> K: 0.381
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.80), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ), // O: 0.80 -> K: 0.472
          ],
        ), // Re-use 4-5-1 slots for 4-1-4-1 name
      ],
    ),
    TeamFormationConfig(
      // 9 Players - Updated
      numberOfPlayers: 9,
      defaultLineupName: "3-3-2",
      availableLineups: [
        LineupDetails(
          name: "3-3-2",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.75),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.25),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a014",
            ),
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.70),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a017",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.48), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ),
            PlayerFormationSlot(
              roleInFormation: "LM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.30),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a018",
            ),
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.72), 0.60),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ),
            PlayerFormationSlot(
              roleInFormation: "CF",
              relativePosition: Vector2(_getKickoffX(0.72), 0.40),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a019",
            ),
          ],
        ),
        // --- NEW 9v9 FORMATIONS ---
        LineupDetails(
          name: "2-4-2",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.70),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.30),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.90),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a017",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.60),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.40),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a016",
            ),
            PlayerFormationSlot(
              roleInFormation: "LM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.10),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a018",
            ),
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.78), 0.65),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ),
            PlayerFormationSlot(
              roleInFormation: "CF",
              relativePosition: Vector2(_getKickoffX(0.78), 0.35),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a019",
            ),
          ],
        ),
        LineupDetails(
          name: "4-3-1",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "RB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.90),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a002",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.65),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.35),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "LB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.10),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a003",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.70),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.48), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.30),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a010",
            ),
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.75), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ),
          ],
        ),
        LineupDetails(
          name: "3-2-3",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.75),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.18), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.25),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a014",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.45), 0.65),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.45), 0.35),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ),
            PlayerFormationSlot(
              roleInFormation: "RW",
              relativePosition: Vector2(_getKickoffX(0.70), 0.85),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a007",
            ),
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.75), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ),
            PlayerFormationSlot(
              roleInFormation: "LW",
              relativePosition: Vector2(_getKickoffX(0.70), 0.15),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a011",
            ),
          ],
        ),
      ],
    ),
    TeamFormationConfig(
      // 7 Players - Updated
      numberOfPlayers: 7,
      defaultLineupName: "2-3-1",
      availableLineups: [
        LineupDetails(
          name: "2-3-1",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.70),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.30),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.85),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a017",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ),
            PlayerFormationSlot(
              roleInFormation: "LM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.15),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a018",
            ),
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.85), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ),
          ],
        ),
        LineupDetails(
          name: "3-2-1",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.75),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.20), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.25),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a014",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.65),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.35),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ),
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.80), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ),
          ],
        ),
        // --- NEW 7v7 FORMATIONS ---
        LineupDetails(
          name: "3-1-2",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.80),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.22), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.20),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a014",
            ),
            PlayerFormationSlot(
              roleInFormation: "CDM",
              relativePosition: Vector2(_getKickoffX(0.50), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ),
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.75), 0.65),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ),
            PlayerFormationSlot(
              roleInFormation: "CF",
              relativePosition: Vector2(_getKickoffX(0.75), 0.35),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a019",
            ),
          ],
        ),
        LineupDetails(
          name: "2-1-3",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.70),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.30),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.45), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ),
            PlayerFormationSlot(
              roleInFormation: "RW",
              relativePosition: Vector2(_getKickoffX(0.70), 0.80),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a007",
            ),
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.75), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ),
            PlayerFormationSlot(
              roleInFormation: "LW",
              relativePosition: Vector2(_getKickoffX(0.70), 0.20),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a011",
            ),
          ],
        ),
      ],
    ),
    TeamFormationConfig(
      // 5 Players - Updated
      numberOfPlayers: 5,
      defaultLineupName: "2-1-1",
      availableLineups: [
        LineupDetails(
          name: "2-1-1",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.30), 0.70),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.30), 0.30),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ),
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.75), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ),
          ],
        ),
        // --- NEW 5v5 FORMATIONS ---
        LineupDetails(
          name: "1-2-1",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.75),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.55), 0.25),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a006",
            ),
            PlayerFormationSlot(
              roleInFormation: "ST",
              relativePosition: Vector2(_getKickoffX(0.78), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a009",
            ),
          ],
        ),
        LineupDetails(
          name: "1-3",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "RM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.80),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a017",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ),
            PlayerFormationSlot(
              roleInFormation: "LM",
              relativePosition: Vector2(_getKickoffX(0.60), 0.20),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a018",
            ),
          ],
        ),
        LineupDetails(
          name: "3-1",
          playerSlots: [
            PlayerFormationSlot(
              roleInFormation: "GK",
              relativePosition: Vector2(0.05, 0.5),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a001",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.30), 0.80),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a004",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.25), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a005",
            ),
            PlayerFormationSlot(
              roleInFormation: "CB",
              relativePosition: Vector2(_getKickoffX(0.30), 0.20),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a014",
            ),
            PlayerFormationSlot(
              roleInFormation: "CM",
              relativePosition: Vector2(_getKickoffX(0.65), 0.50),
              designatedPlayerId: "663b8a00a1b2c3d4e5f6a008",
            ),
          ],
        ),
      ],
    ),
  ];

  static final List<TeamFormationConfig> _awayConfigurations =
      _homeConfigurations.map((homeConfig) {
        return TeamFormationConfig(
          numberOfPlayers: homeConfig.numberOfPlayers,
          defaultLineupName: homeConfig.defaultLineupName,
          availableLineups:
              homeConfig.availableLineups.map((homeLineup) {
                // Keep track of away player IDs used for *this specific away lineup*
                List<String> assignedAwayPlayerIdsThisLineup = [];

                List<PlayerFormationSlot> awayPlayerSlots =
                    homeLineup.playerSlots.map((homeKickoffSlot) {
                      String roleToAssign = homeKickoffSlot.roleInFormation;
                      String? selectedAwayPlayerId;

                      // Try to find an unused away player with the exact role
                      for (var awayPlayerTuple in PlayerUtilsV2.awayPlayers) {
                        if (awayPlayerTuple.item1 == roleToAssign &&
                            !assignedAwayPlayerIdsThisLineup.contains(
                              awayPlayerTuple.item2,
                            )) {
                          selectedAwayPlayerId = awayPlayerTuple.item2;
                          assignedAwayPlayerIdsThisLineup.add(
                            selectedAwayPlayerId!,
                          );
                          break;
                        }
                      }

                      // Fallback: If no unused player of the exact role, try to find *any* unused away player.
                      // This is a basic fallback; more sophisticated logic might be needed for optimal tactical assignment.
                      if (selectedAwayPlayerId == null) {
                        for (var awayPlayerTuple in PlayerUtilsV2.awayPlayers) {
                          if (!assignedAwayPlayerIdsThisLineup.contains(
                            awayPlayerTuple.item2,
                          )) {
                            selectedAwayPlayerId = awayPlayerTuple.item2;
                            assignedAwayPlayerIdsThisLineup.add(
                              selectedAwayPlayerId!,
                            );
                            print(
                              "Warning: Fallback player assignment for away lineup '${homeLineup.name}', role '${roleToAssign}'. Assigned player with role '${awayPlayerTuple.item1}'.",
                            );
                            break;
                          }
                        }
                      }

                      // If still no player can be assigned (e.g., not enough unique players in awayPlayers list
                      // for the number of slots), this is a data setup issue.
                      if (selectedAwayPlayerId == null) {
                        print(
                          "ERROR: Could not assign a unique away player for role '${roleToAssign}' in lineup '${homeLineup.name}'. Ran out of available away players for this lineup. Assigning first available as a last resort.",
                        );
                        // Last resort: pick the first away player, even if it causes a duplicate within this lineup (undesirable)
                        // Or, throw an error, or assign a "dummy" player ID.
                        // This indicates the awayPlayers list might be too small or the logic needs more robust handling for this edge case.
                        selectedAwayPlayerId =
                            PlayerUtilsV2
                                .awayPlayers
                                .first
                                .item2; // Fallback to prevent crash
                        // To strictly prevent duplicates even in fallback, you'd need to ensure awayPlayers.length >= numberOfPlayers
                      }

                      return PlayerFormationSlot(
                        roleInFormation: homeKickoffSlot.roleInFormation,
                        relativePosition: _getProcessedAwayPosition(
                          homeKickoffSlot.relativePosition,
                          homeKickoffSlot.roleInFormation,
                        ),
                        designatedPlayerId: selectedAwayPlayerId!,
                      );
                    }).toList();

                return LineupDetails(
                  name: homeLineup.name,
                  playerSlots: awayPlayerSlots,
                );
              }).toList(),
        );
      }).toList();

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
