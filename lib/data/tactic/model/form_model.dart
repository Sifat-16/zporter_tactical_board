import 'package:flame/components.dart';
import 'package:flutter/foundation.dart'; // For describeEnum, listEquals
import 'package:flutter/material.dart'; // For Color

// Assuming FieldItemModel and its helpers are defined correctly and imported
import 'field_item_model.dart';

// --- FormItemModel Hierarchy (Keep as provided) ---

enum FormType { TEXT, LINE, FREE_DRAW, UNKNOWN }

abstract class FormItemModel {
  final FormType formType;

  FormItemModel({required this.formType});
  Map<String, dynamic> toJson();
  FormItemModel clone();
  Map<String, dynamic> baseToJson() => {'formType': describeEnum(formType)};

  factory FormItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('Cannot create FormItemModel from null JSON');
    }
    final typeString = json['formType'] as String?;
    final formType = FormType.values.firstWhere(
      (e) => describeEnum(e) == typeString,
      orElse: () => FormType.UNKNOWN,
    );

    switch (formType) {
      case FormType.TEXT:
        return FormTextModel.fromJson(json);
      case FormType.LINE:
        return LineModel.fromJson(json);
      case FormType.FREE_DRAW:
        return FreeDrawModel.fromJson(json);
      case FormType.UNKNOWN:
      default:
        throw UnimplementedError(
          'fromJson not implemented for formType: $formType',
        );
    }
  }
}

// --- Concrete FormItemModel Subclasses (Keep as provided) ---

class FormTextModel extends FormItemModel {
  String text;
  FormTextModel({required this.text}) : super(formType: FormType.TEXT);
  FormTextModel.fromJson(Map<String, dynamic> json)
    : text = json['text'] as String? ?? '',
      super(formType: FormType.TEXT);
  @override
  Map<String, dynamic> toJson() => {...super.baseToJson(), 'text': text};
  @override
  FormTextModel clone() => FormTextModel(text: text);
}

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

class LineModel extends FormItemModel {
  Vector2 start;
  Vector2 end;
  Color color;
  double thickness;
  LineType lineType;
  LineModel({
    required this.start,
    required this.end,
    required this.lineType,
    required this.color,
    this.thickness = 2.0,
  }) : super(formType: FormType.LINE);
  LineModel.fromJson(Map<String, dynamic> json)
    : start = FieldItemModel.vector2FromJson(json['start']) ?? Vector2.zero(),
      end = FieldItemModel.vector2FromJson(json['end']) ?? Vector2.zero(),
      color = Color(json['color'] as int? ?? Colors.black.value),
      thickness = (json['thickness'] as num?)?.toDouble() ?? 2.0,
      lineType = LineType.values.firstWhere(
        (e) => describeEnum(e) == (json['lineType'] as String?),
        orElse: () => LineType.UNKNOWN,
      ),
      super(formType: FormType.LINE);
  @override
  Map<String, dynamic> toJson() => {
    ...super.baseToJson(),
    'start': FieldItemModel.vector2ToJson(start),
    'end': FieldItemModel.vector2ToJson(end),
    'color': color.value,
    'thickness': thickness,
    'lineType': describeEnum(lineType),
  };
  @override
  LineModel clone() => LineModel(
    start: start.clone(),
    end: end.clone(),
    color: color,
    thickness: thickness,
    lineType: lineType,
  );
  LineModel copyWith({
    Vector2? start,
    Vector2? end,
    Color? color,
    double? thickness,
    LineType? lineType,
  }) => LineModel(
    start: start ?? this.start.clone(),
    end: end ?? this.end.clone(),
    color: color ?? this.color,
    thickness: thickness ?? this.thickness,
    lineType: lineType ?? this.lineType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineModel &&
          other.start == start &&
          other.end == end &&
          other.color == color &&
          other.thickness == thickness &&
          other.lineType == lineType;
  @override
  int get hashCode =>
      start.hashCode ^
      end.hashCode ^
      color.hashCode ^
      thickness.hashCode ^
      lineType.hashCode;
  @override
  String toString() =>
      'LineModel(start: $start, end: $end, color: $color, thickness: $thickness, lineType: $lineType)';
}

class FreeDrawModel extends FormItemModel {
  List<Vector2> points;
  Color color;
  double thickness;
  FreeDrawModel({
    required this.points,
    required this.color,
    this.thickness = 5.0,
  }) : super(formType: FormType.FREE_DRAW);
  FreeDrawModel.fromJson(Map<String, dynamic> json)
    : points =
          (json['points'] as List<dynamic>?)
              ?.map(
                (pointJson) =>
                    FieldItemModel.vector2FromJson(pointJson) ?? Vector2.zero(),
              )
              .toList() ??
          [],
      color = Color(json['color'] as int? ?? Colors.black.value),
      thickness = (json['thickness'] as num?)?.toDouble() ?? 5.0,
      super(formType: FormType.FREE_DRAW);
  @override
  Map<String, dynamic> toJson() => {
    ...super.baseToJson(),
    'points': points.map((p) => FieldItemModel.vector2ToJson(p)).toList(),
    'color': color.value,
    'thickness': thickness,
  };
  @override
  FreeDrawModel clone() => FreeDrawModel(
    points: points.map((p) => p.clone()).toList(),
    color: color,
    thickness: thickness,
  );
  FreeDrawModel copyWith({
    List<Vector2>? points,
    Color? color,
    double? thickness,
  }) => FreeDrawModel(
    points: points ?? this.points.map((p) => p.clone()).toList(),
    color: color ?? this.color,
    thickness: thickness ?? this.thickness,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreeDrawModel &&
          listEquals(other.points, points) &&
          other.color == color &&
          other.thickness == thickness;
  // Corrected hashCode using Object.hash for list comparison
  @override
  int get hashCode => Object.hash(Object.hashAll(points), color, thickness);
  @override
  String toString() =>
      'FreeDrawModel(points: $points, color: $color, thickness: $thickness)';
}

// --- FormModel Class with Fixed fromJson ---

class FormModel extends FieldItemModel {
  String name;
  String? imagePath;
  FormItemModel? formItemModel; // This uses the hierarchy above

