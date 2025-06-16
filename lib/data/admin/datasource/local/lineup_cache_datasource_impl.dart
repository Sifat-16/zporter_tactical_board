// File: lib/data/admin/datasources/lineup_sembast_datasource.dart
// (This would be the implementation file)

import 'package:logger/logger.dart';
import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart'; // Your Sembast DB helper
import 'package:zporter_tactical_board/app/helper/logger.dart'; // Your zlog helper
import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart'; // Your models

// Define an interface for this local cache data source (optional, but good practice)
abstract class LineupCacheDataSource {
  Future<List<FormationCategory>> getCachedCategories();
  Future<void> cacheCategories(List<FormationCategory> categories);
  Future<List<FormationTemplate>> getCachedTemplates();
  Future<void> cacheTemplates(List<FormationTemplate> templates);
  Future<void> clearCache(); // Optional: to clear all cached lineup data
}

class LineupCacheDataSourceImpl implements LineupCacheDataSource {
  static final _categoryStore = stringMapStoreFactory.store(
    'formation_categories_cache',
  );
  static final _templateStore = stringMapStoreFactory.store(
    'formation_templates_cache',
  );

  Future<Database> get _db async =>
      SemDB.database; // Access your Sembast DB instance

  @override
  Future<void> cacheCategories(List<FormationCategory> categories) async {
    try {
      final dbClient = await _db;
      await dbClient.transaction((txn) async {
        // Clear existing categories before caching new ones for a full refresh
        await _categoryStore.delete(txn);
        zlog(
          level: Level.debug,
          data: "Sembast: Cleared existing cached categories.",
        );
        for (var category in categories) {
          // Use categoryId as the key
          await _categoryStore
              .record(category.categoryId)
              .put(txn, category.toJson());
        }
      });
      zlog(
        level: Level.info,
        data:
            "Sembast: Successfully cached ${categories.length} formation categories.",
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Sembast: Error caching formation categories: $e\n$stackTrace",
      );
      // Decide if this error should be rethrown or handled silently
    }
  }

  @override
  Future<List<FormationCategory>> getCachedCategories() async {
    try {
      final dbClient = await _db;
      final snapshots = await _categoryStore.find(dbClient);
      if (snapshots.isEmpty) {
        zlog(
          level: Level.debug,
          data: "Sembast: No cached formation categories found.",
        );
        return [];
      }
      final categories =
          snapshots
              .map((snapshot) {
                try {
                  return FormationCategory.fromJson(snapshot.value);
                } catch (e, stackTrace) {
                  zlog(
                    level: Level.error,
                    data:
                        "Sembast: Error parsing cached category ${snapshot.key}: $e\n$stackTrace",
                  );
                  return null;
                }
              })
              .whereType<FormationCategory>()
              .toList();
      zlog(
        level: Level.info,
        data: "Sembast: Fetched ${categories.length} categories from cache.",
      );
      return categories;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Sembast: Error fetching cached categories: $e\n$stackTrace",
      );
      return []; // Return empty on error to allow fallback to remote
    }
  }

  @override
  Future<void> cacheTemplates(List<FormationTemplate> templates) async {
    try {
      final dbClient = await _db;
      await dbClient.transaction((txn) async {
        // Clear existing templates before caching new ones
        await _templateStore.delete(txn);
        zlog(
          level: Level.debug,
          data: "Sembast: Cleared existing cached templates.",
        );
        for (var template in templates) {
          // Use templateId as the key
          await _templateStore
              .record(template.templateId)
              .put(txn, template.toJson());
        }
      });
      zlog(
        level: Level.info,
        data:
            "Sembast: Successfully cached ${templates.length} formation templates.",
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Sembast: Error caching formation templates: $e\n$stackTrace",
      );
    }
  }

  @override
  Future<List<FormationTemplate>> getCachedTemplates() async {
    try {
      final dbClient = await _db;
      final snapshots = await _templateStore.find(dbClient);
      if (snapshots.isEmpty) {
        zlog(
          level: Level.debug,
          data: "Sembast: No cached formation templates found.",
        );
        return [];
      }
      final templates =
          snapshots
              .map((snapshot) {
                try {
                  return FormationTemplate.fromJson(snapshot.value);
                } catch (e, stackTrace) {
                  zlog(
                    level: Level.error,
                    data:
                        "Sembast: Error parsing cached template ${snapshot.key}: $e\n$stackTrace",
                  );
                  return null;
                }
              })
              .whereType<FormationTemplate>()
              .toList();
      zlog(
        level: Level.info,
        data: "Sembast: Fetched ${templates.length} templates from cache.",
      );
      return templates;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Sembast: Error fetching cached templates: $e\n$stackTrace",
      );
      return [];
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final dbClient = await _db;
      await dbClient.transaction((txn) async {
        await _categoryStore.delete(txn);
        await _templateStore.delete(txn);
      });
      zlog(level: Level.info, data: "Sembast: Cleared all cached lineup data.");
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Sembast: Error clearing cache: $e\n$stackTrace",
      );
    }
  }
}
