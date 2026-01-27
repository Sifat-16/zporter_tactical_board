import 'package:flame/components.dart'; // For Vector2
import 'package:flutter/foundation.dart'; // For describeEnum, listEquals
import 'package:flutter/material.dart'; // For Color
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart'; // For base class, FieldItemType and helpers
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart'; // Assuming Shape is here

/// Data model representing a polygon shape defined by a list of vertices.
class PolygonShapeModel extends ShapeModel {
  /// List of vertices defining the polygon, relative to the center (offset).
  List<Vector2> relativeVertices;

  /// Optional: Maximum number of vertices this polygon can have.
  /// If null, there is no limit (or limit is handled elsewhere).
  int? maxVertices;

  /// Optional: Minimum number of vertices this polygon must have.
  /// Defaults to 2, as a line requires at least two points.
  final int minVertices;

  PolygonShapeModel({
    // FieldItemModel properties
    required super.id,
    required Vector2 center, // The geometric center of the polygon
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

    // Polygon specific properties
    required this.relativeVertices,
    required this.maxVertices,
    this.minVertices = 2, // <<< ADDED minVertices parameter with default
    // Added based on user's previous models
    required super.name,
    required super.imagePath,
  }) : super(
          offset: center, // Map center to the base 'offset'
          color: strokeColor, // Map strokeColor to the base 'color'
          fieldItemType: FieldItemType.POLYGON, // Set the specific type
          scaleSymmetrically:
              false, // Polygons generally don't scale symmetrically
          size: null, // Bounding box size can be calculated if needed
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

  /// Creates a PolygonShapeModel instance from a JSON map.
  static PolygonShapeModel fromJson(Map<String, dynamic> json) {
    // Parse base FieldItemModel & Shape properties
    final id = json['_id'] as String? ?? '';
    final offset = FieldItemModel.offsetFromJson(json['offset']) ??
        Vector2.zero(); // Center
    final angle = (json['angle'] as num?)?.toDouble() ?? 0.0;
    final strokeColor = json['color'] != null ? Color(json['color']) : null;
    final opacity = (json['opacity'] as num?)?.toDouble() ?? 1.0;
    final canBeCopied =
        json['canBeCopied'] as bool? ?? true; // Adjust default if needed
    final createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    final updatedAt =
        json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
    final zIndex = json['zIndex'] as int?;
    final fillColor =
        json['fillColor'] != null ? Color(json['fillColor']) : null;
    final strokeWidth = (json['strokeWidth'] as num?)?.toDouble() ?? 2.0;
    final name = json['name'] as String? ?? '';
    final imagePath = json['imagePath'] as String? ?? '';

    // Parse Polygon specific properties (list of vertices)
    List<Vector2> vertices = [];
    if (json['relativeVertices'] is List) {
      vertices = (json['relativeVertices'] as List)
          .map((vJson) => FieldItemModel.vector2FromJson(vJson))
          .whereType<Vector2>() // Filter out any nulls from parsing
          .toList();
    }

    final maxVertices = json['maxVertices'] as int?;
    // <<< ADDED: Parse minVertices, defaulting to 2 if not present
    final minVertices = json['minVertices'] as int? ?? 2;

    return PolygonShapeModel(
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
      relativeVertices: vertices,
      maxVertices: maxVertices,
      minVertices: minVertices, // <<< ADDED
      name: name,
      imagePath: imagePath,
    );
  }

  /// Converts this PolygonShapeModel instance to a JSON map.
  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(), // Include base Shape and FieldItemModel fields
        'relativeVertices': relativeVertices
            .map((v) => FieldItemModel.vector2ToJson(v))
            .toList(),
        if (maxVertices != null) 'maxVertices': maxVertices,
        // <<< ADDED: Serialize minVertices (it has a default, so always include or only if not default?)
        // For consistency, let's always include it.
        'minVertices': minVertices,
      };

  // --- CopyWith, Clone, Equality ---

  /// Creates a copy of this instance with potentially modified properties.
  @override
  PolygonShapeModel copyWith({
    // FieldItemModel fields
    String? id,
    Vector2? offset, // Represents center
    bool? scaleSymmetrically,
    FieldItemType? fieldItemType, // Should remain POLYGON
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? size, // Usually ignored
    Color? color, // Represents strokeColor
    double? opacity,
    int? zIndex,
    // Shape fields
    Color? fillColor,
    double? strokeWidth,
    bool clearFillColor = false,
    // Polygon fields
    List<Vector2>? relativeVertices,
    int? maxVertices,
    int? minVertices, // <<< ADDED
    // Added based on user's previous models
    String? name,
    String? imagePath,
  }) {
    return PolygonShapeModel(
      id: id ?? this.id,
      center: offset ?? this.center.clone(),
      angle: angle ?? this.angle,
      strokeColor: color ?? this.strokeColor,
      opacity: opacity ?? this.opacity,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      zIndex: zIndex ?? this.zIndex,
      fillColor: clearFillColor ? null : (fillColor ?? this.fillColor),
      strokeWidth: strokeWidth ?? this.strokeWidth,
      relativeVertices: relativeVertices ??
          this.relativeVertices.map((v) => v.clone()).toList(),
      maxVertices: maxVertices ?? this.maxVertices,
      minVertices: minVertices ?? this.minVertices, // <<< ADDED
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  /// Creates a deep copy of this instance.
  @override
  PolygonShapeModel clone() => copyWith();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && // Check Shape and FieldItemModel equality
          other is PolygonShapeModel &&
          runtimeType == other.runtimeType &&
          listEquals(relativeVertices, other.relativeVertices) &&
          maxVertices == other.maxVertices &&
          minVertices == other.minVertices; // <<< ADDED to equality check

  @override
  int get hashCode =>
      super.hashCode ^ // Combine base hash code
      Object.hashAll(relativeVertices) ^
      maxVertices.hashCode ^
      minVertices.hashCode; // <<< ADDED to hash code

  @override
  String toString() {
    String baseStr = super.toString().replaceFirst("ShapeModel(", "");
    // <<< ADDED minVertices and maxVertices to toString
    return 'PolygonShapeModel(vertices: ${relativeVertices.length}, minVertices: $minVertices, maxVertices: $maxVertices, $baseStr';
  }
}
