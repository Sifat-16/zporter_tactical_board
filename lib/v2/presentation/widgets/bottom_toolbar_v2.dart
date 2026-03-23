import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';

/// Bottom toolbar matching V1's FormSpeedDialComponent layout.
///
/// Three sections across the bottom of the board:
/// - Left: Fullscreen toggle, Undo
/// - Center: (reserved for drawing tools)
/// - Right: Copy, Add scene, Delete, Clear all
///
/// Height: 36px. Semi-transparent black background.
/// Hidden during animation playback.
class BottomToolbarV2 extends ConsumerWidget {
  /// Called when the fullscreen button is tapped.
  final VoidCallback? onToggleFullscreen;

  /// Called when the "add scene" button is tapped.
  final VoidCallback? onAddScene;

  /// Called when the "clear all" button is tapped.
  final VoidCallback? onClearAll;

  /// Whether fullscreen is currently active.
  final bool isFullscreen;

  const BottomToolbarV2({
    super.key,
    this.onToggleFullscreen,
    this.onAddScene,
    this.onClearAll,
    this.isFullscreen = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = ref.watch(boardProviderV2);
    final notifier = ref.read(boardProviderV2.notifier);
    final hasSelection = boardState.selectedElementId != null;
    final canUndo = notifier.canUndo;
    final canRedo = notifier.canRedo;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          // LEFT SECTION: Fullscreen, Undo/Redo
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ToolbarButton(
                  icon: isFullscreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  tooltip: isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
                  onTap: onToggleFullscreen,
                ),
                _ToolbarButton(
                  icon: Icons.undo,
                  tooltip: 'Undo',
                  onTap: canUndo ? () => notifier.undo() : null,
                  enabled: canUndo,
                ),
                _ToolbarButton(
                  icon: Icons.redo,
                  tooltip: 'Redo',
                  onTap: canRedo ? () => notifier.redo() : null,
                  enabled: canRedo,
                ),
              ],
            ),
          ),

          // CENTER SECTION: Drawing tools placeholder
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ToolbarButton(
                  icon: Icons.touch_app,
                  tooltip: 'Select',
                  onTap: () {
                    // Default pointer mode — deselect active tools
                  },
                ),
              ],
            ),
          ),

          // RIGHT SECTION: Copy, Add Scene, Delete, Clear
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ToolbarButton(
                  icon: Icons.copy,
                  tooltip: 'Copy',
                  onTap: hasSelection
                      ? () {
                          final id = boardState.selectedElementId!;
                          notifier.copyElement(id);
                          final element = boardState.selectedElement;
                          if (element?.offset != null) {
                            notifier.pasteElement(
                              newId: DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString(),
                              offset: Offset(
                                element!.offset!.dx + 0.03,
                                element.offset!.dy + 0.03,
                              ),
                            );
                          }
                        }
                      : null,
                  enabled: hasSelection,
                ),
                _ToolbarButton(
                  icon: CupertinoIcons.add_circled,
                  tooltip: 'Add Scene',
                  onTap: onAddScene,
                ),
                _ToolbarButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete',
                  onTap: hasSelection
                      ? () => notifier.removeSelectedElement()
                      : null,
                  enabled: hasSelection,
                ),
                _ToolbarButton(
                  icon: Icons.cleaning_services_outlined,
                  tooltip: 'Clear All',
                  onTap: onClearAll,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool enabled;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
