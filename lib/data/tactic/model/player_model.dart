import 'package:flame/components.dart';
import 'package:flutter/foundation.dart'; // For describeEnum
import 'package:flutter/material.dart'; // For Color

// Assuming FieldItemModel and its helpers (vector2ToJson/FromJson, parseObjectId etc.)
// are defined in 'field_item_model.dart' or imported correctly.
import 'field_item_model.dart';

// Ensure this enum definition matches your project
enum PlayerType { HOME, OTHER, AWAY, UNKNOWN }

class PlayerModel extends FieldItemModel {
  String role;
  String? imagePath;
  int index;
  PlayerType playerType;

  PlayerModel({
    // --- Base FieldItemModel properties ---
    required super.id,
    required super.offset, // PlayerModel seems to require offset unlike others
    super.fieldItemType = FieldItemType.PLAYER, // Default type for PlayerModel
    super.angle,
    super.canBeCopied = false, // Keep existing default from provided code
    super.scaleSymmetrically = true, // Keep existing default from provided code
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
    // Keep existing toJson logic
    return {
      ...super.toJson(), // Includes base fields + fieldItemType='PLAYER'
      'role': role,
      'imagePath': imagePath,
      'index': index,
      'playerType': describeEnum(
        playerType,
      ), // Use describeEnum for serialization
    };
  }

  // --- FIXED fromJson Static Method ---
  static PlayerModel fromJson(Map<String, dynamic> json) {
    // --- Parse Base Class Properties DIRECTLY from JSON ---
    // DO NOT call FieldItemModel.fromJson(json) here!
    // Use static helpers from FieldItemModel where appropriate.

    final id = json['_id']; // Use helper
    final offset =
        FieldItemModel.offsetFromJson(json['offset']) ??
        Vector2.zero(); // Use helper + Default
    final scaleSymmetrically =
        json['scaleSymmetrically'] as bool? ?? true; // Default from constructor
    final angle = json['angle'] as double?;
    final canBeCopied =
        json['canBeCopied'] as bool? ?? false; // Default from constructor
    final createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    final updatedAt =
        json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
    final size = FieldItemModel.vector2FromJson(json['size']); // Use helper
    final color = json['color'] != null ? Color(json['color']) : null;
    final opacity = json['opacity'] as double?;
    // final fieldItemType = FieldItemType.PLAYER; // We know this because we are in PlayerModel.fromJson

    // --- Deserialize PlayerModel Specific Properties (Keep Existing Logic) ---
    final playerTypeString = json['playerType'] as String?;
    final playerType = PlayerType.values.firstWhere(
      (e) => describeEnum(e) == playerTypeString,
      orElse: () => PlayerType.UNKNOWN, // Default if null or invalid
    );
    final role = json['role'] as String? ?? 'Unknown'; // Default if null
    final index = json['index'] as int? ?? -1; // Default if null
    final imagePath = json['imagePath'] as String?;

    // --- Construct and Return PlayerModel Instance ---
    return PlayerModel(
      // Pass parsed base properties
      id: id,
      offset: offset,
      scaleSymmetrically: scaleSymmetrically,
      angle: angle,
      canBeCopied: canBeCopied,
      createdAt: createdAt,
      updatedAt: updatedAt,
      size: size,
      color: color,
      opacity: opacity,
      // fieldItemType is set automatically by PlayerModel constructor

      // Pass parsed PlayerModel specific properties
      role: role,
      index: index,
      imagePath: imagePath,
      playerType: playerType,
    );
  }

  // --- copyWith and clone remain unchanged from your provided code ---
  @override
  PlayerModel copyWith({
    // --- Base FieldItemModel properties ---
    String? id,
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
      offset:
          offset ??
          this.offset
              ?.clone(), // Assumes Vector2 is immutable OR handle clone if needed
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      fieldItemType: this.fieldItemType, // Keep original type PLAYER
      angle: angle ?? this.angle,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      size:
          size ??
          this.size, // Assumes Vector2 is immutable OR handle clone if needed
      color: color ?? this.color, // Color is immutable
      opacity: opacity ?? this.opacity,
      // --- Use new or existing values for PlayerModel properties ---
      role: role ?? this.role,
      index: index ?? this.index,
      imagePath:
          imagePath ?? this.imagePath, // Handles null assignment correctly
      playerType: playerType ?? this.playerType,
    );
  }

  @override
  PlayerModel clone() => copyWith(); // Keep simplified clone
}
