import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:zporter_tactical_board/v2/core/json_helpers.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';

// =============================================================================
// Shape base — shared fields across circle, square, triangle, polygon
// =============================================================================

/// Abstract base for shape elements. Adds fill color, stroke width, name, and
/// image path on top of [BoardElement].
abstract class ShapeElement extends BoardElement {
  final Color? fillColor;
  final double strokeWidth;
  final String name;
  final String imagePath;

  const ShapeElement({
    required super.id,
    super.offset,
    required super.fieldItemType,
    super.size,
    super.angle,
    super.color,
    super.opacity = 1.0,
    required super.canBeCopied,
    required super.scaleSymmetrically,
    super.createdAt,
    super.updatedAt,
    super.zIndex,
    required this.name,
    required this.imagePath,
    this.fillColor,
    this.strokeWidth = 2.0,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'fillColor': JsonHelpers.colorToJson(fillColor),
      'strokeWidth': strokeWidth,
      'name': name,
      'imagePath': imagePath,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShapeElement) return false;
    return super == other &&
        fillColor == other.fillColor &&
        strokeWidth == other.strokeWidth &&
        name == other.name &&
        imagePath == other.imagePath;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, fillColor, strokeWidth, name, imagePath);
}

// =============================================================================
// CircleElement
// =============================================================================

/// Immutable circle shape. Matches V1 [CircleShapeModel].
class CircleElement extends ShapeElement {
  final double radius;

  /// Alias for offset — circles use center as their position.
  Offset get center => offset ?? Offset.zero;
  Color? get strokeColor => color;

  CircleElement({
    required super.id,
    required Offset center,
    super.angle,
    Color? strokeColor,
    super.opacity = 1.0,
    super.canBeCopied = true,
    super.createdAt,
    super.updatedAt,
    super.zIndex,
    required super.name,
    required super.imagePath,
    super.fillColor,
    super.strokeWidth = 2.0,
    required this.radius,
  }) : super(
          offset: center,
          color: strokeColor,
          fieldItemType: FieldItemType.CIRCLE,
          scaleSymmetrically: true,
          size: Size(radius * 2, radius * 2),
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'radius': radius,
    };
  }

  factory CircleElement.fromJson(Map<String, dynamic> json) {
    return CircleElement(
      id: json['_id'] as String? ?? '',
      center: JsonHelpers.offsetFromJson(json['offset']) ?? Offset.zero,
      angle: JsonHelpers.toDouble(json['angle']),
      strokeColor: JsonHelpers.colorFromJson(json['color']),
      opacity: JsonHelpers.toDouble(json['opacity']) ?? 1.0,
      canBeCopied: json['canBeCopied'] as bool? ?? true,
      createdAt: JsonHelpers.dateTimeFromJson(json['createdAt']),
      updatedAt: JsonHelpers.dateTimeFromJson(json['updatedAt']),
      zIndex: JsonHelpers.toInt(json['zIndex']),
      fillColor: JsonHelpers.colorFromJson(json['fillColor']),
      strokeWidth: JsonHelpers.toDouble(json['strokeWidth']) ?? 2.0,
      radius: JsonHelpers.toDouble(json['radius']) ?? 10.0,
      name: json['name'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
    );
  }

  CircleElement copyWith({
    String? id,
    Offset? center,
    Object? offset = sentinel,
    bool? scaleSymmetrically,
    double? angle,
    bool? canBeCopied,
    Object? createdAt = sentinel,
    Object? updatedAt = sentinel,
    Object? size = sentinel,
    Object? color = sentinel,
    Color? strokeColor,
    double? opacity,
    Object? zIndex = sentinel,
    Color? fillColor,
    bool clearFillColor = false,
    double? strokeWidth,
    double? radius,
    String? name,
    String? imagePath,
  }) {
    return CircleElement(
      id: id ?? this.id,
      center: center ?? (offset == sentinel ? this.center : (offset as Offset?) ?? Offset.zero),
      angle: angle ?? this.angle,
      strokeColor: strokeColor ?? (color == sentinel ? this.color : color as Color?),
      opacity: opacity ?? this.opacity,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt:
          createdAt == sentinel ? this.createdAt : createdAt as DateTime?,
      updatedAt:
          updatedAt == sentinel ? this.updatedAt : updatedAt as DateTime?,
      zIndex: zIndex == sentinel ? this.zIndex : zIndex as int?,
      fillColor: clearFillColor ? null : (fillColor ?? this.fillColor),
      strokeWidth: strokeWidth ?? this.strokeWidth,
      radius: radius ?? this.radius,
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
      angle: angle,
      canBeCopied: canBeCopied,
      createdAt: createdAt,
      updatedAt: updatedAt,
      color: color,
      opacity: opacity,
      zIndex: zIndex,
    );
  }

  @override
  CircleElement clone() => copyWith();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CircleElement) return false;
    return super == other && radius == other.radius;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, radius);
}

