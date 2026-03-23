import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/v2/core/coordinate_system.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/presentation/animated_board_widget.dart';
import 'package:zporter_tactical_board/v2/presentation/widgets/delete_drop_zone_v2.dart';
import 'package:zporter_tactical_board/v2/presentation/widgets/selection_handles_overlay.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';

/// Wraps [AnimatedTacticBoardV2] in a [DragTarget<BoardElement>] so
/// elements can be dragged from toolbar panels onto the board.
///
/// Also overlays:
/// - [SelectionHandlesOverlay] for interactive resize/rotation handles
/// - [DeleteDropZoneV2] for drag-to-delete (left edge)
/// - Drag-over feedback when dragging elements from panels
class BoardDropZoneV2 extends ConsumerWidget {
  /// Global key for the board's RepaintBoundary (for thumbnail capture).
  final GlobalKey? repaintBoundaryKey;

  const BoardDropZoneV2({
    super.key,
    this.repaintBoundaryKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Do NOT ref.watch(boardProviderV2) at this level — it would rebuild
    // the DragTarget on every state change, breaking drag tracking.

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = Size(constraints.maxWidth, constraints.maxHeight);

        return DragTarget<BoardElement>(
          onAcceptWithDetails: (details) {
            _onElementDropped(context, ref, details.data, details.offset,
                constraints);
          },
          builder: (context, candidateData, rejectedData) {
            return Stack(
              children: [
                // Board (always fills entire area)
                RepaintBoundary(
                  key: repaintBoundaryKey,
                  child: AnimatedTacticBoardV2(
                    onElementSelected: (element) {
                      ref
                          .read(boardProviderV2.notifier)
                          .selectElement(element?.id);
                    },
                    onElementMoved: (elementId, newOffset) {
                      ref
                          .read(boardProviderV2.notifier)
                          .updateElementPositionLive(elementId, newOffset);
                    },
                    onDragStart: (elementId) {
                      ref.read(boardProviderV2.notifier).startDrag(elementId);
                    },
                    onDragEnd: () {
                      _onBoardDragEnd(ref);
                    },
                    onBoardTap: () {
                      ref.read(boardProviderV2.notifier).deselectElement();
                    },
                  ),
                ),

                // Selection handles + delete zone — Consumer watches state
                // only for these overlays, so DragTarget is not disturbed.
                Consumer(
                  builder: (context, ref, _) {
                    final boardState = ref.watch(boardProviderV2);
                    return Stack(
                      children: [
                        // Interactive resize/rotation handles
                        SelectionHandlesOverlay(
                          state: boardState,
                          boardSize: boardSize,
                          onResizeStart: (id) {
                            ref
                                .read(boardProviderV2.notifier)
                                .startResize(id);
                          },
                          onResizeLive: (id, newSize) {
                            ref
                                .read(boardProviderV2.notifier)
                                .updateElementSizeLive(id, newSize);
                          },
                          onResizeEnd: (id) {
                            ref.read(boardProviderV2.notifier).endResize(id);
                          },
                          onRotationStart: (id) {
                            ref
                                .read(boardProviderV2.notifier)
                                .startRotation(id);
                          },
                          onRotateLive: (id, angle) {
                            ref
                                .read(boardProviderV2.notifier)
                                .updateElementAngleLive(id, angle);
                          },
                          onRotationEnd: (id) {
                            ref
                                .read(boardProviderV2.notifier)
                                .endRotation(id);
                          },
                        ),

                        // Delete drop zone (left edge, visible during drag)
                        if (boardState.isDraggingItem)
                          DeleteDropZoneV2(height: boardSize.height),
                      ],
                    );
                  },
                ),

                // Drag-over feedback from panel drops
                if (candidateData.isNotEmpty)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.08),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.7),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Handle drag end — check if element was dragged to delete zone.
  void _onBoardDragEnd(WidgetRef ref) {
    final boardState = ref.read(boardProviderV2);
    final notifier = ref.read(boardProviderV2.notifier);
    final selectedId = boardState.selectedElementId;
    if (selectedId == null) return;

    final element = boardState.selectedElement;
    if (element != null &&
        element.offset != null &&
        element.offset!.dx < -0.02) {
      // Dragged past left edge — delete the element
      notifier.cancelDrag(selectedId);
      notifier.removeElement(selectedId);
    } else {
      notifier.endDrag(selectedId);
    }
  }

  void _onElementDropped(
    BuildContext context,
    WidgetRef ref,
    BoardElement element,
    Offset globalOffset,
    BoxConstraints constraints,
  ) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(globalOffset);
    final boardSize = Size(constraints.maxWidth, constraints.maxHeight);
    final coords = CoordinateSystem(boardSize);

    final relativeOffset = coords.toRelative(localPosition);
    final clampedOffset = Offset(
      relativeOffset.dx.clamp(0.0, 1.0),
      relativeOffset.dy.clamp(0.0, 1.0),
    );

    final newElement = element.copyWithBase(
      id: RandomGenerator.generateId(),
      offset: clampedOffset,
    );

    ref.read(boardProviderV2.notifier).addElement(newElement);
  }
}
