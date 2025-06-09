import 'package:bot_toast/bot_toast.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/lineup_view_model/lineup_controller.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/lineup_arrangement_dialog.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class PlayersToolbarAway extends ConsumerStatefulWidget {
  const PlayersToolbarAway({super.key, this.showFooter = true});
  final bool showFooter;

  @override
  ConsumerState<PlayersToolbarAway> createState() => _PlayersToolbarAwayState();
}

class _PlayersToolbarAwayState extends ConsumerState<PlayersToolbarAway> {
  List<PlayerModel> players = [];
  List<PlayerModel> _duplicatePlayers = [];

  // State for managing search bar visibility
  bool _isSearching = false;
  final TextEditingController _searchController =
      TextEditingController(); // Controller for the search field

  CategorizedFormationGroup? selectedFormation;
  FormationTemplate? selectedLineUp;
  List<CategorizedFormationGroup> teamFormation = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initiatePlayerLocally();
  }

  // --- Helper Methods for Toggling Search ---
  void _openSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
    });
  }
  // --- End Helper Methods ---

  initiatePlayerLocally() {
    WidgetsBinding.instance.addPostFrameCallback((t) async {
      List<PlayerModel> pls = await PlayerUtilsV2.getOrInitializeAwayPlayers();
      setState(() {
        players = pls;
        _duplicatePlayers = players;
      });
    });
  }

  initiateTeamFormationLocally({
    required List<CategorizedFormationGroup> lineups,
  }) {
    teamFormation = lineups;
    selectedFormation = teamFormation.firstOrNull;
    selectedLineUp = selectedFormation?.templates.firstOrNull;
  }

  List<PlayerModel> generateActivePlayers({
    required List<PlayerModel> players,
    required List<PlayerModel> fieldPlayers,
  }) {
    List<PlayerModel> duplicatePlayers = List.from(players);
    for (var f in fieldPlayers) {
      if (f.playerType == PlayerType.AWAY) {
        duplicatePlayers.removeWhere((p) => p.id == f.id);
      }
    }
    return duplicatePlayers;
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    final lineup = ref.watch(lineupProvider);

    if (lineup.categorizedGroups.isNotEmpty && teamFormation.isEmpty) {
      initiateTeamFormationLocally(lineups: lineup.categorizedGroups);
    }

    _duplicatePlayers = generateActivePlayers(
      players: _duplicatePlayers,
      fieldPlayers: bp.players,
    )..sort((a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));

    return Column(
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            children: [
              ...List.generate(_duplicatePlayers.length + 1, (index) {
                if (index == _duplicatePlayers.length) {
                  return _buildAddPlayer();
                }
                PlayerModel player = _duplicatePlayers[index];
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
                            _duplicatePlayers = players;
                          });
                        }
                      } else {
                        zlog(data: 'Player edit cancelled.');
                      }
                    },
                    child: PlayerComponentV2(playerModel: player));
              }),
            ],
          ),
        ),
        SizedBox(height: 10),
        if (widget.showFooter)
          _buildFooter(needCleanup: _duplicatePlayers.length != players.length)
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
              context: context, playerType: PlayerType.AWAY);
          if (newPlayer != null) {
            setState(() {
              players.add(newPlayer);
              _duplicatePlayers = players;
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

            // --- Away Team Logic Start ---

            // 1. Get the base template (which uses HOME players) and the available AWAY roster.
            final List<PlayerModel> homeTemplatePlayers =
                scene.components.whereType<PlayerModel>().toList();
            final List<PlayerModel> awayRoster =
                players; // The current state's away players

            // 2. Create the mirrored "target" positions for the away team.
            // This replicates the positioning logic from `generateAwayPlayerFromScene`.
            List<PlayerModel> targetAwayPositions = [];
            for (final homePlayer in homeTemplatePlayers) {
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

              // Create a "target" player model that has the mirrored position and the target role/number.
              // We use the home player's ID as a unique key for the position itself.
              targetAwayPositions.add(
                homePlayer.copyWith(
                  offset: mirroredOffset,
                  playerType: PlayerType.AWAY,
                ),
              );
            }

            // 3. Pre-assign away players based on role and jersey number.
            Map<String, PlayerModel?> initialAssignments = {};
            List<PlayerModel> unassignedRosterPlayers = List.from(awayRoster);

            for (final targetPos in targetAwayPositions) {
              PlayerModel? match;
              // Find a player in the available roster that matches the target role and number.
              int matchIndex = unassignedRosterPlayers.indexWhere(
                  (awayPlayer) =>
                      (awayPlayer.role == targetPos.role) &&
                      (awayPlayer.jerseyNumber == targetPos.jerseyNumber));

              if (matchIndex != -1) {
                // If a match is found, assign them and remove them from the pool of available players.
                match = unassignedRosterPlayers.removeAt(matchIndex);
              }
              // Use the target position's unique ID as the key for the assignment map.
              initialAssignments[targetPos.id] = match;
            }

            // --- Away Team Logic End ---

            // 4. Launch the dialog with the pre-processed data.
            final List<PlayerModel>? finalPlayersToAdd =
                await showDialog<List<PlayerModel>>(
              context: context,
              barrierDismissible: false,
              builder: (_) => LineupArrangementDialog(
                // Pass the generated target positions.
                targetPositions: targetAwayPositions,
                // Pass the full away roster for the user to pick from.
                coachsRoster: awayRoster,
                // Pass the initial assignments we just figured out.
                initialAssignments: initialAssignments,
              ),
            );

            if (finalPlayersToAdd == null) return; // User cancelled

            // 5. Apply the final, user-confirmed lineup to the board.
            bool proceed = false;
            final bool playersOnField = ref
                .read(boardProvider)
                .players
                .any((p) => p.playerType == PlayerType.AWAY);

            if (playersOnField) {
              proceed = await showConfirmationDialog(
                    context: context,
                    title: "Apply New Lineup",
                    content:
                        "This action will remove all away players currently on the field. Are you sure you want to proceed?",
                  ) ??
                  false;
            } else {
              proceed = true;
            }

            if (proceed) {
              tacticBoard.removeFieldItems(awayRoster);
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
}
