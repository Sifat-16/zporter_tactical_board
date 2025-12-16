import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/services/sync/sync_queue_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/sync/sync_status_provider.dart';

/// Simple toolbar sync indicator
/// Shows upload icon when pending/syncing, checkmark when synced
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(syncStatusProvider);

    return syncStatusAsync.when(
      data: (status) {
        return _buildIcon(status);
      },
      loading: () => const Icon(
        Icons.sync,
        size: 20,
        color: Colors.orange,
      ),
      error: (_, __) =>
          const Icon(Icons.error_outline, size: 20, color: Colors.red),
    );
  }

  Widget _buildIcon(SyncQueueStatus status) {
    // Show upload icon if syncing or pending
    if (status.isSyncing || status.pendingCount > 0 || status.failedCount > 0) {
      return const Icon(
        Icons.cloud_upload_outlined,
        size: 20,
        color: Colors.orange,
      );
    }

    // Show success checkmark when all synced
    return const Icon(
      Icons.check_circle,
      size: 20,
      color: Colors.green,
    );
  }
}
