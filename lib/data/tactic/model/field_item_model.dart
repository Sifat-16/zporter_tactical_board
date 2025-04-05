import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // Import for Color
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';

import 'equipment_model.dart';
import 'form_model.dart';

enum FieldItemType { PLAYER, FORM, EQUIPMENT }

abstract class FieldItemModel {
  String id;
  Vector2? offset;
  FieldItemType fieldItemType; // We'll use this for type dispatching
  bool scaleSymmetrically;
  double? angle;
  bool canBeCopied;
  DateTime? createdAt;
  DateTime? updatedAt;
  Vector2? size;
  Color? color;
  double? opacity;

  // Base constructor for subclasses
  FieldItemModel({
    required this.id,
    this.offset,
    required this.fieldItemType, // Subclass must provide its type
    required this.scaleSymmetrically,
    this.angle,
    required this.canBeCopied,
    this.createdAt,
    this.updatedAt,
    required this.size,
    required this.color,
    this.opacity = 1.0,
  });

  // toJson includes the fieldItemType for dispatching in fromJson
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Assumes id is already an ObjectId type
      'offset': offsetToJson(offset?.clone()),
      'scaleSymmetrically': scaleSymmetrically,
      // Use the enum value's name string for the type field
      'fieldItemType': fieldItemType.toString().split('.').last,
      'angle': angle,
      'canBeCopied': canBeCopied,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'size': vector2ToJson(size),
      'color': color?.value,
      'opacity': opacity,
    };
  }

  // --- Static fromJson Dispatcher ---
  // Reads 'fieldItemType' and calls the appropriate subclass static fromJson
  static FieldItemModel fromJson(Map<String, dynamic> json) {
    final typeString = json['fieldItemType'] as String?;
    // zlog(data: "FieldItemType fromJson ${typeString}");
    if (typeString == null) {
      throw Exception(
        'FieldItemModel JSON missing required field: fieldItemType',
      );
    }

    // Find the enum value corresponding to the string
    final fieldItemType = FieldItemType.values.firstWhere(
      (e) => e.toString().split('.').last == typeString,
      orElse:
          () =>
              throw Exception(
                'Unknown FieldItemType string: $typeString',
              ), // Throw if type string is invalid
    );

    // Switch based on the enum value and delegate to subclass constructors
    switch (fieldItemType) {
      case FieldItemType.PLAYER:
        // Assumes PlayerModel has static PlayerModel fromJson(Map<String, dynamic> json)
        return PlayerModel.fromJson(json);
      case FieldItemType.FORM:
        // Assumes FormModel has static FormModel fromJson(Map<String, dynamic> json)
        return FormModel.fromJson(json);
      case FieldItemType.EQUIPMENT:
        // Assumes EquipmentModel has static EquipmentModel fromJson(Map<String, dynamic> json)
        return EquipmentModel.fromJson(json);
      // Add cases for any other FieldItemType values
      // No default case needed if all enum values are handled and we throw on invalid string
    }
  }

  // --- Abstract methods to be implemented by subclasses ---

  // copyWith MUST be implemented by concrete subclasses
  FieldItemModel copyWith({
    String? id,
    Vector2? offset,
    FieldItemType? fieldItemType, // Usually ignored in copyWith
    bool? scaleSymmetrically,
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? size,
    Color? color,
    double? opacity,
  });

  // clone MUST be implemented by concrete subclasses
  FieldItemModel clone();

  // --- Static Helper functions (identical to previous versions) ---
  static Map<String, dynamic>? offsetToJson(Vector2? offset) {
    if (offset == null) return null;
    return {'dx': offset.x, 'dy': offset.y};
  }

  static Vector2? offsetFromJson(dynamic json) {
    // Allow parsing Offset-like maps too for compatibility if needed
    if (json is Map<String, dynamic>) {
      final dx = json['dx'] ?? json['x']; // Check common keys
      final dy = json['dy'] ?? json['y'];
      if (dx is num && dy is num) {
        return Vector2(dx.toDouble(), dy.toDouble());
      }
    }
    return null;
  }

  static Map<String, dynamic>? vector2ToJson(Vector2? vec) {
    if (vec == null) return null;
    return {'x': vec.x, 'y': vec.y};
  }

  static Vector2? vector2FromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) return null;
    final x = json['x'];
    final y = json['y'];
    if (x is num && y is num) {
      return Vector2(x.toDouble(), y.toDouble());
    }
    return null;
  }

  // Optional: Helper for ObjectId if needed, though casting often works
  // static ObjectId parseObjectId(dynamic id) {
  //   if (id is ObjectId) return id;
  //   if (id is String) return ObjectId.parse(id);
  //   // Handle other potential types or throw error
  //   throw ArgumentError('Cannot parse ObjectId from type ${id.runtimeType}');
  // }

  // --- End Helper functions ---
}

