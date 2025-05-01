import 'dart:ui';

import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/datastructures/tuple.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';

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
}
