import 'package:flame/components.dart';
import 'package:flutter/foundation.dart'; // For describeEnum, listEquals
import 'package:flutter/material.dart'; // For Color

// Assuming FieldItemModel and its helpers are defined correctly and imported
import 'field_item_model.dart'; // Make sure this path is correct

// --- FormItemModel Hierarchy (Keep as provided) ---

enum FormType { TEXT, LINE, FREE_DRAW, UNKNOWN }

enum LineType {
  STRAIGHT_LINE,
  STRAIGHT_LINE_DASHED,
  STRAIGHT_LINE_ZIGZAG,
  STRAIGHT_LINE_ZIGZAG_ARROW,
  STRAIGHT_LINE_ARROW,
  STRAIGHT_LINE_ARROW_DOUBLE,
  RIGHT_TURN_ARROW,
  UNKNOWN,
}

class LineModelV2 extends FieldItemModel {
  Vector2 end;
  Vector2 start;
  double thickness;
  LineType lineType;
  String name;
  String imagePath;
  // NEW: Optional fields for control points
  Vector2? controlPoint1;
  Vector2? controlPoint2;

  LineModelV2({
    // FieldItemModel required properties
    required super.id,
    super.fieldItemType = FieldItemType.LINE,
    // FieldItemModel optional properties
    super.angle,
    super.canBeCopied = true,
    super.scaleSymmetrically = false,
    super.createdAt,
    super.updatedAt,
    super.size,
    super.color, // Base color (can store line color here too now)
    super.opacity,
    super.offset,

    // LineModel specific properties
    required this.end,
    required this.start,
    required this.lineType,
    this.thickness = 2.0,
    required this.name,
    required this.imagePath,
    // NEW: Add control points to constructor (optional)
    this.controlPoint1,
    this.controlPoint2,
  });

  // --- Updated fromJson Static Factory Method ---
  static LineModelV2 fromJson(Map<String, dynamic> json) {
    // --- Parse Base FieldItemModel Properties ---

    final id =
        json['_id'] as String? ?? ''; // Example: handle potential null id
    final offset =
        FieldItemModel.offsetFromJson(json['offset']) ?? Vector2.zero();
    final scaleSymmetrically = json['scaleSymmetrically'] as bool? ?? false;
    final angle =
        (json['angle'] as num?)?.toDouble(); // Allow num for flexibility
    final canBeCopied = json['canBeCopied'] as bool? ?? true;
    final createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    final updatedAt =
        json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
    final size = FieldItemModel.vector2FromJson(json['size']);
    final color =
        json['color'] != null
            ? Color(json['color'])
            : null; // Use base 'color' for line color
    final opacity =
        (json['opacity'] as num?)?.toDouble() ?? 1.0; // Default opacity to 1.0
    final fieldItemType = FieldItemType.values.firstWhere(
      (e) => e.name == (json['fieldItemType'] as String?),
      orElse: () => FieldItemType.LINE, // Default to LINE if missing/invalid
    );

    // --- Parse LineModel Specific Properties ---
    final start =
        FieldItemModel.vector2FromJson(json['start']) ??
        offset; // Use offset as fallback for start
    final end = FieldItemModel.vector2FromJson(json['end']) ?? Vector2.zero();
    final thickness = (json['thickness'] as num?)?.toDouble() ?? 2.0;
    final lineType = LineType.values.firstWhere(
      (e) => describeEnum(e) == (json['lineType'] as String?),
      orElse:
          () =>
              LineType
                  .STRAIGHT_LINE, // Default to straight line if missing/invalid
    );
    final name = json['name'] as String? ?? '';
    final imagePath = json['imagePath'] as String? ?? '';

    // --- NEW: Parse Control Points (Optional) ---
    final controlPoint1 = FieldItemModel.vector2FromJson(json['controlPoint1']);
    final controlPoint2 = FieldItemModel.vector2FromJson(json['controlPoint2']);

    return LineModelV2(
      // Base properties
      id: id,
      offset:
          offset, // Keep original offset behavior if needed, or sync with start
      angle: angle,
      canBeCopied: canBeCopied,
      scaleSymmetrically: scaleSymmetrically,
      createdAt: createdAt,
      updatedAt: updatedAt,
      size: size,
      color: color, // Set base color as line color
      opacity: opacity,
      fieldItemType: fieldItemType,
      // LineModel specific properties
      start: start,
      end: end,
      lineType: lineType,
      thickness: thickness,
      name: name,
      imagePath: imagePath,
      // NEW: Assign parsed control points
      controlPoint1: controlPoint1,
      controlPoint2: controlPoint2,
    );
  }

