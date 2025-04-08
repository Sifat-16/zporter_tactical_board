import 'package:flame/components.dart';
import 'package:flutter/foundation.dart'; // For describeEnum, listEquals
import 'package:flutter/material.dart'; // For Color

// Assuming FieldItemModel and its helpers are defined correctly and imported
import 'field_item_model.dart';

// --- FormItemModel Hierarchy (Keep as provided) ---

enum FormType { TEXT, LINE, FREE_DRAW, UNKNOWN }

// abstract class FormItemModel {
//   final FormType formType;
//
//   FormItemModel({required this.formType});
//   Map<String, dynamic> toJson();
//   FormItemModel clone();
//   Map<String, dynamic> baseToJson() => {'formType': describeEnum(formType)};
//
//   factory FormItemModel.fromJson(Map<String, dynamic>? json) {
//     if (json == null) {
//       throw ArgumentError('Cannot create FormItemModel from null JSON');
//     }
//     final typeString = json['formType'] as String?;
//     final formType = FormType.values.firstWhere(
//       (e) => describeEnum(e) == typeString,
//       orElse: () => FormType.UNKNOWN,
//     );
//
//     switch (formType) {
//       case FormType.TEXT:
//         return FormTextModel.fromJson(json);
//       // case FormType.LINE:
//       //   return LineModel.fromJson(json);
//       // case FormType.FREE_DRAW:
//       //   return FreeDrawModel.fromJson(json);
//       case FormType.UNKNOWN:
//       default:
//         throw UnimplementedError(
//           'fromJson not implemented for formType: $formType',
//         );
//     }
//   }
// }

// --- Concrete FormItemModel Subclasses (Keep as provided) ---

// class FormTextModel extends FormItemModel {
//   String text;
//   FormTextModel({required this.text}) : super(formType: FormType.TEXT);
//   FormTextModel.fromJson(Map<String, dynamic> json)
//     : text = json['text'] as String? ?? '',
//       super(formType: FormType.TEXT);
//   @override
//   Map<String, dynamic> toJson() => {...super.baseToJson(), 'text': text};
//   @override
//   FormTextModel clone() => FormTextModel(text: text);
// }

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
      fieldItemType: FieldItemType.FREEDRAW, // Explicitly set type
      // Pass LineModel specific properties
      points:
          (json['points'] as List<dynamic>?)
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
    'lineColor':
        color
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
    // LineModel properties
    Color? lineColor, // Parameter for line color
    double? thickness,
    List<Vector2>? points,
  }) => FreeDrawModelV2(
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
      'LineModel(id: $id, points: $points, lineColor: $color, thickness: $thickness, lineType:'; // Include some base info
}

// class FreeDrawModel extends FormItemModel {
//   List<Vector2> points;
//   Color color;
//   double thickness;
//   FreeDrawModel({
//     required this.points,
//     required this.color,
//     this.thickness = 5.0,
//   }) : super(formType: FormType.FREE_DRAW);
//   FreeDrawModel.fromJson(Map<String, dynamic> json)
//     : points =
//           (json['points'] as List<dynamic>?)
//               ?.map(
//                 (pointJson) =>
//                     FieldItemModel.vector2FromJson(pointJson) ?? Vector2.zero(),
//               )
//               .toList() ??
//           [],
//       color = Color(json['color'] as int? ?? Colors.black.value),
//       thickness = (json['thickness'] as num?)?.toDouble() ?? 5.0,
//       super(formType: FormType.FREE_DRAW);
//   @override
//   Map<String, dynamic> toJson() => {
//     ...super.baseToJson(),
//     'points': points.map((p) => FieldItemModel.vector2ToJson(p)).toList(),
//     'color': color.value,
//     'thickness': thickness,
//   };
//   @override
//   FreeDrawModel clone() => FreeDrawModel(
//     points: points.map((p) => p.clone()).toList(),
//     color: color,
//     thickness: thickness,
//   );
//   FreeDrawModel copyWith({
//     List<Vector2>? points,
//     Color? color,
//     double? thickness,
//   }) => FreeDrawModel(
//     points: points ?? this.points.map((p) => p.clone()).toList(),
//     color: color ?? this.color,
//     thickness: thickness ?? this.thickness,
//   );
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is FreeDrawModel &&
//           listEquals(other.points, points) &&
//           other.color == color &&
//           other.thickness == thickness;
//   // Corrected hashCode using Object.hash for list comparison
//   @override
//   int get hashCode => Object.hash(Object.hashAll(points), color, thickness);
//   @override
//   String toString() =>
//       'FreeDrawModel(points: $points, color: $color, thickness: $thickness)';
// }

// --- FormModel Class with Fixed fromJson ---

