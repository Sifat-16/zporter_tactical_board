# Phase 2 Week 2 - Data Model Migration Guide

**Date:** November 19, 2025  
**Status:** ✅ COMPLETE  
**Branch:** feature/offline-sync-optimization

---

## Overview

This guide documents the data model changes required for Phase 2 Week 2 image optimization. The changes add support for Firebase Storage URLs while maintaining backward compatibility with existing base64 images.

---

## Data Model Changes

### PlayerModel Updates

**New Fields Added:**
```dart
String? imageUrl; // Firebase Storage URL (Phase 2 Week 2)
```

**Helper Methods Added:**
```dart
bool get hasBase64Image => imageBase64 != null && imageBase64!.isNotEmpty;
bool get hasImageUrl => imageUrl != null && imageUrl!.isNotEmpty;
bool get needsImageMigration => hasBase64Image && !hasImageUrl;
```

**JSON Serialization:**
- `toJson()` - Now includes `imageUrl` field
- `fromJson()` - Parses `imageUrl` field (defaults to `null` for old documents)
- `copyWith()` - Supports updating `imageUrl`

**Backward Compatibility:**
- Old documents without `imageUrl` will have `imageUrl = null`
- `imageBase64` field is preserved for backward compatibility
- Documents can have both `imageBase64` and `imageUrl` during migration

### EquipmentModel Updates

**New Fields Added:**
```dart
String? imageUrl; // Firebase Storage URL (Phase 2 Week 2)
```

**Helper Methods Added:**
```dart
bool get hasImagePath => imagePath != null && imagePath!.isNotEmpty;
bool get hasImageUrl => imageUrl != null && imageUrl!.isNotEmpty;
bool get needsImageMigration => hasImagePath && !hasImageUrl;
```

**JSON Serialization:**
- `toJson()` - Now includes `imageUrl` field
- `fromJson()` - Parses `imageUrl` field (defaults to `null` for old documents)
- `copyWith()` - Supports updating `imageUrl`

**Backward Compatibility:**
- Old documents without `imageUrl` will have `imageUrl = null`
- `imagePath` field is preserved (used for local assets)
- Documents can have both `imagePath` and `imageUrl`

---

## Migration Strategy

### Phase 1: Lazy Migration (Recommended)

**Implementation:** Automatic migration on save

**Workflow:**
1. User opens existing tactic board
2. System detects players/equipment with `needsImageMigration == true`
3. On save, for each item needing migration:
   - Extract image data from `imageBase64`/`imagePath`
   - Upload to Firebase Storage
   - Set `imageUrl` to returned download URL
   - Keep original `imageBase64`/`imagePath` (optional cleanup later)
4. Save updated document to Firestore

**Code Example:**
```dart
Future<PlayerModel> migratePlayerImage(PlayerModel player) async {
  if (!player.needsImageMigration) {
    return player;
  }

  try {
    // Convert base64 to bytes
    final bytes = ImageConversionService.base64ToBytes(player.imageBase64);
    if (bytes == null) {
      return player;
    }

    // Upload to Firebase Storage
    final imageUrl = await _imageStorageService.uploadPlayerImage(
      userId: userId,
      playerId: player.id,
      imageData: bytes,
    );

    // Update model with new URL
    return player.copyWith(imageUrl: imageUrl);
  } catch (e) {
    zlog(level: Level.error, data: 'Failed to migrate player image: $e');
    return player; // Keep original on error
  }
}
```

**Pros:**
- ✅ No upfront migration work
- ✅ Only migrates active documents
- ✅ User-transparent
- ✅ Gradual rollout
- ✅ Error recovery built-in

**Cons:**
- ⚠️ Takes multiple saves to migrate all documents
- ⚠️ Old documents stay in base64 until edited

### Phase 2: Background Migration (Future Enhancement)

**Implementation:** One-time batch migration job

**Workflow:**
1. Query all user collections from Firestore
2. For each document:
   - Check each player/equipment for `needsImageMigration`
   - Upload images to Firebase Storage
   - Update document with new URLs
   - Track progress
3. Report completion statistics

**Code Example:**
```dart
Future<void> migrateAllUserImages(String userId) async {
  final collections = await _repository.getAnimationCollections(userId);
  
  int totalImages = 0;
  int migratedImages = 0;
  int failedImages = 0;

  for (final collection in collections) {
    for (final player in collection.allPlayers) {
      if (player.needsImageMigration) {
        totalImages++;
        try {
          final migrated = await migratePlayerImage(player);
          if (migrated.hasImageUrl) {
            migratedImages++;
          }
        } catch (e) {
          failedImages++;
        }
      }
    }
    
    // Update collection in Firestore
    await _repository.saveAnimationCollection(collection);
  }

  zlog(
    level: Level.info,
    data: 'Migration complete: $migratedImages/$totalImages migrated, $failedImages failed',
  );
}
```

**Pros:**
- ✅ Complete migration
- ✅ All users benefit immediately
- ✅ Can be monitored
- ✅ Predictable timeline

**Cons:**
- ⚠️ Requires background job infrastructure
- ⚠️ Higher initial Firebase Storage costs
- ⚠️ Risk of race conditions with active editing
- ⚠️ Needs progress tracking UI

---

## Image Loading Strategy

### Priority Order

When displaying an image, check in this order:

1. **Cache** - Check local cache first (offline support)
2. **Firebase Storage URL** - Download from `imageUrl` if available
3. **Base64** - Fallback to `imageBase64` for old documents
4. **Placeholder** - Show default image if none available

