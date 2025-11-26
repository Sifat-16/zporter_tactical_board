# Phase 2 Testing Guide

**Date:** November 19, 2025  
**Status:** Ready for Manual QA  
**Branch:** feature/offline-sync-optimization

---

## ✅ Unit Test Results

**All 36 tests passing (100%)**

### Test Coverage Summary

| Component | Tests | Status | Coverage |
|-----------|-------|--------|----------|
| SyncOperation Model | 30 | ✅ Pass | 100% |
| SyncQueueStatus Model | 4 | ✅ Pass | 100% |
| Enum Validation | 2 | ✅ Pass | 100% |
| **TOTAL** | **36** | **✅ Pass** | **100%** |

### Detailed Test Results

**SyncOperation (30 tests)**
- ✅ Model creation with defaults
- ✅ Model creation with custom values
- ✅ CopyWith immutability
- ✅ JSON serialization/deserialization
- ✅ Round-trip JSON conversion
- ✅ Retry logic (canRetry, isReadyToRetry)
- ✅ Exponential backoff (1s, 2s, 4s, 8s, 16s)
- ✅ Retry cap at 60 seconds
- ✅ Priority scoring algorithm
- ✅ Age-based priority increase
- ✅ Retry penalty on priority
- ✅ Equality comparison
- ✅ toString debug output

**SyncQueueStatus (4 tests)**
- ✅ Default values
- ✅ Custom values
- ✅ CopyWith updates
- ✅ toString format

**Enums (2 tests)**
- ✅ All SyncOperationType values present
- ✅ All SyncPriority values present
- ✅ All SyncOperationStatus values present
- ✅ NetworkQuality enum validation

---

## 🧪 Manual Testing Checklist

### Prerequisites

**1. Enable Phase 2 Features**

Edit `lib/app/config/feature_flags.dart`:
```dart
// Change these from false to true:
static const bool enableSyncQueue = true;
static const bool enableSyncOrchestrator = true;
```

**2. Clean Build**
```bash
flutter clean
flutter pub get
flutter run
```

---

### Test Scenario 1: Offline Editing ⭐️ CRITICAL

**Steps:**
1. Open tactic board editor
2. **Disconnect network** (airplane mode or disable WiFi)
3. Drag a player component to new position
4. Add a new equipment component
5. Draw a trajectory line
6. Check console logs

**Expected Results:**
- ✅ All actions complete instantly (<50ms)
- ✅ No errors in console
- ✅ Logs show: "Saved collection {id} to LOCAL successfully (Offline)"
- ✅ Logs show: "Sync operation enqueued for {id}"

**Check in Logs:**
```
[Repo] Network Offline: Saving Collection...
[Repo] Saved collection ... to LOCAL successfully (Offline)
[Repo] Phase 2: Enqueuing sync operation...
[Repo] Sync operation enqueued ... Will sync when online.
```

---

### Test Scenario 2: Automatic Sync on Reconnect ⭐️ CRITICAL

**Steps:**
1. Continue from Scenario 1 (device still offline)
2. Make 2-3 more edits while offline
3. **Reconnect network** (disable airplane mode)
4. Wait 2-3 seconds
5. Check console logs

**Expected Results:**
- ✅ Logs show: "Network available (wifi), triggering sync"
- ✅ Logs show: "Processing sync queue: X operations"
- ✅ Logs show: "Sync operation completed: {id}"
- ✅ Check Firestore → all changes should be there

**Check in Logs:**
```
[ConnectivityService] Connectivity changed: wifi
[Orchestrator] Network available (wifi), triggering sync
[SyncQueueManager] Processing sync queue: 3 operations
[SyncQueueManager] Sync operation completed: {id}
```

---

### Test Scenario 3: Sync Queue Priority

**Steps:**
1. Go offline
2. Make high-priority edit (drag player) 
3. Make low-priority edit (change color)
4. Make another high-priority edit (add component)
5. Reconnect network
6. Check console logs for processing order

**Expected Results:**
- ✅ High-priority operations process first
- ✅ Order in logs: high → high → low

**Check in Logs:**
```
Processing sync operation: {id-1} (priority: high)
Processing sync operation: {id-3} (priority: high)
Processing sync operation: {id-2} (priority: normal)
```

---

### Test Scenario 4: Retry Logic with Failure

**Steps:**
1. Go offline
2. Make an edit
3. Stay offline for 1 minute
4. Check logs for retry attempts

**Expected Results:**
- ✅ Logs show retry attempts
- ✅ Exponential backoff visible (1s, 2s, 4s, 8s)
- ✅ After 3 failures → permanently failed

**Check in Logs:**
```
[SyncQueueManager] Sync operation failed, will retry at {time} (attempt 1/3)
... wait 1 second ...
[SyncQueueManager] Sync operation failed, will retry at {time} (attempt 2/3)
... wait 2 seconds ...
[SyncQueueManager] Sync operation failed, will retry at {time} (attempt 3/3)
... wait 4 seconds ...
[SyncQueueManager] Sync operation permanently failed after 3 retries
```

