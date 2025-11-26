/// Example: How to integrate trajectory editing into your animation editor
///
/// This file demonstrates the integration pattern for Phase 2 components.
/// Use this as a reference when implementing Phase 3 (Design Toolbar Integration).

import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_trajectory_data.dart';
import 'package:zporter_tactical_board/data/animation/model/trajectory_path_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/trajectory_components.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';

/// Example integration in animation editor
class TrajectoryEditingIntegrationExample {
  // Reference to the Flame game
  final TacticBoardGame game;

  // Current animation state
  final List<AnimationItemModel> scenes;
  int currentSceneIndex = 0;

  // Trajectory editor manager
  TrajectoryEditorManager? _trajectoryManager;

  // Currently selected component
  String? _selectedComponentId;

  TrajectoryEditingIntegrationExample({
    required this.game,
    required this.scenes,
  });

  /// STEP 1: Initialize trajectory manager when entering animation mode
  Future<void> enterAnimationEditMode() async {
    final currentScene = scenes[currentSceneIndex];
    final previousScene =
        currentSceneIndex > 0 ? scenes[currentSceneIndex - 1] : null;

    // Create manager
    _trajectoryManager = TrajectoryEditorManager(
      currentScene: currentScene,
      previousScene: previousScene,
      onTrajectoryChanged: _handleTrajectoryChanged,
      priority: 5,
    );

    // Add to game world
    await game.world.add(_trajectoryManager!);
  }

  /// STEP 2: Show trajectory UI when user selects a component
  Future<void> onComponentSelected(FieldItemModel component) async {
    if (_trajectoryManager == null) return;

    _selectedComponentId = component.id;

    // Show trajectory editing UI
    await _trajectoryManager!.showTrajectoryForComponent(
      componentId: component.id,
      currentItem: component,
    );
  }

  /// STEP 3: Hide trajectory UI when selection is cleared
  Future<void> onSelectionCleared() async {
    if (_trajectoryManager == null) return;

    await _trajectoryManager!.hideTrajectory();
    _selectedComponentId = null;
  }

  /// STEP 4: Handle trajectory changes and update animation model
  void _handleTrajectoryChanged(
    String componentId,
    TrajectoryPathModel trajectory,
  ) {
    final currentScene = scenes[currentSceneIndex];

    // Get or create trajectory data
    final trajectoryData =
        currentScene.trajectoryData ?? AnimationTrajectoryData();

    // Update trajectory for this component
    trajectoryData.setTrajectory(componentId, trajectory);

    // Update scene with new trajectory data
    final updatedScene = currentScene.copyWith(
      trajectoryData: trajectoryData,
    );

    // Replace scene in list
    scenes[currentSceneIndex] = updatedScene;

    // TODO: Persist to Firestore
    // _saveAnimationToFirestore();

    // Notify UI to refresh
    // setState(() {});
  }

  /// STEP 5: Clean up when exiting animation mode
  Future<void> exitAnimationEditMode() async {
    if (_trajectoryManager != null) {
      await _trajectoryManager!.hideTrajectory();
      game.world.remove(_trajectoryManager!);
      _trajectoryManager = null;
    }
  }

  // ========== UI ACTION HANDLERS ==========

  /// Add control point (called from toolbar button)
  Future<void> onAddControlPoint() async {
    await _trajectoryManager?.addControlPoint();
  }

  /// Remove control point (called from toolbar button)
  Future<void> onRemoveControlPoint() async {
    await _trajectoryManager?.removeControlPoint();
  }

  /// Toggle trajectory enabled (called from toolbar toggle)
  void onToggleTrajectoryEnabled() {
    _trajectoryManager?.toggleTrajectoryEnabled();
  }

  /// Update path color (called from toolbar color picker)
  void onPathColorChanged(Color color) {
    _trajectoryManager?.updatePathColor(color);
  }

  /// Update smoothness (called from toolbar slider)
  void onSmoothnessChanged(double smoothness) {
    _trajectoryManager?.updateSmoothness(smoothness);
  }

  // ========== SCENE NAVIGATION ==========

