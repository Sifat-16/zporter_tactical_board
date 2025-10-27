import 'package:zporter_tactical_board/data/animation/model/trajectory_path_model.dart';

/// Stores trajectory paths for components transitioning between animation scenes
///
/// Each AnimationItemModel (scene) can have trajectories for its components
/// that define how they animate from the previous scene to this scene
///
/// Example:
/// Scene 1: Player at (100, 100)
/// Scene 2: Player at (500, 500) with curved trajectory
///
/// Scene 2's AnimationTrajectoryData would contain:
/// {
///   "player_id_123": TrajectoryPathModel(curved path with control points)
/// }
class AnimationTrajectoryData {
  /// Map of component ID to its trajectory path
  /// Key: Component ID (player.id, equipment.id, etc.)
  /// Value: Trajectory path model defining the animation path
  final Map<String, TrajectoryPathModel> componentTrajectories;

  AnimationTrajectoryData({
    Map<String, TrajectoryPathModel>? componentTrajectories,
  }) : componentTrajectories = componentTrajectories ?? {};

  /// Get trajectory for a specific component
  TrajectoryPathModel? getTrajectory(String componentId) {
    return componentTrajectories[componentId];
  }

  /// Set trajectory for a specific component
  void setTrajectory(String componentId, TrajectoryPathModel trajectory) {
    componentTrajectories[componentId] = trajectory;
  }

  /// Remove trajectory for a specific component
  void removeTrajectory(String componentId) {
    componentTrajectories.remove(componentId);
  }

  /// Check if a component has a custom trajectory
  bool hasTrajectory(String componentId) {
    return componentTrajectories.containsKey(componentId) &&
        componentTrajectories[componentId]!.isCustomPath;
  }

  /// Get all component IDs that have trajectories
  List<String> get componentsWithTrajectories =>
      componentTrajectories.keys.toList();

  /// Check if any components have custom trajectories
  bool get hasAnyTrajectories =>
      componentTrajectories.values.any((t) => t.isCustomPath);

  /// Create a copy with optional field updates
  AnimationTrajectoryData copyWith({
    Map<String, TrajectoryPathModel>? componentTrajectories,
  }) {
    return AnimationTrajectoryData(
      componentTrajectories: componentTrajectories ??
          this.componentTrajectories.map(
                (key, value) => MapEntry(key, value.clone()),
              ),
    );
  }

  /// Convert to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'componentTrajectories': componentTrajectories.map(
        (componentId, trajectory) => MapEntry(componentId, trajectory.toJson()),
      ),
    };
  }

  /// Create from JSON data
  factory AnimationTrajectoryData.fromJson(Map<String, dynamic> json) {
    final trajectoriesJson =
        json['componentTrajectories'] as Map<String, dynamic>?;

    final componentTrajectories = <String, TrajectoryPathModel>{};

    if (trajectoriesJson != null) {
      trajectoriesJson.forEach((componentId, trajectoryJson) {
        componentTrajectories[componentId] = TrajectoryPathModel.fromJson(
            trajectoryJson as Map<String, dynamic>);
      });
    }

    return AnimationTrajectoryData(
      componentTrajectories: componentTrajectories,
    );
  }

  /// Create a clone
  AnimationTrajectoryData clone() {
    return AnimationTrajectoryData(
      componentTrajectories: componentTrajectories.map(
        (key, value) => MapEntry(key, value.clone()),
      ),
    );
  }

  /// Create empty trajectory data
  factory AnimationTrajectoryData.empty() {
    return AnimationTrajectoryData(componentTrajectories: {});
  }
}
