// connectivity_service.dart (New file or part of your services)

import 'dart:async'; // For StreamSubscription

import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

/// A static class to manage connectivity monitoring and notifications.
class ConnectivityService {
  // Private constructor to prevent instantiation
  ConnectivityService._();

  // --- Static Variables ---
  static StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription;
  // Store the previous result to detect changes, initialize assuming offline
  static List<ConnectivityResult> _previousResult = [ConnectivityResult.none];
  // Optional: Reference to logger instance from GetIt
  // static final Logger? _logger = sl.isRegistered<Logger>() ? sl<Logger>() : null;

  // --- Static Methods ---

  /// Initializes the connectivity listener.
  /// Checks the initial state and subscribes to future changes.
  static void initialize() {
    // Prevent multiple initializations
    if (_connectivitySubscription != null) {
      zlog(data: "Connectivity listener already initialized.");
      return;
    }

    // --- Check Initial State ---
    Connectivity().checkConnectivity().then((
      List<ConnectivityResult> initialResult,
    ) {
      zlog(data: 'Initial connectivity status: $initialResult');
      _updateStatus(initialResult, isInitialCheck: true);
    });

    // --- Subscribe to Changes ---
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      zlog(data: 'Connectivity changed: $result');
      _updateStatus(result);
    });

    zlog(data: "Connectivity listener initialized.");
  }

  /// Processes connectivity status changes and shows appropriate toasts.
  static void _updateStatus(
    List<ConnectivityResult> result, {
    bool isInitialCheck = false,
  }) {
    // Determine current online/offline status
    bool currentlyOnline = !result.contains(ConnectivityResult.none);
    bool previouslyOnline = !_previousResult.contains(ConnectivityResult.none);

    // Only show toasts on actual state change
    if (!isInitialCheck && currentlyOnline != previouslyOnline) {
      if (currentlyOnline) {
        zlog(data: "Status Change: Offline -> Online");
        BotToast.showText(
          text: "Network established, back to online mode",
          contentColor: Colors.green.shade700,
          textStyle: const TextStyle(color: Colors.white),
          duration: const Duration(seconds: 3),
          // Other BotToast customization options...
        );
      } else {
        zlog(data: "Status Change: Online -> Offline");
        BotToast.showText(
          text: "Network error, back to offline mode",
          contentColor: Colors.red.shade700,
          textStyle: const TextStyle(color: Colors.white),
          duration: const Duration(seconds: 3),
          // Other BotToast customization options...
        );
      }
    } else if (isInitialCheck) {
      // Log initial status
      if (!currentlyOnline) {
        zlog(data: "Initial Status: Offline");
        // Optional: Show initial offline toast if desired
        // BotToast.showText(text: "App started in offline mode", ...);
      } else {
        zlog(data: "Initial Status: Online");
      }
    }

    // Update the previous state for the next comparison
    _previousResult = result;
  }

  /// Disposes the connectivity stream subscription.
  /// Call this if you need to explicitly stop listening (rare for global setup).
  static void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    zlog(data: "Connectivity listener disposed.");
  }

  /// Static getter to check the current online status synchronously based on the last known result.
  /// Note: This reflects the *last event received*, not a real-time check.
  static bool get isOnline {
    return !_previousResult.contains(ConnectivityResult.none);
  }

  /// Static method to perform a real-time connectivity check.
  static Future<bool> checkRealtimeConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
