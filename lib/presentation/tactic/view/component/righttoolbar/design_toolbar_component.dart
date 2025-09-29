// import 'package:flame/components.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:zporter_tactical_board/app/core/component/color_picker_slider.dart';
// import 'package:zporter_tactical_board/app/core/component/custom_slider.dart';
// import 'package:zporter_tactical_board/app/core/component/opacity_slider.dart';
// import 'package:zporter_tactical_board/app/core/component/switcher_component.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';
//
// class DesignToolbarComponent extends ConsumerStatefulWidget {
//   const DesignToolbarComponent({super.key});
//
//   @override
//   ConsumerState<DesignToolbarComponent> createState() =>
//       _DesignToolbarComponentState();
// }
//
// class _DesignToolbarComponentState
//     extends ConsumerState<DesignToolbarComponent> {
//   @override
//   Widget build(BuildContext context) {
//     final bp = ref.watch(boardProvider);
//     return bp.selectedItemOnTheBoard == null
//         ? Center(
//             child: Text(
//               "Tap and mark what to redesign",
//               style: Theme.of(
//                 context,
//               ).textTheme.labelMedium!.copyWith(color: ColorManager.white),
//             ),
//           )
//         : Container(
//             padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
//             child: ListView(
//               children: [
//                 _buildTopActionWidget(boardState: bp),
//                 SizedBox(height: 20),
//                 _buildFillColorWidget("Fill Color", boardState: bp),
//                 SizedBox(height: 20),
//                 _buildOpacitySliderWidget(boardState: bp),
//                 SizedBox(height: 20),
//
//                 // NEW: Conditionally show the Aerial Pass switcher for the ball
//                 if (bp.selectedItemOnTheBoard is EquipmentModel &&
//                     (bp.selectedItemOnTheBoard as EquipmentModel).name ==
//                         "BALL")
//                   _buildAerialPassSwitcher(
//                       equipmentModel:
//                           bp.selectedItemOnTheBoard as EquipmentModel),
//
//                 if (bp.selectedItemOnTheBoard is PlayerModel)
//                   _buildSwitcherWidget(
//                       playerModel: bp.selectedItemOnTheBoard as PlayerModel),
//               ],
//             ),
//           );
//   }
//
//   // NEW: Widget to control the isAerialArrival flag on the ball model
//   Widget _buildAerialPassSwitcher({required EquipmentModel equipmentModel}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         SwitcherComponent(
//           title: "Aerial Pass / Cross",
//           initialValue: equipmentModel.isAerialArrival,
//           onChanged: (newValue) {
//             // Create a copy of the model with the updated flag
//             final updatedModel =
//                 equipmentModel.copyWith(isAerialArrival: newValue);
//
//             // Call the new method in the provider to update the state
//             ref
//                 .read(boardProvider.notifier)
//                 .updateEquipmentModel(newModel: updatedModel);
//           },
//         ),
//         SizedBox(height: 20), // Add spacing after the switcher
//       ],
//     );
//   }
//
//   Widget _buildTopActionWidget({required BoardState boardState}) {
//     FieldItemModel? selectedItem = boardState.selectedItemOnTheBoard;
//     return SizedBox(
//       height: 50,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           if (selectedItem?.canBeCopied == true)
//             Expanded(
//               child: FittedBox(
//                 child: GestureDetector(
//                   onTap: () {
//                     ref.read(boardProvider.notifier).copyElement();
//                   },
//                   child: Transform.scale(
//                     scale: 0.7,
//                     child: Icon(Icons.copy, color: ColorManager.grey),
//                   ),
//                 ),
//               ),
//             ),
//           Expanded(
//             child: FittedBox(
//               child: GestureDetector(
//                 onTap: () {
//                   ref.read(boardProvider.notifier).moveDown();
//                 },
//                 child: Icon(Icons.move_down_outlined, color: ColorManager.grey),
//               ),
//             ),
//           ),
//           Expanded(
//             child: FittedBox(
//               child: GestureDetector(
//                 onTap: () {
//                   ref.read(boardProvider.notifier).moveUp();
//                 },
//                 child: Icon(Icons.move_up_outlined, color: ColorManager.grey),
//               ),
//             ),
//           ),
//           Expanded(
//             child: FittedBox(
//               child: GestureDetector(
//                 onTap: () {
//                   ref.read(boardProvider.notifier).removeElement();
//                 },
//                 child: Transform.scale(
//                   scale: 0.7,
//                   child: Icon(FontAwesomeIcons.trash, color: ColorManager.grey),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFillColorWidget(String title, {required BoardState boardState}) {
//     FieldItemModel item = boardState.selectedItemOnTheBoard!;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: Theme.of(
//             context,
//           ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
//         ),
//         SizedBox(height: 10),
//         ColorSlider(
//           initialColor: item.color,
//           colors: [
//             Colors.red,
//             Colors.blue,
//             Colors.green,
//             Colors.yellow,
//             Colors.purple,
//           ],
//           onColorChanged: (c) {
//             setState(() {
//               item.color = c;
//             });
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOpacitySliderWidget({required BoardState boardState}) {
//     FieldItemModel item = boardState.selectedItemOnTheBoard!;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Opacity",
//           style: Theme.of(
//             context,
//           ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
//         ),
//         SizedBox(height: 10),
//         OpacitySlider(
//           initial: item.opacity ?? 1,
//           onOpacityChanged: (v) {
//             setState(() {
//               item.opacity = v;
//             });
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSizeSliderWidget({required BoardState boardState}) {
//     FieldItemModel item = boardState.selectedItemOnTheBoard!;
//     if (item is LineModelV2 ||
//         item is FreeDrawModelV2 ||
//         item is ShapeModel ||
//         item is EquipmentModel) {
//       return SizedBox.shrink();
//     }
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Size",
//           style: Theme.of(
//             context,
//           ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
//         ),
//         SizedBox(height: 10),
//         CustomSlider(
//           min: 16,
//           max: 100,
//           initial: item.size?.x ?? 32,
//           onValueChanged: (v) {
//             setState(() {
//               item.size = Vector2(v, v);
//             });
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSwitcherWidget({required PlayerModel playerModel}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SwitcherComponent(
//           title: "Image",
//           initialValue: playerModel.showImage,
//           onChanged: (t) {
//             playerModel.showImage = t;
//             ref
//                 .read(boardProvider.notifier)
//                 .updatePlayerModel(newModel: playerModel);
//           },
//         ),
//         SizedBox(height: 10),
//         SwitcherComponent(
//           title: "Name",
//           initialValue: playerModel.showName,
//           onChanged: (t) {
//             playerModel.showName = t;
//             ref
//                 .read(boardProvider.notifier)
//                 .updatePlayerModel(newModel: playerModel);
//           },
//         ),
//         SizedBox(height: 10),
//         SwitcherComponent(
//           title: "Number",
//           initialValue: playerModel.showNr,
//           onChanged: (t) {
//             playerModel.showNr = t;
//             ref
//                 .read(boardProvider.notifier)
//                 .updatePlayerModel(newModel: playerModel);
//           },
//         ),
//         SizedBox(height: 10),
//         SwitcherComponent(
//           title: "Role",
//           initialValue: playerModel.showRole,
//           onChanged: (t) {
//             playerModel.showRole = t;
//             ref
//                 .read(boardProvider.notifier)
//                 .updatePlayerModel(newModel: playerModel);
//           },
//         ),
//       ],
//     );
//   }
// }

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zporter_tactical_board/app/core/component/color_picker_slider.dart';
import 'package:zporter_tactical_board/app/core/component/custom_slider.dart';
import 'package:zporter_tactical_board/app/core/component/opacity_slider.dart';
import 'package:zporter_tactical_board/app/core/component/switcher_component.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

class DesignToolbarComponent extends ConsumerStatefulWidget {
  const DesignToolbarComponent({super.key});

  @override
  ConsumerState<DesignToolbarComponent> createState() =>
      _DesignToolbarComponentState();
}

class _DesignToolbarComponentState
    extends ConsumerState<DesignToolbarComponent> {
  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    return bp.selectedItemOnTheBoard == null
        ? Center(
            child: Text(
              "Tap and mark what to redesign",
              style: Theme.of(
                context,
              ).textTheme.labelMedium!.copyWith(color: ColorManager.white),
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
            child: ListView(
              children: [
                _buildTopActionWidget(boardState: bp),
                SizedBox(height: 20),
                _buildFillColorWidget("Fill Color", boardState: bp),
                SizedBox(height: 20),
                _buildOpacitySliderWidget(boardState: bp),
                SizedBox(height: 20),
                // REMOVED: The old aerial pass switcher is now gone from here.
                if (bp.selectedItemOnTheBoard is PlayerModel)
                  _buildSwitcherWidget(
                      playerModel: bp.selectedItemOnTheBoard as PlayerModel),
              ],
            ),
          );
  }

  // REMOVED: The helper method for the old switcher is now gone.

  Widget _buildTopActionWidget({required BoardState boardState}) {
    FieldItemModel? selectedItem = boardState.selectedItemOnTheBoard;
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (selectedItem?.canBeCopied == true)
            Expanded(
              child: FittedBox(
                child: GestureDetector(
                  onTap: () {
                    ref.read(boardProvider.notifier).copyElement();
                  },
                  child: Transform.scale(
                    scale: 0.7,
                    child: Icon(Icons.copy, color: ColorManager.grey),
                  ),
                ),
              ),
            ),
          Expanded(
            child: FittedBox(
              child: GestureDetector(
                onTap: () {
                  ref.read(boardProvider.notifier).moveDown();
                },
                child: Icon(Icons.move_down_outlined, color: ColorManager.grey),
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              child: GestureDetector(
                onTap: () {
                  ref.read(boardProvider.notifier).moveUp();
                },
                child: Icon(Icons.move_up_outlined, color: ColorManager.grey),
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              child: GestureDetector(
                onTap: () {
                  ref.read(boardProvider.notifier).removeElement();
                },
                child: Transform.scale(
                  scale: 0.7,
                  child: Icon(FontAwesomeIcons.trash, color: ColorManager.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFillColorWidget(String title, {required BoardState boardState}) {
    FieldItemModel item = boardState.selectedItemOnTheBoard!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
        ),
        SizedBox(height: 10),
        ColorSlider(
          initialColor: item.color,
          colors: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.purple,
          ],
          onColorChanged: (c) {
            setState(() {
              item.color = c;
            });
          },
        ),
      ],
    );
  }

  Widget _buildOpacitySliderWidget({required BoardState boardState}) {
    FieldItemModel item = boardState.selectedItemOnTheBoard!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Opacity",
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
        ),
        SizedBox(height: 10),
        OpacitySlider(
          initial: item.opacity ?? 1,
          onOpacityChanged: (v) {
            setState(() {
              item.opacity = v;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSizeSliderWidget({required BoardState boardState}) {
    FieldItemModel item = boardState.selectedItemOnTheBoard!;
    if (item is LineModelV2 ||
        item is FreeDrawModelV2 ||
        item is ShapeModel ||
        item is EquipmentModel) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Size",
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
        ),
        SizedBox(height: 10),
        CustomSlider(
          min: 16,
          max: 100,
          initial: item.size?.x ?? 32,
          onValueChanged: (v) {
            setState(() {
              item.size = Vector2(v, v);
            });
          },
        ),
      ],
    );
  }

  Widget _buildSwitcherWidget({required PlayerModel playerModel}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitcherComponent(
          title: "Image",
          initialValue: playerModel.showImage,
          onChanged: (t) {
            playerModel.showImage = t;
            ref
                .read(boardProvider.notifier)
                .updatePlayerModel(newModel: playerModel);
          },
        ),
        SizedBox(height: 10),
        SwitcherComponent(
          title: "Name",
          initialValue: playerModel.showName,
          onChanged: (t) {
            playerModel.showName = t;
            ref
                .read(boardProvider.notifier)
                .updatePlayerModel(newModel: playerModel);
          },
        ),
        SizedBox(height: 10),
        SwitcherComponent(
          title: "Number",
          initialValue: playerModel.showNr,
          onChanged: (t) {
            playerModel.showNr = t;
            ref
                .read(boardProvider.notifier)
                .updatePlayerModel(newModel: playerModel);
          },
        ),
        SizedBox(height: 10),
        SwitcherComponent(
          title: "Role",
          initialValue: playerModel.showRole,
          onChanged: (t) {
            playerModel.showRole = t;
            ref
                .read(boardProvider.notifier)
                .updatePlayerModel(newModel: playerModel);
          },
        ),
      ],
    );
  }
}
