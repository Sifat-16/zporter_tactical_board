// import 'package:bot_toast/bot_toast.dart';
// import 'package:flame/components.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
// import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/helper/size_helper.dart';
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
// class PlayersToolbarAway extends ConsumerStatefulWidget {
//   const PlayersToolbarAway({super.key, this.showFooter = true});
//   final bool showFooter;
//
//   @override
//   ConsumerState<PlayersToolbarAway> createState() => _PlayersToolbarAwayState();
// }
//
// class _PlayersToolbarAwayState extends ConsumerState<PlayersToolbarAway> {
//   List<PlayerModel> players = []; // Holds the full list for the away team
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
//     WidgetsBinding.instance.addPostFrameCallback((_) {
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
//     List<PlayerModel> pls = await PlayerUtilsV2.getOrInitializeAwayPlayers();
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
//         .where((f) => f.playerType == PlayerType.AWAY) // Logic for AWAY team
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
//     // This list correctly represents the "bench" or "roster" for the away team
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
//               PlayerModel player = activeToolbarPlayers[index];
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
//             benchPlayers: activeToolbarPlayers,
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
//           // Creates an AWAY player
//           PlayerModel? newPlayer = await PlayerUtilsV2.showCreatePlayerDialog(
//               context: context, playerType: PlayerType.AWAY);
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
//   Widget _buildFooter({required List<PlayerModel> benchPlayers}) {
//     final boardState = ref.read(boardProvider);
//     final playersOnField = boardState.players
//         .where((p) => p.playerType == PlayerType.AWAY) // Logic for AWAY team
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
//             // --- AWAY TEAM POSITIONING LOGIC ---
//             // Create mirrored "target" positions from the HOME template
//             final List<PlayerModel> homeTemplatePlayers =
//                 scene.components.whereType<PlayerModel>().toList();
//             List<PlayerModel> targetAwayPositions = [];
//             for (final homePlayer in homeTemplatePlayers) {
//               Vector2 mirroredOffset = Vector2(
//                 1 -
//                     ((homePlayer.offset?.x ?? 0) -
//                         (SizeHelper.getBoardRelativeVector(
//                               gameScreenSize: tacticBoard.gameField.size,
//                               actualPosition: homePlayer.size ?? Vector2.zero(),
//                             ).x *
//                             1.25 /
//                             2)),
//                 1 -
//                     ((homePlayer.offset?.y ?? 0) -
//                         (SizeHelper.getBoardRelativeVector(
//                               gameScreenSize: tacticBoard.gameField.size,
//                               actualPosition: homePlayer.size ?? Vector2.zero(),
//                             ).y /
//                             2)),
//               );
//               targetAwayPositions.add(
//                 homePlayer.copyWith(
//                   offset: mirroredOffset,
//                   playerType: PlayerType.AWAY,
//                 ),
//               );
//             }
//
//             // --- NEW LOGIC: DISTINGUISH BETWEEN SETUP AND RE-ARRANGE ---
//             Map<String, PlayerModel?> initialAssignments;
//             List<PlayerModel> playersToArrange;
//
//             if (!isRearranging) {
//               // --- 1. INITIAL SETUP LOGIC (Your original logic) ---
//               zlog(data: "Performing initial away lineup setup.");
//               playersToArrange = players; // Full away roster
//               initialAssignments = {};
//               List<PlayerModel> unassignedRosterPlayers =
//                   List.from(playersToArrange);
//
//               for (final targetPos in targetAwayPositions) {
//                 int matchIndex = unassignedRosterPlayers.indexWhere((p) =>
//                     p.role == targetPos.role &&
//                     p.jerseyNumber == targetPos.jerseyNumber);
//                 if (matchIndex != -1) {
//                   initialAssignments[targetPos.id] =
//                       unassignedRosterPlayers.removeAt(matchIndex);
//                 } else {
//                   initialAssignments[targetPos.id] = null;
//                 }
//               }
//             } else {
//               // --- 2. RE-ARRANGEMENT LOGIC ---
//               zlog(data: "Performing away lineup re-arrangement.");
//               playersToArrange =
//                   playersOnField; // Key change: Use players on field!
//               initialAssignments = {};
//               List<PlayerModel> availableOnField = List.from(playersOnField);
//
//               for (final targetPos in targetAwayPositions) {
//                 int matchIndex = availableOnField
//                     .indexWhere((p) => p.role == targetPos.role);
//                 if (matchIndex != -1) {
//                   initialAssignments[targetPos.id] =
//                       availableOnField.removeAt(matchIndex);
//                 } else {
//                   initialAssignments[targetPos.id] = null;
//                 }
//               }
//               // Assign any remaining players to remaining slots
//               for (final targetPos in targetAwayPositions) {
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
//                 targetPositions: targetAwayPositions,
//                 playersToArrange: playersToArrange,
//                 benchPlayers: benchPlayers,
//                 initialAssignments: initialAssignments,
//               ),
//             );
//
//             if (finalLineup == null) return; // User cancelled
//
//             // --- SURGICAL APPLY LOGIC (Identical to Home) ---
//             zlog(data: "Applying new away lineup...");
//
//             final Set<String> originalPlayerIds =
//                 playersOnField.map((p) => p.id).toSet();
//             final Set<String> finalPlayerIds =
//                 finalLineup.map((p) => p.id).toSet();
//
//             final Set<String> idsToRemove =
//                 originalPlayerIds.difference(finalPlayerIds);
//             final List<PlayerModel> playersToRemove = playersOnField
//                 .where((p) => idsToRemove.contains(p.id))
//                 .toList();
//             if (playersToRemove.isNotEmpty) {
//               tacticBoard.removeFieldItems(playersToRemove);
//               zlog(
//                   data:
//                       "Removed ${playersToRemove.length} substituted away players.");
//             }
//
//             for (final newPlayerState in finalLineup) {
//               if (originalPlayerIds.contains(newPlayerState.id)) {
//                 tacticBoard.removeFieldItems([newPlayerState]);
//                 tacticBoard.addItem(newPlayerState);
//               } else {
//                 tacticBoard.addItem(newPlayerState);
//                 zlog(
//                     data:
//                         "Added substituted away player: ${newPlayerState.name}");
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
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/lineup_arrangement_dialog.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

