import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmButtonText = 'Confirm',
  String cancelButtonText = 'Cancel',

  /// Optional: Pass a specific ColorManager color (e.g., ColorManager.red) for the confirm button.
  Color? confirmButtonColor,

  /// Optional: Display an icon above the title.
  Widget? icon,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible:
        true, // Allow dismissal by tapping outside (returns null)
    builder: (BuildContext dialogContext) {
      // --- Use colors from ColorManager ---
      final Color dialogBgColor =
          ColorManager.dark1; // Surface color for dialog
      final Color primaryAccentColor =
          ColorManager.blue; // Default confirm button color
      final Color mainTextColor = ColorManager.white; // Main text color
      final Color subtleTextColor =
          ColorManager.grey; // Dimmer text (content, cancel button)
      final Color defaultIconColor = ColorManager.grey;

      // Determine confirm button background color
      final Color actualConfirmButtonColor =
          confirmButtonColor ?? primaryAccentColor;
      // Determine text color for confirm button based on its background brightness
      final Color confirmButtonTextColor =
          ThemeData.estimateBrightnessForColor(actualConfirmButtonColor) ==
                  Brightness.dark
              ? ColorManager
                  .white // Use white text on dark button backgrounds
              : ColorManager
                  .black; // Use black text on light button backgrounds

      return Theme(
        // Override theme specifically for this dialog using ColorManager colors
        data: ThemeData.dark().copyWith(
          // Start with dark defaults
          dialogBackgroundColor: dialogBgColor,
          colorScheme: ThemeData.dark().colorScheme.copyWith(
            primary: actualConfirmButtonColor, // Affects ElevatedButton bg
            surface: dialogBgColor, // Dialog background
            onSurface: mainTextColor, // Default text (like title)
            onPrimary: confirmButtonTextColor, // Text ON confirm button
            secondary: subtleTextColor, // Affects TextButton text color
          ),
          // Style buttons
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: subtleTextColor, // Use grey for cancel text
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: confirmButtonTextColor, // Text ON confirm button
              backgroundColor:
                  actualConfirmButtonColor, // Confirm button background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          iconTheme: IconThemeData(
            color: defaultIconColor,
          ), // Default icon color
        ),
        // Use AlertDialog for standard structure
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: dialogBgColor, // Explicitly set background
          iconPadding: const EdgeInsets.only(top: 24.0),
          icon: icon, // Use passed icon widget directly
          titlePadding: const EdgeInsets.only(
            top: 16.0,
            left: 24.0,
            right: 24.0,
          ),
          title: Text(
            title,
            textAlign: TextAlign.left,
            // Inherits onSurface color (white) from theme, applies specific weight/size
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: ColorManager.white,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24.0,
            16.0,
            24.0,
            24.0,
          ), // Increased bottom padding
          content: Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ColorManager.grey,
              fontSize: 14,
            ), // Explicitly use grey
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            // Cancel Button (uses TextButtonTheme -> grey text)
            TextButton(
              child: Text(cancelButtonText),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Return false
              },
            ),
            // Confirm Button (uses ElevatedButtonTheme -> primary/custom bg, contrast text)
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Return true
              },
              child: Text(confirmButtonText),
            ),
          ],
        ),
      );
    },
  );
}
