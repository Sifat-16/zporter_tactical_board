import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/responsive_screen_component.dart';
import 'package:zporter_tactical_board/presentation/admin/view/responsive/admin_screen_tablet.dart';

class AdminScreen extends ResponsiveScreen {
  const AdminScreen({super.key});

  @override
  Widget buildDesktop(BuildContext context) {
    return AdminScreenTablet();
  }

  @override
  Widget buildMobile(BuildContext context) {
    return AdminScreenTablet();
  }

  @override
  Widget buildTablet(BuildContext context) {
    return AdminScreenTablet();
  }

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends ResponsiveScreenState<AdminScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
