import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/datastructures/tuple.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/domain/admin/lineup/default_lineup_repository.dart';

abstract class PlayerDialogResult {}

/// Represents the action of updating the current player's details.
class PlayerUpdateResult extends PlayerDialogResult {
  final PlayerModel updatedPlayer;
  PlayerUpdateResult(this.updatedPlayer);
}

/// Represents the action of swapping the current player with another from the roster.
class PlayerSwapResult extends PlayerDialogResult {
  /// The player currently being edited, who will be moved to the bench.
  final PlayerModel playerToBench;

  /// The player from the bench who will be moved to the field.
  final PlayerModel playerToBringIn;

  PlayerSwapResult(
      {required this.playerToBench, required this.playerToBringIn});
}

class PlayerUtilsV2 {
  static DefaultLineupRepository _repository = sl.get();
  // --- Sembast Store Definitions ---
  static const String _homePlayersStoreName = 'home_players_store';
  static const String _awayPlayersStoreName = 'away_players_store';

  // We use stringMapStoreFactory for storing maps with string keys (player.id)
  static final _homePlayersStore =
      stringMapStoreFactory.store(_homePlayersStoreName);
  static final _awayPlayersStore =
      stringMapStoreFactory.store(_awayPlayersStoreName);
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

  static Tuple3<String, String, int>? findDefaultPlayerDataById(
      String playerId) {
    final allDefaultPlayers = [...homePlayers, ...awayPlayers];
    return allDefaultPlayers.firstWhereOrNull((p) => p.item2 == playerId);
  }

  /// Fetches home players from DB, or generates from static data and saves if DB is empty.
  static Future<List<PlayerModel>> getOrInitializeHomePlayers() async {
    final db = await SemDB.database;
    // Check if store has any records. Using count() is efficient for this.
    final recordCount = await _homePlayersStore.count(db);

    if (recordCount == 0) {
      zlog(
          data:
              'Home players not found in DB. Generating from static data and saving...');
      List<PlayerModel> staticHomePlayers =
          generatePlayerModelList(playerType: PlayerType.HOME);
      await _savePlayersToDb(db, staticHomePlayers, _homePlayersStore);
      return staticHomePlayers;
    } else {
      zlog(data: 'Found $recordCount home players in DB. Loading...');
      final records = await _homePlayersStore.find(db);
      return records
          .map((snapshot) => PlayerModel.fromJson(snapshot.value))
          .toList();
    }
  }

  // ... inside PlayerUtilsV2

  static Stream<List<PlayerModel>> watchHomePlayers() async* {
    final db = await SemDB.database;

    // CORRECTED: First, create a query from the store.
    final query = _homePlayersStore.query();

    // Then, call onSnapshots on the query object.
    final stream = query.onSnapshots(db);

    // The rest of the stream transformation logic is correct and remains the same.
    yield* stream.map((snapshots) {
      // For each list of snapshots, map it to a list of PlayerModel objects.
      return snapshots
          .map((snapshot) => PlayerModel.fromJson(snapshot.value))
          .toList();
    });
  }

  /// Fetches away players from DB, or generates from static data and saves if DB is empty.
  static Future<List<PlayerModel>> getOrInitializeAwayPlayers() async {
    final db = await SemDB.database;
    final recordCount = await _awayPlayersStore.count(db);

    if (recordCount == 0) {
      zlog(
          data:
              'Away players not found in DB. Generating from static data and saving...');
      List<PlayerModel> staticAwayPlayers =
          generatePlayerModelList(playerType: PlayerType.AWAY);
      await _savePlayersToDb(db, staticAwayPlayers, _awayPlayersStore);
      return staticAwayPlayers;
    } else {
      zlog(data: 'Found $recordCount away players in DB. Loading...');
      final records = await _awayPlayersStore.find(db);
      return records
          .map((snapshot) => PlayerModel.fromJson(snapshot.value))
          .toList();
    }
  }