// CHANGED: Create the StreamProvider for Away players.
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
    // REMOVED: No need to manually initiate players from here.
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

  // REMOVED: initiatePlayerLocally is no longer needed.

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

    // CHANGED: Watch the new stream provider for away players.
    final awayPlayersAsync = ref.watch(awayPlayersStreamProvider);

    if (lineup.categorizedGroups.isNotEmpty && teamFormation.isEmpty) {
      initiateTeamFormationLocally(lineups: lineup.categorizedGroups);
    }

    return awayPlayersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (players) {
        // `players` now comes directly from the stream
        List<PlayerModel> activeToolbarPlayers = generateActivePlayers(
          sourcePlayers: players,
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
                        // The UI will update automatically via the stream after the DB is saved.
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
          // The UI will update automatically via the stream after the DB is saved.
          await PlayerUtilsV2.showCreatePlayerDialog(
              context: context, playerType: PlayerType.AWAY);
        },
        child: Icon(
          FontAwesomeIcons.circlePlus,
          color: ColorManager.white,
        ));
  }

  // The _buildFooter method does not need to change.
  // We add a re-read of the provider's state inside the onTap to get the full player list.
  Widget _buildFooter({required List<PlayerModel> benchPlayers}) {
    final boardState = ref.read(boardProvider);
    final playersOnField = boardState.players
        .where((p) => p.playerType == PlayerType.AWAY)
        .toList();
    final bool isRearranging = playersOnField.isNotEmpty;

    return Column(
      children: [
        // ... (DropdownSelectors remain the same)
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

            final List<PlayerModel> homeTemplatePlayers =
                scene.components.whereType<PlayerModel>().toList();
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
              targetAwayPositions.add(
                homePlayer.copyWith(
                  offset: mirroredOffset,
                  playerType: PlayerType.AWAY,
                ),
              );
            }

            Map<String, PlayerModel?> initialAssignments;
            List<PlayerModel> playersToArrange;

            if (!isRearranging) {
              zlog(data: "Performing initial away lineup setup.");
              // Get the full roster from the provider's current state.
              final allPlayers =
                  ref.read(awayPlayersStreamProvider).value ?? [];
              playersToArrange = allPlayers;
              initialAssignments = {};
              List<PlayerModel> unassignedRosterPlayers =
                  List.from(playersToArrange);

              for (final targetPos in targetAwayPositions) {
                int matchIndex = unassignedRosterPlayers.indexWhere((p) =>
                    p.role == targetPos.role &&
                    p.jerseyNumber == targetPos.jerseyNumber);
                if (matchIndex != -1) {
                  initialAssignments[targetPos.id] =
                      unassignedRosterPlayers.removeAt(matchIndex);
                } else {
                  initialAssignments[targetPos.id] = null;
                }
              }
            } else {
              zlog(data: "Performing away lineup re-arrangement.");
              playersToArrange = playersOnField;
              initialAssignments = {};
              List<PlayerModel> availableOnField = List.from(playersOnField);

              for (final targetPos in targetAwayPositions) {
                int matchIndex = availableOnField
                    .indexWhere((p) => p.role == targetPos.role);
                if (matchIndex != -1) {
                  initialAssignments[targetPos.id] =
                      availableOnField.removeAt(matchIndex);
                } else {
                  initialAssignments[targetPos.id] = null;
                }
              }
              for (final targetPos in targetAwayPositions) {
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
                targetPositions: targetAwayPositions,
                playersToArrange: playersToArrange,
                benchPlayers: benchPlayers,
                initialAssignments: initialAssignments,
              ),
            );

            if (finalLineup == null) return;

            zlog(data: "Applying new away lineup...");

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
                      "Removed ${playersToRemove.length} substituted away players.");
            }

            for (final newPlayerState in finalLineup) {
              if (originalPlayerIds.contains(newPlayerState.id)) {
                tacticBoard.removeFieldItems([newPlayerState]);
                tacticBoard.addItem(newPlayerState);
              } else {
                tacticBoard.addItem(newPlayerState);
                zlog(
                    data:
                        "Added substituted away player: ${newPlayerState.name}");
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
