import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';

abstract class _ResponsiveScreenTypeStrategy {
  bool isMobile(BuildContext context);
  bool isTablet(BuildContext context);
  bool isDesktop(BuildContext context);
}

class ResponsiveScreenHelper implements _ResponsiveScreenTypeStrategy {
  static final ResponsiveScreenHelper _instance =
      ResponsiveScreenHelper._internal();
  factory ResponsiveScreenHelper() => _instance;
  ResponsiveScreenHelper._internal();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  @override
  bool isDesktop(BuildContext context) {
    double width = context.screenWidth;
    return width >= tabletBreakpoint;
  }

  @override
  bool isMobile(BuildContext context) {
    double width = context.screenWidth;
    return width < mobileBreakpoint;
  }

  @override
  bool isTablet(BuildContext context) {
    double width = context.screenWidth;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
}