  static Stream<List<PlayerModel>> watchAwayPlayers() async* {
    final db = await SemDB.database;

    // Create a query for the away players store
    final query = _awayPlayersStore.query();

    // Get the stream of snapshots from the query
    final stream = query.onSnapshots(db);

    // Transform the stream of database data into a stream of PlayerModel lists
    yield* stream.map((snapshots) {
      return snapshots
          .map((snapshot) => PlayerModel.fromJson(snapshot.value))
          .toList();
    });
  }

  /// Saves a list of players to the specified Sembast store.
  static Future<void> _savePlayersToDb(Database db, List<PlayerModel> players,
      StoreRef<String, Map<String, dynamic>> store) async {
    await db.transaction((txn) async {
      for (var player in players) {
        // Using player.id as the key. This will overwrite if a player with the same ID exists.
        await store.record(player.id).put(txn, player.toJson());
      }
    });
    zlog(data: 'Saved ${players.length} players to store: ${store.name}');
  }

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

  static List<String> getUniqueRoles() {
    final Set<String> roles = {};
    // Combine roles from all player lists
    final allPlayersData = [...homePlayers, ...awayPlayers];
    for (var playerDataTuple in allPlayersData) {
      roles.add(playerDataTuple.item1);
    }
    final sortedRoles = roles.toList()..sort();
    // Provide a fallback if no roles are found in static data
    return sortedRoles.isNotEmpty
        ? sortedRoles
        : ['GK', 'DEF', 'MID', 'FWD', 'ST'];
  }

  /// Generates a list of default jersey numbers (1-99).
  static List<int> getDefaultJerseyNumbers() {
    return List.generate(99, (index) => index + 1);
  }

  static Future<bool> isJerseyNumberTaken(
      int jerseyNumber, PlayerType playerType, String currentPlayerId) async {
    List<PlayerModel> teamPlayers;

    // Fetch the relevant team's players
    // These methods should ideally fetch the latest from DB or an up-to-date cache
    switch (playerType) {
      case PlayerType.HOME:
        teamPlayers = await getOrInitializeHomePlayers();
        break;
      case PlayerType.AWAY:
        teamPlayers = await getOrInitializeAwayPlayers();
        break;
      default:
        // For other player types, jersey number uniqueness might not apply or needs different logic.
        // If it can apply to PlayerType.OTHER and they have jersey numbers, extend this.
        zlog(
            data:
                "Jersey number check not applicable for PlayerType: $playerType");
        return false; // Not considered taken for non-Home/Away types by default
    }

    // Check if any *other* player on the team has this jersey number
    for (var player in teamPlayers) {
      if (player.id != currentPlayerId && player.jerseyNumber == jerseyNumber) {
        return true; // Number is taken by another player
      }
    }
    return false; // Number is not taken
  }

  static Future<void> updatePlayerInDb(PlayerModel player) async {
    final db = await SemDB.database;
    StoreRef<String, Map<String, dynamic>> store;

    // Determine the correct store based on playerType
    switch (player.playerType) {
      case PlayerType.HOME:
        store = _homePlayersStore;
        break;
      case PlayerType.AWAY:
        store = _awayPlayersStore;
        break;
      case PlayerType.OTHER:
      case PlayerType.UNKNOWN:
        zlog(
            data:
                'Player type ${player.playerType} not typically stored individually for editing in this context. Update logic might need specific handling if required.');
        // If you need to store/update OTHER players, define a store for them.
        // For now, we'll skip updating for OTHER/UNKNOWN or throw an error.
        return; // Or throw Exception('Cannot update player of type ${player.playerType}');
    }

    try {
      await store.record(player.id).put(db, player.toJson());
      zlog(
          data:
              'Player ${player.id} (${player.name}) updated in store: ${store.name} - ${player.toJson()}');
    } catch (e) {
      zlog(data: 'Error updating player ${player.id} in DB: $e');
      rethrow; // Rethrow to allow caller to handle
    }
  }

