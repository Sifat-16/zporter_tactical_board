import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Make sure this path is correct

class CustomTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final int maxLines;
  final int? minLines;
  final bool enabled;
  final String? hintText; // Added hintText parameter

  const CustomTextFormField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.hintText, // Added hintText
  }) : assert(
         initialValue == null || controller == null,
         'Cannot provide both an initialValue and a controller.',
       );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Define styles based on the reference DropdownSelector's DropdownMenu
    final inputTextStyle = textTheme.labelMedium!.copyWith(
      color: ColorManager.white, // Text color inside the field
    );
    // Label style matching the reference (used for floating label)
    final labelStyle = textTheme.labelLarge!.copyWith(
      color: ColorManager.grey, // Color for the label when floating or idle
      fontWeight: FontWeight.bold,
    );
    // Style for the hint text
    final hintStyle = textTheme.labelMedium!.copyWith(
      color: ColorManager.grey.withOpacity(0.7),
    );

    // Define border colors (adjust as needed)
    final enabledBorderColor = ColorManager.grey.withOpacity(0.5);
    final focusedBorderColor =
        ColorManager.white; // Or Theme.of(context).primaryColor
    final disabledBorderColor = ColorManager.grey.withOpacity(0.3);
    final errorColor = Theme.of(context).colorScheme.error;

    const inputBorder = OutlineInputBorder(
      // Consistent border structure
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ), // Optional rounded corners
      // Default border side, will be overridden by specific states below
      borderSide: BorderSide(),
    );

    return Padding(
      // Keep overall padding like the reference widget
      padding: EdgeInsets.zero,
      child: TextFormField(
        // --- Pass standard TextFormField properties ---
        controller: controller,
        initialValue: initialValue,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
        onChanged: onChanged,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onFieldSubmitted,
        maxLines: maxLines,
        minLines: minLines,
        enabled: enabled,

        // --- Apply Styling ---
        style: inputTextStyle, // Style of the text entered by the user
        cursorColor: ColorManager.white, // Color of the cursor

        decoration: InputDecoration(
          // Label: uses labelStyle, floats above on focus/content
          label: Text(label, style: labelStyle),
          // Hint Text: Shown when empty and not focused (if label is floating)
          hintText: hintText,
          hintStyle: hintStyle,

          // Background Fill (optional, use colors from your manager)
          filled: true,
          fillColor: ColorManager.dark1.withOpacity(
            0.5,
          ), // Subtle dark background
          // Border Styling for different states
          border: inputBorder.copyWith(
            borderSide: BorderSide(color: enabledBorderColor),
          ),
          enabledBorder: inputBorder.copyWith(
            borderSide: BorderSide(color: enabledBorderColor),
          ),
          focusedBorder: inputBorder.copyWith(
            borderSide: BorderSide(
              color: focusedBorderColor,
              width: 1.5,
            ), // Highlight focus
          ),
          disabledBorder: inputBorder.copyWith(
            borderSide: BorderSide(color: disabledBorderColor),
          ),
          errorBorder: inputBorder.copyWith(
            borderSide: BorderSide(color: errorColor),
          ),
          focusedErrorBorder: inputBorder.copyWith(
            borderSide: BorderSide(
              color: errorColor,
              width: 1.5,
            ), // Highlight error focus
          ),

          // Internal padding within the text field border
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
        ),
      ),
    );
  }
}
