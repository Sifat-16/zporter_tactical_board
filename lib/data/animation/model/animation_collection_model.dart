import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';

class AnimationCollectionModel {
  String id;
  String name;
  List<AnimationModel> animations;
  String userId;
  DateTime createdAt;
  DateTime updatedAt;
  int orderIndex;

  AnimationCollectionModel({
    required this.id,
    required this.name,
    required this.animations,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.orderIndex = 0,
  });

  AnimationCollectionModel copyWith({
    String? id,
    String? name,
    List<AnimationModel>? animations,
    DateTime? createdAt,
    String? userId,
    DateTime? updatedAt,
    int? orderIndex,
  }) {
    return AnimationCollectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      animations: animations ?? this.animations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'userId': userId,
      'animations': animations.map((animation) => animation.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'orderIndex': orderIndex,
    };
  }

  factory AnimationCollectionModel.fromJson(Map<String, dynamic> json) {
    return AnimationCollectionModel(
      id: json['_id'],
      name: json['name'],
      userId: json['userId'],
      animations: (json['animations'] as List)
          .map((animationJson) => AnimationModel.fromJson(animationJson))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  AnimationCollectionModel clone() {
    return AnimationCollectionModel(
      id: id, // ObjectId is immutable
      name: name,
      userId: userId,
      animations: animations.map((e) => e.clone()).toList(),
      createdAt: createdAt, // DateTime is immutable
      updatedAt: updatedAt, // DateTime is immutable
    );
  }
}
