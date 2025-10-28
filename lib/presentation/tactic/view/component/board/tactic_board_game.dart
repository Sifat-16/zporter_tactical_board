import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/mixin/animation_playback_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/smart_guide_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game_animation.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/draggable_circle_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/scaling_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/text_field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/circle_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart'; // Assuming LineModel, FreeDrawModel are here or in models
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/polygon_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/square_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/trajectory_editor_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_trajectory_data.dart';
import 'package:zporter_tactical_board/data/animation/model/trajectory_path_model.dart';

// Assuming GameField is defined in 'game_field.dart' as per your import
import 'game_field.dart';
import 'grid_component.dart';
import 'mixin/board_riverpod_integration.dart';
import 'mixin/drawing_input_handler.dart';
import 'mixin/item_management.dart';
import 'mixin/layering_management.dart'; // Make sure this import points to the correct file

String? _boardComparator;

// --- Base Abstract Class (Unchanged) ---
abstract class TacticBoardGame extends FlameGame
    with
        DragCallbacks,
        TapCallbacks,
        RiverpodGameMixin,
        AnimationPlaybackControls {
  late GameField gameField;
  bool isAnimating = false;
  late DrawingBoardComponent drawingBoard;
  addItem(FieldItemModel item, {bool save = true});
  late BuildContext context;

  /// Trajectory editor manager - must be accessible from abstract class for field components
  TrajectoryEditorManager? get trajectoryManager;
}

