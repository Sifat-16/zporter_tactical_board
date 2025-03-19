import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';

class SettingsToolbarComponent extends StatefulWidget {
  const SettingsToolbarComponent({super.key});

  @override
  State<SettingsToolbarComponent> createState() =>
      _SettingsToolbarComponentState();
}

class _SettingsToolbarComponentState extends State<SettingsToolbarComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      child: ListView(
        children: [
          DropdownSelector(
            label: "Home Club",
            items: ["Club 1", "Club 2", "Club 3"],
            initialValue: null,
            onChanged: (s) {},
          ),

          DropdownSelector(
            label: "Home Team",
            items: ["Team 1", "Team 2", "Team 3"],
            initialValue: null,
            onChanged: (s) {},
          ),

          DropdownSelector(
            label: "Away Club",
            items: ["Club 1", "Club 2", "Club 3"],
            initialValue: null,
            onChanged: (s) {},
          ),

          DropdownSelector(
            label: "Away Team",
            items: ["Team 1", "Team 2", "Team 3"],
            initialValue: null,
            onChanged: (s) {},
          ),

          // ImagePicker(label: "Background Image",  onChanged: (s){})
        ],
      ),
    );
  }
}
