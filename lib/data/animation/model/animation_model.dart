import 'package:mongo_dart/mongo_dart.dart';

import 'animation_item_model.dart'; // Import AnimationItemModel

class AnimationModel {
  ObjectId id;
  List<AnimationItemModel> animations;
  DateTime createdAt;
  DateTime updatedAt;

  AnimationModel({
    required this.id,
    required this.animations,
    required this.createdAt,
    required this.updatedAt,
  });

  AnimationModel copyWith({
    ObjectId? id,
    List<AnimationItemModel>? animations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnimationModel(
      id: id ?? this.id,
      animations: animations ?? this.animations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'animations': animations.map((animation) => animation.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AnimationModel.fromJson(Map<String, dynamic> json) {
    return AnimationModel(
      id: json['_id'] as ObjectId,
      animations:
          (json['animations'] as List)
              .map(
                (animationJson) => AnimationItemModel.fromJson(animationJson),
              )
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  AnimationModel clone() {
    return AnimationModel(
      id: id, // ObjectId is immutable
      animations: animations.map((e) => e.clone()).toList(),
      createdAt: createdAt, // DateTime is immutable
      updatedAt: updatedAt, // DateTime is immutable
    );
  }
}
