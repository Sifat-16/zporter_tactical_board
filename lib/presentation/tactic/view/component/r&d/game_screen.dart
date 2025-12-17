import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_capture_x_plus/widget_capture_x_plus.dart';
import 'package:widget_capture_x_plus/widget_capture_x_plus_controller.dart';
import 'package:zporter_tactical_board/app/core/component/z_loader.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/animation_sharer.dart';
import 'package:zporter_tactical_board/app/helper/device_capability_checker.dart';
import 'package:zporter_tactical_board/app/helper/file_name_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/animation_controls_widget.dart';
// Removed unused import: trajectory_editing_toolbar.dart
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/mixin/animation_playback_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/model/guide_line.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/form_speed_dial_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

enum AnimationShareType { image, video }

final GlobalKey<RiverpodAwareGameWidgetState> gameWidgetKey =
    GlobalKey<RiverpodAwareGameWidgetState>();
final GlobalKey gameBoundaryKey = GlobalKey();

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    super.key,
    required this.scene,
    this.config,
    this.saveToDb = true,
    this.onSceneSave,
    this.isPlayerMode = false,
  });
  final AnimationItemModel? scene;
  final FormSpeedDialConfig? config;
  final bool saveToDb;
  final Function(AnimationItemModel?)? onSceneSave;
  final bool isPlayerMode;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  TacticBoard? tacticBoardGame;
  bool gameInitialized = false;
  int previousAngle = 0;

  final double _snapTolerance = 5.0;

  List<GuideLine> _activeGuides = [];

  // Trajectory editing state - REMOVED (now in BoardState)
  // bool _showTrajectoryToolbar = false;
  // String? _selectedComponentId;

  final WidgetCaptureXPlusController _widgetCaptureXPlusController =
      WidgetCaptureXPlusController(
          outputBaseFileName:
              FileNameGenerator.generateZporterCaptureFilename());

  final closeButtonColor = Colors.grey[300];
  final closeButtonBackgroundColor = Colors.black;

  final ValueNotifier<double> _exportProgressNotifier =
      ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _isFinalizingVideoNotifier =
      ValueNotifier<bool>(false);

  // This will hold the context of the dialog that is currently shown.
  // It's crucial for popping the correct dialog instance.
  BuildContext? _currentExportDialogContext;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(boardProvider.notifier).initializeFromScene(widget.scene);
        createTacticBoardIfNecessary(widget.scene);

        // Initialize trajectory editor if in animation mode
        _initializeTrajectoryEditorIfNeeded();
      }
    });

    // createTacticBoardIfNecessary(widget.scene);
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.scene?.id == widget.scene?.id) {
    //   WidgetsBinding.instance.addPostFrameCallback((t) {
    //     if (!mounted) return;
    //     if (ref.read(animationProvider).isPerformingUndo == true) {
    //       updateTacticBoardIfNecessary(widget.scene);
    //       ref.read(animationProvider.notifier).toggleUndo(undo: false);
    //     }
    //   });
    // } else {
    //   updateTacticBoardIfNecessary(widget.scene);
    // }

    if (oldWidget.scene?.id != widget.scene?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(boardProvider.notifier).initializeFromScene(widget.scene);
          updateTacticBoardIfNecessary(widget.scene);
        }
      });
    } else {
      // Your existing logic for undo/redo
      WidgetsBinding.instance.addPostFrameCallback((t) {
        if (!mounted) return;
        if (ref.read(animationProvider).isPerformingUndo == true) {
          // For undo, you may also need to re-seed from the new scene
          ref.read(boardProvider.notifier).initializeFromScene(widget.scene);
          updateTacticBoardIfNecessary(widget.scene);
          ref.read(animationProvider.notifier).toggleUndo(undo: false);
        }
      });
    }
  }

  @override
  void dispose() {
    _exportProgressNotifier.dispose();
    _isFinalizingVideoNotifier.dispose();
    if (_currentExportDialogContext != null &&
        mounted &&
        Navigator.canPop(_currentExportDialogContext!)) {
      Navigator.of(_currentExportDialogContext!).pop(null);
    }
    _currentExportDialogContext = null;
    super.dispose();
  }

  // ========== Trajectory Editing Methods ==========

  /// Initialize trajectory editor if in animation mode
  void _initializeTrajectoryEditorIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final animationState = ref.read(animationProvider);
      final animationModel = animationState.selectedAnimationModel;

      // Only initialize if we have an animation with multiple scenes
      if (animationModel != null && animationModel.animationScenes.length > 1) {
        await tacticBoardGame?.initializeTrajectoryEditor();
      }
    });
  }

  // ========== Trajectory Editing Methods ==========

  /// Handle component selection - show trajectory toolbar
  void _onComponentSelected(FieldItemModel component) {
    final animationState = ref.read(animationProvider);
    final animationModel = animationState.selectedAnimationModel;
    final currentScene = animationState.selectedScene;

    debugPrint('🎯 Component selected: ${component.id}');
    debugPrint('   Animation model: ${animationModel != null ? "✅" : "❌"}');
    debugPrint('   Current scene: ${currentScene != null ? "✅" : "❌"}');

    // Only show toolbar if:
    // 1. We have an animation
    // 2. Animation has multiple scenes
    // 3. Current scene is not the first scene
    if (animationModel == null || currentScene == null) {
      print('   ❌ Missing animation or scene - exiting');
      return;
    }

    print('   Scene count: ${animationModel.animationScenes.length}');
    if (animationModel.animationScenes.length < 2) {
      print('   ❌ Need at least 2 scenes - exiting');
      return;
    }

    final sceneIndex = animationModel.animationScenes
        .indexWhere((s) => s.id == currentScene.id);
    print('   Current scene index: $sceneIndex');

    if (sceneIndex <= 0) {
      print('   ❌ Scene 0 or not found - no previous scene - exiting');
      return;
    }

    print('   ✅ Showing trajectory visualization');

    // Show trajectory visualization on canvas
    print('   📍 Calling showTrajectoryForComponent');
    tacticBoardGame?.showTrajectoryForComponent(
      componentId: component.id,
      currentItem: component,
    );
  }

  /// Handle selection cleared - hide trajectory toolbar
  void _onSelectionCleared() {
    // Hide trajectory visualization
    tacticBoardGame?.hideTrajectory();
  }

  bool isBoardBusy(BoardState bp) {
    return bp.animatingObj != null;
  }

  createTacticBoardIfNecessary(AnimationItemModel? selectedScene) {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      if (!mounted) return;

      setState(() {
        tacticBoardGame = TacticBoard(
          myContext: context,
          scene: selectedScene,
          saveToDb: widget.saveToDb,
          onSceneSave: widget.onSceneSave,
        );

        if (mounted) {
          ref.read(boardProvider.notifier).updateBoardBackground(
              selectedScene?.boardBackground ?? BoardBackground.full);
          ref.read(boardProvider.notifier).updateGameBoard(tacticBoardGame);
          ref.read(boardProvider.notifier).updateBoardColor(
                ref.read(animationProvider.notifier).getFieldColor(),
              );
          gameInitialized = true;
        }
      });
    });
  }

  updateTacticBoardIfNecessary(AnimationItemModel? selectedScene) {
    createTacticBoardIfNecessary(selectedScene);
  }

  Future<RecordingOutput?> _showVideoExportProgressDialog() async {
    // Ensure any previous dialog is closed before showing a new one.
    if (_currentExportDialogContext != null &&
        mounted &&
        Navigator.canPop(_currentExportDialogContext!)) {
      Navigator.of(_currentExportDialogContext!).pop(null);
    }
    _currentExportDialogContext = null;

    _exportProgressNotifier.value = 0.0;
    _isFinalizingVideoNotifier.value = false;

    try {
      zlog(data: "Starting widget recording for video export.");
      // CRITICAL FIX: Set recording state BEFORE starting to prevent auto-save interference
      ref
          .read(animationProvider.notifier)
          .setRecordingAnimation(isRecording: true);
      await _widgetCaptureXPlusController.startRecording();
      zlog(data: "Widget recording started.");
    } catch (e, s) {
      zlog(data: "Error starting widget recording: $e\n$s");
      // Reset recording state on error
      ref
          .read(animationProvider.notifier)
          .setRecordingAnimation(isRecording: false);
      BotToast.showText(
          text: "Failed to start video recording. Please try again.");
      // Ensure state is reset if recording fails to start.
      // The caller (onShare) will handle resetting boardProvider state.
      return null;
    }

    RecordingOutput? dialogResult = await showDialog<RecordingOutput?>(
      context: context,
      barrierColor: ColorManager.black,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Store the context for this specific dialog instance.
        _currentExportDialogContext = dialogContext;
        return AlertDialog(
          backgroundColor: ColorManager.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: ValueListenableBuilder<bool>(
            /* ... Title UI ... */
            valueListenable: _isFinalizingVideoNotifier,
            builder: (context, isFinalizing, child) => Text(
                isFinalizing ? 'Finalizing Video' : 'Exporting Animation',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ColorManager.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          content: ValueListenableBuilder<bool>(
            /* ... Content UI (Progress vs Finalizing) ... */
            valueListenable: _isFinalizingVideoNotifier,
            builder: (context, isFinalizing, child) {
              if (isFinalizing) {
                /* ... Finalizing UI with ZLoader ... */
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  ZLoader(logoAssetPath: 'assets/image/logo.png'),
                  const SizedBox(height: 20),
                  Text('Processing...',
                      style: TextStyle(
                          color: ColorManager.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Please wait a moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: ColorManager.white.withOpacity(0.7),
                          fontSize: 14))
                ]);
              } else {
                /* ... Progress UI (0-100%) ... */
                return ValueListenableBuilder<double>(
                    valueListenable: _exportProgressNotifier,
                    builder: (context, progressValue, child) {
                      return Column(mainAxisSize: MainAxisSize.min, children: [
                        Stack(alignment: Alignment.center, children: [
                          SizedBox(
                              width: 90,
                              height: 90,
                              child: CircularProgressIndicator(
                                  value: progressValue,
                                  strokeWidth: 7.0,
                                  backgroundColor: Colors.grey.shade700,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      ColorManager.yellow))),
                          ClipOval(
                              child: Image.asset('assets/image/logo.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) => Icon(
                                      Icons.video_library,
                                      size: 40,
                                      color: Colors.white54)))
                        ]),
                        const SizedBox(height: 20),
                        Text('${(progressValue * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                                color: ColorManager.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Please wait, generating video...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColorManager.white.withOpacity(0.7),
                                fontSize: 14))
                      ]);
                    });
              }
            },
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 15.0, top: 5.0),
          actions: <Widget>[
            ValueListenableBuilder<bool>(
              /* ... Cancel Button UI ... */
              valueListenable: _isFinalizingVideoNotifier,
              builder: (context, isFinalizing, child) {
                if (isFinalizing) return const SizedBox.shrink();
                return TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              color: Colors.redAccent.withOpacity(0.7)))),
                  child: const Text('Cancel Export',
                      style: TextStyle(color: Colors.redAccent, fontSize: 15)),
                  onPressed: () async {
                    zlog(data: "User tapped Cancel Export button.");
                    // Stop game animation first
                    if (gameInitialized) {
                      tacticBoardGame?.performStopAnimation(hardReset: false);
                    }

                    RecordingOutput? cancelledRecOutput;
                    try {
                      zlog(
                          data:
                              "Stopping widget recording due to cancellation.");
                      cancelledRecOutput =
                          await _widgetCaptureXPlusController.stopRecording();
                      zlog(
                          data:
                              "Widget recording stopped on cancel. Output: ${cancelledRecOutput?.filePath}, Success: ${cancelledRecOutput?.success}.");
                    } catch (e, s) {
                      zlog(data: "Error stopping recording on cancel: $e\n$s");
                    } finally {
                      // CRITICAL FIX: Always reset recording state
                      ref
                          .read(animationProvider.notifier)
                          .setRecordingAnimation(isRecording: false);
                    }

                    // Pop with null to signify cancellation to the awaiter of _showVideoExportProgressDialog
                    if (mounted && Navigator.canPop(dialogContext)) {
                      // Use dialogContext directly here
                      Navigator.of(dialogContext).pop(null);
                    }
                    _exportProgressNotifier.value = 0.0; // Reset notifiers
                    _isFinalizingVideoNotifier.value = false;
                    BotToast.showText(text: "Video export cancelled by user.");
                    // The boardProvider state will be reset by the caller (onShare)
                  },
                );
              },
            ),
          ],
        );
      },
    );

    // Cleanup _currentExportDialogContext after showDialog completes (either by pop or future completion)
    _currentExportDialogContext = null;
    _isFinalizingVideoNotifier.value = false; // Ensure this is reset

    // If dialogResult is null here, it means it was popped with null (cancel/error) or an issue occurred.
    // If export was still marked active in provider, onShare will clean it up.
    zlog(data: "showDialog completed. Returning: ${dialogResult?.filePath}");
    return dialogResult;
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    int quarterTurns = bp.boardAngle;

    // if (quarterTurns != previousAngle) {
    //   updateTacticBoardIfNecessary(widget.scene);
    // }

    ref.listen(boardProvider, (prev, current) {
      if (prev?.showFullScreen != current.showFullScreen) {
        if (gameInitialized) {
          tacticBoardGame?.redrawLines();
        }
      }
      if (current.refreshBoard == true) {
        if (gameInitialized) {
          tacticBoardGame?.redrawLines();
        }
        if (mounted) {
          ref.read(boardProvider.notifier).toggleRefreshBoard(false);
        }
      }
      // If animatingObj is cleared externally while dialog is up, dismiss dialog
      if (prev?.animatingObj != null &&
          current.animatingObj == null &&
          _currentExportDialogContext != null) {
        if (mounted && Navigator.canPop(_currentExportDialogContext!)) {
          Navigator.of(_currentExportDialogContext!).pop(null);
          zlog(
              data:
                  "AnimatingObj cleared externally, dismissing export dialog with null.");
        }
      }

      // ========== TRAJECTORY FIX: Re-show after animation ends ==========
      // When animation stops (animatingObj goes from non-null to null),
      // re-show trajectory if we have a selected component and trajectory editing is enabled
      if (prev?.animatingObj != null &&
          current.animatingObj == null &&
          current.selectedItemOnTheBoard != null &&
          current.trajectoryEditingEnabled) {
        // Animation just stopped - re-show trajectory for selected component
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _onComponentSelected(current.selectedItemOnTheBoard!);
          }
        });
      }

      // ========== Trajectory Editing: Listen to selection changes ==========
      if (!mounted) return;

      // Check if selection changed
      final previousSelection = prev?.selectedItemOnTheBoard;
      final currentSelection = current.selectedItemOnTheBoard;

      // Check if trajectory editing enabled state changed
      final prevTrajectoryEnabled = prev?.trajectoryEditingEnabled ?? false;
      final currentTrajectoryEnabled = current.trajectoryEditingEnabled;

      // Show/hide trajectory based on both selection AND trajectoryEditingEnabled
      if (currentSelection != null &&
          currentSelection.id != previousSelection?.id) {
        // Component selected
        if (currentTrajectoryEnabled) {
          _onComponentSelected(currentSelection);
        } else {
          _onSelectionCleared(); // Hide trajectory if editing not enabled
        }
      } else if (previousSelection != null && currentSelection == null) {
        // Selection cleared
        _onSelectionCleared();
      } else if (currentSelection != null &&
          prevTrajectoryEnabled != currentTrajectoryEnabled) {
        // Trajectory editing mode toggled while component selected
        if (currentTrajectoryEnabled) {
          _onComponentSelected(currentSelection);
        } else {
          _onSelectionCleared();
        }
      }
    });
    previousAngle = quarterTurns;

    return DragTarget<FieldItemModel>(
      /* ... (onAcceptWithDetails - Same as before) ... */

      onWillAcceptWithDetails: (data) {
        // When a player/equipment first enters the board, show the grid.
        ref.read(boardProvider.notifier).toggleItemDrag(true);
        return true;
      },
      // --- END ADD ---

      // --- ADD THIS ---
      onLeave: (data) {
        // When the item is dragged back off the board, hide the grid.
        ref.read(boardProvider.notifier).toggleItemDrag(false);
        ref.read(boardProvider.notifier).clearGuides(); // Also clear guides
      },

      onMove: (details) {
        // --- THIS IS THE GUIDE-DRAWING LOGIC (NO SNAPPING) ---
        if (tacticBoardGame == null) return;
        _activeGuides.clear();

        // 1. Get cursor position
        final RenderBox gameScreenBox = context.findRenderObject() as RenderBox;
        final Vector2 gameScreenSize = gameScreenBox.size.toVector2();
        final double gameScreenWidth = gameScreenSize.x;
        final Offset globalGameScreenOffset =
            gameScreenBox.localToGlobal(Offset.zero);
        final Vector2 screenRelativeOffset =
            details.offset.toVector2() - globalGameScreenOffset.toVector2();
        final double dx = screenRelativeOffset.x;
        final double dy = screenRelativeOffset.y;
        final Vector2 cursorPosition = (quarterTurns == 1)
            ? Vector2(dy, gameScreenWidth - dx)
            : screenRelativeOffset;

        // 2. Get "my" (the dragged item's) alignment points
        final Vector2 itemSize = details.data.size ?? Vector2(32.0, 32.0);
        final Vector2 myCenter =
            cursorPosition + (itemSize / 2) - Vector2(10, 10);

        bool didSmartAlign = false;
        final fieldSize = tacticBoardGame!.size;

        // 3. Get other items
        final otherItems = tacticBoardGame!.children
            .where((c) => (c is PlayerComponent || c is EquipmentComponent));

        for (final item in otherItems) {
          if (item is! PositionComponent) continue;

          // Get other item's alignment points (Anchor.center)
          final Vector2 otherCenter = item.position - Vector2(10, 10);

          if ((myCenter.x - otherCenter.x).abs() < _snapTolerance) {
            _activeGuides.add(GuideLine(
                start: Vector2(otherCenter.x, 0),
                end: Vector2(otherCenter.x, fieldSize.y)));
            didSmartAlign = true;
          }

          if ((myCenter.y - otherCenter.y).abs() < _snapTolerance) {
            _activeGuides.add(GuideLine(
                start: Vector2(0, otherCenter.y),
                end: Vector2(fieldSize.x, otherCenter.y)));
            didSmartAlign = true;
          }
        }

        // 4. Update the providers
        ref.read(boardProvider.notifier).updateGuides(_activeGuides);
        ref.read(boardProvider.notifier).toggleItemDrag(!didSmartAlign);
      },

      onAcceptWithDetails: (details) async {
        if (tacticBoardGame == null) return;
        // if (!gameInitialized ||
        //     isBoardBusy(bp) ||
        //     _currentExportDialogContext != null) {
        //   return;
        // }
        // FieldItemModel fieldItemModel = details.data;
        // final RenderBox gameScreenBox = context.findRenderObject() as RenderBox;
        // final Vector2 gameScreenSize = gameScreenBox.size.toVector2();
        // final double gameScreenWidth = gameScreenSize.x;
        // final Offset globalGameScreenOffset =
        //     gameScreenBox.localToGlobal(Offset.zero);
        // final Vector2 screenRelativeOffset =
        //     details.offset.toVector2() - globalGameScreenOffset.toVector2();
        // final double dx = screenRelativeOffset.x;
        // final double dy = screenRelativeOffset.y;
        // Vector2 transformedOffset = (quarterTurns == 1)
        //     ? Vector2(dy, gameScreenWidth - dx)
        //     : screenRelativeOffset;
        // Vector2 actualPosition =
        //     transformedOffset + tacticBoardGame.gameField.position;
        // fieldItemModel.offset = SizeHelper.getBoardRelativeVector(
        //     gameScreenSize: gameScreenSize, actualPosition: actualPosition);
        //
        // if (fieldItemModel is EquipmentModel) {
        //   fieldItemModel =
        //       fieldItemModel.copyWith(id: RandomGenerator.generateId());
        // }
        //
        // await tacticBoardGame.addItem(fieldItemModel);

        // 1. Initial checks to ensure the board is ready to accept items.
        if (!gameInitialized ||
            isBoardBusy(bp) ||
            _currentExportDialogContext != null) {
          return;
        }

        // 2. Get the data for the item that was dropped.
        FieldItemModel fieldItemModel = details.data;

        // 3. [NEW] Get the item's size to calculate its center.
        // We provide a default size in case the model's size is null.
        // You should use the same default you use in your components (e.g., AppSize.s32).
        final Vector2 itemSize = fieldItemModel.size ?? Vector2(32.0, 32.0);

        // 4. Find the position and size of the game widget on the screen.
        final RenderBox gameScreenBox = context.findRenderObject() as RenderBox;
        final Vector2 gameScreenSize = gameScreenBox.size.toVector2();
        final double gameScreenWidth = gameScreenSize.x;
        final Offset globalGameScreenOffset =
            gameScreenBox.localToGlobal(Offset.zero);

        // 5. Calculate the cursor's drop position relative to the game widget's top-left corner.
        final Vector2 screenRelativeOffset =
            details.offset.toVector2() - globalGameScreenOffset.toVector2();
        final double dx = screenRelativeOffset.x;
        final double dy = screenRelativeOffset.y;

        // 6. Determine the cursor's absolute position on the canvas, accounting for board rotation.
        final Vector2 cursorPosition = (quarterTurns == 1)
            ? Vector2(dy, gameScreenWidth - dx)
            : screenRelativeOffset;

        // 7. [NEW FIX] Adjust the position to place the ITEM'S CENTER under the cursor.
        // We do this by subtracting half of the item's width and height.
        final Vector2 centerOffset = itemSize / 2;
        final Vector2 adjustedTargetPosition = cursorPosition + centerOffset;

        // 8. [PREVIOUS FIX] Convert the adjusted absolute position into a relative offset for storage.
        fieldItemModel.offset = SizeHelper.getBoardRelativeVector(
          gameScreenSize: tacticBoardGame!.gameField.size,
          actualPosition:
              adjustedTargetPosition, // Use the new adjusted position
        );

        // 9. If the item is equipment (like a cone), give it a new unique ID.
        if (fieldItemModel is EquipmentModel) {
          fieldItemModel =
              fieldItemModel.copyWith(id: RandomGenerator.generateId());
        }

        // 10. Add the fully configured item to the tactic board.
        await tacticBoardGame?.addItem(fieldItemModel);

        ref.read(boardProvider.notifier).toggleItemDrag(false);
        ref.read(boardProvider.notifier).clearGuides();
      },
      builder: (BuildContext context, List<Object?> candidateData,
          List<dynamic> rejectedData) {
        if (!gameInitialized) {
          return Center(
              child: Text("Field is not initialized. Contact developer!!",
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: ColorManager.white)));
        }
        return tacticBoardGame == null
            ? SizedBox.shrink()
            : RotatedBox(
                quarterTurns: quarterTurns,
                child: Stack(
                  children: [
                    RepaintBoundary(
                        key: gameBoundaryKey,
                        child: WidgetCaptureXPlus(
                            controller: _widgetCaptureXPlusController,
                            childToRecord: Container(
                                padding: EdgeInsets.only(bottom: 0),
                                child: RiverpodAwareGameWidget(
                                    game: tacticBoardGame!,
                                    key: gameWidgetKey)))),
                    // TEST BUTTON - Remove this after testing
                    // Positioned(
                    //   top: 10,
                    //   right: 10,
                    //   child: FloatingActionButton.small(
                    //     backgroundColor: Colors.purple[700],
                    //     onPressed: () => _showMockDeviceWarning(context),
                    //     child: Icon(Icons.bug_report, color: Colors.white),
                    //     tooltip: 'Test Device Warning',
                    //   ),
                    // ),
                    if (isBoardBusy(bp) &&
                        bp.animatingObj != null &&
                        ref.read(animationProvider).selectedAnimationModel !=
                            null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Offstage(
                          offstage: _currentExportDialogContext != null,
                          child: SizedBox(
                            height: 35,
                            child: AnimationControlsWidget(
                              key: ValueKey(
                                  "${bp.animatingObj.hashCode}_${ref.read(animationProvider).selectedAnimationModel!.id}"),
                              animatingObj: bp.animatingObj!,
                              game: tacticBoardGame!,
                              animationModel: ref
                                  .read(animationProvider)
                                  .selectedAnimationModel!
                                  .copyWith(),
                              initialIsPlaying: bp.animatingObj!.isAnimating &&
                                  !bp.animatingObj!.isExporting,
                              initialPaceFactor: 1.0,
                              onExportProgressCallback: (progress) async {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((t) async {
                                  _exportProgressNotifier.value = progress;
                                  if (progress >= 1.0 &&
                                      !_isFinalizingVideoNotifier.value) {
                                    _isFinalizingVideoNotifier.value = true;
                                    zlog(
                                        data:
                                            "Animation playback 100%. Switched to finalizing video state.");
                                    RecordingOutput? recordingOutput;
                                    try {
                                      zlog(
                                          data:
                                              "Stopping widget recording (finalization step).");
                                      recordingOutput =
                                          await _widgetCaptureXPlusController
                                              .stopRecording();
                                      zlog(
                                          data:
                                              "Widget recording stopped. Output: ${recordingOutput?.filePath}, Success: ${recordingOutput?.success}");
                                    } catch (e, s) {
                                      zlog(
                                        data:
                                            "Error stopping widget recording (finalization step): $e\n$s",
                                      );
                                    } finally {
                                      // CRITICAL FIX: Always reset recording state
                                      ref
                                          .read(animationProvider.notifier)
                                          .setRecordingAnimation(
                                              isRecording: false);
                                    }

                                    if (_currentExportDialogContext != null &&
                                        mounted &&
                                        Navigator.canPop(
                                            _currentExportDialogContext!)) {
                                      // This is the crucial pop that returns the result to _showVideoExportProgressDialog's awaiter
                                      Navigator.of(_currentExportDialogContext!)
                                          .pop(recordingOutput);
                                    }
                                    // _isFinalizingVideoNotifier and provider state are reset by the caller of _showVideoExportProgressDialog (onShare)
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      )
                    else if (_currentExportDialogContext == null)
                      Align(
                        /* ... (FormSpeedDialComponent) ... */
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 30,
                          child: FormSpeedDialComponent(
                              tacticBoardGame: tacticBoardGame!,
                              config: widget.config ??
                                  FormSpeedDialConfig(
                                    onShare: () async {
                                      AnimationModel? selectedAnimation = ref
                                          .read(animationProvider)
                                          .selectedAnimationModel;
                                      if (isBoardBusy(bp)) {
                                        BotToast.showText(
                                            text:
                                                "Please wait for the current operation to complete.");
                                        return;
                                      }
                                      if (selectedAnimation == null) {
                                        await AnimationSharer.captureAndShare(
                                            gameBoundaryKey,
                                            context: context,
                                            fileName: FileNameGenerator
                                                .generateZporterCaptureFilename());
                                      } else {
                                        AnimationShareType? type =
                                            await _showShareChoiceDialog(
                                                context, 'Share As');
                                        if (type == AnimationShareType.image) {
                                          await AnimationSharer.captureAndShare(
                                              gameBoundaryKey,
                                              context: context,
                                              fileName: FileNameGenerator
                                                  .generateZporterCaptureFilename());
                                        } else if (type ==
                                            AnimationShareType.video) {
                                          if (!mounted) return;

                                          // Check device capability before starting video recording
                                          final deviceInfo =
                                              await DeviceCapabilityChecker
                                                  .checkDeviceCapabilities();
                                          if (!mounted) return;

                                          // Show warning if device has limitations
                                          final shouldProceed =
                                              await _showDeviceCapabilityWarning(
                                                  context, deviceInfo);
                                          if (!shouldProceed || !mounted) {
                                            // User cancelled due to device warning
                                            return;
                                          }

                                          // 1. Set state to exporting
                                          if (mounted) {
                                            ref
                                                .read(boardProvider.notifier)
                                                .toggleAnimating(
                                                    animatingObj:
                                                        AnimatingObj.export());
                                          }

                                          // 2. Show dialog (which starts recording) and await its result
                                          final RecordingOutput? finalOutput =
                                              await _showVideoExportProgressDialog();
                                          zlog(
                                              data:
                                                  "Awaited _showVideoExportProgressDialog. Final Output: ${finalOutput?.filePath}, Success: ${finalOutput?.success}");

                                          // 3. Dialog is closed, now reset board state fully
                                          if (mounted) {
                                            ref
                                                .read(boardProvider.notifier)
                                                .toggleAnimating(
                                                    animatingObj: null);
                                          }

                                          // 4. Process the result
                                          if (finalOutput != null &&
                                              finalOutput.success &&
                                              finalOutput.filePath != null) {
                                            try {
                                              AnimationSharer.shareImageFile(
                                                context: context,
                                                finalOutput.filePath!,
                                                // text: Platform.isIOS
                                                //     ? null
                                                //     : "Zporter Football Pad Animation",
                                                // title: Platform.isIOS
                                                //     ? "Zporter Football Pad Animation"
                                                //     : null,
                                                text: Platform.isIOS
                                                    ? null
                                                    : "${finalOutput.filePath!.split("/").last}",
                                                title: Platform.isIOS
                                                    ? "${finalOutput.filePath!.split("/").last}"
                                                    : null,
                                                subject:
                                                    "Check out this from my Zporter Football Pad",
                                              );
                                              zlog(
                                                  data:
                                                      "Video ready for sharing: ${finalOutput.filePath}");
                                            } catch (e) {}

                                            // TODO: Share/Save finalOutput.filePath
                                            // Example: await AnimationSharer.shareFile(finalOutput.filePath!);
                                          } else if (finalOutput != null &&
                                              !finalOutput.success) {
                                            BotToast.showText(
                                                text:
                                                    "Video export failed: ${finalOutput.errorMessage ?? 'Unknown error.'}");
                                          } else {
                                            // finalOutput is null
                                            BotToast.showText(
                                                text:
                                                    "Video export was cancelled or did not complete.");
                                          }
                                        }
                                      }
                                    },
                                    onDownload: () async {
                                      AnimationModel? selectedAnimation = ref
                                          .read(animationProvider)
                                          .selectedAnimationModel;
                                      if (isBoardBusy(bp)) {
                                        BotToast.showText(
                                            text:
                                                "Please wait for the current operation to complete.");
                                        return;
                                      }
                                      if (selectedAnimation == null) {
                                        await AnimationDownloader
                                            .captureAndDownload(gameBoundaryKey,
                                                fileName: FileNameGenerator
                                                    .generateZporterCaptureFilename());
                                      } else {
                                        AnimationShareType? type =
                                            await _showShareChoiceDialog(
                                                context, 'Download As');
                                        if (type == AnimationShareType.image) {
                                          await AnimationDownloader
                                              .captureAndDownload(
                                                  gameBoundaryKey,
                                                  fileName: FileNameGenerator
                                                      .generateZporterCaptureFilename());
                                        } else if (type ==
                                            AnimationShareType.video) {
                                          if (!mounted) return;

                                          // Check device capability before starting video recording
                                          final deviceInfo =
                                              await DeviceCapabilityChecker
                                                  .checkDeviceCapabilities();
                                          if (!mounted) return;

                                          // Show warning if device has limitations
                                          final shouldProceed =
                                              await _showDeviceCapabilityWarning(
                                                  context, deviceInfo);
                                          if (!shouldProceed || !mounted) {
                                            // User cancelled due to device warning
                                            return;
                                          }

                                          // 1. Set state to exporting
                                          if (mounted) {
                                            ref
                                                .read(boardProvider.notifier)
                                                .toggleAnimating(
                                                    animatingObj:
                                                        AnimatingObj.export());
                                          }

                                          // 2. Show dialog (which starts recording) and await its result
                                          final RecordingOutput? finalOutput =
                                              await _showVideoExportProgressDialog();
                                          zlog(
                                              data:
                                                  "Awaited _showVideoExportProgressDialog. Final Output: ${finalOutput?.filePath}, Success: ${finalOutput?.success}");

                                          // 3. Dialog is closed, now reset board state fully
                                          if (mounted) {
                                            ref
                                                .read(boardProvider.notifier)
                                                .toggleAnimating(
                                                    animatingObj: null);
                                          }

                                          // 4. Process the result
                                          if (finalOutput != null &&
                                              finalOutput.success &&
                                              finalOutput.filePath != null) {
                                            AnimationDownloader.downloadFile(
                                                finalOutput.filePath!,
                                                text:
                                                    "${FileNameGenerator.generateZporterCaptureFilename()}.mp4");
                                            zlog(
                                                data:
                                                    "Video ready for sharing: ${finalOutput.filePath}");
                                            // TODO: Share/Save finalOutput.filePath
                                            // Example: await AnimationSharer.shareFile(finalOutput.filePath!);
                                          } else if (finalOutput != null &&
                                              !finalOutput.success) {
                                            BotToast.showText(
                                                text:
                                                    "Video export failed: ${finalOutput.errorMessage ?? 'Unknown error.'}");
                                          } else {
                                            // finalOutput is null
                                            BotToast.showText(
                                                text:
                                                    "Video export was cancelled or did not complete.");
                                          }
                                        }
                                      }
                                    },
                                  )),
                        ),
                      ),
                    // Trajectory editing toolbar removed - now in design toolbar
                    if (bp.animatingObj?.isAnimating == true &&
                        !bp.animatingObj!.isExporting &&
                        _currentExportDialogContext == null &&
                        !widget.isPlayerMode)
                      Positioned(
                        /* ... (Close button for normal animation) ... */
                        top: 10.0,
                        right: 10.0,
                        child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              splashColor: Colors.white12,
                              onTap: () {
                                tacticBoardGame?.performStopAnimation();
                                if (mounted) {
                                  ref
                                      .read(boardProvider.notifier)
                                      .toggleAnimating(animatingObj: null);
                                }
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: closeButtonBackgroundColor,
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.close,
                                      color: closeButtonColor, size: 26.0)),
                            )),
                      ),
                  ],
                ),
              );
      },
    );
  }

  Future<AnimationShareType?> _showShareChoiceDialog(
      BuildContext context, String title) async {
    /* ... (Same as before) ... */
    return await showDialog<AnimationShareType>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return SimpleDialog(
              backgroundColor: ColorManager.black,
              title: Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: ColorManager.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              children: <Widget>[
                SimpleDialogOption(
                    onPressed: () =>
                        Navigator.pop(dialogContext, AnimationShareType.image),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(children: [
                          Icon(Icons.image_outlined,
                              color: ColorManager.white.withOpacity(0.8)),
                          const SizedBox(width: 10),
                          Text('Image (Current Scene)',
                              style: TextStyle(
                                  color: ColorManager.white, fontSize: 16))
                        ]))),
                SimpleDialogOption(
                    onPressed: () =>
                        Navigator.pop(dialogContext, AnimationShareType.video),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(children: [
                          Icon(Icons.videocam_outlined,
                              color: ColorManager.white.withOpacity(0.8)),
                          const SizedBox(width: 10),
                          Text('Video/GIF (Animation)',
                              style: TextStyle(
                                  color: ColorManager.white, fontSize: 16))
                        ]))),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(
                        color: ColorManager.grey.withOpacity(0.3), height: 1)),
                SimpleDialogOption(
                    onPressed: () => Navigator.pop(dialogContext, null),
                    child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: ColorManager.grey, fontSize: 14)))))
              ]);
        });
  }

  /// TEST METHOD - Shows mock device warning dialogs for testing UI
  /// Remove this method after testing is complete
  Future<void> _showMockDeviceWarning(BuildContext context) async {
    // Show a menu to choose which mock scenario to test
    final scenario = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Choose Test Scenario'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'low_ram'),
            child: Text('Low RAM Device (iPad Air 2)'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'old_os'),
            child: Text('Old OS Device (iOS 11)'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'critical'),
            child: Text('Critical Device (Low RAM + Old OS)'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'medium'),
            child: Text('Medium Device (Should not warn)'),
          ),
        ],
      ),
    );

    if (scenario == null || !mounted) return;

    // Create mock DeviceInfo based on scenario
    DeviceInfo mockDeviceInfo;

    switch (scenario) {
      case 'low_ram':
        mockDeviceInfo = DeviceInfo(
          capability: DeviceCapability.low,
          osVersion: 'iOS 14.0',
          deviceModel: 'iPad Air 2',
          isLowRAM: true,
          isOldOS: false,
          warnings: [
            'Your device has limited memory (1.5 GB RAM).',
            'Video recording may cause the app to slow down or crash.',
          ],
          recommendations: [
            'Consider using image export instead for better reliability.',
            'If proceeding with video, expect longer processing times.',
          ],
        );
        break;

      case 'old_os':
        mockDeviceInfo = DeviceInfo(
          capability: DeviceCapability.low,
          osVersion: 'iOS 11.4',
          deviceModel: 'iPad (5th generation)',
          isLowRAM: false,
          isOldOS: true,
          warnings: [
            'Your device is running an older iOS version (iOS 11.4).',
            'Video recording may not be fully optimized.',
          ],
          recommendations: [
            'Consider updating your device OS for better performance.',
            'Some features may not work as expected.',
          ],
        );
        break;

      case 'critical':
        mockDeviceInfo = DeviceInfo(
          capability: DeviceCapability.low,
          osVersion: 'iOS 10.3',
          deviceModel: 'iPad mini 2',
          isLowRAM: true,
          isOldOS: true,
          warnings: [
            'Your device has very limited resources (1 GB RAM, iOS 10.3).',
            'Video recording may fail or cause the app to crash.',
          ],
          recommendations: [
            'We strongly recommend using image export instead.',
            'Video recording is not recommended on this device.',
          ],
        );
        break;

      case 'medium':
        mockDeviceInfo = DeviceInfo(
          capability: DeviceCapability.medium,
          osVersion: 'iOS 13.0',
          deviceModel: 'iPad (6th generation)',
          isLowRAM: false,
          isOldOS: false,
          warnings: [],
          recommendations: [],
        );
        break;

      default:
        return;
    }

    // Show the actual warning dialog
    final shouldProceed =
        await _showDeviceCapabilityWarning(context, mockDeviceInfo);

    // Show result
    if (mounted) {
      BotToast.showText(
        text: shouldProceed
            ? '✅ User chose to proceed anyway'
            : '❌ User cancelled',
        duration: Duration(seconds: 2),
      );
    }
  }

  /// Shows a warning dialog about device capabilities for video recording
  /// Returns true if user wants to proceed despite warnings, false otherwise
  Future<bool> _showDeviceCapabilityWarning(
      BuildContext context, DeviceInfo deviceInfo) async {
    if (!deviceInfo.shouldShowWarning) {
      // Device is capable, no warning needed
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final isCritical = deviceInfo.capability == DeviceCapability.low &&
            (deviceInfo.isLowRAM || deviceInfo.isOldOS);

        return AlertDialog(
          backgroundColor: ColorManager.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Row(
            children: [
              Icon(
                isCritical ? Icons.error_outline : Icons.warning_amber_outlined,
                color: isCritical ? Colors.red[400] : Colors.orange[400],
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Device Performance Warning',
                  style: TextStyle(
                    color: ColorManager.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (deviceInfo.warningMessage.isNotEmpty)
                Text(
                  deviceInfo.warningMessage,
                  style: TextStyle(
                    color: ColorManager.white.withOpacity(0.9),
                    fontSize: 15,
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorManager.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Info:',
                      style: TextStyle(
                        color: ColorManager.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (deviceInfo.deviceModel.isNotEmpty)
                      Text(
                        '• Device: ${deviceInfo.deviceModel}',
                        style: TextStyle(
                          color: ColorManager.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    if (deviceInfo.osVersion.isNotEmpty)
                      Text(
                        '• OS Version: ${deviceInfo.osVersion}',
                        style: TextStyle(
                          color: ColorManager.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    if (deviceInfo.isLowRAM)
                      Text(
                        '• Low Memory Detected',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (deviceInfo.isOldOS)
                      Text(
                        '• Older OS Version',
                        style: TextStyle(
                          color: Colors.orange[300],
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              if (deviceInfo.recommendationMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  deviceInfo.recommendationMessage,
                  style: TextStyle(
                    color: ColorManager.white.withOpacity(0.85),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: ColorManager.grey,
                  fontSize: 15,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(
                backgroundColor:
                    isCritical ? Colors.red[700] : Colors.orange[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Proceed Anyway',
                  style: TextStyle(
                    color: ColorManager.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
