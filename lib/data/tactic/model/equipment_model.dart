import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // Import for Color
import 'package:mongo_dart/mongo_dart.dart';

import 'field_item_model.dart'; // Assuming FieldItemModel is in this file

class EquipmentModel extends FieldItemModel {
  String name;
  String? imagePath;

  EquipmentModel({
    // --- Existing FieldItemModel properties ---
    required super.id,
    super.offset,
    super.fieldItemType = FieldItemType.EQUIPMENT,
    super.angle,
    super.canBeCopied = true,
    super.scaleSymmetrically = true,
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
    // super.toJson() already includes size, color, opacity
    return {
      ...super.toJson(),
      // Add EquipmentModel specific fields
      'name': name,
      'imagePath': imagePath,
    };
  }

  static EquipmentModel fromJson(Map<String, dynamic> json) {
    // FieldItemModel.fromJson now handles all base properties including new ones
    final base = FieldItemModel.fromJson(json);
    return EquipmentModel(
      // --- Pass all base properties ---
      id: base.id,
      offset: base.offset,
      fieldItemType:
          base.fieldItemType, // Should be EQUIPMENT, but respect base if overridden
      angle: base.angle,
      scaleSymmetrically: base.scaleSymmetrically,
      canBeCopied: base.canBeCopied,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      // --- Pass NEW base properties ---
      size: base.size,
      color: base.color,
      opacity: base.opacity,
      // --- Pass EquipmentModel specific properties ---
      name: json['name'] ?? 'Unnamed Equipment', // Provide default if null
      imagePath: json['imagePath'],
    );
  }

  @override
  EquipmentModel copyWith({
    // --- FieldItemModel properties ---
    ObjectId? id,
    Vector2? offset,
    bool? scaleSymmetrically,
    FieldItemType? fieldItemType, // Usually not overridden for specific types
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      offset: offset ?? this.offset?.clone(), // Clone mutable Vector2
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      fieldItemType: this.fieldItemType, // Keep original type
      angle: angle ?? this.angle,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // --- Use new or existing values for NEW base properties ---
      size: size ?? this.size?.clone(), // Clone mutable Vector2
      color: color ?? this.color, // Color is immutable
      opacity: opacity ?? this.opacity,
      // --- Use new or existing values for EquipmentModel properties ---
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  // Recommendation: Replace the manual clone below with:
  // @override
  // EquipmentModel clone() => copyWith();

  @override
  EquipmentModel clone() {
    // Manual cloning (less maintainable than using copyWith())
    return EquipmentModel(
      // --- Base ---
      id: id, // ObjectId is complex, usually treated as immutable reference
      offset: offset?.clone(), // Clone mutable Vector2
      fieldItemType: fieldItemType,
      angle: angle,
      scaleSymmetrically: scaleSymmetrically,
      canBeCopied: canBeCopied,
      createdAt: createdAt, // DateTime is immutable
      updatedAt: updatedAt, // DateTime is immutable
      // --- New Base ---
      size: size?.clone(), // Clone mutable Vector2
      color: color, // Color is immutable
      opacity: opacity,
      // --- Equipment ---
      name: name, // String is immutable
      imagePath: imagePath, // String is immutable (or null)
    );
  }
}
