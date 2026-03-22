import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/v2/core/coordinate_system.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/presentation/animated_board_widget.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';

/// Wraps [AnimatedTacticBoardV2] in a [DragTarget<BoardElement>] so
/// elements can be dragged from toolbar panels onto the board.
///
/// Converts the drop position from screen pixels to ratio-based (0.0–1.0)
/// center-anchored coordinates using [CoordinateSystem], then calls
/// [BoardNotifier.addElement()] with the correctly positioned element.
class BoardDropZoneV2 extends ConsumerWidget {
  /// Global key for the board's RepaintBoundary (for thumbnail capture).
  final GlobalKey? repaintBoundaryKey;

  const BoardDropZoneV2({
    super.key,
    this.repaintBoundaryKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DragTarget<BoardElement>(
          onAcceptWithDetails: (details) {
            _onElementDropped(
              context,
              ref,
              details.data,
              details.offset,
              constraints,
            );
          },
          builder: (context, candidateData, rejectedData) {
            final board = RepaintBoundary(
              key: repaintBoundaryKey,
              child: AnimatedTacticBoardV2(
                onElementSelected: (element) {
                  final notifier = ref.read(boardProviderV2.notifier);
                  notifier.selectElement(element?.id);
                },
                onElementMoved: (elementId, newOffset) {
                  final notifier = ref.read(boardProviderV2.notifier);
                  notifier.updateElementPositionLive(elementId, newOffset);
                },
                onDragStart: (elementId) {
                  final notifier = ref.read(boardProviderV2.notifier);
                  notifier.startDrag(elementId);
                },
                onDragEnd: () {
                  final boardState = ref.read(boardProviderV2);
                  final notifier = ref.read(boardProviderV2.notifier);
                  final selectedId = boardState.selectedElementId;
                  if (selectedId != null) {
                    notifier.endDrag(selectedId);
                  }
                },
                onBoardTap: () {
                  ref.read(boardProviderV2.notifier).deselectElement();
                },
              ),
            );

            // Visual feedback during drag-over
            if (candidateData.isNotEmpty) {
              return Stack(
                children: [
                  board,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return board;
          },
        );
      },
    );
  }

  void _onElementDropped(
    BuildContext context,
    WidgetRef ref,
    BoardElement element,
    Offset globalOffset,
    BoxConstraints constraints,
  ) {
    // Convert global drop position to local board position
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(globalOffset);
    final boardSize = Size(constraints.maxWidth, constraints.maxHeight);
    final coords = CoordinateSystem(boardSize);

    // Convert to ratio-based (0.0–1.0) center-anchored position
    final relativeOffset = coords.toRelative(localPosition);

    // Clamp to board bounds
    final clampedOffset = Offset(
      relativeOffset.dx.clamp(0.0, 1.0),
      relativeOffset.dy.clamp(0.0, 1.0),
    );

    // Create element with unique ID and drop position
    final newElement = element.copyWithBase(
      id: RandomGenerator.generateId(),
      offset: clampedOffset,
    );

    ref.read(boardProviderV2.notifier).addElement(newElement);
  }
}
