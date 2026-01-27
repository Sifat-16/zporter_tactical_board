import 'dart:ui';

import 'package:flame/components.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';

import 'field_item_model.dart';

class CircleShapeModel extends ShapeModel {
  /// The radius of the circle.
  double radius;

  CircleShapeModel({
    // FieldItemModel properties
    required super.id,
    required Vector2 center, // Use 'center' for clarity, maps to 'offset'
    super.angle, // Usually circles don't rotate visually unless textured
    Color? strokeColor, // Use base 'color' for stroke
    super.opacity,
    required super.canBeCopied,
    super.createdAt,
    super.updatedAt,
    super.zIndex,
    required super.name,
    required super.imagePath,

    // Shape properties
    super.fillColor, // Pass fillColor to Shape constructor
    super.strokeWidth, // Pass strokeWidth to Shape constructor
    // Circle specific properties
    required this.radius,
  }) : super(
          offset: center, // Map center to the base 'offset' property
          color: strokeColor, // Map strokeColor to the base 'color' property
          fieldItemType:
              FieldItemType.CIRCLE, // Set the specific type for this model
          // Circles scale symmetrically, size is related to radius
          scaleSymmetrically: true,
          size: Vector2(radius * 2, radius * 2), // Set size based on radius
        );

  /// Gets the center position (same as offset).
  Vector2 get center => offset ?? Vector2.zero();

  /// Sets the center position (updates offset).
  set center(Vector2 value) {
    offset = value;
  }

  /// Gets the stroke color (same as base color).
  Color? get strokeColor => color;

  /// Sets the stroke color (updates base color).
  set strokeColor(Color? value) {
    color = value;
  }

  // --- Serialization ---

  /// Creates a CircleShapeModel instance from a JSON map.
  static CircleShapeModel fromJson(Map<String, dynamic> json) {
    // Parse base FieldItemModel properties first
    final id = json['_id'] as String? ?? '';
    final offset = FieldItemModel.offsetFromJson(json['offset']) ??
        Vector2.zero(); // Center
    final angle = (json['angle'] as num?)?.toDouble();
    final strokeColor = json['color'] != null
        ? Color(json['color'])
        : null; // Stroke from base color
    final opacity = (json['opacity'] as num?)?.toDouble() ?? 1.0;
    final canBeCopied = json['canBeCopied'] as bool? ?? true;
    final createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    final updatedAt =
        json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
    final zIndex = json['zIndex'] as int?;

    // Parse Shape specific properties
    final fillColor =
        json['fillColor'] != null ? Color(json['fillColor']) : null;
    final strokeWidth = (json['strokeWidth'] as num?)?.toDouble() ?? 2.0;

    // Parse Circle specific properties
    final radius = (json['radius'] as num?)?.toDouble() ??
        10.0; // Default radius if missing

    final name = json['name'] as String? ?? '';
    final imagePath = json['imagePath'] as String? ?? '';

    return CircleShapeModel(
      id: id,
      center: offset, // Use offset as center
      angle: angle,
      strokeColor: strokeColor,
      opacity: opacity,
      canBeCopied: canBeCopied,
      createdAt: createdAt,
      updatedAt: updatedAt,
      zIndex: zIndex,
      fillColor: fillColor,
      strokeWidth: strokeWidth,
      radius: radius,
      name: name,
      imagePath: imagePath,
    );
  }

  /// Converts this CircleShapeModel instance to a JSON map.
  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(), // Include base Shape and FieldItemModel fields
        'radius': radius,
        // 'center' is saved as 'offset' in super.toJson()
        // 'strokeColor' is saved as 'color' in super.toJson()
        // 'fillColor' and 'strokeWidth' are saved in super.toJson() from Shape
      };

  // --- CopyWith, Clone, Equality ---

  /// Creates a copy of this instance with potentially modified properties.
  @override
  CircleShapeModel copyWith({
    // FieldItemModel fields
    String? id,
    Vector2? offset, // Represents center
    bool? scaleSymmetrically, // Usually true for circles
    FieldItemType? fieldItemType, // Should remain CIRCLE
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? size, // Ignored, calculated from radius
    Color? color, // Represents strokeColor
    double? opacity,
    int? zIndex,
    // Shape fields
    Color? fillColor,
    double? strokeWidth,
    bool clearFillColor = false, // Flag from Shape copyWith
    // Circle fields
    double? radius,
  }) {
    return CircleShapeModel(
      id: id ?? this.id,
      center: offset ?? this.center.clone(), // Use center getter/setter logic
      angle: angle ?? this.angle,
      strokeColor: color ?? this.strokeColor, // Use color getter/setter logic
      opacity: opacity ?? this.opacity,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      zIndex: zIndex ?? this.zIndex,
      // Pass shape fields to super
      fillColor: clearFillColor ? null : (fillColor ?? this.fillColor),
      strokeWidth: strokeWidth ?? this.strokeWidth,
      // Pass circle field
      radius: radius ?? this.radius,
      name: name,
      imagePath: imagePath,
    );
  }

  /// Creates a deep copy of this instance.
  @override
  CircleShapeModel clone() => copyWith();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && // Check Shape and FieldItemModel equality
          other is CircleShapeModel &&
          runtimeType == other.runtimeType &&
          radius == other.radius;

  @override
  int get hashCode =>
      super.hashCode ^ // Combine Shape and FieldItemModel hash code
      radius.hashCode;

  @override
  String toString() {
    // Remove "Shape(" from super.toString() for cleaner output
    String baseStr = super.toString().replaceFirst("Shape(", "");
    return 'CircleShapeModel(radius: $radius, $baseStr';
  }
}
