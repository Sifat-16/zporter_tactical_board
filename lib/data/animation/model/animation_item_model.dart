import 'dart:ui';

import 'package:flame/components.dart'; // For Vector2
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

class AnimationItemModel {
  String id;
  List<FieldItemModel> components;
  Color fieldColor;
  DateTime createdAt;
  String userId;
  DateTime updatedAt;
  Vector2 fieldSize;
  Duration sceneDuration; // ADDED: Duration for this specific scene's movements

  // Inside the AnimationItemModel class, add this line with the other properties
  BoardBackground boardBackground;

  AnimationItemModel({
    required this.id,
    required this.components,
    required this.createdAt,
    required this.userId,
    required this.fieldColor,
    required this.updatedAt,
    required this.fieldSize,
    this.boardBackground = BoardBackground.full,
    Duration? sceneDuration, // Optional in constructor to allow default
  }) : sceneDuration =
            sceneDuration ?? const Duration(seconds: 2); // Default to 2 seconds

  AnimationItemModel copyWith({
    String? id,
    List<FieldItemModel>? components,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    Vector2? fieldSize,
    Color? fieldColor,
    Duration? sceneDuration, // ADDED
    BoardBackground? boardBackground,
    // List<AnimationItemModel>? history, // 'history' was in your old copyWith, not used in constructor
  }) {
    return AnimationItemModel(
      id: id ?? this.id,
      components: components ?? this.components.map((e) => e.clone()).toList(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      fieldColor: fieldColor ?? this.fieldColor,
      fieldSize: fieldSize ?? this.fieldSize.clone(),
      sceneDuration: sceneDuration ?? this.sceneDuration, // ADDED
      boardBackground: boardBackground ?? this.boardBackground,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'components': components.map((component) => component.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'fieldColor': fieldColor.toARGB32(),
      'fieldSize': FieldItemModel.vector2ToJson(fieldSize.clone()),
      'sceneDurationMilliseconds':
          sceneDuration.inMilliseconds, // ADDED: Store as milliseconds
      'boardBackground': boardBackground.name,
    };
  }

  factory AnimationItemModel.fromJson(Map<String, dynamic> json) {
    final componentsList = json['components'] as List?;
    final createdAtString = json['createdAt'] as String?;
    final updatedAtString = json['updatedAt'] as String?;
    final idValue = json['id'] ?? json['_id'];
    final fieldSizeJson = json['fieldSize'];
    // final historyList = (json['history'] ?? []) as List?; // 'history' not used in constructor
    final userId = json['userId'];
    final color = json['fieldColor'] == null
        ? ColorManager.grey
        : Color((json['fieldColor'] as int?) ?? 0);

    final sceneDurationMilliseconds =
        json['sceneDurationMilliseconds'] as int?; // ADDED

    final boardBackgroundString = json['boardBackground'] as String?;
    final boardBackground = BoardBackground.values.firstWhere(
      (e) => e.name == boardBackgroundString,
      orElse: () => BoardBackground.full, // Default value if not found
    );

    if (idValue == null ||
        componentsList == null ||
        createdAtString == null ||
        // historyList == null || // Not in constructor
        updatedAtString == null) {
      throw FormatException(
        "Missing required fields (id, components, createdAt, updatedAt) in AnimationItemModel JSON",
      );
    }

    final Vector2? parsedFieldSize = FieldItemModel.vector2FromJson(
      fieldSizeJson,
    );
    if (parsedFieldSize == null) {
      throw FormatException(
        "Missing or invalid required field 'fieldSize' in AnimationItemModel JSON: $fieldSizeJson",
      );
    }

    return AnimationItemModel(
      id: idValue.toString(),
      components: componentsList
          .map(
            (componentJson) => FieldItemModel.fromJson(
              componentJson as Map<String, dynamic>,
            ),
          )
          .toList(),
      userId: userId,
      fieldColor: color,
      createdAt: DateTime.parse(createdAtString),
      updatedAt: DateTime.parse(updatedAtString),
      fieldSize: parsedFieldSize,
      boardBackground: boardBackground,
      sceneDuration: sceneDurationMilliseconds != null // ADDED
          ? Duration(milliseconds: sceneDurationMilliseconds)
          : const Duration(seconds: 2), // Default if missing
    );
  }

  AnimationItemModel clone({bool addHistory = true}) {
    // 'addHistory' param not used here
    return AnimationItemModel(
      id: id,
      fieldColor: fieldColor,
      userId: userId,
      components: components.map((e) => e.clone()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      boardBackground: boardBackground,
      fieldSize: fieldSize.clone(),
      sceneDuration: sceneDuration, // ADDED
    );
  }

  // cloneHistory seemed identical to clone in your provided code, removed for brevity
  // If it had a different purpose, you can re-add it.

  factory AnimationItemModel.createEmptyAnimationItem({
    String? id,
    String? userId,
    List<FieldItemModel>? components,
    DateTime? createdAt,
    DateTime? updatedAt,
    Color? fieldColor,
    Vector2? fieldSize,
    BoardBackground? boardBackground,
    Duration? sceneDuration, // ADDED
  }) {
    final now = DateTime.now();
    return AnimationItemModel(
      id: id ?? RandomGenerator.generateId(),
      components: components ?? [],
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      userId: userId ?? "default_user_id",
      fieldColor: fieldColor ?? ColorManager.grey,
      fieldSize: fieldSize ?? Vector2(1280, 720),
      boardBackground: boardBackground ?? BoardBackground.full,
      sceneDuration:
          sceneDuration ?? const Duration(seconds: 2), // ADDED default
    );
  }
}
