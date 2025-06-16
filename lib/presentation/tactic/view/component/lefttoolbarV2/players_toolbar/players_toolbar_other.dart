import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class PlayersToolbarOther extends ConsumerStatefulWidget {
  const PlayersToolbarOther({super.key});

  @override
  ConsumerState<PlayersToolbarOther> createState() =>
      _PlayersToolbarOtherState();
}

class _PlayersToolbarOtherState extends ConsumerState<PlayersToolbarOther> {
  List<PlayerModel> players = [];
  List<PlayerModel> _duplicatePlayers = [];

  // State for managing search bar visibility
  bool _isSearching = false;
  final TextEditingController _searchController =
      TextEditingController(); // Controller for the search field
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initiatePlayerLocally();
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
          playerType: PlayerType.OTHER,
        );
        _duplicatePlayers = players;
      });
    });
  }

  List<PlayerModel> generateActivePlayers({
    required List<PlayerModel> players,
    required List<PlayerModel> fieldPlayers,
  }) {
    List<PlayerModel> duplicatePlayers = List.from(players);
    for (var f in fieldPlayers) {
      if (f.playerType == PlayerType.OTHER) {
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
}
