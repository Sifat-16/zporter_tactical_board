// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/services/injection_container.dart';
// import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart';
// import 'package:zporter_tactical_board/domain/admin/lineup/default_lineup_repository.dart';
// import 'package:zporter_tactical_board/presentation/admin/view_model/lineup_view_model/lineup_state.dart';
//
// final lineupProvider = StateNotifierProvider<LineupController, LineupState>(
//   (ref) => LineupController(ref),
// );
//
// class LineupController extends StateNotifier<LineupState> {
//   LineupController(this.ref) : super(const LineupState()) {
//     _initialize();
//   }
//
//   final DefaultLineupRepository _repository = sl.get();
//   final Ref ref;
//
//   Future<void> _initialize() async {
//     await Future.wait([
//       fetchCategoriesAndTemplates(),
//       fetchCategorizedLineups(),
//     ]);
//   }
//
//   Future<List<CategorizedFormationGroup>> fetchCategorizedLineups() async {
//     List<CategorizedFormationGroup> items = state.categorizedGroups;
//     if (items.isNotEmpty) {
//       return items;
//     }
//     state = state.copyWith(status: LineupStatus.loading, clearError: true);
//     try {
//       final data = await Future.wait([
//         _repository.getCategorizedLineupGroups(),
//         _repository.getFormationCategories(),
//         _repository.getAllFormationTemplates(),
//       ]);
//
//       state = state.copyWith(
//         status: LineupStatus.success,
//         categorizedGroups: data[0] as List<CategorizedFormationGroup>?,
//         categories: data[1]
//             as List<FormationCategory>?, // Populate if keeping them in state
//         allTemplates: data[2]
//             as List<FormationTemplate>?, // Populate if keeping them in state
//       );
//       return state.categorizedGroups;
//     } catch (e) {
//       state = state.copyWith(
//         status: LineupStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//     return [];
//   }
//
//   Future<void> fetchCategoriesAndTemplates() async {
//     state = state.copyWith(status: LineupStatus.loading, clearError: true);
//     try {
//       final categories = await _repository.getFormationCategories();
//       final templates = await _repository.getAllFormationTemplates();
//       state = state.copyWith(
//         status: LineupStatus.success,
//         categories: categories,
//         allTemplates: templates,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         status: LineupStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }
//
//   // Future<void> createLineup(
//   //   FormationCategory categoryData,
//   //   FormationTemplate templateData,
//   // ) async {
//   //   state = state.copyWith(status: LineupStatus.loading, clearError: true);
//   //   try {
//   //     bool categoryExists = state.categories.any(
//   //       (c) => c.categoryId == categoryData.categoryId,
//   //     );
//   //     if (!categoryExists) {
//   //       await _repository.addFormationCategory(categoryData);
//   //     }
//   //     await _repository.addFormationTemplate(templateData);
//   //     await fetchCategoriesAndTemplates(); // Refresh all data
//   //   } catch (e) {
//   //     state = state.copyWith(
//   //       status: LineupStatus.error,
//   //       errorMessage: e.toString(),
//   //     );
//   //   }
//   // }
//
//   Future<void> createLineup(
//       FormationCategory categoryData, FormationTemplate templateData) async {
//     state = state.copyWith(status: LineupStatus.loading, clearError: true);
//     try {
//       // NEW LOGIC: Set order index for new items
//       int categoryOrder = state.categories.length;
//       int templateOrder = state.allTemplates
//           .where((t) => t.categoryId == categoryData.categoryId)
//           .length;
//
//       final categoryToCreate = categoryData.copyWith(orderIndex: categoryOrder);
//       final templateToCreate = templateData.copyWith(orderIndex: templateOrder);
//
//       bool categoryExists = state.categories
//           .any((c) => c.categoryId == categoryToCreate.categoryId);
//       if (!categoryExists) {
//         await _repository.addFormationCategory(categoryToCreate);
//       }
//       await _repository.addFormationTemplate(templateToCreate);
//       await fetchCategoriesAndTemplates(); // Refresh all data
//     } catch (e) {
//       state = state.copyWith(
//         status: LineupStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }
//
//   Future<void> editLineupTemplate(FormationTemplate template) async {
//     state = state.copyWith(status: LineupStatus.loading, clearError: true);
//     try {
//       await _repository.updateFormationTemplate(template);
//       // Instead of fetching all, just update the local state if successful for better UX
//       final updatedTemplates = List<FormationTemplate>.from(state.allTemplates);
//       final index = updatedTemplates.indexWhere(
//         (t) => t.templateId == template.templateId,
//       );
//       if (index != -1) {
//         updatedTemplates[index] = template;
//         state = state.copyWith(
//           status: LineupStatus.success,
//           allTemplates: updatedTemplates,
//         );
//       } else {
//         // If not found, refresh all (should not happen ideally)
//         await fetchCategoriesAndTemplates();
//       }
//     } catch (e) {
//       state = state.copyWith(
//         status: LineupStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }
//
//   Future<void> deleteLineupTemplate(String templateId) async {
//     state = state.copyWith(status: LineupStatus.loading, clearError: true);
//     try {
//       await _repository.deleteFormationTemplate(templateId);
//       // Instead of fetching all, just update the local state
//       final updatedTemplates = List<FormationTemplate>.from(state.allTemplates)
//         ..removeWhere((t) => t.templateId == templateId);
//       state = state.copyWith(
//         status: LineupStatus.success,
//         allTemplates: updatedTemplates,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         status: LineupStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }
//
//   Future<void> editFormationCategory(FormationCategory category) async {
//     // We only allow editing displayName for now.
//     // categoryId and numberOfPlayers should remain the same for an existing category.
//     state = state.copyWith(status: LineupStatus.loading, clearError: true);
//     try {
//       await _repository.updateFormationCategory(category);
//       await fetchCategoriesAndTemplates();
//     } catch (e) {
//       state = state.copyWith(
//         status: LineupStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }
//
//   Future<void> deleteFormationCategory(String categoryId) async {
//     state = state.copyWith(status: LineupStatus.loading, clearError: true);
//     try {
//       await _repository.deleteFormationCategory(categoryId);
//       // Refresh data: category and its templates will be gone
//       await fetchCategoriesAndTemplates();
//     } catch (e) {
//       state = state.copyWith(
//         status: LineupStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }
//
//   Future<void> updateLineupOrder({
//     List<FormationCategory>? updatedCategories,
//     List<FormationTemplate>? updatedTemplates,
//   }) async {
//     // Optimistically update the UI state first for a snappy feel
//     final originalState = state;
//     state = state.copyWith(
//       categories: updatedCategories ?? state.categories,
//       allTemplates: updatedTemplates ?? state.allTemplates,
//     );
//
//     try {
//       await _repository.updateLineupOrder(
//         categories: updatedCategories ?? [],
//         templates: updatedTemplates ?? [],
//       );
//     } catch (e) {
//       // If the save fails, revert to the original state and show an error
//       state = originalState.copyWith(
//         status: LineupStatus.error,
//         errorMessage: 'Failed to save new order: $e',
//       );
//     }
//   }
// }

