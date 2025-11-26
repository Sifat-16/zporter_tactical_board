import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/app/services/sync/models/sync_operation.dart';
import 'package:zporter_tactical_board/app/services/sync/sync_queue_manager.dart';

void main() {
  group('SyncQueueStatus', () {
    test('creates status with default values', () {
      const status = SyncQueueStatus();

      expect(status.pendingCount, 0);
      expect(status.processingCount, 0);
      expect(status.failedCount, 0);
      expect(status.completedCount, 0);
      expect(status.isSyncing, false);
      expect(status.lastError, null);
      expect(status.lastSyncAt, null);
    });

    test('creates status with custom values', () {
      final now = DateTime.now();
      final status = SyncQueueStatus(
        pendingCount: 5,
        processingCount: 2,
        failedCount: 1,
        completedCount: 10,
        isSyncing: true,
        lastError: 'Test error',
        lastSyncAt: now,
      );

      expect(status.pendingCount, 5);
      expect(status.processingCount, 2);
      expect(status.failedCount, 1);
      expect(status.completedCount, 10);
      expect(status.isSyncing, true);
      expect(status.lastError, 'Test error');
      expect(status.lastSyncAt, now);
    });

    test('copyWith creates new instance with updated values', () {
      const original = SyncQueueStatus(
        pendingCount: 5,
        isSyncing: false,
      );

      final updated = original.copyWith(
        pendingCount: 3,
        isSyncing: true,
      );

      expect(updated.pendingCount, 3);
      expect(updated.isSyncing, true);
      expect(original.pendingCount, 5);
      expect(original.isSyncing, false);
    });

    test('toString provides readable format', () {
      const status = SyncQueueStatus(
        pendingCount: 5,
        processingCount: 2,
        failedCount: 1,
        completedCount: 10,
        isSyncing: true,
      );

      final str = status.toString();

      expect(str, contains('pending: 5'));
      expect(str, contains('processing: 2'));
      expect(str, contains('failed: 1'));
      expect(str, contains('completed: 10'));
      expect(str, contains('syncing: true'));
    });
  });

  group('SyncOperation Enums', () {
    test('SyncOperationType has all expected values', () {
      expect(SyncOperationType.values.length, 3);
      expect(SyncOperationType.values, contains(SyncOperationType.create));
      expect(SyncOperationType.values, contains(SyncOperationType.update));
      expect(SyncOperationType.values, contains(SyncOperationType.delete));
    });

    test('SyncPriority has all expected values', () {
      expect(SyncPriority.values.length, 3);
      expect(SyncPriority.values, contains(SyncPriority.high));
      expect(SyncPriority.values, contains(SyncPriority.normal));
      expect(SyncPriority.values, contains(SyncPriority.low));
    });

    test('SyncOperationStatus has all expected values', () {
      expect(SyncOperationStatus.values.length, 5);
      expect(SyncOperationStatus.values, contains(SyncOperationStatus.pending));
      expect(
          SyncOperationStatus.values, contains(SyncOperationStatus.processing));
      expect(
          SyncOperationStatus.values, contains(SyncOperationStatus.completed));
      expect(SyncOperationStatus.values, contains(SyncOperationStatus.failed));
      expect(SyncOperationStatus.values,
          contains(SyncOperationStatus.permanentlyFailed));
    });
  });

  // Note: Full integration tests for SyncQueueManager would require:
  // 1. Sembast database setup/teardown
  // 2. Mock datasources for local/remote
  // 3. Async operation testing
  // These are better suited for integration tests rather than unit tests
  // The model tests above cover the core business logic
}
