import 'package:flame/components.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'field_item_model.dart';

class EquipmentModel extends FieldItemModel {
  String name;
  String? imagePath;

  EquipmentModel({
    required super.id,
    super.offset,
    super.fieldItemType = FieldItemType.PLAYER,
    super.angle,
    super.scaleSymmetrically = true,
    super.createdAt,
    super.updatedAt,
    required this.name,
    this.imagePath,
  });

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'name': name, 'imagePath': imagePath};
  }

  static EquipmentModel fromJson(Map<String, dynamic> json) {
    final base = FieldItemModel.fromJson(json);
    return EquipmentModel(
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
  EquipmentModel copyWith({
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
    return EquipmentModel(
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
  EquipmentModel clone() {
    return EquipmentModel(
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
