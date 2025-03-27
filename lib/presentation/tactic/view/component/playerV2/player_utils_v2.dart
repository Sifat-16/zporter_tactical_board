import 'package:flame/components.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:zporter_tactical_board/app/datastructures/tuple.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';

class PlayerUtilsV2 {
  static List<Tuple2<String, String>> homePlayers = [
    Tuple2("GK", "660211dca1b2c3d4e5f6a810"), // Hex will vary
    Tuple2("RB", "660211dca1b2c3d4e5f6a811"), // Hex will vary
    Tuple2("LB", "660211dca1b2c3d4e5f6a812"), // Hex will vary
    Tuple2("CB", "660211dca1b2c3d4e5f6a813"), // Hex will vary
    Tuple2("CM", "660211dca1b2c3d4e5f6a814"), // Hex will vary
    Tuple2("AM", "660211dca1b2c3d4e5f6a815"), // Hex will vary
    Tuple2(
      "AM",
      "660211dca1b2c3d4e5f6a816",
    ), // Hex will vary (different from previous AM)
    Tuple2("S", "660211dca1b2c3d4e5f6a817"), // Hex will vary
    Tuple2("RW", "660211dca1b2c3d4e5f6a818"), // Hex will vary
    Tuple2("LW", "660211dca1b2c3d4e5f6a819"), // Hex will vary
    Tuple2("FW", "660211dca1b2c3d4e5f6a81a"), // Hex will vary
    Tuple2("CAM", "660211dca1b2c3d4e5f6a81b"), // Hex will vary
    Tuple2("CDM", "660211dca1b2c3d4e5f6a81c"), // Hex will vary
    Tuple2("RM", "660211dca1b2c3d4e5f6a81d"), // Hex will vary
    Tuple2(
      "GK",
      "660211dca1b2c3d4e5f6a81e",
    ), // Hex will vary (different from previous GK)
    Tuple2(
      "RB",
      "660211dca1b2c3d4e5f6a81f",
    ), // Hex will vary (different from previous RB)
    Tuple2(
      "LB",
      "660211dca1b2c3d4e5f6a820",
    ), // Hex will vary (different from previous LB)
    Tuple2(
      "CB",
      "660211dca1b2c3d4e5f6a821",
    ), // Hex will vary (different from previous CB)
    Tuple2(
      "CB",
      "660211dca1b2c3d4e5f6a822",
    ), // Hex will vary (different from previous CBs)
    Tuple2(
      "CM",
      "660211dca1b2c3d4e5f6a823",
    ), // Hex will vary (different from previous CM)
    Tuple2(
      "AM",
      "660211dca1b2c3d4e5f6a824",
    ), // Hex will vary (different from previous AMs)
    Tuple2(
      "AM",
      "660211dca1b2c3d4e5f6a825",
    ), // Hex will vary (different from previous AMs)
    Tuple2(
      "S",
      "660211dca1b2c3d4e5f6a826",
    ), // Hex will vary (different from previous S)
  ];

  static List<Tuple2<String, String>> awayPlayers = [
    Tuple2(
      "GK",
      "660212e8a1b2c3d4e5f6a830",
    ), // Hex will vary & differ from home
    Tuple2(
      "RB",
      "660212e8a1b2c3d4e5f6a831",
    ), // Hex will vary & differ from home
    Tuple2(
      "LB",
      "660212e8a1b2c3d4e5f6a832",
    ), // Hex will vary & differ from home
    Tuple2(
      "CB",
      "660212e8a1b2c3d4e5f6a833",
    ), // Hex will vary & differ from home
    Tuple2(
      "CM",
      "660212e8a1b2c3d4e5f6a834",
    ), // Hex will vary & differ from home
    Tuple2(
      "AM",
      "660212e8a1b2c3d4e5f6a835",
    ), // Hex will vary & differ from home
    Tuple2(
      "AM",
      "660212e8a1b2c3d4e5f6a836",
    ), // Hex will vary & differ from home
    Tuple2("S", "660212e8a1b2c3d4e5f6a837"), // Hex will vary & differ from home
    Tuple2(
      "RW",
      "660212e8a1b2c3d4e5f6a838",
    ), // Hex will vary & differ from home
    Tuple2(
      "LW",
      "660212e8a1b2c3d4e5f6a839",
    ), // Hex will vary & differ from home
    Tuple2(
      "FW",
      "660212e8a1b2c3d4e5f6a83a",
    ), // Hex will vary & differ from home
    Tuple2(
      "CAM",
      "660212e8a1b2c3d4e5f6a83b",
    ), // Hex will vary & differ from home
    Tuple2(
      "CDM",
      "660212e8a1b2c3d4e5f6a83c",
    ), // Hex will vary & differ from home
    Tuple2(
      "RM",
      "660212e8a1b2c3d4e5f6a83d",
    ), // Hex will vary & differ from home
    Tuple2(
      "GK",
      "660212e8a1b2c3d4e5f6a83e",
    ), // Hex will vary & differ from home
    Tuple2(
      "RB",
      "660212e8a1b2c3d4e5f6a83f",
    ), // Hex will vary & differ from home
    Tuple2(
      "LB",
      "660212e8a1b2c3d4e5f6a840",
    ), // Hex will vary & differ from home
    Tuple2(
      "CB",
      "660212e8a1b2c3d4e5f6a841",
    ), // Hex will vary & differ from home
    Tuple2(
      "CB",
      "660212e8a1b2c3d4e5f6a842",
    ), // Hex will vary & differ from home
    Tuple2(
      "CM",
      "660212e8a1b2c3d4e5f6a843",
    ), // Hex will vary & differ from home
    Tuple2(
      "AM",
      "660212e8a1b2c3d4e5f6a844",
    ), // Hex will vary & differ from home
    Tuple2(
      "AM",
      "660212e8a1b2c3d4e5f6a845",
    ), // Hex will vary & differ from home
    Tuple2("S", "660212e8a1b2c3d4e5f6a846"), // Hex will vary & differ from home
  ];

  static List<PlayerModel> generatePlayerModelList({
    required PlayerType playerType,
  }) {
    List<PlayerModel> generatedPlayers = [];
    List<Tuple2<String, String>> players =
        (playerType == PlayerType.HOME) ? homePlayers : awayPlayers;
    int index = 1;

    for (Tuple2 p in players) {
      ObjectId id = ObjectId.fromHexString(p.item2);
      PlayerModel playerModelV2 = PlayerModel(
        id: id,
        role: p.item1,
        index: index,
        color:
            playerType == PlayerType.HOME
                ? ColorManager.blue
                : ColorManager.red,
        playerType: playerType,
        offset: Vector2(0, 0),
        size: Vector2(32, 32),
      );
      generatedPlayers.add(playerModelV2);
      index++;
    }
    return generatedPlayers;
  }
}
