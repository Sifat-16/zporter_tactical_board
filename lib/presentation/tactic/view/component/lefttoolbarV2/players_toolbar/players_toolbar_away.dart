import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/team_formation_config_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class PlayersToolbarAway extends ConsumerStatefulWidget {
  const PlayersToolbarAway({super.key});

  @override
  ConsumerState<PlayersToolbarAway> createState() => _PlayersToolbarAwayState();
}

class _PlayersToolbarAwayState extends ConsumerState<PlayersToolbarAway> {
  List<PlayerModel> players = [];
  List<PlayerModel> _duplicatePlayers = [];

  List<TeamFormationConfig> teamFormation = [];
  TeamFormationConfig? selectedFormation;
  LineupDetails? selectedLineUp;

  // State for managing search bar visibility
  bool _isSearching = false;
  final TextEditingController _searchController =
      TextEditingController(); // Controller for the search field
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initiatePlayerLocally();
    initiateTeamFormationLocally();
    // context.read<PlayerBloc>().add(PlayerTypeLoadEvent(playerType: PlayerType.HOME));
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
    WidgetsBinding.instance.addPostFrameCallback((t) {
      setState(() {
        players = PlayerUtilsV2.generatePlayerModelList(
          playerType: PlayerType.AWAY,
        );
        _duplicatePlayers = players;
      });
    });
  }

  initiateTeamFormationLocally() {
    teamFormation = PlayerUtilsV2.getAllConfigurations(
      playerType: PlayerType.AWAY,
    );

    selectedFormation = teamFormation.firstOrNull;
    selectedLineUp = selectedFormation?.availableLineups.firstOrNull;
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

    _duplicatePlayers = generateActivePlayers(
      players: _duplicatePlayers,
      fieldPlayers: bp.players,
    );

    return Column(
      children: [
        // Use AnimatedSwitcher for a smooth transition (optional but nice)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildHeader(), // Build header dynamically
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            children: [
              ...List.generate(_duplicatePlayers.length, (index) {
                PlayerModel player = _duplicatePlayers[index];
                return PlayerComponentV2(playerModel: player);
              }),
            ],
          ),
        ),

        SizedBox(height: 10),

        _buildFooter(),
      ],
    );
  }

  // --- Updated _buildHeader method ---
  Widget _buildHeader() {
    return SizedBox.shrink();
    // Key is important for AnimatedSwitcher to differentiate widgets
    if (_isSearching) {
      return Padding(
        // Add padding if needed
        key: const ValueKey('searchHeader'), // Key for AnimatedSwitcher
        padding: EdgeInsets.symmetric(
          vertical: AppSize.s4,
          horizontal: 2,
        ), // Adjust padding as needed
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                // Constrain height if necessary
                height: AppSize.s32, // Example height, adjust as needed
                child: TextField(
                  controller: _searchController,
                  autofocus: true, // Automatically focus the search field
                  style: TextStyle(
                    color: ColorManager.white,
                    fontSize: AppSize.s14,
                  ),
                  cursorColor: ColorManager.yellow,
                  decoration: InputDecoration(
                    hintText: "Search players...",
                    hintStyle: TextStyle(
                      color: ColorManager.grey,
                      fontSize: AppSize.s14,
                    ),
                    filled: true,
                    fillColor: ColorManager.black.withOpacity(
                      0.3,
                    ), // Example background
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSize.s8,
                      vertical: AppSize.s4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.s4),
                      borderSide: BorderSide.none, // No border outline
                    ),
                    focusedBorder: OutlineInputBorder(
                      // Optional: Style when focused
                      borderRadius: BorderRadius.circular(AppSize.s4),
                      borderSide: BorderSide(
                        color: ColorManager.yellow,
                        width: 1,
                      ),
                    ),
                    isDense: true, // Reduces intrinsic height
                  ),
                  onChanged: (value) {
                    setState(() {
                      _duplicatePlayers =
                          players
                              .where(
                                (p) => p.role.toLowerCase().contains(
                                  value.toLowerCase(),
                                ),
                              )
                              .toList();
                    });
                  },
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: ColorManager.grey),
              tooltip: 'Close Search',
              onPressed: _closeSearch, // Call close search method
            ),
          ],
        ),
      );
    } else {
      // Original Header
      return Padding(
        // Add padding if needed
        key: const ValueKey('defaultHeader'), // Key for AnimatedSwitcher
        padding: EdgeInsets.symmetric(
          vertical: AppSize.s4,
        ), // Adjust padding as needed
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_duplicatePlayers.length} Players", // TODO: Update this dynamically if needed
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
            ),
            Row(
              children: [
                IconButton(
                  // Use IconButton for better semantics and splash effect
                  icon: Icon(Icons.search, color: ColorManager.grey),
                  tooltip: 'Search Players',
                  onPressed: _openSearch, // Call open search method
                ),
                // Keep other icons, wrap them in IconButton if they need actions
                IconButton(
                  icon: Icon(
                    Icons.arrow_drop_down_outlined,
                    color: ColorManager.grey,
                  ),
                  tooltip: 'Sort Options', // Example tooltip
                  onPressed: () {
                    // TODO: Implement sort action
                  },
                ),
                // IconButton(
                //   icon: Icon(
                //     Icons.filter_list_outlined,
                //     color: ColorManager.grey,
                //   ),
                //   tooltip: 'Filter Options', // Example tooltip
                //   onPressed: () {
                //     // TODO: Implement filter action
                //   },
                // ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFooter() {
    return Column(
      children: [
        DropdownSelector<TeamFormationConfig>(
          label: "Players",
          items: teamFormation,
          initialValue: selectedFormation,
          onChanged: (s) {
            setState(() {
              selectedFormation = s;
              selectedLineUp = selectedFormation?.availableLineups.firstOrNull;
            });
          },
          itemAsString: (TeamFormationConfig item) {
            return item.numberOfPlayers.toString();
          },
        ),

        SizedBox(height: 10),

        DropdownSelector<LineupDetails>(
          label: "Line Up",
          items: selectedFormation?.availableLineups ?? [],
          initialValue: selectedLineUp,
          onChanged: (s) {
            setState(() {
              selectedLineUp = s;
            });
          },
          itemAsString: (LineupDetails item) {
            return item.name;
          },
        ),
        SizedBox(height: 10),
        CustomButton(
          onTap: () async {
            bool? proceed = await showConfirmationDialog(
              context: context,
              title: "Confirm New Lineup Setup",
              content:
                  "This action will remove all away players currently on the field to apply the new lineup. Are you sure you want to proceed?",
            );
            if (proceed == true) {
              TacticBoard? tacticBoard =
                  (ref.read(boardProvider).tacticBoardGame) as TacticBoard?;

              List<PlayerFormationSlot> slots =
                  selectedLineUp?.playerSlots ?? [];
              List<PlayerModel> playersToAdd =
                  slots.map((p) {
                    return players
                        .firstWhere(
                          (player) => player.id == p.designatedPlayerId,
                        )
                        .copyWith(offset: p.relativePosition);
                  }).toList();

              tacticBoard?.removeFieldItems(players);

              if (tacticBoard != null) {
                for (var pd in playersToAdd) {
                  tacticBoard.addItem(pd);
                }
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
