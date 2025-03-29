import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/component/color_picker_slider.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

class SettingsToolbarComponent extends ConsumerStatefulWidget {
  const SettingsToolbarComponent({super.key});

  @override
  ConsumerState<SettingsToolbarComponent> createState() =>
      _SettingsToolbarComponentState();
}

class _SettingsToolbarComponentState
    extends ConsumerState<SettingsToolbarComponent> {
  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      child: ListView(
        children: [
          DropdownSelector<String>(
            label: "Home Club",
            items: ["Club 1", "Club 2", "Club 3"],
            initialValue: null,
            onChanged: (s) {},
            itemAsString: (String item) {
              return item;
            },
          ),

          DropdownSelector<String>(
            label: "Home Team",
            items: ["Team 1", "Team 2", "Team 3"],
            initialValue: null,
            onChanged: (s) {},
            itemAsString: (String item) {
              return item;
            },
          ),

          DropdownSelector<String>(
            label: "Away Club",
            items: ["Club 1", "Club 2", "Club 3"],
            initialValue: null,
            onChanged: (s) {},
            itemAsString: (String item) {
              return item;
            },
          ),

          DropdownSelector<String>(
            label: "Away Team",
            items: ["Team 1", "Team 2", "Team 3"],
            initialValue: null,
            onChanged: (s) {},
            itemAsString: (String item) {
              return item;
            },
          ),

          _buildFillColorWidget("Field Color", boardState: bp),

          // ImagePicker(label: "Background Image",  onChanged: (s){})
        ],
      ),
    );
  }

  Widget _buildFillColorWidget(String title, {required BoardState boardState}) {
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
          initialColor: boardState.boardColor,
          colors: [
            ColorManager.grey,
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.purple,
          ],
          onColorChanged: (c) {
            ref.read(boardProvider.notifier).updateBoardColor(c);
          },
        ),
      ],
    );
  }
}
