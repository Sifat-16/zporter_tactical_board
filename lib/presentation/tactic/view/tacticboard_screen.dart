import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/responsive_screen_component.dart';
import 'package:zporter_tactical_board/presentation/auth/view_model/auth_controller.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/responsive/tacticboard_screen_tablet.dart';

class TacticboardScreen extends ResponsiveScreen {
  const TacticboardScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget buildDesktop(BuildContext context) {
    return TacticboardScreenTablet(userId: userId);
  }

  @override
  Widget buildMobile(BuildContext context) {
    return TacticboardScreenTablet(userId: userId);
  }

  @override
  Widget buildTablet(BuildContext context) {
    return TacticboardScreenTablet(userId: userId);
  }

  @override
  _TacticboardScreenState createState() => _TacticboardScreenState();
}

class _TacticboardScreenState extends ResponsiveScreenState<TacticboardScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      ref.read(authProvider.notifier).initiateUser(widget.userId);
    });
    _loadTacticalBoard();
  }

  _loadTacticalBoard() {}
}
