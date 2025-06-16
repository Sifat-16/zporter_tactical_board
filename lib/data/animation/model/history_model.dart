import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';

class HistoryModel {
  String
  id; // ID matching the AnimationCollection or AnimationItem this history belongs to
  List<AnimationItemModel> history; // List of past states

  HistoryModel({required this.id, required this.history});

  /// Converts this HistoryModel instance to a JSON-encodable Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Convert each AnimationItemModel in the history list to its JSON map.
      // Assuming AnimationItemModel.toJson() exists and handles its own fields.
      // We might want to exclude further nested history within these items
      // if AnimationItemModel.toJson() has an includeHistory flag.
      'history': history.map((item) => item.toJson()).toList(),
    };
  }

  /// Creates a HistoryModel instance from a JSON Map.
  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    List<AnimationItemModel> historyList = [];
    if (json['history'] is List) {
      historyList =
          (json['history'] as List)
              .map((itemJson) {
                if (itemJson is Map<String, dynamic>) {
                  try {
                    // Assuming AnimationItemModel.fromJson exists
                    return AnimationItemModel.fromJson(itemJson);
                  } catch (e) {
                    print(
                      "Error parsing history item in HistoryModel.fromJson: $e",
                    );
                    // Return a default/empty item or skip? Skipping for now.
                    return null;
                  }
                }
                return null; // Skip non-map items in history list
              })
              .whereType<AnimationItemModel>()
              .toList(); // Filter out any nulls from errors/skips
    }

    return HistoryModel(
      id: json['id'] as String? ?? '', // Provide default for id if missing
      history: historyList,
    );
  }

  // Optional: Add copyWith, equality operators, toString if needed later
  HistoryModel copyWith({String? id, List<AnimationItemModel>? history}) {
    return HistoryModel(
      id: id ?? this.id,
      history:
          history ??
          List<AnimationItemModel>.from(
            this.history.map((e) => e.copyWith()),
          ), // Deep copy history
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          // Basic list equality check (length and element-wise)
          // Note: This doesn't guarantee deep equality of AnimationItemModels
          // unless AnimationItemModel itself overrides == correctly.
          history.length == other.history.length &&
          Iterable.generate(
            history.length,
          ).every((i) => history[i] == other.history[i]);

  @override
  int get hashCode => id.hashCode ^ history.hashCode; // Simple hash combine

  @override
  String toString() {
    return 'HistoryModel{id: $id, historyCount: ${history.length}}';
  }
}