// ---- The Refactored TacticBoard Class ----
class TacticBoard extends TacticBoardGame
    with
        DrawingInputHandler, // Provides drawing state and drag handlers
        ItemManagement, // Provides addItem, _checkAndRemoveComponent, _copyItem
        LayeringManagement, // Provides layering helpers and _moveUp/DownElement
        BoardRiverpodIntegration, // Provides setupBoardListeners
        AnimationPlaybackMixin {
  late final GridComponent grid;
  late final SmartGuideComponent smartGuide;
  AnimationItemModel? scene;
  bool saveToDb;
  BuildContext myContext;
  Function(AnimationItemModel?)? onSceneSave;

  /// Trajectory editor manager for animation path editing (PRO feature)
  /// Only initialized when editing multi-scene animations
  TrajectoryEditorManager? _trajectoryManager;

  @override
  TrajectoryEditorManager? get trajectoryManager => _trajectoryManager;

  TacticBoard(
      {required this.scene,
      this.saveToDb = true,
      this.onSceneSave,
      required this.myContext});

  // --- Variables for the 1-second timer ---
  double _timerAccumulator = 0.0; // Accumulates delta time
  final double _checkInterval = 1.0; // Desired interval in seconds

  // --- Variable to store the previous state for comparison ---
  // Ensure this is a member variable if used across update calls

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    setupBoardListeners(); // Call the listener setup method from the mixin
    _initiateField(); // Field setup specific to this game
    context = myContext;
  }

  // In class TacticBoard
  _initiateField() {
    gameField = GameField(
      size: Vector2(size.x - 22.5, size.y - 22.5),
      // Use the provider for the initial color too, for consistency.
      initialColor: ref.read(boardProvider).boardColor,
    );

    // --- ADD THIS BLOCK ---
    // 1. Create the grid
    grid = GridComponent(); // You can adjust 50.0
    // 2. Set its size to match the field
    grid.size = gameField.size;
    // 3. Hide it by default
    grid.isHidden = true;
    // 4. Add it AS A CHILD of the gameField
    gameField.add(grid);
    // --- END ADD ---

    // --- ADD THIS BLOCK ---
    // 1. Create the smart guide component
    smartGuide = SmartGuideComponent();
    // 2. Set its size to match the field
    smartGuide.size = gameField.size;
    // 4. Add it AS A CHILD of the gameField
    gameField.add(smartGuide);

    WidgetsBinding.instance.addPostFrameCallback((t) {
      if (!isMounted) return; // Add mounted check
      ref.read(boardProvider.notifier).updateFieldSize(size: gameField.size);
      add(gameField);

      // This is the correct logic: Get items from the provider state,
      // which initializeFromScene already prepared for us.
      final currentItems = ref.read(boardProvider.notifier).allFieldItems();

      addInitialItems(currentItems);
    });
  }

  @override
  Color backgroundColor() {
    return ColorManager.grey;
  }

  @override
  bool get debugMode => false; // Unchanged

  @override
  void onTapDown(TapDownEvent info) {
    if (isAnimating) return;
    super.onTapDown(info);
    final tapPosition = info.localPosition; // Position in game coordinates

    final components = componentsAtPoint(tapPosition);

    if (components.isNotEmpty) {
      if (!components.any((t) => t is FieldComponent) &&
          !components.any((t) => t is DrawingBoardComponent) &&
          !components.any((t) => t is DraggableRectangleComponent) &&
          !components.any((t) => t is LineDrawerComponentV2) &&
          !components.any((t) => t is CircleShapeDrawerComponent) &&
          !components.any((t) => t is CircleRadiusDraggableDot) &&
          !components.any((t) => t is SquareShapeDrawerComponent) &&
          !components.any((t) => t is SquareRadiusDraggableDot) &&
          !components.any((t) => t is ScalingHandle) &&
          !components.any((t) => t is PolygonShapeDrawerComponent) &&
          !components.any((t) => t is PolygonVertexDotComponent) &&
          !components.any((t) => t is TextFieldComponent) &&
          ref.read(lineProvider).activeForm is! PolygonShapeModel) {
        bool deselect = true;

        try {
          WidgetsBinding.instance.addPostFrameCallback((t) {
            FieldItemModel? f = ref.read(boardProvider).selectedItemOnTheBoard;
            if (f is FreeDrawModelV2) {
              deselect = false;
            }
          });
        } catch (e) {}

        if (deselect) {
          ref
              .read(boardProvider.notifier)
              .toggleSelectItemEvent(fieldItemModel: null);
        }

        zlog(data: "Tapped components ${components}");
      } else {
        zlog(data: "Animate to design tab called");

        /// detect the trash mode is on or not, if on then remove that widget

        bool isTrashModeActive = false;
        try {
          WidgetsBinding.instance.addPostFrameCallback((t) {
            isTrashModeActive = ref.read(lineProvider).isTrashActive;
          });
        } catch (e) {}

        // if (isTrashModeActive) {
        //   // ref.read(boardProvider.notifier).removeElement();
        // } else {
        //   ref.read(boardProvider.notifier).animateToDesignTab();
        // }
      }
    }
  }

  @override
  void update(double dt) {
    _timerAccumulator += dt;

    if (_timerAccumulator >= _checkInterval) {
      WidgetsBinding.instance.addPostFrameCallback((t) {
        // CRITICAL FIX: Skip auto-save during undo/redo operations OR video recording
        if (ref.read(animationProvider).isPerformingUndo ||
            ref.read(animationProvider).skipHistorySave ||
            ref.read(animationProvider).isRecordingAnimation) {
          zlog(
              data:
                  "Skipping auto-save during undo/redo or recording operation");
          _timerAccumulator -= _checkInterval;
          return;
        }

        String current = _getCurrentBoardStateString(); // <-- USE HELPER

        if (_boardComparator == null) {
          _boardComparator = current;
        } else {
          if (_boardComparator != current) {
            _boardComparator = current;
            updateDatabase();
          }
        }
        _timerAccumulator -= _checkInterval;
      });
    }
    super.update(dt);
  }

  updateDatabase() {
    if (!isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((t) async {
        ref
            .read(animationProvider.notifier)
            .toggleLoadingSave(showLoading: true);
        try {
          await ref
              .read(animationProvider.notifier)
              .updateDatabaseOnChange(saveToDb: saveToDb)
              .then((a) {
            zlog(
                data:
                    "After save coming animation item model ${a?.toJson()} - $saveToDb");
            // REMOVED: History is now saved BEFORE the update in updateDatabaseOnChange
            // This prevents the race condition
            onSceneSave?.call(a);
          });
        } catch (e) {
          zlog(data: "Error updating database: $e");
        }

        ref
            .read(animationProvider.notifier)
            .toggleLoadingSave(showLoading: false);
      });
    } else {
      ref
          .read(animationProvider.notifier)
          .toggleLoadingSave(showLoading: false);
      zlog(data: "Is animating");
    }
  }

  void redrawLines() {
    WidgetsBinding.instance.addPostFrameCallback((t) async {
      try {
        List<FieldItemModel> items =
            ref.read(boardProvider.notifier).allFieldItems();
        zlog(data: "items detected ${ref.exists(boardProvider)}", show: true);

        resetItems(items);
      } catch (e) {}
    });
  }

  void forceUpdateComparator() {
    try {
      _boardComparator = _getCurrentBoardStateString(); // <-- USE HELPER
      _timerAccumulator = 0.0;
    } catch (e) {
      zlog(data: "Error forcing comparator update: $e");
    }
  }

  String _getCurrentBoardStateString() {
    try {
      List<FieldItemModel> items =
          ref.read(boardProvider.notifier).onAnimationSave();
      String current = items.map((e) => e.toJson()).join(
            ',',
          );
      current =
          "$current,${ref.read(animationProvider.notifier).getFieldColor().toARGB32()},";

      // IMPORTANT: Include trajectory data in the state string for auto-save detection
      final currentScene = ref.read(animationProvider).selectedScene;
      if (currentScene?.trajectoryData != null) {
        final trajectoryJson = currentScene!.trajectoryData!.toJson();
        current = "$current,trajectory:$trajectoryJson";
      }

      return current;
    } catch (e) {
      // This can happen if providers aren't ready. Default to a "clean" state string.
      zlog(data: "Error getting current board state string: $e");
      return _boardComparator ??
          ""; // Return the last known comparator if error
    }
  }

  bool get isDirty {
    // If comparator hasn't been set yet, assume it's not dirty.
    if (_boardComparator == null) {
      return false;
    }
    // Compare the last saved state to the current state.
    return _boardComparator != _getCurrentBoardStateString();
  }

  // ========== Trajectory Editor Management ==========

  /// Initialize trajectory editor for animation path editing
  /// Call this when entering animation mode with multiple scenes
  Future<void> initializeTrajectoryEditor() async {
    try {
      final animationState = ref.read(animationProvider);
      final currentScene = animationState.selectedScene;
      final animationModel = animationState.selectedAnimationModel;

      if (currentScene == null || animationModel == null) return;

      final scenes = animationModel.animationScenes;
      final currentIndex = scenes.indexWhere((s) => s.id == currentScene.id);

      // Don't initialize if this is the first scene (no previous scene for trajectory)
      if (currentIndex <= 0) {
        await cleanupTrajectoryEditor();
        return;
      }

      final previousScene = scenes[currentIndex - 1];

      // Remove existing manager if present
      if (_trajectoryManager != null) {
        world.remove(_trajectoryManager!);
        _trajectoryManager = null;
      }

      // Create new manager
      _trajectoryManager = TrajectoryEditorManager(
        currentScene: currentScene,
        previousScene: previousScene,
        onTrajectoryChanged: _handleTrajectoryChanged,
        priority: 5,
      );

      await world.add(_trajectoryManager!);
      zlog(data: "Trajectory editor initialized for scene ${currentScene.id}");
    } catch (e, s) {
      zlog(data: "Error initializing trajectory editor: $e\n$s");
    }
  }

  /// Handle trajectory changes from the editor
  void _handleTrajectoryChanged(
    String componentId,
    TrajectoryPathModel trajectory,
  ) {
    try {
      final animationState = ref.read(animationProvider);
      final currentScene = animationState.selectedScene;
      final animationModel = animationState.selectedAnimationModel;

      if (currentScene == null || animationModel == null) {
        return;
      }

      // Get or create trajectory data
      final trajectoryData =
          currentScene.trajectoryData ?? AnimationTrajectoryData();

      // Update trajectory for this component
      trajectoryData.setTrajectory(componentId, trajectory);

      // Update scene with new trajectory data
      final updatedScene = currentScene.copyWith(
        trajectoryData: trajectoryData,
      );

      // Find the scene index in the animation
      final sceneIndex = animationModel.animationScenes
          .indexWhere((s) => s.id == currentScene.id);

      if (sceneIndex != -1) {
        // Update the scene in the animation model
        animationModel.animationScenes[sceneIndex] = updatedScene;
      }

      // Update state with the new scene
      ref.read(animationProvider.notifier).selectScene(scene: updatedScene);

      // CRITICAL: Update the trajectory manager's scene reference
      // so it has the latest trajectory data for subsequent operations
      if (_trajectoryManager != null) {
        final scenes = animationModel.animationScenes;
        final previousSceneForManager =
            sceneIndex > 0 ? scenes[sceneIndex - 1] : null;
        _trajectoryManager!.updateScenes(
          newCurrentScene: updatedScene,
          newPreviousScene: previousSceneForManager,
        );
      }

      // IMPORTANT: Save to database
      if (onSceneSave != null) {
        onSceneSave!(updatedScene);
      }

      zlog(
          data:
              "Trajectory updated for component $componentId in scene ${currentScene.id}");
      zlog(data: "  Control points: ${trajectory.controlPoints.length}");
      zlog(data: "  Enabled: ${trajectory.enabled}");
      zlog(
          data:
              "  Positions: ${trajectory.controlPoints.map((cp) => cp.position).toList()}");
    } catch (e, s) {
      zlog(data: "Error handling trajectory change: $e\n$s");
    }
  }

  /// Clean up trajectory editor when exiting animation mode or switching scenes
  Future<void> cleanupTrajectoryEditor() async {
    if (_trajectoryManager != null) {
      await _trajectoryManager!.hideTrajectory();
      world.remove(_trajectoryManager!);
      _trajectoryManager = null;
      zlog(data: "Trajectory editor cleaned up");
    }
  }

  /// Show trajectory editing UI for a specific component
  Future<void> showTrajectoryForComponent({
    required String componentId,
    required FieldItemModel currentItem,
  }) async {
    // Always ensure trajectory manager is initialized with fresh data
    if (trajectoryManager == null) {
      await initializeTrajectoryEditor();
    }

    // If still null after initialization, can't show trajectory
    if (trajectoryManager == null) {
      print('⚠️ Cannot show trajectory - manager not initialized');
      return;
    }

    await trajectoryManager!.showTrajectoryForComponent(
      componentId: componentId,
      currentItem: currentItem,
    );
  }

  /// Hide trajectory editing UI
  Future<void> hideTrajectory() async {
    await trajectoryManager?.hideTrajectory();
  }

  /// Check if trajectory editing is currently active
  bool get isTrajectoryEditingActive =>
      trajectoryManager?.isEditingTrajectory ?? false;

  /// Get current trajectory for selected component
  TrajectoryPathModel? get currentTrajectory {
    if (trajectoryManager == null) return null;
    final selectedId = trajectoryManager!.selectedComponentId;
    if (selectedId == null) return null;

    final currentScene = ref.read(animationProvider).selectedScene;
    return currentScene?.trajectoryData?.getTrajectory(selectedId);
  }

  /// Add a control point to the current trajectory
  Future<void> addTrajectoryControlPoint() async {
    await trajectoryManager?.addControlPoint();
  }

  /// Remove the last control point from the current trajectory
  Future<void> removeTrajectoryControlPoint() async {
    await trajectoryManager?.removeControlPoint();
  }

  /// Update the smoothness of the current trajectory (0.0 to 1.0)
  void updateTrajectorySmoothness(double smoothness) {
    trajectoryManager?.updateSmoothness(smoothness);
  }
}
