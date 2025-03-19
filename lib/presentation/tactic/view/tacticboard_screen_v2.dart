import 'package:flutter/src/widgets/framework.dart';
import 'package:zporter_tactical_board/app/core/component/responsive_screen_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/responsive/tacticboard_screen_tablet_v2.dart';

class TacticboardScreenV2 extends ResponsiveScreen {
  const TacticboardScreenV2({super.key});

  @override
  Widget buildDesktop(BuildContext context) {
    return TacticboardScreenTabletV2();
  }

  @override
  Widget buildMobile(BuildContext context) {
    return TacticboardScreenTabletV2();
  }

  @override
  Widget buildTablet(BuildContext context) {
    return TacticboardScreenTabletV2();
  }

  @override
  _TacticboardScreenV2State createState() => _TacticboardScreenV2State();
}

class _TacticboardScreenV2State
    extends ResponsiveScreenState<TacticboardScreenV2> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadTacticalBoard();
  }

  _loadTacticalBoard() {}
}
