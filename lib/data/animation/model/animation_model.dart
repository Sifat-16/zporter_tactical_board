import 'animation_item_model.dart'; // Import AnimationItemModel

class AnimationModel {
  String id;
  String name;

  List<AnimationItemModel> animationScenes;
  DateTime createdAt;
  DateTime updatedAt;

  AnimationModel({
    required this.id,
    required this.name,
    required this.animationScenes,
    required this.createdAt,
    required this.updatedAt,
  });

  AnimationModel copyWith({
    String? id,
    String? name,
    List<AnimationItemModel>? animationScenes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnimationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      animationScenes: animationScenes ?? this.animationScenes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'animationScenes':
          animationScenes.map((animation) => animation.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AnimationModel.fromJson(Map<String, dynamic> json) {
    return AnimationModel(
      id: json['_id'],
      name: json['name'],
      animationScenes:
          (json['animationScenes'] as List)
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
      name: name,
      animationScenes: animationScenes.map((e) => e.clone()).toList(),
      createdAt: createdAt, // DateTime is immutable
      updatedAt: updatedAt, // DateTime is immutable
    );
  }
}
