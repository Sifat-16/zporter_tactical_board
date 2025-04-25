import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class PlayersToolbarHome extends ConsumerStatefulWidget {
  const PlayersToolbarHome({super.key});

  @override
  ConsumerState<PlayersToolbarHome> createState() => _PlayersToolbarHomeState();
}

class _PlayersToolbarHomeState extends ConsumerState<PlayersToolbarHome> {
  List<PlayerModel> players = []; // Holds the full list for filtering base
  // List<PlayerModel> _duplicatePlayers = []; // This seems redundant now, filter in build

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initiatePlayerLocally();
    // Add listener to rebuild on search text changes if filtering in build
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
    // Removed WidgetsBinding, setState will trigger build anyway
    players = PlayerUtilsV2.generatePlayerModelList(
      playerType: PlayerType.HOME,
    );
    // No need to set _duplicatePlayers here if filtering in build
  }

  List<PlayerModel> generateActivePlayers({
    required List<PlayerModel> sourcePlayers, // Use the full list
    required List<PlayerModel> fieldPlayers,
  }) {
    // Create a copy from the source players list
    List<PlayerModel> activePlayers = List.from(sourcePlayers);
    Set<String> fieldPlayerIds =
        fieldPlayers
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

    // --- Filtering Logic inside Build ---
    // 1. Get players not currently on the field
    List<PlayerModel> activeToolbarPlayers = generateActivePlayers(
      sourcePlayers: players, // Always start from the full generated list
      fieldPlayers: bp.players,
    );

    // 2. Apply search filter if active
    final String searchTerm = _searchController.text.toLowerCase();
    if (_isSearching && searchTerm.isNotEmpty) {
      activeToolbarPlayers =
          activeToolbarPlayers
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
              return PlayerComponentV2(playerModel: player);
            }),
          ),
          // --- End Scrollbar Wrapper ---
        ),
      ],
    );
  }

  // --- Updated _buildHeader method ---
  // Takes the current count as parameter
  Widget _buildHeader(int currentCount) {
    return SizedBox.shrink();
    // if (_isSearching) {
    //   return Padding(
    //     key: const ValueKey('searchHeader'),
    //     padding: EdgeInsets.symmetric(vertical: AppSize.s4, horizontal: 2),
    //     child: Row(
    //       children: [
    //         Expanded(
    //           child: SizedBox(
    //             height: AppSize.s32,
    //             child: TextField(
    //               controller: _searchController,
    //               autofocus: true,
    //               style: TextStyle(
    //                 color: ColorManager.white,
    //                 fontSize: AppSize.s14,
    //               ),
    //               cursorColor: ColorManager.yellow,
    //               decoration: InputDecoration(
    //                 hintText: "Search players...",
    //                 hintStyle: TextStyle(
    //                   color: ColorManager.grey,
    //                   fontSize: AppSize.s14,
    //                 ),
    //                 filled: true,
    //                 fillColor: ColorManager.black.withOpacity(0.3),
    //                 contentPadding: EdgeInsets.symmetric(
    //                   horizontal: AppSize.s8,
    //                   vertical: AppSize.s4,
    //                 ),
    //                 border: OutlineInputBorder(
    //                   borderRadius: BorderRadius.circular(AppSize.s4),
    //                   borderSide: BorderSide.none,
    //                 ),
    //                 focusedBorder: OutlineInputBorder(
    //                   borderRadius: BorderRadius.circular(AppSize.s4),
    //                   borderSide: BorderSide(
    //                     color: ColorManager.yellow,
    //                     width: 1,
    //                   ),
    //                 ),
    //                 isDense: true,
    //               ),
    //               // onChanged handled by listener added in initState now
    //               // onChanged: (value) {
    //               //   // Trigger rebuild via listener now
    //               //   // setState(() {});
    //               // },
    //             ),
    //           ),
    //         ),
    //         IconButton(
    //           icon: Icon(Icons.close, color: ColorManager.grey),
    //           tooltip: 'Close Search',
    //           onPressed: () {
    //             _searchController.clear(); // Clear text on close
    //             _closeSearch(); // Updates _isSearching and triggers rebuild
    //           },
    //         ),
    //       ],
    //     ),
    //   );
    // } else {
    //   // Original Header
    //   return Padding(
    //     key: const ValueKey('defaultHeader'),
    //     padding: EdgeInsets.symmetric(vertical: AppSize.s4),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Padding(
    //           // Add padding to player count text
    //           padding: const EdgeInsets.only(left: AppSize.s8),
    //           child: Text(
    //             "$currentCount Players", // Show current filtered/active count
    //             style: Theme.of(
    //               context,
    //             ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
    //           ),
    //         ),
    //         Row(
    //           children: [
    //             IconButton(
    //               icon: Icon(Icons.search, color: ColorManager.grey),
    //               tooltip: 'Search Players',
    //               onPressed: _openSearch,
    //             ),
    //             IconButton(
    //               icon: Icon(
    //                 Icons.arrow_drop_down_outlined,
    //                 color: ColorManager.grey,
    //               ),
    //               tooltip: 'Sort Options',
    //               onPressed: () {
    //                 /* TODO: Implement sort */
    //               },
    //             ),
    //             // IconButton(
    //             //   icon: Icon(Icons.filter_list_outlined, color: ColorManager.grey),
    //             //   tooltip: 'Filter Options',
    //             //   onPressed: () { /* TODO: Implement filter */ },
    //             // ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   );
    // }
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
