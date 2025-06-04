import 'dart:ui';

import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/datastructures/tuple.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/domain/admin/lineup/default_lineup_repository.dart';

class PlayerUtilsV2 {
  static DefaultLineupRepository _repository = sl.get();
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

  static List<PlayerModel> generatePlayerModelList({
    required PlayerType playerType,
  }) {
    List<PlayerModel> generatedPlayers = [];
    List<Tuple3<String, String, int>> players = (playerType == PlayerType.HOME)
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

  static List<PlayerModel> generateHomePlayerFromScene(
      {required AnimationItemModel scene,
      required List<PlayerModel> availablePlayers}) {
    List<PlayerModel> scenePlayers =
        scene.components.whereType<PlayerModel>().toList() ?? [];

    List<PlayerModel> playersToAdd = scenePlayers.map((p) {
          return availablePlayers
              .firstWhere((player) => player.id == p.id)
              .copyWith(offset: p.offset);
        }).toList() ??
        [];
    return playersToAdd;
  }

  static List<PlayerModel> generateAwayPlayerFromScene({
    required AnimationItemModel scene,
    required List<PlayerModel> availablePlayers,
    required Vector2 fieldSize,
  }) {
    zlog(data: "Generating away players for lineup");
    List<PlayerModel> scenePlayers = scene.components
        .whereType<PlayerModel>()
        .toList()
        .where((p) => p.playerType == PlayerType.HOME)
        .toList();

    List<PlayerModel> playersToAdd = [];

    for (PlayerModel p in scenePlayers) {
      PlayerModel? playerModel = availablePlayers.firstWhereOrNull(
        (player) =>
            (player.role == p.role) && (player.jerseyNumber == p.jerseyNumber),
      );

      if (playerModel != null) {
        Vector2 offset = Vector2(
          1 -
              ((p.offset?.x ?? 0) -
                  (SizeHelper.getBoardRelativeVector(
                        gameScreenSize: fieldSize,
                        actualPosition: p.size ?? Vector2.zero(),
                      ).x *
                      1.25 /
                      2)),

          1 -
              ((p.offset?.y ?? 0) -
                  (SizeHelper.getBoardRelativeVector(
                        gameScreenSize: fieldSize,
                        actualPosition: p.size ?? Vector2.zero(),
                      ).y /
                      2)),
          // p.offset?.y ?? 0,
        );
        zlog(data: "Check the components ${offset} - ${fieldSize} ${p.size}");
        playerModel = playerModel.copyWith(offset: offset);

        playersToAdd.add(playerModel);
      }
    }

    return playersToAdd;
  }

  // static List<PlayerModel> generateAwayPlayerFromScene({
  //   required AnimationItemModel scene,
  //   required List<PlayerModel> availablePlayers, // Changed name for clarity
  //   required Vector2 fieldSize,
  // }) {
  //   zlog(data: "Generating away players for lineup with opposite logic");
  //   List<PlayerModel> homeScenePlayers = scene.components
  //       .whereType<PlayerModel>()
  //       .where((p) => p.playerType == PlayerType.HOME)
  //       .toList();
  //
  //   List<PlayerModel> playersToAdd = [];
  //
  //   // Map: Home Player "ROLE_JERSEY" -> Target Away Player Tuple<Role, Jersey>
  //   // This map defines the tactical opposites.
  //   // Assumes your Tuple class can create a 2-element tuple like Tuple(item1, item2)
  //   // or you use a custom _TargetPlayerIdentity class.
  //   final Map<String, Tuple2<String, int>> homeToAwayTargetMap = {
  //     "LB_3": Tuple2("RB", 2), // Home LB (3) -> Away RB (2)
  //     "RB_2": Tuple2("LB", 3), // Home RB (2) -> Away LB (3)
  //     "LW_11": Tuple2("RW", 7), // Home LW (11) -> Away RW (7)
  //     "RW_7": Tuple2("LW", 11), // Home RW (7) -> Away LW (11)
  //     "LM_18": Tuple2("RM", 17), // Home LM (18) -> Away RM (17)
  //     "RM_17": Tuple2("LM", 18), // Home RM (17) -> Away LM (18)
  //     // Assuming WB jersey 13 is Left, 12 is Right for Home team
  //     "WB_13": Tuple2("WB", 12), // Home Left WB (13) -> Away Right WB (12)
  //     "WB_12": Tuple2("WB", 13), // Home Right WB (12) -> Away Left WB (13)
  //     // Assuming W jersey 23 is Left, 22 is Right for Home team
  //     "W_23": Tuple2("W", 22), // Home Left W (23) -> Away Right W (22)
  //     "W_22": Tuple2("W", 23), // Home Right W (22) -> Away Left W (23)
  //   };
  //
  //   for (PlayerModel homePlayer in homeScenePlayers) {
  //     String targetAwayRole = homePlayer.role;
  //     int targetAwayJersey = homePlayer.jerseyNumber;
  //
  //     String homePlayerKey = "${homePlayer.role}_${homePlayer.jerseyNumber}";
  //
  //     if (homeToAwayTargetMap.containsKey(homePlayerKey)) {
  //       Tuple2<String, int> targetIdentity =
  //           homeToAwayTargetMap[homePlayerKey]!;
  //       targetAwayRole = targetIdentity.item1;
  //       targetAwayJersey = targetIdentity.item2;
  //       zlog(
  //           data:
  //               "Mapping Home (${homePlayer.role} #${homePlayer.jerseyNumber}) to target Away Identity (${targetAwayRole} #${targetAwayJersey})");
  //     } else {
  //       // Player role is symmetrical (CB, GK, CM, CDM, ST, CAM, CF, F)
  //       // Their role and jersey number remain the same for the opponent search.
  //       zlog(
  //           data:
  //               "No specific mapping for Home (${homePlayer.role} #${homePlayer.jerseyNumber}). Using same role/jersey for Away search.");
  //     }
  //
  //     PlayerModel? awayPlayerMatch = availablePlayers.firstWhereOrNull(
  //       (player) =>
  //           player.role == targetAwayRole &&
  //           player.jerseyNumber == targetAwayJersey,
  //     );
  //
  //     if (awayPlayerMatch != null) {
  //       // Use the original position mirroring logic, as you mentioned it was working fine.
  //       Vector2 mirroredOffset = Vector2(
  //         1.0 -
  //             ((homePlayer.offset?.x ?? 0) -
  //                 (SizeHelper.getBoardRelativeVector(
  //                       gameScreenSize: fieldSize,
  //                       actualPosition: homePlayer.size ?? Vector2.zero(),
  //                     ).x *
  //                     1.25 /
  //                     2)),
  //         homePlayer.offset?.y ?? 0, // Y-coordinate remains the same
  //       );
  //
  //       zlog(
  //           data:
  //               "Found Away Player: ${awayPlayerMatch.role} #${awayPlayerMatch.jerseyNumber}. Original Home offset: ${homePlayer.offset}, Mirrored Away offset: $mirroredOffset");
  //
  //       PlayerModel finalAwayPlayer =
  //           awayPlayerMatch.copyWith(offset: mirroredOffset);
  //       playersToAdd.add(finalAwayPlayer);
  //     } else {
  //       zlog(
  //           data:
  //               "CRITICAL: Could not find matching away player for Home (${homePlayer.role} #${homePlayer.jerseyNumber}) with target Away Identity (${targetAwayRole} #${targetAwayJersey}) in availableAwayPlayers. Check awayPlayers list and mapping.");
  //     }
  //   }
  //
  //   return playersToAdd;
  // }
}