### Code Example

```dart
Future<Uint8List?> getPlayerImage(PlayerModel player) async {
  // 1. Try cache first (fastest)
  if (player.hasImageUrl) {
    final cached = await _imageCacheManager.getCachedImage(player.imageUrl!);
    if (cached != null) {
      return cached;
    }
  }

  // 2. Download from Firebase Storage
  if (player.hasImageUrl) {
    try {
      final bytes = await _imageStorageService.downloadImage(player.imageUrl!);
      if (bytes != null) {
        // Cache for next time
        await _imageCacheManager.cacheImage(player.imageUrl!, bytes);
        return bytes;
      }
    } catch (e) {
      zlog(level: Level.warning, data: 'Failed to download image, trying base64');
    }
  }

  // 3. Fallback to base64 (old documents)
  if (player.hasBase64Image) {
    return ImageConversionService.base64ToBytes(player.imageBase64);
  }

  // 4. No image available
  return null;
}
```

---

## Testing Migration

### Unit Tests

**Test Cases:**
- ✅ Model has imageUrl field
- ✅ Helper methods detect migration needs
- ✅ JSON serialization includes imageUrl
- ✅ JSON deserialization handles missing imageUrl
- ✅ copyWith updates imageUrl correctly
- ✅ Backward compatibility with old documents

**Run Tests:**
```bash
flutter test test/data/tactic/model/image_migration_test.dart
```

### Integration Tests

**Scenarios to Test:**

1. **New Document Creation**
   - Create new player with image
   - Verify imageUrl is set immediately
   - Verify no base64 data stored

2. **Old Document Loading**
   - Load document with only base64
   - Verify image displays correctly
   - Verify needsImageMigration = true

3. **Migration on Save**
   - Load old document
   - Edit and save
   - Verify imageUrl is now set
   - Verify image still displays

4. **Offline Behavior**
   - Load document with imageUrl
   - Turn off network
   - Verify cached image loads
   - Verify graceful degradation

---

## Rollout Plan

### Week 2 Days 2-4

**Day 2: Repository Integration**
- Implement migration logic in repository save method
- Add error handling and logging
- Test with sample documents

**Day 3: Image Loading**
- Implement cache-first loading strategy
- Add download and caching logic
- Handle offline scenarios

**Day 4: Testing & Monitoring**
- Run integration tests
- Monitor Firebase Storage usage
- Monitor document size reduction
- Collect performance metrics

### Week 2 Day 5: Gradual Rollout

**Step 1: Internal Testing (10% of users)**
```dart
static const bool enableImageOptimization = true;  // Test group only
```

**Step 2: Beta Testing (50% of users)**
```dart
static const bool enableImageOptimization = true;  // Wider rollout
```

**Step 3: Full Rollout (100% of users)**
```dart
static const bool enableImageOptimization = true;  // All users
```

---

## Monitoring

### Metrics to Track

1. **Migration Progress**
   - Number of images migrated
   - Migration success rate
   - Average migration time

2. **Document Size Reduction**
   - Average document size before/after
   - Total storage savings
   - Cost impact

3. **Performance Impact**
   - Document load time before/after
   - Cache hit rate
   - Network usage

4. **Error Rates**
   - Upload failures
   - Download failures
   - Cache failures

### Logging

```dart
// Log migration start
zlog(level: Level.info, data: 'Starting image migration for player ${player.id}');

// Log migration success
zlog(level: Level.info, data: 'Migrated player image: ${player.id} -> $imageUrl');

// Log migration failure
zlog(level: Level.error, data: 'Failed to migrate player ${player.id}: $error');

// Log performance metrics
zlog(level: Level.info, data: 'Document size reduced: $oldSize -> $newSize (${percentSaved}% saved)');
```

---

## Cleanup Strategy

### Phase 1: Keep Both (Weeks 2-4)
- Keep both `imageBase64` and `imageUrl`
- Allows rollback if issues found
- Provides backward compatibility

### Phase 2: Remove Base64 (Week 5+)
Once migration is stable:
- Remove `imageBase64` from migrated documents
- Keep field in model for old documents
- Update cleanup job to remove after verification

**Cleanup Code:**
```dart
Future<PlayerModel> cleanupMigratedImage(PlayerModel player) async {
  if (player.hasImageUrl && player.hasBase64Image) {
    // Both exist, remove base64
    return player.copyWith(imageBase64: Object()); // Use sentinel to clear
  }
  return player;
}
```

---

## Rollback Plan

If critical issues are found:

**Step 1: Disable Feature Flag**
```dart
static const bool enableImageOptimization = false;
```

**Step 2: Revert to Base64**
- System automatically falls back to `imageBase64`
- No data loss (both fields preserved)
- No migration needed

**Step 3: Fix Issues**
- Debug and fix problems
- Test thoroughly
- Re-enable feature flag

---

## Success Criteria

### Week 2 Complete When:
- ✅ All models support `imageUrl` field
- ✅ Migration logic implemented and tested
- ✅ Cache-first loading strategy working
- ✅ 100% unit test coverage for new code
- ✅ Integration tests passing
- ✅ Documentation complete

### Migration Success When:
- ✅ 99%+ of active documents migrated
- ✅ Document size reduced by 99%+
- ✅ No increase in error rates
- ✅ Performance improved (faster loads)
- ✅ User satisfaction maintained

---

**Next Steps:**
1. Implement repository migration logic
2. Implement image loading with cache
3. Run integration tests
4. Begin gradual rollout
