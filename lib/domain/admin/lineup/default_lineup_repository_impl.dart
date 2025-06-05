import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/admin/datasource/default_lineup_datasource.dart';
import 'package:zporter_tactical_board/data/admin/datasource/local/lineup_cache_datasource_impl.dart';
import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart';

import 'default_lineup_repository.dart';

class DefaultLineupRepositoryImpl implements DefaultLineupRepository {
  final DefaultLineupDatasource localDataSource;
  final LineupCacheDataSource localCacheDataSource;

  DefaultLineupRepositoryImpl({
    required this.localDataSource,
    required this.localCacheDataSource,
  });

  @override
  Future<List<FormationCategory>> getFormationCategories() async {
    // Here you could add logic: try remote, if fails try local, cache, etc.
    return localDataSource.getFormationCategories();
  }

  @override
  Future<List<FormationTemplate>> getFormationTemplatesForCategory(
    String categoryId,
  ) async {
    return localDataSource.getFormationTemplatesForCategory(categoryId);
  }

  @override
  Future<List<FormationTemplate>> getAllFormationTemplates() async {
    return localDataSource.getAllFormationTemplates();
  }

  @override
  Future<void> addFormationCategory(FormationCategory category) async {
    return localDataSource.addFormationCategory(category);
  }

  @override
  Future<void> addFormationTemplate(FormationTemplate template) async {
    return localDataSource.addFormationTemplate(template);
  }

  @override
  Future<void> updateFormationTemplate(FormationTemplate template) async {
    return localDataSource.updateFormationTemplate(template);
  }

  @override
  Future<void> deleteFormationTemplate(String templateId) async {
    return localDataSource.deleteFormationTemplate(templateId);
  }

  @override
  Future<void> updateFormationCategory(FormationCategory category) async {
    return localDataSource.updateFormationCategory(category);
  }

  @override
  Future<void> deleteFormationCategory(String categoryId) async {
    return localDataSource.deleteFormationCategory(categoryId);
  }

  @override
  Future<List<CategorizedFormationGroup>> getCategorizedLineupGroups() async {
    List<FormationCategory> categories = [];
    List<FormationTemplate> allTemplates = [];
    bool fetchedFromRemote = false;

    try {
      zlog(
        data:
            "Repository: Attempting to fetch lineup data from remote (Firestore)...",
      );
      // 1. Try fetching from the remote source (Firestore)
      final remoteResults = await Future.wait([
        localDataSource.getFormationCategories(),
        localDataSource.getAllFormationTemplates(),
      ]);

      categories = remoteResults[0] as List<FormationCategory>;
      allTemplates = remoteResults[1] as List<FormationTemplate>;
      fetchedFromRemote = true;
      zlog(
        data:
            "Repository: Successfully fetched data from remote. Categories: ${categories.length}, Templates: ${allTemplates.length}",
      );

      // 2. If successful, cache the data to Sembast
      if (categories.isNotEmpty || allTemplates.isNotEmpty) {
        // Only cache if there's something to cache
        zlog(data: "Repository: Caching fetched data to Sembast...");
        await Future.wait([
          localCacheDataSource.cacheCategories(categories),
          localCacheDataSource.cacheTemplates(allTemplates),
        ]);
        zlog(data: "Repository: Data cached successfully.");
      }
    } catch (e) {
      zlog(
        data:
            "Repository: Failed to fetch from remote: $e. Attempting to load from cache (Sembast)...",
      );
      // 3. If remote fetch fails, try fetching from the local cache (Sembast)
      try {
        final cacheResults = await Future.wait([
          localCacheDataSource.getCachedCategories(),
          localCacheDataSource.getCachedTemplates(),
        ]);
        categories = cacheResults[0] as List<FormationCategory>;
        allTemplates = cacheResults[1] as List<FormationTemplate>;
        zlog(
          data:
              "Repository: Successfully fetched data from cache. Categories: ${categories.length}, Templates: ${allTemplates.length}",
        );

        if (categories.isEmpty && allTemplates.isEmpty) {
          zlog(data: "Repository: Cache is also empty.");
          // Optionally, you could rethrow the original remote error or a specific "cache empty" error.
          // For now, we'll proceed, and it will result in an empty groupedData list.
        }
      } catch (cacheError) {
        zlog(
          data: "Repository: Failed to fetch from cache as well: $cacheError",
        );
        // If both remote and cache fail, rethrow the original remote error or a more generic one
        throw Exception(
          "Failed to get categorized lineup groups from both remote and cache. Original error: $e, Cache error: $cacheError",
        );
      }
    }

    // 4. Combine the fetched (or cached) data
    if (categories.isEmpty && !fetchedFromRemote) {
      // If categories list is empty and we didn't even attempt a successful remote fetch (e.g., remote failed, cache was empty)
      zlog(data: "Repository: No categories available to form groups.");
      return [];
    }
    if (categories.isEmpty && fetchedFromRemote) {
      zlog(
        data:
            "Repository: Fetched from remote, but no categories found. Returning empty groups.",
      );
      return [];
    }

    final Map<String, List<FormationTemplate>> templatesByCategoryId = {};
    for (var template in allTemplates) {
      (templatesByCategoryId[template.categoryId] ??= []).add(template);
    }

    List<CategorizedFormationGroup> groupedData = [];
    for (var category in categories) {
      groupedData.add(
        CategorizedFormationGroup(
          category: category,
          templates: templatesByCategoryId[category.categoryId] ?? [],
        ),
      );
    }
    zlog(
      data:
          "Repository: Successfully combined data into ${groupedData.length} categorized groups.",
    );
    return groupedData;
  }
}
