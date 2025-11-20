# Phase 2: Core Architecture - Implementation Plan

## Overview
**Goal:** Implement offline-first architecture with local database and intelligent sync  
**Duration:** 3 weeks  
**Expected Impact:** 99.9% document size reduction + full offline capability

---

## Week 1: Local-First Repository Layer

### Day 1-2: Local Datasource Implementation

#### Task 1.1: Create Abstract Local Datasource
**File:** `lib/data/animation/datasource/local/animation_local_datasource.dart`
```dart
abstract class AnimationLocalDataSource {
  Future<void> saveAnimationCollection(AnimationCollectionModel model);
  Future<AnimationCollectionModel?> getAnimationCollection(String collectionId);
  Future<List<AnimationCollectionModel>> getAllAnimationCollections(String userId);
  Future<void> deleteAnimationCollection(String collectionId);
  Future<List<String>> getAllPendingSyncIds();
  Future<void> markAsSynced(String collectionId);
  Future<void> markAsPendingSync(String collectionId);
}
```

#### Task 1.2: Implement Sembast Local Datasource
**File:** `lib/data/animation/datasource/local/animation_local_datasource_impl.dart`
```dart
class AnimationLocalDataSourceImpl implements AnimationLocalDataSource {
  final Database _database;
  final StoreRef<String, Map<String, dynamic>> _store;
  
  // Use existing semDB database instance
  // Store: 'animations' for main data
  // Store: 'sync_metadata' for sync tracking
}
```

**Key Methods:**
- Save to IndexedDB (web) or file system (mobile)
- Query by userId, collectionId
- Track sync status per document
- Efficient JSON serialization

#### Task 1.3: Enhance Repository
**File:** `lib/data/animation/repository/animation_repository_impl.dart`

**Changes:**
- Add `AnimationLocalDataSource` dependency
- Implement dual-mode save:
  ```dart
  @override
  Future<void> saveAnimationCollection(AnimationCollectionModel model) async {
    // 1. Save to local FIRST (always succeeds, instant)
    await _localDataSource.saveAnimationCollection(model);
    
    // 2. Queue for cloud sync (if feature enabled)
    if (FeatureFlags.enableLocalFirstMode) {
      await _syncQueue.enqueue(SyncOperation(...));
    } else {
      // Fallback: Direct Firebase save (Phase 1 behavior)
      await _remoteDataSource.saveAnimationCollection(model);
    }
  }
  ```

**Estimated:** 2 days

---

### Day 3-4: Sync Queue Manager

#### Task 2.1: Create Sync Operation Model
**File:** `lib/app/services/sync/models/sync_operation.dart`
```dart
enum SyncOperationType { create, update, delete }
enum SyncPriority { high, normal, low }

class SyncOperation {
  final String id;
  final SyncOperationType type;
  final String collectionId;
  final SyncPriority priority;
  final DateTime createdAt;
  final int retryCount;
  final String? errorMessage;
}
```

#### Task 2.2: Implement Sync Queue Manager
**File:** `lib/app/services/sync/sync_queue_manager.dart`
```dart
class SyncQueueManager {
  final AnimationRemoteDataSource _remoteDataSource;
  final AnimationLocalDataSource _localDataSource;
  
  // Priority queue with retry logic
  // Exponential backoff: 1s, 2s, 4s, 8s, 16s
  // Max retries: 3
  // Batch operations when possible
  
  Future<void> processQueue();
  Future<void> enqueue(SyncOperation operation);
  Future<void> clearQueue();
  Stream<SyncStatus> get statusStream;
}
```

**Features:**
- Persistent queue (survives app restart)
- Retry with exponential backoff
- Batch multiple operations
- Conflict detection

**Estimated:** 2 days

---

### Day 5: Network Monitoring

#### Task 3.1: Connectivity Service
**File:** `lib/app/services/network/connectivity_service.dart`
```dart
class ConnectivityService {
  final Connectivity _connectivity;
  
  Stream<ConnectivityResult> get connectivityStream;
  Future<bool> get isOnline;
  Future<NetworkQuality> get quality; // WiFi/Cellular/None
}
```

#### Task 3.2: Sync Orchestrator
**File:** `lib/app/services/sync/sync_orchestrator_service.dart`
```dart
class SyncOrchestratorService {
  final SyncQueueManager _queueManager;
  final ConnectivityService _connectivity;
  
  // Listen to connectivity changes
  // Trigger sync when online
  // Pause sync when offline
  // Handle app lifecycle
  
  void start();
  void pause();
  Future<void> syncNow();
}
```

**Estimated:** 1 day

---

## Week 2: Data Model Optimization

