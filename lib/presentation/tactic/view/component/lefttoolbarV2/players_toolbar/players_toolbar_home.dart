import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/lineup_view_model/lineup_controller.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/lineup_arrangement_dialog.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class PlayersToolbarHome extends ConsumerStatefulWidget {
  const PlayersToolbarHome({super.key, this.showFooter = true});

  final bool showFooter;

  @override
  ConsumerState<PlayersToolbarHome> createState() => _PlayersToolbarHomeState();
}

class _PlayersToolbarHomeState extends ConsumerState<PlayersToolbarHome> {
  List<PlayerModel> players = []; // Holds the full list for filtering base
  // List<PlayerModel> _duplicatePlayers = []; // This seems redundant now, filter in build

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  CategorizedFormationGroup? selectedFormation;
  FormationTemplate? selectedLineUp;
  List<CategorizedFormationGroup> teamFormation = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      initiatePlayerLocally();
    });

    _searchController.addListener(() {
      if (mounted) {
        setState(() {}); // Rebuild to apply filter when text changes
      }
    });
  }

  // --- 2. Dispose Controller ---
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  initiatePlayerLocally() async {
    // zlog(data: "Comming to here to initiate players");
    // // Removed WidgetsBinding, setState will trigger build anyway
    // players = PlayerUtilsV2.generatePlayerModelList(
    //   playerType: PlayerType.HOME,
    // );

    List<PlayerModel> pls = await PlayerUtilsV2.getOrInitializeHomePlayers();

    setState(() {
      players = pls;
    });

    // No need to set _duplicatePlayers here if filtering in build
  }

  initiateTeamFormationLocally({
    required List<CategorizedFormationGroup> lineups,
  }) {
    teamFormation = lineups;
    selectedFormation = teamFormation.firstOrNull;
    selectedLineUp = selectedFormation?.templates.firstOrNull;
  }

  List<PlayerModel> generateActivePlayers({
    required List<PlayerModel> sourcePlayers, // Use the full list
    required List<PlayerModel> fieldPlayers,
  }) {
    // Create a copy from the source players list
    List<PlayerModel> activePlayers = List.from(sourcePlayers);
    Set<String> fieldPlayerIds = fieldPlayers
        .where((f) => f.playerType == PlayerType.HOME)
        .map((f) => f.id)
        .toSet(); // Use Set for faster lookup

    // Remove players that are already on the field
    activePlayers.removeWhere((p) => fieldPlayerIds.contains(p.id));
    return activePlayers;
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    final lineup = ref.watch(lineupProvider);

    if (lineup.categorizedGroups.isNotEmpty && teamFormation.isEmpty) {
      initiateTeamFormationLocally(lineups: lineup.categorizedGroups);
    }

    // --- Filtering Logic inside Build ---
    // 1. Get players not currently on the field
    List<PlayerModel> activeToolbarPlayers = generateActivePlayers(
      sourcePlayers: players, // Always start from the full generated list
      fieldPlayers: bp.players,
    )..sort((a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));

    // 2. Apply search filter if active
    final String searchTerm = _searchController.text.toLowerCase();
    if (_isSearching && searchTerm.isNotEmpty) {
      activeToolbarPlayers = activeToolbarPlayers
          .where((p) => p.role.toLowerCase().contains(searchTerm))
          .toList()
        ..sort((a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));
    }
    // --- End Filtering Logic ---

    return Column(
      children: [
        Expanded(
          // --- 3. Wrap GridView with Scrollbar ---
          child: GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(
              AppSize.s4,
            ), // Add some padding for grid items
            mainAxisSpacing: AppSize.s4, // Spacing between rows
            crossAxisSpacing: AppSize.s4, // Spacing between columns
            children: List.generate(activeToolbarPlayers.length + 1, (index) {
              if (index == activeToolbarPlayers.length) {
                return _buildAddPlayer();
              }

              // Use filtered list
              PlayerModel player = activeToolbarPlayers[index];

              Key? itemKey;

              return GestureDetector(
                  onLongPress: () async {
                    PlayerModel? updatedPlayer =
                        await PlayerUtilsV2.showEditPlayerDialog(
                      context: context,
                      player: player,
                    );

                    if (updatedPlayer != null) {
                      // Player was updated, now you need to save this 'updatedPlayer'
                      // back to your Sembast database and update your UI state.
                      zlog(
                          data:
                              'Player updated: ${updatedPlayer.name}, Image: ${updatedPlayer.imagePath}');

                      int index =
                          players.indexWhere((p) => p.id == updatedPlayer.id);
                      if (index != -1) {
                        setState(() {
                          players[index] = updatedPlayer;
                        });
                      }
                    } else {
                      zlog(data: 'Player edit cancelled.');
                    }
                  },
                  child: PlayerComponentV2(key: itemKey, playerModel: player));
            }),
          ),
          // --- End Scrollbar Wrapper ---
        ),
        SizedBox(height: 10),
        if (widget.showFooter)
          _buildFooter(
            needCleanup: activeToolbarPlayers.length != players.length,
          )
        else
          SizedBox.shrink(),
      ],
    );
  }

  // --- Updated _buildHeader method ---
  // Takes the current count as parameter
  Widget _buildAddPlayer() {
    return GestureDetector(
        onTap: () async {
          PlayerModel? newPlayer = await PlayerUtilsV2.showCreatePlayerDialog(
              context: context, playerType: PlayerType.HOME);
          if (newPlayer != null) {
            setState(() {
              players.add(newPlayer);
            });
          }
        },
        child: Icon(
          FontAwesomeIcons.circlePlus,
          color: ColorManager.white,
        ));
  }

  Widget _buildFooter({required bool needCleanup}) {
    return Column(
      children: [
        DropdownSelector<CategorizedFormationGroup>(
          label: "Players",
          hint: "Players",
          items: teamFormation,
          initialValue: selectedFormation,
          onChanged: (s) {
            setState(() {
              selectedFormation = s;
              selectedLineUp = selectedFormation?.templates.firstOrNull;
            });
          },
          itemAsString: (CategorizedFormationGroup item) {
            return item.category.displayName.toString();
          },
        ),
        SizedBox(height: 10),
        DropdownSelector<FormationTemplate>(
          hint: "Line Up",
          label: "Line Up",
          items: selectedFormation?.templates ?? [],
          initialValue: selectedLineUp,
          onChanged: (s) {
            setState(() {
              selectedLineUp = s;
            });
          },
          itemAsString: (FormationTemplate item) {
            return item.name;
          },
        ),
        SizedBox(height: 10),
        CustomButton(
          borderRadius: 3,
          onTap: () async {
            TacticBoard? tacticBoard =
                (ref.read(boardProvider).tacticBoardGame) as TacticBoard?;
            AnimationItemModel? scene = selectedLineUp?.scene;

            if (scene == null || tacticBoard == null) {
              BotToast.showText(text: "Please select a lineup first.");
              return;
            }

            // --- Home Team Logic Start ---

            // 1. For the home team, the template players directly represent the target positions.
            final List<PlayerModel> targetPositions =
                scene.components.whereType<PlayerModel>().toList();
            final List<PlayerModel> homeRoster =
                players; // The current state's home players

            // 2. Pre-assign players based on matching ID.
            final Map<String, PlayerModel> rosterMap = {
              for (var p in homeRoster) p.id: p
            };
            Map<String, PlayerModel?> initialAssignments = {};
            for (final targetPos in targetPositions) {
              // If a player on the roster has the same ID as the target position, assign them.
              if (rosterMap.containsKey(targetPos.id)) {
                initialAssignments[targetPos.id] = rosterMap[targetPos.id];
              } else {
                // Otherwise, the spot is unassigned (legacy/missing player).
                initialAssignments[targetPos.id] = null;
              }
            }

            // --- Home Team Logic End ---

            // 3. Launch the dialog with the processed data.
            final List<PlayerModel>? finalPlayersToAdd =
                await showDialog<List<PlayerModel>>(
              context: context,
              barrierDismissible: false,
              builder: (_) => LineupArrangementDialog(
                // The template itself defines the target positions.
                targetPositions: targetPositions,
                // Pass the full home roster for the user to pick from.
                coachsRoster: homeRoster,
                // Pass the initial assignments we just figured out.
                initialAssignments: initialAssignments,
              ),
            );

            if (finalPlayersToAdd == null) return; // User cancelled

            // 4. Apply the final, user-confirmed lineup to the board.
            bool proceed = false;
            final bool playersOnField = ref
                .read(boardProvider)
                .players
                .any((p) => p.playerType == PlayerType.HOME);

            if (playersOnField) {
              proceed = await showConfirmationDialog(
                    context: context,
                    title: "Apply New Lineup",
                    content:
                        "This action will remove all home players currently on the field. Are you sure you want to proceed?",
                  ) ??
                  false;
            } else {
              proceed = true;
            }

            if (proceed) {
              tacticBoard.removeFieldItems(homeRoster);
              for (final player in finalPlayersToAdd) {
                tacticBoard.addItem(player);
              }
            }
          },
          fillColor: ColorManager.blue,
          child: Text(
            "ADD",
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }

  // Helper Methods for Toggling Search State
  void _openSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _closeSearch() {
    // Already cleared controller text in IconButton onPressed
    setState(() {
      _isSearching = false;
      // Force rebuild to ensure list updates without search term
    });
  }
}
