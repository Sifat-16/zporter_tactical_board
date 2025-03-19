import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/extensions/responsive_screen_extension.dart';

abstract class ResponsiveScreen extends StatefulWidget {
  const ResponsiveScreen({super.key});

  /// Force implementation of UI for mobile
  Widget buildMobile(BuildContext context);

  /// Force implementation of UI for tablet
  Widget buildTablet(BuildContext context);

  /// Force implementation of UI for desktop
  Widget buildDesktop(BuildContext context);

  @override
  ResponsiveScreenState createState();
}

abstract class ResponsiveScreenState<T extends ResponsiveScreen>
    extends State<T> {
  @override
  Widget build(BuildContext context) {
    // Switch on the context to determine the current screen size and render accordingly
    if (context.isDesktop) {
      return widget.buildDesktop(context);
    } else if (context.isTablet) {
      return widget.buildTablet(context);
    } else {
      return widget.buildMobile(context);
    }
  }
}
