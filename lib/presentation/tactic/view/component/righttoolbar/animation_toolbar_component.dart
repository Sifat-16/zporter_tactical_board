import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/core/dialogs/animation_copy_dialog.dart';
import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view/animation/default_animation_constants.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/animation/animation_toolbar/animation_list_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/animation/animation_toolbar/animation_scene_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/mixin/animation_playback_mixin.dart';
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

    return Container(
      child: Column(
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
      ),
    );
  }

  Widget _buildPlayAnimationWidget({required AnimationModel animationModel}) {
    return Column(
      // spacing: 10, // Column doesn't have spacing, use SizedBox
      children: [
        GestureDetector(
          onTap: () {
            ref
                .read(boardProvider.notifier)
                .toggleAnimating(animatingObj: AnimatingObj.animate());
          },
          child: Icon(
            Icons.play_circle_outline,
            color: ColorManager.white,
          ),
        ),
        SizedBox(height: 10),
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
              onTap: () {
                BotToast.showText(text: "Animation saved");
                ref.read(animationProvider.notifier).clearAnimation();
              },
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
                    try {
                      animationCreateItem?.items = ref
                              .read(animationProvider)
                              .selectedScene
                              ?.components ??
                          [];
                    } catch (e) {}

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
    final List<AnimationCollectionModel> collectionList =
        ap.animationCollections;
    final AnimationCollectionModel? selectedCollection =
        ap.selectedAnimationCollectionModel;
    return ReorderableListView.builder(
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
              data: "More options tapped for: ${animation.name}",
            );
          },
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        ref
            .read(animationProvider.notifier)
            .reorderAnimations(oldIndex, newIndex);
      },
    );
  }

  // --- UPDATED METHOD ---
  Widget _buildAnimationSceneList({required AnimationState ap}) {
    final scenes = ap.selectedAnimationModel?.animationScenes ?? [];

    // Ensure scenes are always sorted by index before displaying
    scenes.sort((a, b) => a.index.compareTo(b.index));

    zlog(
      data:
          "Detected animation scene changes ${scenes.map((a) => a.sceneDuration.inMilliseconds).toList()}",
    );

    return Theme(
      data: ThemeData(canvasColor: ColorManager.yellow.withValues(alpha: 0.4)),
      child: ReorderableListView.builder(
        itemCount: scenes.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorder: (oldIndex, newIndex) {
          print("Re-order happening in toolbar");
          ref.read(animationProvider.notifier).reorderScene(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final animationItemModel = scenes[index];
          final Color colorForThisField = ColorManager.grey;

          return AnimationSceneItem(
            key: ValueKey(
                animationItemModel.id), // Key is crucial for reordering
            animation: animationItemModel,
            sceneIndex: index + 1, // Pass the 1-based index for display
            isFirst: index == 0,
            isLast: index == scenes.length - 1,
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
            onMoveUp: () {
              ref
                  .read(animationProvider.notifier)
                  .moveScene(animationItemModel.id, moveUp: true);
            },
            onMoveDown: () {
              ref
                  .read(animationProvider.notifier)
                  .moveScene(animationItemModel.id, moveUp: false);
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
            // ADD a function call for the onDuplicate callback
            onDuplicate: () {
              ref
                  .read(animationProvider.notifier)
                  .duplicateScene(sceneId: animationItemModel.id);
            },
            // ADD a function call for the onInsertBlank callback
            onInsertBlank: () {
              ref
                  .read(animationProvider.notifier)
                  .insertNewBlankScene(afterSceneId: animationItemModel.id);
            },
          );
        },
      ),
    );
  }

  // Widget _buildCollectionBox({
  //   required List<AnimationCollectionModel> collectionList,
  //   required AnimationCollectionModel? selectedCollection,
  // }) {
  //   return Align(
  //     alignment: Alignment.bottomCenter,
  //     child: Container(
  //       color: ColorManager.transparent,
  //       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
  //       child: Column(
  //         children: [
  //           DropdownSelector<AnimationCollectionModel?>(
  //             key: UniqueKey(),
  //             label: "Collection",
  //             hint: "Select Collection",
  //             items: collectionList,
  //             initialValue: selectedCollection,
  //             onChanged: (s) {
  //               ref
  //                   .read(animationProvider.notifier)
  //                   .selectAnimationCollection(s, changeSelectedScene: false);
  //               zlog(data: "Collection Chosen ${s?.name}");
  //             },
  //             itemAsString: (AnimationCollectionModel? item) {
  //               return item?.name ?? "";
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCollectionBox({
    required List<AnimationCollectionModel> collectionList,
    required AnimationCollectionModel? selectedCollection,
  }) {
    // This dialog can be reused from your input dialogs file
    Future<String?> showEditCollectionDialog(String initialValue) async {
      return await showNewCollectionInputDialog(
        context,
        collectionList.map((c) => c.name.toLowerCase()).toList(),
        initialValue: initialValue,
      );
    }

    // // This is a standard confirmation dialog
    // Future<bool?> showDeleteConfirmationDialog() async {
    //   return await showDialog<bool>(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       backgroundColor: ColorManager.dark2,
    //       title: Text("Confirm Deletion",
    //           style: TextStyle(color: ColorManager.white)),
    //       content: Text(
    //           "Are you sure you want to delete this collection and all of its animations? This action cannot be undone.",
    //           style: TextStyle(color: ColorManager.white)),
    //       actions: [
    //         TextButton(
    //             onPressed: () => Navigator.of(context).pop(false),
    //             child: Text("Cancel")),
    //         TextButton(
    //             onPressed: () => Navigator.of(context).pop(true),
    //             child:
    //                 Text("Delete", style: TextStyle(color: ColorManager.red))),
    //       ],
    //     ),
    //   );
    // }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: ColorManager.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: DropdownSelector<AnimationCollectionModel?>(
          key: UniqueKey(),
          label: "Collection",
          hint: "Select Collection",
          items: collectionList,
          initialValue: selectedCollection,
          onChanged: (s) {
            ref
                .read(animationProvider.notifier)
                .selectAnimationCollection(s, changeSelectedScene: false);
          },
          itemAsString: (AnimationCollectionModel? item) {
            return item?.name ?? "";
          },
          // --- ADDED: Provide the new callbacks here ---
          onEditItem: (collection) async {
            if (collection == null) return;
            // Prevent editing the default collection
            if (collection.id ==
                DefaultAnimationConstants.default_animation_collection_id) {
              BotToast.showText(
                  text: "The default collection cannot be modified.");
              return;
            }
            final newName = await showEditCollectionDialog(collection.name);
            if (newName != null && newName.isNotEmpty) {
              ref.read(animationProvider.notifier).editCollectionName(
                    collection: collection,
                    newName: newName,
                  );
            }
          },
          onDeleteItem: (collection) async {
            if (collection == null) return;
            // Prevent deleting the default collection
            if (collection.id ==
                DefaultAnimationConstants.default_animation_collection_id) {
              BotToast.showText(
                  text: "The default collection cannot be modified.");
              return;
            }
            final confirm = await showConfirmationDialog(
              context: context,
              confirmButtonColor: ColorManager.red,
              confirmButtonText: "Delete",
              title: "Confirm Deletion",
              content:
                  "Are you sure you want to delete this collection and all of its animations? This action cannot be undone.",
            );
            if (confirm == true) {
              ref.read(animationProvider.notifier).deleteCollection(
                    collectionToDelete: collection,
                  );
            }
          },
        ),
      ),
    );
  }

  Widget _buildAnimationBox({
    required List<AnimationModel> animationList,
    required AnimationModel? selectedAnimation,
    required List<AnimationCollectionModel> collectionList,
    required AnimationCollectionModel? selectedCollection,
    required AnimationToolbarConfig config,
  }) {
    if (selectedCollection == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: ColorManager.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: DropdownSelector<AnimationModel>(
          key: UniqueKey(),
          label: "Select Animation",
          items: animationList,
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
