import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/config/feature_flags.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/app/services/sync/sync_queue_manager.dart';

/// Provider for sync queue status
/// Only active when useOfflineFirstArchitecture is enabled
final syncStatusProvider = StreamProvider<SyncQueueStatus>((ref) {
  if (!FeatureFlags.useOfflineFirstArchitecture) {
    // Return empty stream when feature is disabled
    return Stream.value(const SyncQueueStatus());
  }

  final syncQueueManager = sl<SyncQueueManager>();
  return syncQueueManager.statusStream;
});
