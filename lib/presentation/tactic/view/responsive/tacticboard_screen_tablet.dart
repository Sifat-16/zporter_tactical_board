import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/compact_paginator.dart';
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
                  child: _buildCentralContentFullScreen(
                    context,
                    ref,
                    ap,
                    selectedScene,
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
      body: SizedBox(
        height: context.heightPercent(90),
        child: Stack(
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
          ], // End Stack children
        ),
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
                              child:
                              // PaginationComponent(
                              //   totalPages: asp.defaultAnimationItems.length,
                              //   initialPage: asp.defaultAnimationItemIndex,
                              //   currentPage: asp.defaultAnimationItemIndex,
                              //   onIndexChange: (index) {
                              //     ref
                              //         .read(animationProvider.notifier)
                              //         .changeDefaultAnimationIndex(index);
                              //   },
                              // ),
                              CompactPaginator(
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

  Widget _buildCentralContentFullScreen(
    BuildContext context,
    WidgetRef ref,
    AnimationState asp,
    AnimationItemModel? selectedScene,
  ) {
    AnimationCollectionModel? collectionModel =
        asp.selectedAnimationCollectionModel;

    AnimationModel? animationModel = asp.selectedAnimationModel;

    return Padding(
      padding: const EdgeInsets.all(5),
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
