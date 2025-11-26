import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

/// Network quality indicator
enum NetworkQuality {
  /// No network connection
  offline,

  /// WiFi connection (best quality)
  wifi,

  /// Mobile data connection (cellular)
  mobile,

  /// Other connection types (ethernet, etc.)
  other,
}

/// Service for monitoring network connectivity
class ConnectivityService {
  final Connectivity _connectivity;
  late final StreamController<ConnectivityResult> _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _connectivityController = StreamController<ConnectivityResult>.broadcast();
    _initConnectivityListener();
  }

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivityController.stream;

  /// Initialize connectivity listener
  void _initConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.isNotEmpty) {
          final result = results.first;
          _connectivityController.add(result);
          zlog(
            level: Level.info,
            data: 'Connectivity changed: ${result.name}',
          );
        }
      },
      onError: (error) {
        zlog(
          level: Level.error,
          data: 'Connectivity stream error: $error',
        );
      },
    );
  }

  /// Check if device is currently online
  Future<bool> get isOnline async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty) return false;
      final result = results.first;
      return result != ConnectivityResult.none;
    } catch (e) {
      zlog(
        level: Level.error,
        data: 'Error checking connectivity: $e',
      );
      return false;
    }
  }

  /// Get current network quality
  Future<NetworkQuality> get quality async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty) return NetworkQuality.offline;

      final result = results.first;
      switch (result) {
        case ConnectivityResult.wifi:
          return NetworkQuality.wifi;
        case ConnectivityResult.mobile:
          return NetworkQuality.mobile;
        case ConnectivityResult.ethernet:
        case ConnectivityResult.vpn:
        case ConnectivityResult.bluetooth:
          return NetworkQuality.other;
        case ConnectivityResult.none:
        case ConnectivityResult.other:
          return NetworkQuality.offline;
      }
    } catch (e) {
      zlog(
        level: Level.error,
        data: 'Error getting network quality: $e',
      );
      return NetworkQuality.offline;
    }
  }

  /// Get current connectivity result
  Future<ConnectivityResult> get currentConnectivity async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty) return ConnectivityResult.none;
      return results.first;
    } catch (e) {
      zlog(
        level: Level.error,
        data: 'Error getting connectivity result: $e',
      );
      return ConnectivityResult.none;
    }
  }

  /// Check if on WiFi (best for large syncs)
  Future<bool> get isOnWifi async {
    final result = await currentConnectivity;
    return result == ConnectivityResult.wifi;
  }

  /// Check if on mobile data
  Future<bool> get isOnMobile async {
    final result = await currentConnectivity;
    return result == ConnectivityResult.mobile;
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}
