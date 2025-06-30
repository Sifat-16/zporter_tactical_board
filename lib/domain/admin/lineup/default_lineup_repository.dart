import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart'; // Adjust path as needed

abstract class DefaultLineupRepository {
  Future<List<FormationCategory>> getFormationCategories();
  Future<List<FormationTemplate>> getFormationTemplatesForCategory(
    String categoryId,
  );
  Future<List<FormationTemplate>>
      getAllFormationTemplates(); // To filter by category client-side or for _buildUnifiedList

  Future<void> addFormationCategory(
    FormationCategory category,
  ); // If categories can be user-created
  Future<void> addFormationTemplate(FormationTemplate template);
  Future<void> updateFormationTemplate(FormationTemplate template);
  Future<void> deleteFormationTemplate(String templateId);
  Future<void> updateFormationCategory(FormationCategory category);
  Future<void> deleteFormationCategory(String categoryId);
  Future<List<CategorizedFormationGroup>> getCategorizedLineupGroups();

  Future<void> updateLineupOrder({
    required List<FormationCategory> categories,
    required List<FormationTemplate> templates,
  });
}