---

### Test Scenario 5: Periodic Sync

**Steps:**
1. Make an edit while online (should save immediately)
2. Wait 5 minutes without touching the app
3. Make another edit
4. Check logs

**Expected Results:**
- ✅ Logs show: "Periodic sync triggered" every 5 minutes
- ✅ If no pending operations: "No pending sync operations"

**Check in Logs:**
```
[Orchestrator] Periodic sync triggered
[SyncQueueManager] No pending sync operations
```

---

### Test Scenario 6: App Lifecycle Integration

**Steps:**
1. Make an edit while offline
2. **Put app in background** (home button / app switcher)
3. Wait 3 seconds
4. **Bring app to foreground**
5. Check logs

**Expected Results:**
- ✅ On background: "App paused, triggering final sync"
- ✅ On foreground: "App resumed, checking for sync"
- ✅ If online: Sync completes automatically

**Check in Logs:**
```
[Orchestrator] App paused, triggering final sync
[Orchestrator] App resumed, checking for sync
[Orchestrator] Starting sync: X operations pending
```

---

### Test Scenario 7: Delete Operation Offline

**Steps:**
1. Go offline
2. Delete a tactic board collection
3. Check console logs
4. Reconnect network
5. Verify deletion synced to Firestore

**Expected Results:**
- ✅ Logs show: "Deleting collection ... from LOCAL and queueing for sync"
- ✅ Logs show: "Delete operation enqueued"
- ✅ On reconnect: Deletion syncs to Firestore
- ✅ Collection removed from Firestore

**Check in Logs:**
```
[Repo] Network Offline (Phase 2): Deleting collection ... and queueing...
[Repo] Deleted collection ... from LOCAL successfully
[Repo] Delete operation enqueued ... Will sync when online.
```

---

### Test Scenario 8: Rapid Network Switching

**Steps:**
1. Make an edit while online
2. Quickly toggle: Offline → Online → Offline → Online (5 seconds)
3. Check logs
4. Verify no duplicate syncs

**Expected Results:**
- ✅ Debouncing prevents rapid sync triggers
- ✅ Only 1 sync triggered after stabilization (2 second debounce)
- ✅ No duplicate saves

**Check in Logs:**
```
[ConnectivityService] Connectivity changed: none
[ConnectivityService] Connectivity changed: wifi
... debounce delay (2 seconds) ...
[Orchestrator] Network available (wifi), triggering sync
```

---

## 🐛 Known Issues to Watch For

### Issue 1: Delete Operation userId Empty
**Symptom:** Warning in logs about empty userId in delete sync operations  
**Impact:** Low - Sync will still work, just missing userId tracking  
**Fix:** Will be addressed in next iteration

### Issue 2: Queue Size Limit
**Symptom:** If >50 operations queued, oldest low-priority operations removed  
**Impact:** Low - Only in extreme offline scenarios  
**Monitoring:** Check logs for "Removed old low-priority operation"

---

## 📊 Performance Benchmarks

### Target Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Offline save latency | <50ms | Time between action and "Saved to LOCAL" log |
| Sync completion time | <2s per operation | Time from "Processing" to "Completed" log |
| Queue size (typical) | <10 operations | Check SyncQueueStatus in logs |
| Retry success rate | >95% | (completed / total) operations |
| Background sync | Works when app closed | Make edit, close app, reopen after 5 min |

---

## ✅ Acceptance Criteria

**Phase 2 Week 1 is ready for Week 2 when:**

- [x] All 36 unit tests passing
- [ ] All 8 manual test scenarios pass
- [ ] No crashes or errors during offline editing
- [ ] Sync queue successfully processes pending operations
- [ ] Automatic sync works on network restoration
- [ ] App lifecycle integration works (background/foreground)
- [ ] Logs show correct priority ordering
- [ ] Retry logic works with exponential backoff
- [ ] Performance meets target benchmarks

---

## 🚀 Next Steps After Testing

1. **If all tests pass:**
   - Document any findings
   - Update feature flags to enabled by default
   - Proceed to Week 2: Image optimization

2. **If issues found:**
   - Document issues in detail (steps to reproduce, logs, expected vs actual)
   - Fix critical issues first
   - Re-test affected scenarios
   - Then proceed to Week 2

---

## 📝 Test Results Log

**Tester:** _________________  
**Date:** _________________  
**Device:** _________________  
**OS Version:** _________________

| Scenario | Status | Notes |
|----------|--------|-------|
| 1. Offline Editing | ⬜ | |
| 2. Auto Sync on Reconnect | ⬜ | |
| 3. Queue Priority | ⬜ | |
| 4. Retry Logic | ⬜ | |
| 5. Periodic Sync | ⬜ | |
| 6. App Lifecycle | ⬜ | |
| 7. Delete Offline | ⬜ | |
| 8. Rapid Network Switching | ⬜ | |

**Overall Status:** ⬜ Pass / ⬜ Fail  
**Ready for Week 2:** ⬜ Yes / ⬜ No

**Additional Notes:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
