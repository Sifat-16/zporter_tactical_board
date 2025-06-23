import 'package:flutter/material.dart';

class NavigationService {
  // 1. Create the GlobalKey
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // 2. Create a getter for easy access to the context
  static BuildContext? get currentContext {
    // The navigatorKey.currentContext is the context of the navigator widget
    return navigatorKey.currentContext;
  }
}
