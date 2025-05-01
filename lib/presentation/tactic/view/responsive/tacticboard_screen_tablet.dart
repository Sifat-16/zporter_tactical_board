// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// // Imports for your project components and providers
// import 'package:zporter_tactical_board/app/core/component/pagination_component.dart';
// import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
// import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/show_quick_save_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/animation_data_input_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart'; // Assuming AnimationState is needed for the helper method type hint
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';
//
// class TacticboardScreenTablet extends ConsumerStatefulWidget {
//   const TacticboardScreenTablet({super.key, required this.userId});
//
//   final String userId;
//
//   @override
//   ConsumerState<TacticboardScreenTablet> createState() =>
//       _TacticboardScreenTabletState();
// }
//
// class _TacticboardScreenTabletState
//     extends ConsumerState<TacticboardScreenTablet> {
//   // Key for accessing Scaffold state to open drawers
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((t) async {
//       await ref.read(animationProvider.notifier).getAllCollections();
//       await ref.read(animationProvider.notifier).configureDefaultAnimations();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bp = ref.watch(boardProvider);
//     final ap = ref.watch(animationProvider);
//     final AnimationItemModel? selectedScene = ap.selectedScene;
//
//     ref.listen<BoardState>(
//       // Replace BoardState with the actual type of your boardProvider's state
//       boardProvider,
//       (BoardState? previousState, BoardState newState) {
//         // Check if 'isDragging' became true
//         final bool dragJustStarted =
//             newState.isDraggingElementToBoard &&
//             !(previousState?.isDraggingElementToBoard ?? false);
//
//         if (dragJustStarted) {
//           print("Listener detected drag start (isDragging == true)");
//           // Access ScaffoldState via the key
//           final scaffoldState = _scaffoldKey.currentState;
//           if (scaffoldState != null) {
//             // Check if left drawer is open and close it
//             if (scaffoldState.isDrawerOpen) {
//               print("Closing left drawer because drag started.");
//               scaffoldState.closeDrawer();
//             }
//             // Check if right drawer is open and close it
//             if (scaffoldState.isEndDrawerOpen) {
//               print("Closing right drawer because drag started.");
//               scaffoldState.closeEndDrawer();
//             }
//           } else {
//             print(
//               "Warning: ScaffoldKey currentState was null when trying to close drawers on drag.",
//             );
//           }
//         }
//       },
//     );
//
//     if (ap.isLoadingAnimationCollections) {
//       // Keep loading indicator
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     // --- Full Screen Mode ---
//     if (bp.showFullScreen) {
//       return PopScope(
//         canPop: false,
//         onPopInvoked: (bool didPop) {
//           if (!didPop) {
//             ref.read(boardProvider.notifier).toggleFullScreen();
//           }
//         },
//         // Simplified Fullscreen: Just the GameScreen + Close Button
//         child: SafeArea(
//           child: Scaffold(
//             key: _scaffoldKey,
//             onDrawerChanged: (b) {
//               if (b) {
//                 ref
//                     .read(boardProvider.notifier)
//                     .updateDraggingToBoard(isDragging: false);
//               }
//             },
//             onEndDrawerChanged: (b) {},
//             drawer: Drawer(
//               backgroundColor:
//                   ColorManager.black, // Make drawer background transparent
//               child: LefttoolbarComponent(),
//             ),
//
//             // Right Drawer with transparent background
//             endDrawer: Drawer(
//               backgroundColor:
//                   ColorManager.black, // Make drawer background transparent
//               child: RighttoolbarComponent(),
//             ),
//             backgroundColor: ColorManager.black, // Match background if needed
//             body: Stack(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(5.0), // Keep padding
//                   child: GameScreen(scene: selectedScene),
//                 ),
//
//                 Positioned(
//                   left: 0, // Adjust position as needed
//                   top: context.heightPercent(45),
//                   child: GestureDetector(
//                     onTap: () {
//                       _scaffoldKey.currentState?.openDrawer();
//                     },
//                     child: Icon(Icons.chevron_right, color: Colors.white),
//                   ),
//                 ),
//
//                 Positioned(
//                   right: 0, // Adjust position as needed
//                   top: context.heightPercent(45),
//                   child: GestureDetector(
//                     onTap: () {
//                       _scaffoldKey.currentState?.openEndDrawer();
//                     },
//                     child: Icon(Icons.chevron_left, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     // --- Normal Mode (Scaffold with Drawers) ---
//     return Scaffold(
//       key: _scaffoldKey, // Assign the key
//       backgroundColor: ColorManager.black, // Set background color
//       // Left Drawer with transparent background
//       onDrawerChanged: (b) {
//         if (b) {
//           ref
//               .read(boardProvider.notifier)
//               .updateDraggingToBoard(isDragging: false);
//         }
//       },
//       onEndDrawerChanged: (b) {},
//       drawer: Drawer(
//         backgroundColor:
//             ColorManager.black, // Make drawer background transparent
//         child: LefttoolbarComponent(),
//       ),
//
//       // Right Drawer with transparent background
//       endDrawer: Drawer(
//         backgroundColor:
//             ColorManager.black, // Make drawer background transparent
//         child: RighttoolbarComponent(),
//       ),
//
//       // Body with Stack for Content and Drawer Triggers
//       body: Stack(
//         children: [
//           // Main Content Area
//           _buildCentralContent(context, ref, ap, selectedScene),
//
//           // Left Drawer Trigger Icon
//           Positioned(
//             left: 5, // Adjust position as needed
//             top:
//                 MediaQuery.of(context).size.height / 2 -
//                 25, // Center vertically
//             child: Material(
//               color: ColorManager.grey.withValues(
//                 alpha: 0.5,
//               ), // Semi-transparent background
//               borderRadius: BorderRadius.circular(8),
//               elevation: 2.0, // Optional: Add shadow
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(8),
//                 onTap: () => _scaffoldKey.currentState?.openDrawer(),
//                 child: const Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Icon(
//                     Icons.chevron_right,
//                     color: Colors.white,
//                   ), // Icon to open left drawer
//                 ),
//               ),
//             ),
//           ),
//
//           // Right Drawer Trigger Icon
//           Positioned(
//             right: 5, // Adjust position as needed
//             top:
//                 MediaQuery.of(context).size.height / 2 -
//                 25, // Center vertically
//             child: Material(
//               color: ColorManager.grey.withValues(
//                 alpha: 0.5,
//               ), // Semi-transparent background
//               borderRadius: BorderRadius.circular(8),
//               elevation: 2.0, // Optional: Add shadow
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(8),
//                 onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
//                 child: const Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Icon(
//                     Icons.chevron_left,
//                     color: Colors.white,
//                   ), // Icon to open right drawer
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper method to build the central content area
//   Widget _buildCentralContent(
//     BuildContext context,
//     WidgetRef ref,
//     AnimationState asp, // Type hint from provider's state
//     AnimationItemModel? selectedScene,
//   ) {
//     AnimationCollectionModel? collectionModel =
//         asp.selectedAnimationCollectionModel;
//     AnimationModel? animationModel = asp.selectedAnimationModel;
//
//     return Padding(
//       padding: const EdgeInsets.only(
//         top: 50.0, // Keep original top padding
//         left: 40, // Keep padding to avoid overlap with drawer triggers
//         right: 40, // Keep padding to avoid overlap with drawer triggers
//       ),
//       child:
//           asp.showNewCollectionInput == true ||
//                   asp.showNewAnimationInput == true
//               ? AnimationDataInputComponent()
//               : asp.showQuickSave
//               ? ShowQuickSaveComponent()
//               : Column(
//                 mainAxisAlignment:
//                     MainAxisAlignment.start, // Align content to top
//                 children: [
//                   SizedBox(
//                     height:
//                         MediaQuery.of(context).size.height *
//                         0.85, // Adjust height as needed
//                     child: GameScreen(scene: selectedScene),
//                   ),
//                   if (animationModel == null)
//                     Row(
//                       children: [
//                         if (asp.defaultAnimationItems.isNotEmpty)
//                           Expanded(
//                             child: PaginationComponent(
//                               totalPages: asp.defaultAnimationItems.length,
//                               initialPage: asp.defaultAnimationItemIndex,
//                               currentPage: asp.defaultAnimationItemIndex,
//                               onIndexChange: (index) {
//                                 ref
//                                     .read(animationProvider.notifier)
//                                     .changeDefaultAnimationIndex(index);
//                               },
//                             ),
//                           ),
//                         IconButton(
//                           onPressed: () {
//                             ref
//                                 .read(animationProvider.notifier)
//                                 .createNewDefaultAnimationItem();
//                           },
//                           icon: Icon(Icons.add, color: ColorManager.white),
//                         ),
//                         IconButton(
//                           onPressed: () async {
//                             bool? confirm = await showConfirmationDialog(
//                               context: context,
//                               title: "Reset Board?",
//                               content:
//                                   "This will remove all elements currently placed on the tactical board, returning it to an empty state. Proceed?",
//                             );
//                             if (confirm == true) {
//                               ref
//                                   .read(animationProvider.notifier)
//                                   .deleteDefaultAnimation();
//                             }
//                           },
//                           icon: Icon(Icons.delete, color: ColorManager.white),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// --- Assuming Your Imports Are Correct ---
import 'package:zporter_tactical_board/app/core/component/pagination_component.dart';
import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart'; // Assuming zlog exists
// import 'package:zporter_tactical_board/app/extensions/size_extension.dart'; // If used
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
// --- End Imports ---

class TacticboardScreenTablet extends ConsumerStatefulWidget {
  const TacticboardScreenTablet({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<TacticboardScreenTablet> createState() =>
      _TacticboardScreenTabletState();
}

class _TacticboardScreenTabletState
    extends ConsumerState<TacticboardScreenTablet> {
  // --- State for panel visibility and dimensions ---
  bool _isLeftPanelOpen = false; // Start open or closed? Let's start closed.
  bool _isRightPanelOpen = false;
  late double _leftPanelWidth = 200.0; // Default, will be updated
  late double _rightPanelWidth = 250.0; // Default, will be updated
  final Duration _panelAnimationDuration = const Duration(milliseconds: 250);
  // --- End State ---

  // --- Toggle Functions ---
  void _toggleLeftPanel() {
    setState(() {
      _isLeftPanelOpen = !_isLeftPanelOpen;
    });
  }

  void _toggleRightPanel() {
    setState(() {
      _isRightPanelOpen = !_isRightPanelOpen;
    });
  }
  // --- End Toggle Functions ---

  @override
  void initState() {
    super.initState();

    // Initial data loading remains the same
    WidgetsBinding.instance.addPostFrameCallback((t) async {
      // Initialize panel widths based on context AFTER first frame
      if (mounted) {
        setState(() {
          _leftPanelWidth = context.widthPercent(20);
          _rightPanelWidth = context.widthPercent(20);
        });
      }
      try {
        await ref.read(animationProvider.notifier).getAllCollections();
        await ref.read(animationProvider.notifier).configureDefaultAnimations();
      } catch (e) {
        zlog(data: "Error during initial data load: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final bp = ref.watch(boardProvider);
    final ap = ref.watch(animationProvider);
    final AnimationItemModel? selectedScene = ap.selectedScene;

    // Listener (removed drag listener as it's not relevant to this layout)
    /* ref.listen<BoardState>(...) */

    // Loading State
    if (ap.isLoadingAnimationCollections) {
      return const Scaffold(
        backgroundColor: ColorManager.black,
        body: Center(
          child: CircularProgressIndicator(color: ColorManager.white),
        ),
      );
    }

    // --- Full Screen Mode (Now Includes Panels) ---
    if (bp.showFullScreen) {
      return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (!didPop) {
            ref.read(boardProvider.notifier).toggleFullScreen();
          }
        },
        child: SafeArea(
          // SafeArea for fullscreen content
          child: Scaffold(
            backgroundColor: ColorManager.black,
            body: Stack(
              // Use Stack for layering panels and buttons
              children: [
                // --- 1. Main Content Area (Bottom Layer) ---
                // Padding might be needed if panels don't fully cover edges
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      5.0,
                    ), // Minimal padding for content
                    child: GameScreen(scene: selectedScene),
                  ),
                ),

                // --- 2. Left Sliding Panel (AnimatedPositioned) ---
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
                    child: LefttoolbarComponent(),
                  ),
                ),

                // --- 3. Right Sliding Panel (AnimatedPositioned) ---
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

                // --- 4. Left Panel Trigger Button (AnimatedPositioned) ---
                AnimatedPositioned(
                  duration: _panelAnimationDuration,
                  curve: Curves.easeInOut,
                  left: _isLeftPanelOpen ? _leftPanelWidth - 20 : 5,
                  top: MediaQuery.of(context).size.height / 2 - 25,
                  child: Material(
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

                // --- 5. Right Panel Trigger Button (AnimatedPositioned) ---
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
    }

    // --- Normal Mode (Stack Layout with AnimatedPositioned Panels) ---
    // This part remains the same as the previous version
    return Scaffold(
      backgroundColor: ColorManager.black,
      body: Stack(
        // Use Stack for layering
        children: [
          // --- 1. Main Content Area (Bottom Layer) ---
          Positioned.fill(
            child: _buildCentralContent(context, ref, ap, selectedScene),
          ),

          // --- 2. Left Sliding Panel (AnimatedPositioned) ---
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
              child: LefttoolbarComponent(),
            ),
          ),

          // --- 3. Right Sliding Panel (AnimatedPositioned) ---
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

          // --- 4. Left Panel Trigger Button (AnimatedPositioned) ---
          AnimatedPositioned(
            duration: _panelAnimationDuration,
            curve: Curves.easeInOut,
            left: _isLeftPanelOpen ? _leftPanelWidth - 20 : 5,
            top: MediaQuery.of(context).size.height / 2 - 25,
            child: Material(
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

          // --- 5. Right Panel Trigger Button (AnimatedPositioned) ---
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
        ], // End Stack children
      ), // End Stack
    ); // End Scaffold
  }

  // Helper method to build the central content area (UNMODIFIED INTERNALLY)
  Widget _buildCentralContent(
    BuildContext context,
    WidgetRef ref,
    AnimationState asp,
    AnimationItemModel? selectedScene,
  ) {
    AnimationCollectionModel? collectionModel =
        asp.selectedAnimationCollectionModel;
    AnimationModel? animationModel = asp.selectedAnimationModel;

    return Padding(
      padding: const EdgeInsets.only(
        top: 50.0,
        left: 10, // Minimal padding, panels slide over
        right: 10,
        bottom: 10,
      ),
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
                  // Bottom controls row
                  if (animationModel == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          if (asp.defaultAnimationItems.isNotEmpty)
                            Expanded(
                              child: PaginationComponent(
                                totalPages: asp.defaultAnimationItems.length,
                                initialPage: asp.defaultAnimationItemIndex,
                                currentPage: asp.defaultAnimationItemIndex,
                                onIndexChange: (index) {
                                  ref
                                      .read(animationProvider.notifier)
                                      .changeDefaultAnimationIndex(index);
                                },
                              ),
                            ),
                          IconButton(
                            onPressed: () {
                              ref
                                  .read(animationProvider.notifier)
                                  .createNewDefaultAnimationItem();
                            },
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
}
