import 'dart:ui';

import 'package:flutter/material.dart' show Colors;
import 'package:zporter_tactical_board/v2/core/json_helpers.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';

/// Immutable text annotation element on the tactical board.
///
/// Matches V1 [TextModel] field-for-field. JSON is V1-compatible.
class TextElement extends BoardElement {
  final String text;
  final String name;
  final String imagePath;

  const TextElement({
    required super.id,
    super.offset = Offset.zero,
    super.angle = 0.0,
    super.canBeCopied = true,
    super.scaleSymmetrically = false,
    super.createdAt,
    super.updatedAt,
    super.size = const Size(100, 30),
    super.color = Colors.black,
    super.opacity = 1.0,
    super.zIndex,
    required this.text,
    required this.name,
    required this.imagePath,
  }) : super(fieldItemType: FieldItemType.TEXT);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['text'] = text;
    json['name'] = name;
    json['imagePath'] = imagePath;
    return json;
  }

  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      id: json['_id'] as String? ?? '',
      offset: JsonHelpers.offsetFromJson(json['offset']) ?? Offset.zero,
      scaleSymmetrically: json['scaleSymmetrically'] as bool? ?? false,
      angle: JsonHelpers.toDouble(json['angle']) ?? 0.0,
      canBeCopied: json['canBeCopied'] as bool? ?? true,
      createdAt: JsonHelpers.dateTimeFromJson(json['createdAt']),
      updatedAt: JsonHelpers.dateTimeFromJson(json['updatedAt']),
      size: JsonHelpers.sizeFromJson(json['size']) ?? const Size(100, 30),
      color: JsonHelpers.colorFromJson(json['color']) ?? Colors.black,
      opacity: JsonHelpers.toDouble(json['opacity']) ?? 1.0,
      zIndex: JsonHelpers.toInt(json['zIndex']),
      text: json['text'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
    );
  }

  TextElement copyWith({
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
    String? text,
    String? name,
    String? imagePath,
  }) {
    return TextElement(
      id: id ?? this.id,
      offset: offset == sentinel
          ? this.offset ?? Offset.zero
          : (offset as Offset?) ?? Offset.zero,
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      angle: angle ?? this.angle ?? 0.0,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt:
          createdAt == sentinel ? this.createdAt : createdAt as DateTime?,
      updatedAt:
          updatedAt == sentinel ? this.updatedAt : updatedAt as DateTime?,
      size: size == sentinel
          ? this.size ?? const Size(100, 30)
          : (size as Size?) ?? const Size(100, 30),
      color: color == sentinel
          ? this.color ?? Colors.black
          : (color as Color?) ?? Colors.black,
      opacity: opacity ?? this.opacity,
      zIndex: zIndex == sentinel ? this.zIndex : zIndex as int?,
      text: text ?? this.text,
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
  TextElement clone() => copyWith();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TextElement) return false;
    return super == other &&
        text == other.text &&
        name == other.name &&
        imagePath == other.imagePath;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, text, name, imagePath);
}
