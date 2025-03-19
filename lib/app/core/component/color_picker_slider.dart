import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class ColorSlider extends StatefulWidget {
  final List<Color> colors;
  final ValueChanged<Color>? onColorChanged;

  const ColorSlider({Key? key, required this.colors, this.onColorChanged})
    : super(key: key);

  @override
  _ColorSliderState createState() => _ColorSliderState();
}

class _ColorSliderState extends State<ColorSlider> {
  double _sliderValue = 0.0;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.colors.first;
  }

  void _updateColor(double value) {
    setState(() {
      _sliderValue = value;
      _selectedColor = _getInterpolatedColor(value);
    });

    widget.onColorChanged?.call(_selectedColor);
  }

  Color _getInterpolatedColor(double value) {
    int sectionCount = widget.colors.length - 1;
    double scaledValue = value * sectionCount;
    int index = scaledValue.floor();

    if (index >= sectionCount) return widget.colors.last;

    double t = scaledValue - index; // Get fractional part for interpolation
    return Color.lerp(widget.colors[index], widget.colors[index + 1], t) ??
        widget.colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 300,
          height: 8, // Make track denser
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
              trackHeight: 4, // Makes the track thinner
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 6, // Makes the thumb smaller
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 10, // Reduces the hover effect size
              ),
              inactiveTrackColor: Colors.transparent,
              activeTrackColor: Colors.transparent,
            ),
            child: Slider(
              value: _sliderValue,
              thumbColor: _selectedColor,

              onChanged: _updateColor,
              min: 0,
              max: 1,
              activeColor: Colors.transparent,
              inactiveColor: Colors.transparent,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected Color:',
              style: Theme.of(
                context,
              ).textTheme.labelSmall!.copyWith(color: ColorManager.grey),
            ),
            const SizedBox(height: 10),
            Text(
              "${_selectedColor.value.toRadixString(16)}",
              style: Theme.of(
                context,
              ).textTheme.labelSmall!.copyWith(color: ColorManager.grey),
            ),
          ],
        ),
      ],
    );
  }
}
