import 'package:flutter/src/widgets/framework.dart';
import 'package:zporter_tactical_board/app/core/component/responsive_screen_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/responsive/tacticboard_screen_tablet.dart';

class TacticboardScreen extends ResponsiveScreen {
  const TacticboardScreen({super.key});

  @override
  Widget buildDesktop(BuildContext context) {
    return TacticboardScreenTablet();
  }

  @override
  Widget buildMobile(BuildContext context) {
    return TacticboardScreenTablet();
  }

  @override
  Widget buildTablet(BuildContext context) {
    return TacticboardScreenTablet();
  }

  @override
  _TacticboardScreenState createState() => _TacticboardScreenState();
}

class _TacticboardScreenState extends ResponsiveScreenState<TacticboardScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadTacticalBoard();
  }

  _loadTacticalBoard() {}
}
