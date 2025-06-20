import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Assuming this exists

// Generic StatefulWidget remains the same
class DropdownSelector<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final String? emptyItem;
  final String? hint;

  final T? initialValue;
  final ValueChanged<T?> onChanged;
  final EdgeInsets? padding;
  final String Function(T item) itemAsString; // Converts non-null T to String

  const DropdownSelector({
    super.key,
    required this.label,
    this.emptyItem,
    required this.items,
    this.hint,
    this.initialValue,
    required this.onChanged,
    this.padding,
    required this.itemAsString,
  });

  @override
  _DropdownSelectorState<T> createState() => _DropdownSelectorState<T>();
}

class _DropdownSelectorState<T> extends State<DropdownSelector<T>> {
  T? _selectedValue;
  // Add TextEditingController for DropdownMenu display
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    // Initialize controller text based on initial selection
    _controller = TextEditingController(
      text: _selectedValue == null
          ? ''
          : widget.itemAsString(
              _selectedValue as T,
            ), // Display "" or item string
    );
  }

  @override
  void didUpdateWidget(covariant DropdownSelector<T> oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    setState(() {
      _selectedValue = widget.initialValue;

      _controller.text = _selectedValue == null
          ? ''
          : widget.itemAsString(
              _selectedValue as T,
            ); // Display "" or item string
    });
    zlog(data: "Selector update ${widget.initialValue.runtimeType}");
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dropdownItemStyle = textTheme.labelMedium!.copyWith(
      color: ColorManager.white,
    );
    final dropdownHintStyle = TextStyle(color: ColorManager.white);

    return Padding(
      // Keep overall padding
      padding: widget.padding ?? EdgeInsets.zero,
      // Replace DropdownButtonFormField with DropdownMenu
      child: LayoutBuilder(builder: (context, constraints) {
        return DropdownMenu<T?>(
          width: constraints.maxWidth,
          hintText: widget.hint,
          expandedInsets: EdgeInsets.zero,
          enableSearch: true,
          searchCallback: (items, query) {
            return null;
          },
          // Controller manages the text field's display
          controller: _controller,
          // Provide initial selection (DropdownMenu handles this internally too, but sync with controller)
          initialSelection: _selectedValue,
          // Label Widget
          label: Text(
            widget.label,
            style: textTheme.labelLarge!.copyWith(
              color: ColorManager.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          dropdownMenuEntries: <DropdownMenuEntry<T?>>[
            ...widget.items.map<DropdownMenuEntry<T?>>((T item) {
              return DropdownMenuEntry<T?>(
                value: item,
                labelWidget: SizedBox(
                  width: constraints.maxWidth,
                  child: Text(
                    widget.itemAsString(item),
                    style: dropdownHintStyle,
                  ),
                ),
                label: widget.itemAsString(item), // Required label string
                // Optional: Use labelWidget if specific styling per item is needed
                // labelWidget: Text(widget.itemAsString(item), style: dropdownItemStyle),
              );
            }),
          ],
          // Callback when an item is selected
          onSelected: (T? value) {
            // Update internal state
            setState(() {
              _selectedValue = value;
            });
            widget.onChanged(value);
          },

          // Style the dropdown menu itself (background, text style for items)
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(ColorManager.dark2),
          ),

          // Style the text field part using InputDecorationTheme or directly
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(),

            floatingLabelBehavior: FloatingLabelBehavior.auto,

            // You might need to customize filled, fillColor etc. based on design
          ),

          // The text style within the TextField part (controlled by controller)
          textStyle:
              dropdownItemStyle, // Use same style for selected item text?
        );
      }),
    );
  }
}
