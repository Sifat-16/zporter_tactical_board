import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/animation/animation_toolbar/animation_list_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart';

class AnimationToolbarComponent extends ConsumerStatefulWidget {
  const AnimationToolbarComponent({super.key});

  @override
  ConsumerState<AnimationToolbarComponent> createState() =>
      _AnimationToolbarComponentState();
}

class _AnimationToolbarComponentState
    extends ConsumerState<AnimationToolbarComponent>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      if (ref.read(animationProvider).animationCollections.isEmpty) {
        ref.read(animationProvider.notifier).getAllCollections();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ap = ref.watch(animationProvider);

    // --- Estimate or determine the height needed for the bottom selectors ---
    // This is the trickiest part of this method. You might need to adjust this value.
    // Consider font sizes, padding, and the intrinsic height of DropdownSelector.
    // Let's estimate ~70-80px per dropdown including padding.
    const double bottomSelectorAreaHeight =
        160.0; // Adjust this value as needed

    return Stack(
      children: [
        // ListView takes up the whole stack area, but with bottom padding
        // so content doesn't go under the positioned selectors
        Padding(
          // Apply padding only at the bottom of the ListView area
          padding: const EdgeInsets.only(bottom: bottomSelectorAreaHeight),
          child:
              ap.selectedAnimationModel == null
                  ? _buildAnimationList(ap: ap)
                  : ListView.builder(
                    itemCount: 100,
                    // No shrinkWrap or special physics needed here
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        child: Text(
                          "Hello $index", // Added index
                          style: TextStyle(color: ColorManager.white),
                        ),
                      );
                    },
                  ),
        ),

        _buildCollectionBox(ap: ap),
      ],
    );
  }

  // In your file containing _buildAnimationList

  // --- Updated _buildAnimationList Method ---

  Widget _buildAnimationList({required AnimationState ap}) {
    return ListView.builder(
      itemCount: ap.animations.length,
      itemBuilder: (context, index) {
        final animation = ap.animations[index];
        // // Calculate display index (e.g., starting from 1)
        // final String displayIndexString = "${index + 1}";
        // Determine field color if needed
        final Color colorForThisField =
            ColorManager.grey; // Default or from animation

        // Return the new dedicated widget instance
        return AnimationListItem(
          key: ValueKey(
            animation.id,
          ), // Use a unique key if list items can change/reorder
          animation: animation,

          onTap: () {
            ref.read(animationProvider.notifier).selectAnimation(animation);
          },

          fieldColor: colorForThisField,
          onCopy: () {
            zlog(data: "Copy tapped for: ${animation.name ?? animation.id}");
            // TODO: Implement actual copy logic (e.g., call notifier)
          },
          onOpen: () {
            zlog(data: "Open tapped for: ${animation.name ?? animation.id}");
            // TODO: Implement actual open logic (e.g., select animation via notifier)
            ref.read(animationProvider.notifier).selectAnimation(animation);
          },
          onMoreOptions: () {
            zlog(
              data:
                  "More options tapped for: ${animation.name ?? animation.id}",
            );
            // TODO: Implement more options logic (e.g., show menu/dialog)
          },
        );
      },
    );
  }

  Widget _buildCollectionBox({required AnimationState ap}) {
    // Positioned container at the bottom for the selectors

    return Align(
      alignment: Alignment.bottomCenter,
      child:
          ap.isLoadingAnimationCollections
              ? Center(child: CircularProgressIndicator())
              : Container(
                // Add background color so list doesn't show through
                // Use your app's background color or a specific one
                color: ColorManager.black, // Example
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8,
                ), // Optional padding above dropdowns
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Take only needed height
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownSelector<AnimationCollectionModel?>(
                            key: UniqueKey(),
                            label: "Collection",
                            emptyItem: "Add new Collection",
                            items: ap.animationCollections,
                            initialValue: ap.selectedAnimationCollectionModel,
                            onChanged: (s) {
                              ref
                                  .read(animationProvider.notifier)
                                  .selectAnimationCollection(s);
                              zlog(data: "Collection Chosen ${s}");
                            },
                            itemAsString: (AnimationCollectionModel? item) {
                              return item?.name ?? "";
                            },
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownSelector<AnimationModel>(
                            key: UniqueKey(),
                            label: "Animation",
                            emptyItem: "Add new Animation",
                            items: ap.animations,
                            initialValue: ap.selectedAnimationModel,
                            onChanged: (s) {
                              ref
                                  .read(animationProvider.notifier)
                                  .selectAnimation(s);
                              zlog(data: "Animation Chosen ${s}");
                            },
                            itemAsString: (AnimationModel? item) {
                              return item?.name ?? "";
                            },
                          ),
                        ),
                      ],
                    ),

                    CustomButton(
                      fillColor: ColorManager.blue,
                      borderRadius: 3,
                      height: 50,
                      child: Text(
                        "New",
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(color: ColorManager.white),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
