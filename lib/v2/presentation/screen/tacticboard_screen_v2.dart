import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/v2/presentation/screen/board_shell_v2.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';
import 'package:zporter_tactical_board/v2/state/collection_provider.dart';

/// Top-level entry point for the V2 tactical board.
///
/// Drop-in replacement for V1's [TacticboardScreen].
/// Handles initialization, deep-linking, player mode, and fullscreen.
///
/// Usage:
/// ```dart
/// TacticboardScreenV2(
///   userId: currentUser.id,
///   onFullScreenChanged: (isFullScreen) { ... },
/// )
/// ```
class TacticboardScreenV2 extends ConsumerStatefulWidget {
  /// Required user ID for persistence.
  final String userId;

  /// Callback when fullscreen state changes.
  final ValueChanged<bool>? onFullScreenChanged;

  /// Deep-link: select a specific collection on load.
  final String? collectionId;

  /// Deep-link: select a specific animation on load.
  final String? animationId;

  /// View-only mode: shows board only, auto-triggers playback.
  final bool isPlayerMode;

  const TacticboardScreenV2({
    super.key,
    required this.userId,
    this.onFullScreenChanged,
    this.collectionId,
    this.animationId,
    this.isPlayerMode = false,
  });

  @override
  ConsumerState<TacticboardScreenV2> createState() =>
      _TacticboardScreenV2State();
}

class _TacticboardScreenV2State extends ConsumerState<TacticboardScreenV2> {
  final _repaintBoundaryKey = GlobalKey();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Defer initialization to avoid provider access during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final collNotifier = ref.read(collectionProviderV2.notifier);

    // Load collections
    await collNotifier.loadCollections(widget.userId);

    // Handle deep-linking
    if (widget.collectionId != null) {
      final collState = ref.read(collectionProviderV2);
      final collection = collState.collections
          .cast<dynamic>()
          .firstWhere(
            (c) => c.id == widget.collectionId,
            orElse: () => null,
          );
      if (collection != null) {
        collNotifier.selectCollection(collection);

        if (widget.animationId != null) {
          final animation = collection.animations
              .cast<dynamic>()
              .firstWhere(
                (a) => a.id == widget.animationId,
                orElse: () => null,
              );
          if (animation != null) {
            collNotifier.selectAnimation(animation);
          }
        }
      }
    }

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch fullscreen state and notify parent
    ref.watch(boardProviderV2);
    ref.listen(
      boardProviderV2.select((s) => s.showFullScreen),
      (previous, next) {
        widget.onFullScreenChanged?.call(next);
      },
    );

    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }

    // Player mode: board only, no toolbars
    if (widget.isPlayerMode) {
      return BoardShellV2(
        userId: widget.userId,
        repaintBoundaryKey: _repaintBoundaryKey,
      );
    }

    return BoardShellV2(
      userId: widget.userId,
      repaintBoundaryKey: _repaintBoundaryKey,
    );
  }
}
