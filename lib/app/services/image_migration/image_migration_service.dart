import 'dart:convert';
import 'dart:typed_data';

import 'package:sembast/sembast.dart';
import 'package:zporter_tactical_board/app/config/database/local/semDB.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/services/connectivity_service.dart';
import 'package:zporter_tactical_board/app/services/firebase_storage_service.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';

/// Service for migrating player images from base64 to Firebase Storage
/// Implements lazy migration: triggers when base64 images are loaded
class ImageMigrationService {
  static final ImageMigrationService _instance =
      ImageMigrationService._internal();
  factory ImageMigrationService() => _instance;
  ImageMigrationService._internal();

  final _storageService = FirebaseStorageService();

  // Sembast store for migration queue
  static final _queueStore = stringMapStoreFactory.store('migration_queue');

  bool _isProcessing = false;
  final Set<String> _inProgress = {}; // Track players currently being migrated

  /// Queue a player for background migration
  /// Called when a player with base64 image is loaded
  Future<void> queueForMigration(PlayerModel player) async {
    // Skip if already has imagePath or already queued
    if (player.imagePath?.isNotEmpty ?? false) return;
    if (player.imageBase64?.isEmpty ?? true) return;
    if (_inProgress.contains(player.id)) return;

    try {
      final db = await SemDB.database;

      // Check if already in queue
      final existing = await _queueStore.record(player.id).get(db);
      if (existing != null) return;

      // Add to queue
      await _queueStore.record(player.id).put(db, {
        'playerId': player.id,
        'userId': player.id.split('_')[0], // Extract userId from playerId
        'queuedAt': DateTime.now().toIso8601String(),
        'retryCount': 0,
        'priority': _calculatePriority(player),
      });

      zlog(data: '[ImageMigration] Queued player ${player.id} for migration');

      // Trigger processing if not already running
      _processQueue();
    } catch (e, stack) {
      zlog(data: '[ImageMigration] Failed to queue player: $e\n$stack');
    }
  }

  /// Calculate migration priority (1-10, higher = more urgent)
  int _calculatePriority(PlayerModel player) {
    // For now, all have same priority
    // Future: Could prioritize recently used players
    return 5;
  }

  /// Process the migration queue in background
  Future<void> _processQueue() async {
    // Don't start if already processing
    if (_isProcessing) return;

    // Only process if online
    if (!ConnectivityService.statusNotifier.value.isOnline) {
      zlog(data: '[ImageMigration] Offline, skipping queue processing');
      return;
    }

    _isProcessing = true;

    try {
      final db = await SemDB.database;

      // Get next batch to process (limit 5 at a time)
      final finder = Finder(
        sortOrders: [SortOrder('priority', false), SortOrder('queuedAt')],
        limit: 5,
      );

      final records = await _queueStore.find(db, finder: finder);

      if (records.isEmpty) {
        _isProcessing = false;
        return;
      }

      zlog(data: '[ImageMigration] Processing ${records.length} players');

      // Process each record
      for (final record in records) {
        final playerId = record.key;

        // Skip if already in progress
        if (_inProgress.contains(playerId)) continue;

        _inProgress.add(playerId);

        try {
          await _migratePlayer(playerId);

          // Remove from queue on success
          await _queueStore.record(playerId).delete(db);

          zlog(data: '[ImageMigration] Successfully migrated $playerId');
        } catch (e) {
          zlog(data: '[ImageMigration] Failed to migrate $playerId: $e');

          // Increment retry count
          final data = record.value;
          final retryCount = (data['retryCount'] as int? ?? 0) + 1;

          if (retryCount >= 3) {
            // Max retries reached, remove from queue
            await _queueStore.record(playerId).delete(db);
            zlog(data: '[ImageMigration] Max retries reached for $playerId');
          } else {
            // Update retry count
            await _queueStore.record(playerId).update(db, {
              'retryCount': retryCount,
              'lastError': e.toString(),
            });
          }
        } finally {
          _inProgress.remove(playerId);
        }
      }
    } catch (e, stack) {
      zlog(data: '[ImageMigration] Queue processing error: $e\n$stack');
    } finally {
      _isProcessing = false;
    }
  }

  /// Migrate a single player's image from base64 to Firebase Storage
  Future<void> _migratePlayer(String playerId) async {
    // Get player from database
    final player = await PlayerUtilsV2.getPlayerFromDbById(playerId);
    if (player == null) {
      throw Exception('Player not found: $playerId');
    }

    // Skip if already has imagePath
    if (player.imagePath?.isNotEmpty ?? false) {
      zlog(data: '[ImageMigration] Player $playerId already has imagePath');
      return;
    }

    // Skip if no base64
    if (player.imageBase64?.isEmpty ?? true) {
      throw Exception('No base64 image found for player $playerId');
    }

    try {
      // Decode base64 to bytes
      final Uint8List imageBytes = base64Decode(player.imageBase64!);

      // Upload to Firebase Storage
      final String downloadUrl =
          await _storageService.uploadPlayerImageFromBytes(
        imageBytes: imageBytes,
        playerId: playerId,
      );

      // Update player model with new imagePath and CLEAR base64
      // Base64 is cleared because:
      // 1. URL is now the source of truth
      // 2. Prevents large payloads if this player syncs to Firestore
      // 3. Saves local storage space
      final updatedPlayer = player.copyWith(
        imagePath: downloadUrl,
        imageBase64: null, // Clear base64 after successful upload
      );

      // Save updated player to database
      await PlayerUtilsV2.updatePlayerInDb(updatedPlayer);

      zlog(
          data:
              '[ImageMigration] Migrated $playerId to $downloadUrl (base64 cleared)');
    } catch (e, stack) {
      zlog(data: '[ImageMigration] Upload failed for $playerId: $e\n$stack');
      rethrow;
    }
  }

  /// Get current queue size (for debugging/monitoring)
  Future<int> getQueueSize() async {
    try {
      final db = await SemDB.database;
      return await _queueStore.count(db);
    } catch (e) {
      return 0;
    }
  }

  /// Clear the migration queue (for testing/debugging)
  Future<void> clearQueue() async {
    try {
      final db = await SemDB.database;
      await _queueStore.delete(db);
      zlog(data: '[ImageMigration] Queue cleared');
    } catch (e, stack) {
      zlog(data: '[ImageMigration] Failed to clear queue: $e\n$stack');
    }
  }
}
