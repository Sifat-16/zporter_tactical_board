import 'package:flame/components.dart';
import 'package:flutter/foundation.dart'; // For describeEnum
import 'package:flutter/material.dart'; // For Color
import 'package:mongo_dart/mongo_dart.dart';

// Assuming FieldItemModel and its helpers (vector2ToJson/FromJson) are in this file or imported
import 'field_item_model.dart';

// --- FormItemModel Hierarchy ---

enum FormType { TEXT, LINE, FREE_DRAW, UNKNOWN } // Added UNKNOWN

abstract class FormItemModel {
  final FormType formType;

  FormItemModel({required this.formType});

  /// Creates a JSON representation including the formType.
  Map<String, dynamic> toJson();

  /// Creates a deep copy of the specific FormItemModel implementation.
  FormItemModel clone();

  /// Base serialization for common properties (like formType).
  Map<String, dynamic> baseToJson() => {
    'formType': describeEnum(formType), // Use describeEnum for robustness
  };

  /// Factory constructor to deserialize JSON into the correct concrete subclass.
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

// --- Concrete FormItemModel Subclasses ---

class FormTextModel extends FormItemModel {
  String text;

  FormTextModel({required this.text}) : super(formType: FormType.TEXT);

  // Specific fromJson constructor/factory
  FormTextModel.fromJson(Map<String, dynamic> json)
    : text = json['text'] as String? ?? '', // Default to empty string if null
      super(formType: FormType.TEXT);

  @override
  Map<String, dynamic> toJson() => {
    ...super.baseToJson(), // Include formType
    'text': text,
  };

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
  UNKNOWN, // Added UNKNOWN
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

  // fromJson constructor/factory
  LineModel.fromJson(Map<String, dynamic> json)
    : start =
          FieldItemModel.vector2FromJson(json['start']) ??
          Vector2.zero(), // Use helper
      end =
          FieldItemModel.vector2FromJson(json['end']) ??
          Vector2.zero(), // Use helper
      color = Color(
        json['color'] as int? ?? Colors.black.value,
      ), // Default color
      thickness =
          (json['thickness'] as num?)?.toDouble() ?? 2.0, // Default thickness
      lineType = LineType.values.firstWhere(
        (e) => describeEnum(e) == (json['lineType'] as String?),
        orElse: () => LineType.UNKNOWN,
      ), // Use describeEnum
      super(formType: FormType.LINE);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.baseToJson(), // Include formType
      'start': FieldItemModel.vector2ToJson(start), // Use helper
      'end': FieldItemModel.vector2ToJson(end), // Use helper
      'color': color.value,
      'thickness': thickness,
      'lineType': describeEnum(lineType), // Use describeEnum
    };
  }

  @override
  LineModel clone() {
    return LineModel(
      start: start.clone(), // Clone mutable Vector2
      end: end.clone(), // Clone mutable Vector2
      color: color, // Color is immutable
      thickness: thickness,
      lineType: lineType,
    );
  }

  // copyWith remains useful for modifying instances
  LineModel copyWith({
    Vector2? start,
    Vector2? end,
    Color? color,
    double? thickness,
    LineType? lineType,
  }) {
    return LineModel(
      start: start ?? this.start.clone(),
      end: end ?? this.end.clone(),
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      lineType: lineType ?? this.lineType,
    );
  }

  // ==, hashCode, toString from your original code are fine
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LineModel &&
        other.start == start &&
        other.end == end &&
        other.color == color &&
        other.thickness == thickness &&
        other.lineType == lineType;
  }

  @override
  int get hashCode {
    return start.hashCode ^
        end.hashCode ^
        color.hashCode ^
        thickness.hashCode ^
        lineType.hashCode;
  }

  @override
  String toString() {
    return 'LineModel(start: $start, end: $end, color: $color, thickness: $thickness, lineType: $lineType)';
  }
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

  // fromJson constructor/factory
  FreeDrawModel.fromJson(Map<String, dynamic> json)
    : points =
          (json['points'] as List<dynamic>?)
              ?.map(
                (pointJson) =>
                    FieldItemModel.vector2FromJson(pointJson) ?? Vector2.zero(),
              )
              .toList() ??
          [], // Handle null list, null points
      color = Color(
        json['color'] as int? ?? Colors.black.value,
      ), // Default color
      thickness =
          (json['thickness'] as num?)?.toDouble() ?? 5.0, // Default thickness
      super(formType: FormType.FREE_DRAW);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.baseToJson(), // Include formType
      'points':
          points
              .map((p) => FieldItemModel.vector2ToJson(p))
              .toList(), // Use helper
      'color': color.value,
      'thickness': thickness,
    };
  }

  @override
  FreeDrawModel clone() {
    return FreeDrawModel(
      points:
          points.map((p) => p.clone()).toList(), // Deep copy list of Vector2
      color: color,
      thickness: thickness,
    );
  }

  // copyWith remains useful
  FreeDrawModel copyWith({
    List<Vector2>? points,
    Color? color,
    double? thickness,
  }) {
    return FreeDrawModel(
      points:
          points ??
          this.points
              .map((p) => p.clone())
              .toList(), // Deep copy if using existing
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
    );
  }

  // ==, hashCode, toString from your original code are fine (assuming _listEquals works)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FreeDrawModel &&
        // other.points.length == points.length && // listEquals checks length
        listEquals(other.points, points) && // Use listEquals from foundation
        other.color == color &&
        other.thickness == thickness;
  }

  // @override
  // int get hashCode {
  //   // Use listHash from foundation for better list hashing
  //
  //   return Object.hash(listEquals(points), color, thickness);
  // }

  @override
  String toString() {
    return 'FreeDrawModel(points: $points, color: $color, thickness: $thickness)';
  }
}

