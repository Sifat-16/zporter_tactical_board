import 'dart:async';
import 'dart:math' as math;
import 'package:logger/logger.dart';
import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart';
import 'package:zporter_tactical_board/app/config/feature_flags.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/services/connectivity_service.dart';
import 'package:zporter_tactical_board/app/services/storage/image_conversion_service.dart';
import 'package:zporter_tactical_board/app/services/storage/image_storage_service.dart';
import 'package:zporter_tactical_board/app/services/sync/models/sync_operation.dart';
import 'package:zporter_tactical_board/data/admin/datasource/default_animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/datasource/local/animation_local_datasource_impl.dart';
import 'package:zporter_tactical_board/data/animation/datasource/remote/animation_remote_datasource_impl.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';

/// Status of the sync queue
class SyncQueueStatus {
  /// Number of operations pending in queue
  final int pendingCount;

  /// Number of operations currently processing
  final int processingCount;

  /// Number of operations that failed
  final int failedCount;

  /// Total operations completed in this session
  final int completedCount;

  /// Whether sync is currently active
  final bool isSyncing;

  /// Last error message (if any)
  final String? lastError;

  /// Last sync timestamp
  final DateTime? lastSyncAt;

  const SyncQueueStatus({
    this.pendingCount = 0,
    this.processingCount = 0,
    this.failedCount = 0,
    this.completedCount = 0,
    this.isSyncing = false,
    this.lastError,
    this.lastSyncAt,
  });

  SyncQueueStatus copyWith({
    int? pendingCount,
    int? processingCount,
    int? failedCount,
    int? completedCount,
    bool? isSyncing,
    String? lastError,
    DateTime? lastSyncAt,
  }) {
    return SyncQueueStatus(
      pendingCount: pendingCount ?? this.pendingCount,
      processingCount: processingCount ?? this.processingCount,
      failedCount: failedCount ?? this.failedCount,
      completedCount: completedCount ?? this.completedCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastError: lastError ?? this.lastError,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return 'SyncQueueStatus(pending: $pendingCount, processing: $processingCount, '
        'failed: $failedCount, completed: $completedCount, syncing: $isSyncing)';
  }
}

/// Manages the sync queue for offline-first operations
class SyncQueueManager {
  // Sembast store for sync queue
  static final _syncQueueStore = intMapStoreFactory.store('sync_queue');

  // Local and remote datasources
  final AnimationLocalDatasourceImpl _localDataSource;
  final AnimationRemoteDatasourceImpl _remoteDataSource;
  final DefaultAnimationDatasource? _defaultAnimationDataSource;
  final ImageStorageService? _imageStorageService;

  // Status stream controller
  final _statusController = StreamController<SyncQueueStatus>.broadcast();

  // Current status
  SyncQueueStatus _currentStatus = const SyncQueueStatus();

  // Processing lock
  bool _isProcessing = false;

  // Queue size limit
  static const int maxQueueSize = 50;

