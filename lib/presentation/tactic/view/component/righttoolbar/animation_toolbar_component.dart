import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/core/dialogs/animation_copy_dialog.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/animation/animation_toolbar/animation_list_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/animation/animation_toolbar/animation_scene_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

import 'animation_data_input_component.dart';

class AnimationToolbarConfig {
  final bool showCollectionSelector;
  final bool showAnimationSelector;
  final bool showAnimationList;
  final bool showBackToDefaultButton;
  final Function(AnimationItemModel)? onSceneDelete;

  const AnimationToolbarConfig({
    this.showCollectionSelector = true,
    this.showAnimationSelector = true,
    this.showAnimationList = true,
    this.showBackToDefaultButton = true,
    this.onSceneDelete,
  });

  static const animationListOnly = AnimationToolbarConfig(
    showCollectionSelector: false,
    showAnimationSelector: false,
    showBackToDefaultButton: false,
    showAnimationList: true,
  );
  static const full = AnimationToolbarConfig();
  static const listOnlyNoSelectors = AnimationToolbarConfig(
    showCollectionSelector: false,
    showAnimationSelector: false,
    showAnimationList: true,
    showBackToDefaultButton: false,
  );
}
// --- End of Configuration Class ---

class AnimationToolbarComponent extends ConsumerStatefulWidget {
  const AnimationToolbarComponent({
    super.key,
    this.config = const AnimationToolbarConfig(), // Add config parameter
  });

  final AnimationToolbarConfig config; // Store the config

  @override
  ConsumerState<AnimationToolbarComponent> createState() =>
      _AnimationToolbarComponentState();
}

