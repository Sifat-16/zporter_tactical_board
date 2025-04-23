import 'package:flame/components.dart'; // For Vector2
import 'package:flutter/material.dart'; // For Color
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart'; // For base class, FieldItemType and helpers
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart'; // Assuming Shape is here

/// Data model representing a square shape on the tactical board.
class SquareShapeModel extends ShapeModel {
  /// The length of each side of the square.
  /// It's recommended to store this as a *relative* value (e.g., a fraction
  /// of the minimum game field dimension) to ensure responsiveness.
  double side;

  SquareShapeModel({
    // FieldItemModel properties
    required super.id,
    required Vector2 center, // Use 'center' for clarity, maps to 'offset'
    super.angle = 0.0, // Squares can rotate
    Color? strokeColor, // Use base 'color' for stroke
    super.opacity,
    required super.canBeCopied,
    super.createdAt,
    super.updatedAt,

    // Shape properties
    super.fillColor,
    super.strokeWidth,
    required super.name,
    required super.imagePath,

    required this.side, // Store the relative side length
  }) : super(
         offset: center, // Map center to the base 'offset' property
         color: strokeColor, // Map strokeColor to the base 'color' property
         fieldItemType: FieldItemType.SQUARE, // Set the specific type
         scaleSymmetrically: true, // Squares scale symmetrically
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

  /// Creates a SquareShapeModel instance from a JSON map.
  static SquareShapeModel fromJson(Map<String, dynamic> json) {
    // Parse base FieldItemModel & Shape properties
    final id = json['_id'] as String? ?? '';
    final offset =
        FieldItemModel.offsetFromJson(json['offset']) ??
        Vector2.zero(); // Center
    final angle = (json['angle'] as num?)?.toDouble() ?? 0.0;
    final strokeColor = json['color'] != null ? Color(json['color']) : null;
    final opacity = (json['opacity'] as num?)?.toDouble() ?? 1.0;
    final canBeCopied = json['canBeCopied'] as bool? ?? true;
    final createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    final updatedAt =
        json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
    final fillColor =
        json['fillColor'] != null ? Color(json['fillColor']) : null;
    final strokeWidth = (json['strokeWidth'] as num?)?.toDouble() ?? 2.0;

    // Parse Square specific properties
    // Assume 'side' is stored as a relative value (double)
    final side =
        (json['side'] as num?)?.toDouble() ??
        0.1; // Default relative side length
    final name = json['name'] as String? ?? '';
    final imagePath = json['imagePath'] as String? ?? '';

    return SquareShapeModel(
      id: id,
      center: offset,
      angle: angle,
      strokeColor: strokeColor,
      opacity: opacity,
      canBeCopied: canBeCopied,
      createdAt: createdAt,
      updatedAt: updatedAt,
      fillColor: fillColor,
      strokeWidth: strokeWidth,
      side: side,
      name: name,
      imagePath: imagePath, // Assign the relative side length
    );
  }

  /// Converts this SquareShapeModel instance to a JSON map.
  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(), // Include base Shape and FieldItemModel fields
    'side': side, // Save the relative side length
    // 'center' is saved as 'offset' in super.toJson()
    // 'strokeColor' is saved as 'color' in super.toJson()
    // 'fillColor', 'strokeWidth', 'angle' are saved in super.toJson()
  };

  // --- CopyWith, Clone, Equality ---

  /// Creates a copy of this instance with potentially modified properties.
  @override
  SquareShapeModel copyWith({
    // FieldItemModel fields
    String? id,
    Vector2? offset, // Represents center
    bool? scaleSymmetrically, // Usually true for squares
    FieldItemType? fieldItemType, // Should remain SQUARE
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? size, // Ignored
    Color? color, // Represents strokeColor
    double? opacity,
    // Shape fields
    Color? fillColor,
    double? strokeWidth,
    bool clearFillColor = false,
    // Square fields
    double? side, // Relative side length
  }) {
    return SquareShapeModel(
      id: id ?? this.id,
      center: offset ?? this.center.clone(),
      angle: angle ?? this.angle,
      strokeColor: color ?? this.strokeColor,
      opacity: opacity ?? this.opacity,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fillColor: clearFillColor ? null : (fillColor ?? this.fillColor),
      strokeWidth: strokeWidth ?? this.strokeWidth,
      side: side ?? this.side, // Copy the relative side length
      name: name,
      imagePath: imagePath,
    );
  }

  /// Creates a deep copy of this instance.
  @override
  SquareShapeModel clone() => copyWith();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && // Check Shape and FieldItemModel equality
          other is SquareShapeModel &&
          runtimeType == other.runtimeType &&
          side == other.side;

  @override
  int get hashCode =>
      super.hashCode ^ // Combine Shape and FieldItemModel hash code
      side.hashCode;

  @override
  String toString() {
    String baseStr = super.toString().replaceFirst("Shape(", "");
    return 'SquareShapeModel(side: $side, $baseStr';
  }
}
