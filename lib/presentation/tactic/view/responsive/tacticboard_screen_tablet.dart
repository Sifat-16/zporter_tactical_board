import 'dart:convert';
import 'dart:ui' as ui;

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/compact_paginator.dart';
import 'package:zporter_tactical_board/app/core/component/z_loader.dart';
import 'package:zporter_tactical_board/app/core/component/zporter_logo_launcher.dart';
import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/app/services/js_interop/js_interop.dart';
import 'package:zporter_tactical_board/app/services/storage/image_storage_service.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/tutorial_selection_dialogue.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/mixin/animation_playback_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/sync/sync_status_indicator.dart';
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
    this.tacticalBoardId,
    this.exerciseName,
    this.existingThumbnailUrl,
    this.isPlayerMode = false,
    this.stateManager,
  });
  final String userId;
  final String? collectionId;
  final String? animationId;
  final String? tacticalBoardId;
  final String? exerciseName;
  final String? existingThumbnailUrl;
  final bool isPlayerMode;
  final TacticalBoardStateManager? stateManager;

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
  bool _isInitialized = false; // Track if initial data load is complete
  int _resizeCounter = 0; // Track resize events to force GameScreen rebuild

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

    // Register callbacks with the JS Interop state manager (only in widget mode)
    widget.stateManager?.onSaveRequested(() {
      zlog(data: "Save requested via JS Interop");
      _handleSave();
    });

    widget.stateManager?.onCancelRequested(() {
      zlog(data: "Cancel requested via JS Interop");
      _handleCancel();
    });

    widget.stateManager?.onResizeRequested(() {
      zlog(data: "Resize requested via JS Interop");
      _handleResize();
    });

    // Register callback for when initial animation data is set from JavaScript
    // This is used when editing an existing tactical board
    widget.stateManager?.onInitialAnimationDataSet(() {
      zlog(
          data:
              "Initial animation data set via JS Interop - loading external data");
      _loadExternalAnimationData();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initialLoadAndSelect();
    });
  }

  /// Load animation data passed from the parent web app
  Future<void> _loadExternalAnimationData() async {
    final jsonData = widget.stateManager?.getInitialAnimationDataJson();
    if (jsonData == null || jsonData.isEmpty) {
      zlog(data: "[_loadExternalAnimationData] No external animation data");
      return;
    }

    try {
      zlog(
          data:
              "[_loadExternalAnimationData] Parsing external animation data...");
      final Map<String, dynamic> data = jsonDecode(jsonData);

      // The animation data should contain a 'scene' field with the scene data
      final sceneData = data['scene'] as Map<String, dynamic>?;
      if (sceneData != null) {
        zlog(data: "[_loadExternalAnimationData] Found scene data, loading...");
        ref.read(animationProvider.notifier).loadExternalSceneData(sceneData);

        // Mark as initialized
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
        zlog(
            data:
                "[_loadExternalAnimationData] External scene loaded successfully");
      } else {
        zlog(
            data:
                "[_loadExternalAnimationData] No scene data found in external data");
        // Fallback to normal initialization
        await _initialLoadAndSelect();
      }
    } catch (e, s) {
      zlog(
          data: "[_loadExternalAnimationData] Error loading external data: $e");
      print("[_loadExternalAnimationData] Stack: $s");
      // Fallback to normal initialization on error
      await _initialLoadAndSelect();
    }
  }

  Future<void> _initialLoadAndSelect() async {
    try {
      print(
          "[_initialLoadAndSelect] Starting initialization - userId: ${widget.userId}");

      // Mark as not initialized during load
      setState(() {
        _isInitialized = false;
      });

      // 1. Fetch all collections and animations for the user first.
      print("[_initialLoadAndSelect] Calling getAllCollections...");
      await ref.read(animationProvider.notifier).getAllCollections();

      print("[_initialLoadAndSelect] Collections loaded successfully");

      // After fetching, the state is now populated. Get the list of collections.
      final collections = ref.read(animationProvider).animationCollections;

      print("[_initialLoadAndSelect] Found ${collections.length} collections");

      // EXERCISE NAME HANDLING: If exerciseName is provided, find or create "Exercises" collection
      if (widget.exerciseName != null && widget.exerciseName!.isNotEmpty) {
        print(
            "[_initialLoadAndSelect] Exercise name provided: ${widget.exerciseName}");
        await _handleExerciseNameFlow(collections);
        return;
      }

      // 2. Check if a specific collectionId was passed from the URL.
      if (widget.collectionId != null && collections.isNotEmpty) {
        print(
            "[_initialLoadAndSelect] Looking for collection: ${widget.collectionId}");

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

        print("[_initialLoadAndSelect] Collection selected successfully");

        return; // Exit after successful selection.
      }

      // 5. If no specific IDs were passed or found, run the default startup.
      print("[_initialLoadAndSelect] Loading default animations");
      await ref.read(animationProvider.notifier).configureDefaultAnimations();
      print("[_initialLoadAndSelect] Default animations loaded");
    } catch (e, s) {
      print("[_initialLoadAndSelect] ERROR: $e");
      print("[_initialLoadAndSelect] STACK: $s");

      // Fallback to default animations in case of any error.
      try {
        await ref.read(animationProvider.notifier).configureDefaultAnimations();
        print("[_initialLoadAndSelect] Recovered with default animations");
      } catch (fallbackError) {
        print(
            "[_initialLoadAndSelect] CRITICAL: Failed to load defaults: $fallbackError");
      }
    } finally {
      // Mark as initialized after everything is done
      if (mounted) {
        // Wait for next frame to ensure provider state has fully propagated
        await Future.delayed(Duration.zero);

        setState(() {
          _isInitialized = true;
        });
        print(
            "[_initialLoadAndSelect] Initialization complete - marked as ready");
      }
    }
  }

  /// Handle the exercise name flow: find or create "Tactics-Exercise" collection,
  /// then find or create an animation with the exercise name
  Future<void> _handleExerciseNameFlow(
      List<AnimationCollectionModel> collections) async {
    const String exercisesCollectionName = "Tactics-Exercise";
    final String exerciseName = widget.exerciseName!;

    print(
        "[_handleExerciseNameFlow] Looking for '$exercisesCollectionName' collection");

    // Find or create "Exercises" collection
    AnimationCollectionModel? exercisesCollection =
        collections.firstWhereOrNull(
      (c) => c.name == exercisesCollectionName,
    );

    if (exercisesCollection == null) {
      // Create the "Exercises" collection
      print(
          "[_handleExerciseNameFlow] Creating new '$exercisesCollectionName' collection");
      await ref.read(animationProvider.notifier).createNewCollectionAndReturn(
            exercisesCollectionName,
          );

      // Refresh collections after creation
      final updatedCollections =
          ref.read(animationProvider).animationCollections;
      exercisesCollection = updatedCollections.firstWhereOrNull(
        (c) => c.name == exercisesCollectionName,
      );
    }

    if (exercisesCollection == null) {
      print(
          "[_handleExerciseNameFlow] ERROR: Could not find or create '$exercisesCollectionName' collection");
      // Fallback to default animations
      await ref.read(animationProvider.notifier).configureDefaultAnimations();
      return;
    }

    print(
        "[_handleExerciseNameFlow] Found/created '$exercisesCollectionName' collection: ${exercisesCollection.id}");

    // Find animation with the exercise name in this collection
    AnimationModel? existingAnimation =
        exercisesCollection.animations.firstWhereOrNull(
      (a) => a.name == exerciseName,
    );

    if (existingAnimation != null) {
      // Animation exists, select it
      print(
          "[_handleExerciseNameFlow] Found existing animation: ${existingAnimation.name}");
      ref.read(animationProvider.notifier).selectAnimationCollection(
            exercisesCollection,
            animationSelect: existingAnimation,
          );
    } else {
      // Create new animation with exercise name
      print("[_handleExerciseNameFlow] Creating new animation: $exerciseName");
      ref.read(animationProvider.notifier).selectAnimationCollection(
            exercisesCollection,
            changeSelectedScene: false,
          );

      // Create the animation with the exercise name
      await ref.read(animationProvider.notifier).createNewAnimationWithName(
            exercisesCollection,
            exerciseName,
          );
    }

    print("[_handleExerciseNameFlow] Exercise name flow completed");
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

  // Widget mode: Capture thumbnail as base64 PNG
  Future<String?> _captureThumbnail() async {
    try {
      final context = gameBoundaryKey.currentContext;
      if (context == null) {
        zlog(data: "Widget mode: Boundary key has no context");
        return null;
      }

      final renderObject = context.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        final image = await renderObject.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        image.dispose();

        if (byteData == null) {
          zlog(data: "Widget mode: ByteData is null after toImage");
          return null;
        }

        final pngBytes = byteData.buffer.asUint8List();
        final base64String = base64Encode(pngBytes);
        zlog(
            data: "Widget mode: Thumbnail captured (${pngBytes.length} bytes)");
        return base64String;
      } else {
        zlog(
            data:
                "Widget mode: Expected RenderRepaintBoundary but found ${renderObject.runtimeType}");
        return null;
      }
    } catch (e, s) {
      zlog(data: "Widget mode: Error capturing thumbnail: $e\n$s");
      return null;
    }
  }

  // Widget mode: Handle save action
  Future<void> _handleSave() async {
    try {
      zlog(data: "Save requested - saving to Firebase and capturing thumbnail");

      // Step 1: Save the animation to Firebase using the animation provider
      final ap = ref.read(animationProvider);
      final selectedCollection = ap.selectedAnimationCollectionModel;
      final selectedAnimation = ap.selectedAnimationModel;
      final selectedScene = ap.selectedScene;

      if (selectedCollection == null ||
          selectedAnimation == null ||
          selectedScene == null) {
        BotToast.showText(text: "No animation data to save");
        return;
      }

      // Save to Firebase via animation provider
      await ref
          .read(animationProvider.notifier)
          .updateDatabaseOnChange(saveToDb: true);

      zlog(
          data:
              "Saved to Firebase - Collection: ${selectedCollection.id}, Animation: ${selectedAnimation.id}");

      // Step 2: Handle thumbnail
      // Priority: 1. Use existing thumbnail if provided (user-uploaded or previously generated)
      //           2. Generate new thumbnail only if none exists
      String? thumbnailUrl = widget.existingThumbnailUrl;

      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
        zlog(
            data:
                "Using existing thumbnail - skipping generation: $thumbnailUrl");
      } else {
        // No existing thumbnail, generate one
        zlog(data: "No existing thumbnail - generating new one");
        try {
          final base64Thumbnail = await _captureThumbnail();
          if (base64Thumbnail != null) {
            try {
              final imageService = sl.get<ImageStorageService>();
              final thumbnailBytes = base64Decode(base64Thumbnail);
              thumbnailUrl = await imageService.uploadTacticThumbnail(
                userId: widget.userId,
                animationId: selectedAnimation.id,
                imageData: thumbnailBytes,
              );
              zlog(data: "Thumbnail uploaded successfully: $thumbnailUrl");
            } catch (uploadError) {
              zlog(data: "Thumbnail upload failed (CORS?): $uploadError");
              // Continue without thumbnail - not a critical error
            }
          }
        } catch (thumbnailError) {
          zlog(data: "Thumbnail capture failed: $thumbnailError");
          // Continue without thumbnail - not a critical error
        }
      }

      // Step 3: ALWAYS set save result (even without thumbnail)
      zlog(data: "Setting save result...");
      widget.stateManager?.setSaveResult(
        collectionId: selectedCollection.id,
        animationId: selectedAnimation.id,
        thumbnailUrl: thumbnailUrl,
      );

      zlog(
          data:
              "Save completed - collectionId: ${selectedCollection.id}, animationId: ${selectedAnimation.id}, thumbnailUrl: $thumbnailUrl");

      BotToast.showText(text: "Tactical board saved successfully");
    } catch (e, s) {
      zlog(data: "Error saving tactical board: $e\n$s");
      BotToast.showText(text: "Failed to save tactical board");

      // Even on error, try to set a result so React doesn't timeout
      final ap = ref.read(animationProvider);
      if (ap.selectedAnimationCollectionModel != null &&
          ap.selectedAnimationModel != null) {
        widget.stateManager?.setSaveResult(
          collectionId: ap.selectedAnimationCollectionModel!.id,
          animationId: ap.selectedAnimationModel!.id,
          thumbnailUrl: null,
        );
      }
    }
  }

  // Handle cancel action - called via JS Interop
  void _handleCancel() {
    zlog(data: "Cancel requested via JS Interop");
    // Parent app handles the actual closing
    // This is just for any cleanup needed in the Flutter widget
  }

  void _handleResize() {
    zlog(data: "Resize requested via JS Interop - toggling fullscreen");

    // Call the same function that the toolbar fullscreen button uses
    ref.read(boardProvider.notifier).toggleFullScreen();
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    final ap = ref.watch(animationProvider);
    final AnimationItemModel? selectedScene = ap.selectedScene;

    print(
        "Build called - initialized: $_isInitialized, loading: ${ap.isLoadingAnimationCollections}, scene: ${selectedScene?.id}");

    _leftPanelWidth = context.widthPercent(25);
    _rightPanelWidth = context.widthPercent(25);

    // Show loading until initialization is complete
    if (!_isInitialized ||
        ap.isLoadingAnimationCollections ||
        selectedScene == null) {
      print("Showing loading screen - waiting for initialization");
      return const Scaffold(
        backgroundColor: ColorManager.black,
        body: Center(
          child: ZLoader(logoAssetPath: "assets/image/logo.png"),
        ),
      );
    }

    print("Rendering tactical board UI - initialization complete");

    // PLAYER MODE: Show only the game screen with animation controls
    if (widget.isPlayerMode) {
      // Auto-trigger animation playback when in player mode
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ap.selectedAnimationModel != null && bp.animatingObj == null) {
          ref
              .read(boardProvider.notifier)
              .toggleAnimating(animatingObj: AnimatingObj.animate());
        }
      });

      return Scaffold(
        backgroundColor: ColorManager.black,
        body: SafeArea(
          child: GameScreen(
            key: ValueKey('game_screen_$_resizeCounter'),
            scene: selectedScene,
            isPlayerMode: true,
          ),
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
                // Hide panels and toggles in widget mode
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
                // Note: Save/Cancel buttons removed - parent app handles UI via JS Interop
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
              child: _buildCentralContent(context, ref, ap, selectedScene, bp),
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

  Widget _buildCentralContent(BuildContext context, WidgetRef ref,
      AnimationState asp, AnimationItemModel? selectedScene, BoardState bp) {
    AnimationModel? animationModel = asp.selectedAnimationModel;
    return Padding(
      padding: EdgeInsets.only(top: 50.0, left: 10, right: 10, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (animationModel != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    flex: 1,
                    child: Opacity(
                      opacity: 0,
                      child: IconButton(
                          onPressed: () {}, icon: Icon(Icons.cancel_outlined)),
                    )),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      animationModel.name,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: ColorManager.white.withValues(alpha: 0.8),
                          fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Flexible(
                    flex: 1,
                    child: (bp.animatingObj?.isAnimating ?? false) == true
                        ? SizedBox()
                        : IconButton(
                            onPressed: () {
                              ref
                                  .read(animationProvider.notifier)
                                  .clearAnimation();
                            },
                            icon: Icon(
                              Icons.cancel_outlined,
                              color: ColorManager.white,
                            )))
              ],
            ),
          Expanded(
            child: GameScreen(
              key: ValueKey('game_screen_$_resizeCounter'),
              scene: selectedScene,
            ),
          ),
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
                            child: const Icon(
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
        child: GameScreen(
          key: ValueKey('game_screen_$_resizeCounter'),
          scene: selectedScene,
        ),
      ),
    );
  }
}
