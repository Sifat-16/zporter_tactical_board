import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/custom_text_field.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';

Future<String?> showNewCollectionInputDialog(
  BuildContext context,
  List<String> collectionNameExists,
) {
  TextEditingController _controller = TextEditingController();
  final _newCollectionFormKey = GlobalKey<FormState>();
  return showDialog<String>(
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

          titlePadding: const EdgeInsets.only(
            top: 16.0,
            left: 24.0,
            right: 24.0,
          ),
          title: Text(
            "New Collection",
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

          content: Form(
            key: _newCollectionFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                CustomTextFormField(
                  // Use the controller from the State
                  controller: _controller,
                  label: "Collection",
                  hintText: "Write collection name...",
                  textInputAction:
                      TextInputAction.done, // Set appropriate action
                  // Add the validator
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a collection name.'; // Error message
                    } else if (value.isNotEmpty &&
                        collectionNameExists.contains(
                          value.trim().toLowerCase(),
                        )) {
                      return 'This name is already taken';
                    }
                    return null; // Return null if valid
                  },
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
                        if (_newCollectionFormKey.currentState?.validate() ??
                            false) {
                          Navigator.of(context).pop(_controller.text.trim());
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

class AnimationCreateItem {
  AnimationCollectionModel animationCollectionModel;
  String newAnimationName;
  List<FieldItemModel> items;

  AnimationCreateItem({
    required this.animationCollectionModel,
    required this.newAnimationName,
    this.items = const [],
  });
}

Future<AnimationCreateItem?> showNewAnimationInputDialog(
  BuildContext context, {
  required List<AnimationCollectionModel> collectionList,
  required AnimationCollectionModel? selectedCollection,
}) {
  TextEditingController _controller = TextEditingController();
  final _newAnimationFormKey = GlobalKey<FormState>();
  return showDialog<AnimationCreateItem>(
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
            "New Animation",
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
            child: Form(
              key: _newAnimationFormKey,
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
                  CustomTextFormField(
                    // Use the controller from the State
                    controller: _controller,
                    label: "Animation",
                    hintText: "Write animation name...",
                    textInputAction:
                        TextInputAction.done, // Set appropriate action
                    // Add the validator
                    validator: (value) {
                      List<String> animationNames = (selectedCollection
                              ?.animations
                              .map((a) => a.name.toLowerCase())
                              .toList()) ??
                          [];
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an animation name.'; // Error message
                      } else if (value.isNotEmpty &&
                          animationNames.contains(value.trim().toLowerCase())) {
                        return 'This name is already taken';
                      }
                      return null; // Return null if valid
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 10,
                    children: [
                      CustomButton(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                        borderRadius: 2,
                        fillColor: ColorManager.dark1,
                        child: Text("Cancel"),
                        onTap: () {
                          Navigator.of(context).pop(null); // Return false
                        },
                      ),
                      // Confirm Button (uses ElevatedButtonTheme -> primary/custom bg, contrast text)
                      CustomButton(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                        borderRadius: 2,
                        fillColor: ColorManager.blue,
                        onTap: () {
                          if (_newAnimationFormKey.currentState?.validate() ??
                              false) {
                            if (selectedCollection != null) {
                              AnimationCreateItem animationCreateItem =
                                  AnimationCreateItem(
                                animationCollectionModel: selectedCollection!,
                                newAnimationName: _controller.text.trim(),
                              );
                              Navigator.of(
                                context,
                              ).pop(animationCreateItem); // Return true
                            }
                          }
                        },
                        child: Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
