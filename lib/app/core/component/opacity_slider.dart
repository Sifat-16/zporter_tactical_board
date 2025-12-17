import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class OpacitySlider extends StatefulWidget {
  final ValueChanged<double>? onOpacityChanged;
  final double initial;

  const OpacitySlider({Key? key, this.onOpacityChanged, required this.initial})
      : super(key: key);

  @override
  _OpacitySliderState createState() => _OpacitySliderState();
}

class _OpacitySliderState extends State<OpacitySlider> {
  double _opacityValue = 1.0; // Initial opacity is 100%

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _opacityValue = widget.initial;
  }

  void _updateOpacity(double value) {
    setState(() {
      _opacityValue = value;
    });

    widget.onOpacityChanged?.call(_opacityValue); // Notify the parent if needed
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
              value: _opacityValue,
              onChanged: _updateOpacity,
              min: 0.0,
              max: 1.0,
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
              '${(_opacityValue * 100).round()}%', // Display percentage
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
