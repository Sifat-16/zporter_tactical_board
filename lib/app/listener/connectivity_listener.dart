// lib/app/widgets/connectivity_listener.dart

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/services/connectivity_service.dart';

class ConnectivityListener extends StatefulWidget {
  final Widget child;
  const ConnectivityListener({super.key, required this.child});

  @override
  State<ConnectivityListener> createState() => _ConnectivityListenerState();
}

class _ConnectivityListenerState extends State<ConnectivityListener> {
  @override
  void initState() {
    super.initState();
    // Add the listener here. This is guaranteed to run in a valid UI context.
    ConnectivityService.statusNotifier.addListener(_showConnectivityToast);
  }

  @override
  void dispose() {
    // Clean up the listener.
    ConnectivityService.statusNotifier.removeListener(_showConnectivityToast);
    super.dispose();
  }

  void _showConnectivityToast() {
    final status = ConnectivityService.statusNotifier.value;

    // The core logic now lives safely inside a widget.
    // We only care about transitions, not the initial state.
    if (status.isOnline != status.wasOnline) {
      if (status.isOnline) {
        BotToast.showText(
          text: "Network established, back to online mode",
          contentColor: Colors.green.shade700,
          textStyle: const TextStyle(color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      } else {
        BotToast.showText(
          text: "Network error, back to offline mode",
          contentColor: Colors.red.shade700,
          textStyle: const TextStyle(color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget just passes its child through, it doesn't render anything itself.
    return widget.child;
  }
}
