import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/custom_cropper_page.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/datastructures/tuple.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/services/connectivity_service.dart';
import 'package:zporter_tactical_board/app/services/firebase_storage_service.dart';
import 'package:zporter_tactical_board/app/services/image_migration/image_migration_service.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/domain/admin/lineup/default_lineup_repository.dart';

abstract class PlayerDialogResult {}

class PlayerUpdateResult extends PlayerDialogResult {
  final PlayerModel updatedPlayer;
  PlayerUpdateResult(this.updatedPlayer);
}

class PlayerSwapResult extends PlayerDialogResult {
  final PlayerModel playerToBench;
  final PlayerModel playerToBringIn;

  PlayerSwapResult(
      {required this.playerToBench, required this.playerToBringIn});
}

class PlayerUtilsV2 {
  static DefaultLineupRepository _repository = sl.get();
  static const String _homePlayersStoreName = 'home_players_store';
  static const String _awayPlayersStoreName = 'away_players_store';

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
    Tuple3("CDM", "663b8a00a1b2c3d4e5f6a006",
        6), // CDM Central Defending Midfielder
    Tuple3("RW", "663b8a00a1b2c3d4e5f6a007", 7), // RW Right Wing
    Tuple3("CM", "663b8a00a1b2c3d4e5f6a008", 8), // CM Central Midfield
    Tuple3("ST", "663b8a00a1b2c3d4e5f6a009", 9), // ST Striker
    Tuple3("CAM", "663b8a00a1b2c3d4e5f6a010",
        10), // CAM Central Attacking Midfield
    Tuple3("LW", "663b8a00a1b2c3d4e5f6a011", 11), // LW Left Wing
    Tuple3("WB", "663b8a00a1b2c3d4e5f6a012", 12), // WB Wing Back (Right?)
    Tuple3("WB", "663b8a00a1b2c3d4e5f6a013", 13), // WB Wing Back (Left?)
    Tuple3("CB", "663b8a00a1b2c3d4e5f6a014", 14), // CB Center Back
    Tuple3("CB", "663b8a00a1b2c3d4e5f6a015", 15), // CB Center Back
    Tuple3("CDM", "663b8a00a1b2c3d4e5f6a016",
        16), // CDM Central Defending Midfielder
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
    Tuple3("CDM", "663b8a99a1b2c3d4e5f6b006",
        6), // CDM Central Defending Midfielder
    Tuple3("RW", "663b8a99a1b2c3d4e5f6b007", 7), // RW Right Wing
    Tuple3("CM", "663b8a99a1b2c3d4e5f6b008", 8), // CM Central Midfield
    Tuple3("ST", "663b8a99a1b2c3d4e5f6b009", 9), // ST Striker
    Tuple3("CAM", "663b8a99a1b2c3d4e5f6b010",
        10), // CAM Central Attacking Midfield
    Tuple3("LW", "663b8a99a1b2c3d4e5f6b011", 11), // LW Left Wing
    Tuple3("WB", "663b8a99a1b2c3d4e5f6b012", 12), // WB Wing Back (Right?)
    Tuple3("WB", "663b8a99a1b2c3d4e5f6b013", 13), // WB Wing Back (Left?)
    Tuple3("CB", "663b8a99a1b2c3d4e5f6b014", 14), // CB Center Back
    Tuple3("CB", "663b8a99a1b2c3d4e5f6b015", 15), // CB Center Back
    Tuple3("CDM", "663b8a99a1b2c3d4e5f6b016",
        16), // CDM Central Defending Midfielder
    Tuple3("RM", "663b8a99a1b2c3d4e5f6b017", 17), // RM Right Midfield
    Tuple3("LM", "663b8a99a1b2c3d4e5f6b018", 18), // LM Left Midfield
    Tuple3("CF", "663b8a99a1b2c3d4e5f6b019", 19), // CF Center Forward
    Tuple3("F", "663b8a99a1b2c3d4e5f6b020", 20), // F Forward
    Tuple3("GK", "663b8a99a1b2c3d4e5f6b021", 21), // GK Goalkeeper
    Tuple3("W", "663b8a99a1b2c3d4e5f6b022", 22), // W Winger (Right?)
    Tuple3("W", "663b8a99a1b2c3d4e5f6b023", 23), // W Winger (Left?)
  ];

  static List<Tuple3<String, String, int>> otherPlayers = [
    Tuple3("REF", "F1XED0THERPLAYERID00001", 1),
    Tuple3("REF", "F1XED0THERPLAYERID00002", 2),
    Tuple3("REF", "F1XED0THERPLAYERID00003", 3),
    Tuple3("REF", "F1XED0THERPLAYERID00004", 4),
    Tuple3("REF", "F1XED0THERPLAYERID00005", 5),
    Tuple3("REF", "F1XED0THERPLAYERID00006", 6),
    Tuple3("HC", "F1XED0THERPLAYERID00007", -1),
    Tuple3("AC", "F1XED0THERPLAYERID00008", -1),
    Tuple3("GKC", "F1XED0THERPLAYERID00009", -1),
    Tuple3("SPC", "F1XED0THERPLAYERID00010", -1),
    Tuple3("ANA", "F1XED0THERPLAYERID00011", -1),
    Tuple3("TM", "F1XED0THERPLAYERID00012", -1),
    Tuple3("PHY", "F1XED0THERPLAYERID00013", -1),
    Tuple3("DR", "F1XED0THERPLAYERID00014", -1),
    Tuple3("SD", "F1XED0THERPLAYERID00015", -1),
  ];

  static Tuple3<String, String, int>? findDefaultPlayerDataById(
      String playerId) {
    final allDefaultPlayers = [...homePlayers, ...awayPlayers];
    return allDefaultPlayers.firstWhereOrNull((p) => p.item2 == playerId);
  }

  static Future<List<PlayerModel>> getOrInitializeHomePlayers() async {
    final db = await SemDB.database;
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

  static Stream<List<PlayerModel>> watchHomePlayers() async* {
    final db = await SemDB.database;
    final query = _homePlayersStore.query();
    final stream = query.onSnapshots(db);

    yield* stream.map((snapshots) {
      return snapshots
          .map((snapshot) => PlayerModel.fromJson(snapshot.value))
          .toList();
    });
  }

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
    final query = _awayPlayersStore.query();
    final stream = query.onSnapshots(db);
    yield* stream.map((snapshots) {
      return snapshots
          .map((snapshot) => PlayerModel.fromJson(snapshot.value))
          .toList();
    });
  }

  static Future<void> _savePlayersToDb(Database db, List<PlayerModel> players,
      StoreRef<String, Map<String, dynamic>> store) async {
    await db.transaction((txn) async {
      for (var player in players) {
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
          color = ColorManager.black;
          break;
      }

      // --- CHANGE 1: UPDATE PlayerModel constructor to initialize both numbers ---
      PlayerModel playerModelV2 = PlayerModel(
        id: id,
        role: p.item1,
        jerseyNumber: p.item3, // This is the permanent "role" number
        displayNumber:
            p.item3 > 0 ? p.item3 : null, // The display number starts the same
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
        scene.components.whereType<PlayerModel>().toList();

    List<PlayerModel> playersToAdd = scenePlayers.map((p) {
      return availablePlayers
          .firstWhere((player) => player.id == p.id)
          .copyWith(offset: p.offset);
    }).toList();
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
        .where((p) => p.playerType == PlayerType.HOME)
        .toList();

    List<PlayerModel> playersToAdd = [];

    for (PlayerModel p in scenePlayers) {
      // --- NO CHANGE: Lineup logic correctly uses the permanent 'jerseyNumber' ---
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
        );
        playerModel = playerModel.copyWith(offset: offset);
        playersToAdd.add(playerModel);
      }
    }

    return playersToAdd;
  }

  static List<String> getUniqueRoles() {
    final Set<String> roles = {};
    final allPlayersData = [...homePlayers, ...awayPlayers];
    for (var playerDataTuple in allPlayersData) {
      roles.add(playerDataTuple.item1);
    }
    final sortedRoles = roles.toList()..sort();
    // Add "-" option at the beginning for neutral/no role display
    final rolesWithNeutral = ['-', ...sortedRoles];
    return rolesWithNeutral.isNotEmpty
        ? rolesWithNeutral
        : ['-', 'GK', 'DEF', 'MID', 'FWD', 'ST'];
  }

  static Future<bool> isJerseyNumberTaken(
      int jerseyNumber, PlayerType playerType, String currentPlayerId) async {
    List<PlayerModel> teamPlayers;
    switch (playerType) {
      case PlayerType.HOME:
        teamPlayers = await getOrInitializeHomePlayers();
        break;
      case PlayerType.AWAY:
        teamPlayers = await getOrInitializeAwayPlayers();
        break;
      default:
        return false;
    }

    // --- CHANGE 2: Check against the DISPLAY number now ---
    for (var player in teamPlayers) {
      if (player.id != currentPlayerId &&
          player.displayNumber == jerseyNumber) {
        return true;
      }
    }
    return false;
  }

  static Future<void> updatePlayerInDb(PlayerModel player) async {
    final db = await SemDB.database;
    StoreRef<String, Map<String, dynamic>> store;

    switch (player.playerType) {
      case PlayerType.HOME:
        store = _homePlayersStore;
        break;
      case PlayerType.AWAY:
        store = _awayPlayersStore;
        break;
      default:
        zlog(
            data:
                'Player type ${player.playerType} not supported for individual updates.');
        return;
    }

    try {
      await store.record(player.id).put(db, player.toJson());
      zlog(
          data:
              'Player ${player.id} (${player.name}) updated in store: ${store.name} - ${player.toJson()}');
    } catch (e) {
      zlog(data: 'Error updating player ${player.id} in DB: $e');
      rethrow;
    }
  }

  static Future<void> deletePlayerInDb(PlayerModel player) async {
    final db = await SemDB.database;
    StoreRef<String, Map<String, dynamic>> store;

    switch (player.playerType) {
      case PlayerType.HOME:
        store = _homePlayersStore;
        break;
      case PlayerType.AWAY:
        store = _awayPlayersStore;
        break;
      default:
        zlog(
            data:
                'Player type ${player.playerType} not supported for deletion.');
        return;
    }

    try {
      await store.record(player.id).delete(db);
      zlog(
          data:
              'Player ${player.id} (${player.name}) deleted from store: ${store.name}');
    } catch (e) {
      zlog(data: 'Error deleting player ${player.id} from DB: $e');
      rethrow;
    }
  }

  static Future<PlayerModel?> showCreatePlayerDialog({
    required BuildContext context,
    required PlayerType playerType,
  }) async {
    final PlayerModel? newPlayer = await showDialog<PlayerModel?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PlayerEditorDialog(
          player: null,
          playerType: playerType,
          showReplace: false,
          onDelete: (p) async {},
          availableRoles: getUniqueRoles(),
        );
      },
    );

    if (newPlayer != null) {
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
    return null;
  }

  static Future<PlayerDialogResult?> showEditPlayerDialog(
      {required BuildContext context,
      required PlayerModel player,
      List<PlayerModel> rosterPlayers = const [],
      required bool showReplace}) async {
    // final PlayerDialogResult? result = await showDialog<PlayerDialogResult?>(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext dialogContext) {
    //     return PlayerEditorDialog(
    //       player: player,
    //       showReplace: showReplace,
    //       playerType: player.playerType,
    //       onDelete: (p) async {
    //         await deletePlayerInDb(p);
    //       },
    //       availableRoles: getUniqueRoles(),
    //       availableReplacements: rosterPlayers,
    //     );
    //   },
    // );
    //
    // if (result is PlayerUpdateResult) {
    //   if (result.updatedPlayer != player) {
    //     zlog(data: 'Player model changed. Saving to database...');
    //     try {
    //       await updatePlayerInDb(result.updatedPlayer);
    //     } catch (e) {
    //       zlog(data: 'Failed to update player: $e');
    //     }
    //   }
    // }
    // return result;

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
          availableReplacements: rosterPlayers,
        );
      },
    );

    // The save logic has been removed from here and moved to the toolbar.
    return result;
  }

  static Future<PlayerModel?> getPlayerFromDbById(String playerId) async {
    if (playerId.isEmpty) {
      return null;
    }

    final db = await SemDB.database;
    Map<String, dynamic>? playerData;

    try {
      var snapshot = await _homePlayersStore.record(playerId).getSnapshot(db);
      if (snapshot != null) {
        playerData = snapshot.value;
      } else {
        snapshot = await _awayPlayersStore.record(playerId).getSnapshot(db);
        if (snapshot != null) {
          playerData = snapshot.value;
        }
      }

      if (playerData != null) {
        return PlayerModel.fromJson(playerData);
      } else {
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
        return preferredNumber;
    }

    // --- CHANGE 3: Check against the DISPLAY number now ---
    final Set<int> takenNumbers = teamPlayers
        .where((p) => p.id != currentPlayerId && p.displayNumber != null)
        .map((p) => p.displayNumber!)
        .toSet();

    if (preferredNumber >= 1 &&
        preferredNumber <= 99 &&
        !takenNumbers.contains(preferredNumber)) {
      return preferredNumber;
    }

    for (int offset = 1; offset < 99; offset++) {
      int higher = preferredNumber + offset;
      if (higher <= 99 && !takenNumbers.contains(higher)) {
        return higher;
      }
      int lower = preferredNumber - offset;
      if (lower >= 1 && !takenNumbers.contains(lower)) {
        return lower;
      }
    }

    for (int i = 1; i <= 99; i++) {
      if (!takenNumbers.contains(i)) {
        return i;
      }
    }

    throw Exception(
        'All jersey numbers from 1 to 99 are taken for team $playerType.');
  }
}

