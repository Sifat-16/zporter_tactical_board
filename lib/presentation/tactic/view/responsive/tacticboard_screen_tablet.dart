import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/compact_paginator.dart';
import 'package:zporter_tactical_board/app/core/component/z_loader.dart';
import 'package:zporter_tactical_board/app/core/component/zporter_logo_launcher.dart';
import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/tutorial_selection_dialogue.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/mixin/animation_playback_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

class TacticboardScreenTablet extends ConsumerStatefulWidget {
  const TacticboardScreenTablet({
    super.key,
    required this.userId,
    this.collectionId,
    this.animationId,
  });
  final String userId;
  final String? collectionId;
  final String? animationId;

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
          ref.read(animationProvider.notifier).addNewScene(
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // try {
      //   await ref.read(animationProvider.notifier).getAllCollections();
      //   await ref.read(animationProvider.notifier).configureDefaultAnimations();
      // } catch (e, s) {
      //   zlog(data: "Error during initial data load or tutorial setup: $e \n$s");
      // }
      _initialLoadAndSelect();
    });
  }

  Future<void> _initialLoadAndSelect() async {
    try {
      // 1. Fetch all collections and animations for the user first.
      await ref.read(animationProvider.notifier).getAllCollections();

      // After fetching, the state is now populated. Get the list of collections.
      final collections = ref.read(animationProvider).animationCollections;

      // 2. Check if a specific collectionId was passed from the URL.
      if (widget.collectionId != null && collections.isNotEmpty) {
        // Find the collection that matches the provided ID.
        final targetCollection = collections.firstWhere(
          (c) => c.id == widget.collectionId,
          orElse: () => collections.first, // Fallback to the first collection
        );

        AnimationModel? targetAnimation;
        // 3. If a collection was found, check for a specific animationId.
        if (widget.animationId != null &&
            targetCollection.animations.isNotEmpty) {
          targetAnimation = targetCollection.animations
              .firstWhereOrNull((a) => a.id == widget.animationId);
        }

        // 4. Select the found collection and/or animation.
        // Your existing method already handles selecting both at once.
        ref.read(animationProvider.notifier).selectAnimationCollection(
              targetCollection,
              animationSelect: targetAnimation,
            );
        return; // Exit after successful selection.
      }

      // 5. If no specific IDs were passed or found, run the default startup.
      await ref.read(animationProvider.notifier).configureDefaultAnimations();
    } catch (e, s) {
      zlog(data: "Error during initial load and select: $e \n$s");
      // Fallback to default animations in case of any error.
      await ref.read(animationProvider.notifier).configureDefaultAnimations();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isAnimating(BoardState bp) {
    AnimatingObj? animatingObj = bp.animatingObj;
    if (animatingObj == null) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    final ap = ref.watch(animationProvider);
    final AnimationItemModel? selectedScene = ap.selectedScene;

    zlog(data: "Build called for selected scene ${selectedScene?.id}");

    _leftPanelWidth = context.widthPercent(25);
    _rightPanelWidth = context.widthPercent(25);

    if (ap.isLoadingAnimationCollections) {
      return const Scaffold(
        backgroundColor: ColorManager.black,
        body: Center(
          child: ZLoader(logoAssetPath: "assets/image/logo.png"),
          // child: CircularProgressIndicator(color: ColorManager.white),
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
                if (!isAnimating(bp))
                  AnimatedPositioned(
                    duration: _panelAnimationDuration,
                    curve: Curves.easeInOut,
                    left: _isLeftPanelOpen ? 0 : -_leftPanelWidth,
                    top: 0,
                    bottom: 0,
                    width: _leftPanelWidth,
                    child: SafeArea(
                      child: Material(
                        elevation: 4.0,
                        color: ColorManager.transparent,
                        // LefttoolbarComponent no longer takes the key
                        child: const LefttoolbarComponent(),
                      ),
                    ),
                  ),
                if (!isAnimating(bp))
                  AnimatedPositioned(
                    duration: _panelAnimationDuration,
                    curve: Curves.easeInOut,
                    right: _isRightPanelOpen ? 0 : -_rightPanelWidth,
                    top: 0,
                    bottom: 0,
                    width: _rightPanelWidth,
                    child: SafeArea(
                      child: Material(
                        elevation: 4.0,
                        color: ColorManager.transparent,
                        child: RighttoolbarComponent(),
                      ),
                    ),
                  ),
                if (!isAnimating(bp))
                  AnimatedPositioned(
                    duration: _panelAnimationDuration,
                    curve: Curves.easeInOut,
                    left: _isLeftPanelOpen ? _leftPanelWidth - 20 : 5,
                    top: (context.heightPercent(92) / 2) - 25,
                    // Assign the static key directly to the Material widget
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
                if (!isAnimating(bp))
                  AnimatedPositioned(
                    duration: _panelAnimationDuration,
                    curve: Curves.easeInOut,
                    right: _isRightPanelOpen ? _rightPanelWidth - 20 : 5,
                    top: (context.heightPercent(92) / 2) - 25,
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

      screenContent = Stack(
        children: [
          // 1. The Scaffold is now a child of the root Stack
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: context.screenHeight * .92,
              width: context.widthPercent(100),
              child: _buildCentralContent(context, ref, ap, selectedScene),
            ),
          ),

          // 2. AnimatedPositioned widgets are now direct children of the root Stack,
          //    overlaying the Scaffold.
          if (!isAnimating(bp))
            AnimatedPositioned(
              duration: _panelAnimationDuration,
              curve: Curves.easeInOut,
              left: _isLeftPanelOpen ? 0 : -_leftPanelWidth,
              top: 0,
              bottom: 0,
              width: _leftPanelWidth,
              child: SafeArea(
                child: Material(
                  elevation: 4.0,
                  color: ColorManager.transparent,
                  child: const LefttoolbarComponent(),
                ),
              ),
            ),

          if (!isAnimating(bp))
            AnimatedPositioned(
              duration: _panelAnimationDuration,
              curve: Curves.easeInOut,
              right: _isRightPanelOpen ? 0 : -_rightPanelWidth,
              top: 0,
              bottom: 0,
              width: _rightPanelWidth,
              child: SafeArea(
                child: Material(
                  elevation: 4.0,
                  color: ColorManager.transparent,
                  child:
                      RighttoolbarComponent(), // Assuming this doesn't need 'const' or is stateful
                ),
              ),
            ),

          if (!isAnimating(bp))
            AnimatedPositioned(
              duration: _panelAnimationDuration,
              curve: Curves.easeInOut,
              left: _isLeftPanelOpen ? _leftPanelWidth - 20 : 5,
              top: (context.heightPercent(104) / 2) -
                  25, // Consider if context here refers to the correct one
              // It should be the context of the build method where screenContent is defined
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

          if (!isAnimating(bp))
            AnimatedPositioned(
              duration: _panelAnimationDuration,
              curve: Curves.easeInOut,
              right: _isRightPanelOpen ? _rightPanelWidth - 20 : 5,
              top: (context.heightPercent(104) / 2) -
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

  void _showTutorialSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // We return a dedicated widget for the dialog's content.
        return const TutorialSelectionDialog();
      },
    );
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (animationModel != null)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                animationModel.name ?? "",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: ColorManager.white.withValues(alpha: 0.8),
                    fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Expanded(child: GameScreen(scene: selectedScene)),
          if (animationModel == null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      // child: Image.asset(
                      //   AssetsManager.logo,
                      //   height: AppSize.s40,
                      //   width: AppSize.s40,
                      // ),
                      child: ZporterLogoLauncher(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: context.widthPercent(22),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              _showTutorialSelectionDialog(context);
                            },
                            child: Icon(
                              Icons.school_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // color: Colors.yellow,
                      ),
                      if (asp.defaultAnimationItems.isNotEmpty)
                        Container(
                          // color: Colors.green,
                          width: context.widthPercent(22),
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
                      Container(
                        // color: Colors.green,
                        width: context.widthPercent(22),
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                ref
                                    .read(animationProvider.notifier)
                                    .copyCurrentDefaultScene();
                                BotToast.showText(text: "Scene Copied");
                              },
                              child: Icon(
                                Icons.copy,
                                color: ColorManager.white,
                              ),
                              // tooltip: "Copy Current Scene",
                            ),
                            InkWell(
                              onTap: () => ref
                                  .read(animationProvider.notifier)
                                  .createNewDefaultAnimationItem(),

                              child: Icon(
                                CupertinoIcons.add_circled,
                                color: ColorManager.white,
                              ),
                              // tooltip: "Add New Scene",
                            ),
                            InkWell(
                              onTap: () async {
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
                              child: Icon(Icons.delete_sweep_outlined,
                                  color: ColorManager.white),
                              // tooltip: "Clear Current Scene",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                // child:/ Image.asset(
                //   AssetsManager.logo,
                //   height: AppSize.s40,
                //   width: AppSize.s40,
                // ),
                child: ZporterLogoLauncher(),
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
      child: SafeArea(
        top: true,
        bottom: true,
        child: GameScreen(scene: selectedScene),
      ),
    );
  }
}
