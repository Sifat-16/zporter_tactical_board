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
            "No Item Selected",
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
              _buildSizeSliderWidget(boardState: bp),
              // SizedBox(height: 20),
              // IncrementDecrementNumberField(
              //   label: "Border type",
              //   initialValue: 0,
              //   onChanged: (d) {},
              // ),
              // SizedBox(height: 20),
              // IncrementDecrementNumberField(
              //   label: "Border thickness",
              //   initialValue: 2,
              //   onChanged: (d) {},
              // ),
              // SizedBox(height: 20),
              // _buildFillColorWidget("Border color", boardState: bp),
              // SizedBox(height: 20),
              // _buildSwitcherWidget(),
            ],
          ),
        );
  }

  Widget _buildTopActionWidget({required BoardState boardState}) {
    FieldItemModel? selectedItem = boardState.selectedItemOnTheBoard;
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        spacing: 25,
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 10,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
        ),

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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 10,

      children: [
        Text(
          "Opacity",
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
        ),

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
    if (
    // item is FormModel && item.formItemModel is LineModel
    //     ||
    item is LineModelV2 ||
        item is FreeDrawModelV2 ||
        item is ShapeModel ||
        item is EquipmentModel) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 10,

      children: [
        Text(
          "Size",
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
        ),

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

  Widget _buildSwitcherWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 10,

      children: [
        SwitcherComponent(
          title: "Images",
          initialValue: true,
          onChanged: (t) {},
        ),
        SwitcherComponent(
          title: "Names",
          initialValue: true,
          onChanged: (t) {},
        ),
        SwitcherComponent(
          title: "Number",
          initialValue: true,
          onChanged: (t) {},
        ),
        SwitcherComponent(
          title: "Role",
          initialValue: false,
          onChanged: (t) {},
        ),
      ],
    );
  }
}
