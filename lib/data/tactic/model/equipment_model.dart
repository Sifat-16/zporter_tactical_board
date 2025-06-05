import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // Import for Color

// Assuming FieldItemModel and its helpers are defined correctly and imported
import 'field_item_model.dart';

class EquipmentModel extends FieldItemModel {
  String name;
  String? imagePath;

  EquipmentModel({
    // --- Existing FieldItemModel properties ---
    required super.id,
    super.offset, // Nullable in constructor
    super.fieldItemType =
        FieldItemType.EQUIPMENT, // Default type for EquipmentModel
    super.angle,
    super.canBeCopied = true, // Keep existing default
    super.scaleSymmetrically = true, // Keep existing default
    super.createdAt,
    super.updatedAt,
    // --- New FieldItemModel properties ---
    super.size,
    super.color,
    super.opacity,
    // --- EquipmentModel specific properties ---
    required this.name,
    this.imagePath,
  });

  @override
  Map<String, dynamic> toJson() {
    // Keep existing toJson logic
    return {
      ...super.toJson(), // Includes base fields + fieldItemType='EQUIPMENT'
      'name': name,
      'imagePath': imagePath,
    };
  }

  // --- FIXED fromJson Static Method ---
  static EquipmentModel fromJson(Map<String, dynamic> json) {
    // --- Parse Base Class Properties DIRECTLY from JSON ---
    // DO NOT call FieldItemModel.fromJson(json) here!
    // Use static helpers from FieldItemModel where appropriate.

    final id = json['_id']; // Use helper
    final offset = FieldItemModel.offsetFromJson(
      json['offset'],
    ); // Use helper (nullable)
    // Note: fieldItemType is not parsed here, it's determined by being in EquipmentModel.fromJson
    final scaleSymmetrically =
        json['scaleSymmetrically'] as bool? ?? true; // Default from constructor
    final angle = json['angle'] as double?;
    final canBeCopied =
        json['canBeCopied'] as bool? ?? true; // Default from constructor
    final createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    final updatedAt =
        json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
    final size = FieldItemModel.vector2FromJson(json['size']); // Use helper
    final color = json['color'] != null ? Color(json['color']) : null;
    final opacity =
        json['opacity'] == null
            ? null
            : double.parse(json['opacity'].toString());

    // --- Deserialize EquipmentModel Specific Properties (Keep Existing Logic) ---
    final name =
        json['name'] as String? ?? 'Unnamed Equipment'; // Default if null
    final imagePath = json['imagePath'] as String?;

    // --- Construct and Return EquipmentModel Instance ---
    return EquipmentModel(
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
      // fieldItemType is set automatically by EquipmentModel constructor

      // Pass parsed EquipmentModel specific properties
      name: name,
      imagePath: imagePath,
    );
  }

  // --- copyWith and clone remain unchanged from your provided code ---
  @override
  EquipmentModel copyWith({
    // --- FieldItemModel properties ---
    String? id,
    Vector2? offset,
    bool? scaleSymmetrically,
    FieldItemType? fieldItemType, // Usually not overridden
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? fieldSize,
    // --- NEW FieldItemModel properties ---
    Vector2? size,
    Color? color,
    double? opacity,
    // --- EquipmentModel properties ---
    String? name,
    String? imagePath,
  }) {
    return EquipmentModel(
      // --- Use new or existing values for base properties ---
      id: id ?? this.id,
      offset:
          offset ?? this.offset?.clone(), // Clone mutable Vector2 if necessary
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      fieldItemType: this.fieldItemType, // Keep original type
      angle: angle ?? this.angle,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      size: size ?? this.size?.clone(), // Clone mutable Vector2 if necessary
      color: color ?? this.color, // Color is immutable
      opacity: opacity ?? this.opacity,
      // --- Use new or existing values for EquipmentModel properties ---
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  // Recommendation: Replace the manual clone below with:
  @override
  EquipmentModel clone() => copyWith();
}
