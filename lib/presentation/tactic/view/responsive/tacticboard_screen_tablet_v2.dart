import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';

class TacticboardScreenTabletV2 extends StatefulWidget {
  const TacticboardScreenTabletV2({super.key});

  @override
  State<TacticboardScreenTabletV2> createState() =>
      _TacticboardScreenTabletV2State();
}

class _TacticboardScreenTabletV2State extends State<TacticboardScreenTabletV2> {
  @override
  Widget build(BuildContext context) {
    return MultiSplitView(
      initialAreas: [
        Area(
          flex: 1,
          max: 1,
          builder: (context, area) {
            return LefttoolbarComponent();
          },
        ),
        Area(
          flex: 3,
          max: 3,
          builder: (context, area) {
            return Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                spacing: 20,
                children: [
                  Flexible(flex: 7, child: GameScreen()),

                  Flexible(flex: 1, child: Container(color: Colors.red)),
                ],
              ),
            );
          },
        ),
        Area(
          flex: 1,
          max: 1,
          builder: (context, area) {
            return RighttoolbarComponent();
          },
        ),
      ],
    );
  }
}
