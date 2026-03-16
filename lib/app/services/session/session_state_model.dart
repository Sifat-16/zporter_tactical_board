/// Explicitly tracks which kind of view the user was on.
/// Prevents one state type from accidentally restoring as another.
enum SessionNavigationType {
  defaultScreen, // On one of the default animation screens (paginator)
  collection;    // Viewing a collection (with optional animation/scene)

  String toJson() => name;

  static SessionNavigationType fromJson(String? value) {
    if (value == 'collection') return SessionNavigationType.collection;
    return SessionNavigationType.defaultScreen;
  }
}

class SessionStateModel {
  final SessionNavigationType navigationType;
  final int defaultAnimationItemIndex;
  final String? selectedCollectionId;
  final String? selectedCollectionName;
  final String? selectedAnimationId;
  final String? selectedAnimationName;
  final String? selectedSceneId;
  final DateTime savedAt;

  SessionStateModel({
    required this.navigationType,
    required this.defaultAnimationItemIndex,
    this.selectedCollectionId,
    this.selectedCollectionName,
    this.selectedAnimationId,
    this.selectedAnimationName,
    this.selectedSceneId,
    required this.savedAt,
  });

  factory SessionStateModel.fromJson(Map<String, dynamic> json) {
    return SessionStateModel(
      navigationType: SessionNavigationType.fromJson(
          json['navigationType'] as String?),
      defaultAnimationItemIndex: json['defaultAnimationItemIndex'] as int? ?? 0,
      selectedCollectionId: json['selectedCollectionId'] as String?,
      selectedCollectionName: json['selectedCollectionName'] as String?,
      selectedAnimationId: json['selectedAnimationId'] as String?,
      selectedAnimationName: json['selectedAnimationName'] as String?,
      selectedSceneId: json['selectedSceneId'] as String?,
      savedAt: json['savedAt'] != null
          ? DateTime.parse(json['savedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'navigationType': navigationType.toJson(),
      'defaultAnimationItemIndex': defaultAnimationItemIndex,
      'selectedCollectionId': selectedCollectionId,
      'selectedCollectionName': selectedCollectionName,
      'selectedAnimationId': selectedAnimationId,
      'selectedAnimationName': selectedAnimationName,
      'selectedSceneId': selectedSceneId,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  /// Whether this state has meaningful context beyond just "Screen 1".
  bool get hasMeaningfulContext =>
      navigationType == SessionNavigationType.collection ||
      defaultAnimationItemIndex > 0;

  /// Whether this state is recent enough to be worth resuming (within 7 days).
  bool get isRecent =>
      DateTime.now().difference(savedAt).inDays < 7;

  /// A human-readable summary of where the user was.
  String get displaySummary {
    if (navigationType == SessionNavigationType.collection) {
      final parts = <String>[];
      if (selectedCollectionName != null) parts.add(selectedCollectionName!);
      if (selectedAnimationName != null) parts.add(selectedAnimationName!);
      if (parts.isNotEmpty) return parts.join(' › ');
    }
    return 'Screen ${defaultAnimationItemIndex + 1}';
  }
}
