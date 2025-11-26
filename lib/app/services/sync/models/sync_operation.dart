/// Types of sync operations that can be performed
enum SyncOperationType {
  /// Create a new document in the remote database
  create,

  /// Update an existing document in the remote database
  update,

  /// Delete a document from the remote database
  delete,
}

/// Priority levels for sync operations
enum SyncPriority {
  /// High priority: User-initiated actions, immediate sync needed
  high,

  /// Normal priority: Regular auto-saves, background sync
  normal,

  /// Low priority: Cleanup operations, optional sync
  low,
}

/// Status of a sync operation
enum SyncOperationStatus {
  /// Operation is pending and waiting to be processed
  pending,

  /// Operation is currently being processed
  processing,

  /// Operation completed successfully
  completed,

  /// Operation failed and needs retry
  failed,

  /// Operation failed permanently after max retries
  permanentlyFailed,
}

/// Represents a single sync operation in the queue
class SyncOperation {
  /// Unique identifier for this sync operation
  final String id;

  /// Type of operation (create, update, delete)
  final SyncOperationType type;

  /// ID of the animation collection to sync
  final String collectionId;

  /// User ID who owns this collection
  final String userId;

  /// Priority of this operation
  final SyncPriority priority;

  /// When this operation was created
  final DateTime createdAt;

  /// Number of times this operation has been retried
  final int retryCount;

  /// Maximum number of retries allowed (default: 3)
  final int maxRetries;

  /// Error message from last failed attempt (if any)
  final String? errorMessage;

  /// Current status of the operation
  final SyncOperationStatus status;

  /// When the operation was last attempted
  final DateTime? lastAttemptAt;

  /// When the next retry should occur (for exponential backoff)
  final DateTime? nextRetryAt;

  /// Additional metadata for the operation (optional)
  final Map<String, dynamic>? metadata;

  const SyncOperation({
    required this.id,
    required this.type,
    required this.collectionId,
    required this.userId,
    this.priority = SyncPriority.normal,
    required this.createdAt,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.errorMessage,
    this.status = SyncOperationStatus.pending,
    this.lastAttemptAt,
    this.nextRetryAt,
    this.metadata,
  });

  /// Create a copy with updated fields
  SyncOperation copyWith({
    String? id,
    SyncOperationType? type,
    String? collectionId,
    String? userId,
    SyncPriority? priority,
    DateTime? createdAt,
    int? retryCount,
    int? maxRetries,
    String? errorMessage,
    SyncOperationStatus? status,
    DateTime? lastAttemptAt,
    DateTime? nextRetryAt,
    Map<String, dynamic>? metadata,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      collectionId: collectionId ?? this.collectionId,
      userId: userId ?? this.userId,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON for storage in Sembast
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'collectionId': collectionId,
      'userId': userId,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'maxRetries': maxRetries,
      'errorMessage': errorMessage,
      'status': status.name,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'nextRetryAt': nextRetryAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create from JSON stored in Sembast
  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: SyncOperationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      collectionId: json['collectionId'] as String,
      userId: json['userId'] as String,
      priority: SyncPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => SyncPriority.normal,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      maxRetries: json['maxRetries'] as int? ?? 3,
      errorMessage: json['errorMessage'] as String?,
      status: SyncOperationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncOperationStatus.pending,
      ),
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'] as String)
          : null,
      nextRetryAt: json['nextRetryAt'] != null
          ? DateTime.parse(json['nextRetryAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Check if this operation can be retried
  bool get canRetry =>
      retryCount < maxRetries && status == SyncOperationStatus.failed;

  /// Check if operation is ready to process or retry
  bool get isReadyToRetry {
    // Pending operations are always ready
    if (status == SyncOperationStatus.pending) return true;

    // Failed operations need to check retry logic
    if (status == SyncOperationStatus.failed) {
      if (retryCount >= maxRetries) return false;
      if (nextRetryAt == null) return true;
      return DateTime.now().isAfter(nextRetryAt!);
    }

    // Other statuses (processing, completed, permanentlyFailed) are not ready
    return false;
  }

  /// Calculate next retry time using exponential backoff
  /// Formula: 2^retryCount seconds (1s, 2s, 4s, 8s, 16s...)
  DateTime calculateNextRetryTime() {
    final secondsToWait = (1 << retryCount).clamp(1, 60); // Max 60 seconds
    return DateTime.now().add(Duration(seconds: secondsToWait));
  }

  /// Get priority score for queue ordering (higher = more urgent)
  int get priorityScore {
    int score = 0;

    // Priority weight (highest impact)
    switch (priority) {
      case SyncPriority.high:
        score += 1000;
        break;
      case SyncPriority.normal:
        score += 500;
        break;
      case SyncPriority.low:
        score += 100;
        break;
    }

    // Age weight (older operations get higher priority)
    final ageInMinutes = DateTime.now().difference(createdAt).inMinutes;
    score += ageInMinutes;

    // Retry penalty (operations that failed get lower priority)
    score -= (retryCount * 50);

    return score;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncOperation &&
        other.id == id &&
        other.type == type &&
        other.collectionId == collectionId &&
        other.userId == userId &&
        other.priority == priority &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      collectionId,
      userId,
      priority,
      status,
    );
  }

  @override
  String toString() {
    return 'SyncOperation(id: $id, type: $type, collectionId: $collectionId, '
        'userId: $userId, priority: $priority, status: $status, '
        'retryCount: $retryCount/$maxRetries)';
  }
}
