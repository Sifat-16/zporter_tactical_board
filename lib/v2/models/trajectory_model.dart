import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:zporter_tactical_board/v2/core/json_helpers.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';

// =============================================================================
// ControlPoint
// =============================================================================

/// A control point on a trajectory path. Immutable.
/// Matches V1 [ControlPoint] field-for-field.
class ControlPointV2 {
  final String id;
  final Offset position;
  final ControlPointType type;
  final double tension;

  ControlPointV2({
    String? id,
    required this.position,
    this.type = ControlPointType.smooth,
    this.tension = 0.5,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': {'x': position.dx, 'y': position.dy},
      'type': type.name,
      'tension': tension,
    };
  }

  factory ControlPointV2.fromJson(Map<String, dynamic> json) {
    final posJson = json['position'] as Map<String, dynamic>?;
    final position = posJson != null
        ? Offset(
            (posJson['x'] as num?)?.toDouble() ?? 0.0,
            (posJson['y'] as num?)?.toDouble() ?? 0.0,
          )
        : Offset.zero;

    return ControlPointV2(
      id: json['id'] as String?,
      position: position,
      type: ControlPointType.fromString(json['type'] as String?),
      tension: JsonHelpers.toDouble(json['tension']) ?? 0.5,
    );
  }

  ControlPointV2 copyWith({
    String? id,
    Offset? position,
    ControlPointType? type,
    double? tension,
  }) {
    return ControlPointV2(
      id: id ?? this.id,
      position: position ?? this.position,
      type: type ?? this.type,
      tension: tension ?? this.tension,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ControlPointV2) return false;
    return id == other.id &&
        position == other.position &&
        type == other.type &&
        tension == other.tension;
  }

  @override
  int get hashCode => Object.hash(id, position, type, tension);
}

// =============================================================================
// TrajectoryPath
// =============================================================================

/// A trajectory path for a single component's movement between scenes.
/// Immutable. Matches V1 [TrajectoryPathModel] field-for-field.
class TrajectoryPathV2 {
  final String id;
  final PathType pathType;
  final TrajectoryType trajectoryType;
  final TrajectoryLineStyle lineStyle;
  final List<ControlPointV2> controlPoints;
  final bool enabled;
  final Color pathColor;
  final double pathWidth;
  final bool showControlPoints;
  final double smoothness;

  TrajectoryPathV2({
    String? id,
    this.pathType = PathType.straight,
    this.trajectoryType = TrajectoryType.running,
    this.lineStyle = TrajectoryLineStyle.solid,
    List<ControlPointV2>? controlPoints,
    this.enabled = false,
    Color? pathColor,
    this.pathWidth = 2.0,
    this.showControlPoints = true,
    this.smoothness = 0.5,
  })  : id = id ?? const Uuid().v4(),
        controlPoints =
            List.unmodifiable(controlPoints ?? const <ControlPointV2>[]),
        pathColor = pathColor ?? const Color(0xFFFFC107);

  bool get isCustomPath => pathType != PathType.straight && enabled;
  bool get hasControlPoints => controlPoints.isNotEmpty;

