import 'package:bot_toast/bot_toast.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/lineup_view_model/lineup_controller.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// --- NOTE: LineupArrangementDialog is no longer imported as it's not used here.
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

final awayPlayersStreamProvider = StreamProvider<List<PlayerModel>>((ref) {
  PlayerUtilsV2.getOrInitializeAwayPlayers();
  return PlayerUtilsV2.watchAwayPlayers();
});

class PlayersToolbarAway extends ConsumerStatefulWidget {
  const PlayersToolbarAway({super.key, this.showFooter = true});
  final bool showFooter;

  @override
  ConsumerState<PlayersToolbarAway> createState() => _PlayersToolbarAwayState();
}

class _PlayersToolbarAwayState extends ConsumerState<PlayersToolbarAway> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  CategorizedFormationGroup? selectedFormation;
  FormationTemplate? selectedLineUp;
  List<CategorizedFormationGroup> teamFormation = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  initiateTeamFormationLocally({
    required List<CategorizedFormationGroup> lineups,
  }) {
    teamFormation = lineups;
    selectedFormation = teamFormation.firstOrNull;
    selectedLineUp = selectedFormation?.templates.firstOrNull;
  }

  List<PlayerModel> generateActivePlayers({
    required List<PlayerModel> sourcePlayers,
    required List<PlayerModel> fieldPlayers,
  }) {
    List<PlayerModel> activePlayers = List.from(sourcePlayers);
    Set<String> fieldPlayerIds = fieldPlayers
        .where((f) => f.playerType == PlayerType.AWAY)
        .map((f) => f.id)
        .toSet();

    activePlayers.removeWhere((p) => fieldPlayerIds.contains(p.id));
    return activePlayers;
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    final lineup = ref.watch(lineupProvider);
    final awayPlayersAsync = ref.watch(awayPlayersStreamProvider);

    if (lineup.categorizedGroups.isNotEmpty && teamFormation.isEmpty) {
      initiateTeamFormationLocally(lineups: lineup.categorizedGroups);
    }

    return awayPlayersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (playersFromDb) {
        final List<PlayerModel> sanitizedPlayers = playersFromDb
            .map((player) => player.copyWith(size: Vector2(32, 32)))
            .toList();
        // --- END OF FIX ---

        // All subsequent logic will now use the sanitized list.
        List<PlayerModel> activeToolbarPlayers = generateActivePlayers(
          sourcePlayers: sanitizedPlayers, // Use the corrected list
          fieldPlayers: bp.players,
        )..sort((a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));

        final String searchTerm = _searchController.text.toLowerCase();
        if (_isSearching && searchTerm.isNotEmpty) {
          activeToolbarPlayers = activeToolbarPlayers
              .where((p) =>
                  (p.name?.toLowerCase().contains(searchTerm) ?? false) ||
                  p.role.toLowerCase().contains(searchTerm))
              .toList();
        }

        return Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(AppSize.s4),
                mainAxisSpacing: AppSize.s4,
                crossAxisSpacing: AppSize.s4,
                children:
                    List.generate(activeToolbarPlayers.length + 1, (index) {
                  if (index == activeToolbarPlayers.length) {
                    return _buildAddPlayer();
                  }
                  PlayerModel player = activeToolbarPlayers[index];
                  return GestureDetector(
                      onDoubleTap: () async {
                        await PlayerUtilsV2.showEditPlayerDialog(
                          context: context,
                          player: player,
                          showReplace: false,
                        );
                      },
                      child: PlayerComponentV2(playerModel: player));
                }),
              ),
            ),
            const SizedBox(height: 10),
            if (widget.showFooter)
              _buildFooter(
                benchPlayers: activeToolbarPlayers,
              )
            else
              const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _buildAddPlayer() {
    return GestureDetector(
        onTap: () async {
          await PlayerUtilsV2.showCreatePlayerDialog(
              context: context, playerType: PlayerType.AWAY);
        },
        child: Icon(
          FontAwesomeIcons.circlePlus,
          color: ColorManager.white,
        ));
  }

  Widget _buildFooter({required List<PlayerModel> benchPlayers}) {
    final boardState = ref.read(boardProvider);
    final playersOnField = boardState.players
        .where((p) => p.playerType == PlayerType.AWAY)
        .toList();
    final bool isRearranging = playersOnField.isNotEmpty;

    return Column(
      children: [
        DropdownSelector<CategorizedFormationGroup>(
          label: "Formation Category",
          hint: "Select Category",
          items: teamFormation,
          initialValue: selectedFormation,
          onChanged: (s) {
            setState(() {
              selectedFormation = s;
              selectedLineUp = selectedFormation?.templates.firstOrNull;
            });
          },
          itemAsString: (item) => item.category.displayName,
        ),
        const SizedBox(height: 10),
        DropdownSelector<FormationTemplate>(
          hint: "Select Lineup",
          label: "Line Up",
          items: selectedFormation?.templates ?? [],
          initialValue: selectedLineUp,
          onChanged: (s) {
            setState(() {
              selectedLineUp = s;
            });
          },
          itemAsString: (item) => item.name,
        ),
        const SizedBox(height: 10),
        CustomButton(
          borderRadius: 3,
          // onTap: () {
          //   final TacticBoard? tacticBoard =
          //       boardState.tacticBoardGame as TacticBoard?;
          //   final AnimationItemModel? scene = selectedLineUp?.scene;
          //
          //   if (scene == null || tacticBoard == null) {
          //     BotToast.showText(text: "Please select a lineup first.");
          //     return;
          //   }
          //
          //   // --- 1. IDENTIFY ACTORS AND PREPARE LISTS ---
          //   final List<PlayerModel> currentPlayersOnField = playersOnField;
          //   final List<PlayerModel> currentPlayersOnBench = benchPlayers;
          //
          //   // --- Get home template and MIRROR positions for AWAY team ---
          //   final List<PlayerModel> targetPositions =
          //       scene.components.whereType<PlayerModel>().map((homePlayer) {
          //     Vector2 mirroredOffset = Vector2(
          //       1 -
          //           ((homePlayer.offset?.x ?? 0) -
          //               (SizeHelper.getBoardRelativeVector(
          //                     gameScreenSize: tacticBoard.gameField.size,
          //                     actualPosition: homePlayer.size ?? Vector2.zero(),
          //                   ).x *
          //                   1.25 /
          //                   2)),
          //       1 -
          //           ((homePlayer.offset?.y ?? 0) -
          //               (SizeHelper.getBoardRelativeVector(
          //                     gameScreenSize: tacticBoard.gameField.size,
          //                     actualPosition: homePlayer.size ?? Vector2.zero(),
          //                   ).y /
          //                   2)),
          //     );
          //     return homePlayer.copyWith(
          //         offset: mirroredOffset, playerType: PlayerType.AWAY);
          //   }).toList();
          //
          //   final List<PlayerModel> finalLineup = [];
          //
          //   List<PlayerModel> playersToAssign =
          //       List.from(currentPlayersOnField);
          //   List<PlayerModel> unfilledPositions = List.from(targetPositions);
          //
          //   // --- 2. PASS 1: PERFECT ROLE MATCHES ---
          //   List<PlayerModel> tempPlayers = [];
          //   for (var player in playersToAssign) {
          //     final positionIndex = unfilledPositions
          //         .indexWhere((pos) => pos.role == player.role);
          //     if (positionIndex != -1) {
          //       final position = unfilledPositions.removeAt(positionIndex);
          //       finalLineup.add(player.copyWith(offset: position.offset));
          //     } else {
          //       tempPlayers.add(player);
          //     }
          //   }
          //   playersToAssign = tempPlayers;
          //
          //   // --- 3. PASS 2: FILL REMAINING POSITIONS WITH REMAINING FIELD PLAYERS ---
          //   // This ensures field players are kept on the field.
          //   while (playersToAssign.isNotEmpty && unfilledPositions.isNotEmpty) {
          //     final player = playersToAssign.removeAt(0);
          //     final position = unfilledPositions.removeAt(0);
          //     finalLineup.add(player.copyWith(offset: position.offset));
          //   }
          //
          //   // --- 4. PASS 3: HANDLE PLAYER COUNT DIFFERENCES ---
          //   if (unfilledPositions.isNotEmpty) {
          //     List<PlayerModel> benchCandidates =
          //         List.from(currentPlayersOnBench);
          //     while (
          //         benchCandidates.isNotEmpty && unfilledPositions.isNotEmpty) {
          //       final player = benchCandidates.removeAt(0);
          //       final position = unfilledPositions.removeAt(0);
          //       finalLineup.add(player.copyWith(offset: position.offset));
          //     }
          //   }
          //
          //   // --- 5. APPLY CHANGES TO THE TACTICAL BOARD (Granular Update) ---
          //   final Set<String> finalPlayerIds =
          //       finalLineup.map((p) => p.id).toSet();
          //   final List<PlayerModel> playersToRemove = currentPlayersOnField
          //       .where((p) => !finalPlayerIds.contains(p.id))
          //       .toList();
          //
          //   if (playersToRemove.isNotEmpty) {
          //     tacticBoard.removeFieldItems(playersToRemove);
          //     zlog(data: "Benched ${playersToRemove.length} away players.");
          //   }
          //
          //   for (final playerState in finalLineup) {
          //     tacticBoard.removeFieldItems([playerState]);
          //     tacticBoard.addItem(playerState);
          //   }
          //
          //   zlog(
          //       data:
          //           "Away board updated. ${finalLineup.length} players on field.");
          //   // =================================================================== //
          //   // END: CORRECTED "PLAYER-FIRST" LINEUP LOGIC (AWAY)                 //
          //   // =================================================================== //
          // },

          onTap: () {
            final TacticBoard? tacticBoard =
                boardState.tacticBoardGame as TacticBoard?;
            final AnimationItemModel? scene = selectedLineUp?.scene;

            if (scene == null || tacticBoard == null) {
              BotToast.showText(text: "Please select a lineup first.");
              return;
            }

            // =================================================================== //
            // START: NEW "PLAYER-FIRST" LINEUP LOGIC (AWAY)                     //
            // =================================================================== //
            zlog(
                data:
                    "Applying new AWAY formation with a 'Player-First' strategy.");

            // --- 1. GATHER ACTORS ---
            // The definitive list of AWAY players currently ON THE FIELD.
            final List<PlayerModel> currentPlayersOnField = boardState.players
                .where((p) => p.playerType == PlayerType.AWAY)
                .toList();

            // The definitive list of AWAY players currently ON THE BENCH.
            final List<PlayerModel> currentPlayersOnBench = benchPlayers;

            zlog(
                data:
                    "Away Field: ${currentPlayersOnField.length}, Bench: ${currentPlayersOnBench.length}");

            // --- 2. GENERATE MIRRORED AWAY POSITIONS FROM HOME TEMPLATE ---
            // Formation templates are always stored from the Home perspective.
            // We must mirror the positions for the Away team.
            final List<PlayerModel> homeTemplatePositions =
                scene.components.whereType<PlayerModel>().toList();

            final List<PlayerModel> targetPositions =
                homeTemplatePositions.map((homePlayer) {
              // This is your existing, correct mirroring logic.
              Vector2 mirroredOffset = Vector2(
                1 -
                    ((homePlayer.offset?.x ?? 0) -
                        (SizeHelper.getBoardRelativeVector(
                              gameScreenSize: tacticBoard.gameField.size,
                              actualPosition: homePlayer.size ?? Vector2.zero(),
                            ).x *
                            1.25 /
                            2)),
                1 -
                    ((homePlayer.offset?.y ?? 0) -
                        (SizeHelper.getBoardRelativeVector(
                              gameScreenSize: tacticBoard.gameField.size,
                              actualPosition: homePlayer.size ?? Vector2.zero(),
                            ).y /
                            2)),
              );
              // Return a new PlayerModel representing the mirrored position.
              return homePlayer.copyWith(
                  offset: mirroredOffset, playerType: PlayerType.AWAY);
            }).toList();

            zlog(data: "Target Away Positions: ${targetPositions.length}");

            // This will hold our final calculated lineup.
            final List<PlayerModel> finalLineup = [];

            // Create mutable lists that we can remove items from as we assign them.
            List<PlayerModel> playersToAssign =
                List.from(currentPlayersOnField);
            List<PlayerModel> unfilledPositions = List.from(targetPositions);

            // --- 3. PASS 1: ASSIGN FIELD PLAYERS WITH PERFECT ROLE MATCHES ---
            List<PlayerModel> remainingFieldPlayers = [];
            for (final player in playersToAssign) {
              final positionIndex = unfilledPositions
                  .indexWhere((pos) => pos.role == player.role);

              if (positionIndex != -1) {
                final position = unfilledPositions.removeAt(positionIndex);
                finalLineup.add(player.copyWith(offset: position.offset));
              } else {
                remainingFieldPlayers.add(player);
              }
            }
            zlog(
                data:
                    "Pass 1 (Away Role Match): Assigned ${finalLineup.length} players. ${remainingFieldPlayers.length} field players remain.");

            // --- 4. PASS 2: FILL REMAINING POSITIONS WITH REMAINING FIELD PLAYERS ---
            // Ensures the same XI players stay on the field.
            while (remainingFieldPlayers.isNotEmpty &&
                unfilledPositions.isNotEmpty) {
              final player = remainingFieldPlayers.removeAt(0);
              final position = unfilledPositions.removeAt(0);
              finalLineup.add(player.copyWith(offset: position.offset));
            }
            zlog(
                data:
                    "Pass 2 (Away Fill Field): Assigned remaining field players. Total on field: ${finalLineup.length}.");

            // --- 5. PASS 3: HANDLE PLAYER COUNT MISMATCHES ---
            // Case A: New formation needs MORE players.
            if (unfilledPositions.isNotEmpty) {
              zlog(
                  data:
                      "Away formation requires ${unfilledPositions.length} more players. Filling from bench.");
              List<PlayerModel> benchCandidates =
                  List.from(currentPlayersOnBench);

              while (
                  benchCandidates.isNotEmpty && unfilledPositions.isNotEmpty) {
                final player = benchCandidates.removeAt(0);
                final position = unfilledPositions.removeAt(0);
                finalLineup.add(player.copyWith(offset: position.offset));
              }
            }
            // Case B: New formation needs FEWER players is handled implicitly.

            // --- 6. APPLY THE CHANGES TO THE TACTICAL BOARD (ATOMIC UPDATE) ---
            final Set<String> finalPlayerIds =
                finalLineup.map((p) => p.id).toSet();

            // Find players to remove: those on the field now but NOT in the final lineup.
            final List<PlayerModel> playersToRemove = currentPlayersOnField
                .where((p) => !finalPlayerIds.contains(p.id))
                .toList();

            if (playersToRemove.isNotEmpty) {
              tacticBoard.removeFieldItems(playersToRemove);
              zlog(
                  data:
                      "Benched ${playersToRemove.length} away players: ${playersToRemove.map((p) => p.jerseyNumber).join(', ')}");
            }

            // Add or Update players in the final lineup.
            for (final playerState in finalLineup) {
              tacticBoard.removeFieldItems(
                  [playerState]); // Removes by ID if it exists
              tacticBoard.addItem(
                  playerState); // Adds the updated player with new offset
            }

            zlog(
                data:
                    "Away board update complete. ${finalLineup.length} players are on the field.");
            // =================================================================== //
            // END: NEW "PLAYER-FIRST" LINEUP LOGIC (AWAY)                       //
            // =================================================================== //
          },
          fillColor: ColorManager.blue,
          child: Text(
            isRearranging ? "RE-ARRANGE" : "ADD",
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
