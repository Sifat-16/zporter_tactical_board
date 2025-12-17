import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Assuming this is needed for ColorManager.grey

class ColorSlider extends StatefulWidget {
  final List<Color> colors;
  final ValueChanged<Color>? onColorChanged;
  final Color? initialColor; // New optional parameter

  const ColorSlider({
    super.key,
    required this.colors,
    this.onColorChanged,
    this.initialColor, // Added to constructor
  }) : assert(colors.length > 0, 'colors list cannot be empty');

  @override
  _ColorSliderState createState() => _ColorSliderState();
}

class _ColorSliderState extends State<ColorSlider> {
  double _sliderValue = 0.0;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();

    // Determine initial state based on initialColor
    _initializeState();
  }

  // Helper function to set initial state
  void _initializeState() {
    _selectedColor = widget.initialColor ?? widget.colors.first;
    _sliderValue = _findSliderValueForColor(_selectedColor) ?? 0.0;
  }

  // --- Optional: Helper to find approximate slider value for a given color ---
  // Note: This might not be perfectly accurate, especially for complex gradients.
  double? _findSliderValueForColor(Color targetColor) {
    if (widget.colors.length <= 1) return 0.0;

    double minDifference = double.infinity;
    double bestValue = 0.0;

    // Check endpoints first
    if (_colorDifference(targetColor, widget.colors.first) < minDifference) {
      minDifference = _colorDifference(targetColor, widget.colors.first);
      bestValue = 0.0;
    }
    if (_colorDifference(targetColor, widget.colors.last) < minDifference) {
      minDifference = _colorDifference(targetColor, widget.colors.last);
      bestValue = 1.0;
    }

    // Check segments
    int sectionCount = widget.colors.length - 1;
    for (int i = 0; i < sectionCount; i++) {
      // Check along the lerp segment with reasonable steps
      for (double t = 0.0; t <= 1.0; t += 0.05) {
        // Check every 5% along segment
        Color lerpedColor =
            Color.lerp(widget.colors[i], widget.colors[i + 1], t) ??
                widget.colors[i];
        double diff = _colorDifference(targetColor, lerpedColor);
        if (diff < minDifference) {
          minDifference = diff;
          // Calculate overall slider value for this segment position
          bestValue = (i + t) / sectionCount;
        }
      }
    }
    // Threshold check - if the best match isn't very close, maybe don't use it?
    // if (minDifference > 500) return null; // Arbitrary threshold

    return bestValue.clamp(0.0, 1.0);
  }

  // Simple color difference calculation (sum of squared differences)
  double _colorDifference(Color c1, Color c2) {
    int rDiff = c1.red - c2.red;
    int gDiff = c1.green - c2.green;
    int bDiff = c1.blue - c2.blue;
    // int aDiff = c1.alpha - c2.alpha; // Optionally include alpha difference
    return (rDiff * rDiff + gDiff * gDiff + bDiff * bDiff)
        .toDouble(); // + aDiff * aDiff
  }
  // --- End Optional Helper ---

  void _updateColor(double value) {
    // Clamp value just in case
    final clampedValue = value.clamp(0.0, 1.0);
    final newSelectedColor = _getInterpolatedColor(clampedValue);

    // Avoid unnecessary setState calls if color/value haven't changed significantly
    if ((clampedValue - _sliderValue).abs() > 0.001 ||
        newSelectedColor != _selectedColor) {
      setState(() {
        _sliderValue = clampedValue;
        _selectedColor = newSelectedColor;
      });
      widget.onColorChanged?.call(_selectedColor);
    }
  }

  Color _getInterpolatedColor(double value) {
    if (widget.colors.length == 1) return widget.colors.first;

    int sectionCount = widget.colors.length - 1;
    double scaledValue = value * sectionCount;
    int index = scaledValue.floor().clamp(
          0,
          sectionCount - 1,
        ); // Ensure index is valid

    // Ensure t is between 0.0 and 1.0
    double t = (scaledValue - index).clamp(0.0, 1.0);

    // Handle edge case where value is exactly 1.0
    if (value >= 1.0) return widget.colors.last;

    return Color.lerp(widget.colors[index], widget.colors[index + 1], t) ??
        widget.colors[index]; // Fallback to start of segment
  }

  @override
  Widget build(BuildContext context) {
    // Handle case of empty colors list gracefully
    if (widget.colors.isEmpty) {
      return const SizedBox(
        height: 50,
        child: Center(child: Text("Error: No colors provided.")),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // width: 300, // Consider using LayoutBuilder or constraints for flexibility
          constraints: const BoxConstraints(
            maxWidth: 300,
          ), // Better than fixed width
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              // Make track transparent so gradient shows through
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
            ),
            child: Slider(
              value: _sliderValue,
              thumbColor: _selectedColor, // Thumb reflects selected color
              onChanged: _updateColor,
              min: 0.0, // Explicitly use double
              max: 1.0, // Explicitly use double
            ),
          ),
        ),
        const SizedBox(height: 10), // Reduced spacing slightly
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ), // Add some padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected:', // Shorter label
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: ColorManager.grey),
              ),
              // const SizedBox(width: 10), // Spacing adjusted by MainAxisAlignment.spaceBetween
              Container(
                // Swatch to show the color visually
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
              ),
              Text(
                // Show hex code including alpha, uppercase
                "#${_selectedColor.value.toRadixString(16).toUpperCase().padLeft(8, '0')}",
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: ColorManager.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
