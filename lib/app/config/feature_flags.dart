/// Feature flags for offline-first optimization
/// These flags control the rollout of Phase 1, 2, and 3 improvements
class FeatureFlags {
  // ============================================================
  // PHASE 1: QUICK WINS - Auto-save Optimization
  // ============================================================

  /// Enable debounced auto-save (30s instead of 1s)
  /// Safe to enable immediately - 97% cost reduction
  static const bool enableDebouncedAutoSave = true;

  /// Auto-save interval in seconds
  /// Default: 30.0 (optimized)
  /// Fallback: 1.0 (current behavior)
  static const double autoSaveIntervalSeconds =
      enableDebouncedAutoSave ? 30.0 : 1.0;

  /// Enable event-driven saves (immediate save on critical actions)
  /// Ensures important changes are saved instantly
  static const bool enableEventDrivenSave = true;

  /// Skip history on auto-save to reduce write operations
  /// History still saved on manual actions
  static const bool enableHistoryOptimization = true;

  // ============================================================
  // PHASE 2: CORE ARCHITECTURE (Week 1 Implementation)
  // ============================================================

  /// Enable local-first mode with Sembast
  /// Week 1: Local datasource + sync queue infrastructure
  /// Set to true to enable dual-write (local + sync queue)
  static const bool enableLocalFirstMode = true; // Will enable after testing

  /// Enable sync queue manager for background sync
  /// Handles retry logic, exponential backoff, and priority queue
  static const bool enableSyncQueue = true; // Will enable after testing

  /// Enable network monitoring and sync orchestration
  /// Automatically syncs when online, pauses when offline
  static const bool enableSyncOrchestrator = true; // Will enable after testing

  /// Enable image optimization (Firebase Storage instead of base64)
  /// Week 2: Will reduce document size from 4MB to 2.5KB
  /// IMPORTANT: Requires migration of existing base64 images
  static const bool enableImageOptimization = true; // Set true after testing

  /// Enable automatic image upload on save
  /// When true, base64 images are automatically uploaded to Firebase Storage
  static const bool enableAutoImageUpload = true; // Week 2 feature

  /// Enable image caching for offline access
  /// When true, downloaded images are cached locally
  static const bool enableImageCaching = true; // Week 2 feature

  /// Enable background sync workers (iOS/Android platform-specific)
  /// Week 3: Ensures sync even when app is closed
  static const bool enableBackgroundSync = true; // Week 3 feature

  // ============================================================
  // PHASE 2 CONFIGURATION
  // ============================================================

  /// Sync queue configuration
  static const int maxSyncQueueSize = 50;
  static const int maxSyncRetries = 3;

  /// Periodic sync interval (seconds)
  /// How often to check for pending sync operations
  /// Changed from 5 minutes to 30 seconds for faster user feedback
  static const int periodicSyncIntervalSeconds = 30;

  /// Debounce delay for connectivity changes (seconds)
  /// Prevents rapid sync triggers during network fluctuations
  static const int connectivityDebounceSeconds = 2;

  /// Image cache configuration
  static const int maxImageCacheSizeMB = 50;
  static const int maxImageCacheAgeDays = 7;

  // ============================================================
  // MASTER SWITCH - Emergency Rollback
  // ============================================================

  /// Master switch for all offline-first features
  /// Set to false to instantly rollback to original behavior
  static const bool useOfflineFirstArchitecture = true;

  // ============================================================
  // DEBUGGING & MONITORING
  // ============================================================

  /// Enable verbose logging for save operations
  static const bool enableSaveDebugLogs = true;

  /// Track save operation metrics (timing, size, success rate)
  static const bool enableSaveMetrics = true;
}
