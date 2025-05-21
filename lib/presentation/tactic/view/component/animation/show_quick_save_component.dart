import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/custom_text_field.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';

class ShowQuickSaveComponent extends ConsumerStatefulWidget {
  const ShowQuickSaveComponent({super.key});

  @override
  ConsumerState<ShowQuickSaveComponent> createState() =>
      _ShowQuickSaveComponentState();
}

class _ShowQuickSaveComponentState
    extends ConsumerState<ShowQuickSaveComponent> {
  final _newCollectionFormKey = GlobalKey<FormState>();

  TextEditingController _animationNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ap = ref.watch(animationProvider);
    final List<AnimationCollectionModel> collectionList =
        ap.animationCollections;
    final AnimationCollectionModel? selectedCollection =
        ap.selectedAnimationCollectionModel;
    final List<AnimationModel> animations = ap.animations;
    final AnimationModel? selectedAnimation = ap.selectedAnimationModel;

    return SizedBox(
      width: context.widthPercent(50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCollectionBox(
            collectionList: collectionList,
            selectedCollection: selectedCollection,
          ),
          _buildNewAnimationWidget(
            selectedAnimationCollectionModel: selectedCollection,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                borderRadius: 2,
                onTap: () {
                  ref.read(animationProvider.notifier).cancelQuickSave();
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
                onTap: () {
                  _submitNewAnimation();
                }, // Call separate submit method
                fillColor: ColorManager.blue,
                child: Text(
                  "Save",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: ColorManager.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionBox({
    required List<AnimationCollectionModel> collectionList,
    required AnimationCollectionModel? selectedCollection,
  }) {
    // Positioned container at the bottom for the selectors
    return Container(
      width: context.widthPercent(50),
      color: ColorManager.black, // Example
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 8,
      ), // Optional padding above dropdowns
      child: DropdownSelector<AnimationCollectionModel?>(
        label: "Select Collection",
        items: collectionList,
        initialValue: selectedCollection,
        onChanged: (s) {
          ref.read(animationProvider.notifier).selectAnimationCollection(s);
          zlog(data: "Collection Chosen ${s}");
        },
        itemAsString: (AnimationCollectionModel? item) {
          return item?.name ?? "";
        },
      ),
    );
  }

  Widget _buildNewAnimationWidget({
    required AnimationCollectionModel? selectedAnimationCollectionModel,
  }) {
    return Center(
      child: SizedBox(
        width: context.widthPercent(50),
        // Wrap content in a Form widget
        child: Form(
          key: _newCollectionFormKey, // Assign the key to the Form
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Animation Collection : ${selectedAnimationCollectionModel?.name ?? "Error"}",
                style: Theme.of(
                  context,
                ).textTheme.labelLarge!.copyWith(color: ColorManager.white),
              ),
              CustomTextFormField(
                // Use the controller from the State
                controller: _animationNameController,
                label: "New Animation Name....",
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
            ],
          ),
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
      AnimationItemModel? selectedAnimation =
          ref.read(animationProvider).selectedScene;
      ref
          .read(animationProvider.notifier)
          .createNewAnimation(
            newCollectionName,
            dummyAnimationPassed: selectedAnimation,
          );
    } else {
      // Form is invalid, validation errors will be displayed automatically
      zlog(data: "Form is invalid.");
    }
  }
}
