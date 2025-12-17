import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class CustomSlider extends StatefulWidget {
  final ValueChanged<double>? onValueChanged;
  final double min;
  final double max;
  final double? initial;

  const CustomSlider({
    Key? key,
    this.onValueChanged,
    required this.min,
    required this.max,
    required this.initial,
  }) : super(key: key);

  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double _value = 1.0; // Initial opacity is 100%

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _value = widget.initial ?? widget.min;
  }

  void _updateOpacity(double value) {
    setState(() {
      _value = value;
    });

    widget.onValueChanged?.call(_value); // Notify the parent if needed
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 300,
          height: 8, // Custom track height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[300], // Track background color
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4, // Makes the track thinner
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10, // Comfortable thumb size
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 24, // Larger touch area for better usability
              ),
              inactiveTrackColor: Colors.grey[400], // Inactive track color
              activeTrackColor: Colors.grey, // Active track color
            ),
            child: Slider(
              value: _value,
              onChanged: _updateOpacity,
              min: widget.min,
              max: widget.max,
              divisions: 100, // Sets the slider divisions
              activeColor: Colors.grey,
              inactiveColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Text(
              '${(_value).round()}', // Display percentage
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: ColorManager.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
