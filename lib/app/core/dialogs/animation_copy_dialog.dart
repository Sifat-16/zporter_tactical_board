import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';

class AnimationCopyItem {
  AnimationCollectionModel animationCollectionModel;
  AnimationModel animationModel;
  String newAnimationName;

  AnimationCopyItem({
    required this.animationModel,
    required this.animationCollectionModel,
    required this.newAnimationName,
  });
}

Future<AnimationCopyItem?> showAnimationCopyDialog(
  BuildContext context, {
  required String title,
  String? initialValue,
  String hintText = 'Enter name...', // Default hint text
  String buttonText = 'OK', // Default button text
  required List<AnimationCollectionModel> collectionList,
  required AnimationCollectionModel? selectedCollection,
  required AnimationModel animation,
}) {
  TextEditingController _controller = TextEditingController(text: initialValue);

  return showDialog<AnimationCopyItem>(
    context: context,
    barrierDismissible: true, // Allow dismissing by tapping outside
    builder: (BuildContext dialogContext) {
      final Color dialogBgColor =
          ColorManager.black; // Surface color for dialog
      final Color primaryAccentColor =
          ColorManager.blue; // Default confirm button color
      final Color mainTextColor = ColorManager.white; // Main text color
      final Color subtleTextColor =
          ColorManager.grey; // Dimmer text (content, cancel button)
      final Color defaultIconColor = ColorManager.grey;

      // Determine confirm button background color
      final Color actualConfirmButtonColor = primaryAccentColor;
      // Determine text color for confirm button based on its background brightness
      final Color confirmButtonTextColor = ThemeData.estimateBrightnessForColor(
                  actualConfirmButtonColor) ==
              Brightness.dark
          ? ColorManager.white // Use white text on dark button backgrounds
          : ColorManager.black; // Use black text on light button backgrounds
      return Theme(
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
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          backgroundColor: dialogBgColor,
          iconPadding: const EdgeInsets.only(top: 24.0),
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

          content: SizedBox(
            width: context.widthPercent(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                DropdownSelector<AnimationCollectionModel?>(
                  key: UniqueKey(),
                  label: "Collection",
                  items: collectionList,
                  initialValue: selectedCollection,
                  onChanged: (s) {
                    selectedCollection = s;
                  },
                  itemAsString: (AnimationCollectionModel? item) {
                    return item?.name ?? "";
                  },
                ),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    label: Text("Animation"),
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10,
                  children: [
                    CustomButton(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      borderRadius: 2,
                      fillColor: ColorManager.dark1,
                      child: Text("Cancel"),
                      onTap: () {
                        Navigator.of(context).pop(null); // Return false
                      },
                    ),
                    // Confirm Button (uses ElevatedButtonTheme -> primary/custom bg, contrast text)
                    CustomButton(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      borderRadius: 2,
                      fillColor: ColorManager.blue,
                      onTap: () {
                        if (selectedCollection != null) {
                          AnimationCopyItem animationCopyItem =
                              AnimationCopyItem(
                            animationModel: animation,
                            animationCollectionModel: selectedCollection!,
                            newAnimationName: _controller.text.trim(),
                          );
                          Navigator.of(
                            context,
                          ).pop(animationCopyItem); // Return true
                        } else {
                          BotToast.showText(text: "Invalid Collection");
                          Navigator.of(context).pop(null); // Return true
                        }
                      },
                      child: Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- End ConstrainedBox wrapper ---
        ),
      );
    },
  );
}