  SyncQueueManager({
    required AnimationLocalDatasourceImpl localDataSource,
    required AnimationRemoteDatasourceImpl remoteDataSource,
    DefaultAnimationDatasource? defaultAnimationDataSource,
    ImageStorageService? imageStorageService,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _defaultAnimationDataSource = defaultAnimationDataSource,
        _imageStorageService = imageStorageService {
    // Reset any stuck processing operations on initialization
    _resetStuckOperations();
  }

  /// Reset any operations stuck in 'processing' state back to 'pending'
  /// This can happen if the app crashes or is closed while syncing
  Future<void> _resetStuckOperations() async {
    try {
      final db = await SemDB.database;
      final finder = Finder(
        filter: Filter.equals('status', 'processing'),
      );
      final processingOps = await _syncQueueStore.find(db, finder: finder);

      if (processingOps.isEmpty) return;

      zlog(
        level: Level.info,
        data:
            'Resetting ${processingOps.length} stuck operations to pending...',
      );

      for (final snapshot in processingOps) {
        final operation = SyncOperation.fromJson(snapshot.value);
        final resetOp = operation.copyWith(
          status: SyncOperationStatus.pending,
          lastAttemptAt: null,
        );
        await _syncQueueStore.record(snapshot.key).put(db, resetOp.toJson());
      }

      zlog(
        level: Level.info,
        data: 'All stuck operations reset successfully',
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error resetting stuck operations: $e\n$stackTrace',
      );
    }
  }

  /// Stream of sync queue status updates
  Stream<SyncQueueStatus> get statusStream => _statusController.stream;

  /// Get current status
  SyncQueueStatus get currentStatus => _currentStatus;

  /// Enqueue a new sync operation
  Future<void> enqueue(SyncOperation operation) async {
    try {
      final db = await SemDB.database;

      // Check queue size
      final currentSize = await _syncQueueStore.count(db);
      if (currentSize >= maxQueueSize) {
        zlog(
          level: Level.warning,
          data:
              'Sync queue full ($currentSize operations). Removing oldest low-priority operation.',
        );
        await _removeOldestLowPriorityOperation(db);
      }

      // Generate unique key for this operation
      final key = DateTime.now().millisecondsSinceEpoch;

      // Save to queue
      await _syncQueueStore.record(key).put(db, operation.toJson());

      zlog(
        level: Level.debug,
        data:
            'Enqueued sync operation: ${operation.id} (${operation.type.name})',
      );

      // Update status
      await _updateStatus();
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error enqueuing sync operation: $e\n$stackTrace',
      );
    }
  }

  /// Process all pending operations in the queue
  Future<void> processQueue() async {
    if (_isProcessing) {
      zlog(
        level: Level.debug,
        data: 'Sync queue already processing, skipping...',
      );
      return;
    }

    _isProcessing = true;
    _currentStatus = _currentStatus.copyWith(isSyncing: true);
    _statusController.add(_currentStatus);

    try {
      final db = await SemDB.database;

      // Get all pending or failed (ready to retry) operations
      final finder = Finder(
        sortOrders: [SortOrder('priority', false)], // High priority first
      );
      final snapshots = await _syncQueueStore.find(db, finder: finder);

      zlog(
        level: Level.info,
        data:
            '🚀 Processing sync queue: ${snapshots.length} operations in parallel',
      );

      // Process all operations in parallel using Future.wait()
      final futures = snapshots.map((snapshot) async {
        try {
          final operation = SyncOperation.fromJson(snapshot.value);

          // Skip if not ready to process
          if (operation.status == SyncOperationStatus.processing ||
              operation.status == SyncOperationStatus.completed ||
              !operation.isReadyToRetry) {
            return;
          }

          // Process the operation
          await _processOperation(db, snapshot.key, operation);
        } catch (e, stackTrace) {
          zlog(
            level: Level.error,
            data:
                'Error processing sync operation ${snapshot.key}: $e\n$stackTrace',
          );
        }
      }).toList();

      // Wait for all operations to complete
      await Future.wait(futures);

      // Update status after processing
      await _updateStatus();
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error processing sync queue: $e\n$stackTrace',
      );
      _currentStatus = _currentStatus.copyWith(
        isSyncing: false,
        lastError: e.toString(),
      );
      _statusController.add(_currentStatus);
    } finally {
      _isProcessing = false;
      _currentStatus = _currentStatus.copyWith(isSyncing: false);
      _statusController.add(_currentStatus);
    }
  }

  /// Process a single sync operation
  Future<void> _processOperation(
    Database db,
    int key,
    SyncOperation operation,
  ) async {
    try {
      // Mark as processing
      final processingOp = operation.copyWith(
        status: SyncOperationStatus.processing,
        lastAttemptAt: DateTime.now(),
      );
      await _syncQueueStore.record(key).put(db, processingOp.toJson());

      zlog(
        level: Level.debug,
        data:
            'Processing sync operation: ${operation.id} (${operation.type.name})',
      );

      // Execute the sync operation based on type
      switch (operation.type) {
        case SyncOperationType.create:
        case SyncOperationType.update:
          await _syncCreateOrUpdate(operation);
          break;
        case SyncOperationType.delete:
          await _syncDelete(operation);
          break;
      }

      // Mark as completed and remove from queue
      await _syncQueueStore.record(key).delete(db);

      zlog(
        level: Level.info,
        data:
            'Sync operation completed: ${operation.id} (${operation.type.name})',
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Sync operation failed: ${operation.id} - $e\n$stackTrace',
      );

      // Handle retry logic
      await _handleOperationFailure(db, key, operation, e.toString());
    }
  }