// abstract class FieldItemModel {
//   ObjectId id;
//   Vector2? offset;
//   FieldItemType fieldItemType;
//   bool scaleSymmetrically;
//   double? angle;
//   bool canBeCopied;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//
//   // --- New Properties ---
//   Vector2? size;
//   Color? color;
//   double? opacity; // Should typically be between 0.0 and 1.0
//
//   FieldItemModel({
//     required this.id,
//     this.offset,
//     required this.canBeCopied,
//     required this.fieldItemType,
//     required this.scaleSymmetrically,
//     this.angle,
//     this.createdAt,
//     this.updatedAt,
//     // Add new properties to constructor
//     required this.size,
//     required this.color,
//     this.opacity = 1,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'offset': offsetToJson(offset),
//       'scaleSymmetrically': scaleSymmetrically,
//       'fieldItemType': fieldItemType.toString().split('.').last,
//       'angle': angle,
//       'canBeCopied': canBeCopied,
//       'createdAt': createdAt?.toIso8601String(),
//       'updatedAt': updatedAt?.toIso8601String(),
//       // --- Serialize new properties ---
//       'size': vector2ToJson(size), // Use helper for consistency
//       'color': color?.value, // Store color as integer value
//       'opacity': opacity,
//     };
//   }
//
//   static FieldItemModel fromJson(Map<String, dynamic> json) {
//     final fieldItemType = FieldItemType.values.firstWhere(
//       (e) => e.toString().split('.').last == json['fieldItemType'],
//       orElse: () => FieldItemType.PLAYER, // Provide a default if not found
//     );
//
//     return _FieldItemModelImpl(
//       id: json['_id'],
//       offset: offsetFromJson(json['offset']),
//       canBeCopied: json['canBeCopied'] ?? false, // Default if null
//       scaleSymmetrically: json['scaleSymmetrically'] ?? true, // Default if null
//       fieldItemType: fieldItemType,
//       angle: json['angle']?.toDouble(),
//       createdAt:
//           json['createdAt'] != null
//               ? DateTime.tryParse(json['createdAt'])
//               : null,
//       updatedAt:
//           json['updatedAt'] != null
//               ? DateTime.tryParse(json['updatedAt'])
//               : null,
//       // --- Deserialize new properties ---
//       size: vector2FromJson(json['size']), // Use helper
//       color:
//           json['color'] != null
//               ? Color(json['color'])
//               : null, // Create Color from int
//       opacity: json['opacity']?.toDouble(), // Ensure it's a double
//     );
//   }
//
//   FieldItemModel copyWith({
//     ObjectId? id,
//     Vector2? offset,
//     FieldItemType? fieldItemType,
//     double? angle,
//     bool? scaleSymmetrically,
//     bool? canBeCopied,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     // --- Add new properties to copyWith ---
//     Vector2? size,
//     Color? color,
//     double? opacity,
//   }) {
//     return _FieldItemModelImpl(
//       id: id ?? this.id,
//       scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
//       offset: offset ?? this.offset?.clone(), // Clone offset if keeping old one
//       fieldItemType: fieldItemType ?? this.fieldItemType,
//       angle: angle ?? this.angle,
//       canBeCopied: canBeCopied ?? this.canBeCopied,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       // --- Use new or existing values ---
//       size: size ?? this.size?.clone(), // Clone size if keeping old one
//       color: color ?? this.color, // Color is immutable, no clone needed
//       opacity: opacity ?? this.opacity,
//     );
//   }
//
//   FieldItemModel clone();
//
//   // --- Helper functions for serialization ---
//   static Map<String, dynamic>? offsetToJson(Vector2? offset) {
//     if (offset == null) return null;
//     return {'dx': offset.x, 'dy': offset.y};
//   }
//
//   static Vector2? offsetFromJson(dynamic json) {
//     if (json == null || json is! Map<String, dynamic>) return null;
//     final dx = json['dx'];
//     final dy = json['dy'];
//     if (dx is num && dy is num) {
//       return Vector2(dx.toDouble(), dy.toDouble());
//     }
//     return null;
//   }
//
//   static Map<String, dynamic>? vector2ToJson(Vector2? vec) {
//     if (vec == null) return null;
//     return {'x': vec.x, 'y': vec.y};
//   }
//
//   static Vector2? vector2FromJson(dynamic json) {
//     if (json == null || json is! Map<String, dynamic>) return null;
//     final x = json['x'];
//     final y = json['y'];
//     if (x is num && y is num) {
//       return Vector2(x.toDouble(), y.toDouble());
//     }
//     return null;
//   }
//
//   // --- End Helper functions ---
// }
//
// // Private implementation to allow fromJson construction and require clone override.
// class _FieldItemModelImpl extends FieldItemModel {
//   _FieldItemModelImpl({
//     required super.id,
//     required super.offset,
//     required super.fieldItemType,
//     required super.scaleSymmetrically,
//     required super.canBeCopied,
//     super.angle,
//     super.createdAt,
//     super.updatedAt,
//     // --- Add new properties to super constructor call ---
//     required super.size,
//     required super.color,
//     required super.opacity,
//   });
//
//   @override
//   FieldItemModel clone() {
//     // Use copyWith to create a deep copy (or shallow if properties are immutable)
//     return copyWith();
//   }
// }