// --- Final FormModel (mostly verification) ---

class FormModel extends FieldItemModel {
  String name;
  String? imagePath;
  FormItemModel? formItemModel;

  FormModel({
    // Base properties
    required super.id,
    super.offset,
    super.fieldItemType = FieldItemType.FORM,
    super.angle,
    super.canBeCopied = true,
    super.scaleSymmetrically = true,
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
    return {
      ...super.toJson(),
      'name': name,
      'imagePath': imagePath,
      'formItemModel':
          formItemModel?.toJson(), // Now calls correct subclass method
    };
  }

  static FormModel fromJson(Map<String, dynamic> json) {
    final base = FieldItemModel.fromJson(json);
    final formItemData =
        json['formItemModel'] as Map<String, dynamic>?; // Cast for safety

    return FormModel(
      // Pass base properties
      id: base.id,
      offset: base.offset,
      fieldItemType: base.fieldItemType,
      angle: base.angle,
      scaleSymmetrically: base.scaleSymmetrically,
      canBeCopied: base.canBeCopied,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      size: base.size,
      color: base.color,
      opacity: base.opacity,
      // Pass FormModel properties
      name: json['name'] ?? 'Unnamed Form',
      imagePath: json['imagePath'],
      // Use the factory constructor, handle null
      formItemModel:
          formItemData != null ? FormItemModel.fromJson(formItemData) : null,
    );
  }

  @override
  FormModel copyWith({
    // Base properties
    ObjectId? id,
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
    FormItemModel? formItemModel, // Allows replacing the whole item
    bool clearFormItemModel = false, // Option to explicitly clear
  }) {
    // Determine the formItemModel for the new instance
    FormItemModel? newFormItemModel;
    if (clearFormItemModel) {
      newFormItemModel = null;
    } else if (formItemModel != null) {
      // If a new one is provided, use it (assume it's already correct type/cloned if needed)
      newFormItemModel = formItemModel;
    } else {
      // Otherwise, clone the existing one if it's not null
      newFormItemModel = this.formItemModel?.clone();
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
      formItemModel: newFormItemModel, // Use the determined value
    );
  }

  // Use simplified clone
  @override
  FormModel clone() => copyWith();
}
