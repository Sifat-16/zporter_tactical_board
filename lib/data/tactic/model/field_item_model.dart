import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // Import for Color
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';

import 'equipment_model.dart';
import 'form_model.dart';

enum FieldItemType { PLAYER, EQUIPMENT, LINE, FREEDRAW }

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
    if (typeString == null) {
      throw Exception(
        'FieldItemModel JSON missing required field: fieldItemType',
      );
    }

    // Find the enum value corresponding to the string
    final fieldItemType = FieldItemType.values.firstWhere(
      (e) {
        // zlog(data: "Field item type string enum ${e}");
        return e.toString().split('.').last == typeString;
      },
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
      // case FieldItemType.FORM:
      //   // Assumes FormModel has static FormModel fromJson(Map<String, dynamic> json)
      //   return FormModel.fromJson(json);
      case FieldItemType.EQUIPMENT:
        // Assumes EquipmentModel has static EquipmentModel fromJson(Map<String, dynamic> json)
        return EquipmentModel.fromJson(json);
      // Add cases for any other FieldItemType values
      // No default case needed if all enum values are handled and we throw on invalid string
      case FieldItemType.LINE:
        // TODO: Handle this case.
        return LineModelV2.fromJson(json);
      case FieldItemType.FREEDRAW:
        // TODO: Handle this case.
        return FreeDrawModelV2.fromJson(json);
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
}
