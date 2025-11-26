import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/trajectory_path_model.dart';

/// Context menu for editing trajectory properties
///
/// PHASE 5A: Allows coaches to customize trajectory type, color, and line style
/// Opened by double-tapping on a trajectory path or control point
class TrajectoryContextMenu extends StatefulWidget {
  /// Position where menu should appear (screen coordinates)
  final Offset position;

  /// Current trajectory model being edited
  final TrajectoryPathModel trajectory;

  /// Whether opened from a control point (vs trajectory path)
  final bool openedFromControlPoint;

  /// Selected control point type (if opened from control point)
  final ControlPointType? selectedControlPointType;

  /// Callback when trajectory type changes
  final Function(TrajectoryType type) onTypeChanged;

  /// Callback when trajectory color changes
  final Function(Color color) onColorChanged;

  /// Callback when line style changes
  final Function(LineStyle style) onStyleChanged;

  /// Callback when control point mode changes
  final Function(ControlPointType type)? onControlPointModeChanged;

  /// Callback when "Add Point Here" is tapped
  final VoidCallback onAddPoint;

  /// Callback when "Remove Point" is tapped
  final VoidCallback onRemovePoint;

  /// Callback when "Delete Trajectory" is tapped
  final VoidCallback onDeleteTrajectory;

  /// Callback when menu should close
  final VoidCallback onClose;

  const TrajectoryContextMenu({
    super.key,
    required this.position,
    required this.trajectory,
    this.openedFromControlPoint = false,
    this.selectedControlPointType,
    required this.onTypeChanged,
    required this.onColorChanged,
    required this.onStyleChanged,
    this.onControlPointModeChanged,
    required this.onAddPoint,
    required this.onRemovePoint,
    required this.onDeleteTrajectory,
    required this.onClose,
  });

  @override
  State<TrajectoryContextMenu> createState() => _TrajectoryContextMenuState();
}

class _TrajectoryContextMenuState extends State<TrajectoryContextMenu> {
  late TrajectoryType selectedType;
  late LineStyle selectedStyle;
  late Color selectedColor;
  late ControlPointType? selectedControlPointMode;

  // Draggable menu position
  late Offset menuPosition;
  Offset? dragStartOffset;

