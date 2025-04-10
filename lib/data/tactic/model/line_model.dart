import 'package:flame/components.dart';
import 'package:flutter/foundation.dart'; // For describeEnum, listEquals
import 'package:flutter/material.dart'; // For Color

// Assuming FieldItemModel and its helpers are defined correctly and imported
import 'field_item_model.dart';

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
  //   imagePath: "diagonal-line.png",

  LineModelV2({
    // FieldItemModel required properties
    required super.id,
    super.fieldItemType = FieldItemType.LINE, // Set the type
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

    // LineModel specific properties
    required this.end,
    required this.start,
    required this.lineType,
    this.thickness = 2.0,
    required this.name,
    required this.imagePath,
  }); // Call super constructor

  // --- Updated fromJson Static Factory Method ---
  static LineModelV2 fromJson(Map<String, dynamic> json) {
    // // --- Parse Base Class Properties ---
    // final baseModel = FieldItemModel.fromJson(json); // Use base factory
    //
    // zlog(data: "Line mode basemodel ${baseModel.fieldItemType}");
    //
    // --- Parse LineModel Specific Properties ---
    // 'start' is handled by baseModel.offset
    final start =
        FieldItemModel.vector2FromJson(json['start']) ?? Vector2.zero();
    final end = FieldItemModel.vector2FromJson(json['end']) ?? Vector2.zero();
    final lineColor = Color(
      json['lineColor'] as int? ?? Colors.black.value,
    ); // Use specific key 'lineColor'
    final thickness = (json['thickness'] as num?)?.toDouble() ?? 2.0;
    final lineType = LineType.values.firstWhere(
      (e) => describeEnum(e) == (json['lineType'] as String?),
      orElse: () => LineType.UNKNOWN,
    );
    final name = json['name'];
    final imagePath = json['imagePath'];

    final id = json['_id']; // Use helper
    final offset =
        FieldItemModel.offsetFromJson(json['offset']) ??
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
    final opacity =
        json['opacity'] == null
            ? null
            : double.parse(json['opacity'].toString());

    // --- Construct and Return LineModel Instance ---
    return LineModelV2(
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
      fieldItemType: FieldItemType.LINE, // Explicitly set type
      // Pass LineModel specific properties
      start: start,
      end: end,
      lineType: lineType,
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
    'start': FieldItemModel.vector2ToJson(start),
    'end': FieldItemModel.vector2ToJson(end),
    'name': name,
    'lineColor':
        color
            ?.value, // Use specific key 'lineColor' to avoid clash with base color
    'thickness': thickness,
    'lineType': lineType.toString().split('.').last,
    'imagePath': imagePath,
    // Note: 'start' is implicitly saved as 'offset' in super.toJson()
  };

  // --- Updated copyWith Method ---
  @override
  LineModelV2 copyWith({
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
    // LineModel properties
    Vector2? start,
    Vector2? end,
    Color? lineColor, // Parameter for line color
    double? thickness,
    LineType? lineType,
  }) => LineModelV2(
    // Base properties
    id: id ?? this.id,
    start: start ?? this.start.clone(), // Pass 'start' which sets 'offset'
    scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
    angle: angle ?? this.angle,
    canBeCopied: canBeCopied ?? this.canBeCopied,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    size: size ?? this.size?.clone(),
    color: color ?? this.color, // Base color
    opacity: opacity ?? this.opacity,
    fieldItemType: this.fieldItemType, // Keep original type
    // LineModel properties
    end: end ?? this.end.clone(),
    thickness: thickness ?? this.thickness,
    lineType: lineType ?? this.lineType,
    name: name,
    imagePath: imagePath,
  );

  // --- Updated clone Method ---
  @override
  LineModelV2 clone() => copyWith(); // clone uses copyWith

  // --- Updated operator == and hashCode ---
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineModelV2 &&
          // Check base properties (important ones like id, offset/start)
          super == other && // Use FieldItemModel's equality check
          // Check LineModel specific properties
          other.start == start &&
          other.end == end &&
          other.color == color && // Line color
          other.thickness == thickness &&
          other.lineType == lineType;

  @override
  int get hashCode =>
      // Combine base hash code with specific properties
      super.hashCode ^ // Use FieldItemModel's hashCode
      end.hashCode ^
      start.hashCode ^
      color.hashCode ^ // Line color
      thickness.hashCode ^
      lineType.hashCode;

  // --- Updated toString Method ---
  @override
  String toString() =>
      'LineModel(id: $id, start: $start, end: $end, lineColor: $color, thickness: $thickness, lineType: $lineType, ${super.toString().replaceFirst("FieldItemModel(", "")}'; // Include some base info
}
