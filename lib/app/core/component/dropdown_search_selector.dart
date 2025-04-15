import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

// Generic StatefulWidget remains the same
class DropdownSearchSelector<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final String? emptyItem;

  final bool Function(T, T) comparatorFunc;

  final T? initialValue;
  final ValueChanged<T?> onChanged;
  final EdgeInsets? padding;
  final String Function(T item) itemAsString; // Converts non-null T to String

  const DropdownSearchSelector({
    super.key,
    required this.label,
    this.emptyItem,
    required this.items,
    required this.comparatorFunc,

    this.initialValue,
    required this.onChanged,
    this.padding,
    required this.itemAsString,
  });

  @override
  _DropdownSearchSelectorState<T> createState() =>
      _DropdownSearchSelectorState<T>();
}

class _DropdownSearchSelectorState<T> extends State<DropdownSearchSelector<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant DropdownSearchSelector<T> oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    setState(() {
      _selectedValue = widget.initialValue;
    });
    zlog(data: "Selector update ${widget.initialValue.runtimeType}");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define your text styles if needed, e.g.:
    final itemTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white, // Example: White text on black background
    );
    final hintTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.grey, // Example: Grey hint text
    );

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: DropdownSearch<T>(
        compareFn: widget.comparatorFunc,
        selectedItem: _selectedValue, // Make sure to pass the selected value
        onChanged: (T? newValue) {
          // Handle selection changes
          setState(() {
            _selectedValue = newValue;
          });
          widget.onChanged(newValue);
        },
        itemAsString: widget.itemAsString, // Pass itemAsString

        popupProps: PopupProps.menu(
          fit: FlexFit.loose,
          showSearchBox: true,

          // --- Style the Popup Menu ---
          menuProps: MenuProps(
            backgroundColor: Colors.black, // <<< SET POPUP BACKGROUND HERE
            // elevation: 8, // Optional: Adjust shadow if needed
            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Optional: Add border radius
          ),

          // --- Build Items ---
          itemBuilder: (context, item, isSelected, i) {
            // Use a background color aware widget like ListTile or Container
            return Container(
              child: ListTile(
                title: Text(
                  widget.itemAsString(item),
                  style: itemTextStyle?.copyWith(
                    // Ensure style is applied
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                // dense: true, // Optional: Make items more compact
              ),
            );
          },
          // Add empty, loading, error builders as needed
        ),
      ),
    );
  }
}
