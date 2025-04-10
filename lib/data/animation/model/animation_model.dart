import 'dart:ui';

import 'package:zporter_tactical_board/app/manager/color_manager.dart';

import 'animation_item_model.dart'; // Import AnimationItemModel

class AnimationModel {
  String id;
  String name;
  String userId;
  Color fieldColor;
  List<AnimationItemModel> animationScenes;
  DateTime createdAt;
  DateTime updatedAt;

  AnimationModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.fieldColor,
    required this.animationScenes,
    required this.createdAt,
    required this.updatedAt,
  });

  AnimationModel copyWith({
    String? id,
    String? name,
    String? userId,
    Color? fieldColor,
    List<AnimationItemModel>? animationScenes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnimationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      fieldColor: fieldColor ?? this.fieldColor,
      animationScenes: animationScenes ?? this.animationScenes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'userId': userId,
      'fieldColor': fieldColor.toARGB32(),
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
      userId: json['userId'],
      fieldColor:
          json['fieldColor'] == null
              ? ColorManager.grey
              : Color((json['fieldColor'] as int?) ?? 0),
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
      fieldColor: fieldColor,
      userId: userId,
      animationScenes: animationScenes.map((e) => e.clone()).toList(),
      createdAt: createdAt, // DateTime is immutable
      updatedAt: updatedAt, // DateTime is immutable
    );
  }
}
