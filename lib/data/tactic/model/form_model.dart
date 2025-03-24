import 'dart:ui';

import 'package:flame/components.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'field_item_model.dart';

enum FormType { TEXT, LINE, FREE_DRAW }

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
      offset: Vector2(offset?.x ?? 0, offset?.y ?? 0),
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

class FreeDrawModel extends FormItemModel {
  List<Vector2> points;
  Color color;
  double thickness;

  FreeDrawModel({
    super.formType = FormType.FREE_DRAW,
    required this.points,
    required this.color,
    this.thickness = 5.0,
  });

  FreeDrawModel copyWith({
    List<Vector2>? points,
    Color? color,
    double? thickness,
  }) {
    return FreeDrawModel(
      points: points ?? this.points,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
    );
  }

  factory FreeDrawModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> pointsList = json['points'] as List<dynamic>;
    final List<Vector2> points =
        pointsList.map((point) {
          return Vector2(
            (point['x'] as num).toDouble(),
            (point['y'] as num).toDouble(),
          );
        }).toList();

    return FreeDrawModel(
      points: points,
      color: Color(json['color'] as int),
      thickness: (json['thickness'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> pointsJson =
        points.map((point) {
          return {'x': point.x, 'y': point.y}; // Convert each Vector2 to a Map
        }).toList();

    return {
      'points': pointsJson, // List of Maps
      'color': color.value,
      'thickness': thickness,
      'formType': formType.index,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FreeDrawModel &&
        other.points.length == points.length && // Basic length check
        _listEquals(other.points, points) && // Deep comparison
        other.color == color &&
        other.thickness == thickness;
  }

  // Helper function for deep list comparison
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return points.hashCode ^ color.hashCode ^ thickness.hashCode;
  }

  @override
  String toString() {
    return 'FreeDrawModel(points: $points, color: $color, thickness: $thickness)';
  }
}
