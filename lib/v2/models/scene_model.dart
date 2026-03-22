import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:zporter_tactical_board/v2/core/json_helpers.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/trajectory_model.dart';

/// Immutable scene (animation frame) containing a snapshot of all board elements.
///
/// Matches V1 [AnimationItemModel] field-for-field. JSON is V1-compatible.
class SceneModelV2 {
  final String id;
  final int index;
  final List<BoardElement> components;
  final Color fieldColor;
  final DateTime createdAt;
  final String userId;
  final DateTime updatedAt;
  final Size fieldSize;
  final Duration sceneDuration;
  final BoardBackground boardBackground;
  final TrajectoryDataV2? trajectoryData;

  SceneModelV2({
    required this.id,
    required this.index,
    required List<BoardElement> components,
    required this.fieldColor,
    required this.createdAt,
    required this.userId,
    required this.updatedAt,
    required this.fieldSize,
    Duration? sceneDuration,
    this.boardBackground = BoardBackground.full,
    this.trajectoryData,
  })  : components = List.unmodifiable(components),
        sceneDuration = sceneDuration ?? const Duration(seconds: 2);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'index': index,
      'components': components.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'fieldColor': JsonHelpers.colorToJson(fieldColor),
      'fieldSize': JsonHelpers.sizeToJson(fieldSize),
      'sceneDurationMilliseconds': sceneDuration.inMilliseconds,
      'boardBackground': boardBackground.name,
      if (trajectoryData != null && trajectoryData!.hasAnyTrajectories)
        'trajectoryData': trajectoryData!.toJson(),
    };
  }

  factory SceneModelV2.fromJson(Map<String, dynamic> json) {
    // Parse components — skip items that fail to parse
    final componentsList = json['components'] as List? ?? [];
    final components = <BoardElement>[];
    for (final item in componentsList) {
      if (item is Map<String, dynamic>) {
        try {
          components.add(BoardElement.fromJson(item));
        } catch (_) {
          // Skip malformed components — matches V1 error handling
        }
      }
    }

    // Parse field size
    final fieldSizeJson = json['fieldSize'];
    final fieldSize = JsonHelpers.sizeFromJson(fieldSizeJson) ??
        const Size(1050, 680);

    // Parse scene duration
    final durationMs =
        JsonHelpers.toInt(json['sceneDurationMilliseconds']);
    final sceneDuration = durationMs != null
        ? Duration(milliseconds: durationMs)
        : const Duration(seconds: 2);

    // Parse trajectory data
    TrajectoryDataV2? trajectoryData;
    if (json['trajectoryData'] is Map<String, dynamic>) {
      trajectoryData = TrajectoryDataV2.fromJson(
          json['trajectoryData'] as Map<String, dynamic>);
    }

    // Default color
    final fieldColor =
        JsonHelpers.colorFromJson(json['fieldColor']) ??
            const Color(0xFF9E9E9E);

    // Parse timestamps
    final createdAt = JsonHelpers.dateTimeFromJson(json['createdAt']) ??
        DateTime.now();
    final updatedAt = JsonHelpers.dateTimeFromJson(json['updatedAt']) ??
        DateTime.now();

    return SceneModelV2(
      id: (json['id'] ?? json['_id']) as String? ?? '',
      index: JsonHelpers.toInt(json['index']) ?? 0,
      components: components,
      fieldColor: fieldColor,
      createdAt: createdAt,
      userId: json['userId'] as String? ?? '',
      updatedAt: updatedAt,
      fieldSize: fieldSize,
      sceneDuration: sceneDuration,
      boardBackground:
          BoardBackground.fromString(json['boardBackground'] as String?),
      trajectoryData: trajectoryData,
    );
  }

  SceneModelV2 copyWith({
    String? id,
    int? index,
    List<BoardElement>? components,
    Color? fieldColor,
    DateTime? createdAt,
    String? userId,
    DateTime? updatedAt,
    Size? fieldSize,
    Duration? sceneDuration,
    BoardBackground? boardBackground,
    TrajectoryDataV2? trajectoryData,
    bool clearTrajectoryData = false,
  }) {
    return SceneModelV2(
      id: id ?? this.id,
      index: index ?? this.index,
      components: components ?? this.components,
      fieldColor: fieldColor ?? this.fieldColor,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      fieldSize: fieldSize ?? this.fieldSize,
      sceneDuration: sceneDuration ?? this.sceneDuration,
      boardBackground: boardBackground ?? this.boardBackground,
      trajectoryData: clearTrajectoryData
          ? null
          : (trajectoryData ?? this.trajectoryData),
    );
  }

  SceneModelV2 clone() {
    return copyWith(
      components: components.map((c) => c.clone()).toList(),
      trajectoryData: trajectoryData?.copyWith(),
    );
  }

  /// Factory for creating an empty scene.
  factory SceneModelV2.empty({
    required String id,
    required String userId,
    int index = 0,
    Color fieldColor = const Color(0xFF9E9E9E),
    Size fieldSize = const Size(1050, 680),
    BoardBackground boardBackground = BoardBackground.full,
  }) {
    final now = DateTime.now();
    return SceneModelV2(
      id: id,
      index: index,
      components: const [],
      fieldColor: fieldColor,
      createdAt: now,
      userId: userId,
      updatedAt: now,
      fieldSize: fieldSize,
      boardBackground: boardBackground,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SceneModelV2) return false;
    return id == other.id &&
        index == other.index &&
        listEquals(components, other.components) &&
        fieldColor == other.fieldColor &&
        createdAt == other.createdAt &&
        userId == other.userId &&
        updatedAt == other.updatedAt &&
        fieldSize == other.fieldSize &&
        sceneDuration == other.sceneDuration &&
        boardBackground == other.boardBackground &&
        trajectoryData == other.trajectoryData;
  }

  @override
  int get hashCode => Object.hash(
        id,
        index,
        Object.hashAll(components),
        fieldColor,
        createdAt,
        userId,
        updatedAt,
        fieldSize,
        sceneDuration,
        boardBackground,
        trajectoryData,
      );
}
