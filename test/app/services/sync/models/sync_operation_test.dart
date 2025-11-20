import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/app/services/sync/models/sync_operation.dart';

void main() {
  group('SyncOperation', () {
    group('Model Creation', () {
      test('creates operation with required fields', () {
        final operation = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: DateTime(2025, 11, 19),
        );

        expect(operation.id, 'test-id');
        expect(operation.type, SyncOperationType.update);
        expect(operation.collectionId, 'collection-123');
        expect(operation.userId, 'user-456');
        expect(operation.priority, SyncPriority.normal);
        expect(operation.retryCount, 0);
        expect(operation.maxRetries, 3);
        expect(operation.status, SyncOperationStatus.pending);
      });

      test('creates operation with custom priority', () {
        final operation = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.create,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.high,
          createdAt: DateTime.now(),
        );

        expect(operation.priority, SyncPriority.high);
      });

      test('creates operation with custom max retries', () {
        final operation = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.delete,
          collectionId: 'collection-123',
          userId: 'user-456',
          maxRetries: 5,
          createdAt: DateTime.now(),
        );

        expect(operation.maxRetries, 5);
      });
    });

    group('CopyWith', () {
      test('copies with updated retry count', () {
        final original = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: DateTime.now(),
        );

        final updated = original.copyWith(retryCount: 2);

        expect(updated.id, original.id);
        expect(updated.retryCount, 2);
        expect(updated.type, original.type);
      });

      test('copies with updated status', () {
        final original = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: DateTime.now(),
        );

        final updated =
            original.copyWith(status: SyncOperationStatus.completed);

        expect(updated.status, SyncOperationStatus.completed);
        expect(original.status, SyncOperationStatus.pending);
      });

      test('copies with error message', () {
        final original = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: DateTime.now(),
        );

        final updated = original.copyWith(
          errorMessage: 'Network error',
          status: SyncOperationStatus.failed,
        );

        expect(updated.errorMessage, 'Network error');
        expect(updated.status, SyncOperationStatus.failed);
      });
    });

    group('JSON Serialization', () {
      test('serializes to JSON correctly', () {
        final operation = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.high,
          createdAt: DateTime(2025, 11, 19, 10, 30),
          retryCount: 1,
        );

        final json = operation.toJson();

        expect(json['id'], 'test-id');
        expect(json['type'], 'update');
        expect(json['collectionId'], 'collection-123');
        expect(json['userId'], 'user-456');
        expect(json['priority'], 'high');
        expect(json['createdAt'], '2025-11-19T10:30:00.000');
        expect(json['retryCount'], 1);
        expect(json['maxRetries'], 3);
        expect(json['status'], 'pending');
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'id': 'test-id',
          'type': 'create',
          'collectionId': 'collection-123',
          'userId': 'user-456',
          'priority': 'low',
          'createdAt': '2025-11-19T10:30:00.000',
          'retryCount': 2,
          'maxRetries': 5,
          'status': 'failed',
          'errorMessage': 'Test error',
        };

        final operation = SyncOperation.fromJson(json);

        expect(operation.id, 'test-id');
        expect(operation.type, SyncOperationType.create);
        expect(operation.collectionId, 'collection-123');
        expect(operation.userId, 'user-456');
        expect(operation.priority, SyncPriority.low);
        expect(operation.retryCount, 2);
        expect(operation.maxRetries, 5);
        expect(operation.status, SyncOperationStatus.failed);
        expect(operation.errorMessage, 'Test error');
      });

      test('round-trip serialization preserves data', () {
        final original = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.delete,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.high,
          createdAt: DateTime(2025, 11, 19, 10, 30),
          retryCount: 1,
          errorMessage: 'Previous error',
          status: SyncOperationStatus.failed,
        );

        final json = original.toJson();
        final deserialized = SyncOperation.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.type, original.type);
        expect(deserialized.collectionId, original.collectionId);
        expect(deserialized.userId, original.userId);
        expect(deserialized.priority, original.priority);
        expect(deserialized.retryCount, original.retryCount);
        expect(deserialized.errorMessage, original.errorMessage);
        expect(deserialized.status, original.status);
      });
    });

    group('Retry Logic', () {
      test('canRetry returns true when retries available and status is failed',
          () {
        final operation = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: DateTime.now(),
          retryCount: 1,
          maxRetries: 3,
          status: SyncOperationStatus.failed,
        );

        expect(operation.canRetry, true);
      });

      test('canRetry returns false when max retries reached', () {
        final operation = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: DateTime.now(),
          retryCount: 3,
          maxRetries: 3,
          status: SyncOperationStatus.failed,
        );

        expect(operation.canRetry, false);
      });

      test('canRetry returns false when status is not failed', () {
        final operation = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: DateTime.now(),
          retryCount: 1,
          maxRetries: 3,
          status: SyncOperationStatus.completed,
        );

        expect(operation.canRetry, false);
      });

      test('isReadyToRetry returns true when can retry and no nextRetryAt', () {
        final operation = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: DateTime.now(),
          retryCount: 1,
          maxRetries: 3,
          status: SyncOperationStatus.failed,
        );

        expect(operation.isReadyToRetry, true);
      });

      test('isReadyToRetry returns false when nextRetryAt is in future', () {
        final operation = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: DateTime.now(),
          retryCount: 1,
          maxRetries: 3,
          status: SyncOperationStatus.failed,
          nextRetryAt: DateTime.now().add(Duration(seconds: 10)),
        );

        expect(operation.isReadyToRetry, false);
      });

      test('isReadyToRetry returns true when nextRetryAt is in past', () {
        final operation = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: DateTime.now(),
          retryCount: 1,
          maxRetries: 3,
          status: SyncOperationStatus.failed,
          nextRetryAt: DateTime.now().subtract(Duration(seconds: 10)),
        );

        expect(operation.isReadyToRetry, true);
      });

      test('calculateNextRetryTime uses exponential backoff', () {
        final baseTime = DateTime.now();

        // First retry: 2^0 = 1 second
        final operation1 = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: baseTime,
          retryCount: 0,
        );
        final nextRetry1 = operation1.calculateNextRetryTime();
        expect(
          nextRetry1.difference(baseTime).inSeconds,
          closeTo(1, 1),
        );

        // Second retry: 2^1 = 2 seconds
        final operation2 = operation1.copyWith(retryCount: 1);
        final nextRetry2 = operation2.calculateNextRetryTime();
        expect(
          nextRetry2.difference(baseTime).inSeconds,
          closeTo(2, 1),
        );

        // Third retry: 2^2 = 4 seconds
        final operation3 = operation1.copyWith(retryCount: 2);
        final nextRetry3 = operation3.calculateNextRetryTime();
        expect(
          nextRetry3.difference(baseTime).inSeconds,
          closeTo(4, 1),
        );

        // Fourth retry: 2^3 = 8 seconds
        final operation4 = operation1.copyWith(retryCount: 3);
        final nextRetry4 = operation4.calculateNextRetryTime();
        expect(
          nextRetry4.difference(baseTime).inSeconds,
          closeTo(8, 1),
        );
      });

      test('calculateNextRetryTime caps at 60 seconds', () {
        final baseTime = DateTime.now();
        final operation = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: baseTime,
          retryCount: 10, // 2^10 = 1024 seconds, should be capped at 60
        );

        final nextRetry = operation.calculateNextRetryTime();
        final diff = nextRetry.difference(baseTime).inSeconds;

        expect(diff, lessThanOrEqualTo(60));
        expect(diff, greaterThanOrEqualTo(59)); // Allow 1 second tolerance
      });
    });

    group('Priority Score', () {
      test('high priority operations have higher score', () {
        final highPriority = SyncOperation(
          id: 'test-id-1',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.high,
          createdAt: DateTime.now(),
        );

        final normalPriority = SyncOperation(
          id: 'test-id-2',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.normal,
          createdAt: DateTime.now(),
        );

        expect(highPriority.priorityScore,
            greaterThan(normalPriority.priorityScore));
      });

      test('normal priority operations have higher score than low', () {
        final normalPriority = SyncOperation(
          id: 'test-id-1',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.normal,
          createdAt: DateTime.now(),
        );

        final lowPriority = SyncOperation(
          id: 'test-id-2',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.low,
          createdAt: DateTime.now(),
        );

        expect(normalPriority.priorityScore,
            greaterThan(lowPriority.priorityScore));
      });

      test('older operations have higher score', () {
        final older = SyncOperation(
          id: 'test-id-1',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.normal,
          createdAt: DateTime.now().subtract(Duration(minutes: 10)),
        );

        final newer = SyncOperation(
          id: 'test-id-2',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.normal,
          createdAt: DateTime.now(),
        );

        expect(older.priorityScore, greaterThan(newer.priorityScore));
      });

      test('retry count decreases priority score', () {
        final noRetries = SyncOperation(
          id: 'test-id-1',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.normal,
          createdAt: DateTime.now(),
          retryCount: 0,
        );

        final withRetries = SyncOperation(
          id: 'test-id-2',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.normal,
          createdAt: DateTime.now(),
          retryCount: 2,
        );

        expect(noRetries.priorityScore, greaterThan(withRetries.priorityScore));
      });
    });

    group('Equality', () {
      test('operations with same values are equal', () {
        final op1 = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.high,
          createdAt: DateTime(2025, 11, 19),
        );

        final op2 = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.high,
          createdAt: DateTime(2025, 11, 19),
        );

        expect(op1, equals(op2));
        expect(op1.hashCode, equals(op2.hashCode));
      });

      test('operations with different ids are not equal', () {
        final op1 = SyncOperation(
          id: 'test-id-1',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: DateTime.now(),
        );

        final op2 = SyncOperation(
          id: 'test-id-2',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          createdAt: DateTime.now(),
        );

        expect(op1, isNot(equals(op2)));
      });
    });

    group('ToString', () {
      test('toString provides readable format', () {
        final operation = SyncOperation(
          id: 'test-id',
          type: SyncOperationType.update,
          collectionId: 'collection-123',
          userId: 'user-456',
          priority: SyncPriority.high,
          createdAt: DateTime.now(),
          retryCount: 1,
          maxRetries: 3,
          status: SyncOperationStatus.failed,
        );

        final str = operation.toString();

        expect(str, contains('test-id'));
        expect(str, contains('update'));
        expect(str, contains('collection-123'));
        expect(str, contains('user-456'));
        expect(str, contains('high'));
        expect(str, contains('failed'));
        expect(str, contains('1/3'));
      });
    });
  });
}
