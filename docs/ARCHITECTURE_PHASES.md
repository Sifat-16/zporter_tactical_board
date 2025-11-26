# Offline-First Architecture - Implementation Phases

## Project Overview
**Goal:** Transform Zporter Tactical Board into an offline-first application with 99.4% reduction in database costs and seamless user experience.

**Current Issues:**
- Auto-save every 1 second = 540 Firebase writes per 15-min session
- No offline capability (boss requirement unmet)
- Base64 images in documents = 4MB per save
- High costs: $44.30/month at 5,000 users

**Target Achievements:**
- Auto-save every 30 seconds with smart debouncing = 18 writes per session
- Full offline functionality with Sembast local database
- Image optimization via Firebase Storage = 2.5KB documents
- Reduced costs: $3.40/month at 5,000 users (92% savings)

---

## Phase 1: Quick Wins (Week 1)
**Goal:** Immediate 97% cost reduction with minimal code changes

### 1.1 Debounce Auto-Save Timer
**File:** `lib/presentation/tactic/view/component/board/tactic_board_game.dart`
- Change `_checkInterval` from `1.0` to `30.0` seconds
- Add state change tracking to avoid redundant saves
- **Impact:** 540 writes → 30 writes per session

### 1.2 Event-Driven Saves
**Files:** 
- `lib/presentation/tactic/view/component/board/tactic_board_game.dart`
- `lib/presentation/tactic/view_model/animation/animation_provider.dart`

**Add listeners for:**
- Player drag end event
- Equipment drag end event
- Drawing complete event
- Component add/delete event
- Trajectory path complete event

**Logic:** Trigger immediate save on critical events, skip timer-based redundant saves

### 1.3 Skip History on Auto-Save
**File:** `lib/presentation/tactic/view_model/animation/animation_provider.dart`
- Add `shouldSaveHistory` parameter to save methods
- Skip history writes on auto-save (keep for manual saves only)
- **Impact:** Reduces write operations by ~15%

### Success Metrics
- Firebase writes: 540 → 18 per session (97% reduction)
- User experience: No noticeable changes
- Rollback: Instant (feature flag controlled)

---

## Phase 2: Core Architecture (Weeks 2-4)
**Goal:** Implement offline-first with local database and intelligent sync

### 2.1 Local-First Repository Layer (Week 2)

#### 2.1.1 Create Local Datasource
**New Files:**
- `lib/data/animation/datasource/local/animation_local_datasource.dart` (abstract)
- `lib/data/animation/datasource/local/animation_local_datasource_impl.dart`

**Methods:**
- `saveAnimationCollection(AnimationCollectionModel model)`
- `getAnimationCollection(String collectionId)`
- `deleteAnimationCollection(String collectionId)`
- `getAllPendingSync()`
- `markAsSynced(String collectionId)`

#### 2.1.2 Enhance Repository
**File:** `lib/data/animation/repository/animation_repository_impl.dart`

**Add dual-mode operations:**
```dart
// Save to local immediately (always succeeds)
await _localDataSource.saveAnimationCollection(model);

// Queue for cloud sync (background)
await _syncQueue.enqueue(SyncOperation(
  type: SyncOperationType.update,
  collectionId: model.id,
  priority: SyncPriority.normal,
));
```

### 2.2 Sync Queue Manager (Week 2)

#### 2.2.1 Create Sync Queue Service
**New Files:**
- `lib/app/services/sync/sync_queue_manager.dart`
- `lib/app/services/sync/models/sync_operation.dart`
- `lib/app/services/sync/models/sync_status.dart`

**Features:**
- Priority queue (high/normal/low)
- Retry logic with exponential backoff
- Batch operations when possible
- Conflict resolution strategy

#### 2.2.2 Sync Orchestrator
**New File:** `lib/app/services/sync/sync_orchestrator_service.dart`

**Responsibilities:**
- Monitor network connectivity
- Trigger sync on network available
- Handle app lifecycle (pause/resume)
- Background sync scheduling
- Progress notifications

### 2.3 Data Model Optimization (Week 3)

#### 2.3.1 Separate Image Storage
**Modified Files:**
- `lib/data/animation/models/player_model.dart`
- `lib/data/animation/models/equipment_model.dart`

**Changes:**
```dart
// OLD: image: String? // base64 encoded
// NEW: imageUrl: String? // Firebase Storage URL
//      localImagePath: String? // Cached local path
```

#### 2.3.2 Image Upload Service
**New Files:**
- `lib/app/services/storage/image_storage_service.dart`
- `lib/app/services/storage/image_cache_manager.dart`

