import 'dart:ui';

import 'package:flame/components.dart';

import 'field_item_model.dart';

abstract class ShapeModel extends FieldItemModel {
  /// The color used to fill the shape's area. Null means no fill.
  Color? fillColor;

  /// The width of the shape's outline/stroke. Defaults to 2.0.
  double strokeWidth;

  String name;
  String imagePath;

  // Note: We can use the inherited `color` property from FieldItemModel
  // as the `strokeColor` by convention.

  ShapeModel({
    // Required FieldItemModel properties
    required super.id,
    required super.offset, // Often represents the shape's center or anchor
    required super.fieldItemType, // Must be provided by subclasses
    // Optional FieldItemModel properties
    super.size, // Might represent bounding box or be calculated
    super.angle,
    super.color, // Conventionally used as strokeColor
    super.opacity,
    required super.canBeCopied,
    required super.scaleSymmetrically,
    super.createdAt,
    super.updatedAt,

    required this.name,
    required this.imagePath,

    // Shape specific properties
    this.fillColor,
    this.strokeWidth = 2.0, // Default stroke width
  });

  // Subclasses need to implement toJson, fromJson, copyWith, etc.
  // We can add common serialization logic here if desired.
  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(), // Include base fields
    'fillColor': fillColor?.toARGB32(),
    'strokeWidth': strokeWidth,
    'name': name,
    'imagePath': imagePath,
    // 'strokeColor' is saved as 'color' in super.toJson()
  };

  // copyWith needs to be implemented by subclasses to return the correct type
  @override
  ShapeModel copyWith({
    // Base fields
    String? id,
    Vector2? offset,
    bool? scaleSymmetrically,
    FieldItemType? fieldItemType,
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? size,
    Color? color, // Represents strokeColor
    double? opacity,
    // Shape fields
    Color? fillColor,
    double? strokeWidth,
    // Flag to explicitly clear fillColor
    bool clearFillColor = false,
  });

  // clone needs to be implemented by subclasses
  @override
  ShapeModel clone();

  // Equality and hashCode should also consider shape properties
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && // Check base equality
          other is ShapeModel &&
          runtimeType == other.runtimeType &&
          fillColor == other.fillColor &&
          strokeWidth == other.strokeWidth;

  @override
  int get hashCode =>
      super.hashCode ^ // Combine base hash code
      fillColor.hashCode ^
      strokeWidth.hashCode;

  @override
  String toString() {
    // Remove "FieldItemModel(" from super.toString() for cleaner output
    String baseStr = super.toString().replaceFirst("FieldItemModel(", "");
    return 'Shape(fillColor: $fillColor, strokeWidth: $strokeWidth, $baseStr';
  }
}
