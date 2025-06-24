// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Assuming this exists
//
// // Generic StatefulWidget remains the same
// class DropdownSelector<T> extends StatefulWidget {
//   final String label;
//   final List<T> items;
//   final String? emptyItem;
//   final String? hint;
//
//   final T? initialValue;
//   final ValueChanged<T?> onChanged;
//   final EdgeInsets? padding;
//   final String Function(T item) itemAsString; // Converts non-null T to String
//
//   const DropdownSelector({
//     super.key,
//     required this.label,
//     this.emptyItem,
//     required this.items,
//     this.hint,
//     this.initialValue,
//     required this.onChanged,
//     this.padding,
//     required this.itemAsString,
//   });
//
//   @override
//   _DropdownSelectorState<T> createState() => _DropdownSelectorState<T>();
// }
//
// class _DropdownSelectorState<T> extends State<DropdownSelector<T>> {
//   T? _selectedValue;
//   // Add TextEditingController for DropdownMenu display
//   late final TextEditingController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedValue = widget.initialValue;
//     // Initialize controller text based on initial selection
//     _controller = TextEditingController(
//       text: _selectedValue == null
//           ? ''
//           : widget.itemAsString(
//               _selectedValue as T,
//             ), // Display "" or item string
//     );
//   }
//
//   @override
//   void didUpdateWidget(covariant DropdownSelector<T> oldWidget) {
//     // TODO: implement didUpdateWidget
//     super.didUpdateWidget(oldWidget);
//     setState(() {
//       _selectedValue = widget.initialValue;
//
//       _controller.text = _selectedValue == null
//           ? ''
//           : widget.itemAsString(
//               _selectedValue as T,
//             ); // Display "" or item string
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose(); // Dispose the controller
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final dropdownItemStyle = textTheme.labelMedium!.copyWith(
//       color: ColorManager.white,
//     );
//     final dropdownHintStyle = TextStyle(color: ColorManager.white);
//
//     return Padding(
//       // Keep overall padding
//       padding: widget.padding ?? EdgeInsets.zero,
//       // Replace DropdownButtonFormField with DropdownMenu
//       child: LayoutBuilder(builder: (context, constraints) {
//         return DropdownMenu<T?>(
//           width: constraints.maxWidth,
//           hintText: widget.hint,
//           expandedInsets: EdgeInsets.zero,
//           enableSearch: true,
//           searchCallback: (items, query) {
//             return null;
//           },
//           // Controller manages the text field's display
//           controller: _controller,
//           // Provide initial selection (DropdownMenu handles this internally too, but sync with controller)
//           initialSelection: _selectedValue,
//           // Label Widget
//           label: Text(
//             widget.label,
//             style: textTheme.labelLarge!.copyWith(
//               color: ColorManager.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           dropdownMenuEntries: <DropdownMenuEntry<T?>>[
//             ...widget.items.map<DropdownMenuEntry<T?>>((T item) {
//               return DropdownMenuEntry<T?>(
//                 value: item,
//                 labelWidget: SizedBox(
//                   width: constraints.maxWidth,
//                   child: Text(
//                     widget.itemAsString(item),
//                     style: dropdownHintStyle,
//                   ),
//                 ),
//                 label: widget.itemAsString(item), // Required label string
//                 // Optional: Use labelWidget if specific styling per item is needed
//                 // labelWidget: Text(widget.itemAsString(item), style: dropdownItemStyle),
//               );
//             }),
//           ],
//           // Callback when an item is selected
//           onSelected: (T? value) {
//             // Update internal state
//             setState(() {
//               _selectedValue = value;
//             });
//             widget.onChanged(value);
//           },
//
//           // Style the dropdown menu itself (background, text style for items)
//           menuStyle: MenuStyle(
//             backgroundColor: WidgetStatePropertyAll<Color>(ColorManager.dark2),
//           ),
//
//           // Style the text field part using InputDecorationTheme or directly
//           inputDecorationTheme: InputDecorationTheme(
//             border: OutlineInputBorder(),
//
//             floatingLabelBehavior: FloatingLabelBehavior.auto,
//
//             // You might need to customize filled, fillColor etc. based on design
//           ),
//
//           // The text style within the TextField part (controlled by controller)
//           textStyle:
//               dropdownItemStyle, // Use same style for selected item text?
//         );
//       }),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class DropdownSelector<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final String? emptyItem;
  final String? hint;
  final T? initialValue;
  final ValueChanged<T?> onChanged;
  final EdgeInsets? padding;
  final String Function(T item) itemAsString;

  // --- ADDED: Optional callbacks for item actions ---
  final ValueChanged<T>? onEditItem;
  final ValueChanged<T>? onDeleteItem;

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
    // --- ADDED: Add to constructor ---
    this.onEditItem,
    this.onDeleteItem,
  });

  @override
  _DropdownSelectorState<T> createState() => _DropdownSelectorState<T>();
}

class _DropdownSelectorState<T> extends State<DropdownSelector<T>> {
  T? _selectedValue;
  late final TextEditingController _controller;
  // Use a GlobalKey to programmatically control the menu's open/close state
  final GlobalKey _menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _controller = TextEditingController(
      text: _selectedValue == null
          ? ''
          : widget.itemAsString(_selectedValue as T),
    );
  }

  @override
  void didUpdateWidget(covariant DropdownSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _selectedValue = widget.initialValue;
        _controller.text = _selectedValue == null
            ? ''
            : widget.itemAsString(_selectedValue as T);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dropdownItemStyle =
        textTheme.labelMedium!.copyWith(color: ColorManager.white);

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: LayoutBuilder(builder: (context, constraints) {
        return DropdownMenu<T?>(
          key: _menuKey,
          width: constraints.maxWidth,
          hintText: widget.hint,
          expandedInsets: EdgeInsets.zero,
          controller: _controller,
          initialSelection: _selectedValue,
          label: Text(
            widget.label,
            style: textTheme.labelLarge!.copyWith(
              color: ColorManager.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          // --- UPDATED: Build custom entries ---
          dropdownMenuEntries:
              widget.items.map<DropdownMenuEntry<T?>>((T item) {
            return DropdownMenuEntry<T?>(
              value: item,
              // Use labelWidget to build a custom Row for each item
              labelWidget: SizedBox(
                width: constraints.maxWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Item text takes up available space
                    Expanded(
                      child: Text(
                        widget.itemAsString(item),
                        style: dropdownItemStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Conditionally add Edit button if callback is provided
                    if (widget.onEditItem != null)
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: ColorManager.grey, size: 20),
                        onPressed: () {
                          widget.onEditItem?.call(item);
                        },
                      ),
                    // Conditionally add Delete button if callback is provided
                    if (widget.onDeleteItem != null)
                      IconButton(
                        icon: Icon(Icons.delete_forever,
                            color: ColorManager.red, size: 20),
                        onPressed: () {
                          widget.onDeleteItem?.call(item);
                        },
                      ),
                  ],
                ),
              ),
              // Label is still required, but labelWidget is what's displayed
              label: widget.itemAsString(item),
            );
          }).toList(),
          onSelected: (T? value) {
            setState(() {
              _selectedValue = value;
            });
            widget.onChanged(value);
          },
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(ColorManager.dark2),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          textStyle: dropdownItemStyle,
        );
      }),
    );
  }
}