// =============================================================================
// SquareElement
// =============================================================================

/// Immutable square/rectangle shape. Matches V1 [SquareShapeModel].
/// `side` is a relative value (fraction of field size).
class SquareElement extends ShapeElement {
  final double side;

  Offset get center => offset ?? Offset.zero;
  Color? get strokeColor => color;

  const SquareElement({
    required super.id,
    required Offset center,
    super.angle = 0.0,
    Color? strokeColor,
    super.opacity = 1.0,
    super.canBeCopied = true,
    super.createdAt,
    super.updatedAt,
    super.zIndex,
    super.fillColor,
    super.strokeWidth = 2.0,
    required super.name,
    required super.imagePath,
    required this.side,
  }) : super(
          offset: center,
          color: strokeColor,
          fieldItemType: FieldItemType.SQUARE,
          scaleSymmetrically: true,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'side': side,
    };
  }

  factory SquareElement.fromJson(Map<String, dynamic> json) {
    return SquareElement(
      id: json['_id'] as String? ?? '',
      center: JsonHelpers.offsetFromJson(json['offset']) ?? Offset.zero,
      angle: JsonHelpers.toDouble(json['angle']) ?? 0.0,
      strokeColor: JsonHelpers.colorFromJson(json['color']),
      opacity: JsonHelpers.toDouble(json['opacity']) ?? 1.0,
      canBeCopied: json['canBeCopied'] as bool? ?? true,
      createdAt: JsonHelpers.dateTimeFromJson(json['createdAt']),
      updatedAt: JsonHelpers.dateTimeFromJson(json['updatedAt']),
      zIndex: JsonHelpers.toInt(json['zIndex']),
      fillColor: JsonHelpers.colorFromJson(json['fillColor']),
      strokeWidth: JsonHelpers.toDouble(json['strokeWidth']) ?? 2.0,
      side: JsonHelpers.toDouble(json['side']) ?? 0.1,
      name: json['name'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
    );
  }

  SquareElement copyWith({
    String? id,
    Offset? center,
    Object? offset = sentinel,
    bool? scaleSymmetrically,
    double? angle,
    bool? canBeCopied,
    Object? createdAt = sentinel,
    Object? updatedAt = sentinel,
    Object? size = sentinel,
    Object? color = sentinel,
    Color? strokeColor,
    double? opacity,
    Object? zIndex = sentinel,
    Color? fillColor,
    bool clearFillColor = false,
    double? strokeWidth,
    double? side,
    String? name,
    String? imagePath,
  }) {
    return SquareElement(
      id: id ?? this.id,
      center: center ?? (offset == sentinel ? this.center : (offset as Offset?) ?? Offset.zero),
      angle: angle ?? this.angle ?? 0.0,
      strokeColor: strokeColor ?? (color == sentinel ? this.color : color as Color?),
      opacity: opacity ?? this.opacity,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt:
          createdAt == sentinel ? this.createdAt : createdAt as DateTime?,
      updatedAt:
          updatedAt == sentinel ? this.updatedAt : updatedAt as DateTime?,
      zIndex: zIndex == sentinel ? this.zIndex : zIndex as int?,
      fillColor: clearFillColor ? null : (fillColor ?? this.fillColor),
      strokeWidth: strokeWidth ?? this.strokeWidth,
      side: side ?? this.side,
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
      angle: angle,
      canBeCopied: canBeCopied,
      createdAt: createdAt,
      updatedAt: updatedAt,
      color: color,
      opacity: opacity,
      zIndex: zIndex,
    );
  }

  @override
  SquareElement clone() => copyWith();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SquareElement) return false;
    return super == other && side == other.side;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, side);
}

// =============================================================================
// TriangleElement
// =============================================================================

/// Immutable triangle shape. Matches V1 [TriangleShapeModel].
class TriangleElement extends ShapeElement {
  final Offset? vertexA;
  final Offset? vertexB;
  final Offset? vertexC;

  Offset get center => offset ?? Offset.zero;
  Color? get strokeColor => color;