  /// Sync create or update operation
  Future<void> _syncCreateOrUpdate(SyncOperation operation) async {
    // Check data type from metadata
    final dataType = operation.metadata?['dataType'] as String? ?? 'collection';

    if (dataType == 'singleDefaultAnimation') {
      // Handle single default animation sync (from admin screen)
      if (_defaultAnimationDataSource == null) {
        throw Exception('DefaultAnimationDatasource not available for sync');
      }

      final animationId = operation.metadata?['animationId'] as String?;
      if (animationId == null) {
        throw Exception('No animationId in sync operation metadata');
      }

      // Get the animation from local storage
      final animation =
          await _localDataSource.getDefaultAnimationById(animationId);
      if (animation == null) {
        throw Exception(
            'Default animation $animationId not found in local storage');
      }

      // Save to Firebase using the default animation datasource
      await _defaultAnimationDataSource.saveDefaultAnimation(animation);
    } else if (dataType == 'defaultAnimations') {
      // Handle default animations sync
      final defaultAnimations = await _localDataSource.getDefaultAnimations(
        userId: operation.userId,
      );

      if (defaultAnimations.isEmpty) {
        return;
      }

      // Migrate default animation images before uploading
      // This ensures base64 images convert to Firebase Storage URLs during sync
      zlog(
        level: Level.info,
        data:
            '[SyncQueue] Migrating default animations images (base64 → Firebase Storage URLs)...',
      );
      final migratedAnimations = await _migrateDefaultAnimationImages(
          defaultAnimations, operation.userId);

      // Save to remote (Firestore) with URLs instead of base64
      await _remoteDataSource.saveDefaultAnimations(
        animationItems: migratedAnimations,
        userId: operation.userId,
      );

      // Update local Sembast with migrated URLs to stay in sync
      await _localDataSource.saveDefaultAnimations(
        animationItems: migratedAnimations,
        userId: operation.userId,
      );
    } else {
      // Handle animation collection sync (original logic)
      final collections = await _localDataSource.getAllAnimationCollection(
        userId: operation.userId,
      );

      final collection = collections.firstWhere(
        (c) => c.id == operation.collectionId,
        orElse: () =>
            throw Exception('Collection not found: ${operation.collectionId}'),
      );

      // CRITICAL FIX: Migrate images before uploading to Firestore
      // This ensures base64 images convert to Firebase Storage URLs during sync
      final migratedCollection = await _migrateCollectionImages(collection);

      // Save to remote (Firestore) with URLs instead of base64
      await _remoteDataSource.saveAnimationCollection(
        animationCollectionModel: migratedCollection,
      );

      // Update local Sembast with migrated URLs to stay in sync
      await _localDataSource.saveAnimationCollection(
        animationCollectionModel: migratedCollection,
      );

      print(
          '[SyncQueue] Synced collection ${collection.id} with migrated images');
    }
  }

