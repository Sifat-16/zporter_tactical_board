import 'package:flutter/foundation.dart';
import 'package:zporter_tactical_board/v2/core/json_helpers.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';

/// Immutable collection of animations.
///
/// Matches V1 [AnimationCollectionModel] field-for-field. JSON is V1-compatible.
/// Adds optional [schemaVersion] for V2 migration tracking.
class AnimationCollectionModelV2 {
  final String id;
  final String name;
  final List<AnimationModelV2> animations;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int orderIndex;
  final bool isTemplate;
  final bool hasPendingUpdates;
  final int schemaVersion;

  AnimationCollectionModelV2({
    required this.id,
    required this.name,
    required List<AnimationModelV2> animations,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.orderIndex = 0,
    this.isTemplate = false,
    this.hasPendingUpdates = false,
    this.schemaVersion = 2,
  }) : animations = List.unmodifiable(animations);

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'userId': userId,
      'animations': animations.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'orderIndex': orderIndex,
      'isTemplate': isTemplate,
      'hasPendingUpdates': hasPendingUpdates,
      'schemaVersion': schemaVersion,
    };
  }

  factory AnimationCollectionModelV2.fromJson(Map<String, dynamic> json) {
    // Parse animations — skip items that fail to parse
    final animationsList = json['animations'] as List? ?? [];
    final animations = <AnimationModelV2>[];
    for (final item in animationsList) {
      if (item is Map<String, dynamic>) {
        try {
          animations.add(AnimationModelV2.fromJson(item));
        } catch (_) {
          // Skip malformed animations
        }
      }
    }

    return AnimationCollectionModelV2(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      animations: animations,
      createdAt: JsonHelpers.dateTimeFromJson(json['createdAt']) ??
          DateTime.now(),
      updatedAt: JsonHelpers.dateTimeFromJson(json['updatedAt']) ??
          DateTime.now(),
      orderIndex: JsonHelpers.toInt(json['orderIndex']) ?? 0,
      isTemplate: json['isTemplate'] as bool? ?? false,
      hasPendingUpdates: json['hasPendingUpdates'] as bool? ?? false,
      schemaVersion: JsonHelpers.toInt(json['schemaVersion']) ?? 1,
    );
  }

  AnimationCollectionModelV2 copyWith({
    String? id,
    String? name,
    List<AnimationModelV2>? animations,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? orderIndex,
    bool? isTemplate,
    bool? hasPendingUpdates,
    int? schemaVersion,
  }) {
    return AnimationCollectionModelV2(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      animations: animations ?? this.animations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orderIndex: orderIndex ?? this.orderIndex,
      isTemplate: isTemplate ?? this.isTemplate,
      hasPendingUpdates: hasPendingUpdates ?? this.hasPendingUpdates,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  AnimationCollectionModelV2 clone() {
    return copyWith(
      animations: animations.map((a) => a.clone()).toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnimationCollectionModelV2) return false;
    return id == other.id &&
        name == other.name &&
        userId == other.userId &&
        listEquals(animations, other.animations) &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        orderIndex == other.orderIndex &&
        isTemplate == other.isTemplate &&
        hasPendingUpdates == other.hasPendingUpdates &&
        schemaVersion == other.schemaVersion;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        userId,
        Object.hashAll(animations),
        createdAt,
        updatedAt,
        orderIndex,
        isTemplate,
        hasPendingUpdates,
        schemaVersion,
      );
}
