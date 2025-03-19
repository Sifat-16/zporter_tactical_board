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

  void _toggleSwitch(bool value) {
    setState(() {
      _isSwitched = value;
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color:
                _isSwitched ? ColorManager.white : Colors.grey, // Color change
          ),
        ),
        Switch(
          value: _isSwitched,
          onChanged: _toggleSwitch,
          activeColor: Colors.blue,
          // Switch active color
          inactiveTrackColor: ColorManager.dark1, // Switch inactive color
          inactiveThumbColor: Colors.grey, // Thumb color when off
        ),
      ],
    );
  }
}
