import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart'; // Adjust path

abstract class DefaultLineupDatasource {
  Future<List<FormationCategory>> getFormationCategories();
  Future<List<FormationTemplate>> getFormationTemplatesForCategory(
    String categoryId,
  );
  Future<List<FormationTemplate>> getAllFormationTemplates();

  Future<void> addFormationCategory(FormationCategory category);
  Future<void> addFormationTemplate(FormationTemplate template);
  Future<void> updateFormationTemplate(FormationTemplate template);
  Future<void> deleteFormationTemplate(String templateId);
  Future<void> updateFormationCategory(FormationCategory category);
  Future<void> deleteFormationCategory(String categoryId);
}
