import 'dart:ui';

import 'package:zporter_tactical_board/v2/core/json_helpers.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';

/// Immutable equipment element (ball, cone, etc.) on the tactical board.
///
/// Matches V1 [EquipmentModel] field-for-field. JSON is V1-compatible.
class EquipmentElement extends BoardElement {
  final String name;
  final String? imagePath;
  final String? imageUrl;
  final bool isAerialArrival;
  final double passSpeedMultiplier;
  final BallSpin spin;

  const EquipmentElement({
    required super.id,
    super.offset,
    super.angle,
    super.canBeCopied = true,
    super.scaleSymmetrically = true,
    super.createdAt,
    super.updatedAt,
    super.size,
    super.color,
    super.opacity = 1.0,
    super.zIndex,
    required this.name,
    this.imagePath,
    this.imageUrl,
    this.isAerialArrival = false,
    this.passSpeedMultiplier = 1.0,
    this.spin = BallSpin.none,
  }) : super(fieldItemType: FieldItemType.EQUIPMENT);

  bool get hasImagePath => imagePath != null && imagePath!.isNotEmpty;
  bool get hasImageUrl => imageUrl != null && imageUrl!.isNotEmpty;
  bool get needsImageMigration => hasImagePath && !hasImageUrl;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'name': name,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'isAerialArrival': isAerialArrival,
      'passSpeedMultiplier': passSpeedMultiplier,
      'spin': spin.name,
    };
  }

  factory EquipmentElement.fromJson(Map<String, dynamic> json) {
    return EquipmentElement(
      id: json['_id'] as String? ?? '',
      offset: JsonHelpers.offsetFromJson(json['offset']),
      scaleSymmetrically: json['scaleSymmetrically'] as bool? ?? true,
      angle: JsonHelpers.toDouble(json['angle']),
      canBeCopied: json['canBeCopied'] as bool? ?? true,
      createdAt: JsonHelpers.dateTimeFromJson(json['createdAt']),
      updatedAt: JsonHelpers.dateTimeFromJson(json['updatedAt']),
      size: JsonHelpers.sizeFromJson(json['size']),
      color: JsonHelpers.colorFromJson(json['color']),
      opacity: JsonHelpers.toDouble(json['opacity']) ?? 1.0,
      zIndex: JsonHelpers.toInt(json['zIndex']),
      name: json['name'] as String? ?? 'Unnamed Equipment',
      imagePath: json['imagePath'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isAerialArrival: json['isAerialArrival'] as bool? ?? false,
      passSpeedMultiplier:
          JsonHelpers.toDouble(json['passSpeedMultiplier']) ?? 1.0,
      spin: BallSpin.fromString(json['spin'] as String?),
    );
  }

  EquipmentElement copyWith({
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
    String? name,
    Object? imagePath = sentinel,
    Object? imageUrl = sentinel,
    bool? isAerialArrival,
    double? passSpeedMultiplier,
    BallSpin? spin,
  }) {
    return EquipmentElement(
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
      name: name ?? this.name,
      imagePath:
          imagePath == sentinel ? this.imagePath : imagePath as String?,
      imageUrl:
          imageUrl == sentinel ? this.imageUrl : imageUrl as String?,
      isAerialArrival: isAerialArrival ?? this.isAerialArrival,
      passSpeedMultiplier: passSpeedMultiplier ?? this.passSpeedMultiplier,
      spin: spin ?? this.spin,
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
  EquipmentElement clone() => copyWith();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EquipmentElement) return false;
    return super == other &&
        name == other.name &&
        imagePath == other.imagePath &&
        imageUrl == other.imageUrl &&
        isAerialArrival == other.isAerialArrival &&
        passSpeedMultiplier == other.passSpeedMultiplier &&
        spin == other.spin;
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        name,
        imagePath,
        imageUrl,
        isAerialArrival,
        passSpeedMultiplier,
        spin,
      );
}
