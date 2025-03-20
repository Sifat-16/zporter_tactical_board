import 'package:flame/components.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';

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

  static List<PlayerModel> generatePlayerModelList({
    required PlayerType playerType,
  }) {
    List<PlayerModel> generatedPlayers = [];
    int index = 1;
    for (String p in players) {
      ObjectId id = ObjectId();
      PlayerModel playerModelV2 = PlayerModel(
        id: id,
        role: p,
        index: index,
        playerType: playerType,
        offset: Vector2(0, 0),
      );
      generatedPlayers.add(playerModelV2);
      index++;
    }
    return generatedPlayers;
  }
}