  // --- Updated toJson Method ---
  @override
  Map<String, dynamic> toJson() {
    // Ensure base offset matches start if that's the convention
    // super.offset = start; // Uncomment if offset should always be start

    return {
      ...super.toJson(), // Includes base fields (id, offset, type=LINE, etc.)
      // Add/Override LineModel specific fields
      'start': FieldItemModel.vector2ToJson(start), // Explicitly save start
      'end': FieldItemModel.vector2ToJson(end),
      'name': name,
      // 'color' is handled by super.toJson() now for line color
      'thickness': thickness,
      'lineType': describeEnum(lineType), // Use describeEnum for safety
      'imagePath': imagePath,
      // NEW: Conditionally add control points if they exist
      if (controlPoint1 != null)
        'controlPoint1': FieldItemModel.vector2ToJson(controlPoint1!),
      if (controlPoint2 != null)
        'controlPoint2': FieldItemModel.vector2ToJson(controlPoint2!),
    };
  }

  // --- Updated copyWith Method ---
  @override
  LineModelV2 copyWith({
    // FieldItemModel parameters
    String? id,
    Vector2? offset,
    bool? scaleSymmetrically,
    FieldItemType? fieldItemType,
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? size,
    Color? color, // Handles line color now
    double? opacity,
    // LineModel parameters
    Vector2? start,
    Vector2? end,
    // Removed lineColor param as base 'color' is used
    double? thickness,
    LineType? lineType,
    String? name, // Added missing name/imagePath
    String? imagePath,
    // NEW: Control point parameters
    Vector2? controlPoint1,
    Vector2? controlPoint2,
    // Add a flag to explicitly clear control points if needed
    bool clearControlPoints = false,
  }) {
    // Handle clearing control points
    Vector2? cp1 =
        clearControlPoints
            ? null
            : (controlPoint1 ?? this.controlPoint1?.clone());
    Vector2? cp2 =
        clearControlPoints
            ? null
            : (controlPoint2 ?? this.controlPoint2?.clone());

    // If start is provided, update offset accordingly if they should match
    Vector2 finalOffset =
        offset ??
        (start != null
            ? start.clone()
            : this.offset?.clone() ?? Vector2.zero());

    return LineModelV2(
      // Base properties
      id: id ?? this.id,
      offset: finalOffset, // Use updated offset logic
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      angle: angle ?? this.angle,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      size: size ?? this.size?.clone(),
      color: color ?? this.color, // Use base color
      opacity: opacity ?? this.opacity,
      fieldItemType:
          fieldItemType ??
          this.fieldItemType, // Allow changing type? Usually no.
      // LineModel properties
      start: start ?? this.start.clone(), // Ensure start is updated
      end: end ?? this.end.clone(),
      thickness: thickness ?? this.thickness,
      lineType: lineType ?? this.lineType,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      // NEW: Control points
      controlPoint1: cp1,
      controlPoint2: cp2,
    );
  }

  // --- Updated clone Method ---
  @override
  LineModelV2 clone() => copyWith(); // clone uses copyWith

  // --- Updated operator == and hashCode ---
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineModelV2 &&
          super == other && // Use FieldItemModel's equality check
          other.end == end &&
          other.start ==
              start && // Ensure start is compared (part of super== if offset==start)
          other.thickness == thickness &&
          other.lineType == lineType &&
          other.name == name &&
          other.imagePath == imagePath &&
          other.controlPoint1 == controlPoint1 && // NEW
          other.controlPoint2 == controlPoint2; // NEW

  @override
  int get hashCode =>
      super.hashCode ^ // Use FieldItemModel's hashCode
      end.hashCode ^
      start.hashCode ^ // Ensure start is included
      thickness.hashCode ^
      lineType.hashCode ^
      name.hashCode ^
      imagePath.hashCode ^
      controlPoint1.hashCode ^ // NEW
      controlPoint2.hashCode; // NEW

  // --- Updated toString Method ---
  @override
  String toString() {
    String baseString = super.toString().replaceFirst("FieldItemModel(", "");
    return 'LineModelV2(id: $id, start: $start, end: $end, color: $color, thickness: $thickness, lineType: $lineType, name: $name, cp1: $controlPoint1, cp2: $controlPoint2, $baseString';
  }
}
