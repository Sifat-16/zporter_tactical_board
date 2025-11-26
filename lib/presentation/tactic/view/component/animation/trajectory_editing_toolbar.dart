import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/trajectory_path_model.dart';

/// Floating trajectory editing toolbar that appears on the game canvas
///
/// This overlay UI appears when:
/// - User is in animation mode (has multiple scenes)
/// - User has selected a component in the current scene
/// - Current scene is not the first scene (needs previous scene for trajectory)
///
/// Provides controls for:
/// - Enable/disable custom trajectory path
/// - Add/remove control points
/// - Adjust path smoothness
/// - Change path color
/// - Path type selection (future: straight/curved/bezier)
class TrajectoryEditingToolbar extends ConsumerStatefulWidget {
  /// Current trajectory model (null if trajectory editing not active)
  final TrajectoryPathModel? currentTrajectory;

  /// Callback when user toggles trajectory enabled
  final VoidCallback? onToggleEnabled;

  /// Callback when user adds a control point
  final VoidCallback? onAddControlPoint;

  /// Callback when user removes a control point
  final VoidCallback? onRemoveControlPoint;

  /// Callback when user changes smoothness
  final ValueChanged<double>? onSmoothnessChanged;

  /// Callback when user changes path color
  final ValueChanged<Color>? onColorChanged;

  /// Callback when user closes the toolbar
  final VoidCallback? onClose;

  /// Whether the toolbar is visible
  final bool isVisible;

  const TrajectoryEditingToolbar({
    super.key,
    this.currentTrajectory,
    this.onToggleEnabled,
    this.onAddControlPoint,
    this.onRemoveControlPoint,
    this.onSmoothnessChanged,
    this.onColorChanged,
    this.onClose,
    this.isVisible = false,
  });

  @override
  ConsumerState<TrajectoryEditingToolbar> createState() =>
      _TrajectoryEditingToolbarState();
}

class _TrajectoryEditingToolbarState
    extends ConsumerState<TrajectoryEditingToolbar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  // Available path colors
  final List<Color> _pathColors = [
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.blue,
    Colors.cyan,
    Colors.green,
    Colors.lime,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    final trajectory = widget.currentTrajectory;
    final isEnabled = trajectory?.enabled ?? false;
    final smoothness = trajectory?.smoothness ?? 0.5;
    final pathColor = trajectory?.pathColor ?? Colors.yellow;
    final controlPointCount = trajectory?.controlPoints.length ?? 0;

    return Positioned(
      top: 60,
      right: 10,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: ColorManager.black.withOpacity(0.85),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 280,
            maxWidth: 320,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              InkWell(
                onTap: _toggleExpanded,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timeline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Animation Path',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Close button
                      InkWell(
                        onTap: widget.onClose,
                        child: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Expand/collapse icon
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.expand_more,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1, color: Colors.white24),

              // Content (expandable)
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1.0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enable toggle
                      _buildToggleRow(
                        'Enable Custom Path',
                        isEnabled,
                        widget.onToggleEnabled,
                      ),

                      if (isEnabled) ...[
                        const SizedBox(height: 16),

                        // Path type (currently read-only, shows "Curved")
                        _buildInfoRow('Path Type', 'Curved'),

                        const SizedBox(height: 16),

                        // Control points info and buttons
                        _buildControlPointsSection(controlPointCount),

                        const SizedBox(height: 16),

                        // Smoothness slider
                        _buildSmoothnessSlider(smoothness),

                        const SizedBox(height: 16),

                        // Color picker
                        _buildColorPicker(pathColor),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, VoidCallback? onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged != null ? (_) => onChanged() : null,
          activeColor: ColorManager.blue,
          inactiveThumbColor: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildControlPointsSection(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Control Points: ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ColorManager.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Add button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onAddControlPoint,
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add Point',
                  style: TextStyle(fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.blue.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Remove button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: count > 2 ? widget.onRemoveControlPoint : null,
                icon: const Icon(Icons.remove, size: 16),
                label: const Text(
                  'Remove',
                  style: TextStyle(fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.red.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Tip: Drag control points on canvas to adjust curve',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSmoothnessSlider(double smoothness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Smoothness',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              '${(smoothness * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: ColorManager.blue,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: ColorManager.blue.withOpacity(0.2),
            trackHeight: 2,
          ),
          child: Slider(
            value: smoothness,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: widget.onSmoothnessChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker(Color currentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Path Color',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _pathColors.map((color) {
            final isSelected = color.value == currentColor.value;
            return GestureDetector(
              onTap: () => widget.onColorChanged?.call(color),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 16,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
