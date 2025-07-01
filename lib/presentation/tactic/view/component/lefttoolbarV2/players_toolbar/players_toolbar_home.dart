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
            // --- START: DIRECT-APPLICATION LOGIC ---
            TacticBoard? tacticBoard =
                boardState.tacticBoardGame as TacticBoard?;
            AnimationItemModel? scene = selectedLineUp?.scene;

            if (scene == null || tacticBoard == null) {
              BotToast.showText(text: "Please select a lineup first.");
              return;
            }

            final List<PlayerModel> targetPositions =
                scene.components.whereType<PlayerModel>().toList();

            // 1. PREPARE PLAYER POOLS
            playersOnField
                .sort((a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));
            final List<PlayerModel> sortedBench = List.from(benchPlayers)
              ..sort((a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));

            final Map<String, PlayerModel> uniquePlayers = {};
            for (var p in playersOnField) {
              uniquePlayers.putIfAbsent(p.id, () => p);
            }
            for (var p in sortedBench) {
              uniquePlayers.putIfAbsent(p.id, () => p);
            }
            final List<PlayerModel> availablePlayers =
                uniquePlayers.values.toList();

            zlog(
                data:
                    "Applying new formation with ${targetPositions.length} positions. Available players: ${availablePlayers.length}.");

            // 2. PERFORM AUTOMATIC ASSIGNMENT
            final List<PlayerModel> finalLineup = [];
            final Set<String> assignedPlayerIds = {};

            // PASS 1: Assign players by matching role.
            for (final targetPos in targetPositions) {
              final roleMatchIndex = availablePlayers.indexWhere((p) =>
                  !assignedPlayerIds.contains(p.id) &&
                  p.role == targetPos.role);

              if (roleMatchIndex != -1) {
                final playerToAssign = availablePlayers[roleMatchIndex];
                finalLineup
                    .add(playerToAssign.copyWith(offset: targetPos.offset));
                assignedPlayerIds.add(playerToAssign.id);
              }
            }

            // PASS 2: Fill remaining spots with leftover players.
            final unassignedPositions = targetPositions
                .where((tp) => !finalLineup.any((p) => p.offset == tp.offset))
                .toList();

            final remainingPlayers = availablePlayers
                .where((p) => !assignedPlayerIds.contains(p.id))
                .toList();

            for (int i = 0; i < unassignedPositions.length; i++) {
              if (i < remainingPlayers.length) {
                final playerToAssign = remainingPlayers[i];
                finalLineup.add(playerToAssign.copyWith(
                    offset: unassignedPositions[i].offset));
                assignedPlayerIds.add(playerToAssign.id);
              }
            }

            zlog(
                data:
                    "New lineup calculated. Total players: ${finalLineup.length}.");

            // 3. APPLY CHANGES DIRECTLY TO THE TACTICAL BOARD
            final Set<String> originalPlayerIdsOnField =
                playersOnField.map((p) => p.id).toSet();
            final Set<String> finalPlayerIdsInLineup =
                finalLineup.map((p) => p.id).toSet();

            final Set<String> idsToRemove =
                originalPlayerIdsOnField.difference(finalPlayerIdsInLineup);
            final List<PlayerModel> playersToRemove = playersOnField
                .where((p) => idsToRemove.contains(p.id))
                .toList();

            if (playersToRemove.isNotEmpty) {
              tacticBoard.removeFieldItems(playersToRemove);
              zlog(
                  data:
                      "Removed ${playersToRemove.length} players from the field.");
            }

            for (final newPlayerState in finalLineup) {
              zlog(data: "Player size getting ${newPlayerState.size}");
              tacticBoard.removeFieldItems([newPlayerState]);
              tacticBoard.addItem(newPlayerState);
            }
            zlog(data: "Applied ${finalLineup.length} players to the field.");
            // --- END: DIRECT-APPLICATION LOGIC ---
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