  /// Migrate default animation images from base64 to Firebase Storage URLs
  /// This ensures default animations don't upload huge base64 to Firestore
  Future<List<AnimationItemModel>> _migrateDefaultAnimationImages(
    List<AnimationItemModel> animations,
    String userId,
  ) async {
    // Check if image optimization is enabled
    if (!FeatureFlags.enableImageOptimization ||
        !FeatureFlags.enableAutoImageUpload ||
        _imageStorageService == null) {
      zlog(
        level: Level.debug,
        data:
            '[SyncQueue] Image optimization disabled or service unavailable, skipping default animation migration',
      );
      return animations;
    }

    // Check connectivity
    final isOnline = await ConnectivityService.checkRealtimeConnectivity();
    if (!isOnline) {
      zlog(
        level: Level.warning,
        data:
            '[SyncQueue] OFFLINE during sync - skipping default animation migration',
      );
      return animations;
    }

    zlog(
      level: Level.info,
      data:
          '[SyncQueue] Migrating ${animations.length} default animation items...',
    );

    final migratedAnimations = <AnimationItemModel>[];
    bool hasChanges = false;

    for (final animation in animations) {
      final migratedComponents = [...animation.components];
      bool animationChanged = false;

      // Process each component in the animation
      for (int i = 0; i < migratedComponents.length; i++) {
        final component = migratedComponents[i];

        // Migrate PlayerModel images
        if (component is PlayerModel) {
          // DEBUG: Log player image state
          print('[SyncQueue] Default animation player ${component.id}: '
              'imageBase64=${component.imageBase64?.substring(0, 50) ?? "null"}..., '
              'imageUrl=${component.imageUrl ?? "null"}, '
              'imagePath=${component.imagePath ?? "null"}, '
              'needsMigration=${component.needsImageMigration}');

          if (component.needsImageMigration) {
            try {
              print(
                  '[SyncQueue] Migrating default animation player image: ${component.id}');

              final bytes =
                  ImageConversionService.base64ToBytes(component.imageBase64);
              if (bytes != null) {
                final imageUrl = await _imageStorageService.uploadPlayerImage(
                  userId: userId,
                  playerId: component.id,
                  imageData: bytes,
                );

                migratedComponents[i] = component.copyWith(imageUrl: imageUrl);
                animationChanged = true;
                hasChanges = true;

                print(
                    '[SyncQueue] ✅ Default animation player image migrated: ${component.id} → $imageUrl (${bytes.length} bytes)');
              } else {
                print(
                    '[SyncQueue] Failed to convert base64 to bytes for player ${component.id}');
              }
            } catch (e, stackTrace) {
              print(
                  '[SyncQueue] ❌ Failed to migrate default animation player image ${component.id}: $e\n$stackTrace');
              // Keep original with base64
            }
          }
        }
      }

      if (animationChanged) {
        migratedAnimations
            .add(animation.copyWith(components: migratedComponents));
      } else {
        migratedAnimations.add(animation);
      }
    }

    if (hasChanges) {
      zlog(
        level: Level.info,
        data: '[SyncQueue] \u2705 Default animation image migration complete!',
      );
    }

    return migratedAnimations;
  }