  static Future<void> deletePlayerInDb(PlayerModel player) async {
    final db = await SemDB.database;
    StoreRef<String, Map<String, dynamic>> store;

    // Determine the correct store based on playerType
    switch (player.playerType) {
      case PlayerType.HOME:
        store = _homePlayersStore;
        break;
      case PlayerType.AWAY:
        store = _awayPlayersStore;
        break;
      case PlayerType.OTHER:
      case PlayerType.UNKNOWN:
        zlog(
            data:
                'Player type ${player.playerType} not typically stored individually for editing in this context. Update logic might need specific handling if required.');
        // If you need to store/update OTHER players, define a store for them.
        // For now, we'll skip updating for OTHER/UNKNOWN or throw an error.
        return; // Or throw Exception('Cannot update player of type ${player.playerType}');
    }

    try {
      await store.record(player.id).delete(db);
      zlog(
          data:
              'Player ${player.id} (${player.name}) updated in store: ${store.name} - ${player.toJson()}');
    } catch (e) {
      zlog(data: 'Error updating player ${player.id} in DB: $e');
      rethrow; // Rethrow to allow caller to handle
    }
  }

  static Future<PlayerModel?> showCreatePlayerDialog({
    required BuildContext context,
    required PlayerType playerType, // Specify HOME or AWAY
  }) async {
    final PlayerModel? newPlayer = await showDialog<PlayerModel?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PlayerEditorDialog(
          player: null, // Passing null triggers "Create Mode"
          playerType: playerType,
          showReplace: false,
          onDelete: (p) async {},
          availableRoles: getUniqueRoles(),
          availableJerseyNumbers: getDefaultJerseyNumbers(),
        );
      },
    );

    if (newPlayer != null) {
      // If dialog returned a new player, save it to the database.
      // We can reuse updatePlayerInDb as it handles both inserts and updates.
      try {
        await updatePlayerInDb(newPlayer);
        zlog(data: 'New player ${newPlayer.id} successfully saved to DB.');
        return newPlayer;
      } catch (e) {
        zlog(data: 'Failed to save new player: $e');
        if (context.mounted) {
          BotToast.showText(text: "Error: Could not save new player.");
        }
        return null;
      }
    }

    // User cancelled the dialog
    return null;
  }

  /// Shows the dialog to edit player details.
  /// Returns the updated PlayerModel if saved, otherwise null.
  // static Future<PlayerModel?> showEditPlayerDialog({
  //   required BuildContext context,
  //   required PlayerModel player,
  // }) async {
  //   final PlayerModel? resultPlayer = await showDialog<PlayerModel?>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext dialogContext) {
  //       return PlayerEditorDialog(
  //         player: player, // Pass the player to trigger "Edit Mode"
  //         playerType: player.playerType,
  //         onDelete: (p) async {
  //           await deletePlayerInDb(p);
  //         },
  //         availableRoles: getUniqueRoles(),
  //         availableJerseyNumbers: getDefaultJerseyNumbers(),
  //       );
  //     },
  //   );
  //
  //   // The existing save/update logic below this call remains the same and works perfectly.
  //   if (resultPlayer != null) {
  //     if (resultPlayer != player) {
  //       zlog(data: 'Player model changed. Saving to database...');
  //       try {
  //         await updatePlayerInDb(resultPlayer);
  //         return resultPlayer;
  //       } catch (e) {
  //         // ... error handling
  //         return null;
  //       }
  //     } else {
  //       return resultPlayer;
  //     }
  //   }
  //   return null;
  // }

  static Future<PlayerDialogResult?> showEditPlayerDialog(
      {required BuildContext context,
      required PlayerModel player,
      // --- NEW: Pass in the list of available players on the bench ---
      List<PlayerModel> rosterPlayers = const [],
      required bool showReplace}) async {
    // --- MODIFIED: The dialog now returns our custom result type ---
    final PlayerDialogResult? result = await showDialog<PlayerDialogResult?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PlayerEditorDialog(
          player: player,
          showReplace: showReplace,
          playerType: player.playerType,
          onDelete: (p) async {
            await deletePlayerInDb(p);
          },
          availableRoles: getUniqueRoles(),
          availableJerseyNumbers: getDefaultJerseyNumbers(),
          // --- NEW: Pass the roster players to the dialog ---
          availableReplacements: rosterPlayers,
        );
      },
    );

    // --- MODIFIED: Handle the different result types ---
    if (result is PlayerUpdateResult) {
      // The user edited the player's details. Save them.
      if (result.updatedPlayer != player) {
        zlog(data: 'Player model changed. Saving to database...');
        try {
          await updatePlayerInDb(result.updatedPlayer);
        } catch (e) {
          zlog(data: 'Failed to update player: $e');
        }
      }
    }
    // Return the result (update, swap, or null) to the caller to handle board actions.
    return result;
  }

  static Future<PlayerModel?> getPlayerFromDbById(String playerId) async {
    if (playerId.isEmpty) {
      zlog(data: 'Player ID is empty, cannot fetch player.');
      return null;
    }

    final db = await SemDB.database;
    Map<String, dynamic>? playerData;
    PlayerType foundPlayerType =
        PlayerType.UNKNOWN; // To know where it was found

    try {
      // 1. Try to find in the home players store
      var snapshot = await _homePlayersStore.record(playerId).getSnapshot(db);
      if (snapshot != null) {
        playerData = snapshot.value;
        // Assuming PlayerModel.fromJson can derive/handle playerType correctly
        // or the playerType is part of the stored JSON.
        // If not, we infer it here for logging or other logic if needed.
        foundPlayerType = PlayerType.HOME;
        zlog(data: 'Player $playerId found in home players store.');
      } else {
        // 2. If not found in home, try away players store
        snapshot = await _awayPlayersStore.record(playerId).getSnapshot(db);
        if (snapshot != null) {
          playerData = snapshot.value;
          foundPlayerType = PlayerType.AWAY;
          zlog(data: 'Player $playerId found in away players store.');
        }
      }

      // 3. Optionally, search in other stores if you have them (e.g., _otherPlayersStore)
      // if (playerData == null && _otherPlayersStore != null) { // Hypothetical _otherPlayersStore
      //   snapshot = await _otherPlayersStore.record(playerId).getSnapshot(db);
      //   if (snapshot != null) {
      //     playerData = snapshot.value;
      //     foundPlayerType = PlayerType.OTHER; // Or derived from data
      //     zlog(data: 'Player $playerId found in other players store.');
      //   }
      // }

      if (playerData != null) {
        // Ensure the PlayerModel.fromJson correctly reconstructs the playerType
        // or that it's inherently part of the JSON.
        // If your PlayerModel.fromJson doesn't set playerType based on JSON,
        // and you need it on the returned model, you might need to pass `foundPlayerType`
        // or ensure `playerType` is in `playerData`.
        PlayerModel player = PlayerModel.fromJson(playerData);

        // If playerType isn't reliably in JSON, you might need a check or manual setting:
        // if (player.playerType == PlayerType.UNKNOWN && foundPlayerType != PlayerType.UNKNOWN) {
        //   player = player.copyWith(playerType: foundPlayerType); // Assuming copyWith supports this
        // }
        return player;
      } else {
        zlog(data: 'Player with ID $playerId not found in any checked stores.');
        return null;
      }
    } catch (e) {
      zlog(data: 'Error fetching player $playerId from DB: $e');
      return null;
    }
  }

  static Future<int> findClosestUntakenNumber(
    int preferredNumber,
    PlayerType playerType,
    String currentPlayerId,
  ) async {
    List<PlayerModel> teamPlayers;
    switch (playerType) {
      case PlayerType.HOME:
        teamPlayers = await getOrInitializeHomePlayers();
        break;
      case PlayerType.AWAY:
        teamPlayers = await getOrInitializeAwayPlayers();
        break;
      default:
        // For other types, this logic might not apply. Return preferred number as-is.
        return preferredNumber;
    }

    // Create a set of all jersey numbers currently used by *other* players
    final Set<int> takenNumbers = teamPlayers
        .where((p) => p.id != currentPlayerId && p.jerseyNumber > 0)
        .map((p) => p.jerseyNumber)
        .toSet();

    // The preferred number is ideal if it's valid and not taken.
    if (preferredNumber >= 1 &&
        preferredNumber <= 99 &&
        !takenNumbers.contains(preferredNumber)) {
      return preferredNumber;
    }

    // Search outwards from the preferred number for the closest available spot
    for (int offset = 1; offset < 99; offset++) {
      // Check higher number
      int higher = preferredNumber + offset;
      if (higher <= 99 && !takenNumbers.contains(higher)) {
        return higher;
      }
      // Check lower number
      int lower = preferredNumber - offset;
      if (lower >= 1 && !takenNumbers.contains(lower)) {
        return lower;
      }
    }

    // As a last resort (if all numbers 1-99 are somehow taken), find the first possible number.
    // This is highly unlikely in a standard team context.
    for (int i = 1; i <= 99; i++) {
      if (!takenNumbers.contains(i)) {
        return i;
      }
    }

    // Ultimate fallback if every single number is taken, should never be reached.
    // Throws an exception as this indicates a full roster, an unrecoverable state for this function.
    throw Exception(
        'All jersey numbers from 1 to 99 are taken for team $playerType.');
  }
}

