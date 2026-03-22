import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';

/// Settings panel for board configuration.
///
/// Controls field color, team border colors, grid size, and background.
class SettingsPanelV2 extends ConsumerWidget {
  const SettingsPanelV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = ref.watch(boardProviderV2);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildFieldColorPicker(ref, boardState.boardColor),
        const SizedBox(height: 16),
        _buildTeamColorPicker(
          ref,
          label: 'Home Team Border',
          currentColor: boardState.homeTeamBorderColor,
          onColorChanged: (c) =>
              ref.read(boardProviderV2.notifier).updateHomeTeamBorderColor(c),
        ),
        const SizedBox(height: 16),
        _buildTeamColorPicker(
          ref,
          label: 'Away Team Border',
          currentColor: boardState.awayTeamBorderColor,
          onColorChanged: (c) =>
              ref.read(boardProviderV2.notifier).updateAwayTeamBorderColor(c),
        ),
        const SizedBox(height: 16),
        _buildBackgroundSelector(ref, boardState.boardBackground),
        const SizedBox(height: 16),
        _buildGridSizeSlider(ref, boardState.gridSize),
        const SizedBox(height: 16),
        _buildRotateButton(ref),
      ],
    );
  }

  Widget _buildFieldColorPicker(WidgetRef ref, Color currentColor) {
    final fieldColors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2E7D32), // Dark Green
      const Color(0xFF9E9E9E), // Grey
      const Color(0xFF424242), // Dark Grey
      const Color(0xFF1B5E20), // Forest Green
      const Color(0xFF795548), // Brown (dirt)
      Colors.white,
      Colors.black,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Field Color',
            style: TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fieldColors.map((color) {
            final isSelected = currentColor == color;
            return GestureDetector(
              onTap: () =>
                  ref.read(boardProviderV2.notifier).updateBoardColor(color),
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

  Widget _buildTeamColorPicker(
    WidgetRef ref, {
    required String label,
    required Color currentColor,
    required ValueChanged<Color> onColorChanged,
  }) {
    final teamColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.amber,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.pink,
      Colors.white,
      Colors.grey,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: teamColors.map((color) {
            final isSelected = currentColor == color;
            return GestureDetector(
              onTap: () => onColorChanged(color),
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

  Widget _buildBackgroundSelector(
      WidgetRef ref, BoardBackground currentBackground) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Background',
            style: TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: BoardBackground.values.map((bg) {
            final isSelected = bg == currentBackground;
            final label = switch (bg) {
              BoardBackground.full => 'Full',
              BoardBackground.halfUp => 'Half Up',
              BoardBackground.halfDown => 'Half Down',
              BoardBackground.verticalCorridors => 'Corridors',
              BoardBackground.clean => 'Clean',
            };
            return ChoiceChip(
              label: Text(label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.black : Colors.white70,
                  )),
              selected: isSelected,
              selectedColor: Colors.amber,
              backgroundColor: Colors.white10,
              onSelected: (_) =>
                  ref.read(boardProviderV2.notifier).updateBoardBackground(bg),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGridSizeSlider(WidgetRef ref, double gridSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grid Size: ${gridSize.round()}',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        Slider(
          value: gridSize,
          min: 0,
          max: 50,
          divisions: 10,
          activeColor: Colors.amber,
          inactiveColor: Colors.white24,
          onChanged: (value) =>
              ref.read(boardProviderV2.notifier).updateGridSize(value),
        ),
      ],
    );
  }

  Widget _buildRotateButton(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => ref.read(boardProviderV2.notifier).rotateField(),
        icon: const Icon(Icons.rotate_90_degrees_ccw, size: 16),
        label: const Text('Rotate Field', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
