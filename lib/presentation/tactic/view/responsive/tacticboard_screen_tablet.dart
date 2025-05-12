// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/core/component/compact_paginator.dart';
// import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
// import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart'; // Assuming zlog exists
// // import 'package:zporter_tactical_board/app/extensions/size_extension.dart'; // If used
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
// import 'package:zporter_tactical_board/data/tutorials/tutorial_constants.dart';
// import 'package:zporter_tactical_board/data/tutorials/tutorial_utils.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/show_quick_save_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/animation_data_input_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
// // --- End Imports ---
//
// class TacticboardScreenTablet extends ConsumerStatefulWidget {
//   const TacticboardScreenTablet({super.key, required this.userId});
//   final String userId;
//
//   @override
//   ConsumerState<TacticboardScreenTablet> createState() =>
//       _TacticboardScreenTabletState();
// }
//
// class _TacticboardScreenTabletState
//     extends ConsumerState<TacticboardScreenTablet> {
//   // --- State for panel visibility and dimensions ---
//   bool _isLeftPanelOpen = false; // Start open or closed? Let's start closed.
//   bool _isRightPanelOpen = false;
//   late double _leftPanelWidth = 200.0; // Default, will be updated
//   late double _rightPanelWidth = 250.0; // Default, will be updated
//   final Duration _panelAnimationDuration = const Duration(milliseconds: 250);
//   // --- End State ---
//
//   // --- Toggle Functions ---
//   void _toggleLeftPanel() {
//     setState(() {
//       _isLeftPanelOpen = !_isLeftPanelOpen;
//     });
//   }
//
//   void _toggleRightPanel() {
//     setState(() {
//       _isRightPanelOpen = !_isRightPanelOpen;
//     });
//   }
//   // --- End Toggle Functions ---
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initial data loading remains the same
//     WidgetsBinding.instance.addPostFrameCallback((t) async {
//       // Initialize panel widths based on context AFTER first frame
//       if (mounted) {
//         setState(() {
//           _leftPanelWidth = context.widthPercent(20);
//           _rightPanelWidth = context.widthPercent(20);
//         });
//       }
//       try {
//         await ref.read(animationProvider.notifier).getAllCollections();
//         await ref.read(animationProvider.notifier).configureDefaultAnimations();
//         if (mounted) {
//           await _checkAndShowIntroTutorialPrompt();
//         }
//       } catch (e) {
//         zlog(data: "Error during initial data load: $e");
//       }
//     });
//   }
//
//   Future<void> _checkAndShowIntroTutorialPrompt() async {
//     // Check if this specific tutorial prompt has been shown before
//     bool tutorialPromptAlreadyShown = await TutorialUtils.isTutorialShown(
//       TutorialConstants.tacticBoardIntroTutorialId,
//     );
//
//     if (!tutorialPromptAlreadyShown && mounted) {
//       // If not shown, display the confirmation dialog
//       final takeTour = await showConfirmationDialog(
//         context: context,
//         title: "Welcome to the Tactical Board!",
//         content: "Would you like a quick tour of the main features?",
//         confirmButtonText: "Yes, show me",
//         cancelButtonText: "No, thanks",
//       );
//
//       // await TutorialUtils.markTutorialAsShown(
//       //   TutorialConstants.tacticBoardIntroTutorialId,
//       // );
//
//       if (takeTour == true) {
//         zlog(data: "User opted IN for the tactical board intro tutorial.");
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                 "Great! The tutorial will start now... (Not yet implemented)",
//               ),
//             ),
//           );
//         }
//       } else {
//         zlog(
//           data:
//               "User opted OUT of or dismissed the tactical board intro tutorial.",
//         );
//       }
//     } else {
//       if (tutorialPromptAlreadyShown) {
//         zlog(
//           data:
//               "Tactical board intro tutorial prompt already shown previously.",
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Watch providers
//     final bp = ref.watch(boardProvider);
//     final ap = ref.watch(animationProvider);
//     final AnimationItemModel? selectedScene = ap.selectedScene;
//
//     // Listener (removed drag listener as it's not relevant to this layout)
//     /* ref.listen<BoardState>(...) */
//
//     // Loading State
//     if (ap.isLoadingAnimationCollections) {
//       return const Scaffold(
//         backgroundColor: ColorManager.black,
//         body: Center(
//           child: CircularProgressIndicator(color: ColorManager.white),
//         ),
//       );
//     }
//
//     // --- Full Screen Mode (Now Includes Panels) ---
//     if (bp.showFullScreen) {
//       return PopScope(
//         canPop: false,
//         onPopInvoked: (bool didPop) {
//           if (!didPop) {
//             ref.read(boardProvider.notifier).toggleFullScreen();
//           }
//         },
//         child: SafeArea(
//           // SafeArea for fullscreen content
//           child: Scaffold(
//             backgroundColor: ColorManager.black,
//             body: Stack(
//               // Use Stack for layering panels and buttons
//               children: [
//                 // --- 1. Main Content Area (Bottom Layer) ---
//                 // Padding might be needed if panels don't fully cover edges
//                 Positioned.fill(
//                   child: _buildCentralContentFullScreen(
//                     context,
//                     ref,
//                     ap,
//                     selectedScene,
//                   ),
//                 ),
//
//                 // --- 2. Left Sliding Panel (AnimatedPositioned) ---
//                 AnimatedPositioned(
//                   duration: _panelAnimationDuration,
//                   curve: Curves.easeInOut,
//                   left: _isLeftPanelOpen ? 0 : -_leftPanelWidth,
//                   top: 0,
//                   bottom: 0,
//                   width: _leftPanelWidth,
//                   child: Material(
//                     elevation: 4.0,
//                     color: ColorManager.dark2,
//                     child: LefttoolbarComponent(),
//                   ),
//                 ),
//
//                 // --- 3. Right Sliding Panel (AnimatedPositioned) ---
//                 AnimatedPositioned(
//                   duration: _panelAnimationDuration,
//                   curve: Curves.easeInOut,
//                   right: _isRightPanelOpen ? 0 : -_rightPanelWidth,
//                   top: 0,
//                   bottom: 0,
//                   width: _rightPanelWidth,
//                   child: Material(
//                     elevation: 4.0,
//                     color: ColorManager.dark2,
//                     child: RighttoolbarComponent(),
//                   ),
//                 ),
//
//                 // --- 4. Left Panel Trigger Button (AnimatedPositioned) ---
//                 AnimatedPositioned(
//                   duration: _panelAnimationDuration,
//                   curve: Curves.easeInOut,
//                   left: _isLeftPanelOpen ? _leftPanelWidth - 20 : 5,
//                   top: MediaQuery.of(context).size.height / 2 - 25,
//                   child: Material(
//                     color: ColorManager.grey.withOpacity(0.6),
//                     borderRadius: const BorderRadius.only(
//                       topRight: Radius.circular(8),
//                       bottomRight: Radius.circular(8),
//                     ),
//                     elevation: 6.0,
//                     child: InkWell(
//                       borderRadius: const BorderRadius.only(
//                         topRight: Radius.circular(8),
//                         bottomRight: Radius.circular(8),
//                       ),
//                       onTap: _toggleLeftPanel,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 8.0,
//                           horizontal: 4.0,
//                         ),
//                         child: Icon(
//                           _isLeftPanelOpen
//                               ? Icons.chevron_left
//                               : Icons.chevron_right,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // --- 5. Right Panel Trigger Button (AnimatedPositioned) ---
//                 AnimatedPositioned(
//                   duration: _panelAnimationDuration,
//                   curve: Curves.easeInOut,
//                   right: _isRightPanelOpen ? _rightPanelWidth - 20 : 5,
//                   top: MediaQuery.of(context).size.height / 2 - 25,
//                   child: Material(
//                     color: ColorManager.grey.withOpacity(0.6),
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(8),
//                       bottomLeft: Radius.circular(8),
//                     ),
//                     elevation: 6.0,
//                     child: InkWell(
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(8),
//                         bottomLeft: Radius.circular(8),
//                       ),
//                       onTap: _toggleRightPanel,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 8.0,
//                           horizontal: 4.0,
//                         ),
//                         child: Icon(
//                           _isRightPanelOpen
//                               ? Icons.chevron_right
//                               : Icons.chevron_left,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     // --- Normal Mode (Stack Layout with AnimatedPositioned Panels) ---
//     // This part remains the same as the previous version
//     return Scaffold(
//       backgroundColor: ColorManager.black,
//       body: SizedBox(
//         height: context.heightPercent(90),
//         child: Stack(
//           // Use Stack for layering
//           children: [
//             // --- 1. Main Content Area (Bottom Layer) ---
//             Positioned.fill(
//               child: _buildCentralContent(context, ref, ap, selectedScene),
//             ),
//
//             // --- 2. Left Sliding Panel (AnimatedPositioned) ---
//             AnimatedPositioned(
//               duration: _panelAnimationDuration,
//               curve: Curves.easeInOut,
//               left: _isLeftPanelOpen ? 0 : -_leftPanelWidth,
//               top: 0,
//               bottom: 0,
//               width: _leftPanelWidth,
//               child: Material(
//                 elevation: 4.0,
//                 color: ColorManager.dark2,
//                 child: LefttoolbarComponent(),
//               ),
//             ),
//
//             // --- 3. Right Sliding Panel (AnimatedPositioned) ---
//             AnimatedPositioned(
//               duration: _panelAnimationDuration,
//               curve: Curves.easeInOut,
//               right: _isRightPanelOpen ? 0 : -_rightPanelWidth,
//               top: 0,
//               bottom: 0,
//               width: _rightPanelWidth,
//               child: Material(
//                 elevation: 4.0,
//                 color: ColorManager.dark2,
//                 child: RighttoolbarComponent(),
//               ),
//             ),
//
//             // --- 4. Left Panel Trigger Button (AnimatedPositioned) ---
//             AnimatedPositioned(
//               duration: _panelAnimationDuration,
//               curve: Curves.easeInOut,
//               left: _isLeftPanelOpen ? _leftPanelWidth - 20 : 5,
//               top: MediaQuery.of(context).size.height / 2 - 25,
//               child: Material(
//                 color: ColorManager.grey.withOpacity(0.6),
//                 borderRadius: const BorderRadius.only(
//                   topRight: Radius.circular(8),
//                   bottomRight: Radius.circular(8),
//                 ),
//                 elevation: 6.0,
//                 child: InkWell(
//                   borderRadius: const BorderRadius.only(
//                     topRight: Radius.circular(8),
//                     bottomRight: Radius.circular(8),
//                   ),
//                   onTap: _toggleLeftPanel,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 8.0,
//                       horizontal: 4.0,
//                     ),
//                     child: Icon(
//                       _isLeftPanelOpen
//                           ? Icons.chevron_left
//                           : Icons.chevron_right,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // --- 5. Right Panel Trigger Button (AnimatedPositioned) ---
//             AnimatedPositioned(
//               duration: _panelAnimationDuration,
//               curve: Curves.easeInOut,
//               right: _isRightPanelOpen ? _rightPanelWidth - 20 : 5,
//               top: MediaQuery.of(context).size.height / 2 - 25,
//               child: Material(
//                 color: ColorManager.grey.withOpacity(0.6),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(8),
//                   bottomLeft: Radius.circular(8),
//                 ),
//                 elevation: 6.0,
//                 child: InkWell(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(8),
//                     bottomLeft: Radius.circular(8),
//                   ),
//                   onTap: _toggleRightPanel,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 8.0,
//                       horizontal: 4.0,
//                     ),
//                     child: Icon(
//                       _isRightPanelOpen
//                           ? Icons.chevron_right
//                           : Icons.chevron_left,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ], // End Stack children
//         ),
//       ), // End Stack
//     ); // End Scaffold
//   }
//
//   // Helper method to build the central content area (UNMODIFIED INTERNALLY)
//   Widget _buildCentralContent(
//     BuildContext context,
//     WidgetRef ref,
//     AnimationState asp,
//     AnimationItemModel? selectedScene,
//   ) {
//     AnimationCollectionModel? collectionModel =
//         asp.selectedAnimationCollectionModel;
//
//     AnimationModel? animationModel = asp.selectedAnimationModel;
//
//     return Padding(
//       padding: const EdgeInsets.only(
//         top: 50.0,
//         left: 10, // Minimal padding, panels slide over
//         right: 10,
//         bottom: 10,
//       ),
//       child:
//           asp.showNewCollectionInput == true ||
//                   asp.showNewAnimationInput == true
//               ? AnimationDataInputComponent()
//               : asp.showQuickSave
//               ? ShowQuickSaveComponent()
//               : Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Expanded(child: GameScreen(scene: selectedScene)),
//                   // Bottom controls row
//                   if (animationModel == null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Row(
//                         children: [
//                           if (asp.defaultAnimationItems.isNotEmpty)
//                             Expanded(
//                               child:
//                               // PaginationComponent(
//                               //   totalPages: asp.defaultAnimationItems.length,
//                               //   initialPage: asp.defaultAnimationItemIndex,
//                               //   currentPage: asp.defaultAnimationItemIndex,
//                               //   onIndexChange: (index) {
//                               //     ref
//                               //         .read(animationProvider.notifier)
//                               //         .changeDefaultAnimationIndex(index);
//                               //   },
//                               // ),
//                               CompactPaginator(
//                                 totalPages: asp.defaultAnimationItems.length,
//                                 onPageChanged: (index) {
//                                   ref
//                                       .read(animationProvider.notifier)
//                                       .changeDefaultAnimationIndex(index);
//                                 },
//                                 initialPage: asp.defaultAnimationItemIndex,
//                               ),
//                             ),
//                           IconButton(
//                             onPressed: () {
//                               ref
//                                   .read(animationProvider.notifier)
//                                   .createNewDefaultAnimationItem();
//                             },
//                             icon: Icon(Icons.add, color: ColorManager.white),
//                             tooltip: "Add New Scene",
//                           ),
//                           IconButton(
//                             onPressed: () async {
//                               bool? confirm = await showConfirmationDialog(
//                                 context: context,
//                                 title: "Reset Board?",
//                                 content:
//                                     "This will remove all elements currently placed on the tactical board, returning it to an empty state. Proceed?",
//                                 confirmButtonText: "Reset",
//                               );
//                               if (confirm == true) {
//                                 ref
//                                     .read(animationProvider.notifier)
//                                     .deleteDefaultAnimation();
//                               }
//                             },
//                             icon: Icon(
//                               Icons.delete_sweep_outlined,
//                               color: ColorManager.white,
//                             ),
//                             tooltip: "Clear Current Scene",
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//     );
//   }
//
//   Widget _buildCentralContentFullScreen(
//     BuildContext context,
//     WidgetRef ref,
//     AnimationState asp,
//     AnimationItemModel? selectedScene,
//   ) {
//     AnimationCollectionModel? collectionModel =
//         asp.selectedAnimationCollectionModel;
//
//     AnimationModel? animationModel = asp.selectedAnimationModel;
//
//     return Padding(
//       padding: const EdgeInsets.all(5),
//       child:
//           asp.showNewCollectionInput == true ||
//                   asp.showNewAnimationInput == true
//               ? AnimationDataInputComponent()
//               : asp.showQuickSave
//               ? ShowQuickSaveComponent()
//               : GameScreen(scene: selectedScene),
//     );
//   }
// }

