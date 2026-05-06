import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

/// Centralized toast helper that enforces consistent header positioning
/// across the entire app, matching other Zporter apps and web.
///
/// All toasts appear at the top of the screen so they don't block
/// the bottom tab menu (boss requirement).
class AppToast {
  AppToast._();

  /// Show a text message at the top of the screen.
  static void show(
    String text, {
    Duration duration = const Duration(seconds: 3),
    Color? contentColor,
    TextStyle? textStyle,
  }) {
    BotToast.showText(
      text: text,
      align: Alignment.topCenter,
      duration: duration,
      contentColor: contentColor ?? const Color(0xFF303030),
      textStyle: textStyle ?? const TextStyle(color: Colors.white),
    );
  }

  /// Show a success message (green).
  static void success(String text) {
    show(
      text,
      contentColor: Colors.green.shade700,
      textStyle: const TextStyle(color: Colors.white),
    );
  }

  /// Show an error message (red).
  static void error(String text) {
    show(
      text,
      contentColor: Colors.red.shade700,
      textStyle: const TextStyle(color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }
}
