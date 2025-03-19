import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class DropdownSelector extends StatefulWidget {
  final String label;
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String?> onChanged;

  const DropdownSelector({
    Key? key,
    required this.label,
    required this.items,
    this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _DropdownSelectorState createState() => _DropdownSelectorState();
}

class _DropdownSelectorState extends State<DropdownSelector> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedValue,
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text("-", style: TextStyle(color: Colors.grey)),
          ),
          ...widget.items.map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(color: ColorManager.white),
              ),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedValue = value;
          });
          widget.onChanged(value);
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          label: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: ColorManager.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          // suffixIcon: const Icon(Icons.arrow_drop_down, color: ColorManager.grey),
        ),
        dropdownColor: ColorManager.dark1,
      ),
    );
  }
}
