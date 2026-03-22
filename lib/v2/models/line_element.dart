import 'dart:ui';

import 'package:zporter_tactical_board/v2/core/json_helpers.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';

/// Immutable line element on the tactical board.
///
/// Matches V1 [LineModelV2] field-for-field. JSON is V1-compatible.
/// Lines have start/end points, optional Catmull-Rom control points,
/// and a line type that determines the visual style (solid, dashed, zigzag, etc.).
class LineElement extends BoardElement {
  final Offset start;
  final Offset end;
  final double thickness;
  final LineType lineType;
  final String name;
  final String imagePath;
  final Offset? controlPoint1;
  final Offset? controlPoint2;

  const LineElement({
    required super.id,
    super.offset,
    super.angle,
    super.canBeCopied = true,
    super.scaleSymmetrically = false,
    super.createdAt,
    super.updatedAt,
    super.size,
    super.color,
    super.opacity = 1.0,
    super.zIndex,
    required this.start,
    required this.end,
    this.thickness = 2.0,
    required this.lineType,
    required this.name,
    required this.imagePath,
    this.controlPoint1,
    this.controlPoint2,
  }) : super(fieldItemType: FieldItemType.LINE);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'start': JsonHelpers.pointToJson(start),
      'end': JsonHelpers.pointToJson(end),
      'name': name,
      'thickness': thickness,
      'lineType': lineType.name,
      'imagePath': imagePath,
      if (controlPoint1 != null)
        'controlPoint1': JsonHelpers.pointToJson(controlPoint1!),
      if (controlPoint2 != null)
        'controlPoint2': JsonHelpers.pointToJson(controlPoint2!),
    };
  }

  factory LineElement.fromJson(Map<String, dynamic> json) {
    final offset =
        JsonHelpers.offsetFromJson(json['offset']) ?? Offset.zero;

    return LineElement(
      id: json['_id'] as String? ?? '',
      offset: offset,
      scaleSymmetrically: json['scaleSymmetrically'] as bool? ?? false,
      angle: JsonHelpers.toDouble(json['angle']),
      canBeCopied: json['canBeCopied'] as bool? ?? true,
      createdAt: JsonHelpers.dateTimeFromJson(json['createdAt']),
      updatedAt: JsonHelpers.dateTimeFromJson(json['updatedAt']),
      size: JsonHelpers.sizeFromJson(json['size']),
      color: JsonHelpers.colorFromJson(json['color']),
      opacity: JsonHelpers.toDouble(json['opacity']) ?? 1.0,
      zIndex: JsonHelpers.toInt(json['zIndex']),
      start: JsonHelpers.pointFromJson(json['start']) ?? offset,
      end: JsonHelpers.pointFromJson(json['end']) ?? Offset.zero,
      thickness: JsonHelpers.toDouble(json['thickness']) ?? 2.0,
      lineType: LineType.fromString(json['lineType'] as String?),
      name: json['name'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      controlPoint1: JsonHelpers.pointFromJson(json['controlPoint1']),
      controlPoint2: JsonHelpers.pointFromJson(json['controlPoint2']),
    );
  }

  LineElement copyWith({
    String? id,
    Object? offset = sentinel,
    bool? scaleSymmetrically,
    double? angle,
    bool? canBeCopied,
    Object? createdAt = sentinel,
    Object? updatedAt = sentinel,
    Object? size = sentinel,
    Object? color = sentinel,
    double? opacity,
    Object? zIndex = sentinel,
    Offset? start,
    Offset? end,
    double? thickness,
    LineType? lineType,
    String? name,
    String? imagePath,
    Object? controlPoint1 = sentinel,
    Object? controlPoint2 = sentinel,
    bool clearControlPoints = false,
  }) {
    return LineElement(
      id: id ?? this.id,
      offset: offset == sentinel ? this.offset : offset as Offset?,
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      angle: angle ?? this.angle,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt:
          createdAt == sentinel ? this.createdAt : createdAt as DateTime?,
      updatedAt:
          updatedAt == sentinel ? this.updatedAt : updatedAt as DateTime?,
      size: size == sentinel ? this.size : size as Size?,
      color: color == sentinel ? this.color : color as Color?,
      opacity: opacity ?? this.opacity,
      zIndex: zIndex == sentinel ? this.zIndex : zIndex as int?,
      start: start ?? this.start,
      end: end ?? this.end,
      thickness: thickness ?? this.thickness,
      lineType: lineType ?? this.lineType,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      controlPoint1: clearControlPoints
          ? null
          : (controlPoint1 == sentinel
              ? this.controlPoint1
              : controlPoint1 as Offset?),
      controlPoint2: clearControlPoints
          ? null
          : (controlPoint2 == sentinel
              ? this.controlPoint2
              : controlPoint2 as Offset?),
    );
  }

  @override
  BoardElement copyWithBase({
    String? id,
    Object? offset = sentinel,
    bool? scaleSymmetrically,
    double? angle,
    bool? canBeCopied,
    Object? createdAt = sentinel,
    Object? updatedAt = sentinel,
    Object? size = sentinel,
    Object? color = sentinel,
    double? opacity,
    Object? zIndex = sentinel,
  }) {
    return copyWith(
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
      zIndex: zIndex,
    );
  }

  @override
  LineElement clone() => copyWith();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LineElement) return false;
    return super == other &&
        start == other.start &&
        end == other.end &&
        thickness == other.thickness &&
        lineType == other.lineType &&
        name == other.name &&
        imagePath == other.imagePath &&
        controlPoint1 == other.controlPoint1 &&
        controlPoint2 == other.controlPoint2;
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        start,
        end,
        thickness,
        lineType,
        name,
        imagePath,
        controlPoint1,
        controlPoint2,
      );
}