// class FormModel extends FieldItemModel {
//   String name;
//   String? imagePath;
//   FormItemModel? formItemModel; // This uses the hierarchy above
//
//   FormModel({
//     // Base properties
//     required super.id,
//     super.offset, // Nullable as per constructor
//     super.fieldItemType = FieldItemType.FORM, // Default type for FormModel
//     super.angle,
//     super.canBeCopied = true, // Keep existing default
//     super.scaleSymmetrically = true, // Keep existing default
//     super.createdAt,
//     super.updatedAt,
//     super.size,
//     super.color,
//     super.opacity,
//     // FormModel properties
//     required this.name,
//     this.imagePath,
//     this.formItemModel,
//   });
//
//   @override
//   Map<String, dynamic> toJson() {
//     // Keep existing toJson logic
//     return {
//       ...super.toJson(), // Includes base fields + fieldItemType='FORM'
//       'name': name,
//       'imagePath': imagePath,
//       'formItemModel': formItemModel?.toJson(), // Calls correct subclass toJson
//     };
//   }
//
//   // --- FIXED fromJson Static Method ---
//   static FormModel fromJson(Map<String, dynamic> json) {
//     // --- Parse Base Class Properties DIRECTLY from JSON ---
//     // DO NOT call FieldItemModel.fromJson(json) here!
//     // Use static helpers from FieldItemModel where appropriate.
//
//     final id = json['_id']; // Use helper
//     final offset = FieldItemModel.offsetFromJson(
//       json['offset'],
//     ); // Use helper (nullable)
//     // Note: fieldItemType is not parsed here, it's determined by being in FormModel.fromJson
//     final scaleSymmetrically =
//         json['scaleSymmetrically'] as bool? ?? true; // Default from constructor
//     final angle = json['angle'] as double?;
//     final canBeCopied =
//         json['canBeCopied'] as bool? ?? true; // Default from constructor
//     final createdAt =
//         json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
//     final updatedAt =
//         json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
//     final size = FieldItemModel.vector2FromJson(json['size']); // Use helper
//     final color = json['color'] != null ? Color(json['color']) : null;
//     final opacity =
//         json['opacity'] == null
//             ? null
//             : double.parse(json['opacity'].toString());
//
//     // --- Deserialize FormModel Specific Properties (Keep Existing Logic) ---
//     final name = json['name'] as String? ?? 'Unnamed Form'; // Default if null
//     final imagePath = json['imagePath'] as String?;
//     final formItemData =
//         json['formItemModel'] as Map<String, dynamic>?; // Cast for safety
//
//     // Correctly use the FormItemModel factory constructor for the nested model
//     final formItemModel =
//         formItemData != null ? FormItemModel.fromJson(formItemData) : null;
//
//     // --- Construct and Return FormModel Instance ---
//     return FormModel(
//       // Pass parsed base properties
//       id: id,
//       offset: offset,
//       scaleSymmetrically: scaleSymmetrically,
//       angle: angle,
//       canBeCopied: canBeCopied,
//       createdAt: createdAt,
//       updatedAt: updatedAt,
//       size: size,
//       color: color,
//       opacity: opacity,
//       // fieldItemType is set automatically by FormModel constructor
//
//       // Pass parsed FormModel specific properties
//       name: name,
//       imagePath: imagePath,
//       formItemModel: formItemModel, // Pass the deserialized nested model
//     );
//   }
//
//   // --- copyWith and clone remain unchanged from your provided code ---
//   @override
//   FormModel copyWith({
//     // Base properties
//     String? id,
//     Vector2? offset,
//     bool? scaleSymmetrically,
//     FieldItemType? fieldItemType,
//     double? angle,
//     bool? canBeCopied,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     Vector2? size,
//     Color? color,
//     double? opacity,
//     // FormModel properties
//     String? name,
//     String? imagePath,
//     FormItemModel? formItemModel,
//     bool clearFormItemModel = false,
//   }) {
//     FormItemModel? newFormItemModel;
//     if (clearFormItemModel) {
//       newFormItemModel = null;
//     } else if (formItemModel != null) {
//       newFormItemModel = formItemModel;
//     } else {
//       newFormItemModel =
//           this.formItemModel
//               ?.clone(); // Clone existing if not replacing/clearing
//     }
//
//     return FormModel(
//       // Base properties
//       id: id ?? this.id,
//       offset: offset ?? this.offset?.clone(),
//       scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
//       fieldItemType: this.fieldItemType, // Keep original type
//       angle: angle ?? this.angle,
//       canBeCopied: canBeCopied ?? this.canBeCopied,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       size: size ?? this.size?.clone(),
//       color: color ?? this.color,
//       opacity: opacity ?? this.opacity,
//       // FormModel properties
//       name: name ?? this.name,
//       imagePath: imagePath ?? this.imagePath,
//       formItemModel: newFormItemModel,
//     );
//   }
//
//   @override
//   FormModel clone() => copyWith();
// }