**Features:**
- Compress images to WebP format
- Upload to Firebase Storage
- Cache locally for offline access
- Generate thumbnails (75x75, 200x200)

#### 2.3.3 Optimize Sembast Schema
**File:** `lib/app/config/database/local/semDB.dart`

**Add stores:**
```dart
// Main data store
final animationsStore = stringMapStoreFactory.store('animations');

// Sync queue store
final syncQueueStore = intMapStoreFactory.store('sync_queue');

// Image cache metadata
final imageCacheStore = stringMapStoreFactory.store('image_cache');

// User preferences
final preferencesStore = stringMapStoreFactory.store('preferences');
```

### 2.4 Network Monitoring (Week 3)

#### 2.4.1 Connectivity Service
**New File:** `lib/app/services/network/connectivity_service.dart`

**Features:**
- Listen to connectivity changes
- Detect online/offline state
- Quality detection (WiFi/Cellular/None)
- Notify sync orchestrator on state change

#### 2.4.2 Sync Status Provider
**New File:** `lib/presentation/common/providers/sync_status_provider.dart`

**State:**
- `isSyncing: bool`
- `pendingOperations: int`
- `lastSyncTimestamp: DateTime?`
- `syncError: String?`
- `isOnline: bool`

### 2.5 UI/UX Updates (Week 4)

#### 2.5.1 Sync Status Indicator
**New Widget:** `lib/presentation/common/widgets/sync_status_indicator.dart`

**States:**
- Synced ✓ (green)
- Syncing... (blue animated)
- Offline (gray with cloud-off icon)
- Error (red with retry button)

#### 2.5.2 Manual Sync Button
**Location:** App bar / Settings screen

**Features:**
- "Sync Now" for power users
- Shows last sync time
- Displays pending operations count

#### 2.5.3 App Lifecycle Handler
**File:** `lib/app/lifecycle/app_lifecycle_handler.dart`

**Hooks:**
- `onPaused()`: Trigger immediate save + sync
- `onResumed()`: Check for updates, pull changes
- `onDetached()`: Final save attempt
- `onInactive()`: Pause background operations

### Success Metrics
- 100% offline functionality
- Local operations: <50ms response time
- Background sync: Zero user interruption
- Data integrity: Zero loss guarantee

---

## Phase 3: Production Rollout (Weeks 5-6)
**Goal:** Safe deployment with monitoring and gradual rollout

### 3.1 Feature Flags (Week 5)

#### 3.1.1 Remote Config Setup
**File:** `lib/app/config/feature_flags/feature_flags_service.dart`

**Flags:**
```dart
// Phase 1 flags
bool enableDebouncedSave = true;
int autoSaveIntervalSeconds = 30;
bool enableEventDrivenSave = true;
bool enableHistoryOptimization = true;

// Phase 2 flags
bool enableLocalFirstMode = false; // Gradual rollout
bool enableImageOptimization = false;
bool enableBackgroundSync = false;
int syncRetryMaxAttempts = 3;
int syncBatchSize = 5;

// Rollback flag
bool useOfflineFirstArchitecture = false; // Master switch
```

#### 3.1.2 Migration Strategy
**New File:** `lib/data/migration/data_migration_service.dart`

**Features:**
- Detect first-time users vs existing users
- Migrate existing Firebase data to local DB
- Migrate base64 images to Firebase Storage
- Progress tracking
- Rollback capability

### 3.2 Monitoring & Analytics (Week 5)

#### 3.2.1 Custom Events
**Firebase Analytics Events:**
- `save_operation_completed` (local vs cloud)
- `sync_queue_processed` (success/failure)
- `offline_mode_detected`
- `sync_conflict_resolved`
- `image_upload_completed`
- `data_migration_completed`

#### 3.2.2 Performance Monitoring
**Custom Traces:**
- `local_save_duration`
- `cloud_sync_duration`
- `image_upload_duration`
- `sembast_read_duration`
- `sembast_write_duration`

#### 3.2.3 Error Tracking
**Crashlytics Custom Logs:**
- Sync queue failures with retry count
- Image upload errors with file size
- Database write errors with payload size
- Network timeout events

### 3.3 Testing Strategy (Week 5)

#### 3.3.1 Unit Tests
**Coverage:** >80% for new code
- `sync_queue_manager_test.dart`
- `sync_orchestrator_test.dart`
- `image_storage_service_test.dart`
- `animation_local_datasource_test.dart`

#### 3.3.2 Integration Tests
**Scenarios:**
- Save offline → Go online → Auto-sync
- Conflict resolution (two devices editing same animation)
- Network interruption during sync
- App killed during save operation