  @override
  void initState() {
    super.initState();
    selectedType = widget.trajectory.trajectoryType;
    selectedStyle = widget.trajectory.lineStyle;
    selectedColor = widget.trajectory.pathColor;
    selectedControlPointMode = widget.selectedControlPointType;
    menuPosition = widget.position;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop to close menu on tap outside
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Draggable menu positioned at tap location
        Positioned(
          left: menuPosition.dx,
          top: menuPosition.dy,
          child: GestureDetector(
            onPanStart: (details) {
              dragStartOffset = details.localPosition;
            },
            onPanUpdate: (details) {
              setState(() {
                menuPosition = Offset(
                  menuPosition.dx + details.delta.dx,
                  menuPosition.dy + details.delta.dy,
                );
              });
            },
            onPanEnd: (details) {
              dragStartOffset = null;
            },
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 280,
                constraints: const BoxConstraints(
                  maxHeight: 500, // Maximum height before scrolling
                ),
                decoration: BoxDecoration(
                  color: ColorManager.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorManager.dark2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header at the very top (not scrollable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: ColorManager.dark2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.drag_indicator,
                            color: ColorManager.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Edit Trajectory',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorManager.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                size: 20, color: ColorManager.white),
                            onPressed: widget.onClose,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Close menu',
                          ),
                        ],
                      ),
                    ),

                    // Scrollable content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Trajectory Type Selector
                            _buildSectionLabel('Type'),
                            const SizedBox(height: 8),
                            _buildTypeSelector(),
                            const SizedBox(height: 16),

                            // Line Style Selector
                            _buildSectionLabel('Style'),
                            const SizedBox(height: 8),
                            _buildStyleSelector(),
                            const SizedBox(height: 16),

                            // Color Picker
                            _buildSectionLabel('Color'),
                            const SizedBox(height: 8),
                            _buildColorPicker(),
                            const SizedBox(height: 16),

                            const Divider(color: ColorManager.dark2),
                            const SizedBox(height: 8),

                            // Control Point Actions
                            _buildSectionLabel('Control Points'),
                            const SizedBox(height: 8),
                            _buildControlPointActions(),
                            const SizedBox(height: 16),

                            const Divider(color: ColorManager.dark2),
                            const SizedBox(height: 8),

                            // Delete Trajectory Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  widget.onDeleteTrajectory();
                                  widget.onClose();
                                },
                                icon: const Icon(Icons.delete,
                                    color: ColorManager.red),
                                label: const Text(
                                  'Delete Trajectory',
                                  style: TextStyle(color: ColorManager.red),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side:
                                      const BorderSide(color: ColorManager.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ColorManager.white,
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TrajectoryType.values.map((type) {
        final isSelected = selectedType == type;
        return ChoiceChip(
          label: Text(_getTypeLabel(type)),
          avatar: Text(_getTypeIcon(type)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                selectedType = type;
              });
              widget.onTypeChanged(type);
            }
          },
          selectedColor: _getTypeColor(type).withOpacity(0.3),
          backgroundColor: ColorManager.dark2,
          labelStyle: TextStyle(
            color: isSelected ? ColorManager.white : ColorManager.grey,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStyleSelector() {
    return Row(
      children: LineStyle.values.map((style) {
        final isSelected = selectedStyle == style;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedStyle = style;
                });
                widget.onStyleChanged(style);
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isSelected ? ColorManager.yellow : ColorManager.dark2,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? ColorManager.dark1 : ColorManager.dark2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStylePreview(style),
                    const SizedBox(height: 4),
                    Text(
                      _getStyleLabel(style),
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            isSelected ? ColorManager.white : ColorManager.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStylePreview(LineStyle style) {
    return CustomPaint(
      size: const Size(40, 3),
      painter: _LineStylePainter(style),
    );
  }

  Widget _buildColorPicker() {
    final presetColors = [
      Colors.white,
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.black,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presetColors.map((color) {
        final isSelected = selectedColor.value == color.value;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedColor = color;
            });
            widget.onColorChanged(color);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? ColorManager.yellow : ColorManager.grey,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check,
                    size: 16,
                    color: color == Colors.white || color == Colors.yellow
                        ? Colors.black54
                        : Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildControlPointActions() {
    return Column(
      children: [
        // Control Point Mode Selector (only show if opened from control point)
        if (widget.openedFromControlPoint &&
            selectedControlPointMode != null) ...[
          _buildControlPointModeSelector(),
          const SizedBox(height: 8),
        ],

        // Add Point button (only show if NOT opened from control point)
        if (!widget.openedFromControlPoint)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onAddPoint();
                widget.onClose();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Point Here'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.yellow,
                foregroundColor: ColorManager.black,
              ),
            ),
          ),

        // Remove Point button (only show if opened from control point)
        if (widget.openedFromControlPoint) ...[
          if (!widget.openedFromControlPoint) const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onRemovePoint();
                widget.onClose();
              },
              icon: const Icon(Icons.remove, size: 18),
              label: const Text('Remove Point'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.red,
                foregroundColor: ColorManager.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildControlPointModeSelector() {
    return Row(
      children: ControlPointType.values.map((mode) {
        final isSelected = selectedControlPointMode == mode;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedControlPointMode = mode;
                });
                widget.onControlPointModeChanged?.call(mode);
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isSelected ? ColorManager.yellow : ColorManager.dark2,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? ColorManager.dark1 : ColorManager.dark2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getControlPointModeIcon(mode),
                      color:
                          isSelected ? ColorManager.white : ColorManager.grey,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getControlPointModeLabel(mode),
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            isSelected ? ColorManager.white : ColorManager.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getControlPointModeIcon(ControlPointType type) {
    switch (type) {
      case ControlPointType.sharp:
        return Icons.crop_square;
      case ControlPointType.smooth:
        return Icons.circle_outlined;
      case ControlPointType.symmetric:
        return Icons.change_history;
    }
  }

  String _getControlPointModeLabel(ControlPointType type) {
    switch (type) {
      case ControlPointType.sharp:
        return 'Sharp';
      case ControlPointType.smooth:
        return 'Smooth';
      case ControlPointType.symmetric:
        return 'Symmetric';
    }
  }

  String _getTypeLabel(TrajectoryType type) {
    switch (type) {
      case TrajectoryType.passing:
        return 'Passing';
      case TrajectoryType.dribbling:
        return 'Dribbling';
      case TrajectoryType.shooting:
        return 'Shooting';
      case TrajectoryType.running:
        return 'Running';
      case TrajectoryType.defending:
        return 'Defending';
    }
  }

  String _getTypeIcon(TrajectoryType type) {
    switch (type) {
      case TrajectoryType.passing:
        return '⚽';
      case TrajectoryType.dribbling:
        return '👟';
      case TrajectoryType.shooting:
        return '🎯';
      case TrajectoryType.running:
        return '🏃';
      case TrajectoryType.defending:
        return '🛡️';
    }
  }

  Color _getTypeColor(TrajectoryType type) {
    switch (type) {
      case TrajectoryType.passing:
        return Colors.white;
      case TrajectoryType.dribbling:
        return Colors.yellow;
      case TrajectoryType.shooting:
        return Colors.orange;
      case TrajectoryType.running:
        return Colors.blue;
      case TrajectoryType.defending:
        return Colors.red;
    }
  }

  String _getStyleLabel(LineStyle style) {
    switch (style) {
      case LineStyle.solid:
        return 'Solid';
      case LineStyle.dashed:
        return 'Dashed';
      case LineStyle.dotted:
        return 'Dotted';
    }
  }
}

/// Custom painter for line style preview
class _LineStylePainter extends CustomPainter {
  final LineStyle style;

  _LineStylePainter(this.style);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final start = Offset(0, size.height / 2);
    final end = Offset(size.width, size.height / 2);

    switch (style) {
      case LineStyle.solid:
        canvas.drawLine(start, end, paint);
        break;

      case LineStyle.dashed:
        _drawDashedLine(canvas, start, end, paint, dashLength: 6, gapLength: 4);
        break;

      case LineStyle.dotted:
        _drawDashedLine(canvas, start, end, paint, dashLength: 2, gapLength: 3);
        break;
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final distance = (end - start).distance;
    final unitVector = (end - start) / distance;
    double currentDistance = 0;

    while (currentDistance < distance) {
      final dashStart = start + unitVector * currentDistance;
      final dashEnd = start +
          unitVector * (currentDistance + dashLength).clamp(0, distance);
      canvas.drawLine(dashStart, dashEnd, paint);
      currentDistance += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
