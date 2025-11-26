// lib/app/services/connectivity_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart'; // For ValueNotifier
import 'package:zporter_tactical_board/app/helper/logger.dart';

// A simple model to hold both current and previous state for comparison.
class ConnectivityStatus {
  final bool isOnline;
  final bool wasOnline;
  ConnectivityStatus({required this.isOnline, required this.wasOnline});
}

class ConnectivityService {
  ConnectivityService._();

  static StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;

  // The notifier is the new heart of the service. It broadcasts changes.
  static final ValueNotifier<ConnectivityStatus> statusNotifier = ValueNotifier(
      ConnectivityStatus(
          isOnline: true, wasOnline: true) // Assume online initially
      );

  static Future<void> initialize() async {
    if (_connectivitySubscription != null) {
      zlog(data: "[Connectivity] Listener already initialized.");
      return;
    }

    // 1. Get initial state
    final initialResult = await Connectivity().checkConnectivity();
    bool isInitiallyOnline = !initialResult.contains(ConnectivityResult.none);

    // 2. Set the very first state in the notifier.
    // Notice wasOnline and isOnline are the same, so the listener won't fire a toast.
    statusNotifier.value = ConnectivityStatus(
        isOnline: isInitiallyOnline, wasOnline: isInitiallyOnline);
    zlog(data: "[Connectivity] Initial status set to: $isInitiallyOnline");

    // 3. Listen for subsequent changes
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      final bool currentlyOnline = !result.contains(ConnectivityResult.none);
      final bool previouslyOnline =
          statusNotifier.value.isOnline; // Get last known state

      // Only update if the status has actually changed.
      if (currentlyOnline != previouslyOnline) {
        zlog(
            data:
                "[Connectivity] Change detected: $previouslyOnline -> $currentlyOnline");
        statusNotifier.value = ConnectivityStatus(
          isOnline: currentlyOnline,
          wasOnline: previouslyOnline,
        );
      }
    });

    zlog(data: "[Connectivity] Listener initialized.");
  }

  static void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    zlog(data: "[Connectivity] Listener disposed.");
  }

  /// Static getter to check the current online status based on the last known event.
  static bool get isOnline => statusNotifier.value.isOnline;

  // --- METHOD RE-ADDED AS PER YOUR REQUIREMENT ---
  /// Performs a real-time, on-demand connectivity check.
  static Future<bool> checkRealtimeConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      zlog(data: "[Connectivity] Error during real-time check: $e");
      // It's safer to assume offline if the check itself fails.
      return false;
    }
  }
}
