import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/core/dialogs/input_dialog.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/animation/animation_toolbar/animation_list_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/animation/animation_toolbar/animation_scene_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/animation_screen.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ap = ref.watch(animationProvider);
    final List<AnimationCollectionModel> collectionList =
        ap.animationCollections;
    final AnimationCollectionModel? selectedCollection =
        ap.selectedAnimationCollectionModel;
    final List<AnimationModel> animations = ap.animations;
    final AnimationModel? selectedAnimation = ap.selectedAnimationModel;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCollectionBox(
            collectionList: collectionList,
            selectedCollection: selectedCollection,
          ),

          _buildAnimationBox(
            animationList: animations,
            selectedAnimation: selectedAnimation,
            selectedCollection: selectedCollection,
          ),

          // ListView takes up the whole stack area, but with bottom padding
          // so content doesn't go under the positioned selectors
          Padding(
            // Apply padding only at the bottom of the ListView area
            padding: const EdgeInsets.only(bottom: 10),
            child:
                selectedAnimation == null
                    ? _buildAnimationList(ap: ap)
                    : _buildAnimationSceneList(ap: ap),
          ),
        ],
      ),
    );
  }

  // In your file containing _buildAnimationList

  // --- Updated _buildAnimationList Method ---

  Widget _buildAnimationList({required AnimationState ap}) {
    return ListView.builder(
      itemCount: ap.animations.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
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

          onDelete: () {
            ref
                .read(animationProvider.notifier)
                .deleteAnimation(animation: animation);
          },

          fieldColor: colorForThisField,

          onCopy: () async {
            zlog(data: "Copy tapped for: ${animation.name ?? animation.id}");
            // TODO: Implement actual copy logic (e.g., call notifier)
            String? name = await showInputDialog(
              context,
              title: "Enter animation name",
              initialValue: "${animation.name} copy",
              buttonText: "Copy",
              hintText: "${animation.name} copy",
            );
            if (name != null) {
              ref
                  .read(animationProvider.notifier)
                  .copyAnimation(name, animation);
            }
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

  Widget _buildAnimationSceneList({required AnimationState ap}) {
    return ListView.builder(
      itemCount: ap.selectedAnimationModel?.animationScenes.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final animationItemModel =
            ap.selectedAnimationModel?.animationScenes[index];
        // // Calculate display index (e.g., starting from 1)
        // final String displayIndexString = "${index + 1}";
        // Determine field color if needed
        final Color colorForThisField =
            ColorManager.grey; // Default or from animation

        // Return the new dedicated widget instance
        if (animationItemModel == null) {
          return SizedBox();
        }
        return AnimationSceneItem(
          key: ValueKey(
            animationItemModel.id,
          ), // Use a unique key if list items can change/reorder
          animation: animationItemModel,
          isSelected: ap.selectedScene?.id == animationItemModel.id,
          onItemTap: () {
            ref
                .read(animationProvider.notifier)
                .selectScene(scene: animationItemModel);
          },
          fieldColor: colorForThisField,
          onMoreOptions: () {
            // TODO: Implement more options logic (e.g., show menu/dialog)
          },

          onDelete: () {
            ref
                .read(animationProvider.notifier)
                .deleteScene(scene: animationItemModel);
          },
        );
      },
    );
  }

  Widget _buildCollectionBox({
    required List<AnimationCollectionModel> collectionList,
    required AnimationCollectionModel? selectedCollection,
  }) {
    // Positioned container at the bottom for the selectors

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        // Add background color so list doesn't show through
        // Use your app's background color or a specific one
        color: ColorManager.black, // Example
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 8,
        ), // Optional padding above dropdowns
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Collection",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: ColorManager.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(animationProvider.notifier)
                        .toggleNewCollectionInputShow(true);
                  },
                  child: Text(
                    "+ New Collection",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: ColorManager.green,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: DropdownSelector<AnimationCollectionModel?>(
                    key: UniqueKey(),

                    label: "Select Collection",
                    // emptyItem: "Add new Collection",
                    items: collectionList,
                    initialValue: selectedCollection,
                    onChanged: (s) {
                      ref
                          .read(animationProvider.notifier)
                          .selectAnimationCollection(
                            s,
                            changeSelectedScene: false,
                          );
                      zlog(data: "Collection Chosen ${s}");
                    },
                    itemAsString: (AnimationCollectionModel? item) {
                      return item?.name ?? "";
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationBox({
    required List<AnimationModel> animationList,
    required AnimationModel? selectedAnimation,
    required AnimationCollectionModel? selectedCollection,
  }) {
    // Positioned container at the bottom for the selectors

    if (selectedCollection == null) return SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
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
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Animation",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: ColorManager.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(animationProvider.notifier)
                            .toggleNewAnimationInputShow(true);
                      },

                      child: Text(
                        "+ New Animation",
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(color: ColorManager.green),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownSelector<AnimationModel>(
                        key: UniqueKey(),
                        label: "Select Animation",
                        items: animationList,
                        initialValue: selectedAnimation,
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
              ],
            ),

            if (selectedAnimation != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) {
                      final Object heroTag =
                          'anim_${selectedAnimation.id.toString()}';
                      return IconButton(
                        onPressed: () {
                          AnimationModel? animationModel = selectedAnimation;
                          Navigator.push(
                            context,
                            // Use MaterialPageRoute for standard transitions, or PageRouteBuilder for custom ones
                            MaterialPageRoute(
                              builder:
                                  (context) => AnimationScreen(
                                    // Pass the necessary data AND the hero tag
                                    animationModel: animationModel,
                                    heroTag: heroTag, // Pass the SAME tag
                                  ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.play_circle_outline,
                          color: ColorManager.green,
                        ),
                      );
                    },
                  ),
                  CustomButton(
                    onTap: () {
                      ref.read(animationProvider.notifier).clearAnimation();
                    },
                    fillColor: ColorManager.blue,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    borderRadius: 3,
                    child: Text(
                      "Back to default",
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
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
