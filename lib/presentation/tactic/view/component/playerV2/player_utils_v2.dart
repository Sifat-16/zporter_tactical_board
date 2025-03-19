import 'package:mongo_dart/mongo_dart.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_model_v2.dart';

class PlayerUtilsV2 {
  static List<String> players = [
    "GK",
    "RB",
    "LB",
    "CB",
    "CM",
    "AM",
    "AM",
    "S",
    "RW",
    "LW",
    "FW",
    "CAM",
    "CDM",
    "RM",
    "GK",
    "RB",
    "LB",
    "CB",
    "CB",
    "CM",
    "AM",
    "AM",
    "S",
  ];

  static List<PlayerModelV2> generatePlayerModelList({
    required PlayerType playerType,
  }) {
    List<PlayerModelV2> generatedPlayers = [];
    int index = 1;
    for (String p in players) {
      ObjectId id = ObjectId();
      PlayerModelV2 playerModelV2 = PlayerModelV2(
        id: id.oid,
        role: p,
        index: index,
        playerType: playerType,
      );
      generatedPlayers.add(playerModelV2);
      index++;
    }
    return generatedPlayers;
  }
}
