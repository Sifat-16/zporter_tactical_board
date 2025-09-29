// import 'package:flame/components.dart';
// import 'package:flutter/material.dart'; // Import for Color
//
// // Assuming FieldItemModel and its helpers are defined correctly and imported
// import 'field_item_model.dart';
//
// class EquipmentModel extends FieldItemModel {
//   String name;
//   String? imagePath;
//   bool isAerialArrival; // NEW: Flag to indicate an aerial pass animation
//
//   EquipmentModel({
//     // --- Existing FieldItemModel properties ---
//     required super.id,
//     super.offset,
//     super.fieldItemType = FieldItemType.EQUIPMENT,
//     super.angle,
//     super.canBeCopied = true,
//     super.scaleSymmetrically = true,
//     super.createdAt,
//     super.updatedAt,
//     super.size,
//     super.color,
//     super.opacity,
//     // --- EquipmentModel specific properties ---
//     required this.name,
//     this.imagePath,
//     this.isAerialArrival = false, // NEW: Default to false
//   });
//
//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       ...super.toJson(),
//       'name': name,
//       'imagePath': imagePath,
//       'isAerialArrival': isAerialArrival, // NEW: Add to JSON output
//     };
//   }
//
//   static EquipmentModel fromJson(Map<String, dynamic> json) {
//     final id = json['_id'];
//     final offset = FieldItemModel.offsetFromJson(json['offset']);
//     final scaleSymmetrically = json['scaleSymmetrically'] as bool? ?? true;
//     final angle = json['angle'] as double?;
//     final canBeCopied = json['canBeCopied'] as bool? ?? true;
//     final createdAt =
//         json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
//     final updatedAt =
//         json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
//     final size = FieldItemModel.vector2FromJson(json['size']);
//     final color = json['color'] != null ? Color(json['color']) : null;
//     final opacity = json['opacity'] == null
//         ? null
//         : double.parse(json['opacity'].toString());
//     final name = json['name'] as String? ?? 'Unnamed Equipment';
//     final imagePath = json['imagePath'] as String?;
//
//     // NEW: Parse the aerial flag from JSON, defaulting to false if not present
//     final isAerialArrival = json['isAerialArrival'] as bool? ?? false;
//
//     return EquipmentModel(
//       id: id,
//       offset: offset,
//       scaleSymmetrically: scaleSymmetrically,
//       angle: angle,
//       canBeCopied: canBeCopied,
//       createdAt: createdAt,
//       updatedAt: updatedAt,
//       size: size,
//       color: color,
//       opacity: opacity,
//       name: name,
//       imagePath: imagePath,
//       isAerialArrival: isAerialArrival, // NEW: Pass the parsed value
//     );
//   }
//
//   @override
//   EquipmentModel copyWith({
//     String? id,
//     Vector2? offset,
//     bool? scaleSymmetrically,
//     FieldItemType? fieldItemType,
//     double? angle,
//     bool? canBeCopied,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     Vector2? fieldSize,
//     Vector2? size,
//     Color? color,
//     double? opacity,
//     String? name,
//     String? imagePath,
//     bool? isAerialArrival, // NEW: Add to copyWith parameters
//   }) {
//     return EquipmentModel(
//       id: id ?? this.id,
//       offset: offset ?? this.offset?.clone(),
//       scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
//       fieldItemType: this.fieldItemType,
//       angle: angle ?? this.angle,
//       canBeCopied: canBeCopied ?? this.canBeCopied,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       size: size ?? this.size?.clone(),
//       color: color ?? this.color,
//       opacity: opacity ?? this.opacity,
//       name: name ?? this.name,
//       imagePath: imagePath ?? this.imagePath,
//       isAerialArrival:
//           isAerialArrival ?? this.isAerialArrival, // NEW: Handle in copyWith
//     );
//   }
//
//   @override
//   EquipmentModel clone() => copyWith();
// }

import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // Import for Color

// Assuming FieldItemModel and its helpers are defined correctly and imported
import 'field_item_model.dart';

// NEW: Enum to represent the different types of ball spin.
enum BallSpin { none, left, right, knuckleball }

class EquipmentModel extends FieldItemModel {
  String name;
  String? imagePath;
  bool isAerialArrival;

  // NEW: Properties for speed and spin
  double? passSpeedMultiplier;
  BallSpin? spin;

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
    super.size,
    super.color,
    super.opacity,
    // --- EquipmentModel specific properties ---
    required this.name,
    this.imagePath,
    this.isAerialArrival = false,
    // NEW: Add to constructor with default values
    this.passSpeedMultiplier = 1.0,
    this.spin = BallSpin.none,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'name': name,
      'imagePath': imagePath,
      'isAerialArrival': isAerialArrival,
      // NEW: Add new properties to the JSON map for saving
      'passSpeedMultiplier': passSpeedMultiplier,
      'spin': spin?.name, // Save the enum as a string (e.g., 'left')
    };
  }

  static EquipmentModel fromJson(Map<String, dynamic> json) {
    final id = json['_id'];
    final offset = FieldItemModel.offsetFromJson(json['offset']);
    final scaleSymmetrically = json['scaleSymmetrically'] as bool? ?? true;
    final angle = json['angle'] as double?;
    final canBeCopied = json['canBeCopied'] as bool? ?? true;
    final createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    final updatedAt =
        json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
    final size = FieldItemModel.vector2FromJson(json['size']);
    final color = json['color'] != null ? Color(json['color']) : null;
    final opacity = json['opacity'] == null
        ? null
        : double.parse(json['opacity'].toString());
    final name = json['name'] as String? ?? 'Unnamed Equipment';
    final imagePath = json['imagePath'] as String?;
    final isAerialArrival = json['isAerialArrival'] as bool? ?? false;

    // NEW: Parse the new properties from JSON
    final passSpeedMultiplier =
        (json['passSpeedMultiplier'] as num?)?.toDouble() ?? 1.0;

    final spinString = json['spin'] as String?;
    final spin = BallSpin.values.firstWhere(
      (e) => e.name == spinString,
      orElse: () => BallSpin.none, // Default to 'none' if not found
    );

    return EquipmentModel(
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
      name: name,
      imagePath: imagePath,
      isAerialArrival: isAerialArrival,
      // NEW: Pass the parsed values to the constructor
      passSpeedMultiplier: passSpeedMultiplier,
      spin: spin,
    );
  }

  @override
  EquipmentModel copyWith({
    String? id,
    Vector2? offset,
    bool? scaleSymmetrically,
    FieldItemType? fieldItemType,
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? fieldSize,
    Vector2? size,
    Color? color,
    double? opacity,
    String? name,
    String? imagePath,
    bool? isAerialArrival,
    // NEW: Add new properties to copyWith
    double? passSpeedMultiplier,
    BallSpin? spin,
  }) {
    return EquipmentModel(
      id: id ?? this.id,
      offset: offset ?? this.offset?.clone(),
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      fieldItemType: this.fieldItemType,
      angle: angle ?? this.angle,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      size: size ?? this.size?.clone(),
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      isAerialArrival: isAerialArrival ?? this.isAerialArrival,
      // NEW: Handle new properties in copyWith
      passSpeedMultiplier: passSpeedMultiplier ?? this.passSpeedMultiplier,
      spin: spin ?? this.spin,
    );
  }

  @override
  EquipmentModel clone() => copyWith();
}
