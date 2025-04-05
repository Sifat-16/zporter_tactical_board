import 'package:flame/components.dart'; // For Vector2
import 'package:zporter_tactical_board/app/helper/logger.dart';
// Assuming FieldItemModel and its helpers are correctly imported
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// Import ObjectId if your ID is actually that type
// import 'package:mongo_dart/mongo_dart.dart';

class AnimationItemModel {
  String id; // Assuming String ID
  List<FieldItemModel> components;
  DateTime createdAt;
  DateTime updatedAt;
  Vector2 fieldSize; // <-- CHANGED: Removed '?', now non-nullable

  List<AnimationItemModel> history;

  AnimationItemModel({
    required this.id,
    required this.components,
    required this.createdAt,
    required this.updatedAt,
    required this.fieldSize, // <-- CHANGED: Marked as required
    this.history = const [],
  });

  AnimationItemModel copyWith({
    String? id,
    List<FieldItemModel>? components,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2?
    fieldSize, // <-- Parameter stays optional to allow copying without changing it
    List<AnimationItemModel>? history,
  }) {
    return AnimationItemModel(
      id: id ?? this.id,
      // Deep clone component list if not replaced
      components: components ?? this.components.map((e) => e.clone()).toList(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // Use new fieldSize if provided, otherwise clone existing (it's non-nullable)
      fieldSize:
          fieldSize ??
          this.fieldSize
              .clone(), // <-- CHANGED: No '?.' needed for 'this.fieldSize'
      history: history ?? this.history.map((e) => e.clone()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'components': components.map((component) => component.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'history': history.map((component) => component.toJson()).toList(),
      // fieldSize is guaranteed non-null. Clone it before serializing.
      'fieldSize': FieldItemModel.vector2ToJson(
        fieldSize.clone(),
      ), // <-- CHANGED: No '?.' needed
    };
  }

  addToHistory() {
    zlog(data: "History saved $history");
    history = [...history, clone()];
    zlog(data: "History saved $history");
  }

  bool get canUndo => history.isNotEmpty;

  factory AnimationItemModel.fromJson(Map<String, dynamic> json) {
    // Perform null checks for required fields upfront
    final componentsList = json['components'] as List?;
    final createdAtString = json['createdAt'] as String?;
    final updatedAtString = json['updatedAt'] as String?;
    final idValue = json['id'] ?? json['_id'];
    final fieldSizeJson = json['fieldSize']; // Get potential fieldSize data
    final historyList = (json['history'] ?? []) as List?;

    if (idValue == null ||
        componentsList == null ||
        createdAtString == null ||
        historyList == null ||
        updatedAtString == null) {
      throw FormatException(
        "Missing required fields (id, components, createdAt, updatedAt) in AnimationItemModel JSON",
      );
    }

    // Deserialize fieldSize and ensure it's valid, throw error if not
    final Vector2? parsedFieldSize = FieldItemModel.vector2FromJson(
      fieldSizeJson,
    );
    if (parsedFieldSize == null) {
      // Since fieldSize is required, throw an error if it's missing or invalid in the JSON
      throw FormatException(
        "Missing or invalid required field 'fieldSize' in AnimationItemModel JSON: $fieldSizeJson",
      );
    }
    // --- End fieldSize check ---

    return AnimationItemModel(
      id: idValue.toString(), // Adjust if using ObjectId
      components:
          componentsList
              .map(
                (componentJson) => FieldItemModel.fromJson(
                  componentJson as Map<String, dynamic>,
                ),
              )
              .toList(),

      history:
          historyList
              .map(
                (historyJson) => AnimationItemModel.fromJson(
                  historyJson as Map<String, dynamic>,
                ),
              )
              .toList(),
      createdAt: DateTime.parse(createdAtString),
      updatedAt: DateTime.parse(updatedAtString),
      fieldSize: parsedFieldSize, // <-- Pass the non-nullable parsed value
    );
  }

  AnimationItemModel clone({bool addHistory = true}) {
    return AnimationItemModel(
      id: id,
      history: addHistory ? history.map((e) => e.clone()).toList() : [],
      components: components.map((e) => e.clone()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      fieldSize:
          fieldSize.clone(), // <-- CHANGED: No '?.' needed, must clone Vector2
    );
  }

  AnimationItemModel cloneHistory() {
    return AnimationItemModel(
      id: id,
      components: components.map((e) => e.clone()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      fieldSize:
          fieldSize.clone(), // <-- CHANGED: No '?.' needed, must clone Vector2
    );
  }
}
