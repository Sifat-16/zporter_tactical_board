import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';

/// A draggable tile that wraps a [BoardElement] for drag-to-board.
///
/// Used in the Players and Equipment toolbar panels. The element is
/// carried as `Draggable<BoardElement>` so the board's `DragTarget`
/// receives a typed element to add.
class DraggableBoardTileV2 extends ConsumerWidget {
  /// The element to drag onto the board.
  final BoardElement element;

  /// Visual representation in the toolbar.
  final Widget child;

  /// Visual feedback during drag (shown under the finger).
  /// Defaults to a scaled-down version of [child].
  final Widget? feedback;

  /// Size of the feedback widget during drag.
  final double feedbackSize;

  const DraggableBoardTileV2({
    super.key,
    required this.element,
    required this.child,
    this.feedback,
    this.feedbackSize = 40,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Draggable<BoardElement>(
      data: element,
      rootOverlay: true,
      onDragStarted: () {
        ref.read(boardProviderV2.notifier).setDraggingToBoard(true);
      },
      onDragEnd: (_) {
        ref.read(boardProviderV2.notifier).setDraggingToBoard(false);
      },
      onDraggableCanceled: (_, __) {
        ref.read(boardProviderV2.notifier).setDraggingToBoard(false);
      },
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: feedbackSize,
          height: feedbackSize,
          child: feedback ?? child,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      child: child,
    );
  }
}
