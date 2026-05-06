import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';

class TriangleShapeModel extends ShapeModel {
  Vector2? vertexA;
  Vector2? vertexB;
  Vector2? vertexC;

  TriangleShapeModel({
    // FieldItemModel properties
    required super.id,
    required Vector2 center, // The logical center of the triangle
    super.angle = 0.0, // Angle of rotation around the center
    Color? strokeColor,
    super.opacity,
    super.canBeCopied = false,
    super.createdAt,
    super.updatedAt,
    super.zIndex,

    // Shape properties
    super.fillColor,
    super.strokeWidth,

    // --- MODIFIED: Accept nullable vertices ---
    // Triangle specific properties (vertices relative to center)
    this.vertexA,
    this.vertexB,
    this.vertexC,
    // --- END MODIFICATION ---

    // Added these based on user's provided code in query
    required super.name,
    required super.imagePath,
  }) : super(
          offset: center, // Map center to the base 'offset'
          color: strokeColor, // Map strokeColor to the base 'color'
          fieldItemType: FieldItemType.TRIANGLE, // Set the specific type
          scaleSymmetrically: false,
          // Size needs to be calculated based on vertices if needed
          size: Vector2.zero(), // User had Vector2.zero() here
        );

  /// Gets the center position (same as offset).
  Vector2 get center =>
      offset ?? Vector2.zero(); // Handle potential null offset from base

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

  /// Creates a TriangleShapeModel instance from a JSON map.
  static TriangleShapeModel fromJson(Map<String, dynamic> json) {
    // Parse base FieldItemModel & Shape properties
    final id = json['_id'] as String? ?? '';
    final offset = FieldItemModel.offsetFromJson(json['offset']) ??
        Vector2.zero(); // Center
    final angle = (json['angle'] as num?)?.toDouble() ?? 0.0;
    final strokeColor = json['color'] != null ? Color(json['color']) : null;
    final opacity = (json['opacity'] as num?)?.toDouble() ?? 1.0;
    final canBeCopied = json['canBeCopied'] as bool? ?? false; // User had false
    final createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    final updatedAt =
        json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
    final zIndex = json['zIndex'] as int?;
    final fillColor =
        json['fillColor'] != null ? Color(json['fillColor']) : null;
    final strokeWidth = (json['strokeWidth'] as num?)?.toDouble() ?? 2.0;

    // --- MODIFIED: Parse nullable vertices ---
    // Parse Triangle specific properties (vertices relative to center)
    final vertexA = FieldItemModel.vector2FromJson(
      json['vertexA'],
    ); // Allow null
    final vertexB = FieldItemModel.vector2FromJson(
      json['vertexB'],
    ); // Allow null
    final vertexC = FieldItemModel.vector2FromJson(
      json['vertexC'],
    ); // Allow null
    // --- END MODIFICATION ---

    // Added based on user's provided code
    final name = json['name'] as String? ?? '';
    final imagePath = json['imagePath'] as String? ?? '';

    return TriangleShapeModel(
      id: id,
      center: offset,
      angle: angle,
      strokeColor: strokeColor,
      opacity: opacity,
      canBeCopied: canBeCopied,
      createdAt: createdAt,
      updatedAt: updatedAt,
      zIndex: zIndex,
      fillColor: fillColor,
      strokeWidth: strokeWidth,
      vertexA: vertexA, // Assign potentially null vertex
      vertexB: vertexB, // Assign potentially null vertex
      vertexC: vertexC, // Assign potentially null vertex
      name: name,
      imagePath: imagePath,
    );
  }

  /// Converts this TriangleShapeModel instance to a JSON map.
  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(), // Include base Shape and FieldItemModel fields
        // --- MODIFIED: Handle nullable vertices ---
        'vertexA': FieldItemModel.vector2ToJson(vertexA), // Pass nullable value
        'vertexB': FieldItemModel.vector2ToJson(vertexB), // Pass nullable value
        'vertexC': FieldItemModel.vector2ToJson(vertexC), // Pass nullable value
        // --- END MODIFICATION ---
      };

  // --- CopyWith, Clone, Equality ---

  /// Creates a copy of this instance with potentially modified properties.
  @override
  TriangleShapeModel copyWith({
    // FieldItemModel fields
    String? id,
    Vector2? offset, // Represents center
    bool? scaleSymmetrically,
    FieldItemType? fieldItemType, // Should remain TRIANGLE
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? size, // Usually ignored, calculated from vertices
    Color? color, // Represents strokeColor
    double? opacity,
    int? zIndex,
    // Shape fields
    Color? fillColor,
    double? strokeWidth,
    bool clearFillColor = false,
    // --- MODIFIED: Accept nullable vertices ---
    // Triangle fields
    Vector2? vertexA,
    Vector2? vertexB,
    Vector2? vertexC,
    // Added based on user's provided code
    String? name,
    String? imagePath,
    // --- END MODIFICATION ---
  }) {
    return TriangleShapeModel(
      id: id ?? this.id,
      center:
          offset ?? this.center.clone(), // Use getter which handles null offset
      angle: angle ?? this.angle,
      strokeColor: color ?? this.strokeColor, // Use getter
      opacity: opacity ?? this.opacity,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      zIndex: zIndex ?? this.zIndex,
      fillColor: clearFillColor ? null : (fillColor ?? this.fillColor),
      strokeWidth: strokeWidth ?? this.strokeWidth,
      // --- MODIFIED: Handle nullable assignment ---
      vertexA: vertexA ?? this.vertexA?.clone(),
      vertexB: vertexB ?? this.vertexB?.clone(),
      vertexC: vertexC ?? this.vertexC?.clone(),
      // --- END MODIFICATION ---
      name: name ?? this.name, // Added
      imagePath: imagePath ?? this.imagePath, // Added
    );
  }

  /// Creates a deep copy of this instance.
  @override
  TriangleShapeModel clone() => copyWith();

  // --- MODIFIED: Equality and hashCode handle nulls ---
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && // Check Shape and FieldItemModel equality
          other is TriangleShapeModel &&
          runtimeType == other.runtimeType &&
          vertexA == other.vertexA && // Default equality check handles null
          vertexB == other.vertexB &&
          vertexC == other.vertexC;

  @override
  int get hashCode =>
      super.hashCode ^ // Combine Shape and FieldItemModel hash code
      vertexA.hashCode ^ // Default hashCode handles null
      vertexB.hashCode ^
      vertexC.hashCode;
  // --- END MODIFICATION ---

  @override
  String toString() {
    // --- MODIFIED: Handle nulls in toString ---
    String baseStr = super.toString().replaceFirst(
          "ShapeModel(",
          "",
        ); // Assuming base class is ShapeModel now
    return 'TriangleShapeModel(A: ${vertexA?.toString() ?? 'null'}, B: ${vertexB?.toString() ?? 'null'}, C: ${vertexC?.toString() ?? 'null'}, $baseStr';
    // --- END MODIFICATION ---
  }
}