  double get speedMultiplier => trajectoryType.speedMultiplier;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pathType': pathType.name,
      'trajectoryType': trajectoryType.name,
      'lineStyle': lineStyle.name,
      'controlPoints': controlPoints.map((cp) => cp.toJson()).toList(),
      'enabled': enabled,
      'pathColor': JsonHelpers.colorToJson(pathColor),
      'pathWidth': pathWidth,
      'showControlPoints': showControlPoints,
      'smoothness': smoothness,
    };
  }

  factory TrajectoryPathV2.fromJson(Map<String, dynamic> json) {
    final cpList = json['controlPoints'] as List?;
    final controlPoints = cpList
            ?.whereType<Map<String, dynamic>>()
            .map((cp) => ControlPointV2.fromJson(cp))
            .toList() ??
        <ControlPointV2>[];

    return TrajectoryPathV2(
      id: json['id'] as String?,
      pathType: PathType.fromString(json['pathType'] as String?),
      trajectoryType:
          TrajectoryType.fromString(json['trajectoryType'] as String?),
      lineStyle:
          TrajectoryLineStyle.fromString(json['lineStyle'] as String?),
      controlPoints: controlPoints,
      enabled: json['enabled'] as bool? ?? false,
      pathColor: JsonHelpers.colorFromJson(json['pathColor']) ??
          const Color(0xFFFFC107),
      pathWidth: JsonHelpers.toDouble(json['pathWidth']) ?? 2.0,
      showControlPoints: json['showControlPoints'] as bool? ?? true,
      smoothness: JsonHelpers.toDouble(json['smoothness']) ?? 0.5,
    );
  }

  TrajectoryPathV2 copyWith({
    String? id,
    PathType? pathType,
    TrajectoryType? trajectoryType,
    TrajectoryLineStyle? lineStyle,
    List<ControlPointV2>? controlPoints,
    bool? enabled,
    Color? pathColor,
    double? pathWidth,
    bool? showControlPoints,
    double? smoothness,
  }) {
    return TrajectoryPathV2(
      id: id ?? this.id,
      pathType: pathType ?? this.pathType,
      trajectoryType: trajectoryType ?? this.trajectoryType,
      lineStyle: lineStyle ?? this.lineStyle,
      controlPoints: controlPoints ?? this.controlPoints,
      enabled: enabled ?? this.enabled,
      pathColor: pathColor ?? this.pathColor,
      pathWidth: pathWidth ?? this.pathWidth,
      showControlPoints: showControlPoints ?? this.showControlPoints,
      smoothness: smoothness ?? this.smoothness,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TrajectoryPathV2) return false;
    return id == other.id &&
        pathType == other.pathType &&
        trajectoryType == other.trajectoryType &&
        lineStyle == other.lineStyle &&
        listEquals(controlPoints, other.controlPoints) &&
        enabled == other.enabled &&
        pathColor == other.pathColor &&
        pathWidth == other.pathWidth &&
        showControlPoints == other.showControlPoints &&
        smoothness == other.smoothness;
  }

  @override
  int get hashCode => Object.hash(
        id,
        pathType,
        trajectoryType,
        lineStyle,
        Object.hashAll(controlPoints),
        enabled,
        pathColor,
        pathWidth,
        showControlPoints,
        smoothness,
      );
}

// =============================================================================
// TrajectoryData — container for all component trajectories in a scene
// =============================================================================

/// Container mapping component IDs to their trajectory paths.
/// Immutable. Matches V1 [AnimationTrajectoryData].
class TrajectoryDataV2 {
  final Map<String, TrajectoryPathV2> componentTrajectories;

  TrajectoryDataV2({
    Map<String, TrajectoryPathV2>? componentTrajectories,
  }) : componentTrajectories =
            Map.unmodifiable(componentTrajectories ?? const {});

  factory TrajectoryDataV2.empty() => TrajectoryDataV2();

  TrajectoryPathV2? getTrajectory(String componentId) =>
      componentTrajectories[componentId];

  bool hasTrajectory(String componentId) =>
      componentTrajectories.containsKey(componentId) &&
      componentTrajectories[componentId]!.isCustomPath;

  List<String> get componentsWithTrajectories =>
      componentTrajectories.keys.toList();

  bool get hasAnyTrajectories => componentTrajectories.values
      .any((t) => t.isCustomPath);

  TrajectoryDataV2 setTrajectory(
      String componentId, TrajectoryPathV2 trajectory) {
    final updated = Map<String, TrajectoryPathV2>.from(componentTrajectories);
    updated[componentId] = trajectory;
    return TrajectoryDataV2(componentTrajectories: updated);
  }

  TrajectoryDataV2 removeTrajectory(String componentId) {
    final updated = Map<String, TrajectoryPathV2>.from(componentTrajectories);
    updated.remove(componentId);
    return TrajectoryDataV2(componentTrajectories: updated);
  }

  Map<String, dynamic> toJson() {
    return {
      'componentTrajectories': componentTrajectories.map(
        (id, trajectory) => MapEntry(id, trajectory.toJson()),
      ),
    };
  }

  factory TrajectoryDataV2.fromJson(Map<String, dynamic> json) {
    final trajectoriesJson =
        json['componentTrajectories'] as Map<String, dynamic>?;
    if (trajectoriesJson == null) return TrajectoryDataV2.empty();

    final trajectories = <String, TrajectoryPathV2>{};
    for (final entry in trajectoriesJson.entries) {
      if (entry.value is Map<String, dynamic>) {
        trajectories[entry.key] =
            TrajectoryPathV2.fromJson(entry.value as Map<String, dynamic>);
      }
    }
    return TrajectoryDataV2(componentTrajectories: trajectories);
  }

  TrajectoryDataV2 copyWith({
    Map<String, TrajectoryPathV2>? componentTrajectories,
  }) {
    return TrajectoryDataV2(
      componentTrajectories:
          componentTrajectories ?? this.componentTrajectories,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TrajectoryDataV2) return false;
    return mapEquals(componentTrajectories, other.componentTrajectories);
  }

  @override
  int get hashCode => Object.hashAll(
        componentTrajectories.entries
            .map((e) => Object.hash(e.key, e.value)),
      );
}
