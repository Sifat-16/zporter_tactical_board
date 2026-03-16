class SessionStateModel {
  final int defaultAnimationItemIndex;
  final String? selectedCollectionId;
  final String? selectedCollectionName;
  final String? selectedAnimationId;
  final String? selectedAnimationName;
  final String? selectedSceneId;
  final DateTime savedAt;

  SessionStateModel({
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
      defaultAnimationItemIndex > 0 ||
      selectedCollectionId != null ||
      selectedAnimationId != null;

  /// Whether this state is recent enough to be worth resuming (within 7 days).
  bool get isRecent =>
      DateTime.now().difference(savedAt).inDays < 7;

  /// A human-readable summary of where the user was.
  String get displaySummary {
    final parts = <String>[];
    if (selectedCollectionName != null) {
      parts.add(selectedCollectionName!);
    }
    if (selectedAnimationName != null) {
      parts.add(selectedAnimationName!);
    }
    if (parts.isEmpty) {
      parts.add('Screen ${defaultAnimationItemIndex + 1}');
    }
    return parts.join(' › ');
  }
}