  /// Switch to different scene (need to recreate manager)
  Future<void> goToScene(int sceneIndex) async {
    if (sceneIndex < 0 || sceneIndex >= scenes.length) return;

    // Clean up current manager
    if (_trajectoryManager != null) {
      await _trajectoryManager!.hideTrajectory();
      game.world.remove(_trajectoryManager!);
    }

    // Update index
    currentSceneIndex = sceneIndex;

    // Create new manager for this scene
    await enterAnimationEditMode();

    // If component was selected, show trajectory for new scene
    if (_selectedComponentId != null) {
      final component = _findComponentInCurrentScene(_selectedComponentId!);
      if (component != null) {
        await onComponentSelected(component);
      }
    }
  }

  // ========== HELPER METHODS ==========

  /// Find component in current scene by ID
  FieldItemModel? _findComponentInCurrentScene(String componentId) {
    final currentScene = scenes[currentSceneIndex];
    for (final component in currentScene.components) {
      if (component.id == componentId) {
        return component;
      }
    }
    return null;
  }

  /// Check if trajectory editing is active
  bool get isTrajectoryEditingActive =>
      _trajectoryManager?.isEditingTrajectory ?? false;

  /// Get current trajectory for selected component
  TrajectoryPathModel? get currentTrajectory {
    if (_selectedComponentId == null) return null;

    final currentScene = scenes[currentSceneIndex];
    return currentScene.trajectoryData?.getTrajectory(_selectedComponentId!);
  }
}

// ========== EXAMPLE UI INTEGRATION ==========

/// Example widget showing how to add trajectory controls to design toolbar
class AnimationPathToolbarSection extends StatelessWidget {
  final TrajectoryEditingIntegrationExample editor;

  const AnimationPathToolbarSection({
    super.key,
    required this.editor,
  });

  @override
  Widget build(BuildContext context) {
    final trajectory = editor.currentTrajectory;
    final isEnabled = trajectory?.enabled ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Animation Path',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Enable toggle
        SwitchListTile(
          title: const Text('Enable Custom Path'),
          value: isEnabled,
          onChanged: (value) {
            editor.onToggleTrajectoryEnabled();
          },
        ),

        if (isEnabled) ...[
          // Path type (future: dropdown to choose straight/catmullRom/bezier)
          const ListTile(
            title: Text('Path Type'),
            trailing: Text('Curved'),
          ),

          // Smoothness slider
          ListTile(
            title: const Text('Smoothness'),
            subtitle: Slider(
              value: trajectory?.smoothness ?? 0.5,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              label: '${((trajectory?.smoothness ?? 0.5) * 100).toInt()}%',
              onChanged: (value) {
                editor.onSmoothnessChanged(value);
              },
            ),
          ),

          // Color picker
          ListTile(
            title: const Text('Path Color'),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: trajectory?.pathColor ?? Colors.yellow,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onTap: () {
              // Show color picker dialog
              // showColorPicker(context, editor.onPathColorChanged);
            },
          ),

          // Control point buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => editor.onAddControlPoint(),
                icon: const Icon(Icons.add),
                label: const Text('Add Point'),
              ),
              ElevatedButton.icon(
                onPressed: () => editor.onRemoveControlPoint(),
                icon: const Icon(Icons.remove),
                label: const Text('Remove Point'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ========== USAGE EXAMPLE ==========

/// Example: How to use in your main animation editor
/*
class AnimationEditorScreen extends StatefulWidget {
  @override
  State<AnimationEditorScreen> createState() => _AnimationEditorScreenState();
}

class _AnimationEditorScreenState extends State<AnimationEditorScreen> {
  late TrajectoryEditingIntegrationExample trajectoryEditor;
  
  @override
  void initState() {
    super.initState();
    
    trajectoryEditor = TrajectoryEditingIntegrationExample(
      game: tacticBoardGame,
      scenes: animationScenes,
    );
    
    // Initialize when ready
    trajectoryEditor.enterAnimationEditMode();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left: Game canvas
          Expanded(
            flex: 3,
            child: GameWidget(game: tacticBoardGame),
          ),
          
          // Right: Design toolbar with trajectory controls
          Expanded(
            flex: 1,
            child: AnimationPathToolbarSection(
              editor: trajectoryEditor,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    trajectoryEditor.exitAnimationEditMode();
    super.dispose();
  }
}
*/
