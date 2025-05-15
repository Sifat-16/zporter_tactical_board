// File: lib/data/admin/datasources/lineup_firestore_datasource_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart'; // Assuming you use the logger package
import 'package:zporter_tactical_board/app/core/constants/firestore_constant.dart'; // Your constants
import 'package:zporter_tactical_board/app/helper/logger.dart'; // Your zlog helper
import 'package:zporter_tactical_board/data/admin/datasource/default_lineup_datasource.dart';
import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart';
// Assuming LineupLocalDataSource is the interface we defined earlier
// If you rename it to LineupDataSource, update here.

class DefaultLineupDatasourceImpl implements DefaultLineupDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _categoryCollectionRef;
  late final CollectionReference<Map<String, dynamic>> _templateCollectionRef;

  DefaultLineupDatasourceImpl() {
    _categoryCollectionRef = _firestore.collection(
      FirestoreConstant.FORMATION_CATEGORIES,
    );
    _templateCollectionRef = _firestore.collection(
      FirestoreConstant.FORMATION_TEMPLATES,
    );
  }

  @override
  Future<List<FormationCategory>> getFormationCategories() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _categoryCollectionRef.get();
      if (snapshot.docs.isEmpty) {
        zlog(
          level: Level.debug,
          data: "Firestore: No formation categories found.",
        );
        return [];
      }
      final categories =
          snapshot.docs
              .map((doc) => FormationCategory.fromJson(doc.data()))
              .toList();
      zlog(
        level: Level.debug,
        data: "Firestore: Fetched ${categories.length} formation categories.",
      );
      return categories;
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error getting formation categories: ${e.code} - ${e.message}",
      );
      throw Exception("Error getting formation categories: ${e.message}");
    } catch (e) {
      zlog(level: Level.error, data: "Error getting formation categories: $e");
      throw Exception("Error getting formation categories: $e");
    }
  }

  @override
  Future<List<FormationTemplate>> getAllFormationTemplates() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _templateCollectionRef.get();
      if (snapshot.docs.isEmpty) {
        zlog(
          level: Level.debug,
          data: "Firestore: No formation templates found.",
        );
        return [];
      }
      final templates =
          snapshot.docs
              .map((doc) => FormationTemplate.fromJson(doc.data()))
              .toList();
      zlog(
        level: Level.debug,
        data: "Firestore: Fetched ${templates.length} formation templates.",
      );
      return templates;
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error getting all formation templates: ${e.code} - ${e.message}",
      );
      throw Exception("Error getting all formation templates: ${e.message}");
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error getting all formation templates: $e",
      );
      throw Exception("Error getting all formation templates: $e");
    }
  }

  @override
  Future<List<FormationTemplate>> getFormationTemplatesForCategory(
    String categoryId,
  ) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _templateCollectionRef
              .where('categoryId', isEqualTo: categoryId) // Query by categoryId
              .get();

      if (snapshot.docs.isEmpty) {
        zlog(
          level: Level.debug,
          data:
              "Firestore: No formation templates found for category ID: $categoryId.",
        );
        return [];
      }
      final templates =
          snapshot.docs
              .map((doc) => FormationTemplate.fromJson(doc.data()))
              .toList();
      zlog(
        level: Level.debug,
        data:
            "Firestore: Fetched ${templates.length} formation templates for category ID: $categoryId.",
      );
      return templates;
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error getting templates for category $categoryId: ${e.code} - ${e.message}",
      );
      throw Exception(
        "Error getting templates for category $categoryId: ${e.message}",
      );
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error getting templates for category $categoryId: $e",
      );
      throw Exception("Error getting templates for category $categoryId: $e");
    }
  }

  @override
  Future<void> addFormationCategory(FormationCategory category) async {
    // For categories, the categoryId is often human-readable (e.g., "11v11")
    // or based on numberOfPlayers. We assume it's set correctly before calling.
    // If you need Firestore to generate an ID, you'd modify this.
    // Let's assume category.categoryId is the intended document ID.
    if (category.categoryId.isEmpty) {
      zlog(
        level: Level.warning,
        data: "Firestore: FormationCategory categoryId is empty. Cannot save.",
      );
      throw Exception("Category ID cannot be empty for saving.");
    }
    try {
      // Use the provided categoryId as the document ID.
      // This implies categoryId should be unique and well-defined.
      await _categoryCollectionRef
          .doc(category.categoryId)
          .set(category.toJson());
      zlog(
        level: Level.debug,
        data:
            "Firestore: Added/Updated formation category with ID: ${category.categoryId}",
      );
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error adding formation category ${category.categoryId}: ${e.code} - ${e.message}",
      );
      throw Exception("Error adding formation category: ${e.message}");
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error adding formation category ${category.categoryId}: $e",
      );
      throw Exception("Error adding formation category: $e");
    }
  }

  @override
  Future<void> addFormationTemplate(FormationTemplate template) async {
    FormationTemplate templateWithId = template;
    try {
      String docId = template.templateId;
      if (docId.isEmpty) {
        final newDocRef = _templateCollectionRef.doc();
        docId = newDocRef.id;
        templateWithId = template.copyWith(
          templateId: docId,
        ); // Use copyWith if available, or manually update
        zlog(
          level: Level.info,
          data:
              "Firestore: Generated new document ID for formation template: $docId",
        );
      }
      await _templateCollectionRef.doc(docId).set(templateWithId.toJson());
      zlog(
        level: Level.debug,
        data: "Firestore: Added/Updated formation template with ID: $docId",
      );
      // If the interface required returning FormationTemplate, you'd return templateWithId here.
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error adding formation template ${templateWithId.templateId}: ${e.code} - ${e.message}",
      );
      throw Exception("Error adding formation template: ${e.message}");
    } catch (e) {
      zlog(
        level: Level.error,
        data:
            "Error adding formation template ${templateWithId.templateId}: $e",
      );
      throw Exception("Error adding formation template: $e");
    }
  }

  @override
  Future<void> updateFormationTemplate(FormationTemplate template) async {
    if (template.templateId.isEmpty) {
      zlog(
        level: Level.error,
        data: "Firestore: Cannot update template with empty ID.",
      );
      throw Exception("Template ID cannot be empty for update.");
    }
    try {
      await _templateCollectionRef
          .doc(template.templateId)
          .update(template.toJson());
      zlog(
        level: Level.debug,
        data:
            "Firestore: Updated formation template with ID: ${template.templateId}",
      );
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error updating formation template ${template.templateId}: ${e.code} - ${e.message}",
      );
      throw Exception("Error updating formation template: ${e.message}");
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error updating formation template ${template.templateId}: $e",
      );
      throw Exception("Error updating formation template: $e");
    }
  }

  @override
  Future<void> deleteFormationTemplate(String templateId) async {
    if (templateId.isEmpty) {
      zlog(
        level: Level.error,
        data: "Firestore: Cannot delete template with empty ID.",
      );
      throw Exception("Template ID cannot be empty for deletion.");
    }
    try {
      await _templateCollectionRef.doc(templateId).delete();
      zlog(
        level: Level.debug,
        data: "Firestore: Deleted formation template with ID: $templateId",
      );
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error deleting formation template $templateId: ${e.code} - ${e.message}",
      );
      throw Exception("Error deleting formation template: ${e.message}");
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error deleting formation template $templateId: $e",
      );
      throw Exception("Error deleting formation template: $e");
    }
  }

  @override
  Future<void> updateFormationCategory(FormationCategory category) async {
    if (category.categoryId.isEmpty) {
      zlog(
        level: Level.error,
        data: "Firestore: Cannot update category with empty ID.",
      );
      throw Exception("Category ID cannot be empty for update.");
    }
    try {
      // Assuming categoryId is the document ID and is not being changed.
      // We are updating other fields like displayName.
      await _categoryCollectionRef
          .doc(category.categoryId)
          .update(category.toJson());
      zlog(
        level: Level.debug,
        data:
            "Firestore: Updated formation category with ID: ${category.categoryId}",
      );
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error updating category ${category.categoryId}: ${e.code} - ${e.message}",
      );
      throw Exception("Error updating category: ${e.message}");
    } catch (e) {
      zlog(
        level: Level.error,
        data: "Error updating category ${category.categoryId}: $e",
      );
      throw Exception("Error updating category: $e");
    }
  }

  @override
  Future<void> deleteFormationCategory(String categoryId) async {
    if (categoryId.isEmpty) {
      zlog(
        level: Level.error,
        data: "Firestore: Cannot delete category with empty ID.",
      );
      throw Exception("Category ID cannot be empty for deletion.");
    }
    try {
      // 1. Delete all templates associated with this category
      final WriteBatch batch = _firestore.batch();
      final QuerySnapshot<Map<String, dynamic>> templatesSnapshot =
          await _templateCollectionRef
              .where('categoryId', isEqualTo: categoryId)
              .get();

      if (templatesSnapshot.docs.isNotEmpty) {
        for (final doc in templatesSnapshot.docs) {
          batch.delete(doc.reference);
        }
        zlog(
          level: Level.debug,
          data:
              "Firestore: Batch deleting ${templatesSnapshot.docs.length} templates for category $categoryId.",
        );
      }

      // 2. Delete the category itself
      batch.delete(_categoryCollectionRef.doc(categoryId));
      zlog(
        level: Level.debug,
        data: "Firestore: Batch deleting category $categoryId.",
      );

      await batch.commit();
      zlog(
        level: Level.debug,
        data:
            "Firestore: Successfully deleted category $categoryId and its templates.",
      );
    } on FirebaseException catch (e) {
      zlog(
        level: Level.error,
        data:
            "Firebase error deleting category $categoryId: ${e.code} - ${e.message}",
      );
      throw Exception("Error deleting category: ${e.message}");
    } catch (e) {
      zlog(level: Level.error, data: "Error deleting category $categoryId: $e");
      throw Exception("Error deleting category: $e");
    }
  }
}
