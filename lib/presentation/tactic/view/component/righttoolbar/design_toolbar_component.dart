import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/color_picker_slider.dart';
import 'package:zporter_tactical_board/app/core/component/increment_decrement_counter_field.dart';
import 'package:zporter_tactical_board/app/core/component/opacity_slider.dart';
import 'package:zporter_tactical_board/app/core/component/switcher_component.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class DesignToolbarComponent extends StatefulWidget {
  const DesignToolbarComponent({super.key});

  @override
  State<DesignToolbarComponent> createState() => _DesignToolbarComponentState();
}

class _DesignToolbarComponentState extends State<DesignToolbarComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      child: ListView(
        children: [
          _buildTopActionWidget(),
          SizedBox(height: 20),
          _buildFillColorWidget("Fill Color"),
          SizedBox(height: 20),
          _buildOpacitySliderWidget(),
          SizedBox(height: 20),
          IncrementDecrementNumberField(
            label: "Border type",
            initialValue: 0,
            onChanged: (d) {},
          ),
          SizedBox(height: 20),
          IncrementDecrementNumberField(
            label: "Border thickness",
            initialValue: 2,
            onChanged: (d) {},
          ),
          SizedBox(height: 20),
          _buildFillColorWidget("Border color"),
          SizedBox(height: 20),
          _buildSwitcherWidget(),
        ],
      ),
    );
  }

  Widget _buildTopActionWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 25,
      children: [
        Expanded(
          child: FittedBox(child: Icon(Icons.copy, color: ColorManager.grey)),
        ),
        Expanded(
          child: FittedBox(
            child: Icon(Icons.move_down_outlined, color: ColorManager.grey),
          ),
        ),
        Expanded(
          child: FittedBox(
            child: Icon(Icons.move_up_outlined, color: ColorManager.grey),
          ),
        ),
        Expanded(
          child: FittedBox(
            child: Icon(CupertinoIcons.delete, color: ColorManager.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildFillColorWidget(String title) {
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
          colors: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.purple,
          ],
        ),
      ],
    );
  }

  Widget _buildOpacitySliderWidget() {
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

        OpacitySlider(),
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
