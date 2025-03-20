import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';

class TacticboardScreenTablet extends StatefulWidget {
  const TacticboardScreenTablet({super.key});

  @override
  State<TacticboardScreenTablet> createState() =>
      _TacticboardScreenTabletState();
}

class _TacticboardScreenTabletState extends State<TacticboardScreenTablet> {
  final GlobalKey _gameScreenKey = GlobalKey(); // Add a GlobalKey
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
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    // Flexible(flex: 7, child: GameScreen(key: _gameScreenKey)),
                    SizedBox(
                      height: context.heightPercent(80),
                      child: GameScreen(key: _gameScreenKey),
                    ),

                    Container(color: Colors.red),

                    // Flexible(flex: 1, child: Container(color: Colors.red)),
                  ],
                ),
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
