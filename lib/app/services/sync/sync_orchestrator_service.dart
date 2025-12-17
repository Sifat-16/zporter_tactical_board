import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/services/network/connectivity_service.dart';
import 'package:zporter_tactical_board/app/services/sync/sync_queue_manager.dart';

/// Orchestrates sync operations based on connectivity and app lifecycle
class SyncOrchestratorService {
  final SyncQueueManager _queueManager;
  final ConnectivityService _connectivityService;

  // Stream subscriptions
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _periodicSyncTimer;

  // State
  bool _isRunning = false;
  bool _isPaused = false;

  // Configuration
  static const Duration periodicSyncInterval = Duration(seconds: 30);
  static const Duration debounceDelay = Duration(seconds: 2);

  // Debounce timer for connectivity changes
  Timer? _connectivityDebounceTimer;

  SyncOrchestratorService({
    required SyncQueueManager queueManager,
    required ConnectivityService connectivityService,
  })  : _queueManager = queueManager,
        _connectivityService = connectivityService;

  /// Start the orchestrator
  void start() {
    if (_isRunning) {
      zlog(
        level: Level.warning,
        data: 'Sync orchestrator already running',
      );
      return;
    }

    _isRunning = true;
    _isPaused = false;

    // Listen to connectivity changes
    _connectivitySubscription =
        _connectivityService.connectivityStream.listen(_onConnectivityChanged);

    // Start periodic sync timer
    _startPeriodicSync();

    // Trigger initial sync if online
    _checkAndSync();

    zlog(
      level: Level.info,
      data: 'Sync orchestrator started',
    );
  }

  /// Pause the orchestrator
  void pause() {
    if (!_isRunning || _isPaused) {
      return;
    }

    _isPaused = true;
    _periodicSyncTimer?.cancel();
    _connectivityDebounceTimer?.cancel();

    zlog(
      level: Level.info,
      data: 'Sync orchestrator paused',
    );
  }

  /// Resume the orchestrator
  void resume() {
    if (!_isRunning || !_isPaused) {
      return;
    }

    _isPaused = false;
    _startPeriodicSync();
    _checkAndSync();

    zlog(
      level: Level.info,
      data: 'Sync orchestrator resumed',
    );
  }

  /// Stop the orchestrator
  void stop() {
    if (!_isRunning) {
      return;
    }

    _isRunning = false;
    _isPaused = false;
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _connectivityDebounceTimer?.cancel();

    zlog(
      level: Level.info,
      data: 'Sync orchestrator stopped',
    );
  }

  /// Trigger immediate sync
  Future<void> syncNow() async {
    if (_isPaused) {
      zlog(
        level: Level.warning,
        data: 'Sync orchestrator paused, cannot sync now',
      );
      return;
    }

    await _performSync();
  }

  /// Handle connectivity changes with debouncing
  void _onConnectivityChanged(ConnectivityResult result) {
    // Cancel previous debounce timer
    _connectivityDebounceTimer?.cancel();

    // Start new debounce timer
    _connectivityDebounceTimer = Timer(debounceDelay, () {
      if (result != ConnectivityResult.none) {
        zlog(
          level: Level.info,
          data: 'Network available (${result.name}), triggering sync',
        );
        _checkAndSync();
      } else {
        zlog(
          level: Level.info,
          data: 'Network unavailable, sync paused',
        );
      }
    });
  }

  /// Start periodic sync timer
  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(periodicSyncInterval, (timer) {
      if (!_isPaused) {
        zlog(
          level: Level.debug,
          data: 'Periodic sync triggered',
        );
        _checkAndSync();
      }
    });
  }

  /// Check connectivity and sync if online
  Future<void> _checkAndSync() async {
    if (_isPaused) return;

    final isOnline = await _connectivityService.isOnline;
    if (isOnline) {
      await _performSync();
    } else {
      zlog(
        level: Level.debug,
        data: 'Device offline, skipping sync',
      );
    }
  }

  /// Perform the actual sync operation
  Future<void> _performSync() async {
    try {
      // Check if there are pending operations
      final pendingCount = await _queueManager.getPendingCount();
      if (pendingCount == 0) {
        zlog(
          level: Level.debug,
          data: 'No pending sync operations',
        );
        return;
      }

      zlog(
        level: Level.info,
        data: 'Starting sync: $pendingCount operations pending',
      );

      // Process the queue
      await _queueManager.processQueue();

      zlog(
        level: Level.info,
        data: 'Sync completed successfully',
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Sync failed: $e\n$stackTrace',
      );
    }
  }

  /// Handle app going to background
  Future<void> onAppPaused() async {
    zlog(
      level: Level.info,
      data: 'App paused, triggering final sync',
    );

    // Trigger immediate sync before app goes to background
    await syncNow();

    // Pause orchestrator
    pause();
  }

  /// Handle app coming to foreground
  Future<void> onAppResumed() async {
    zlog(
      level: Level.info,
      data: 'App resumed, checking for sync',
    );

    // Resume orchestrator
    resume();

    // Trigger immediate sync to get latest updates
    await syncNow();
  }

  /// Dispose resources
  void dispose() {
    stop();
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _connectivityDebounceTimer?.cancel();
  }
}
