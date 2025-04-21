// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:multi_split_view/multi_split_view.dart';
// import 'package:zporter_tactical_board/app/core/component/pagination_component.dart';
// import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/show_quick_save_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_tool_bar.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/animation_data_input_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
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
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((t) async {
//       await ref.read(animationProvider.notifier).getAllCollections();
//       await ref.read(animationProvider.notifier).configureDefaultAnimations();
//       _generateMultiSplitViewController();
//     });
//   }
//
//   MultiSplitViewController? _multiSplitViewController;
//   List<Area> areas = [];
//   MultiSplitViewController? _multiSplitViewFullScreenController;
//   List<Area> fullArea = [];
//
//   @override
//   Widget build(BuildContext context) {
//     final bp = ref.watch(boardProvider);
//     final ap = ref.watch(animationProvider);
//     final AnimationItemModel? selectedScene = ap.selectedScene;
//
//     if (ap.isLoadingAnimationCollections) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (bp.showFullScreen) {
//       return PopScope(
//         canPop: false,
//         onPopInvoked: (bool didPop) {
//           if (!didPop) {
//             ref
//                 .read(boardProvider.notifier)
//                 .toggleFullScreen(); // <-- Adjust this line
//           }
//         },
//         child: MultiSplitView(
//           key: const ValueKey('full-screen'), // Or ValueKey(false)
//           controller: _multiSplitViewFullScreenController,
//         ),
//       );
//     }
//
//     return MultiSplitView(
//       key: const ValueKey('normal'), // Or ValueKey(false)
//       controller: _multiSplitViewController,
//     );
//   }
//
//   _generateMultiSplitViewController() {
//     setState(() {
//       areas = [
//         Area(
//           flex: 1,
//           max: 1,
//           builder: (context, area) {
//             return LefttoolbarComponent();
//           },
//         ),
//         Area(
//           flex: 3,
//           max: 3,
//           builder: (context, area) {
//             final asp = ref.watch(animationProvider);
//             AnimationCollectionModel? collectionModel =
//                 asp.selectedAnimationCollectionModel;
//             AnimationModel? animationModel = asp.selectedAnimationModel;
//             AnimationItemModel? selectedScene = asp.selectedScene;
//             return Padding(
//               padding: const EdgeInsets.only(top: 50.0),
//               child:
//                   asp.showNewCollectionInput == true ||
//                           asp.showNewAnimationInput == true
//                       ? AnimationDataInputComponent()
//                       : asp.showQuickSave
//                       ? ShowQuickSaveComponent()
//                       : SingleChildScrollView(
//                         // physics: NeverScrollableScrollPhysics(),
//                         child: Column(
//                           spacing: 10,
//                           children: [
//                             // Flexible(flex: 7, child: GameScreen(key: _gameScreenKey)),
//                             SizedBox(
//                               height: context.heightPercent(75),
//                               child: GameScreen(scene: selectedScene),
//                             ),
//
//                             FieldToolBar(
//                               selectedCollection: collectionModel,
//                               selectedAnimation: animationModel,
//                               selectedScene: selectedScene,
//                             ),
//
//                             if (animationModel == null)
//                               Row(
//                                 children: [
//                                   if (asp.defaultAnimationItems.isNotEmpty)
//                                     Expanded(
//                                       child: PaginationComponent(
//                                         totalPages:
//                                             asp.defaultAnimationItems.length,
//                                         initialPage:
//                                             asp.defaultAnimationItemIndex,
//                                         currentPage:
//                                             asp.defaultAnimationItemIndex,
//                                         onIndexChange: (index) {
//                                           ref
//                                               .read(animationProvider.notifier)
//                                               .changeDefaultAnimationIndex(
//                                                 index,
//                                               );
//                                         },
//                                       ),
//                                     ),
//                                   IconButton(
//                                     onPressed: () {
//                                       ref
//                                           .read(animationProvider.notifier)
//                                           .createNewDefaultAnimationItem();
//                                     },
//                                     icon: Icon(
//                                       Icons.add,
//                                       color: ColorManager.white,
//                                     ),
//                                   ),
//
//                                   IconButton(
//                                     onPressed: () {
//                                       ref
//                                           .read(animationProvider.notifier)
//                                           .deleteDefaultAnimation();
//                                     },
//                                     icon: Icon(
//                                       Icons.delete,
//                                       color: ColorManager.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                           ],
//                         ),
//                       ),
//             );
//           },
//         ),
//         Area(
//           flex: 1,
//           max: 1,
//           builder: (context, area) {
//             return RighttoolbarComponent();
//           },
//         ),
//       ];
//       fullArea = [
//         Area(
//           flex: 3,
//           max: 3,
//           builder: (context, area) {
//             final asp = ref.watch(animationProvider);
//             AnimationItemModel? selectedScene = asp.selectedScene;
//             return Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Stack(
//                 children: [
//                   GameScreen(scene: selectedScene),
//                   Align(
//                     alignment: Alignment.topRight,
//                     child: IconButton(
//                       onPressed: () {
//                         ref.read(boardProvider.notifier).toggleFullScreen();
//                       },
//                       icon: Icon(
//                         Icons.cancel_outlined,
//                         color: ColorManager.dark2,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ];
//
//       _multiSplitViewController = MultiSplitViewController(areas: areas);
//       _multiSplitViewFullScreenController = MultiSplitViewController(
//         areas: fullArea,
//       );
//     });
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Imports for your project components and providers
import 'package:zporter_tactical_board/app/core/component/pagination_component.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/show_quick_save_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_tool_bar.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/animation_data_input_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart'; // Assuming AnimationState is needed for the helper method type hint
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

class TacticboardScreenTablet extends ConsumerStatefulWidget {
  const TacticboardScreenTablet({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<TacticboardScreenTablet> createState() =>
      _TacticboardScreenTabletState();
}

class _TacticboardScreenTabletState
    extends ConsumerState<TacticboardScreenTablet> {
  // Key for accessing Scaffold state to open drawers
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) async {
      await ref.read(animationProvider.notifier).getAllCollections();
      await ref.read(animationProvider.notifier).configureDefaultAnimations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    final ap = ref.watch(animationProvider);
    final AnimationItemModel? selectedScene = ap.selectedScene;

    ref.listen<BoardState>(
      // Replace BoardState with the actual type of your boardProvider's state
      boardProvider,
      (BoardState? previousState, BoardState newState) {
        // Check if 'isDragging' became true
        final bool dragJustStarted =
            newState.isDraggingElementToBoard &&
            !(previousState?.isDraggingElementToBoard ?? false);

        if (dragJustStarted) {
          print("Listener detected drag start (isDragging == true)");
          // Access ScaffoldState via the key
          final scaffoldState = _scaffoldKey.currentState;
          if (scaffoldState != null) {
            // Check if left drawer is open and close it
            if (scaffoldState.isDrawerOpen) {
              print("Closing left drawer because drag started.");
              scaffoldState.closeDrawer();
            }
            // Check if right drawer is open and close it
            if (scaffoldState.isEndDrawerOpen) {
              print("Closing right drawer because drag started.");
              scaffoldState.closeEndDrawer();
            }
          } else {
            print(
              "Warning: ScaffoldKey currentState was null when trying to close drawers on drag.",
            );
          }
        }
      },
    );

    if (ap.isLoadingAnimationCollections) {
      // Keep loading indicator
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // --- Full Screen Mode ---
    if (bp.showFullScreen) {
      return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (!didPop) {
            ref.read(boardProvider.notifier).toggleFullScreen();
          }
        },
        // Simplified Fullscreen: Just the GameScreen + Close Button
        child: Scaffold(
          backgroundColor: ColorManager.black, // Match background if needed
          body: Padding(
            padding: const EdgeInsets.all(20.0), // Keep padding
            child: Stack(
              children: [
                GameScreen(scene: selectedScene), // Directly use GameScreen
                Align(
                  // Keep the close button
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      ref.read(boardProvider.notifier).toggleFullScreen();
                    },
                    icon: Icon(
                      Icons.fullscreen_exit, // Changed icon for clarity
                      color:
                          ColorManager.dark2 ??
                          Colors.grey, // Provide fallback color
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- Normal Mode (Scaffold with Drawers) ---
    return Scaffold(
      key: _scaffoldKey, // Assign the key
      backgroundColor: ColorManager.black, // Set background color
      // Left Drawer with transparent background
      onDrawerChanged: (b) {
        if (b) {
          ref
              .read(boardProvider.notifier)
              .updateDraggingToBoard(isDragging: false);
        }
      },
      onEndDrawerChanged: (b) {},
      drawer: Drawer(
        backgroundColor:
            Colors.transparent, // Make drawer background transparent
        child: LefttoolbarComponent(),
      ),

      // Right Drawer with transparent background
      endDrawer: Drawer(
        backgroundColor:
            Colors.transparent, // Make drawer background transparent
        child: RighttoolbarComponent(),
      ),

      // Body with Stack for Content and Drawer Triggers
      body: Stack(
        children: [
          // Main Content Area
          _buildCentralContent(context, ref, ap, selectedScene),

          // Left Drawer Trigger Icon
          Positioned(
            left: 5, // Adjust position as needed
            top:
                MediaQuery.of(context).size.height / 2 -
                25, // Center vertically
            child: Material(
              color: ColorManager.grey.withValues(
                alpha: 0.5,
              ), // Semi-transparent background
              borderRadius: BorderRadius.circular(8),
              elevation: 2.0, // Optional: Add shadow
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ), // Icon to open left drawer
                ),
              ),
            ),
          ),

          // Right Drawer Trigger Icon
          Positioned(
            right: 5, // Adjust position as needed
            top:
                MediaQuery.of(context).size.height / 2 -
                25, // Center vertically
            child: Material(
              color: ColorManager.grey.withValues(
                alpha: 0.5,
              ), // Semi-transparent background
              borderRadius: BorderRadius.circular(8),
              elevation: 2.0, // Optional: Add shadow
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ), // Icon to open right drawer
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the central content area
  Widget _buildCentralContent(
    BuildContext context,
    WidgetRef ref,
    AnimationState asp, // Type hint from provider's state
    AnimationItemModel? selectedScene,
  ) {
    AnimationCollectionModel? collectionModel =
        asp.selectedAnimationCollectionModel;
    AnimationModel? animationModel = asp.selectedAnimationModel;

    return Padding(
      padding: const EdgeInsets.only(
        top: 50.0, // Keep original top padding
        left: 40, // Keep padding to avoid overlap with drawer triggers
        right: 40, // Keep padding to avoid overlap with drawer triggers
      ),
      child:
          asp.showNewCollectionInput == true ||
                  asp.showNewAnimationInput == true
              ? AnimationDataInputComponent()
              : asp.showQuickSave
              ? ShowQuickSaveComponent()
              : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Align content to top
                  children: [
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height *
                          0.75, // Adjust height as needed
                      child: GameScreen(scene: selectedScene),
                    ),
                    const SizedBox(height: 10),
                    FieldToolBar(
                      selectedCollection: collectionModel,
                      selectedAnimation: animationModel,
                      selectedScene: selectedScene,
                    ),
                    const SizedBox(height: 10),
                    if (animationModel == null)
                      Row(
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
                          ),
                          IconButton(
                            onPressed: () {
                              ref
                                  .read(animationProvider.notifier)
                                  .deleteDefaultAnimation();
                            },
                            icon: Icon(Icons.delete, color: ColorManager.white),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }
}
