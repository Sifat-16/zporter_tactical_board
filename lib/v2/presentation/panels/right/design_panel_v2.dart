import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';

/// Design panel for editing selected element properties.
///
/// Shows an empty state when no element is selected. When an element
/// is selected, shows action buttons (copy, z-order, delete) and
/// property editors (color, opacity, size, player-specific toggles).
class DesignPanelV2 extends ConsumerWidget {
  const DesignPanelV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = ref.watch(boardProviderV2);
    final selectedId = boardState.selectedElementId;

    if (selectedId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Tap and mark what to redesign',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      );
    }

    final element = boardState.components
        .cast<BoardElement?>()
        .firstWhere((c) => c?.id == selectedId, orElse: () => null);

    if (element == null) {
      return const Center(
        child: Text(
          'Element not found',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildActionBar(ref, element),
        const SizedBox(height: 16),
        _buildOpacitySlider(ref, element),
        const SizedBox(height: 16),
        _buildColorPicker(ref, element),
        if (element is PlayerElement) ...[
          const SizedBox(height: 16),
          _buildPlayerToggles(ref, element),
        ],
      ],
    );
  }

  Widget _buildActionBar(WidgetRef ref, BoardElement element) {
    final notifier = ref.read(boardProviderV2.notifier);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (element.canBeCopied)
          _ActionButton(
            icon: Icons.copy,
            label: 'Copy',
            onTap: () {
              notifier.copyElement(element.id);
              notifier.pasteElement(
                newId: RandomGenerator.generateId(),
                offset: Offset(
                  (element.offset?.dx ?? 0.5) + 0.03,
                  (element.offset?.dy ?? 0.5) + 0.03,
                ),
              );
            },
          ),
        _ActionButton(
          icon: Icons.arrow_upward,
          label: 'Front',
          onTap: () => notifier.moveElementToFront(element.id),
        ),
        _ActionButton(
          icon: Icons.arrow_downward,
          label: 'Back',
          onTap: () => notifier.moveElementToBack(element.id),
        ),
        _ActionButton(
          icon: Icons.keyboard_arrow_up,
          label: 'Up',
          onTap: () => notifier.moveElementUp(element.id),
        ),
        _ActionButton(
          icon: Icons.keyboard_arrow_down,
          label: 'Down',
          onTap: () => notifier.moveElementDown(element.id),
        ),
        _ActionButton(
          icon: Icons.delete_outline,
          label: 'Delete',
          color: Colors.red,
          onTap: () => notifier.removeElement(element.id),
        ),
      ],
    );
  }

  Widget _buildOpacitySlider(WidgetRef ref, BoardElement element) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opacity',
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
        Slider(
          value: element.opacity,
          min: 0.1,
          max: 1.0,
          divisions: 9,
          activeColor: Colors.amber,
          inactiveColor: Colors.white24,
          label: '${(element.opacity * 100).round()}%',
          onChanged: (value) {
            final updated = element.copyWithBase(opacity: value);
            ref.read(boardProviderV2.notifier).updateElement(updated);
          },
        ),
      ],
    );
  }

  Widget _buildColorPicker(WidgetRef ref, BoardElement element) {
    final colors = [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.amber,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.pink,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            final isSelected = element.color == color;
            return GestureDetector(
              onTap: () {
                final updated = element.copyWithBase(color: color);
                ref.read(boardProviderV2.notifier).updateElement(updated);
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.amber : Colors.white24,
                    width: isSelected ? 2 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlayerToggles(WidgetRef ref, PlayerElement player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Display Options',
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 6),
        _ToggleRow(
          label: 'Show Image',
          value: player.showImage,
          onChanged: (v) {
            final updated = player.copyWith(showImage: v);
            ref.read(boardProviderV2.notifier).updateElement(updated);
          },
        ),
        _ToggleRow(
          label: 'Show Number',
          value: player.showNr,
          onChanged: (v) {
            final updated = player.copyWith(showNr: v);
            ref.read(boardProviderV2.notifier).updateElement(updated);
          },
        ),
        _ToggleRow(
          label: 'Show Name',
          value: player.showName,
          onChanged: (v) {
            final updated = player.copyWith(showName: v);
            ref.read(boardProviderV2.notifier).updateElement(updated);
          },
        ),
        _ToggleRow(
          label: 'Show Role',
          value: player.showRole,
          onChanged: (v) {
            final updated = player.copyWith(showRole: v);
            ref.read(boardProviderV2.notifier).updateElement(updated);
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.amber,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