class PlayerEditorDialog extends StatefulWidget {
  final PlayerModel? player;
  final PlayerType playerType;
  final List<String> availableRoles;
  final Function(PlayerModel) onDelete;
  final List<PlayerModel> availableReplacements;
  final bool showReplace;

  const PlayerEditorDialog({
    super.key,
    this.player,
    required this.onDelete,
    required this.playerType,
    required this.availableRoles,
    this.availableReplacements = const [],
    required this.showReplace,
  });

  @override
  State<PlayerEditorDialog> createState() => _PlayerEditorDialogState();
}

class _PlayerEditorDialogState extends State<PlayerEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _displayNumberController;
  late String? _selectedRole;
  // String? _currentImageBase64;

  final FirebaseStorageService _storageService = FirebaseStorageService();
  CroppedFile?
      _pendingImageFile; // This will hold the new image the user picked (works on web & mobile)
  String? _existingImagePath; // This will hold the player's current path/base64
  String? _existingImageBase64;
  Color? _selectedBorderColor; // Custom border color

  bool _isDefaultPlayer = false;
  final ImagePicker _picker = ImagePicker();
  PlayerModel? _selectedReplacementPlayer;
  bool get isEditMode => widget.player != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nameController = TextEditingController(text: widget.player!.name ?? '');
      // --- CHANGE 2: Initialize controller with the display number ---
      _displayNumberController = TextEditingController(
          text: _isNegativeOrEmpty(widget.player!.displayNumber?.toString()));
      _selectedRole = widget.player!.role;
      // _currentImageBase64 = widget.player!.imageBase64;

      _existingImageBase64 =
          widget.player!.imageBase64; // Store existing image data
      _existingImagePath =
          widget.player!.imagePath; // Store existing image path
      _selectedBorderColor = widget.player!.borderColor; // Load border color

      final defaultData =
          PlayerUtilsV2.findDefaultPlayerDataById(widget.player!.id);
      _isDefaultPlayer = defaultData != null;
    } else {
      _nameController = TextEditingController();
      _displayNumberController = TextEditingController();
      _selectedRole = null;
      _existingImageBase64 = null; // Store existing image data
      _existingImagePath = null; // Store existing image path
      _selectedBorderColor = null; // No custom border color for new players
    }
  }

  String _isNegativeOrEmpty(String? value) {
    if (value == null || value.isEmpty) return '';

    final intValue = int.tryParse(value);
    // Return empty string for negative numbers (-1) or invalid input
    if (intValue == null || intValue < 0) {
      return '';
    }

    // Return the actual value for valid positive numbers
    return value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    // --- CHANGE 3: Dispose the new controller ---
    _displayNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Add a small delay to ensure UI is ready
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512, // Limit image size to prevent memory issues
        maxHeight: 512,
        imageQuality: 85, // Compress image
      );

      // Check if still mounted after async operation
      if (!mounted) return;
      if (pickedFile == null) return;

      // Add small delay before cropping to allow memory cleanup
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressQuality: 80,
        maxWidth: 512, // Limit cropped image size
        maxHeight: 512,
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
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.page,
            customRouteBuilder: (cropper, initCropper, crop, rotate, scale) {
              return MaterialPageRoute(
                builder: (context) => CustomCropperPage(
                  cropper: cropper,
                  initCropper: initCropper,
                  crop: crop,
                  rotate: rotate,
                ),
              );
            },
          ),
        ],
      );

      // Check if widget is still mounted before updating state
      if (!mounted) return;
      if (croppedFile == null) return;

      // Store the CroppedFile directly - it works on both web and mobile
      // CroppedFile has a readAsBytes() method that works on all platforms
      setState(() {
        _pendingImageFile = croppedFile;
        _existingImageBase64 = null; // Clear old images so the new one shows
        _existingImagePath = null; // Clear old images so the new one shows
      });

      zlog(data: 'Image picked and cropped successfully: ${croppedFile.path}');
    } on PlatformException catch (e) {
      zlog(
          data:
              'Platform error during image pick/crop: ${e.code} - ${e.message}');
      if (mounted) {
        String errorMessage = "Error accessing gallery.";
        if (e.code == 'photo_access_denied' ||
            e.code == 'camera_access_denied') {
          errorMessage = "Please grant photo library permission in Settings.";
        }
        BotToast.showText(
          text: errorMessage,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      zlog(data: 'Error during image pick/crop process: $e\n$stackTrace');
      if (mounted) {
        BotToast.showText(
          text:
              "Error processing image. Please try again or choose a smaller image.",
          duration: Duration(seconds: 3),
        );
      }
    }
  }

  /// Gets the default border color based on player type
  Color _getDefaultBorderColor() {
    if (widget.player == null) return ColorManager.blue;

    switch (widget.player!.playerType) {
      case PlayerType.HOME:
        return ColorManager.blue;
      case PlayerType.AWAY:
        return ColorManager.red;
      case PlayerType.OTHER:
      case PlayerType.UNKNOWN:
        return ColorManager.grey;
    }
  }

  /// Shows a color picker dialog for border color
  Future<void> _pickBorderColor() async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = _selectedBorderColor ?? _getDefaultBorderColor();

        return AlertDialog(
          backgroundColor: ColorManager.dark1,
          title: Text(
            'Choose Border Color',
            style: TextStyle(color: ColorManager.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Predefined colors
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildColorOption(ColorManager.blue, 'Blue'),
                    _buildColorOption(ColorManager.red, 'Red'),
                    _buildColorOption(ColorManager.green, 'Green'),
                    _buildColorOption(ColorManager.yellow, 'Yellow'),
                    _buildColorOption(Colors.orange, 'Orange'),
                    _buildColorOption(Colors.purple, 'Purple'),
                    _buildColorOption(Colors.pink, 'Pink'),
                    _buildColorOption(Colors.cyan, 'Cyan'),
                    _buildColorOption(ColorManager.white, 'White'),
                    _buildColorOption(ColorManager.grey, 'Grey'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: ColorManager.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempColor),
              child:
                  Text('Select', style: TextStyle(color: ColorManager.yellow)),
            ),
          ],
        );
      },
    );

    if (pickedColor != null) {
      setState(() {
        _selectedBorderColor = pickedColor;
      });
    }
  }

  /// Builds a color option widget for the color picker
  Widget _buildColorOption(Color color, String label) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, color),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ColorManager.white.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: ColorManager.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onDeleteOrResetPressed() async {
    final playerToEdit = widget.player!;
    final staticData = PlayerUtilsV2.findDefaultPlayerDataById(playerToEdit.id);

    if (staticData != null) {
      // --- RESETTING a default player ---
      final String originalRole = staticData.item1;
      final int originalNumber = staticData.item3;

      // --- CHANGE 4: Resetting now means setting the display number back to the permanent number ---
      final PlayerModel resetPlayerModel = playerToEdit.copyWith(
        role: originalRole,
        displayNumber: originalNumber,
        name: '',
        imageBase64: '',
        imagePath: '',
      );

      if (mounted) {
        Navigator.of(context).pop(PlayerUpdateResult(resetPlayerModel));
      }
      BotToast.showText(text: "Player has been reset to default.");
    } else {
      // --- Deleting a user-created player ---
      widget.onDelete.call(playerToEdit);
      if (mounted) {
        Navigator.of(context).pop(null);
      }
      BotToast.showText(text: "Player deleted permanently.");
    }
  }

  Future<void> _onSavePressed() async {
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

    // Allow "-" as a valid role (neutral/no role)
    if (_selectedRole == null || _selectedRole!.isEmpty) {
      BotToast.showText(text: "Please select a role.");
      return;
    }

    // Parse the number field - allow "-" to mean no number (-1)
    final jerseyNumberText = _displayNumberController.text.trim();
    int? jerseyNumberInt;

    if (jerseyNumberText == '-') {
      // User explicitly wants no number
      jerseyNumberInt = -1;
    } else if (jerseyNumberText.isEmpty) {
      // Empty is also acceptable (will use -1)
      jerseyNumberInt = -1;
    } else {
      // Try to parse as a number
      jerseyNumberInt = int.tryParse(jerseyNumberText);
      if (jerseyNumberInt == null) {
        BotToast.showText(
            text: "Jersey number must be a valid number or '-' for no number.");
        return;
      }
    }

    // Only check for duplicates if the number is not -1 (neutral)
    if (jerseyNumberInt != -1) {
      final String playerIdForCheck =
          isEditMode ? widget.player!.id : RandomGenerator.generateId();
      bool isTaken = await PlayerUtilsV2.isJerseyNumberTaken(
          jerseyNumberInt, widget.playerType, playerIdForCheck);

      if (isTaken) {
        BotToast.showText(
            text: 'Jersey number $jerseyNumberInt is already taken!');
        return;
      }
    }

    String? finalImagePath =
        _existingImagePath; // Start with the existing image path/URL
    String? finalBase64 =
        _existingImageBase64; // Start with existing Base64 (for backwards compatibility)
    bool needsBackgroundMigration = false; // Flag to queue for migration

    // A new file was picked by the user, we MUST handle it.
    if (_pendingImageFile != null) {
      // Read image bytes once - we'll need them for either upload or base64
      Uint8List? imageBytes;
      try {
        imageBytes = await _pendingImageFile!.readAsBytes();
      } catch (e) {
        zlog(data: "Failed to read image file: $e");
        BotToast.showText(text: "Error processing image. Please try again.");
        return; // Stop the save - can't even read the file
      }

      // Check connectivity
      final isOnline = ConnectivityService.statusNotifier.value.isOnline;

      if (isOnline) {
        // ONLINE: Try to upload to Firebase Storage with timeout
        try {
          BotToast.showLoading();

          final String playerIdForUpload =
              widget.player?.id ?? RandomGenerator.generateId();

          // Upload with a reasonable timeout (10 seconds)
          final String downloadURL = await Future.any([
            kIsWeb
                ? _storageService.uploadPlayerImageFromBytes(
                    imageBytes: imageBytes,
                    playerId: playerIdForUpload,
                  )
                : _storageService.uploadPlayerImage(
                    imageFile: File(_pendingImageFile!.path),
                    playerId: playerIdForUpload,
                  ),
            Future.delayed(const Duration(seconds: 10), () {
              throw TimeoutException('Upload timed out after 10 seconds');
            }),
          ]);

          // SUCCESS: Use the URL
          finalImagePath = downloadURL;
          finalBase64 = null; // Clear base64, URL is the truth

          setState(() {
            _existingImagePath = downloadURL;
            _existingImageBase64 = null;
            _pendingImageFile = null;
          });

          zlog(data: "Image uploaded successfully: $downloadURL");
        } catch (e) {
          // UPLOAD FAILED: Fall back to base64 for local storage
          zlog(
              data:
                  "Upload failed ($e), saving base64 locally for later migration");

          finalBase64 = base64Encode(imageBytes);
          finalImagePath = null;
          needsBackgroundMigration = true; // Queue for background upload

          BotToast.showText(
            text: "Image saved. Will upload in background.",
            duration: const Duration(seconds: 2),
          );
        } finally {
          BotToast.cleanAll();
        }
      } else {
        // OFFLINE: Save as base64, queue for migration when online
        zlog(data: "Device offline: Saving as base64 for later migration");

        finalBase64 = base64Encode(imageBytes);
        finalImagePath = null;
        needsBackgroundMigration = true;

        BotToast.showText(
          text: "Saved offline. Will sync when online.",
          duration: const Duration(seconds: 2),
        );
      }
    }

    PlayerModel resultPlayer;
    if (isEditMode) {
      resultPlayer = widget.player!.copyWith(
        name: _nameController.text.trim(),
        role: _selectedRole,
        // Save the parsed int to displayNumber (can be -1 for no number)
        displayNumber: jerseyNumberInt,
        imageBase64: finalBase64, // Pass the (likely null) Base64
        imagePath: finalImagePath, // Pass the new PERMANENT path
        borderColor: _selectedBorderColor, // Save custom border color
        updatedAt: DateTime.now(),
      );
    } else {
      // Logic for creating a new player
      final now = DateTime.now();
      resultPlayer = PlayerModel(
        id: RandomGenerator.generateId(),
        playerType: widget.playerType,
        role: _selectedRole!,
        jerseyNumber: jerseyNumberInt, // Now always has a value
        displayNumber: jerseyNumberInt,
        name: _nameController.text.trim(),
        imageBase64: finalBase64,
        imagePath: finalImagePath, // Save the new permanent path
        borderColor: _selectedBorderColor, // Save custom border color
        color: widget.playerType == PlayerType.HOME
            ? ColorManager.blueAccent
            : ColorManager.red,
        offset: Vector2.zero(),
        size: Vector2(32, 32),
        createdAt: now,
        updatedAt: now,
      );
    }

    // CRITICAL: Save to database BEFORE closing dialog
    // This ensures the player is persisted even if user refreshes immediately
    // Show loading indicator during DB save
    BotToast.showLoading();
    try {
      await PlayerUtilsV2.updatePlayerInDb(resultPlayer);
      zlog(data: "Player ${resultPlayer.id} saved to database successfully");

      // On web, add a small delay to ensure IndexedDB transaction commits
      // IndexedDB writes are async and may not be fully committed when Sembast returns
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 100));
        zlog(data: "IndexedDB flush delay completed");
      }
    } catch (e) {
      zlog(data: "Failed to save player to database: $e");
      BotToast.cleanAll();
      if (mounted) {
        BotToast.showText(text: "Error saving player. Please try again.");
      }
      return; // Don't close dialog if save failed
    } finally {
      BotToast.cleanAll(); // Always clean loading indicator
    }

    // Queue for background migration if needed (upload failed or was offline)
    // This will upload the base64 to Firebase Storage in background and update the player
    if (needsBackgroundMigration && resultPlayer.imageBase64 != null) {
      // Queue immediately since DB save is already complete
      ImageMigrationService().queueForMigration(resultPlayer);
      zlog(
          data:
              "Queued player ${resultPlayer.id} for background image migration");
    }

    if (mounted) {
      if (isEditMode) {
        Navigator.of(context).pop(PlayerUpdateResult(resultPlayer));
      } else {
        Navigator.of(context).pop(resultPlayer);
      }
    }
  }

  // ImageProvider? _getImageProvider() {
  //   if (_currentImageBase64 != null && _currentImageBase64!.isNotEmpty) {
  //     try {
  //       return MemoryImage(base64Decode(_currentImageBase64!));
  //     } catch (e) {
  //       zlog(data: "Error decoding Base64 for UI: $e");
  //       return null;
  //     }
  //   }
  //   return null;
  // }

  // Replace your _getImageProvider() function

  ImageProvider? _getImageProvider() {
    // 1. Did the user just pick a NEW file? Show that (from the temp path).
    if (_pendingImageFile != null) {
      // CroppedFile.path works on both web (blob URL) and mobile (file path)
      if (kIsWeb) {
        // On web, use NetworkImage with the blob URL
        return NetworkImage(_pendingImageFile!.path);
      } else {
        return FileImage(File(_pendingImageFile!.path));
      }
    }

    // 2. Is there an existing Base64 string? (for old data)
    if (_existingImageBase64 != null && _existingImageBase64!.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(_existingImageBase64!));
      } catch (e) {
        zlog(data: "Error decoding Base64 for UI: $e");
      }
    }

    // 3. Is there an existing PERMANENT path/URL? Show that.
    if (_existingImagePath != null && _existingImagePath!.isNotEmpty) {
      // Check if it's a network URL (starts with http:// or https://)
      if (_existingImagePath!.startsWith('http://') ||
          _existingImagePath!.startsWith('https://')) {
        return NetworkImage(_existingImagePath!);
      } else {
        // It's a local file path
        return FileImage(File(_existingImagePath!));
      }
    }

    // 4. If nothing else, show null (which shows the "add photo" icon).
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageProvider = _getImageProvider();

    final String buttonText =
        _isDefaultPlayer ? "Reset to Default" : "Delete Permanently";
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
                          onTap: _pickImage,
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
                          // --- CHANGE 7: Replace DropdownSelector with TextFormField ---
                          Expanded(
                            child: TextFormField(
                              // --- MODIFICATION 3: Use the correctly named controller ---
                              controller: _displayNumberController,

                              style: TextStyle(color: ColorManager.white),
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                // --- MODIFICATION 4: Update labels for clarity ---
                                labelText: isEditMode
                                    ? 'Shirt Number (Editable)'
                                    : 'Shirt Number',
                                labelStyle: TextStyle(
                                    color: ColorManager.white.withOpacity(0.7)),
                                hintText: 'Enter number or "-" for none',
                                filled: true,
                                fillColor: ColorManager.dark2,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide.none),
                              ),
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
                          labelText: 'Name (optional)',
                          labelStyle: TextStyle(
                              color: ColorManager.white.withOpacity(0.7)),
                          hintText: 'Leave empty or "-" for no name',
                          hintStyle: TextStyle(
                              color: ColorManager.white.withOpacity(0.5)),
                          filled: true,
                          fillColor: ColorManager.dark2,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Border Color Picker
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Player Border Color',
                                  style: TextStyle(
                                    color: ColorManager.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedBorderColor == null
                                      ? 'Using team default'
                                      : 'Custom color',
                                  style: TextStyle(
                                    color: ColorManager.grey.withOpacity(0.6),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _pickBorderColor(),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _selectedBorderColor ??
                                    _getDefaultBorderColor(),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ColorManager.white.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.color_lens_outlined,
                                color: ColorManager.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_selectedBorderColor != null)
                            IconButton(
                              icon: Icon(Icons.refresh,
                                  color: ColorManager.white),
                              onPressed: () {
                                setState(() {
                                  _selectedBorderColor = null;
                                });
                              },
                              tooltip: 'Reset to default team color',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
                        items: widget.availableReplacements,
                        initialValue: _selectedReplacementPlayer,
                        onChanged: (player) {
                          setState(() {
                            _selectedReplacementPlayer = player;
                          });
                        },
                        // --- CHANGE 8: Show the correct number in the dropdown ---
                        itemAsString: (player) =>
                            '${player.displayNumber ?? player.jerseyNumber}. ${player.name ?? 'Player'} - ${player.role}',
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