  /// Migrate collection images from base64 to Firebase Storage URLs
  /// This is the CRITICAL FIX that ensures images upload during sync
  Future<AnimationCollectionModel> _migrateCollectionImages(
    AnimationCollectionModel collection,
  ) async {
    // Check if image optimization is enabled
    if (!FeatureFlags.enableImageOptimization ||
        !FeatureFlags.enableAutoImageUpload ||
        _imageStorageService == null) {
      zlog(
        level: Level.debug,
        data:
            '[SyncQueue] Image optimization disabled or service unavailable, skipping migration for ${collection.id}',
      );
      return collection;
    }

    // Check connectivity - sync queue should only process when online
    final isOnline = await ConnectivityService.checkRealtimeConnectivity();
    if (!isOnline) {
      zlog(
        level: Level.warning,
        data:
            '[SyncQueue] OFFLINE during sync - this should not happen! Skipping image migration for ${collection.id}',
      );
      return collection;
    }

    zlog(
      level: Level.info,
      data:
          '[SyncQueue] Migrating images for collection ${collection.id} (base64 → Firebase Storage URLs)...',
    );

    bool hasChanges = false;
    final migratedAnimations = <AnimationModel>[];

    // Process each animation in the collection
    for (final animation in collection.animations) {
      final migratedScenes = <AnimationItemModel>[];
      bool animationChanged = false;

      // Process each scene in the animation
      for (final scene in animation.animationScenes) {
        final migratedComponents = [...scene.components];
        bool sceneChanged = false;

        // Process each component in the scene
        for (int i = 0; i < migratedComponents.length; i++) {
          final component = migratedComponents[i];

          // Migrate PlayerModel images
          if (component is PlayerModel) {
            // DEBUG: Log player image state
            print('[SyncQueue] Collection player ${component.id}: '
                'imageBase64=${component.imageBase64?.substring(0, math.min(50, component.imageBase64?.length ?? 0)) ?? "null"}..., '
                'imageUrl=${component.imageUrl ?? "null"}, '
                'imagePath=${component.imagePath ?? "null"}, '
                'needsMigration=${component.needsImageMigration}');

            if (component.needsImageMigration) {
              try {
                print(
                    '[SyncQueue] Migrating player image: ${component.id} (${component.imageBase64?.length ?? 0} bytes base64)');

                final bytes =
                    ImageConversionService.base64ToBytes(component.imageBase64);
                if (bytes != null) {
                  final imageUrl = await _imageStorageService.uploadPlayerImage(
                    userId: collection.userId,
                    playerId: component.id,
                    imageData: bytes,
                  );

                  migratedComponents[i] =
                      component.copyWith(imageUrl: imageUrl);
                  sceneChanged = true;
                  hasChanges = true;

                  print(
                      '[SyncQueue] ✅ Player image migrated: ${component.id} → $imageUrl (${bytes.length} bytes → ${imageUrl.length} bytes, saved ${bytes.length - imageUrl.length} bytes)');
                } else {
                  print(
                      '[SyncQueue] Failed to convert base64 to bytes for player ${component.id}');
                }
              } catch (e, stackTrace) {
                print(
                    '[SyncQueue] ❌ Failed to migrate player image ${component.id}: $e\n$stackTrace. Keeping base64 as fallback.');
                // Keep original component with base64 - don't fail entire sync
                // This handles cases where upload fails due to network issues
              }
            }
          }

          // Migrate EquipmentModel images (if needed in future)
          if (component is EquipmentModel && component.needsImageMigration) {
            // Equipment currently uses local asset paths, not user-uploaded images
            // Skip migration for now unless we add support for user-uploaded equipment images
          }
        }

        if (sceneChanged) {
          migratedScenes.add(scene.copyWith(components: migratedComponents));
          animationChanged = true;
        } else {
          migratedScenes.add(scene);
        }
      }

      if (animationChanged) {
        migratedAnimations
            .add(animation.copyWith(animationScenes: migratedScenes));
      } else {
        migratedAnimations.add(animation);
      }
    }

    if (hasChanges) {
      zlog(
        level: Level.info,
        data:
            '[SyncQueue] ✅ Collection ${collection.id} image migration complete! Uploading URLs to Firestore instead of base64.',
      );
      return collection.copyWith(animations: migratedAnimations);
    }

    zlog(
      level: Level.debug,
      data: '[SyncQueue] No images needed migration in ${collection.id}',
    );
    return collection;
  }

  /// Sync delete operation
  Future<void> _syncDelete(SyncOperation operation) async {
    // Delete from remote (Firestore)
    await _remoteDataSource.deleteAnimationCollection(
      collectionId: operation.collectionId,
    );
  }

  /// Handle operation failure with retry logic
  Future<void> _handleOperationFailure(
    Database db,
    int key,
    SyncOperation operation,
    String errorMessage,
  ) async {
    final newRetryCount = operation.retryCount + 1;

    if (newRetryCount >= operation.maxRetries) {
      // Mark as permanently failed
      final failedOp = operation.copyWith(
        status: SyncOperationStatus.permanentlyFailed,
        retryCount: newRetryCount,
        errorMessage: errorMessage,
      );
      await _syncQueueStore.record(key).put(db, failedOp.toJson());

      zlog(
        level: Level.error,
        data:
            'Sync operation permanently failed after ${operation.maxRetries} retries: ${operation.id}',
      );
    } else {
      // Schedule retry with exponential backoff
      final nextRetryAt = operation.calculateNextRetryTime();
      final retryOp = operation.copyWith(
        status: SyncOperationStatus.failed,
        retryCount: newRetryCount,
        errorMessage: errorMessage,
        nextRetryAt: nextRetryAt,
      );
      await _syncQueueStore.record(key).put(db, retryOp.toJson());

      zlog(
        level: Level.warning,
        data:
            'Sync operation failed, will retry at $nextRetryAt: ${operation.id} (attempt $newRetryCount/${operation.maxRetries})',
      );
    }
  }

