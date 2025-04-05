import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

Future<String?> showInputDialog(
  BuildContext context, {
  required String title,
  String? initialValue,
  String hintText = 'Enter name...', // Default hint text
  String buttonText = 'OK', // Default button text
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true, // Allow dismissing by tapping outside
    builder: (BuildContext dialogContext) {
      // --- Define Dark Theme Colors ---
      final darkBackgroundColor = ColorManager.dark3; // Dark grey
      final primaryColor =
          Colors.blueAccent[100]; // Light blue accent for dark bg
      final hintColor = Colors.grey[500];
      final outlineColor = Colors.grey[700];
      final textColor = Colors.white; // Primary text color

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Rounded corners
        ),
        elevation: 8,
        backgroundColor: darkBackgroundColor, // Set explicit dark background
        // --- Wrap content with ConstrainedBox to limit width ---
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350), // ADJUST THIS VALUE
          child: Theme(
            // Override theme for the content
            data: ThemeData.dark().copyWith(
              // Start with dark theme defaults
              dialogBackgroundColor:
                  darkBackgroundColor, // Consistent background
              colorScheme: ThemeData.dark().colorScheme.copyWith(
                primary: primaryColor, // Button background, focus highlight
                secondary: primaryColor, // Used by some widgets
                surface:
                    darkBackgroundColor, // Background of elements like TextField
                onSurface: textColor, // Default text color
                outline: outlineColor, // Border color
                onPrimary:
                    Colors
                        .black, // Text on primary color button (adjust if needed)
              ),
              inputDecorationTheme: InputDecorationTheme(
                // Style text fields globally within this theme
                hintStyle: TextStyle(color: hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: outlineColor ?? Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: primaryColor ?? Colors.blue,
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              textTheme: ThemeData.dark().textTheme.apply(
                // Ensure text colors are suitable
                bodyColor: textColor,
                displayColor: textColor,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, // Text on button
                  backgroundColor: primaryColor, // Button background
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // Pass parameters down to the content widget
            child: _NameInputDialogContent(
              title: title,
              initialValue: initialValue,
              hintText: hintText,
              buttonText: buttonText,
            ),
          ),
        ),
        // --- End ConstrainedBox wrapper ---
      );
    },
  );
}

// _NameInputDialogContent widget remains the same as before
class _NameInputDialogContent extends StatefulWidget {
  // ... (constructor as before) ...
  final String title;
  final String? initialValue;
  final String hintText;
  final String buttonText;

  const _NameInputDialogContent({
    Key? key,
    required this.title,
    this.initialValue,
    required this.hintText,
    required this.buttonText,
  }) : super(key: key);

  @override
  State<_NameInputDialogContent> createState() =>
      _NameInputDialogContentState();
}

class _NameInputDialogContentState extends State<_NameInputDialogContent> {
  // ... (initState, dispose, _submit as before) ...
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Gets the dark theme context

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Let content fill constrained width
        children: <Widget>[
          // Title
          Text(
            widget.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),

          // TextField
          TextField(
            controller: _controller,
            autofocus: true,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(hintText: widget.hintText),
            onSubmitted: (_) => _submit(),
            textInputAction: TextInputAction.done,
            cursorColor: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24.0),

          CustomButton(
            onTap: _submit,
            child: Text(
              widget.buttonText,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: ColorManager.white),
            ),

            borderRadius: 4,
            fillColor: ColorManager.blue,
          ),
        ],
      ),
    );
  }
}
