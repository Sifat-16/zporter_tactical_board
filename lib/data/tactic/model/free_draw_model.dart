import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // For Color

// Assuming FieldItemModel and its helpers are defined correctly and imported
import 'field_item_model.dart';

class FreeDrawModelV2 extends FieldItemModel {
  List<Vector2> points;
  double thickness;
  String name;
  String imagePath;
  //   imagePath: "diagonal-line.png",

  FreeDrawModelV2({
    // FieldItemModel required properties
    required super.id,
    super.fieldItemType = FieldItemType.FREEDRAW, // Set the type
    // FieldItemModel optional properties (pass them to super)
    super.angle,
    super.canBeCopied = true,
    super.scaleSymmetrically =
        false, // Lines typically don't scale symmetrically
    super.createdAt,
    super.updatedAt,
    super.size, // Size might be calculated from start/end or ignored for lines
    super.color, // Base color (optional, maybe unused for Line)
    super.opacity,
    super.offset,
    super.zIndex,

    // LineModel specific properties
    required this.points,
    this.thickness = 2.0,
    this.name = "FREE-DRAW",
    this.imagePath = "assets/images/free-draw.png",
  }); // Call super constructor

  // --- Updated fromJson Static Factory Method ---
  static FreeDrawModelV2 fromJson(Map<String, dynamic> json) {
    final thickness = (json['thickness'] as num?)?.toDouble() ?? 2.0;

    final name = json['name'];
    final imagePath = json['imagePath'];

    final id = json['_id']; // Use helper
    final offset = FieldItemModel.offsetFromJson(json['offset']) ??
        Vector2.zero(); // Use helper + Default
    final scaleSymmetrically =
        json['scaleSymmetrically'] as bool? ?? true; // Default from constructor
    final angle = json['angle'] as double?;
    final canBeCopied =
        json['canBeCopied'] as bool? ?? false; // Default from constructor
    final createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    final updatedAt =
        json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
    final size = FieldItemModel.vector2FromJson(json['size']); // Use helper
    final color = json['color'] != null ? Color(json['color']) : null;
    final opacity = json['opacity'] == null
        ? null
        : double.parse(json['opacity'].toString());
    final zIndex = json['zIndex'] as int?;

    // --- Construct and Return LineModel Instance ---
    return FreeDrawModelV2(
      // Pass base properties from parsed FieldItemModel
      id: id,
      offset: offset ?? Vector2.zero(), // Use offset as start
      angle: angle,
      canBeCopied: canBeCopied,
      scaleSymmetrically: scaleSymmetrically,
      createdAt: createdAt,
      updatedAt: updatedAt,
      size: size,
      color: color, // Base color
      opacity: opacity,
      zIndex: zIndex,
      fieldItemType: FieldItemType.FREEDRAW, // Explicitly set type
      // Pass LineModel specific properties
      points: (json['points'] as List<dynamic>?)
              ?.map(
                (pointJson) =>
                    FieldItemModel.vector2FromJson(pointJson) ?? Vector2.zero(),
              )
              .toList() ??
          [],
      thickness: thickness,
      name: name,
      imagePath: imagePath,
    );
  }

  // --- Updated toJson Method ---
  @override
  Map<String, dynamic> toJson() => {
        ...super
            .toJson(), // Includes base fields (id, offset (as start), type=LINE, etc.)
        // Add LineModel specific fields
        'points': points.map((p) => FieldItemModel.vector2ToJson(p)).toList(),
        'name': name,
        'lineColor': color
            ?.value, // Use specific key 'lineColor' to avoid clash with base color
        'thickness': thickness,

        'imagePath': imagePath,
        // Note: 'start' is implicitly saved as 'offset' in super.toJson()
      };

  // --- Updated copyWith Method ---
  @override
  FreeDrawModelV2 copyWith({
    String? id,
    Vector2? offset,
    bool? scaleSymmetrically,
    FieldItemType? fieldItemType,
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? size,
    Color? color,
    double? opacity,
    int? zIndex,
    // LineModel properties
    Color? lineColor, // Parameter for line color
    double? thickness,
    List<Vector2>? points,
  }) =>
      FreeDrawModelV2(
        // Base properties
        id: id ?? this.id,
        points: points ?? this.points,
        scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
        angle: angle ?? this.angle,
        canBeCopied: canBeCopied ?? this.canBeCopied,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        size: size ?? this.size?.clone(),
        color: color ?? this.color, // Base color
        opacity: opacity ?? this.opacity,
        zIndex: zIndex ?? this.zIndex,
        fieldItemType: this.fieldItemType, // Keep original type
        // LineModel properties
        thickness: thickness ?? this.thickness,
        name: name,
        imagePath: imagePath,
      );

  // --- Updated clone Method ---
  @override
  FreeDrawModelV2 clone() => copyWith(); // clone uses copyWith

  // --- Updated operator == and hashCode ---
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreeDrawModelV2 &&
          // Check base properties (important ones like id, offset/start)
          super == other && // Use FieldItemModel's equality check
          // Check LineModel specific properties
          other.points == points &&
          other.color == color && // Line color
          other.thickness == thickness;

  @override
  int get hashCode =>
      // Combine base hash code with specific properties
      super.hashCode ^ // Use FieldItemModel's hashCode
      points.hashCode ^
      color.hashCode ^ // Line color
      thickness.hashCode;

  // --- Updated toString Method ---
  @override
  String toString() =>
      'FreeDrawModelV2 (id: $id, points: $points, lineColor: $color, thickness: $thickness, lineType:'; // Include some base info
}
