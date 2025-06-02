import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    initiatePlayerLocally();

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

  initiatePlayerLocally() {
    zlog(data: "Comming to here to initiate players");
    // Removed WidgetsBinding, setState will trigger build anyway
    players = PlayerUtilsV2.generatePlayerModelList(
      playerType: PlayerType.HOME,
    );

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
    );

    // 2. Apply search filter if active
    final String searchTerm = _searchController.text.toLowerCase();
    if (_isSearching && searchTerm.isNotEmpty) {
      activeToolbarPlayers = activeToolbarPlayers
          .where((p) => p.role.toLowerCase().contains(searchTerm))
          .toList();
    }
    // --- End Filtering Logic ---

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildHeader(
            activeToolbarPlayers.length,
          ), // Pass count to header
        ),
        Expanded(
          // --- 3. Wrap GridView with Scrollbar ---
          child: GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(
              AppSize.s4,
            ), // Add some padding for grid items
            mainAxisSpacing: AppSize.s4, // Spacing between rows
            crossAxisSpacing: AppSize.s4, // Spacing between columns
            children: List.generate(activeToolbarPlayers.length, (index) {
              // Use filtered list
              PlayerModel player = activeToolbarPlayers[index];

              Key? itemKey;

              return PlayerComponentV2(key: itemKey, playerModel: player);
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
  Widget _buildHeader(int currentCount) {
    return SizedBox.shrink();
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
            bool? proceed;
            if (needCleanup) {
              proceed = await showConfirmationDialog(
                context: context,
                title: "Confirm New Lineup Setup",
                content:
                    "This action will remove all home players currently on the field to apply the new lineup. Are you sure you want to proceed?",
              );
            } else {
              proceed = true;
            }

            if (proceed == true) {
              TacticBoard? tacticBoard =
                  (ref.read(boardProvider).tacticBoardGame) as TacticBoard?;

              AnimationItemModel? scene = selectedLineUp?.scene;
              if (scene == null) return;

              List<PlayerModel> playersToAdd =
                  PlayerUtilsV2.generateHomePlayerFromScene(
                scene: scene,
                availablePlayers: players,
              );

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
