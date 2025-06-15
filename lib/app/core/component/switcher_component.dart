// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
//
// class SwitcherComponent extends StatefulWidget {
//   final String title;
//   final bool initialValue;
//   final ValueChanged<bool> onChanged;
//
//   const SwitcherComponent({
//     Key? key,
//     required this.title,
//     required this.initialValue,
//     required this.onChanged,
//   }) : super(key: key);
//
//   @override
//   _SwitcherComponentState createState() => _SwitcherComponentState();
// }
//
// class _SwitcherComponentState extends State<SwitcherComponent> {
//   late bool _isSwitched;
//
//   @override
//   void initState() {
//     super.initState();
//     _isSwitched = widget.initialValue;
//   }
//
//   void _toggleSwitch(bool value) {
//     setState(() {
//       _isSwitched = value;
//     });
//     widget.onChanged(value);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           widget.title,
//           style: Theme.of(context).textTheme.labelLarge!.copyWith(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color:
//                 _isSwitched ? ColorManager.white : Colors.grey, // Color change
//           ),
//         ),
//         Switch(
//           value: _isSwitched,
//           onChanged: _toggleSwitch,
//           activeColor: Colors.blue,
//           // Switch active color
//           inactiveTrackColor: ColorManager.dark1, // Switch inactive color
//           inactiveThumbColor: Colors.grey, // Thumb color when off
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class SwitcherComponent extends StatefulWidget {
  final String title;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const SwitcherComponent({
    Key? key,
    required this.title,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _SwitcherComponentState createState() => _SwitcherComponentState();
}

class _SwitcherComponentState extends State<SwitcherComponent> {
  late bool _isSwitched;

  @override
  void initState() {
    super.initState();
    _isSwitched = widget.initialValue;
  }

  void _handleTap() {
    setState(() {
      _isSwitched = !_isSwitched;
    });
    widget.onChanged(_isSwitched);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: _isSwitched ? ColorManager.white : Colors.grey[600],
              ),
        ),
        GestureDetector(
          onTap: _handleTap,
          // Use a container to ensure the tap area is large enough
          child: Container(
            color: Colors.transparent, // Makes the padding tappable
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: _CustomSwitch(
              value: _isSwitched,
            ),
          ),
        ),
      ],
    );
  }
}

//==============================================================================
// FINAL Custom Switch Widget (Oversized Thumb)
//==============================================================================

class _CustomSwitch extends StatelessWidget {
  final bool value;

  const _CustomSwitch({required this.value});

  // Define new dimensions for the oversized thumb effect.
  static const double trackWidth = 40.0;
  static const double trackHeight = 15.0; // The track is shorter.
  static const double thumbSize = 22.0; // The thumb is taller than the track.

  @override
  Widget build(BuildContext context) {
    // The parent SizedBox ensures the widget has enough space for the
    // oversized thumb without being clipped.
    return SizedBox(
      width: trackWidth,
      height: thumbSize, // Height is determined by the larger thumb.
      child: Stack(
        // Center the track vertically within the bounds of the thumb's height.
        alignment: Alignment.center,
        children: [
          // --- Layer 1: The Track (in the background) ---
          Container(
            width: trackWidth,
            height: trackHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(trackHeight / 2),
              color: ColorManager.dark1,
            ),
          ),

          // --- Layer 2: The Thumb (on top) ---
          // AnimatedAlign will move the thumb horizontally within the Stack.
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // The thumb's color changes based on the state.
                color: value ? const Color(0xFF4A4AFF) : Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