// lib/presentation/admin/view_model/lineup_view_model/lineup_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart'; // Adjust path if needed
import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart'; // Adjust path if needed
import 'package:zporter_tactical_board/domain/admin/lineup/default_lineup_repository.dart'; // Adjust path if needed
import 'package:zporter_tactical_board/presentation/admin/view_model/lineup_view_model/lineup_state.dart'; // Adjust path if needed

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
    await fetchCategoriesAndTemplates();
  }

  /// Helper method to build the sorted and grouped list.
  /// This is the single source of truth for the data structure used by the UI.
  List<CategorizedFormationGroup> _buildCategorizedGroups(
    List<FormationCategory> categories,
    List<FormationTemplate> allTemplates,
  ) {
    // 1. Sort the parent categories by their order index
    final sortedCategories = List<FormationCategory>.from(categories)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    // 2. Map each sorted category to a group, containing its sorted templates
    return sortedCategories.map((category) {
      final sortedTemplates = allTemplates
          .where((template) => template.categoryId == category.categoryId)
          .toList()
        ..sort((a, b) => a.orderIndex
            .compareTo(b.orderIndex)); // Sort templates within the category
      return CategorizedFormationGroup(
        category: category,
        templates: sortedTemplates,
      );
    }).toList();
  }

  /// The primary method to fetch all data from the repository and
  /// update the state, including the sorted/grouped list.
  Future<void> fetchCategoriesAndTemplates() async {
    state = state.copyWith(status: LineupStatus.loading, clearError: true);
    try {
      final categories = await _repository.getFormationCategories();
      final templates = await _repository.getAllFormationTemplates();

      // Build the sorted and grouped list using our helper
      final categorizedGroups = _buildCategorizedGroups(categories, templates);

      state = state.copyWith(
        status: LineupStatus.success,
        categories: categories,
        allTemplates: templates,
        categorizedGroups: categorizedGroups,
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
      int categoryOrder = state.categories.length;
      int templateOrder = state.allTemplates
          .where((t) => t.categoryId == categoryData.categoryId)
          .length;

      final categoryToCreate = categoryData.copyWith(orderIndex: categoryOrder);
      final templateToCreate = templateData.copyWith(orderIndex: templateOrder);

      bool categoryExists = state.categories
          .any((c) => c.categoryId == categoryToCreate.categoryId);
      if (!categoryExists) {
        await _repository.addFormationCategory(categoryToCreate);
      }
      await _repository.addFormationTemplate(templateToCreate);

      // Refresh all data to ensure order is correct and lists are in sync
      await fetchCategoriesAndTemplates();
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
      // A full refresh is the safest way to ensure all parts of the state are consistent
      await fetchCategoriesAndTemplates();
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
      await fetchCategoriesAndTemplates();
    } catch (e) {
      state = state.copyWith(
        status: LineupStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> editFormationCategory(FormationCategory category) async {
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
      await fetchCategoriesAndTemplates();
    } catch (e) {
      state = state.copyWith(
        status: LineupStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// This method is called from the UI after a drag-and-drop action.
  Future<void> updateLineupOrder({
    required List<FormationCategory> updatedCategories,
    required List<FormationTemplate> updatedTemplates,
  }) async {
    // Rebuild the grouped list with the new order received from the UI
    final newCategorizedGroups =
        _buildCategorizedGroups(updatedCategories, updatedTemplates);

    // Optimistically update the UI state immediately for a snappy feel
    final originalState = state;
    state = state.copyWith(
      categories: updatedCategories,
      allTemplates: updatedTemplates,
      categorizedGroups: newCategorizedGroups,
    );

    try {
      // Persist the changes to the database
      await _repository.updateLineupOrder(
        categories: updatedCategories,
        templates: updatedTemplates,
      );
    } catch (e) {
      // If the save fails, revert to the original state and show an error
      state = originalState.copyWith(
        status: LineupStatus.error,
        errorMessage: 'Failed to save new order: $e',
      );
    }
  }
}
