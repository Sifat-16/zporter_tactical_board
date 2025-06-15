// import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
// import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/app/manager/values_manager.dart';
// import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
// import 'package:zporter_tactical_board/presentation/admin/view_model/lineup_view_model/lineup_controller.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/lineup_arrangement_dialog.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
//
// class PlayersToolbarHome extends ConsumerStatefulWidget {
//   const PlayersToolbarHome({super.key, this.showFooter = true});
//
//   final bool showFooter;
//
//   @override
//   ConsumerState<PlayersToolbarHome> createState() => _PlayersToolbarHomeState();
// }
//
// class _PlayersToolbarHomeState extends ConsumerState<PlayersToolbarHome> {
//   List<PlayerModel> players = [];
//
//   bool _isSearching = false;
//   final TextEditingController _searchController = TextEditingController();
//   CategorizedFormationGroup? selectedFormation;
//   FormationTemplate? selectedLineUp;
//   List<CategorizedFormationGroup> teamFormation = [];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((t) {
//       initiatePlayerLocally();
//     });
//
//     _searchController.addListener(() {
//       if (mounted) {
//         setState(() {});
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   initiatePlayerLocally() async {
//     List<PlayerModel> pls = await PlayerUtilsV2.getOrInitializeHomePlayers();
//     if (mounted) {
//       setState(() {
//         players = pls;
//       });
//     }
//   }
//
//   initiateTeamFormationLocally({
//     required List<CategorizedFormationGroup> lineups,
//   }) {
//     teamFormation = lineups;
//     selectedFormation = teamFormation.firstOrNull;
//     selectedLineUp = selectedFormation?.templates.firstOrNull;
//   }
//
//   List<PlayerModel> generateActivePlayers({
//     required List<PlayerModel> sourcePlayers,
//     required List<PlayerModel> fieldPlayers,
//   }) {
//     List<PlayerModel> activePlayers = List.from(sourcePlayers);
//     Set<String> fieldPlayerIds = fieldPlayers
//         .where((f) => f.playerType == PlayerType.HOME)
//         .map((f) => f.id)
//         .toSet();
//
//     activePlayers.removeWhere((p) => fieldPlayerIds.contains(p.id));
//     return activePlayers;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bp = ref.watch(boardProvider);
//     final lineup = ref.watch(lineupProvider);
//
//     if (lineup.categorizedGroups.isNotEmpty && teamFormation.isEmpty) {
//       initiateTeamFormationLocally(lineups: lineup.categorizedGroups);
//     }
//
//     // This list now correctly represents the "bench" or "roster"
//     List<PlayerModel> activeToolbarPlayers = generateActivePlayers(
//       sourcePlayers: players,
//       fieldPlayers: bp.players,
//     )..sort((a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));
//
//     final String searchTerm = _searchController.text.toLowerCase();
//     if (_isSearching && searchTerm.isNotEmpty) {
//       activeToolbarPlayers = activeToolbarPlayers
//           .where((p) =>
//               (p.name?.toLowerCase().contains(searchTerm) ?? false) ||
//               p.role.toLowerCase().contains(searchTerm))
//           .toList();
//     }
//
//     return Column(
//       children: [
//         Expanded(
//           child: GridView.count(
//             crossAxisCount: 3,
//             padding: const EdgeInsets.all(AppSize.s4),
//             mainAxisSpacing: AppSize.s4,
//             crossAxisSpacing: AppSize.s4,
//             children: List.generate(activeToolbarPlayers.length + 1, (index) {
//               if (index == activeToolbarPlayers.length) {
//                 return _buildAddPlayer();
//               }
//
//               PlayerModel player = activeToolbarPlayers[index];
//
//               return GestureDetector(
//                   onLongPress: () async {
//                     PlayerModel? updatedPlayer =
//                         await PlayerUtilsV2.showEditPlayerDialog(
//                       context: context,
//                       player: player,
//                     );
//
//                     if (updatedPlayer != null) {
//                       int index =
//                           players.indexWhere((p) => p.id == updatedPlayer.id);
//                       if (index != -1) {
//                         setState(() {
//                           players[index] = updatedPlayer;
//                         });
//                       }
//                     }
//                   },
//                   child: PlayerComponentV2(playerModel: player));
//             }),
//           ),
//         ),
//         SizedBox(height: 10),
//         if (widget.showFooter)
//           _buildFooter(
//             benchPlayers: activeToolbarPlayers, // Pass bench players to footer
//           )
//         else
//           SizedBox.shrink(),
//       ],
//     );
//   }
//
//   Widget _buildAddPlayer() {
//     return GestureDetector(
//         onTap: () async {
//           PlayerModel? newPlayer = await PlayerUtilsV2.showCreatePlayerDialog(
//               context: context, playerType: PlayerType.HOME);
//           if (newPlayer != null) {
//             setState(() {
//               players.add(newPlayer);
//             });
//           }
//         },
//         child: Icon(
//           FontAwesomeIcons.circlePlus,
//           color: ColorManager.white,
//         ));
//   }
//
//   // MODIFIED: _buildFooter to handle new logic
//   Widget _buildFooter({required List<PlayerModel> benchPlayers}) {
//     final boardState = ref.read(boardProvider);
//     final playersOnField = boardState.players
//         .where((p) => p.playerType == PlayerType.HOME)
//         .toList();
//     final bool isRearranging = playersOnField.isNotEmpty;
//
//     return Column(
//       children: [
//         DropdownSelector<CategorizedFormationGroup>(
//           label: "Formation Category",
//           hint: "Select Category",
//           items: teamFormation,
//           initialValue: selectedFormation,
//           onChanged: (s) {
//             setState(() {
//               selectedFormation = s;
//               selectedLineUp = selectedFormation?.templates.firstOrNull;
//             });
//           },
//           itemAsString: (item) => item.category.displayName,
//         ),
//         SizedBox(height: 10),
//         DropdownSelector<FormationTemplate>(
//           hint: "Select Lineup",
//           label: "Line Up",
//           items: selectedFormation?.templates ?? [],
//           initialValue: selectedLineUp,
//           onChanged: (s) {
//             setState(() {
//               selectedLineUp = s;
//             });
//           },
//           itemAsString: (item) => item.name,
//         ),
//         SizedBox(height: 10),
//         CustomButton(
//           borderRadius: 3,
//           onTap: () async {
//             TacticBoard? tacticBoard =
//                 boardState.tacticBoardGame as TacticBoard?;
//             AnimationItemModel? scene = selectedLineUp?.scene;
//
//             if (scene == null || tacticBoard == null) {
//               BotToast.showText(text: "Please select a lineup first.");
//               return;
//             }
//
//             // The target positions defined by the new formation template.
//             final List<PlayerModel> targetPositions =
//                 scene.components.whereType<PlayerModel>().toList();
//
//             // --- NEW LOGIC: DISTINGUISH BETWEEN SETUP AND RE-ARRANGE ---
//
//             Map<String, PlayerModel?> initialAssignments;
//             List<PlayerModel> playersToArrange;
//
//             if (!isRearranging) {
//               // --- 1. INITIAL SETUP LOGIC (Your existing logic) ---
//               zlog(data: "Performing initial lineup setup.");
//               playersToArrange = players; // Full roster
//               initialAssignments = {}; // No one is assigned yet.
//             } else {
//               // --- 2. RE-ARRANGEMENT LOGIC ---
//               zlog(data: "Performing lineup re-arrangement.");
//               playersToArrange =
//                   playersOnField; // Key change: Use players on field!
//
//               // Smart pre-assignment: Try to match current players to new roles
//               initialAssignments = {};
//               List<PlayerModel> availableOnField = List.from(playersOnField);
//
//               for (final targetPos in targetPositions) {
//                 int matchIndex = availableOnField
//                     .indexWhere((p) => p.role == targetPos.role);
//
//                 if (matchIndex != -1) {
//                   initialAssignments[targetPos.id] =
//                       availableOnField.removeAt(matchIndex);
//                 } else {
//                   initialAssignments[targetPos.id] = null;
//                 }
//               }
//               // Assign any remaining players to remaining slots
//               for (final targetPos in targetPositions) {
//                 if (initialAssignments[targetPos.id] == null &&
//                     availableOnField.isNotEmpty) {
//                   initialAssignments[targetPos.id] =
//                       availableOnField.removeAt(0);
//                 }
//               }
//             }
//
//             // --- LAUNCH DIALOG WITH CORRECT CONTEXT ---
//             final List<PlayerModel>? finalLineup =
//                 await showDialog<List<PlayerModel>>(
//               context: context,
//               barrierDismissible: false,
//               builder: (_) => LineupArrangementDialog(
//                 targetPositions: targetPositions,
//                 playersToArrange: playersToArrange, // Pass the correct list
//                 benchPlayers: benchPlayers, // Players not on the field
//                 initialAssignments: initialAssignments,
//               ),
//             );
//
//             if (finalLineup == null) return; // User cancelled
//
//             // --- 4. SURGICAL APPLY LOGIC ---
//             zlog(data: "Applying new lineup...");
//
//             final Set<String> originalPlayerIds =
//                 playersOnField.map((p) => p.id).toSet();
//             final Set<String> finalPlayerIds =
//                 finalLineup.map((p) => p.id).toSet();
//
//             // Find players to remove (substituted out)
//             final Set<String> idsToRemove =
//                 originalPlayerIds.difference(finalPlayerIds);
//             final List<PlayerModel> playersToRemove = playersOnField
//                 .where((p) => idsToRemove.contains(p.id))
//                 .toList();
//             if (playersToRemove.isNotEmpty) {
//               tacticBoard.removeFieldItems(playersToRemove);
//               zlog(
//                   data:
//                       "Removed ${playersToRemove.length} substituted players.");
//             }
//
//             // Update positions for existing players and add new ones
//             for (final newPlayerState in finalLineup) {
//               if (originalPlayerIds.contains(newPlayerState.id)) {
//                 // This player was already on the field, just update them.
//                 // A simple way is to remove the old and add the new state.
//                 tacticBoard
//                     .removeFieldItems([newPlayerState]); // Remove by ID match
//                 tacticBoard.addItem(newPlayerState);
//               } else {
//                 // This is a new player (substituted in)
//                 tacticBoard.addItem(newPlayerState);
//                 zlog(data: "Added substituted player: ${newPlayerState.name}");
//               }
//             }
//           },
//           fillColor: ColorManager.blue,
//           child: Text(
//             isRearranging ? "RE-ARRANGE" : "ADD", // Dynamic button text
//             style: Theme.of(context).textTheme.labelLarge!.copyWith(
//                   color: ColorManager.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:bot_toast/bot_toast.dart';
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
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/lineup_arrangement_dialog.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

// CHANGED: Create the StreamProvider here or in a separate file.
final homePlayersStreamProvider = StreamProvider<List<PlayerModel>>((ref) {
  PlayerUtilsV2.getOrInitializeHomePlayers();
  return PlayerUtilsV2.watchHomePlayers();
});

// CHANGED: Converted to ConsumerStatefulWidget to handle local state for search/formation
class PlayersToolbarHome extends ConsumerStatefulWidget {
  const PlayersToolbarHome({super.key, this.showFooter = true});

  final bool showFooter;

  @override
  ConsumerState<PlayersToolbarHome> createState() => _PlayersToolbarHomeState();
}

class _PlayersToolbarHomeState extends ConsumerState<PlayersToolbarHome> {
  // REMOVED: The local `players` list is no longer needed.
  // List<PlayerModel> players = [];

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  CategorizedFormationGroup? selectedFormation;
  FormationTemplate? selectedLineUp;
  List<CategorizedFormationGroup> teamFormation = [];

  @override
  void initState() {
    super.initState();
    // REMOVED: No need to manually initiate players.
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

  // This logic is now only for formations, which is fine.
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

    // CHANGED: Watch the new stream provider.
    final homePlayersAsync = ref.watch(homePlayersStreamProvider);

    if (lineup.categorizedGroups.isNotEmpty && teamFormation.isEmpty) {
      initiateTeamFormationLocally(lineups: lineup.categorizedGroups);
    }

    return homePlayersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (players) {
        // `players` now comes directly from the stream
        // This list now correctly represents the "bench" or "roster"
        List<PlayerModel> activeToolbarPlayers = generateActivePlayers(
          sourcePlayers: players, // Use the data from the stream
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
                      onLongPress: () async {
                        // Logic is the same, but we no longer need setState.
                        // The change will be saved to the DB and the stream will update the UI.
                        await PlayerUtilsV2.showEditPlayerDialog(
                          context: context,
                          player: player,
                        );
                      },
                      child: PlayerComponentV2(playerModel: player));
                }),
              ),
            ),
            SizedBox(height: 10),
            if (widget.showFooter)
              _buildFooter(
                benchPlayers: activeToolbarPlayers,
              )
            else
              SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _buildAddPlayer() {
    return GestureDetector(
        onTap: () async {
          // Logic is the same, but we no longer need setState.
          // The new player will be saved to the DB and the stream will update the UI.
          await PlayerUtilsV2.showCreatePlayerDialog(
              context: context, playerType: PlayerType.HOME);
        },
        child: Icon(
          FontAwesomeIcons.circlePlus,
          color: ColorManager.white,
        ));
  }

  // The footer logic remains completely unchanged as it depends on local state
  // and data passed into it, which is correct.
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
        SizedBox(height: 10),
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
        SizedBox(height: 10),
        CustomButton(
          borderRadius: 3,
          onTap: () async {
            TacticBoard? tacticBoard =
                boardState.tacticBoardGame as TacticBoard?;
            AnimationItemModel? scene = selectedLineUp?.scene;

            if (scene == null || tacticBoard == null) {
              BotToast.showText(text: "Please select a lineup first.");
              return;
            }

            final List<PlayerModel> targetPositions =
                scene.components.whereType<PlayerModel>().toList();

            Map<String, PlayerModel?> initialAssignments;
            List<PlayerModel> playersToArrange;

            if (!isRearranging) {
              zlog(data: "Performing initial lineup setup.");
              // We need all players from the stream here, which we can get by re-reading the provider's state.
              final allPlayers =
                  ref.read(homePlayersStreamProvider).value ?? [];
              playersToArrange = allPlayers;
              initialAssignments = {};
            } else {
              zlog(data: "Performing lineup re-arrangement.");
              playersToArrange = playersOnField;

              initialAssignments = {};
              List<PlayerModel> availableOnField = List.from(playersOnField);

              for (final targetPos in targetPositions) {
                int matchIndex = availableOnField
                    .indexWhere((p) => p.role == targetPos.role);

                if (matchIndex != -1) {
                  initialAssignments[targetPos.id] =
                      availableOnField.removeAt(matchIndex);
                } else {
                  initialAssignments[targetPos.id] = null;
                }
              }
              for (final targetPos in targetPositions) {
                if (initialAssignments[targetPos.id] == null &&
                    availableOnField.isNotEmpty) {
                  initialAssignments[targetPos.id] =
                      availableOnField.removeAt(0);
                }
              }
            }

            final List<PlayerModel>? finalLineup =
                await showDialog<List<PlayerModel>>(
              context: context,
              barrierDismissible: false,
              builder: (_) => LineupArrangementDialog(
                targetPositions: targetPositions,
                playersToArrange: playersToArrange,
                benchPlayers: benchPlayers,
                initialAssignments: initialAssignments,
              ),
            );

            if (finalLineup == null) return;

            zlog(data: "Applying new lineup...");

            final Set<String> originalPlayerIds =
                playersOnField.map((p) => p.id).toSet();
            final Set<String> finalPlayerIds =
                finalLineup.map((p) => p.id).toSet();

            final Set<String> idsToRemove =
                originalPlayerIds.difference(finalPlayerIds);
            final List<PlayerModel> playersToRemove = playersOnField
                .where((p) => idsToRemove.contains(p.id))
                .toList();
            if (playersToRemove.isNotEmpty) {
              tacticBoard.removeFieldItems(playersToRemove);
              zlog(
                  data:
                      "Removed ${playersToRemove.length} substituted players.");
            }

            for (final newPlayerState in finalLineup) {
              if (originalPlayerIds.contains(newPlayerState.id)) {
                tacticBoard.removeFieldItems([newPlayerState]);
                tacticBoard.addItem(newPlayerState);
              } else {
                tacticBoard.addItem(newPlayerState);
                zlog(data: "Added substituted player: ${newPlayerState.name}");
              }
            }
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
