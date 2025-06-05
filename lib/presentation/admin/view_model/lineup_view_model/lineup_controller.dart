import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart';
import 'package:zporter_tactical_board/domain/admin/lineup/default_lineup_repository.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/lineup_view_model/lineup_state.dart';

final lineupProvider = StateNotifierProvider<LineupController, LineupState>(
  (ref) => LineupController(ref),
);

class LineupController extends StateNotifier<LineupState> {
  LineupController(this.ref) : super(const LineupState()) {
    _initialize();
  }

  final DefaultLineupRepository _repository = sl.get();
  final Ref ref;

  Future<void> _initialize() async {
    await Future.wait([
      fetchCategoriesAndTemplates(),
      fetchCategorizedLineups(),
    ]);
  }

  Future<List<CategorizedFormationGroup>> fetchCategorizedLineups() async {
    List<CategorizedFormationGroup> items = state.categorizedGroups;
    if (items.isNotEmpty) {
      return items;
    }
    state = state.copyWith(status: LineupStatus.loading, clearError: true);
    try {
      final data = await Future.wait([
        _repository.getCategorizedLineupGroups(),
        _repository.getFormationCategories(),
        _repository.getAllFormationTemplates(),
      ]);

      state = state.copyWith(
        status: LineupStatus.success,
        categorizedGroups: data[0] as List<CategorizedFormationGroup>?,
        categories:
            data[1]
                as List<
                  FormationCategory
                >?, // Populate if keeping them in state
        allTemplates:
            data[2]
                as List<
                  FormationTemplate
                >?, // Populate if keeping them in state
      );
      return state.categorizedGroups;
    } catch (e) {
      state = state.copyWith(
        status: LineupStatus.error,
        errorMessage: e.toString(),
      );
    }
    return [];
  }

  Future<void> fetchCategoriesAndTemplates() async {
    state = state.copyWith(status: LineupStatus.loading, clearError: true);
    try {
      final categories = await _repository.getFormationCategories();
      final templates = await _repository.getAllFormationTemplates();
      state = state.copyWith(
        status: LineupStatus.success,
        categories: categories,
        allTemplates: templates,
      );
    } catch (e) {
      state = state.copyWith(
        status: LineupStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> createLineup(
    FormationCategory categoryData,
    FormationTemplate templateData,
  ) async {
    state = state.copyWith(status: LineupStatus.loading, clearError: true);
    try {
      bool categoryExists = state.categories.any(
        (c) => c.categoryId == categoryData.categoryId,
      );
      if (!categoryExists) {
        await _repository.addFormationCategory(categoryData);
      }
      await _repository.addFormationTemplate(templateData);
      await fetchCategoriesAndTemplates(); // Refresh all data
    } catch (e) {
      state = state.copyWith(
        status: LineupStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> editLineupTemplate(FormationTemplate template) async {
    state = state.copyWith(status: LineupStatus.loading, clearError: true);
    try {
      await _repository.updateFormationTemplate(template);
      // Instead of fetching all, just update the local state if successful for better UX
      final updatedTemplates = List<FormationTemplate>.from(state.allTemplates);
      final index = updatedTemplates.indexWhere(
        (t) => t.templateId == template.templateId,
      );
      if (index != -1) {
        updatedTemplates[index] = template;
        state = state.copyWith(
          status: LineupStatus.success,
          allTemplates: updatedTemplates,
        );
      } else {
        // If not found, refresh all (should not happen ideally)
        await fetchCategoriesAndTemplates();
      }
    } catch (e) {
      state = state.copyWith(
        status: LineupStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteLineupTemplate(String templateId) async {
    state = state.copyWith(status: LineupStatus.loading, clearError: true);
    try {
      await _repository.deleteFormationTemplate(templateId);
      // Instead of fetching all, just update the local state
      final updatedTemplates = List<FormationTemplate>.from(state.allTemplates)
        ..removeWhere((t) => t.templateId == templateId);
      state = state.copyWith(
        status: LineupStatus.success,
        allTemplates: updatedTemplates,
      );
    } catch (e) {
      state = state.copyWith(
        status: LineupStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> editFormationCategory(FormationCategory category) async {
    // We only allow editing displayName for now.
    // categoryId and numberOfPlayers should remain the same for an existing category.
    state = state.copyWith(status: LineupStatus.loading, clearError: true);
    try {
      await _repository.updateFormationCategory(category);
      await fetchCategoriesAndTemplates();
    } catch (e) {
      state = state.copyWith(
        status: LineupStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteFormationCategory(String categoryId) async {
    state = state.copyWith(status: LineupStatus.loading, clearError: true);
    try {
      await _repository.deleteFormationCategory(categoryId);
      // Refresh data: category and its templates will be gone
      await fetchCategoriesAndTemplates();
    } catch (e) {
      state = state.copyWith(
        status: LineupStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
