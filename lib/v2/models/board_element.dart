import 'dart:ui';

import 'package:zporter_tactical_board/v2/core/json_helpers.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/models/equipment_element.dart';
import 'package:zporter_tactical_board/v2/models/line_element.dart';
import 'package:zporter_tactical_board/v2/models/free_draw_element.dart';
import 'package:zporter_tactical_board/v2/models/shape_elements.dart';
import 'package:zporter_tactical_board/v2/models/text_element.dart';

/// Sentinel object for distinguishing "not provided" from "set to null"
/// in copyWith methods.
const Object _sentinel = Object();

/// Immutable base class for all board elements.
///
/// Replaces V1's mutable [FieldItemModel]. All fields are final.
/// Uses [Offset] instead of Flame's [Vector2] for positions.
/// Uses [Size] instead of [Vector2] for dimensions.
///
/// JSON serialization is V1-compatible: same key names, same formats.
abstract class BoardElement {
  final String id;
  final Offset? offset;
  final FieldItemType fieldItemType;
  final bool scaleSymmetrically;
  final double? angle;
  final bool canBeCopied;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Size? size;
  final Color? color;
  final double opacity;
  final int? zIndex;

  const BoardElement({
    required this.id,
    this.offset,
    required this.fieldItemType,
    required this.scaleSymmetrically,
    this.angle,
    required this.canBeCopied,
    this.createdAt,
    this.updatedAt,
    this.size,
    this.color,
    this.opacity = 1.0,
    this.zIndex,
  });

  /// Base JSON — subclasses merge their fields with this.
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'offset': JsonHelpers.offsetToJson(offset),
      'scaleSymmetrically': scaleSymmetrically,
      'fieldItemType': fieldItemType.name,
      'angle': angle,
      'canBeCopied': canBeCopied,
      'createdAt': JsonHelpers.dateTimeToJson(createdAt),
      'updatedAt': JsonHelpers.dateTimeToJson(updatedAt),
      'size': JsonHelpers.sizeToJson(size),
      'color': JsonHelpers.colorToJson(color),
      'opacity': opacity,
      'zIndex': zIndex,
    };
  }

  /// Dispatcher: reads `fieldItemType` and delegates to the correct subclass.
  static BoardElement fromJson(Map<String, dynamic> json) {
    final typeString = json['fieldItemType'] as String?;
    if (typeString == null) {
      throw FormatException(
        'BoardElement JSON missing required field: fieldItemType',
      );
    }

    final type = FieldItemType.fromString(typeString);

    switch (type) {
      case FieldItemType.PLAYER:
        return PlayerElement.fromJson(json);
      case FieldItemType.EQUIPMENT:
        return EquipmentElement.fromJson(json);
      case FieldItemType.LINE:
        return LineElement.fromJson(json);
      case FieldItemType.FREEDRAW:
        return FreeDrawElement.fromJson(json);
      case FieldItemType.CIRCLE:
        return CircleElement.fromJson(json);
      case FieldItemType.SQUARE:
        return SquareElement.fromJson(json);
      case FieldItemType.TRIANGLE:
        return TriangleElement.fromJson(json);
      case FieldItemType.POLYGON:
        return PolygonElement.fromJson(json);
      case FieldItemType.TEXT:
        return TextElement.fromJson(json);
    }
  }

  /// Abstract copy — subclasses implement with their own fields.
  BoardElement copyWithBase({
    String? id,
    Object? offset = _sentinel,
    bool? scaleSymmetrically,
    double? angle,
    bool? canBeCopied,
    Object? createdAt = _sentinel,
    Object? updatedAt = _sentinel,
    Object? size = _sentinel,
    Object? color = _sentinel,
    double? opacity,
    Object? zIndex = _sentinel,
  });

  /// Deep clone.
  BoardElement clone();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BoardElement) return false;
    return id == other.id &&
        offset == other.offset &&
        fieldItemType == other.fieldItemType &&
        scaleSymmetrically == other.scaleSymmetrically &&
        angle == other.angle &&
        canBeCopied == other.canBeCopied &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        size == other.size &&
        color == other.color &&
        opacity == other.opacity &&
        zIndex == other.zIndex;
  }

  @override
  int get hashCode => Object.hash(
        id,
        offset,
        fieldItemType,
        scaleSymmetrically,
        angle,
        canBeCopied,
        createdAt,
        updatedAt,
        size,
        color,
        opacity,
        zIndex,
      );
}

/// Shared sentinel for nullable copyWith fields across all element types.
const Object sentinel = _sentinel;
