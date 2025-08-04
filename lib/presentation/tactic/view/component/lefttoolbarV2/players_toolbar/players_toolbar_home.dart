import 'package:bot_toast/bot_toast.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
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

final homePlayersStreamProvider = StreamProvider<List<PlayerModel>>((ref) {
  PlayerUtilsV2.getOrInitializeHomePlayers();
  return PlayerUtilsV2.watchHomePlayers();
});

class PlayersToolbarHome extends ConsumerStatefulWidget {
  const PlayersToolbarHome({super.key, this.showFooter = true});

  final bool showFooter;

  @override
  ConsumerState<PlayersToolbarHome> createState() => _PlayersToolbarHomeState();
}

class _PlayersToolbarHomeState extends ConsumerState<PlayersToolbarHome> {
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

  void initiateTeamFormationLocally({
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
        .where((f) => f.playerType == PlayerType.HOME)
        .map((f) => f.id)
        .toSet();

    activePlayers.removeWhere((p) => fieldPlayerIds.contains(p.id));
    return activePlayers;
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    final lineup = ref.watch(lineupProvider);
    final homePlayersAsync = ref.watch(homePlayersStreamProvider);

    if (lineup.categorizedGroups.isNotEmpty && teamFormation.isEmpty) {
      initiateTeamFormationLocally(lineups: lineup.categorizedGroups);
    }

    return homePlayersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (playersFromDb) {
        final List<PlayerModel> sanitizedPlayers = playersFromDb
            .map((player) => player.copyWith(size: Vector2(32, 32)))
            .toList();
        // --- END OF FIX ---

        playersFromDb.forEach((p) {
          zlog(
              data:
                  "Found player for DB ${p.role} - ${p.jerseyNumber} - ${p.name} - ${p.imageBase64}");
        });

        // All subsequent logic will now use the sanitized list.
        List<PlayerModel> activeToolbarPlayers = generateActivePlayers(
          sourcePlayers: sanitizedPlayers, // Use the corrected list
          fieldPlayers: bp.players,
        )..sort((a, b) => (a.displayNumber ?? a.jerseyNumber)
            .compareTo(b.displayNumber ?? b.jerseyNumber));

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
                        final result = await PlayerUtilsV2.showEditPlayerDialog(
                          context: context,
                          player: player,
                          showReplace: false,
                        );

                        if (result is PlayerUpdateResult) {
                          // The dialog returned an updated player, now we save it.
                          await PlayerUtilsV2.updatePlayerInDb(
                              result.updatedPlayer);
                        }
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
              context: context, playerType: PlayerType.HOME);
        },
        child: const Icon(
          FontAwesomeIcons.circlePlus,
          color: ColorManager.white,
        ));
  }

  Widget _buildFooter({required List<PlayerModel> benchPlayers}) {
    final boardState = ref.read(boardProvider);
    final playersOnField = boardState.players
        .where((p) => p.playerType == PlayerType.HOME)
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
          onTap: () {
            final TacticBoard? tacticBoard =
                boardState.tacticBoardGame as TacticBoard?;
            final AnimationItemModel? scene = selectedLineUp?.scene;

            if (scene == null || tacticBoard == null) {
              BotToast.showText(text: "Please select a lineup first.");
              return;
            }

            // =================================================================== //
            // START: NEW "PLAYER-FIRST" LINEUP LOGIC (HOME)                     //
            // =================================================================== //
            zlog(
                data: "Applying new formation with a 'Player-First' strategy.");

            // --- 1. GATHER ACTORS ---
            // The definitive list of players currently ON THE FIELD. THIS IS OUR SOURCE OF TRUTH.
            final List<PlayerModel> currentPlayersOnField = boardState.players
                .where((p) => p.playerType == PlayerType.HOME)
                .toList();

            // The definitive list of players currently ON THE BENCH.
            final List<PlayerModel> currentPlayersOnBench = benchPlayers;

            // The list of POSITIONS (with roles) required by the new formation.
            final List<PlayerModel> targetPositions =
                scene.components.whereType<PlayerModel>().toList();

            zlog(
                data:
                    "Field: ${currentPlayersOnField.length}, Bench: ${currentPlayersOnBench.length}, Target: ${targetPositions.length}");

            // This will hold our final calculated lineup.
            final List<PlayerModel> finalLineup = [];

            // Create mutable lists that we can remove items from as we assign them.
            List<PlayerModel> playersToAssign =
                List.from(currentPlayersOnField);
            List<PlayerModel> unfilledPositions = List.from(targetPositions);

            // --- 2. PASS 1: ASSIGN FIELD PLAYERS WITH PERFECT ROLE MATCHES ---
            // Prioritize keeping players in their preferred roles.
            List<PlayerModel> remainingFieldPlayers = [];
            for (final player in playersToAssign) {
              final positionIndex = unfilledPositions
                  .indexWhere((pos) => pos.role == player.role);

              if (positionIndex != -1) {
                // Found a perfect match. Assign the player to this position.
                final position = unfilledPositions.removeAt(positionIndex);
                finalLineup.add(player.copyWith(offset: position.offset));
              } else {
                // This player is on the field, but their role doesn't exist in the new formation.
                // Keep them aside for the next pass.
                remainingFieldPlayers.add(player);
              }
            }
            zlog(
                data:
                    "Pass 1 (Role Match): Assigned ${finalLineup.length} players. ${remainingFieldPlayers.length} field players remain.");

            // --- 3. PASS 2: FILL REMAINING POSITIONS WITH REMAINING FIELD PLAYERS ---
            // This is the CRITICAL step. It ensures the same XI players stay on the field,
            // even if they have to play out of their 'natural' position.
            while (remainingFieldPlayers.isNotEmpty &&
                unfilledPositions.isNotEmpty) {
              final player = remainingFieldPlayers.removeAt(0);
              final position = unfilledPositions.removeAt(0);
              finalLineup.add(player.copyWith(offset: position.offset));
            }
            zlog(
                data:
                    "Pass 2 (Fill Field): Assigned remaining field players. Total on field: ${finalLineup.length}.");

            // --- 4. PASS 3: HANDLE PLAYER COUNT MISMATCHES ---
            // Case A: New formation needs MORE players (e.g., switching from 10 to 11 men).
            if (unfilledPositions.isNotEmpty) {
              zlog(
                  data:
                      "New formation requires ${unfilledPositions.length} more players. Filling from bench.");
              List<PlayerModel> benchCandidates =
                  List.from(currentPlayersOnBench);

              // (Optional but good): Prioritize bench players by role match as well.
              benchCandidates.sort((a, b) => a.role.compareTo(b.role));
              unfilledPositions.sort((a, b) => a.role.compareTo(b.role));

              while (
                  benchCandidates.isNotEmpty && unfilledPositions.isNotEmpty) {
                final player = benchCandidates.removeAt(0);
                final position = unfilledPositions.removeAt(0);
                finalLineup.add(player.copyWith(offset: position.offset));
              }
            }
            // Case B: New formation needs FEWER players. The players left in `remainingFieldPlayers` are implicitly benched.
            // No extra code is needed for this case. They simply won't be in the `finalLineup`.

            // --- 5. APPLY THE CHANGES TO THE TACTICAL BOARD (ATOMIC UPDATE) ---
            // This is much safer than clearing the board and re-adding.
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
                      "Benched ${playersToRemove.length} players: ${playersToRemove.map((p) => p.jerseyNumber).join(', ')}");
            }

            // Add or Update players in the final lineup.
            for (final playerState in finalLineup) {
              // TacticBoard should be smart enough to either move an existing component or add a new one.
              // A safe implementation is to remove any existing version first, then add the new state.
              tacticBoard.removeFieldItems([playerState]); // Removes by ID
              tacticBoard.addItem(
                  playerState); // Adds the updated player with new offset
            }

            zlog(
                data:
                    "Board update complete. ${finalLineup.length} players are on the field.");
            // =================================================================== //
            // END: NEW "PLAYER-FIRST" LINEUP LOGIC (HOME)                       //
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
