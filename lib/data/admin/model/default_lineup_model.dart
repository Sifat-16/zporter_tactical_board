// Represents a player in the master roster
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';

class CategorizedFormationGroup {
  final FormationCategory category;
  final List<FormationTemplate> templates;

  CategorizedFormationGroup({required this.category, required this.templates});

  // Optional: copyWith, if needed later
  CategorizedFormationGroup copyWith({
    FormationCategory? category,
    List<FormationTemplate>? templates,
  }) {
    return CategorizedFormationGroup(
      category: category ?? this.category,
      templates: templates ?? this.templates,
    );
  }
}

class FormationCategory {
  final String categoryId; // Unique ID for the category, e.g., "11v11"
  final int numberOfPlayers; // E.g., 11, 9, 7, 5
  final String displayName; // E.g., "11 vs 11 Formations"
  final int orderIndex;

  FormationCategory({
    required this.categoryId,
    required this.numberOfPlayers,
    required this.displayName,
    this.orderIndex = 0,
  });

  factory FormationCategory.fromJson(Map<String, dynamic> json) {
    return FormationCategory(
      categoryId: json['categoryId'] as String,
      numberOfPlayers: json['numberOfPlayers'] as int,
      displayName: json['displayName'] as String,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'numberOfPlayers': numberOfPlayers,
      'displayName': displayName,
      'orderIndex': orderIndex,
    };
  }

  FormationCategory copyWith({
    String? categoryId,
    int? numberOfPlayers,
    String? displayName,
    int? orderIndex,
  }) {
    return FormationCategory(
      categoryId: categoryId ?? this.categoryId,
      numberOfPlayers: numberOfPlayers ?? this.numberOfPlayers,
      displayName: displayName ?? this.displayName,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}

// Represents a specific formation template, e.g., "4-3-3"
class FormationTemplate {
  String templateId; // Unique ID for this formation template
  String categoryId; // Foreign key linking to FormationCategory.categoryId
  String name; // Formation name, e.g., "4-3-3", "4-4-2 Diamond"
  final AnimationItemModel scene; // <<< NEW FIELD: Optional scene data
  final int orderIndex;

  FormationTemplate({
    required this.templateId,
    required this.categoryId,
    required this.name,
    required this.scene, // <<< ADDED to constructor (optional)
    this.orderIndex = 0,
  });

  factory FormationTemplate.fromJson(Map<String, dynamic> json) {
    AnimationItemModel sceneModel;
    if (json['scene'] != null && json['scene'] is Map<String, dynamic>) {
      try {
        sceneModel = AnimationItemModel.fromJson(
          json['scene'] as Map<String, dynamic>,
        );
      } catch (e) {
        // Optional: Log error or handle cases where scene data might be malformed
        print(
          "Error deserializing scene for template ${json['templateId']}: $e",
        );
        sceneModel = AnimationItemModel.createEmptyAnimationItem();
      }
    } else {
      sceneModel = AnimationItemModel.createEmptyAnimationItem();
    }

    return FormationTemplate(
      templateId: json['templateId'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      scene: sceneModel, // <<< ASSIGNED here
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'categoryId': categoryId,
      'name': name,
      'scene': scene
          ?.toJson(), // <<< ADDED here: call toJson on scene if it's not null
      'orderIndex': orderIndex,
    };
  }

  FormationTemplate copyWith({
    String? templateId,
    String? categoryId,
    String? name,
    AnimationItemModel? scene,
    int? orderIndex, // NEW
  }) {
    return FormationTemplate(
      templateId: templateId ?? this.templateId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      scene: scene ?? this.scene,
      orderIndex: orderIndex ?? this.orderIndex, // NEW
    );
  }
}