class PlayerEditorDialog extends StatefulWidget {
  /// The player to edit. If null, the dialog is in "Create" mode.
  final PlayerModel? player;

  /// The team type (Home/Away) the player belongs to. Required in both modes.
  final PlayerType playerType;

  /// A list of all available roles for the dropdown.
  final List<String> availableRoles;

  final Function(PlayerModel) onDelete;

  /// A list of all available jersey numbers for the dropdown.
  final List<int> availableJerseyNumbers;

  final List<PlayerModel> availableReplacements;

  final bool showReplace;

  const PlayerEditorDialog({
    super.key,
    this.player,
    required this.onDelete,
    required this.playerType,
    required this.availableRoles,
    required this.availableJerseyNumbers,
    this.availableReplacements = const [],
    required this.showReplace,
  });

  @override
  State<PlayerEditorDialog> createState() => _PlayerEditorDialogState();
}

class _PlayerEditorDialogState extends State<PlayerEditorDialog> {
  // State variables for form fields
  late final TextEditingController _nameController;
  late int? _selectedJerseyNumber;
  late String? _selectedRole;
  String? _currentImageBase64;

  // --- State variable to track if the player is a default one ---
  bool _isDefaultPlayer = false;

  final ImagePicker _picker = ImagePicker();
  PlayerModel? _selectedReplacementPlayer;
  bool get isEditMode => widget.player != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      // Standard initialization from the player model
      _nameController = TextEditingController(text: widget.player!.name ?? '');
      _selectedJerseyNumber =
          widget.player!.jerseyNumber > 0 ? widget.player!.jerseyNumber : null;
      _selectedRole = widget.player!.role;
      _currentImageBase64 = widget.player!.imageBase64;

