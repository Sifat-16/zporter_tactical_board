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

  /// Currently selected control point ID (for removal)
  String? _selectedControlPointId;

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
      print('   ℹ️  This means the component was added in the current scene,');
      print('   ℹ️  so there is no trajectory to edit (no previous position).');
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
    for (var i = 0; i < trajectory.controlPoints.length; i++) {
      final controlPoint = trajectory.controlPoints[i];
      final isSelected = controlPoint.id == _selectedControlPointId;

      print('     CP $i: ID=${controlPoint.id}, selected=$isSelected');

      final cpComponent = ControlPointComponent(
        controlPoint: controlPoint,
        onDrag: _onControlPointDrag,
        onTap: _onControlPointTap,
        isSelected: isSelected, // Restore selection
        priority: 101, // HIGHEST priority
      );
      _controlPointComponents.add(cpComponent);
      await game.add(cpComponent); // Add directly to game, not world
    }
    print('   ✅ All ${_controlPointComponents.length} control points added');
    if (_selectedControlPointId != null) {
      print('   🔴 Currently selected control point: $_selectedControlPointId');
    }
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
    _selectedControlPointId = null; // Clear control point selection
  }

  /// Update trajectory endpoint when component is dragged
  /// Called in real-time during component drag to update trajectory path
  void updateTrajectoryEndpoint(Vector2 newEndPosition) {
    if (_pathComponent == null || _selectedComponentId == null) return;

    print('🎯 Updating trajectory endpoint to: $newEndPosition');

    // Recalculate the path with the new endpoint
    _pathComponent!.updatePath(newEndPosition: newEndPosition);
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

  /// Handle control point tap (cycle through types and mark as selected)
  void _onControlPointTap(String controlPointId) {
    if (_selectedComponentId == null || _pathComponent == null) return;

    // Track which control point was selected
    final previousSelection = _selectedControlPointId;
    _selectedControlPointId = controlPointId;
    print('🔵 Control point tapped: $controlPointId');
    print('   Previous selection: $previousSelection');

    // Update visual selection state for all control points
    for (final cpComponent in _controlPointComponents) {
      final shouldBeSelected = (cpComponent.controlPoint.id == controlPointId);
      cpComponent.setSelected(
          shouldBeSelected); // Use setSelected method to trigger visual update
      if (shouldBeSelected) {
        print(
            '   ✅ Marked control point ${cpComponent.controlPoint.id} as SELECTED (RED)');
      }
    }

    // Only cycle types if clicking the same control point twice
    if (previousSelection == controlPointId) {
      print('   Same control point clicked twice - cycling type');
      final trajectory = _pathComponent!.pathModel;
      final cpIndex =
          trajectory.controlPoints.indexWhere((cp) => cp.id == controlPointId);
      if (cpIndex == -1) return;

      // Cycle through control point types
      final currentType = trajectory.controlPoints[cpIndex].type;
      final nextType = _getNextControlPointType(currentType);

      print('   Cycling type from $currentType to $nextType');

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
    } else {
      print('   Different control point clicked - just selecting (RED)');
    }
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

    // Add at midpoint - pathPoints are in screen coordinates (pixels)
    final midIndex = pathPoints.length ~/ 2;
    final midPositionScreen = pathPoints[midIndex];

    // Convert screen coordinates to logical coordinates (0.0-1.0)
    final fieldSize = game.gameField.size;
    final midPositionLogical = SizeHelper.getBoardRelativeVector(
      gameScreenSize: fieldSize,
      actualPosition: midPositionScreen,
    );

    print('🔵 Adding control point at midpoint:');
    print('   Screen position: $midPositionScreen');
    print('   Logical position: $midPositionLogical');
    print('   Field size: $fieldSize');

    final newControlPoint = ControlPoint(
      id: 'cp_${DateTime.now().millisecondsSinceEpoch}',
      position: midPositionLogical, // Use logical coordinates
      type: ControlPointType.smooth,
      tension: 0.5,
    );

    // Create a new list with the new control point
    final updatedControlPoints =
        List<ControlPoint>.from(trajectory.controlPoints);

    // Insert at appropriate position (after first control point)
    if (updatedControlPoints.length > 1) {
      updatedControlPoints.insert(1, newControlPoint);
    } else {
      updatedControlPoints.add(newControlPoint);
    }

    print('   Total control points: ${updatedControlPoints.length}');

    // Create a new trajectory object with updated control points
    final updatedTrajectory = TrajectoryPathModel(
      id: trajectory.id,
      pathType: trajectory.pathType,
      controlPoints: updatedControlPoints,
      enabled: trajectory.enabled,
      pathColor: trajectory.pathColor,
      pathWidth: trajectory.pathWidth,
      showControlPoints: trajectory.showControlPoints,
      smoothness: trajectory.smoothness,
    );

    // Notify parent FIRST so the data is saved
    onTrajectoryChanged(_selectedComponentId!, updatedTrajectory);

    // Then refresh UI with the updated trajectory
    await showTrajectoryForComponent(
      componentId: _selectedComponentId!,
      currentItem: _findItemInScene(currentScene, _selectedComponentId!)!,
    );
  }

  /// Remove the selected control point (or last one if none selected)
  Future<void> removeControlPoint() async {
    if (_selectedComponentId == null || _pathComponent == null) return;

    final trajectory = _pathComponent!.pathModel;

    if (trajectory.controlPoints.length <= 2) {
      // Can't remove - need at least 2 points (start and end)
      print('⚠️ Cannot remove control point: need at least 2 points');
      return;
    }

    print('🔴 REMOVE CONTROL POINT called');
    print('   Selected control point ID: $_selectedControlPointId');
    print('   Current control points (${trajectory.controlPoints.length}):');
    for (var i = 0; i < trajectory.controlPoints.length; i++) {
      print(
          '     $i: ID=${trajectory.controlPoints[i].id}, pos=${trajectory.controlPoints[i].position}');
    }

    // Create a new list without the selected control point
    List<ControlPoint> updatedControlPoints;

    if (_selectedControlPointId != null) {
      final cpIndex = trajectory.controlPoints
          .indexWhere((cp) => cp.id == _selectedControlPointId);

      if (cpIndex != -1) {
        print('   ✅ Found selected control point at index $cpIndex');
        print(
            '   🗑️  Removing control point: ${trajectory.controlPoints[cpIndex].id}');

        // Create new list WITHOUT the selected control point
        updatedControlPoints =
            List<ControlPoint>.from(trajectory.controlPoints);
        updatedControlPoints.removeAt(cpIndex);
        _selectedControlPointId = null; // Clear selection
      } else {
        print('   ⚠️ Selected control point not found, removing last one');
        updatedControlPoints =
            List<ControlPoint>.from(trajectory.controlPoints);
        updatedControlPoints.removeLast();
      }
    } else {
      // No selection, remove the last control point
      print('   ℹ️ No control point selected, removing last one');
      updatedControlPoints = List<ControlPoint>.from(trajectory.controlPoints);
      updatedControlPoints.removeLast();
    }

    print('   Remaining control points: ${updatedControlPoints.length}');
    for (var i = 0; i < updatedControlPoints.length; i++) {
      print(
          '     $i: ID=${updatedControlPoints[i].id}, pos=${updatedControlPoints[i].position}');
    }

    // IMPORTANT: Create a new trajectory object with updated control points
    final updatedTrajectory = TrajectoryPathModel(
      id: trajectory.id,
      pathType: trajectory.pathType,
      controlPoints: updatedControlPoints,
      enabled: trajectory.enabled,
      pathColor: trajectory.pathColor,
      pathWidth: trajectory.pathWidth,
      showControlPoints: trajectory.showControlPoints,
      smoothness: trajectory.smoothness,
    );

    // Notify parent FIRST so the data is saved
    onTrajectoryChanged(_selectedComponentId!, updatedTrajectory);

    // Then refresh UI with the updated trajectory
    await showTrajectoryForComponent(
      componentId: _selectedComponentId!,
      currentItem: _findItemInScene(currentScene, _selectedComponentId!)!,
    );
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