#### 3.3.3 E2E Tests
**User Flows:**
- Create animation offline → Sync when online
- Edit animation across multiple devices
- Large animation with 20+ players
- Rapid edits stress test

### 3.4 Gradual Rollout (Week 6)

#### 3.4.1 Rollout Schedule
**Day 1-2:** Internal testing (dev team)
- 5 users, `useOfflineFirstArchitecture = true`
- Monitor for critical bugs

**Day 3-4:** Beta users (5%)
- ~250 users if 5,000 total
- Monitor sync success rate, error rate

**Day 5-6:** Early adopters (10%)
- 500 users
- Analyze performance metrics

**Day 7-9:** Broader rollout (25%)
- 1,250 users
- Check database cost reduction

**Day 10-12:** Majority rollout (50%)
- 2,500 users
- Validate scalability

**Day 13-14:** Full rollout (100%)
- All users
- Celebrate success 🎉

#### 3.4.2 Rollback Plan
**Triggers:**
- Error rate >5%
- Sync failure rate >10%
- User complaints >20
- Critical data loss detected

**Action:**
1. Set `useOfflineFirstArchitecture = false` in Remote Config
2. All users revert to Phase 1 (debounced saves)
3. Investigate issues
4. Fix and retry rollout

### 3.5 Documentation (Week 6)

#### 3.5.1 Developer Docs
**Files:**
- `docs/OFFLINE_ARCHITECTURE.md`
- `docs/SYNC_QUEUE_DESIGN.md`
- `docs/IMAGE_OPTIMIZATION.md`
- `docs/TROUBLESHOOTING.md`

#### 3.5.2 User Guide
**Help Center Articles:**
- "How offline mode works"
- "Understanding sync status"
- "What happens if I edit offline?"
- "Resolving sync conflicts"

### Success Metrics
- Zero breaking changes for users
- <1% error rate in production
- 92% database cost reduction achieved
- 100% offline functionality working
- Positive user feedback

---

## Technical Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer (Flutter)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Tactic Board │  │ Sync Status  │  │ Settings     │     │
│  │ (Flame)      │  │ Indicator    │  │ Screen       │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Presentation Layer (Riverpod)              │
│  ┌──────────────────────┐  ┌─────────────────────────┐     │
│  │ AnimationProvider     │  │ SyncStatusProvider      │     │
│  └──────────────────────┘  └─────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  ┌────────────────────────────────────────────┐             │
│  │ SaveAnimationCollectionUseCase             │             │
│  │ GetAnimationCollectionUseCase              │             │
│  └────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer (Repository)                   │
│  ┌────────────────────────────────────────────┐             │
│  │ AnimationRepositoryImpl                    │             │
│  │  - Save local first (always succeeds)      │             │
│  │  - Queue cloud sync (background)           │             │
│  │  - Handle conflicts                        │             │
│  └────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
            ▼                                    ▼
┌─────────────────────────┐       ┌─────────────────────────┐
│   Local Datasource      │       │   Remote Datasource     │
│   (Sembast)             │       │   (Firebase)            │
│                         │       │                         │
│  - Instant writes       │       │  - Background sync      │
│  - IndexedDB (web)      │       │  - Retry logic          │
│  - File system (mobile) │       │  - Conflict detection   │
└─────────────────────────┘       └─────────────────────────┘
            ▼                                    ▼
┌─────────────────────────┐       ┌─────────────────────────┐
│   Device Storage        │       │   Firebase Cloud        │
│   (FREE)                │       │   (Optimized Cost)      │
└─────────────────────────┘       └─────────────────────────┘
                                              │
                                              ▼
                                  ┌─────────────────────────┐
                                  │ Sync Queue Manager      │
                                  │  - Priority queue       │
                                  │  - Batch operations     │
                                  │  - Retry backoff        │
                                  └─────────────────────────┘
                                              │
                                              ▼
                                  ┌─────────────────────────┐
                                  │ Sync Orchestrator       │
                                  │  - Network monitor      │
                                  │  - Lifecycle handler    │
                                  │  - Background worker    │
                                  └─────────────────────────┘
```

---

## Data Flow

### Save Operation (Offline-First)
```
User Edits Tactic Board
         ↓
Debounced Auto-Save (30s) OR Event-Driven Save
         ↓
AnimationProvider.save()
         ↓
AnimationRepository.saveAnimationCollection()
         ↓