// lib/presentation/tactic/view/tacticboard_screen_tablet.dart
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import your new keys utility file
// Other necessary imports
import 'package:zporter_tactical_board/app/core/component/compact_paginator.dart';
import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/show_quick_save_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/animation_data_input_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tutorials/tactic_board_tutorial_manager.dart';
import 'package:zporter_tactical_board/presentation/tutorials/tutorial_keys.dart';

class TacticboardScreenTablet extends ConsumerStatefulWidget {
  const TacticboardScreenTablet({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<TacticboardScreenTablet> createState() =>
      _TacticboardScreenTabletState();
}

class _TacticboardScreenTabletState
    extends ConsumerState<TacticboardScreenTablet> {
  bool _isLeftPanelOpen = false;
  bool _isRightPanelOpen = false;
  late double _leftPanelWidth;
  late double _rightPanelWidth;
  final Duration _panelAnimationDuration = const Duration(milliseconds: 250);

  late final TacticBoardTutorialManager _tutorialManager;
  // Keys are no longer defined here, they are in TutorialKeys

  void _toggleLeftPanel() {
    setState(() {
      _isLeftPanelOpen = !_isLeftPanelOpen;
    });
    zlog(data: "Left panel toggled. Is open: $_isLeftPanelOpen");
  }

  void _toggleRightPanel() {
    setState(() {
      _isRightPanelOpen = !_isRightPanelOpen;
    });
  }

  void _performAddNewSceneAction() {
    final ap = ref.read(animationProvider); // Read current state
    final AnimationCollectionModel? selectedCollection =
        ap.selectedAnimationCollectionModel;
    final AnimationModel? selectedAnimation = ap.selectedAnimationModel;
    final AnimationItemModel? selectedScene = ap.selectedScene;

    zlog(data: "Tutorial: Performing Add New Scene action.");

    if (selectedCollection == null || selectedAnimation == null) {
      if (ref.read(boardProvider).showFullScreen) {
        ref.read(boardProvider.notifier).toggleFullScreen();
      }
      ref.read(animationProvider.notifier).showQuickSave();
    } else {
      try {
        if (selectedScene != null) {
          ref
              .read(animationProvider.notifier)
              .addNewScene(
                selectedCollection: selectedCollection,
                selectedAnimation: selectedAnimation,
                selectedScene: selectedScene,
              );
          zlog(data: "Tutorial: New scene added successfully.");
        } else {
          BotToast.showText(
            text: "Cannot add new scene: No current scene selected.",
          );
          zlog(
            data: "Tutorial: Cannot add new scene - no current scene selected.",
          );
        }
      } catch (e) {
        BotToast.showText(text: "Error adding new scene: $e");
        zlog(data: "Tutorial: Error adding new scene - $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _leftPanelWidth = 200.0;
    _rightPanelWidth = 250.0;
    _tutorialManager = TacticBoardTutorialManager();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {
          _leftPanelWidth = context.widthPercent(20);
          _rightPanelWidth = context.widthPercent(20);
        });
      }
      try {
        await ref.read(animationProvider.notifier).getAllCollections();
        await ref.read(animationProvider.notifier).configureDefaultAnimations();

        if (mounted) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _tutorialManager.checkAndShowOpenLeftPanelTutorial(
                context: context,
                onLeftPanelButtonTutorialTap: _toggleLeftPanel,
                onTutorialStepFinished: () {
                  // Step 1 (Open Panel) Finished
                  zlog(
                    data:
                        "TacticboardScreen: Left panel tutorial step finished.",
                  );
                  if (_isLeftPanelOpen && mounted) {
                    Future.delayed(const Duration(milliseconds: 600), () {
                      if (mounted) {
                        if (TutorialKeys.firstPlayerKey.currentContext !=
                            null) {
                          zlog(
                            data:
                                "TacticboardScreen: Attempting to show drag player tutorial.",
                          );
                          _tutorialManager.showDragPlayerTutorial(
                            context: context,
                            onTutorialStepFinished: () {
                              // Step 2 (Drag Player) IS NOW TRULY Finished
                              zlog(
                                data:
                                    "TacticboardScreen: Drag player ACTION tutorial step finished.",
                              );
                              // Now, start the "Add New Scene" tutorial step
                              Future.delayed(const Duration(milliseconds: 300), () {
                                if (mounted &&
                                    TutorialKeys
                                            .addNewSceneButtonKey
                                            .currentContext !=
                                        null) {
                                  zlog(
                                    data:
                                        "TacticboardScreen: Attempting to show Add New Scene tutorial.",
                                  );
                                  _tutorialManager.showAddNewSceneTutorial(
                                    context: context,
                                    onAddNewSceneButtonTutorialTap:
                                        _performAddNewSceneAction,
                                    onTutorialStepFinished: () {
                                      zlog(
                                        data:
                                            "TacticboardScreen: Add New Scene tutorial step finished.",
                                      );
                                      zlog(data: "TUTORIAL SEQUENCE COMPLETE!");
                                    },
                                  );
                                } else if (mounted) {
                                  zlog(
                                    data:
                                        "TacticboardScreen: TutorialKeys.addNewSceneButtonKey.currentContext is NULL. Cannot start Add New Scene tutorial.",
                                  );
                                }
                              });
                            },
                          );
                        } else {
                          /* ... log error ... */
                          zlog(
                            data:
                                "TacticboardScreen: TutorialKeys.firstPlayerKey.currentContext is NULL.",
                          );
                        }
                      }
                    });
                  } else if (mounted) {
                    /* ... log error ... */
                    zlog(data: "TacticboardScreen: Left panel is not open.");
                  }
                },
              );
            }
          });
        }
      } catch (e, s) {
        zlog(data: "Error during initial data load or tutorial setup: $e \n$s");
      }
    });
  }

  @override
  void dispose() {
    _tutorialManager.dismissCurrentCoachMarkTutorial();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    final ap = ref.watch(animationProvider);
    final AnimationItemModel? selectedScene = ap.selectedScene;

    if (ap.isLoadingAnimationCollections) {
      return const Scaffold(
        backgroundColor: ColorManager.black,
        body: Center(
          child: CircularProgressIndicator(color: ColorManager.white),
        ),
      );
    }

    Widget screenContent;
    if (bp.showFullScreen) {
      screenContent = PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (!didPop) ref.read(boardProvider.notifier).toggleFullScreen();
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: ColorManager.black,
            body: Stack(
              children: [
                Positioned.fill(
                  child: _buildCentralContentFullScreen(
                    context,
                    ref,
                    ap,
                    selectedScene,
                  ),
                ),
                AnimatedPositioned(
                  duration: _panelAnimationDuration,
                  curve: Curves.easeInOut,
                  left: _isLeftPanelOpen ? 0 : -_leftPanelWidth,
                  top: 0,
                  bottom: 0,
                  width: _leftPanelWidth,
                  child: Material(
                    elevation: 4.0,
                    color: ColorManager.dark2,
                    // LefttoolbarComponent no longer takes the key
                    child: const LefttoolbarComponent(),
                  ),
                ),
                AnimatedPositioned(
                  duration: _panelAnimationDuration,
                  curve: Curves.easeInOut,
                  right: _isRightPanelOpen ? 0 : -_rightPanelWidth,
                  top: 0,
                  bottom: 0,
                  width: _rightPanelWidth,
                  child: Material(
                    elevation: 4.0,
                    color: ColorManager.dark2,
                    child: RighttoolbarComponent(),
                  ),
                ),
                AnimatedPositioned(
                  duration: _panelAnimationDuration,
                  curve: Curves.easeInOut,
                  left: _isLeftPanelOpen ? _leftPanelWidth - 20 : 5,
                  top: MediaQuery.of(context).size.height / 2 - 25,
                  // Assign the static key directly to the Material widget
                  child: Material(
                    key: TutorialKeys.leftPanelButtonKey,
                    color: ColorManager.grey.withOpacity(0.6),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    elevation: 6.0,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      onTap: _toggleLeftPanel,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        child: Icon(
                          _isLeftPanelOpen
                              ? Icons.chevron_left
                              : Icons.chevron_right,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                AnimatedPositioned(
                  duration: _panelAnimationDuration,
                  curve: Curves.easeInOut,
                  right: _isRightPanelOpen ? _rightPanelWidth - 20 : 5,
                  top: MediaQuery.of(context).size.height / 2 - 25,
                  child: Material(
                    color: ColorManager.grey.withOpacity(0.6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    elevation: 6.0,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      onTap: _toggleRightPanel,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        child: Icon(
                          _isRightPanelOpen
                              ? Icons.chevron_right
                              : Icons.chevron_left,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Normal Mode
      // screenContent = Scaffold(
      //   backgroundColor: ColorManager.black,
      //   body: SizedBox(
      //     height: context.heightPercent(100),
      //     width: context.widthPercent(100),
      //     child: Stack(
      //       children: [
      //         Positioned.fill(
      //           child: _buildCentralContent(context, ref, ap, selectedScene),
      //         ),
      //         AnimatedPositioned(
      //           duration: _panelAnimationDuration,
      //           curve: Curves.easeInOut,
      //           left: _isLeftPanelOpen ? 0 : -_leftPanelWidth,
      //           top: 0,
      //           bottom: 0,
      //           width: _leftPanelWidth,
      //           child: Material(
      //             elevation: 4.0,
      //             color: ColorManager.dark2,
      //             // LefttoolbarComponent no longer takes the key
      //             child: const LefttoolbarComponent(),
      //           ),
      //         ),
      //         AnimatedPositioned(
      //           duration: _panelAnimationDuration,
      //           curve: Curves.easeInOut,
      //           right: _isRightPanelOpen ? 0 : -_rightPanelWidth,
      //           top: 0,
      //           bottom: 0,
      //           width: _rightPanelWidth,
      //           child: Material(
      //             elevation: 4.0,
      //             color: ColorManager.dark2,
      //             child: RighttoolbarComponent(),
      //           ),
      //         ),
      //         AnimatedPositioned(
      //           duration: _panelAnimationDuration,
      //           curve: Curves.easeInOut,
      //           left: _isLeftPanelOpen ? _leftPanelWidth - 20 : 5,
      //           top: (context.heightPercent(90) / 2) - 25,
      //           // Assign the static key directly to the Material widget
      //           child: Material(
      //             key: TutorialKeys.leftPanelButtonKey,
      //             color: ColorManager.grey.withOpacity(0.6),
      //             borderRadius: const BorderRadius.only(
      //               topRight: Radius.circular(8),
      //               bottomRight: Radius.circular(8),
      //             ),
      //             elevation: 6.0,
      //             child: InkWell(
      //               borderRadius: const BorderRadius.only(
      //                 topRight: Radius.circular(8),
      //                 bottomRight: Radius.circular(8),
      //               ),
      //               onTap: _toggleLeftPanel,
      //               child: Padding(
      //                 padding: const EdgeInsets.symmetric(
      //                   vertical: 8.0,
      //                   horizontal: 4.0,
      //                 ),
      //                 child: Icon(
      //                   _isLeftPanelOpen
      //                       ? Icons.chevron_left
      //                       : Icons.chevron_right,
      //                   color: Colors.white,
      //                   size: 20,
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ),
      //
      //         AnimatedPositioned(
      //           duration: _panelAnimationDuration,
      //           curve: Curves.easeInOut,
      //           right: _isRightPanelOpen ? _rightPanelWidth - 20 : 5,
      //           top: (context.heightPercent(90) / 2) - 25,
      //           child: Material(
      //             color: ColorManager.grey.withOpacity(0.6),
      //             borderRadius: const BorderRadius.only(
      //               topLeft: Radius.circular(8),
      //               bottomLeft: Radius.circular(8),
      //             ),
      //             elevation: 6.0,
      //             child: InkWell(
      //               borderRadius: const BorderRadius.only(
      //                 topLeft: Radius.circular(8),
      //                 bottomLeft: Radius.circular(8),
      //               ),
      //               onTap: _toggleRightPanel,
      //               child: Padding(
      //                 padding: const EdgeInsets.symmetric(
      //                   vertical: 8.0,
      //                   horizontal: 4.0,
      //                 ),
      //                 child: Icon(
      //                   _isRightPanelOpen
      //                       ? Icons.chevron_right
      //                       : Icons.chevron_left,
      //                   color: Colors.white,
      //                   size: 20,
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // );
      screenContent = Stack(
        children: [
          // 1. The Scaffold is now a child of the root Stack
          Scaffold(
            backgroundColor: ColorManager.black,
            body: SizedBox(
              // This SizedBox ensures _buildCentralContent still knows its bounds
              // within the Scaffold's body.
              height: context.heightPercent(100),
              width: context.widthPercent(100),
              // The Stack previously here is removed, _buildCentralContent is placed directly.
              // Positioned.fill is used to make _buildCentralContent fill the SizedBox.
              child: _buildCentralContent(context, ref, ap, selectedScene),
            ),
            // If you have an AppBar, FloatingActionButton, etc., for the Scaffold,
            // they would remain here.
          ),

          // 2. AnimatedPositioned widgets are now direct children of the root Stack,
          //    overlaying the Scaffold.
          AnimatedPositioned(
            duration: _panelAnimationDuration,
            curve: Curves.easeInOut,
            left: _isLeftPanelOpen ? 0 : -_leftPanelWidth,
            top: 0,
            bottom: 0,
            width: _leftPanelWidth,
            child: Material(
              elevation: 4.0,
              color: ColorManager.dark2,
              child: const LefttoolbarComponent(),
            ),
          ),
          AnimatedPositioned(
            duration: _panelAnimationDuration,
            curve: Curves.easeInOut,
            right: _isRightPanelOpen ? 0 : -_rightPanelWidth,
            top: 0,
            bottom: 0,
            width: _rightPanelWidth,
            child: Material(
              elevation: 4.0,
              color: ColorManager.dark2,
              child:
                  RighttoolbarComponent(), // Assuming this doesn't need 'const' or is stateful
            ),
          ),
          AnimatedPositioned(
            duration: _panelAnimationDuration,
            curve: Curves.easeInOut,
            left: _isLeftPanelOpen ? _leftPanelWidth - 20 : 5,
            top:
                (context.heightPercent(90) / 2) -
                25, // Consider if context here refers to the correct one
            // It should be the context of the build method where screenContent is defined
            child: Material(
              key: TutorialKeys.leftPanelButtonKey,
              color: ColorManager.grey.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              elevation: 6.0,
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                onTap: _toggleLeftPanel,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  child: Icon(
                    _isLeftPanelOpen ? Icons.chevron_left : Icons.chevron_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: _panelAnimationDuration,
            curve: Curves.easeInOut,
            right: _isRightPanelOpen ? _rightPanelWidth - 20 : 5,
            top:
                (context.heightPercent(90) / 2) -
                25, // Same consideration for context here
            child: Material(
              color: ColorManager.grey.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              elevation: 6.0,
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                onTap: _toggleRightPanel,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  child: Icon(
                    _isRightPanelOpen
                        ? Icons.chevron_right
                        : Icons.chevron_left,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return screenContent;
  }

  Widget _buildCentralContent(
    BuildContext context,
    WidgetRef ref,
    AnimationState asp,
    AnimationItemModel? selectedScene,
  ) {
    AnimationModel? animationModel = asp.selectedAnimationModel;
    return Padding(
      padding: EdgeInsets.only(top: 50.0, left: 10, right: 10, bottom: 10),
      child:
          asp.showNewCollectionInput == true ||
                  asp.showNewAnimationInput == true
              ? AnimationDataInputComponent()
              : asp.showQuickSave
              ? ShowQuickSaveComponent()
              : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(child: GameScreen(scene: selectedScene)),
                  if (animationModel == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          if (asp.defaultAnimationItems.isNotEmpty)
                            Expanded(
                              child: CompactPaginator(
                                totalPages: asp.defaultAnimationItems.length,
                                onPageChanged: (index) {
                                  ref
                                      .read(animationProvider.notifier)
                                      .changeDefaultAnimationIndex(index);
                                },
                                initialPage: asp.defaultAnimationItemIndex,
                              ),
                            ),
                          IconButton(
                            onPressed:
                                () =>
                                    ref
                                        .read(animationProvider.notifier)
                                        .createNewDefaultAnimationItem(),
                            icon: Icon(Icons.add, color: ColorManager.white),
                            tooltip: "Add New Scene",
                          ),
                          IconButton(
                            onPressed: () async {
                              bool? confirm = await showConfirmationDialog(
                                context: context,
                                title: "Reset Board?",
                                content:
                                    "This will remove all elements currently placed on the tactical board, returning it to an empty state. Proceed?",
                                confirmButtonText: "Reset",
                              );
                              if (confirm == true) {
                                ref
                                    .read(animationProvider.notifier)
                                    .deleteDefaultAnimation();
                              }
                            },
                            icon: Icon(
                              Icons.delete_sweep_outlined,
                              color: ColorManager.white,
                            ),
                            tooltip: "Clear Current Scene",
                          ),
                        ],
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildCentralContentFullScreen(
    BuildContext context,
    WidgetRef ref,
    AnimationState asp,
    AnimationItemModel? selectedScene,
  ) {
    return Padding(
      padding: EdgeInsets.all(5),
      child:
          asp.showNewCollectionInput == true ||
                  asp.showNewAnimationInput == true
              ? AnimationDataInputComponent()
              : asp.showQuickSave
              ? ShowQuickSaveComponent()
              : GameScreen(scene: selectedScene),
    );
  }
}
