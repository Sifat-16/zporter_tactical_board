import 'package:flame/components.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'field_item_model.dart';

enum PlayerType { HOME, OTHER, AWAY }

class PlayerModel extends FieldItemModel {
  String role;
  String? imagePath;
  int index;
  PlayerType playerType;

  PlayerModel({
    required super.id,
    required super.offset,
    super.fieldItemType = FieldItemType.PLAYER,
    super.angle,
    required this.index,
    super.scaleSymmetrically = true,
    super.createdAt,
    super.updatedAt,
    required this.role,
    this.imagePath,
    required this.playerType,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'role': role,
      'imagePath': imagePath,
      'playerType': playerType.toString().split('.').last,
    };
  }

  static PlayerModel fromJson(Map<String, dynamic> json) {
    final base = FieldItemModel.fromJson(json);
    return PlayerModel(
      id: base.id,
      offset: base.offset,
      angle: base.angle,
      createdAt: base.createdAt,
      index: json['index'],
      updatedAt: base.updatedAt,
      role: json['role'],
      imagePath: json['imagePath'],
      playerType: PlayerType.values.firstWhere(
        (e) => e.toString().split('.').last == json['playerType'],
      ),
    );
  }

  @override
  PlayerModel copyWith({
    ObjectId? id,
    Vector2? offset,
    bool? scaleSymmetrically,
    FieldItemType? fieldItemType,
    double? angle,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? role,
    int? index,
    String? imagePath,
    PlayerType? playerType,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      offset: offset ?? this.offset,
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      fieldItemType: this.fieldItemType,
      angle: angle ?? this.angle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      index: index ?? this.index,
      imagePath: imagePath ?? this.imagePath,
      playerType: playerType ?? this.playerType,
    );
  }

  @override
  PlayerModel clone() {
    return PlayerModel(
      id: id,
      offset: offset,
      fieldItemType: fieldItemType,
      angle: angle,
      index: index,
      createdAt: createdAt,
      updatedAt: updatedAt,
      role: role,
      imagePath: imagePath,
      playerType: playerType,
    );
  }
}
