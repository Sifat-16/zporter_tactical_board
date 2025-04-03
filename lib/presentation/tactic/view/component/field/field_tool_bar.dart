import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';

class FieldToolBar extends ConsumerStatefulWidget {
  const FieldToolBar({
    super.key,
    required this.selectedCollection,
    required this.selectedAnimation,
    required this.selectedScene,
  });

  final AnimationCollectionModel? selectedCollection;
  final AnimationModel? selectedAnimation;
  final AnimationItemModel? selectedScene;

  @override
  ConsumerState<FieldToolBar> createState() => _FieldToolBarState();
}

class _FieldToolBarState extends ConsumerState<FieldToolBar> {
  @override
  Widget build(BuildContext context) {
    zlog(
      data:
          "Animation scene updated {widget.selectedScene?.componentHistory.length}",
    );
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: FaIcon(
                    FontAwesomeIcons.arrowsUpDownLeftRight,
                    color: ColorManager.grey,
                  ),
                ),

                // IconButton(
                //   onPressed: () {},
                //   icon: FaIcon(FontAwesomeIcons.plus, color: ColorManager.grey),
                // ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.rotate_left, color: ColorManager.grey),
                ),

                if (widget.selectedScene?.canUndo == true)
                  IconButton(
                    onPressed: () {
                      ref
                          .read(animationProvider.notifier)
                          .performUndoOperation();
                    },
                    icon: Icon(Icons.undo, color: ColorManager.green),
                  ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.threed_rotation, color: ColorManager.grey),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.share, color: ColorManager.grey),
                ),
              ],
            ),
          ),

          SizedBox(width: AppSize.s32),

          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  onTap: () {
                    if (widget.selectedCollection == null ||
                        widget.selectedAnimation == null) {
                      // no collection or animation is chosen, so show a overlay to add or select item

                      ref.read(animationProvider.notifier).showQuickSave();

                      // showDialog(
                      //   context: context,
                      //   builder: (context) {
                      //     return AlertDialog(
                      //       backgroundColor: ColorManager.dark2,
                      //       content: Center(child: ShowQuickSaveComponent()),
                      //     );
                      //   },
                      // );
                    } else {
                      try {
                        ref
                            .read(animationProvider.notifier)
                            .addNewScene(
                              selectedCollection: widget.selectedCollection!,
                              selectedAnimation: widget.selectedAnimation!,
                              selectedScene: widget.selectedScene!,
                            );
                      } catch (e) {
                        BotToast.showText(text: "Error $e !!!");
                      }
                    }
                  },
                  fillColor: ColorManager.blue,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  borderRadius: 3,
                  child: Text(
                    "Add New Scene",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: ColorManager.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // CustomButton(
                //   onTap: () {
                //     // ref
                //     //     .read(animationProvider.notifier)
                //     //     .onAnimationSave(
                //     //       selectedCollection: selectedCollection,
                //     //       selectedAnimation: selectedAnimation,
                //     //       selectedScene: selectedScene,
                //     //     );
                //     // context.read<BoardBloc>().add(SaveToAnimationEvent());
                //     // AnimationDataModel animationDataModel = AnimationDataModel(id: ObjectId(), items: globalAnimations);
                //     // context.read<AnimationBloc>().add(AnimationDatabaseSaveEvent(animationDataModel: animationDataModel));
                //   },
                //   fillColor: ColorManager.blue,
                //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                //   borderRadius: 3,
                //   child: Text(
                //     "Save to animation",
                //     style: Theme.of(context).textTheme.labelLarge!.copyWith(
                //       color: ColorManager.white,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
