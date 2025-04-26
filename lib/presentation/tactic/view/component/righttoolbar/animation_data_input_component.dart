import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/custom_text_field.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart';

class AnimationDataInputComponent extends ConsumerStatefulWidget {
  const AnimationDataInputComponent({super.key});

  @override
  ConsumerState<AnimationDataInputComponent> createState() =>
      _AnimationDataInputComponentState();
}

class _AnimationDataInputComponentState
    extends ConsumerState<AnimationDataInputComponent> {
  // Key for the "New Collection" form
  final _newCollectionFormKey = GlobalKey<FormState>();
  // Controller for the collection name input
  late TextEditingController _animationCollectionNameController;
  late TextEditingController _animationNameController;

  @override
  Widget build(BuildContext context) {
    final ap = ref.watch(animationProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (ap.showNewCollectionInput)
          _buildNewAnimationCollectionWidget()
        else
          _buildNewAnimationWidget(ap: ap),
      ],
    );
  }

  // --- UPDATED Method to build the "Add New Collection" section ---
  Widget _buildNewAnimationCollectionWidget() {
    _animationCollectionNameController = TextEditingController();
    // Now uses the controller and key from the State class
    return SizedBox(
      width: context.widthPercent(100),
      // Wrap content in a Form widget
      child: Form(
        key: _newCollectionFormKey, // Assign the key to the Form
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextFormField(
              // Use the controller from the State
              controller: _animationCollectionNameController,
              label: "Collection Name....",
              textInputAction: TextInputAction.done, // Set appropriate action
              // Add the validator
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a collection name.'; // Error message
                }
                return null; // Return null if valid
              },
              // Optional: Submit form when 'done' action is pressed on keyboard
              onFieldSubmitted: (_) {
                _submitNewCollection();
              },
            ),
            const SizedBox(height: 20), // Add spacing
            SizedBox(
              width: context.widthPercent(20),
              child: Row(
                children: [
                  CustomButton(
                    borderRadius: 2,
                    onTap: () {
                      ref
                          .read(animationProvider.notifier)
                          .toggleNewCollectionInputShow(false);
                    }, // Call separate submit method
                    fillColor: ColorManager.red,
                    child: Text(
                      "Cancel",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: ColorManager.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(width: 10),
                  CustomButton(
                    borderRadius: 2,
                    onTap: _submitNewCollection, // Call separate submit method
                    fillColor: ColorManager.blue,
                    child: Text(
                      "Add new Collection",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: ColorManager.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper method to handle form submission ---
  void _submitNewCollection() {
    // Validate the form using the GlobalKey
    if (_newCollectionFormKey.currentState?.validate() ?? false) {
      // If the form is valid:
      final newCollectionName = _animationCollectionNameController.text.trim();
      zlog(data: "Form is valid. Adding collection: $newCollectionName");

      // TODO: Call your Riverpod notifier method to actually create
      //       and select the new collection. Example:
      ref
          .read(animationProvider.notifier)
          .createNewCollection(newCollectionName);

      // Optionally clear the text field after submission
      // _animationCollectionNameController.clear();

      // Optional: Hide keyboard
      // FocusScope.of(context).unfocus();
    } else {
      // Form is invalid, validation errors will be displayed automatically
      zlog(data: "Form is invalid.");
    }
  }

  Widget _buildNewAnimationWidget({required AnimationState ap}) {
    _animationNameController = TextEditingController();
    // Now uses the controller and key from the State class
    return Container(
      width: context.widthPercent(100),
      // Wrap content in a Form widget
      child: Form(
        key: _newCollectionFormKey, // Assign the key to the Form
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Animation Collection : ${ap.selectedAnimationCollectionModel?.name ?? "Error"}",
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: ColorManager.white),
            ),
            CustomTextFormField(
              // Use the controller from the State
              controller: _animationNameController,
              label: "Animation Name....",
              textInputAction: TextInputAction.done, // Set appropriate action
              // Add the validator
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a Animation Name.'; // Error message
                }
                return null; // Return null if valid
              },
              // Optional: Submit form when 'done' action is pressed on keyboard
              onFieldSubmitted: (_) {
                _submitNewAnimation();
              },
            ),
            const SizedBox(height: 20), // Add spacing
            SizedBox(
              width: context.widthPercent(20),

              child: Row(
                children: [
                  CustomButton(
                    borderRadius: 2,
                    onTap: () {
                      ref
                          .read(animationProvider.notifier)
                          .toggleNewAnimationInputShow(false);
                    }, // Call separate submit method
                    fillColor: ColorManager.red,
                    child: Text(
                      "Cancel",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: ColorManager.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(width: 10),
                  CustomButton(
                    borderRadius: 2,
                    onTap: _submitNewAnimation, // Call separate submit method
                    fillColor: ColorManager.blue,
                    child: Text(
                      "Add new Animation",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: ColorManager.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper method to handle form submission ---
  void _submitNewAnimation() {
    // Validate the form using the GlobalKey
    if (_newCollectionFormKey.currentState?.validate() ?? false) {
      // If the form is valid:
      final newCollectionName = _animationNameController.text.trim();
      zlog(data: "Form is valid. Adding collection: $newCollectionName");

      // TODO: Call your Riverpod notifier method to actually create
      //       and select the new collection. Example:
      ref
          .read(animationProvider.notifier)
          .createNewAnimation(newCollectionName);
    } else {
      // Form is invalid, validation errors will be displayed automatically
      zlog(data: "Form is invalid.");
    }
  }
}
