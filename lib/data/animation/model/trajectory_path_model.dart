import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';

/// Defines the type of path trajectory for animation
enum PathType {
  /// Straight line from start to end (default, free tier)
  straight,

  /// Smooth curve through control points using Catmull-Rom spline (PRO feature)
  catmullRom,

  /// Cubic Bezier curve with control handles (PRO feature - future)
  bezier,
}

/// Defines the behavior of a control point
enum ControlPointType {
  /// Sharp corner with hard angle transition
  sharp,

  /// Smooth curve with gradual transition
  smooth,

  /// Symmetric smooth curve (equal on both sides)
  symmetric,
}

/// Represents a single control point on a trajectory path
class ControlPoint {
  /// Unique identifier for this control point
  final String id;

  /// Position of the control point on the board
  final Vector2 position;

  /// Type of curve behavior at this point
  final ControlPointType type;

  /// Smoothness/tension factor (0.0 = sharp, 1.0 = maximum smooth)
  /// Used for fine-tuning curve behavior
  final double tension;

  ControlPoint({
    String? id,
    required this.position,
    this.type = ControlPointType.smooth,
    this.tension = 0.5,
  }) : id = id ?? RandomGenerator.generateId();

  /// Create a copy with optional field updates
  ControlPoint copyWith({
    String? id,
    Vector2? position,
    ControlPointType? type,
    double? tension,
  }) {
    return ControlPoint(
      id: id ?? this.id,
      position: position ?? this.position.clone(),
      type: type ?? this.type,
      tension: tension ?? this.tension,
    );
  }

  /// Convert to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': {'x': position.x, 'y': position.y},
      'type': type.name,
      'tension': tension,
    };
  }

  /// Create from JSON data
  factory ControlPoint.fromJson(Map<String, dynamic> json) {
    final positionJson = json['position'] as Map<String, dynamic>;
    return ControlPoint(
      id: json['id'] as String,
      position: Vector2(
        (positionJson['x'] as num).toDouble(),
        (positionJson['y'] as num).toDouble(),
      ),
      type: ControlPointType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ControlPointType.smooth,
      ),
      tension: (json['tension'] as num?)?.toDouble() ?? 0.5,
    );
  }

  /// Create a clone of this control point
  ControlPoint clone() {
    return ControlPoint(
      id: id,
      position: position.clone(),
      type: type,
      tension: tension,
    );
  }
}

/// Defines a custom trajectory path for component animation
///
/// PRO FEATURE: Custom paths are only available for pro users
/// Free users always use straight line paths
class TrajectoryPathModel {
  /// Unique identifier for this trajectory
  final String id;

  /// Type of path (straight, curved, bezier)
  final PathType pathType;

  /// List of control points that define the path shape
  /// Empty for straight paths, populated for curved paths
  final List<ControlPoint> controlPoints;

  /// Whether this custom path is enabled
  /// If false, falls back to straight line
  final bool enabled;

  /// Visual color of the path in editor mode
  final Color pathColor;

  /// Width of the path line in pixels
  final double pathWidth;

  /// Whether to show control points in editor mode
  /// Hidden during animation playback
  final bool showControlPoints;

  /// Smoothness factor for the entire path (0.0 to 1.0)
  /// 0.0 = sharp corners, 1.0 = maximum smoothness
  final double smoothness;

  TrajectoryPathModel({
    String? id,
    this.pathType = PathType.straight,
    List<ControlPoint>? controlPoints,
    this.enabled = false,
    Color? pathColor,
    this.pathWidth = 2.0,
    this.showControlPoints = true,
    this.smoothness = 0.5,
  })  : id = id ?? RandomGenerator.generateId(),
        controlPoints = controlPoints ?? [],
        pathColor = pathColor ?? const Color(0xFFFFC107); // Yellow

  /// Create a copy with optional field updates
  TrajectoryPathModel copyWith({
    String? id,
    PathType? pathType,
    List<ControlPoint>? controlPoints,
    bool? enabled,
    Color? pathColor,
    double? pathWidth,
    bool? showControlPoints,
    double? smoothness,
  }) {
    return TrajectoryPathModel(
      id: id ?? this.id,
      pathType: pathType ?? this.pathType,
      controlPoints:
          controlPoints ?? this.controlPoints.map((cp) => cp.clone()).toList(),
      enabled: enabled ?? this.enabled,
      pathColor: pathColor ?? this.pathColor,
      pathWidth: pathWidth ?? this.pathWidth,
      showControlPoints: showControlPoints ?? this.showControlPoints,
      smoothness: smoothness ?? this.smoothness,
    );
  }

  /// Convert to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pathType': pathType.name,
      'controlPoints': controlPoints.map((cp) => cp.toJson()).toList(),
      'enabled': enabled,
      'pathColor': pathColor.value,
      'pathWidth': pathWidth,
      'showControlPoints': showControlPoints,
      'smoothness': smoothness,
    };
  }

  /// Create from JSON data
  factory TrajectoryPathModel.fromJson(Map<String, dynamic> json) {
    final controlPointsList = json['controlPoints'] as List?;

    return TrajectoryPathModel(
      id: json['id'] as String?,
      pathType: PathType.values.firstWhere(
        (e) => e.name == json['pathType'],
        orElse: () => PathType.straight,
      ),
      controlPoints: controlPointsList
              ?.map((cpJson) =>
                  ControlPoint.fromJson(cpJson as Map<String, dynamic>))
              .toList() ??
          [],
      enabled: json['enabled'] as bool? ?? false,
      pathColor: json['pathColor'] != null
          ? Color(json['pathColor'] as int)
          : const Color(0xFFFFC107),
      pathWidth: (json['pathWidth'] as num?)?.toDouble() ?? 2.0,
      showControlPoints: json['showControlPoints'] as bool? ?? true,
      smoothness: (json['smoothness'] as num?)?.toDouble() ?? 0.5,
    );
  }

  /// Create a clone of this trajectory
  TrajectoryPathModel clone() {
    return TrajectoryPathModel(
      id: id,
      pathType: pathType,
      controlPoints: controlPoints.map((cp) => cp.clone()).toList(),
      enabled: enabled,
      pathColor: pathColor,
      pathWidth: pathWidth,
      showControlPoints: showControlPoints,
      smoothness: smoothness,
    );
  }

  /// Check if this is a custom path (not straight)
  bool get isCustomPath => pathType != PathType.straight && enabled;

  /// Check if this path has control points
  bool get hasControlPoints => controlPoints.isNotEmpty;
}
