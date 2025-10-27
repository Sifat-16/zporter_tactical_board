import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/helper/trajectory_calculator.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_trajectory_data.dart';
import 'package:zporter_tactical_board/data/animation/model/trajectory_path_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/control_point_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/ghost_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/trajectory_path_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';

/// Manager for trajectory path editing in animation mode
///
/// Responsibilities:
/// - Creates ghost components to show previous scene positions
/// - Creates trajectory path components to visualize curved paths
/// - Creates control point components for editing
/// - Handles control point dragging and updates
/// - Syncs changes back to animation model
///
/// Usage:
/// 1. Create manager when entering animation edit mode
/// 2. Call showTrajectoryForComponent() when a component is selected
/// 3. Call hideTrajectory() when component is deselected
/// 4. Manager automatically updates trajectory data on drag
class TrajectoryEditorManager extends Component
    with HasGameReference<TacticBoardGame> {
  /// Current animation scene being edited
  final AnimationItemModel currentScene;

  /// Previous animation scene (for ghost positioning)
  final AnimationItemModel? previousScene;

  /// Callback when trajectory data changes
  final Function(String componentId, TrajectoryPathModel trajectory)
      onTrajectoryChanged;

  /// Currently displayed components
  GhostComponent? _ghostComponent;
  TrajectoryPathComponent? _pathComponent;
  final List<ControlPointComponent> _controlPointComponents = [];

  /// Currently selected component ID
  String? _selectedComponentId;

  TrajectoryEditorManager({
    required this.currentScene,
    required this.previousScene,
    required this.onTrajectoryChanged,
    super.priority = 5,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  /// Show trajectory editing UI for a specific component
  ///
  /// [componentId]: The ID of the player/equipment component
  /// [currentPosition]: Current position in this scene
  Future<void> showTrajectoryForComponent({
    required String componentId,
    required FieldItemModel currentItem,
  }) async {
    print('🔵 TrajectoryEditorManager.showTrajectoryForComponent called');
    print('   Component ID: $componentId');
    print('   Current item offset: ${currentItem.offset}');
    print('   Previous scene: ${previousScene != null ? "✅" : "❌"}');

    // ALWAYS clear existing trajectory UI first, even for the same component
    await hideTrajectory();

    _selectedComponentId = componentId;

    // Find previous scene position
    if (previousScene == null) {
      print('   ❌ No previous scene - cannot edit trajectory');
      return;
    }

    final previousItem = _findItemInScene(previousScene!, componentId);
    print('   Previous item found: ${previousItem != null ? "✅" : "❌"}');

    if (previousItem == null) {
      print('   ❌ Component didn\'t exist in previous scene');
      return;
    }

    // Validate positions
    if (previousItem.offset == null || currentItem.offset == null) {
      print('   ❌ Invalid item offsets');
      return;
    }

    print('   Previous item offset: ${previousItem.offset}');

    // Convert logical coordinates (0-1 range) to screen coordinates (pixels)
    final fieldSize = game.gameField.size;
    final previousScreenPos = SizeHelper.getBoardActualVector(
      gameScreenSize: fieldSize,
      actualPosition: previousItem.offset ?? Vector2.zero(),
    );
    final currentScreenPos = SizeHelper.getBoardActualVector(
      gameScreenSize: fieldSize,
      actualPosition: currentItem.offset ?? Vector2.zero(),
    );

    print('   Previous screen pos: $previousScreenPos');
    print('   Current screen pos: $currentScreenPos');

    // Get or create trajectory data (in logical coordinates)
    final trajectoryData =
        currentScene.trajectoryData ?? AnimationTrajectoryData();
    TrajectoryPathModel trajectory =
        trajectoryData.getTrajectory(componentId) ??
            TrajectoryPathModel(
              id: componentId,
              pathType: PathType.catmullRom,
              enabled: true, // Enable custom path by default when editing
              controlPoints: TrajectoryCalculator.generateDefaultControlPoints(
                start: previousItem.offset ?? Vector2.zero(),
                end: currentItem.offset ?? Vector2.zero(),
              ),
            );

    print('   Trajectory enabled: ${trajectory.enabled}');
    print('   Trajectory control points: ${trajectory.controlPoints.length}');
    print('   Start position (logical): ${previousItem.offset}');
    print('   End position (logical): ${currentItem.offset}');

    // Validate control points
    for (var i = 0; i < trajectory.controlPoints.length; i++) {
      final cp = trajectory.controlPoints[i];
      if (cp.position.x.isNaN ||
          cp.position.y.isNaN ||
          cp.position.x.isInfinite ||
          cp.position.y.isInfinite) {
        print(
            '   ⚠️ Invalid control point $i: ${cp.position}, regenerating...');
        trajectory = TrajectoryPathModel(
          id: componentId,
          pathType: PathType.catmullRom,
          enabled: true,
          controlPoints: TrajectoryCalculator.generateDefaultControlPoints(
            start: previousItem.offset!,
            end: currentItem.offset!,
          ),
        );
        break;
      }
    }

    print('   Creating ghost component...');

    // Create ghost component (pass original item, it will handle conversion)
    _ghostComponent = GhostComponent(
      previousSceneItem: previousItem,
      priority: 100, // HIGH priority to render on top
    );
    await game.add(_ghostComponent!); // Add directly to game, not world
    print('   ✅ Ghost component added');
    print('   Ghost final position: ${_ghostComponent!.position}');

    // Create path component (pass logical coordinates, it will convert)
    print('   Creating path component...');
    _pathComponent = TrajectoryPathComponent(
      pathModel: trajectory,
      startPosition: previousItem.offset ?? Vector2.zero(),
      endPosition: currentItem.offset ?? Vector2.zero(),
      isSelected: true,
      priority: 99, // HIGH priority
    );
    await game.add(_pathComponent!); // Add directly to game, not world
    print('   ✅ Path component added');

    // Create control point components (use logical coordinates)
    print('   Creating control point components...');
    for (final controlPoint in trajectory.controlPoints) {
      final cpComponent = ControlPointComponent(
        controlPoint: controlPoint,
        onDrag: _onControlPointDrag,
        onTap: _onControlPointTap,
        isSelected: false,
        priority: 101, // HIGHEST priority
      );
      _controlPointComponents.add(cpComponent);
      await game.add(cpComponent); // Add directly to game, not world
    }
    print('   ✅ All ${_controlPointComponents.length} control points added');
    print('   ✅ Trajectory visualization complete');
  }

  /// Hide all trajectory editing UI
  Future<void> hideTrajectory() async {
    // Remove ghost (check if it has a parent before removing)
    if (_ghostComponent != null) {
      if (_ghostComponent!.isMounted && _ghostComponent!.parent != null) {
        game.remove(_ghostComponent!);
      }
      _ghostComponent = null;
    }

    // Remove path (check if it has a parent before removing)
    if (_pathComponent != null) {
      if (_pathComponent!.isMounted && _pathComponent!.parent != null) {
        game.remove(_pathComponent!);
      }
      _pathComponent = null;
    }

    // Remove control points (check each one)
    for (final cp in _controlPointComponents) {
      if (cp.isMounted && cp.parent != null) {
        game.remove(cp);
      }
    }
    _controlPointComponents.clear();

    _selectedComponentId = null;
  }

  /// Handle control point drag
  void _onControlPointDrag(String controlPointId, Vector2 newPosition) {
    if (_selectedComponentId == null || _pathComponent == null) return;

    print('🎯 Control point dragged: $controlPointId');
    print('   New logical position: $newPosition');

    // Update the control point position in the model
    final trajectory = _pathComponent!.pathModel;
    final cpIndex =
        trajectory.controlPoints.indexWhere((cp) => cp.id == controlPointId);
    if (cpIndex == -1) {
      print('   ❌ Control point not found');
      return;
    }

    print('   Old position: ${trajectory.controlPoints[cpIndex].position}');

    // Update position
    trajectory.controlPoints[cpIndex] = ControlPoint(
      id: controlPointId,
      position: newPosition,
      type: trajectory.controlPoints[cpIndex].type,
      tension: trajectory.controlPoints[cpIndex].tension,
    );

    print('   ✅ Control point updated');
    print(
        '   All control points: ${trajectory.controlPoints.map((cp) => cp.position).toList()}');

    // Recalculate path
    _pathComponent!.updatePath();
    print('   ✅ Path recalculated');

    // Notify parent
    print('   📡 Notifying parent about trajectory change...');
    onTrajectoryChanged(_selectedComponentId!, trajectory);
    print('   ✅ Parent notified');
  }

  /// Handle control point tap (cycle through types)
  void _onControlPointTap(String controlPointId) {
    if (_selectedComponentId == null || _pathComponent == null) return;

    final trajectory = _pathComponent!.pathModel;
    final cpIndex =
        trajectory.controlPoints.indexWhere((cp) => cp.id == controlPointId);
    if (cpIndex == -1) return;

    // Cycle through control point types
    final currentType = trajectory.controlPoints[cpIndex].type;
    final nextType = _getNextControlPointType(currentType);

    // Update type
    trajectory.controlPoints[cpIndex] = ControlPoint(
      id: controlPointId,
      position: trajectory.controlPoints[cpIndex].position,
      type: nextType,
      tension: trajectory.controlPoints[cpIndex].tension,
    );

    // Recalculate path
    _pathComponent!.updatePath();

    // Notify parent
    onTrajectoryChanged(_selectedComponentId!, trajectory);
  }

  /// Get next control point type in cycle
  ControlPointType _getNextControlPointType(ControlPointType current) {
    switch (current) {
      case ControlPointType.sharp:
        return ControlPointType.smooth;
      case ControlPointType.smooth:
        return ControlPointType.symmetric;
      case ControlPointType.symmetric:
        return ControlPointType.sharp;
    }
  }

  /// Add a new control point at the midpoint of the path
  Future<void> addControlPoint() async {
    if (_selectedComponentId == null || _pathComponent == null) return;

    final trajectory = _pathComponent!.pathModel;
    final pathPoints = _pathComponent!.pathPoints;

    if (pathPoints == null || pathPoints.isEmpty) return;

    // Add at midpoint
    final midIndex = pathPoints.length ~/ 2;
    final midPosition = pathPoints[midIndex];

    final newControlPoint = ControlPoint(
      id: 'cp_${DateTime.now().millisecondsSinceEpoch}',
      position: midPosition,
      type: ControlPointType.smooth,
      tension: 0.5,
    );

    // Insert at appropriate position (after first control point)
    if (trajectory.controlPoints.length > 1) {
      trajectory.controlPoints.insert(1, newControlPoint);
    } else {
      trajectory.controlPoints.add(newControlPoint);
    }

    // Refresh UI
    await showTrajectoryForComponent(
      componentId: _selectedComponentId!,
      currentItem: _findItemInScene(currentScene, _selectedComponentId!)!,
    );

    // Notify parent
    onTrajectoryChanged(_selectedComponentId!, trajectory);
  }

  /// Remove the last control point
  Future<void> removeControlPoint() async {
    if (_selectedComponentId == null || _pathComponent == null) return;

    final trajectory = _pathComponent!.pathModel;

    if (trajectory.controlPoints.length <= 2) {
      // Can't remove - need at least 2 points
      return;
    }

    // Remove last control point
    trajectory.controlPoints.removeLast();

    // Refresh UI
    await showTrajectoryForComponent(
      componentId: _selectedComponentId!,
      currentItem: _findItemInScene(currentScene, _selectedComponentId!)!,
    );

    // Notify parent
    onTrajectoryChanged(_selectedComponentId!, trajectory);
  }

  /// Toggle trajectory enabled/disabled
  void toggleTrajectoryEnabled() {
    if (_selectedComponentId == null || _pathComponent == null) return;

    final trajectory = _pathComponent!.pathModel;
    final updatedTrajectory = TrajectoryPathModel(
      id: trajectory.id,
      pathType: trajectory.pathType,
      controlPoints: trajectory.controlPoints,
      enabled: !trajectory.enabled,
      pathColor: trajectory.pathColor,
      pathWidth: trajectory.pathWidth,
      showControlPoints: trajectory.showControlPoints,
      smoothness: trajectory.smoothness,
    );

    // Notify parent
    onTrajectoryChanged(_selectedComponentId!, updatedTrajectory);
  }

  /// Update trajectory path color
  void updatePathColor(Color color) {
    if (_selectedComponentId == null || _pathComponent == null) return;

    final trajectory = _pathComponent!.pathModel;
    final updatedTrajectory = TrajectoryPathModel(
      id: trajectory.id,
      pathType: trajectory.pathType,
      controlPoints: trajectory.controlPoints,
      enabled: trajectory.enabled,
      pathColor: color,
      pathWidth: trajectory.pathWidth,
      showControlPoints: trajectory.showControlPoints,
      smoothness: trajectory.smoothness,
    );

    // Notify parent
    onTrajectoryChanged(_selectedComponentId!, updatedTrajectory);
  }

  /// Update smoothness (0.0 to 1.0)
  void updateSmoothness(double smoothness) {
    if (_selectedComponentId == null || _pathComponent == null) return;

    final trajectory = _pathComponent!.pathModel;
    final updatedTrajectory = TrajectoryPathModel(
      id: trajectory.id,
      pathType: trajectory.pathType,
      controlPoints: trajectory.controlPoints,
      enabled: trajectory.enabled,
      pathColor: trajectory.pathColor,
      pathWidth: trajectory.pathWidth,
      showControlPoints: trajectory.showControlPoints,
      smoothness: smoothness,
    );

    // Recalculate path with new smoothness
    _pathComponent!.updatePath(newPathModel: updatedTrajectory);

    // Notify parent
    onTrajectoryChanged(_selectedComponentId!, updatedTrajectory);
  }

  /// Helper: Find item in scene by component ID
  FieldItemModel? _findItemInScene(
      AnimationItemModel scene, String componentId) {
    // Search through all components
    for (final component in scene.components) {
      if (component.id == componentId) {
        return component;
      }
    }
    return null;
  }

  /// Check if trajectory editing is active
  bool get isEditingTrajectory => _selectedComponentId != null;

  /// Get currently selected component ID
  String? get selectedComponentId => _selectedComponentId;
}
