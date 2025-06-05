import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart';

enum LineupStatus { initial, loading, success, error }

class LineupState {
  final LineupStatus status;
  final List<FormationCategory> categories;
  final List<FormationTemplate> allTemplates; // Store all templates
  final String? errorMessage;
  final List<CategorizedFormationGroup> categorizedGroups;

  const LineupState({
    this.status = LineupStatus.initial,
    this.categories = const [],
    this.allTemplates = const [],
    this.errorMessage,
    this.categorizedGroups = const [],
  });

  LineupState copyWith({
    LineupStatus? status,
    List<FormationCategory>? categories,
    List<FormationTemplate>? allTemplates,
    String? errorMessage,
    bool clearError = false, // Helper to clear error explicitly
    List<CategorizedFormationGroup>? categorizedGroups,
  }) {
    return LineupState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      allTemplates: allTemplates ?? this.allTemplates,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      categorizedGroups: categorizedGroups ?? this.categorizedGroups,
    );
  }
}
