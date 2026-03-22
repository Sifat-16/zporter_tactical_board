import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:zporter_tactical_board/v2/core/json_helpers.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';

/// Immutable animation containing an ordered list of scenes.
///
/// Matches V1 [AnimationModel] field-for-field. JSON is V1-compatible.
/// Adds optional [schemaVersion] for V2 migration tracking.
class AnimationModelV2 {
  final String id;
  final String name;
  final String userId;
  final Color fieldColor;
  final String? collectionId;
  final List<SceneModelV2> animationScenes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BoardBackground boardBackground;
  final int orderIndex;
  final int schemaVersion;

  AnimationModelV2({
    required this.id,
    required this.name,
    required this.userId,
    this.collectionId,
    required this.fieldColor,
    required List<SceneModelV2> animationScenes,
    required this.createdAt,
    required this.updatedAt,
    this.boardBackground = BoardBackground.full,
    this.orderIndex = 0,
    this.schemaVersion = 2,
  }) : animationScenes = List.unmodifiable(animationScenes);

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'userId': userId,
      'fieldColor': JsonHelpers.colorToJson(fieldColor),
      'collectionId': collectionId,
      'animationScenes':
          animationScenes.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'boardBackground': boardBackground.name,
      'orderIndex': orderIndex,
      'schemaVersion': schemaVersion,
    };
  }

  factory AnimationModelV2.fromJson(Map<String, dynamic> json) {
    // Parse animation scenes with auto-indexing (V1 migration)
    final scenesList = json['animationScenes'] as List? ?? [];
    final scenes = <SceneModelV2>[];
    bool hasNullIndex = false;

    for (final item in scenesList) {
      if (item is Map<String, dynamic>) {
        try {
          final scene = SceneModelV2.fromJson(item);
          if (item['index'] == null) hasNullIndex = true;
          scenes.add(scene);
        } catch (_) {
          // Skip malformed scenes
        }
      }
    }

    // V1 migration: if any scene has null index, assign list order as index
    final orderedScenes = hasNullIndex
        ? scenes
            .asMap()
            .entries
            .map((e) => e.value.copyWith(index: e.key))
            .toList()
        : scenes;

    // Sort by index
    orderedScenes.sort((a, b) => a.index.compareTo(b.index));

    // Default color
    final fieldColor =
        JsonHelpers.colorFromJson(json['fieldColor']) ??
            const Color(0xFF9E9E9E);

    return AnimationModelV2(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      collectionId: json['collectionId'] as String?,
      fieldColor: fieldColor,
      animationScenes: orderedScenes,
      createdAt: JsonHelpers.dateTimeFromJson(json['createdAt']) ??
          DateTime.now(),
      updatedAt: JsonHelpers.dateTimeFromJson(json['updatedAt']) ??
          DateTime.now(),
      boardBackground:
          BoardBackground.fromString(json['boardBackground'] as String?),
      orderIndex: JsonHelpers.toInt(json['orderIndex']) ?? 0,
      schemaVersion: JsonHelpers.toInt(json['schemaVersion']) ?? 1,
    );
  }

  AnimationModelV2 copyWith({
    String? id,
    String? name,
    String? userId,
    Color? fieldColor,
    Object? collectionId = _sentinel,
    List<SceneModelV2>? animationScenes,
    DateTime? createdAt,
    DateTime? updatedAt,
    BoardBackground? boardBackground,
    int? orderIndex,
    int? schemaVersion,
  }) {
    return AnimationModelV2(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      fieldColor: fieldColor ?? this.fieldColor,
      collectionId: collectionId == _sentinel
          ? this.collectionId
          : collectionId as String?,
      animationScenes: animationScenes ?? this.animationScenes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      boardBackground: boardBackground ?? this.boardBackground,
      orderIndex: orderIndex ?? this.orderIndex,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  AnimationModelV2 clone() {
    return copyWith(
      animationScenes:
          animationScenes.map((s) => s.clone()).toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnimationModelV2) return false;
    return id == other.id &&
        name == other.name &&
        userId == other.userId &&
        fieldColor == other.fieldColor &&
        collectionId == other.collectionId &&
        listEquals(animationScenes, other.animationScenes) &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        boardBackground == other.boardBackground &&
        orderIndex == other.orderIndex &&
        schemaVersion == other.schemaVersion;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        userId,
        fieldColor,
        collectionId,
        Object.hashAll(animationScenes),
        createdAt,
        updatedAt,
        boardBackground,
        orderIndex,
        schemaVersion,
      );
}

const Object _sentinel = Object();