### Day 6-7: Image Storage Optimization

#### Task 4.1: Image Storage Service
**File:** `lib/app/services/storage/image_storage_service.dart`
```dart
class ImageStorageService {
  final FirebaseStorage _storage;
  
  Future<String> uploadPlayerImage(String playerId, Uint8List imageData);
  Future<String> uploadEquipmentImage(String equipmentId, Uint8List imageData);
  Future<void> deleteImage(String imageUrl);
  Future<Uint8List?> downloadImage(String imageUrl);
  
  // Compress to WebP format
  // Generate thumbnails (75x75, 200x200)
  // Upload to gs://zporter-tactical.appspot.com/users/{userId}/players/
}
```

#### Task 4.2: Update Data Models
**Files:**
- `lib/data/tactic/model/player_model.dart`
- `lib/data/tactic/model/equipment_model.dart`

**Changes:**
```dart
class PlayerModel {
  // OLD: final String? image; // base64 string (~75KB)
  // NEW:
  final String? imageUrl; // Firebase Storage URL (~50 bytes)
  final String? localImagePath; // Cached local path
  
  // Migration helper
  Future<PlayerModel> migrateFromBase64(ImageStorageService service);
}
```

#### Task 4.3: Image Cache Manager
**File:** `lib/app/services/storage/image_cache_manager.dart`
```dart
class ImageCacheManager {
  final Directory _cacheDir;
  
  Future<File?> getCachedImage(String imageUrl);
  Future<void> cacheImage(String imageUrl, Uint8List data);
  Future<void> clearCache();
  Future<int> getCacheSize();
}
```

**Estimated:** 2 days

---

### Day 8-9: Sembast Schema Optimization

#### Task 5.1: Define Stores
**File:** `lib/app/config/database/local/semDB.dart`

**Add stores:**
```dart
// Main data store
final animationsStore = stringMapStoreFactory.store('animations');

// Sync queue store
final syncQueueStore = intMapStoreFactory.store('sync_queue');

// Image cache metadata store
final imageCacheStore = stringMapStoreFactory.store('image_cache');

// User preferences store
final preferencesStore = stringMapStoreFactory.store('preferences');

// Sync metadata store
final syncMetadataStore = stringMapStoreFactory.store('sync_metadata');
```

#### Task 5.2: Optimize Data Structure
**Current structure (nested):**
```json
{
  "animations": [
    { "animationItems": [...], "components": [...] }
  ]
}
```

**Optimized structure (flattened):**
```json
{
  "id": "collection_123",
  "userId": "user_456",
  "animations": [...], // IDs only or lightweight data
  "lastModified": "2025-11-18T...",
  "syncStatus": "synced"
}
```

**Estimated:** 2 days

---

### Day 10: App Lifecycle Integration

#### Task 6.1: App Lifecycle Handler
**File:** `lib/app/lifecycle/app_lifecycle_handler.dart`
```dart
class AppLifecycleHandler extends WidgetsBindingObserver {
  final SyncOrchestratorService _syncOrchestrator;
  final AnimationRepository _repository;
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App going to background
        _onAppPaused();
        break;
      case AppLifecycleState.resumed:
        // App coming to foreground
        _onAppResumed();
        break;
      case AppLifecycleState.detached:
        // App closing
        _onAppDetached();
        break;
    }
  }
  
  Future<void> _onAppPaused() async {
    // Trigger immediate save
    // Start background sync (if possible)
  }
  
  Future<void> _onAppResumed() async {
    // Check for updates
    // Resume sync
  }
}
```

**Estimated:** 1 day

---

## Week 3: UI/UX & Background Sync

### Day 11-12: Sync Status UI

#### Task 7.1: Sync Status Provider
**File:** `lib/presentation/common/providers/sync_status_provider.dart`
```dart
class SyncStatusProvider extends StateNotifier<SyncStatusState> {
  final SyncOrchestratorService _orchestrator;
  
  // Listen to sync events
  // Update UI state
  
  Stream<SyncStatusState> get statusStream;
}

class SyncStatusState {
  final bool isSyncing;
  final int pendingOperations;
  final DateTime? lastSyncTimestamp;
  final String? syncError;
  final bool isOnline;
}
```

#### Task 7.2: Sync Status Indicator Widget
**File:** `lib/presentation/common/widgets/sync_status_indicator.dart`
```dart
class SyncStatusIndicator extends StatelessWidget {
  // Small, subtle indicator in app bar or corner
  
  // States:
  // - Synced ✓ (green dot)
  // - Syncing... (blue animated spinner)
  // - Offline (gray cloud-off icon)
  // - Error (red with retry button)
  
  // Tap to show details popup
}
```

