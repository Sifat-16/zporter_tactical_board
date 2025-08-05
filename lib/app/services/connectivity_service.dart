import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

/// A static class to manage connectivity monitoring and notifications.
class ConnectivityService {
  ConnectivityService._();

  static StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;
  static List<ConnectivityResult> _previousResult = [ConnectivityResult.none];

  // --- NEW ---
  // Add a flag to ensure the initial check is fully complete before any stream toast.
  static bool _hasCompletedInitialCheck = false;

  /// Initializes the connectivity listener.
  static Future<void> initialize() async {
    if (_connectivitySubscription != null) {
      zlog(data: "[Connectivity] Listener already initialized.");
      return;
    }

    zlog(data: "[Connectivity] Initializing...");

    try {
      final List<ConnectivityResult> initialResult =
          await Connectivity().checkConnectivity();
      zlog(
          data:
              '[Connectivity] Initial check completed. Result: $initialResult');
      _updateStatus(initialResult, isInitialCheck: true);
    } catch (e) {
      zlog(data: '[Connectivity] Error on initial check: $e');
      _updateStatus([ConnectivityResult.none], isInitialCheck: true);
    }

    // --- MODIFIED ---
    // Mark the initial check as complete *before* subscribing to the stream.
    _hasCompletedInitialCheck = true;
    zlog(data: "[Connectivity] Initial check is now marked as complete.");

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      zlog(data: '[Connectivity] Stream event received. Result: $result');
      _updateStatus(result);
    });

    zlog(data: "[Connectivity] Listener fully initialized and subscribed.");
  }

  static void _updateStatus(
    List<ConnectivityResult> result, {
    bool isInitialCheck = false,
  }) {
    final bool currentlyOnline = !result.contains(ConnectivityResult.none);
    final bool previouslyOnline =
        !_previousResult.contains(ConnectivityResult.none);

    // --- ENHANCED LOGGING ---
    zlog(
        data: "[Connectivity] _updateStatus called. "
            "isInitialCheck: $isInitialCheck, "
            "hasCompletedInitialCheck: $_hasCompletedInitialCheck, "
            "currentlyOnline: $currentlyOnline, "
            "previouslyOnline: $previouslyOnline");

    // This condition is now much safer.
    final bool shouldShowToast = _hasCompletedInitialCheck &&
        !isInitialCheck &&
        currentlyOnline != previouslyOnline;

    if (shouldShowToast) {
      zlog(data: "[Connectivity] Condition met. Showing toast.");
      // The post-frame callback is still a good idea.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currentlyOnline) {
          zlog(data: "[Connectivity] Status Change: Offline -> Online");
          BotToast.showText(
            text: "Network established, back to online mode",
            contentColor: Colors.green.shade700,
            textStyle: const TextStyle(color: Colors.white),
            duration: const Duration(seconds: 3),
          );
        } else {
          zlog(data: "[Connectivity] Status Change: Online -> Offline");
          BotToast.showText(
            text: "Network error, back to offline mode",
            contentColor: Colors.red.shade700,
            textStyle: const TextStyle(color: Colors.white),
            duration: const Duration(seconds: 3),
          );
        }
      });
    }

    // Update the previous state for the next comparison
    _previousResult = result;
  }

  static void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _hasCompletedInitialCheck = false; // Reset if needed
    zlog(data: "[Connectivity] Listener disposed.");
  }

  // ... (isOnline and checkRealtimeConnectivity getters are fine) ...
  static bool get isOnline {
    return !_previousResult.contains(ConnectivityResult.none);
  }

  static Future<bool> checkRealtimeConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
