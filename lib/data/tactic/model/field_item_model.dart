import 'package:flame/components.dart';
import 'package:mongo_dart/mongo_dart.dart';

enum FieldItemType { PLAYER, FORM, EQUIPMENT }

abstract class FieldItemModel {
  ObjectId id;
  Vector2? offset;
  FieldItemType fieldItemType;
  bool scaleSymmetrically;
  double? angle;
  DateTime? createdAt;
  DateTime? updatedAt;

  FieldItemModel({
    required this.id,
    this.offset,
    required this.fieldItemType,
    required this.scaleSymmetrically,
    this.angle,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'offset': {'dx': offset?.x ?? 0, 'dy': offset?.y ?? 0},
      'scaleSymmetrically': scaleSymmetrically,
      'fieldItemType': fieldItemType.toString().split('.').last,
      'angle': angle,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static FieldItemModel fromJson(Map<String, dynamic> json) {
    final fieldItemType = FieldItemType.values.firstWhere(
      (e) => e.toString().split('.').last == json['fieldItemType'],
    );
    final offset = Vector2(
      (json['offset'] as Map<String, dynamic>)['dx'].toDouble(),
      (json['offset'] as Map<String, dynamic>)['dy'].toDouble(),
    );

    return _FieldItemModelImpl(
      id: json['_id'],
      offset: offset,
      scaleSymmetrically: json['scaleSymmetrically'],
      fieldItemType: fieldItemType,
      angle: json['angle']?.toDouble(),

      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }

  FieldItemModel copyWith({
    ObjectId? id,
    Vector2? offset,
    FieldItemType? fieldItemType,
    double? angle,
    bool? scaleSymmetrically,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return _FieldItemModelImpl(
      id: id ?? this.id,
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      offset: offset ?? this.offset,
      fieldItemType: fieldItemType ?? this.fieldItemType,
      angle: angle ?? this.angle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  FieldItemModel clone();
}

// Private implementation to allow fromJson construction.
class _FieldItemModelImpl extends FieldItemModel {
  _FieldItemModelImpl({
    required super.id,
    required super.offset,
    required super.fieldItemType,
    required super.scaleSymmetrically,
    super.angle,
    super.createdAt,
    super.updatedAt,
  });

  @override
  FieldItemModel clone() {
    // TODO: implement clone
    throw UnimplementedError();
  }
}
