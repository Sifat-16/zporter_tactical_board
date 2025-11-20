import 'dart:async';
import 'package:logger/logger.dart';
import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/services/sync/models/sync_operation.dart';
import 'package:zporter_tactical_board/data/animation/datasource/local/animation_local_datasource_impl.dart';
import 'package:zporter_tactical_board/data/animation/datasource/remote/animation_remote_datasource_impl.dart';

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
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

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
        data: 'Processing sync queue: ${snapshots.length} operations',
      );

      for (final snapshot in snapshots) {
        try {
          final operation = SyncOperation.fromJson(snapshot.value);

          // Skip if not ready to process
          if (operation.status == SyncOperationStatus.processing ||
              operation.status == SyncOperationStatus.completed ||
              !operation.isReadyToRetry) {
            continue;
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
      }

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
    // Get the animation collection from local storage
    final collections = await _localDataSource.getAllAnimationCollection(
      userId: operation.userId,
    );

    final collection = collections.firstWhere(
      (c) => c.id == operation.collectionId,
      orElse: () =>
          throw Exception('Collection not found: ${operation.collectionId}'),
    );

    // Save to remote (Firestore)
    await _remoteDataSource.saveAnimationCollection(
      animationCollectionModel: collection,
    );
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

  /// Dispose resources
  void dispose() {
    _statusController.close();
  }
}