**Design:**
- Non-intrusive, corner placement
- Only visible during sync or errors
- Auto-hide after 3 seconds when synced
- Tap for details

**Estimated:** 2 days

---

### Day 13-14: Background Sync Workers

#### Task 8.1: iOS Background Sync
**File:** `lib/app/services/sync/platform/ios_background_sync.dart`
```dart
class IosBackgroundSync {
  // Use Background App Refresh
  // Register background task
  // Process sync queue during background execution
  
  Future<void> registerBackgroundTask();
  Future<void> scheduleSync();
}
```

#### Task 8.2: Android Background Sync
**File:** `lib/app/services/sync/platform/android_background_sync.dart`
```dart
class AndroidBackgroundSync {
  // Use WorkManager
  // Periodic sync worker (every 15 minutes)
  // Guaranteed execution even if app killed
  
  Future<void> registerWorker();
  Future<void> cancelWorker();
}
```

**Estimated:** 2 days

---

### Day 15: Testing & Integration

#### Task 9.1: Integration Tests
**Files:**
- `test/integration/offline_save_and_sync_test.dart`
- `test/integration/conflict_resolution_test.dart`
- `test/integration/image_optimization_test.dart`

**Scenarios:**
- Save offline → Go online → Auto-sync
- Edit on multiple devices → Conflict resolution
- Upload images → Verify URLs in Firestore
- App killed → Restart → Resume sync

#### Task 9.2: Migration Script
**File:** `lib/data/migration/data_migration_service.dart`
```dart
class DataMigrationService {
  // Migrate existing users from Phase 1 to Phase 2
  
  Future<void> migrateToLocalFirst(String userId) async {
    // 1. Download all user data from Firestore
    // 2. Save to Sembast
    // 3. Migrate base64 images to Firebase Storage
    // 4. Update documents with new URLs
    // 5. Mark migration complete
  }
  
  Future<bool> isMigrationComplete(String userId);
}
```

**Estimated:** 1 day

---

## Dependencies to Add

```yaml
dependencies:
  # Already have: sembast, path_provider, connectivity_plus
  
  # Add for Phase 2:
  image: ^4.0.0  # Image compression
  http: ^1.1.0  # HTTP requests for image upload
  workmanager: ^0.5.0  # Android background tasks
  
  # Consider:
  flutter_cache_manager: ^3.3.0  # Advanced caching (optional)
```

---

## Feature Flags for Phase 2

Update `lib/app/config/feature_flags.dart`:
```dart
// Phase 2 flags (enable after implementation complete)
static const bool enableLocalFirstMode = true;  // Enable after Week 1
static const bool enableImageOptimization = true;  // Enable after Week 2
static const bool enableBackgroundSync = true;  // Enable after Week 3
```

---

## Success Criteria

**Technical:**
- ✅ 100% offline functionality
- ✅ Local save latency <50ms
- ✅ Background sync success rate >95%
- ✅ Document size: 4MB → 2.5KB (99.9% reduction)
- ✅ Image storage working (Firebase Storage)

**Business:**
- ✅ Boss requirement met: "Works without Internet"
- ✅ Additional cost savings: $1.50 → $0.40/month at 5K users
- ✅ Zero data loss incidents

**User Experience:**
- ✅ No visible changes (seamless)
- ✅ App feels faster (local operations)
- ✅ Works offline (no errors)
- ✅ Auto-sync when online (no user action needed)

---

## Risk Mitigation

**Risk 1: Data Inconsistency**
- Mitigation: Dual-write for 2 weeks, Firebase as source of truth
- Verification: Background job compares local vs cloud

**Risk 2: Migration Failures**
- Mitigation: Gradual rollout, per-user migration
- Rollback: Keep Firebase data, disable local-first mode

**Risk 3: Sync Queue Growth**
- Mitigation: Queue size limit (50 operations)
- Alert: Notify if queue >20 operations

**Risk 4: Storage Exhaustion**
- Mitigation: LRU cache eviction, keep 50 most recent
- Monitoring: Alert if storage >80% full

---

## Timeline Summary

| Week | Focus | Deliverables |
|------|-------|--------------|
| Week 1 | Local-First Repository | Local datasource, sync queue, network monitoring |
| Week 2 | Data Optimization | Image storage, model updates, Sembast schema |
| Week 3 | UI & Background Sync | Status indicator, background workers, testing |

**Total Duration:** 3 weeks  
**Team Size:** 2 developers  
**Total Effort:** ~120 hours

---

**Ready to begin Phase 2 Week 1?**