  /// Remove oldest low-priority operation to make space
  Future<void> _removeOldestLowPriorityOperation(Database db) async {
    final finder = Finder(
      sortOrders: [SortOrder('createdAt', true)], // Oldest first
    );
    final snapshots = await _syncQueueStore.find(db, finder: finder);

    for (final snapshot in snapshots) {
      final operation = SyncOperation.fromJson(snapshot.value);
      if (operation.priority == SyncPriority.low) {
        await _syncQueueStore.record(snapshot.key).delete(db);
        zlog(
          level: Level.warning,
          data:
              'Removed old low-priority operation from queue: ${operation.id}',
        );
        break;
      }
    }
  }

  /// Update current status by counting operations
  Future<void> _updateStatus() async {
    try {
      final db = await SemDB.database;
      final snapshots = await _syncQueueStore.find(db);

      int pending = 0;
      int processing = 0;
      int failed = 0;

      for (final snapshot in snapshots) {
        final operation = SyncOperation.fromJson(snapshot.value);
        switch (operation.status) {
          case SyncOperationStatus.pending:
            pending++;
            break;
          case SyncOperationStatus.processing:
            processing++;
            break;
          case SyncOperationStatus.failed:
          case SyncOperationStatus.permanentlyFailed:
            failed++;
            break;
          case SyncOperationStatus.completed:
            break;
        }
      }

      _currentStatus = _currentStatus.copyWith(
        pendingCount: pending,
        processingCount: processing,
        failedCount: failed,
        lastSyncAt: DateTime.now(),
      );
      _statusController.add(_currentStatus);
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error updating sync status: $e\n$stackTrace',
      );
    }
  }

  /// Clear all operations from queue
  Future<void> clearQueue() async {
    try {
      final db = await SemDB.database;
      await _syncQueueStore.delete(db);
      await _updateStatus();

      zlog(
        level: Level.info,
        data: 'Sync queue cleared',
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error clearing sync queue: $e\n$stackTrace',
      );
    }
  }

  /// Get count of pending operations
  Future<int> getPendingCount() async {
    try {
      final db = await SemDB.database;
      return await _syncQueueStore.count(db);
    } catch (e) {
      return 0;
    }
  }

  /// Check if a specific collection has pending sync operations
  /// Returns true if there are unsynced changes for this collection
  Future<bool> hasPendingChanges(String collectionId) async {
    try {
      final db = await SemDB.database;
      final finder = Finder(
        filter: Filter.and([
          Filter.equals('collectionId', collectionId),
          Filter.or([
            Filter.equals('status', SyncOperationStatus.pending.name),
            Filter.equals('status', SyncOperationStatus.processing.name),
            Filter.equals('status', SyncOperationStatus.failed.name),
          ]),
        ]),
      );
      final snapshots = await _syncQueueStore.find(db, finder: finder);
      return snapshots.isNotEmpty;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data:
            'Error checking pending changes for $collectionId: $e\n$stackTrace',
      );
      // On error, assume there might be pending changes (safer)
      return true;
    }
  }

  /// Get all collection IDs that have pending sync operations
  /// Useful for bulk checking to avoid overwriting unsynced data
  Future<Set<String>> getPendingCollectionIds() async {
    try {
      final db = await SemDB.database;
      final finder = Finder(
        filter: Filter.or([
          Filter.equals('status', SyncOperationStatus.pending.name),
          Filter.equals('status', SyncOperationStatus.processing.name),
          Filter.equals('status', SyncOperationStatus.failed.name),
        ]),
      );
      final snapshots = await _syncQueueStore.find(db, finder: finder);
      final collectionIds = <String>{};

      for (final snapshot in snapshots) {
        final operation = SyncOperation.fromJson(snapshot.value);
        collectionIds.add(operation.collectionId);
      }

      return collectionIds;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error getting pending collection IDs: $e\n$stackTrace',
      );
      return {};
    }
  }

  /// Dispose resources
  void dispose() {
    _statusController.close();
  }
}