  FormModel({
    // Base properties
    required super.id,
    super.offset, // Nullable as per constructor
    super.fieldItemType = FieldItemType.FORM, // Default type for FormModel
    super.angle,
    super.canBeCopied = true, // Keep existing default
    super.scaleSymmetrically = true, // Keep existing default
    super.createdAt,
    super.updatedAt,
    super.size,
    super.color,
    super.opacity,
    // FormModel properties
    required this.name,
    this.imagePath,
    this.formItemModel,
  });

  @override
  Map<String, dynamic> toJson() {
    // Keep existing toJson logic
    return {
      ...super.toJson(), // Includes base fields + fieldItemType='FORM'
      'name': name,
      'imagePath': imagePath,
      'formItemModel': formItemModel?.toJson(), // Calls correct subclass toJson
    };
  }

  // --- FIXED fromJson Static Method ---
  static FormModel fromJson(Map<String, dynamic> json) {
    // --- Parse Base Class Properties DIRECTLY from JSON ---
    // DO NOT call FieldItemModel.fromJson(json) here!
    // Use static helpers from FieldItemModel where appropriate.

    final id = json['_id']; // Use helper
    final offset = FieldItemModel.offsetFromJson(
      json['offset'],
    ); // Use helper (nullable)
    // Note: fieldItemType is not parsed here, it's determined by being in FormModel.fromJson
    final scaleSymmetrically =
        json['scaleSymmetrically'] as bool? ?? true; // Default from constructor
    final angle = json['angle'] as double?;
    final canBeCopied =
        json['canBeCopied'] as bool? ?? true; // Default from constructor
    final createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    final updatedAt =
        json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
    final size = FieldItemModel.vector2FromJson(json['size']); // Use helper
    final color = json['color'] != null ? Color(json['color']) : null;
    final opacity = json['opacity'] as double?;

    // --- Deserialize FormModel Specific Properties (Keep Existing Logic) ---
    final name = json['name'] as String? ?? 'Unnamed Form'; // Default if null
    final imagePath = json['imagePath'] as String?;
    final formItemData =
        json['formItemModel'] as Map<String, dynamic>?; // Cast for safety

    // Correctly use the FormItemModel factory constructor for the nested model
    final formItemModel =
        formItemData != null ? FormItemModel.fromJson(formItemData) : null;

    // --- Construct and Return FormModel Instance ---
    return FormModel(
      // Pass parsed base properties
      id: id,
      offset: offset,
      scaleSymmetrically: scaleSymmetrically,
      angle: angle,
      canBeCopied: canBeCopied,
      createdAt: createdAt,
      updatedAt: updatedAt,
      size: size,
      color: color,
      opacity: opacity,
      // fieldItemType is set automatically by FormModel constructor

      // Pass parsed FormModel specific properties
      name: name,
      imagePath: imagePath,
      formItemModel: formItemModel, // Pass the deserialized nested model
    );
  }

  // --- copyWith and clone remain unchanged from your provided code ---
  @override
  FormModel copyWith({
    // Base properties
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
    // FormModel properties
    String? name,
    String? imagePath,
    FormItemModel? formItemModel,
    bool clearFormItemModel = false,
  }) {
    FormItemModel? newFormItemModel;
    if (clearFormItemModel) {
      newFormItemModel = null;
    } else if (formItemModel != null) {
      newFormItemModel = formItemModel;
    } else {
      newFormItemModel =
          this.formItemModel
              ?.clone(); // Clone existing if not replacing/clearing
    }

    return FormModel(
      // Base properties
      id: id ?? this.id,
      offset: offset ?? this.offset?.clone(),
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      fieldItemType: this.fieldItemType, // Keep original type
      angle: angle ?? this.angle,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      size: size ?? this.size?.clone(),
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      // FormModel properties
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      formItemModel: newFormItemModel,
    );
  }

  @override
  FormModel clone() => copyWith();
}
