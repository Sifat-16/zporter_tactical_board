import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class IncrementDecrementNumberField extends StatefulWidget {
  final String label;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const IncrementDecrementNumberField({
    Key? key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _IncrementNumberFieldState createState() => _IncrementNumberFieldState();
}

class _IncrementNumberFieldState extends State<IncrementDecrementNumberField> {
  late TextEditingController _controller;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: _currentValue.toString());
  }

  void _increment() {
    setState(() {
      _currentValue++;
      _controller.text = _currentValue.toString();
      widget.onChanged(_currentValue);
    });
  }

  void _decrement() {
    setState(() {
      _currentValue--;
      _controller.text = _currentValue.toString();
      widget.onChanged(_currentValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,

        keyboardType: TextInputType.number,
        style: Theme.of(
          context,
        ).textTheme.labelMedium!.copyWith(color: ColorManager.white),
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          suffix: _inc_dec_btn(),

          label: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: ColorManager.grey,
              fontWeight: FontWeight.bold,
            ),
          ),

          //contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          hintText: 'Enter a number',
        ),
        onChanged: (value) {
          final intValue = int.tryParse(value);
          if (intValue != null) {
            setState(() {
              _currentValue = intValue;
            });
            widget.onChanged(_currentValue);
          }
        },
      ),
    );
  }

  Widget _inc_dec_btn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _increment,
          child: Icon(Icons.arrow_drop_up, color: ColorManager.grey),
        ),
        GestureDetector(
          onTap: _decrement,
          child: const Icon(Icons.arrow_drop_down, color: ColorManager.grey),
        ),
      ],
    );
  }
}