class _AnimationToolbarComponentState
    extends ConsumerState<AnimationToolbarComponent>
    with AutomaticKeepAliveClientMixin {
  // Keep wantKeepAlive if needed for your use case

  @override
  void initState() {
    super.initState();
    // No changes needed in initState specifically for this config
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for AutomaticKeepAliveClientMixin
    final ap = ref.watch(animationProvider);
    final List<AnimationCollectionModel> collectionList =
        ap.animationCollections;
    final AnimationCollectionModel? selectedCollection =
        ap.selectedAnimationCollectionModel;
    final List<AnimationModel> animations =
        ap.animations; // Animations for the selected collection
    final AnimationModel? selectedAnimation = ap.selectedAnimationModel;

    // Access the config
    final config = widget.config;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (config
                    .showCollectionSelector) // Conditionally show Collection Box
                  _buildCollectionBox(
                    collectionList: collectionList,
                    selectedCollection: selectedCollection,
                  ),
                if (config
                    .showAnimationSelector) // Conditionally show Animation Box
                  _buildAnimationBox(
                    collectionList: collectionList,
                    animationList:
                        animations, // Pass animations for the selected collection
                    selectedAnimation: selectedAnimation,
                    selectedCollection:
                        selectedCollection, // Pass selectedCollection to decide if this box should show content
                    config:
                        config, // Pass config to control "Back to default" button visibility
                  ),
                if (config
                    .showAnimationList) // Conditionally show Animation/Scene List
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: selectedAnimation == null
                        ? _buildAnimationList(ap: ap)
                        : _buildAnimationSceneList(ap: ap),
                  ),
              ],
            ),
          ),
        ),
        if (config.showAnimationList)
          if (selectedAnimation == null)
            _buildAddAnimationCollectionPopup(
              collectionList: collectionList,
              selectedCollection: selectedCollection,
            )
          else
            _buildPlayAnimationWidget(animationModel: selectedAnimation),
      ],
    );
  }

  Widget _buildPlayAnimationWidget({required AnimationModel animationModel}) {
    return Column(
      spacing: 10,
      children: [
        GestureDetector(
          onTap: () {
            ref.read(boardProvider.notifier).toggleAnimating();
          },
          child: Icon(
            // Your original Icon
            Icons.play_circle_outline,
            color: ColorManager.white,
          ),
        ),
        // Builder(
        //   builder: (context) {
        //     final Object heroTag = 'anim_${animationModel.id.toString()}';
        //     return GestureDetector(
        //       onTap: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => AnimationScreen(
        //               animationModel: animationModel,
        //               heroTag: heroTag,
        //             ),
        //           ),
        //         );
        //       },
        //       child: Icon(
        //         // Your original Icon
        //         Icons.play_circle_outline,
        //         color: ColorManager.white,
        //       ),
        //     );
        //   },
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomButton(
              onTap: () {
                ref.read(animationProvider.notifier).clearAnimation();
              },
              fillColor: ColorManager.dark2,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              borderRadius: 3,
              child: Text(
                "Cancel",
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(color: ColorManager.white),
              ),
            ),
            CustomButton(
              fillColor: ColorManager.blue,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              borderRadius: 3,
              child: Text(
                "Save",
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(color: ColorManager.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddAnimationCollectionPopup({
    required List<AnimationCollectionModel> collectionList,
    required AnimationCollectionModel? selectedCollection,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, top: 4, bottom: 4),
        child: Theme(
          data: ThemeData(
            popupMenuTheme: PopupMenuThemeData(color: ColorManager.dark2),
          ),
          child: PopupMenuButton(
            child: CircleAvatar(
              radius: 15,
              backgroundColor: ColorManager.blue,
              child: Center(
                child: Icon(Icons.add, color: ColorManager.white, size: 15),
              ),
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () async {
                    String? newCollectionName =
                        await showNewCollectionInputDialog(
                      context,
                      collectionList.map((c) => c.name.toLowerCase()).toList(),
                    );
                    if (newCollectionName != null) {
                      ref
                          .read(animationProvider.notifier)
                          .createNewCollection(newCollectionName);
                    } else {
                      zlog(data: "Came empty collection name");
                    }
                  },
                  child: Text(
                    "New Collection",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: ColorManager.white,
                        ),
                  ),
                ),
                PopupMenuItem(
                  onTap: () async {
                    AnimationCreateItem? animationCreateItem =
                        await showNewAnimationInputDialog(
                      context,
                      collectionList: collectionList,
                      selectedCollection: selectedCollection,
                    );

                    if (animationCreateItem != null) {
                      ref.read(animationProvider.notifier).createNewAnimation(
                            newAnimation: animationCreateItem,
                          );
                    }
                  },
                  child: Text(
                    "New Animation",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: ColorManager.white,
                        ),
                  ),
                ),
              ];
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationList({required AnimationState ap}) {
    // No changes to the content of this method, visibility controlled by parent
    final List<AnimationCollectionModel> collectionList =
        ap.animationCollections;
    final AnimationCollectionModel? selectedCollection =
        ap.selectedAnimationCollectionModel;
    return ListView.builder(
      itemCount: ap.animations.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final animation = ap.animations[index];
        final Color colorForThisField = ColorManager.grey;

        return AnimationListItem(
          key: ValueKey(animation.id),
          animation: animation,
          onDelete: () {
            ref
                .read(animationProvider.notifier)
                .deleteAnimation(animation: animation);
          },
          fieldColor: colorForThisField,
          onCopy: () async {
            AnimationCopyItem? animationCopyItem =
                await showAnimationCopyDialog(
              context,
              title: "Copy Animation",
              initialValue: "${animation.name} copy",
              buttonText: "Copy",
              hintText: "${animation.name} copy",
              collectionList: collectionList,
              animation: animation,
              selectedCollection: selectedCollection,
            );
            if (animationCopyItem != null) {
              ref
                  .read(animationProvider.notifier)
                  .copyAnimation(animationCopyItem);
            }
          },
          onOpen: () {
            ref.read(animationProvider.notifier).selectAnimation(animation);
          },
          onMoreOptions: () {
            zlog(
              data:
                  "More options tapped for: ${animation.name ?? animation.id}",
            );
          },
        );
      },
    );
  }

  Widget _buildAnimationSceneList({required AnimationState ap}) {
    // No changes to the content of this method, visibility controlled by parent
    final scenes = ap.selectedAnimationModel?.animationScenes ?? [];

    zlog(
      data:
          "Detected animation scence changes ${scenes.map((a) => a.sceneDuration.inMilliseconds).toList()}",
    );

    return ListView.builder(
      itemCount: scenes.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final animationItemModel = scenes[index];
        final Color colorForThisField = ColorManager.grey;

        return AnimationSceneItem(
          key: ValueKey(animationItemModel.id),
          animation: animationItemModel,
          isSelected: ap.selectedScene?.id == animationItemModel.id,
          onItemTap: () {
            ref
                .read(animationProvider.notifier)
                .selectScene(scene: animationItemModel);
          },
          fieldColor: colorForThisField,
          onMoreOptions: () {
            // TODO: Implement more options logic
          },
          onDelete: () {
            if (widget.config.onSceneDelete == null) {
              ref
                  .read(animationProvider.notifier)
                  .deleteScene(scene: animationItemModel);
            } else {
              widget.config.onSceneDelete?.call(animationItemModel);
            }
          },
        );
      },
    );
  }

  Widget _buildCollectionBox({
    required List<AnimationCollectionModel> collectionList,
    required AnimationCollectionModel? selectedCollection,
  }) {
    // No changes to the content of this method, visibility controlled by parent
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: ColorManager.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: Column(
          children: [
            DropdownSelector<AnimationCollectionModel?>(
              key: UniqueKey(),
              label: "Collection",
              hint: "Select Collection",
              items: collectionList,
              initialValue: selectedCollection,
              onChanged: (s) {
                ref
                    .read(animationProvider.notifier)
                    .selectAnimationCollection(s, changeSelectedScene: false);
                zlog(data: "Collection Chosen ${s?.name}");
              },
              itemAsString: (AnimationCollectionModel? item) {
                return item?.name ?? "";
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationBox({
    required List<AnimationModel> animationList,
    required AnimationModel? selectedAnimation,
    required List<AnimationCollectionModel> collectionList,
    required AnimationCollectionModel? selectedCollection,
    required AnimationToolbarConfig config, // Receive config
  }) {
    if (selectedCollection == null) {
      return const SizedBox.shrink(); // Only show if a collection is selected
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: ColorManager.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: DropdownSelector<AnimationModel>(
          key: UniqueKey(),
          label: "Select Animation",
          items:
              animationList, // These are already filtered for the selected collection by the provider
          initialValue: selectedAnimation,
          onChanged: (s) {
            ref.read(animationProvider.notifier).selectAnimation(s);
            zlog(data: "Animation Chosen ${s?.name}");
          },
          itemAsString: (AnimationModel? item) {
            return item?.name ?? "";
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
