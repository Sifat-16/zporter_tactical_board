import 'package:flame/components.dart';
import 'package:flutter/foundation.dart'; // For describeEnum
import 'package:flutter/material.dart'; // For Color
import 'package:mongo_dart/mongo_dart.dart';

// Assuming FieldItemModel and its helpers (vector2ToJson/FromJson) are in this file or imported
import 'field_item_model.dart';

enum PlayerType { HOME, OTHER, AWAY, UNKNOWN } // Added UNKNOWN

class PlayerModel extends FieldItemModel {
  String role;
  String? imagePath;
  int index;
  PlayerType playerType;

  PlayerModel({
    // --- Base FieldItemModel properties ---
    required super.id,
    required super.offset, // PlayerModel seems to require offset unlike others
    super.fieldItemType = FieldItemType.PLAYER,
    super.angle,
    super.canBeCopied = false, // Keep existing default
    super.scaleSymmetrically = true, // Keep existing default
    super.createdAt,
    super.updatedAt,
    // --- New FieldItemModel properties ---
    super.size,
    super.color, // You might set a default color based on playerType later
    super.opacity,
    // --- PlayerModel specific properties ---
    required this.role,
    required this.index,
    required this.playerType,
    this.imagePath,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super
          .toJson(), // Includes id, offset, angle, scaleSym, canBeCopied, dates, size, color, opacity, fieldItemType
      // Add PlayerModel specific fields
      'role': role,
      'imagePath': imagePath,
      'index': index,
      'playerType': describeEnum(playerType), // Use describeEnum
    };
  }

  static PlayerModel fromJson(Map<String, dynamic> json) {
    // FieldItemModel.fromJson handles all base properties including new ones
    final base = FieldItemModel.fromJson(json);

    // Deserialize playerType safely using describeEnum
    final playerTypeString = json['playerType'] as String?;
    final playerType = PlayerType.values.firstWhere(
      (e) => describeEnum(e) == playerTypeString,
      orElse: () => PlayerType.UNKNOWN, // Default if null or invalid
    );

    return PlayerModel(
      // --- Pass all base properties ---
      id: base.id,
      offset:
          base.offset ??
          Vector2.zero(), // Provide default if base offset is null
      fieldItemType: base.fieldItemType, // Should be PLAYER, but respect base
      angle: base.angle,
      // Pass missing base properties from original code
      scaleSymmetrically: base.scaleSymmetrically,
      canBeCopied: base.canBeCopied,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      // --- Pass NEW base properties ---
      size: base.size,
      color: base.color,
      opacity: base.opacity,
      // --- Pass PlayerModel specific properties ---
      role: json['role'] as String? ?? 'Unknown', // Default if null
      index: json['index'] as int? ?? -1, // Default if null
      imagePath: json['imagePath'] as String?,
      playerType: playerType,
    );
  }

  @override
  PlayerModel copyWith({
    // --- Base FieldItemModel properties ---
    ObjectId? id,
    Vector2? offset,
    bool? scaleSymmetrically,
    FieldItemType? fieldItemType, // Usually not overridden for specific types
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? size,
    Color? color,
    double? opacity,
    // --- PlayerModel properties ---
    String? role,
    int? index,
    String? imagePath,
    PlayerType? playerType,
  }) {
    return PlayerModel(
      // --- Use new or existing values for base properties ---
      id: id ?? this.id,
      offset: offset ?? this.offset?.clone(), // Clone mutable Vector2
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      fieldItemType: this.fieldItemType, // Keep original type
      angle: angle ?? this.angle,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      size: size ?? this.size?.clone(), // Clone mutable Vector2
      color: color ?? this.color, // Color is immutable
      opacity: opacity ?? this.opacity,
      // --- Use new or existing values for PlayerModel properties ---
      role: role ?? this.role,
      index: index ?? this.index,
      imagePath: imagePath ?? this.imagePath,
      playerType: playerType ?? this.playerType,
    );
  }

  // Use simplified clone
  @override
  PlayerModel clone() => copyWith();

  /* // Manual clone (less maintainable)
  @override
  PlayerModel clone() {
    return PlayerModel(
      // --- Base ---
      id: id,
      offset: offset?.clone(), // Clone mutable Vector2
      fieldItemType: fieldItemType,
      angle: angle,
      scaleSymmetrically: scaleSymmetrically,
      canBeCopied: canBeCopied,
      createdAt: createdAt,
      updatedAt: updatedAt,
      // --- New Base ---
      size: size?.clone(), // Clone mutable Vector2
      color: color,
      opacity: opacity,
      // --- Player ---
      role: role,
      index: index,
      imagePath: imagePath,
      playerType: playerType,
    );
  }
  */
}
