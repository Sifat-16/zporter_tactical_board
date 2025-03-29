import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';

class AnimationItemModel {
  String id;
  List<FieldItemModel> components;
  DateTime createdAt;
  DateTime updatedAt;

  AnimationItemModel({
    required this.id,
    required this.components,
    required this.createdAt,
    required this.updatedAt,
  });

  AnimationItemModel copyWith({
    String? id,
    List<FieldItemModel>? components,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnimationItemModel(
      id: id ?? this.id,
      components: components ?? this.components,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Use '_id' for MongoDB compatibility
      'components': components.map((component) => component.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(), // Store as ISO 8601 string
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AnimationItemModel.fromJson(Map<String, dynamic> json) {
    return AnimationItemModel(
      id: json['_id'], // Cast to ObjectId
      components:
          (json['components'] as List)
              .map((componentJson) => FieldItemModel.fromJson(componentJson))
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  AnimationItemModel clone() {
    return AnimationItemModel(
      id: id, // ObjectId is immutable, so we can reuse it
      components: components.map((e) => e.clone()).toList(),
      createdAt: createdAt, // DateTime is immutable
      updatedAt: updatedAt, // DateTime is immutable
    );
  }
}
