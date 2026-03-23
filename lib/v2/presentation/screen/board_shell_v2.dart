import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/v2/presentation/panels/left/left_toolbar_v2.dart';
import 'package:zporter_tactical_board/v2/presentation/panels/right/right_toolbar_v2.dart';
import 'package:zporter_tactical_board/v2/presentation/widgets/board_drop_zone_v2.dart';
import 'package:zporter_tactical_board/v2/presentation/widgets/bottom_toolbar_v2.dart';
import 'package:zporter_tactical_board/v2/presentation/widgets/panel_toggle_button.dart';
import 'package:zporter_tactical_board/v2/state/animation_provider.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';

/// Stack layout composing the board with sliding left/right panels.
///
/// Panel width: 25% of screen (same as V1).
/// Animation duration: 250ms (same as V1).
/// Panels auto-hide during animation playback.
class BoardShellV2 extends ConsumerStatefulWidget {
  /// User ID for animation panel CRUD.
  final String userId;

  /// Global key for the board's RepaintBoundary (thumbnail capture).
  final GlobalKey? repaintBoundaryKey;

  const BoardShellV2({
    super.key,
    required this.userId,
    this.repaintBoundaryKey,
  });

  @override
  ConsumerState<BoardShellV2> createState() => _BoardShellV2State();
}

class _BoardShellV2State extends ConsumerState<BoardShellV2> {
  bool _leftPanelOpen = false;
  bool _rightPanelOpen = false;

  static const _animDuration = Duration(milliseconds: 250);
  static const _panelWidthFraction = 0.25;

  @override
  Widget build(BuildContext context) {
    final animState = ref.watch(animationProviderV2);
    final boardState = ref.watch(boardProviderV2);
    final isPlaybackActive = animState.isActive;

    // Auto-hide panels during playback
    final showLeft = _leftPanelOpen && !isPlaybackActive;
    final showRight = _rightPanelOpen && !isPlaybackActive;

    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth * _panelWidthFraction;

        return Stack(
          children: [
            // Board + bottom toolbar in a Column
            Positioned.fill(
              child: Column(
                children: [
                  // Board area
                  Expanded(
                    child: BoardDropZoneV2(
                      repaintBoundaryKey: widget.repaintBoundaryKey,
                    ),
                  ),

                  // Bottom toolbar (hidden during playback)
                  if (!isPlaybackActive)
                    BottomToolbarV2(
                      isFullscreen: boardState.showFullScreen,
                      onToggleFullscreen: () {
                        ref.read(boardProviderV2.notifier).toggleFullScreen();
                      },
                      onAddScene: null, // TODO: wire to collection notifier
                      onClearAll: () {
                        // Remove all elements from the board
                        final components = boardState.components;
                        final notifier = ref.read(boardProviderV2.notifier);
                        for (final c in components) {
                          notifier.removeElement(c.id);
                        }
                      },
                    ),
                ],
              ),
            ),

            // Left panel
            AnimatedPositioned(
              duration: _animDuration,
              curve: Curves.easeInOut,
              left: showLeft ? 0 : -panelWidth,
              top: 0,
              bottom: 0,
              width: panelWidth,
              child: const LeftToolbarV2(),
            ),

            // Right panel
            AnimatedPositioned(
              duration: _animDuration,
              curve: Curves.easeInOut,
              right: showRight ? 0 : -panelWidth,
              top: 0,
              bottom: 0,
              width: panelWidth,
              child: RightToolbarV2(userId: widget.userId),
            ),

            // Left toggle button
            if (!isPlaybackActive)
              AnimatedPositioned(
                duration: _animDuration,
                curve: Curves.easeInOut,
                left: showLeft ? panelWidth : 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: PanelToggleButton(
                    isOpen: _leftPanelOpen,
                    onToggle: () =>
                        setState(() => _leftPanelOpen = !_leftPanelOpen),
                    side: PanelSide.left,
                  ),
                ),
              ),

            // Right toggle button
            if (!isPlaybackActive)
              AnimatedPositioned(
                duration: _animDuration,
                curve: Curves.easeInOut,
                right: showRight ? panelWidth : 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: PanelToggleButton(
                    isOpen: _rightPanelOpen,
                    onToggle: () =>
                        setState(() => _rightPanelOpen = !_rightPanelOpen),
                    side: PanelSide.right,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