  const TriangleElement({
    required super.id,
    required Offset center,
    super.angle = 0.0,
    Color? strokeColor,
    super.opacity = 1.0,
    super.canBeCopied = false,
    super.createdAt,
    super.updatedAt,
    super.zIndex,
    super.fillColor,
    super.strokeWidth = 2.0,
    required super.name,
    required super.imagePath,
    this.vertexA,
    this.vertexB,
    this.vertexC,
  }) : super(
          offset: center,
          color: strokeColor,
          fieldItemType: FieldItemType.TRIANGLE,
          scaleSymmetrically: false,
          size: Size.zero,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'vertexA': JsonHelpers.pointToJson(vertexA),
      'vertexB': JsonHelpers.pointToJson(vertexB),
      'vertexC': JsonHelpers.pointToJson(vertexC),
    };
  }

  factory TriangleElement.fromJson(Map<String, dynamic> json) {
    return TriangleElement(
      id: json['_id'] as String? ?? '',
      center: JsonHelpers.offsetFromJson(json['offset']) ?? Offset.zero,
      angle: JsonHelpers.toDouble(json['angle']) ?? 0.0,
      strokeColor: JsonHelpers.colorFromJson(json['color']),
      opacity: JsonHelpers.toDouble(json['opacity']) ?? 1.0,
      canBeCopied: json['canBeCopied'] as bool? ?? false,
      createdAt: JsonHelpers.dateTimeFromJson(json['createdAt']),
      updatedAt: JsonHelpers.dateTimeFromJson(json['updatedAt']),
      zIndex: JsonHelpers.toInt(json['zIndex']),
      fillColor: JsonHelpers.colorFromJson(json['fillColor']),
      strokeWidth: JsonHelpers.toDouble(json['strokeWidth']) ?? 2.0,
      vertexA: JsonHelpers.pointFromJson(json['vertexA']),
      vertexB: JsonHelpers.pointFromJson(json['vertexB']),
      vertexC: JsonHelpers.pointFromJson(json['vertexC']),
      name: json['name'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
    );
  }

  TriangleElement copyWith({
    String? id,
    Offset? center,
    Object? offset = sentinel,
    bool? scaleSymmetrically,
    double? angle,
    bool? canBeCopied,
    Object? createdAt = sentinel,
    Object? updatedAt = sentinel,
    Object? size = sentinel,
    Object? color = sentinel,
    Color? strokeColor,
    double? opacity,
    Object? zIndex = sentinel,
    Color? fillColor,
    bool clearFillColor = false,
    double? strokeWidth,
    Object? vertexA = sentinel,
    Object? vertexB = sentinel,
    Object? vertexC = sentinel,
    String? name,
    String? imagePath,
  }) {
    return TriangleElement(
      id: id ?? this.id,
      center: center ?? (offset == sentinel ? this.center : (offset as Offset?) ?? Offset.zero),
      angle: angle ?? this.angle ?? 0.0,
      strokeColor: strokeColor ?? (color == sentinel ? this.color : color as Color?),
      opacity: opacity ?? this.opacity,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt:
          createdAt == sentinel ? this.createdAt : createdAt as DateTime?,
      updatedAt:
          updatedAt == sentinel ? this.updatedAt : updatedAt as DateTime?,
      zIndex: zIndex == sentinel ? this.zIndex : zIndex as int?,
      fillColor: clearFillColor ? null : (fillColor ?? this.fillColor),
      strokeWidth: strokeWidth ?? this.strokeWidth,
      vertexA: vertexA == sentinel ? this.vertexA : vertexA as Offset?,
      vertexB: vertexB == sentinel ? this.vertexB : vertexB as Offset?,
      vertexC: vertexC == sentinel ? this.vertexC : vertexC as Offset?,
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
      angle: angle,
      canBeCopied: canBeCopied,
      createdAt: createdAt,
      updatedAt: updatedAt,
      color: color,
      opacity: opacity,
      zIndex: zIndex,
    );
  }

  @override
  TriangleElement clone() => copyWith();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TriangleElement) return false;
    return super == other &&
        vertexA == other.vertexA &&
        vertexB == other.vertexB &&
        vertexC == other.vertexC;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, vertexA, vertexB, vertexC);
}

// =============================================================================
// PolygonElement
// =============================================================================

/// Immutable polygon shape with N vertices. Matches V1 [PolygonShapeModel].
class PolygonElement extends ShapeElement {
  final List<Offset> relativeVertices;
  final int? maxVertices;
  final int minVertices;

