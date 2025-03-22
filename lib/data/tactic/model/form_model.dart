import 'dart:ui';

import 'package:flame/components.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'field_item_model.dart';

enum FormType { TEXT, LINE }

abstract class FormItemModel {
  FormType formType;
  FormItemModel({required this.formType});
}

class FormModel extends FieldItemModel {
  String name;
  String? imagePath;
  FormItemModel? formItemModel;

  FormModel({
    required super.id,
    super.offset,
    super.fieldItemType = FieldItemType.FORM,
    super.angle,
    super.scaleSymmetrically = true,
    super.createdAt,
    super.updatedAt,
    required this.name,
    this.imagePath,
    this.formItemModel,
  });

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'name': name, 'imagePath': imagePath};
  }

  static FormModel fromJson(Map<String, dynamic> json) {
    final base = FieldItemModel.fromJson(json);
    return FormModel(
      id: base.id,
      offset: base.offset,
      angle: base.angle,
      createdAt: base.createdAt,
      name: json['name'],
      updatedAt: base.updatedAt,
      imagePath: json['imagePath'],
    );
  }

  @override
  FormModel copyWith({
    ObjectId? id,
    Vector2? offset,
    bool? scaleSymmetrically,
    FieldItemType? fieldItemType,
    double? angle,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? imagePath,
  }) {
    return FormModel(
      id: id ?? this.id,
      offset: offset ?? this.offset,
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      fieldItemType: this.fieldItemType,
      angle: angle ?? this.angle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  FormModel clone() {
    return FormModel(
      id: id,
      offset: offset,
      fieldItemType: fieldItemType,
      angle: angle,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      imagePath: imagePath,
    );
  }
}

class FormTextModel extends FormItemModel {
  FormTextModel({super.formType = FormType.TEXT, required this.text});
  String text;
}

enum LineType {
  STRAIGHT_LINE,
  STRAIGHT_LINE_DASHED,
  STRAIGHT_LINE_ZIGZAG,
  STRAIGHT_LINE_ZIGZAG_ARROW,
  STRAIGHT_LINE_ARROW,
  STRAIGHT_LINE_ARROW_DOUBLE,
  RIGHT_TURN_ARROW,
}

class LineModel extends FormItemModel {
  Vector2 start;
  Vector2 end;
  Color color;
  double thickness;
  LineType lineType;

  LineModel({
    super.formType = FormType.LINE,
    required this.start,
    required this.end,
    required this.lineType,
    required this.color,
    this.thickness = 2.0,
  });

  LineModel copyWith({
    Vector2? start,
    Vector2? end,
    Color? color,
    double? thickness,
    LineType? lineType,
  }) {
    return LineModel(
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      lineType: lineType ?? this.lineType,
    );
  }

  // Add this factory constructor for JSON deserialization
  factory LineModel.fromJson(Map<String, dynamic> json) {
    return LineModel(
      start: Vector2(json['startX'] as double, json['startY'] as double),
      end: Vector2(json['endX'] as double, json['endY'] as double),
      color: Color(json['color'] as int),
      thickness:
          (json['thickness'] as num).toDouble(), // Handle both int and double
      lineType:
          LineType.values[json['lineType']
              as int], // Assuming LineType is an enum
    );
  }

  // Add this method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'startX': start.x,
      'startY': start.y,
      'endX': end.x,
      'endY': end.y,
      'color': color.value, // Store color as an integer
      'thickness': thickness,
      'lineType': lineType.index, // Store enum as an integer index
      'formType': formType.index,
    };
  }

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
