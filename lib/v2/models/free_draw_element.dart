import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:zporter_tactical_board/v2/core/json_helpers.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';

/// Immutable free-draw stroke element on the tactical board.
///
/// Matches V1 [FreeDrawModelV2] field-for-field. JSON is V1-compatible.
class FreeDrawElement extends BoardElement {
  final List<Offset> points;
  final double thickness;
  final String name;
  final String imagePath;

  FreeDrawElement({
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
    required List<Offset> points,
    this.thickness = 2.0,
    this.name = 'FREE-DRAW',
    this.imagePath = 'assets/images/free-draw.png',
  })  : points = List.unmodifiable(points),
        super(fieldItemType: FieldItemType.FREEDRAW);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'points': JsonHelpers.pointListToJson(points),
      'name': name,
      'lineColor': JsonHelpers.colorToJson(color), // V1 uses 'lineColor' key
      'thickness': thickness,
      'imagePath': imagePath,
    };
  }

  factory FreeDrawElement.fromJson(Map<String, dynamic> json) {
    // V1 stores color in both 'color' and 'lineColor' keys
    final color = JsonHelpers.colorFromJson(json['color']) ??
        JsonHelpers.colorFromJson(json['lineColor']);

    return FreeDrawElement(
      id: json['_id'] as String? ?? '',
      offset: JsonHelpers.offsetFromJson(json['offset']) ?? Offset.zero,
      scaleSymmetrically: json['scaleSymmetrically'] as bool? ?? true,
      angle: JsonHelpers.toDouble(json['angle']),
      canBeCopied: json['canBeCopied'] as bool? ?? false,
      createdAt: JsonHelpers.dateTimeFromJson(json['createdAt']),
      updatedAt: JsonHelpers.dateTimeFromJson(json['updatedAt']),
      size: JsonHelpers.sizeFromJson(json['size']),
      color: color,
      opacity: JsonHelpers.toDouble(json['opacity']) ?? 1.0,
      zIndex: JsonHelpers.toInt(json['zIndex']),
      points: JsonHelpers.pointListFromJson(json['points']),
      thickness: JsonHelpers.toDouble(json['thickness']) ?? 2.0,
      name: json['name'] as String? ?? 'FREE-DRAW',
      imagePath:
          json['imagePath'] as String? ?? 'assets/images/free-draw.png',
    );
  }

  FreeDrawElement copyWith({
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
    List<Offset>? points,
    double? thickness,
    String? name,
    String? imagePath,
  }) {
    return FreeDrawElement(
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
      points: points ?? this.points,
      thickness: thickness ?? this.thickness,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
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
  FreeDrawElement clone() => copyWith(points: List.of(points));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FreeDrawElement) return false;
    return super == other &&
        listEquals(points, other.points) &&
        thickness == other.thickness &&
        name == other.name &&
        imagePath == other.imagePath;
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        Object.hashAll(points),
        thickness,
        name,
        imagePath,
      );
}
