import 'dart:ui';

import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

import 'animation_item_model.dart'; // Import AnimationItemModel

class AnimationModel {
  String id;
  String name;
  String userId;
  Color fieldColor;
  String? collectionId;
  List<AnimationItemModel> animationScenes;
  DateTime createdAt;
  DateTime updatedAt;
  BoardBackground boardBackground;
  int orderIndex;

  AnimationModel({
    required this.id,
    required this.name,
    required this.userId,
    this.collectionId,
    required this.fieldColor,
    required this.animationScenes,
    required this.createdAt,
    required this.updatedAt,
    this.boardBackground = BoardBackground.full,
    this.orderIndex = 0,
  });

  AnimationModel copyWith({
    String? id,
    String? name,
    String? userId,
    Color? fieldColor,
    String? collectionId,
    List<AnimationItemModel>? animationScenes,
    DateTime? createdAt,
    DateTime? updatedAt,
    BoardBackground? boardBackground,
    int? orderIndex,
  }) {
    return AnimationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      collectionId: collectionId ?? this.collectionId,
      fieldColor: fieldColor ?? this.fieldColor,
      animationScenes: animationScenes ?? this.animationScenes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      boardBackground: boardBackground ?? this.boardBackground,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'userId': userId,
      'fieldColor': fieldColor.toARGB32(),
      'collectionId': collectionId,
      'animationScenes':
          animationScenes.map((animation) => animation.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'boardBackground': boardBackground.name,
      'orderIndex': orderIndex,
    };
  }

  // factory AnimationModel.fromJson(Map<String, dynamic> json) {
  //   final boardBackgroundString = json['boardBackground'] as String?;
  //   final boardBackground = BoardBackground.values.firstWhere(
  //     (e) => e.name == boardBackgroundString,
  //     orElse: () => BoardBackground.full, // Default value
  //   );
  //   return AnimationModel(
  //     id: json['_id'],
  //     name: json['name'],
  //     userId: json['userId'],
  //     fieldColor: json['fieldColor'] == null
  //         ? ColorManager.grey
  //         : Color((json['fieldColor'] as int?) ?? 0),
  //     animationScenes: (json['animationScenes'] as List)
  //         .map(
  //           (animationJson) => AnimationItemModel.fromJson(animationJson),
  //         )
  //         .toList(),
  //     boardBackground: boardBackground,
  //     createdAt: DateTime.parse(json['createdAt'] as String),
  //     updatedAt: DateTime.parse(json['updatedAt'] as String),
  //   );
  // }

  factory AnimationModel.fromJson(Map<String, dynamic> json) {
    final boardBackgroundString = json['boardBackground'] as String?;
    final boardBackground = BoardBackground.values.firstWhere(
      (e) => e.name == boardBackgroundString,
      orElse: () => BoardBackground.full, // Default value
    );

    // --- MIGRATION & INDEXING LOGIC ---
    final scenesList = (json['animationScenes'] as List)
        .map(
          (animationJson) => AnimationItemModel.fromJson(animationJson),
        )
        .toList();

    // Check if any scene has the default index of 0, which implies it might be old data.
    // This is a simple check; a more robust one could be checking if 'index' was null.
    final bool needsIndexing = scenesList.any((s) => json['index'] == null);

    if (needsIndexing) {
      for (int i = 0; i < scenesList.length; i++) {
        // Assign the list order as the index.
        scenesList[i] = scenesList[i].copyWith(index: i);
      }
    }
    // Always sort by the index to ensure the order is correct.
    scenesList.sort((a, b) => a.index.compareTo(b.index));
    // --- END OF LOGIC ---

    return AnimationModel(
      id: json['_id'],
      name: json['name'],
      userId: json['userId'],
      fieldColor: json['fieldColor'] == null
          ? ColorManager.grey
          : Color((json['fieldColor'] as int?) ?? 0),
      // Use the newly processed and sorted list
      animationScenes: scenesList,
      collectionId: json['collectionId'] as String?,
      boardBackground: boardBackground,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  AnimationModel clone() {
    return AnimationModel(
      id: id, // ObjectId is immutable
      name: name,
      fieldColor: fieldColor,
      userId: userId,
      boardBackground: boardBackground,
      animationScenes: animationScenes.map((e) => e.clone()).toList(),
      createdAt: createdAt, // DateTime is immutable
      updatedAt: updatedAt, // DateTime is immutable
    );
  }
}