      // --- Check the player's status when the dialog opens ---
      final defaultData =
          PlayerUtilsV2.findDefaultPlayerDataById(widget.player!.id);
      _isDefaultPlayer = defaultData != null;
    } else {
      // Create Mode: Initialize fields as empty
      _nameController = TextEditingController();
      _selectedJerseyNumber = null;
      _selectedRole = null;
      _currentImageBase64 = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Handles picking an image from gallery, cropping it, and converting to Base64.
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return; // User cancelled

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Player Icon',
            toolbarColor: ColorManager.dark1,
            toolbarWidgetColor: ColorManager.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            showCropGrid: false,
            backgroundColor: ColorManager.dark2,
            activeControlsWidgetColor: ColorManager.yellow,
          ),
          IOSUiSettings(
            title: 'Crop Player Icon',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile == null) return; // User cancelled cropping

      final imageBytes = await croppedFile.readAsBytes();
      final base64String = base64Encode(imageBytes);

      setState(() {
        _currentImageBase64 = base64String;
      });
    } catch (e) {
      zlog(data: 'Error during image pick/crop process: $e');
      if (mounted) {
        BotToast.showText(text: "Error processing image. Please try again.");
      }
    }
  }

  /// Handles the "Delete" button press. Decides whether to reset or permanently delete.
  Future<void> _onDeleteOrResetPressed() async {
    final playerToEdit = widget.player!;

    final staticData = PlayerUtilsV2.findDefaultPlayerDataById(playerToEdit.id);

    if (staticData != null) {
      // --- It is a default player -> RESET IT ---
      final String originalRole = staticData.item1;
      final int originalNumber = staticData.item3;

      int finalNumber = await PlayerUtilsV2.findClosestUntakenNumber(
          originalNumber, widget.playerType, playerToEdit.id);

      final PlayerModel resetPlayerModel = playerToEdit.copyWith(
        role: originalRole,
        jerseyNumber: finalNumber,
        name: '',
        imageBase64: '',
        imagePath: '',
      );

      if (mounted) {
        Navigator.of(context).pop(resetPlayerModel);
      }
      BotToast.showText(text: "Player has been reset to default.");
    } else {
      // --- It is a user-created player -> DELETE IT ---
      widget.onDelete.call(playerToEdit);
      if (mounted) {
        Navigator.of(context).pop(null);
      }
      BotToast.showText(text: "Player deleted permanently.");
    }
  }

  // /// Handles the "Save" button press for both Create and Edit modes.
  // Future<void> _onSavePressed() async {
  //   if (_selectedJerseyNumber == null || _selectedRole == null) {
  //     BotToast.showText(text: "Please select a role and jersey number.");
  //     return;
  //   }
  //
  //   final String playerIdForCheck =
  //       isEditMode ? widget.player!.id : RandomGenerator.generateId();
  //   bool isTaken = await PlayerUtilsV2.isJerseyNumberTaken(
  //       _selectedJerseyNumber!, widget.playerType, playerIdForCheck);
  //
  //   if (isTaken) {
  //     BotToast.showText(
  //         text: 'Jersey number $_selectedJerseyNumber is already taken!');
  //     return;
  //   }
  //
  //   PlayerModel resultPlayer;
  //   if (isEditMode) {
  //     resultPlayer = widget.player!.copyWith(
  //       name: _nameController.text.trim(),
  //       role: _selectedRole,
  //       jerseyNumber: _selectedJerseyNumber,
  //       imageBase64: _currentImageBase64,
  //       imagePath: '',
  //       updatedAt: DateTime.now(),
  //     );
  //   } else {
  //     final now = DateTime.now();
  //     resultPlayer = PlayerModel(
  //       id: playerIdForCheck,
  //       playerType: widget.playerType,
  //       role: _selectedRole!,
  //       jerseyNumber: _selectedJerseyNumber!,
  //       name: _nameController.text.trim(),
  //       imageBase64: _currentImageBase64,
  //       color: widget.playerType == PlayerType.HOME
  //           ? ColorManager.blueAccent
  //           : ColorManager.red,
  //       offset: Vector2.zero(),
  //       size: Vector2(32, 32),
  //       createdAt: now,
  //       updatedAt: now,
  //     );
  //   }
  //   if (mounted) {
  //     Navigator.of(context).pop(resultPlayer);
  //   }
  // }

  Future<void> _onSavePressed() async {
    // --- NEW: If a replacement is selected, perform the swap action ---
    if (_selectedReplacementPlayer != null) {
      final result = PlayerSwapResult(
        playerToBench: widget.player!,
        playerToBringIn: _selectedReplacementPlayer!,
      );
      if (mounted) {
        Navigator.of(context).pop(result);
      }
      return;
    }

    // --- EXISTING LOGIC: If no replacement, perform an update ---
    if (_selectedJerseyNumber == null || _selectedRole == null) {
      BotToast.showText(text: "Please select a role and jersey number.");
      return;
    }

    final String playerIdForCheck =
        isEditMode ? widget.player!.id : RandomGenerator.generateId();
    bool isTaken = await PlayerUtilsV2.isJerseyNumberTaken(
        _selectedJerseyNumber!, widget.playerType, playerIdForCheck);

    if (isTaken) {
      BotToast.showText(
          text: 'Jersey number $_selectedJerseyNumber is already taken!');
      return;
    }

    PlayerModel resultPlayer;
    if (isEditMode) {
      resultPlayer = widget.player!.copyWith(
        name: _nameController.text.trim(),
        role: _selectedRole,
        jerseyNumber: _selectedJerseyNumber,
        imageBase64: _currentImageBase64,
        imagePath: '',
        updatedAt: DateTime.now(),
      );
    } else {
      final now = DateTime.now();
      resultPlayer = PlayerModel(
        id: playerIdForCheck,
        playerType: widget.playerType,
        role: _selectedRole!,
        jerseyNumber: _selectedJerseyNumber!,
        name: _nameController.text.trim(),
        imageBase64: _currentImageBase64,
        color: widget.playerType == PlayerType.HOME
            ? ColorManager.blueAccent
            : ColorManager.red,
        offset: Vector2.zero(),
        size: Vector2(32, 32),
        createdAt: now,
        updatedAt: now,
      );
    }
    if (mounted) {
      // --- MODIFIED: Return the correct result type ---
      // Navigator.of(context).pop(PlayerUpdateResult(resultPlayer));

      if (isEditMode) {
        Navigator.of(context).pop(PlayerUpdateResult(resultPlayer));
      } else {
        Navigator.of(context).pop(resultPlayer);
      }
    }
  }

  /// Decodes the Base64 string into an ImageProvider for the UI.
  ImageProvider? _getImageProvider() {
    if (_currentImageBase64 != null && _currentImageBase64!.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(_currentImageBase64!));
      } catch (e) {
        zlog(data: "Error decoding Base64 for UI: $e");
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageProvider = _getImageProvider();

    final String buttonText =
        _isDefaultPlayer ? "Reset to Default" : "Delete Permanently";
    final Color buttonColor =
        _isDefaultPlayer ? (ColorManager.yellow) : (ColorManager.red);

    // --- NEW: A flag to disable editing fields if a replacement is chosen ---
    final bool isReplacing = _selectedReplacementPlayer != null;

    return Dialog(
      backgroundColor: ColorManager.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SizedBox(
        width: context.widthPercent(40),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isEditMode ? 'Edit Player' : 'Create Player',
                  style: theme.textTheme.headlineSmall?.copyWith(
                      color: ColorManager.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              AbsorbPointer(
                absorbing: isReplacing,
                child: Opacity(
                  opacity: isReplacing ? 0.5 : 1.0,
                  child: Column(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap:
                              _pickImage, // This is now controlled by AbsorbPointer
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: ColorManager.white.withOpacity(0.4),
                                image: imageProvider != null
                                    ? DecorationImage(
                                        fit: BoxFit.cover, image: imageProvider)
                                    : null),
                            child: imageProvider == null
                                ? Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: ColorManager.white.withOpacity(0.7),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownSelector<int>(
                              label: 'Nr',
                              items: widget.availableJerseyNumbers,
                              initialValue: _selectedJerseyNumber,
                              hint: "Select Nr",
                              itemAsString: (item) => item.toString(),
                              onChanged: (value) async {
                                if (value == null) {
                                  setState(() => _selectedJerseyNumber = null);
                                  return;
                                }
                                bool isTaken =
                                    await PlayerUtilsV2.isJerseyNumberTaken(
                                        value,
                                        widget.playerType,
                                        isEditMode ? widget.player!.id : '');
                                if (isTaken) {
                                  BotToast.showText(
                                      text:
                                          'Jersey number $value is already taken!');
                                } else {
                                  setState(() => _selectedJerseyNumber = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownSelector<String>(
                              label: 'Role',
                              items: widget.availableRoles,
                              initialValue: _selectedRole,
                              hint: "Select Role",
                              itemAsString: (item) => item,
                              onChanged: (value) =>
                                  setState(() => _selectedRole = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: ColorManager.white),
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(
                              color: ColorManager.white.withOpacity(0.7)),
                          hintText: 'Edit name...',
                          hintStyle: TextStyle(
                              color: ColorManager.white.withOpacity(0.5)),
                          filled: true,
                          fillColor: ColorManager.dark2,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Center(
              //   child: GestureDetector(
              //     onTap: _pickImage,
              //     child: Container(
              //       width: 100,
              //       height: 100,
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(10),
              //           color: ColorManager.white.withOpacity(0.4),
              //           image: imageProvider != null
              //               ? DecorationImage(
              //                   fit: BoxFit.cover, image: imageProvider)
              //               : null),
              //       child: imageProvider == null
              //           ? Icon(
              //               Icons.add_a_photo_outlined,
              //               size: 40,
              //               color: ColorManager.white.withOpacity(0.7),
              //             )
              //           : null,
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 24),
              // Row(
              //   children: [
              //     Expanded(
              //       child: DropdownSelector<int>(
              //         label: 'Nr',
              //         items: widget.availableJerseyNumbers,
              //         initialValue: _selectedJerseyNumber,
              //         hint: "Select Nr",
              //         itemAsString: (item) => item.toString(),
              //         onChanged: (value) async {
              //           if (value == null) {
              //             setState(() => _selectedJerseyNumber = null);
              //             return;
              //           }
              //           bool isTaken = await PlayerUtilsV2.isJerseyNumberTaken(
              //               value,
              //               widget.playerType,
              //               isEditMode ? widget.player!.id : '');
              //           if (isTaken) {
              //             BotToast.showText(
              //                 text: 'Jersey number $value is already taken!');
              //           } else {
              //             setState(() => _selectedJerseyNumber = value);
              //           }
              //         },
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: DropdownSelector<String>(
              //         label: 'Role',
              //         items: widget.availableRoles,
              //         initialValue: _selectedRole,
              //         hint: "Select Role",
              //         itemAsString: (item) => item,
              //         onChanged: (value) =>
              //             setState(() => _selectedRole = value),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 16),
              // TextFormField(
              //   controller: _nameController,
              //   style: TextStyle(color: ColorManager.white),
              //   decoration: InputDecoration(
              //     labelText: 'Name',
              //     labelStyle:
              //         TextStyle(color: ColorManager.white.withOpacity(0.7)),
              //     hintText: 'Enter name...',
              //     hintStyle:
              //         TextStyle(color: ColorManager.white.withOpacity(0.5)),
              //     filled: true,
              //     fillColor: ColorManager.dark2,
              //     border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(8.0),
              //         borderSide: BorderSide.none),
              //   ),
              // ),
              const SizedBox(height: 24),
              if (isEditMode && widget.showReplace) ...[
                const Center(
                  child: Text(
                    "Or replace with",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownSelector<PlayerModel>(
                        label: "Player",
                        hint: widget.availableReplacements.isEmpty
                            ? "No Players Available"
                            : "Select player from roster",
                        items: widget
                            .availableReplacements, // Use the passed-in list
                        initialValue: _selectedReplacementPlayer,
                        onChanged: (player) {
                          setState(() {
                            _selectedReplacementPlayer = player;
                          });
                        },
                        // Nicely format the player's name in the dropdown
                        itemAsString: (player) =>
                            '${player.jerseyNumber}. ${player.name ?? 'Player'} - ${player.role}',
                      ),
                    ),
                    if (isReplacing) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: ColorManager.red),
                        onPressed: () {
                          setState(() {
                            _selectedReplacementPlayer = null;
                          });
                        },
                        tooltip: 'Clear Selection',
                      )
                    ]
                  ],
                ),
                const SizedBox(height: 24),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isEditMode)
                    CustomButton(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      borderRadius: 2,
                      fillColor:
                          isReplacing ? Colors.grey : ColorManager.yellow,
                      onTap: isReplacing ? null : _onDeleteOrResetPressed,
                      child: Text(
                        buttonText,
                        style: theme.textTheme.labelMedium!.copyWith(
                            color: ColorManager.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      CustomButton(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        borderRadius: 2,
                        fillColor: ColorManager.dark1,
                        child: Text(
                          "Cancel",
                          style: theme.textTheme.labelMedium!.copyWith(
                              color: ColorManager.white,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () => Navigator.of(context).pop(null),
                      ),
                      const SizedBox(width: 8),
                      CustomButton(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        borderRadius: 2,
                        fillColor: ColorManager.blue,
                        onTap: _onSavePressed,
                        child: Text("Save",
                            style: theme.textTheme.labelMedium!.copyWith(
                                color: ColorManager.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