  Offset get center => offset ?? Offset.zero;
  Color? get strokeColor => color;

  PolygonElement({
    required super.id,
    required Offset center,
    super.angle = 0.0,
    Color? strokeColor,
    super.opacity = 1.0,
    super.canBeCopied = false,
    super.createdAt,
    super.updatedAt,
    super.zIndex,
    super.fillColor,
    super.strokeWidth = 2.0,
    required super.name,
    required super.imagePath,
    required List<Offset> relativeVertices,
    this.maxVertices,
    this.minVertices = 2,
  })  : relativeVertices = List.unmodifiable(relativeVertices),
        super(
          offset: center,
          color: strokeColor,
          fieldItemType: FieldItemType.POLYGON,
          scaleSymmetrically: false,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'relativeVertices': JsonHelpers.pointListToJson(relativeVertices),
      if (maxVertices != null) 'maxVertices': maxVertices,
      'minVertices': minVertices,
    };
  }

  factory PolygonElement.fromJson(Map<String, dynamic> json) {
    return PolygonElement(
      id: json['_id'] as String? ?? '',
      center: JsonHelpers.offsetFromJson(json['offset']) ?? Offset.zero,
      angle: JsonHelpers.toDouble(json['angle']) ?? 0.0,
      strokeColor: JsonHelpers.colorFromJson(json['color']),
      opacity: JsonHelpers.toDouble(json['opacity']) ?? 1.0,
      canBeCopied: json['canBeCopied'] as bool? ?? true,
      createdAt: JsonHelpers.dateTimeFromJson(json['createdAt']),
      updatedAt: JsonHelpers.dateTimeFromJson(json['updatedAt']),
      zIndex: JsonHelpers.toInt(json['zIndex']),
      fillColor: JsonHelpers.colorFromJson(json['fillColor']),
      strokeWidth: JsonHelpers.toDouble(json['strokeWidth']) ?? 2.0,
      relativeVertices:
          JsonHelpers.pointListFromJson(json['relativeVertices']),
      maxVertices: JsonHelpers.toInt(json['maxVertices']),
      minVertices: JsonHelpers.toInt(json['minVertices']) ?? 2,
      name: json['name'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
    );
  }

  PolygonElement copyWith({
    String? id,
    Offset? center,
    Object? offset = sentinel,
    bool? scaleSymmetrically,
    double? angle,
    bool? canBeCopied,
    Object? createdAt = sentinel,
    Object? updatedAt = sentinel,
    Object? size = sentinel,
    Object? color = sentinel,
    Color? strokeColor,
    double? opacity,
    Object? zIndex = sentinel,
    Color? fillColor,
    bool clearFillColor = false,
    double? strokeWidth,
    List<Offset>? relativeVertices,
    Object? maxVertices = sentinel,
    int? minVertices,
    String? name,
    String? imagePath,
  }) {
    return PolygonElement(
      id: id ?? this.id,
      center: center ?? (offset == sentinel ? this.center : (offset as Offset?) ?? Offset.zero),
      angle: angle ?? this.angle ?? 0.0,
      strokeColor: strokeColor ?? (color == sentinel ? this.color : color as Color?),
      opacity: opacity ?? this.opacity,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt:
          createdAt == sentinel ? this.createdAt : createdAt as DateTime?,
      updatedAt:
          updatedAt == sentinel ? this.updatedAt : updatedAt as DateTime?,
      zIndex: zIndex == sentinel ? this.zIndex : zIndex as int?,
      fillColor: clearFillColor ? null : (fillColor ?? this.fillColor),
      strokeWidth: strokeWidth ?? this.strokeWidth,
      relativeVertices: relativeVertices ?? this.relativeVertices,
      maxVertices: maxVertices == sentinel
          ? this.maxVertices
          : maxVertices as int?,
      minVertices: minVertices ?? this.minVertices,
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
      angle: angle,
      canBeCopied: canBeCopied,
      createdAt: createdAt,
      updatedAt: updatedAt,
      color: color,
      opacity: opacity,
      zIndex: zIndex,
    );
  }

  @override
  PolygonElement clone() =>
      copyWith(relativeVertices: List.of(relativeVertices));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PolygonElement) return false;
    return super == other &&
        listEquals(relativeVertices, other.relativeVertices) &&
        maxVertices == other.maxVertices &&
        minVertices == other.minVertices;
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        Object.hashAll(relativeVertices),
        maxVertices,
        minVertices,
      );
}