┌────────────────────────────────────────┐
│ 1. Save to Sembast (local)             │ ← ALWAYS SUCCEEDS (instant)
│    - Write to IndexedDB/File system    │
│    - Mark as pending sync              │
│    - Return success to user            │
└────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────┐
│ 2. Queue for cloud sync (background)   │ ← NON-BLOCKING
│    - Add to sync_queue store           │
│    - Set priority & retry count        │
│    - Continue user experience          │
└────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────┐
│ 3. Sync Orchestrator processes queue   │ ← WHEN NETWORK AVAILABLE
│    - Check connectivity                │
│    - Batch operations if possible      │
│    - Upload to Firestore               │
│    - Update sync status                │
│    - Mark as synced                    │
│    - Remove from queue                 │
└────────────────────────────────────────┘
         ↓
User sees: ✓ Synced
```

### Load Operation (Cache-First)
```
User Opens Animation
         ↓
AnimationRepository.getAnimationCollection()
         ↓
┌────────────────────────────────────────┐
│ 1. Try Sembast (local cache)           │ ← INSTANT (if exists)
│    - Read from IndexedDB/File system   │
│    - Return immediately                │
└────────────────────────────────────────┘
         ↓ (if not found locally)
┌────────────────────────────────────────┐
│ 2. Fetch from Firestore                │ ← FALLBACK
│    - Download from cloud               │
│    - Save to Sembast for next time     │
│    - Return to user                    │
└────────────────────────────────────────┘
         ↓
┌────────────────────────────────────────┐
│ 3. Background check for updates        │ ← NON-BLOCKING
│    - Compare local vs cloud timestamp  │
│    - Download changes if newer         │
│    - Update local cache                │
│    - Notify user if major changes      │
└────────────────────────────────────────┘
```

---

## Risk Mitigation

### Risk 1: Data Loss During Migration
**Mitigation:**
- Dual-write for 2 weeks (local + cloud simultaneously)
- Keep Firebase as source of truth during transition
- Background verification job compares local vs cloud
- Automatic rollback if inconsistencies detected

### Risk 2: Sync Conflicts
**Mitigation:**
- Timestamp-based conflict detection
- Last-write-wins for simple cases
- User prompt for complex conflicts
- Conflict history log for debugging

### Risk 3: Local Storage Exhaustion
**Mitigation:**
- Monitor Sembast database size
- Implement LRU cache eviction (keep 50 most recent)
- Alert user if storage >80% full
- Offer "Clear Cache" option in settings

### Risk 4: Network Unreliable During Sync
**Mitigation:**
- Exponential backoff retry (1s, 2s, 4s, 8s, 16s)
- Mark failed syncs for manual retry
- Don't retry if >24 hours old (mark as stale)
- User notification after 3 failures

### Risk 5: iOS/Android Background Limitations
**Mitigation:**
- iOS: Use Background App Refresh (15-min intervals)
- Android: Use WorkManager for guaranteed execution
- Prioritize pending operations on app resume
- Fallback to foreground sync if background fails

---

## Dependencies Required

### New Packages
```yaml
dependencies:
  # Already have: sembast, connectivity_plus
  
  # Add for Phase 2:
  image_compression: ^1.0.0  # Compress images before upload
  path_provider: ^2.1.0      # Local file paths
  workmanager: ^0.5.0        # Background tasks (Android)
  
  # Add for Phase 3:
  firebase_remote_config: ^4.0.0  # Feature flags
  package_info_plus: ^5.0.0       # App version info
```

---

## Timeline Summary

| Phase | Duration | Team | Deliverables |
|-------|----------|------|--------------|
| Phase 1: Quick Wins | 1 week | 1 dev | Debounced saves, event-driven saves |
| Phase 2: Core Architecture | 3 weeks | 2 devs | Local-first, sync queue, image optimization |
| Phase 3: Production Rollout | 2 weeks | Full team | Testing, monitoring, gradual rollout |
| **Total** | **6 weeks** | **2-3 devs** | **Complete offline-first system** |

---

## Success Criteria

### Technical Metrics
- ✅ Firebase writes reduced by 99.4%
- ✅ Document sizes reduced by 99.9%
- ✅ Local operations <50ms response time
- ✅ Sync success rate >95%
- ✅ Error rate <1%
- ✅ Code test coverage >80%

### Business Metrics
- ✅ Database costs: $44.30 → $3.40/month (92% reduction)
- ✅ Offline functionality: 100% working
- ✅ User satisfaction: No complaints about performance
- ✅ Boss requirement: ✓ "Works without Internet"

### User Experience
- ✅ No loading spinners during edits
- ✅ Instant save feedback
- ✅ Clear sync status indication
- ✅ Zero data loss incidents
- ✅ Seamless offline→online transition

---

**Last Updated:** November 18, 2025  
**Status:** Ready for Implementation  
**Next Step:** Begin Phase 1 - Quick Wins
