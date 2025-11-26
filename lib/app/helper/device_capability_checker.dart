import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Device capability levels
enum DeviceCapability {
  high, // Modern devices with good performance
  medium, // Mid-range devices
  low, // Older/budget devices that may struggle
  unknown, // Cannot determine
}

/// Detailed device information
class DeviceInfo {
  final DeviceCapability capability;
  final String osVersion;
  final String deviceModel;
  final bool isLowRAM;
  final bool isOldOS;
  final List<String> warnings;
  final List<String> recommendations;

  DeviceInfo({
    required this.capability,
    required this.osVersion,
    required this.deviceModel,
    required this.isLowRAM,
    required this.isOldOS,
    required this.warnings,
    required this.recommendations,
  });

  bool get shouldShowWarning =>
      capability == DeviceCapability.low || isLowRAM || isOldOS;

  String get warningMessage {
    if (warnings.isEmpty) return '';
    return warnings.join('\n');
  }

  String get recommendationMessage {
    if (recommendations.isEmpty) return '';
    return recommendations.join('\n');
  }
}

class DeviceCapabilityChecker {
  static const MethodChannel _channel = MethodChannel('device_capability');

  /// Check device capabilities
  static Future<DeviceInfo> checkDeviceCapabilities() async {
    if (kIsWeb) {
      return _getWebDeviceInfo();
    }

    if (Platform.isIOS) {
      return await _getIOSDeviceInfo();
    } else if (Platform.isAndroid) {
      return await _getAndroidDeviceInfo();
    }

    return DeviceInfo(
      capability: DeviceCapability.unknown,
      osVersion: 'Unknown',
      deviceModel: 'Unknown',
      isLowRAM: false,
      isOldOS: false,
      warnings: [],
      recommendations: [],
    );
  }

  /// iOS-specific device info
  static Future<DeviceInfo> _getIOSDeviceInfo() async {
    try {
      // Try to get system info
      final Map<dynamic, dynamic>? info =
          await _channel.invokeMethod('getDeviceInfo');

      String osVersion = 'Unknown';
      String deviceModel = 'Unknown';
      bool isLowRAM = false;

      if (info != null) {
        osVersion = info['osVersion'] ?? 'Unknown';
        deviceModel = info['model'] ?? 'Unknown';

        // Check RAM (in GB)
        final ram = info['ram'] as int?;
        isLowRAM = (ram != null && ram < 3); // Less than 3GB RAM
      }

      // Parse iOS version
      final version = _parseVersion(osVersion);
      final isOldOS = version < 13.0; // iOS 13 is from 2019

      // Check for older iPad models
      final isOldDevice = _isOldIOSDevice(deviceModel);

      DeviceCapability capability;
      List<String> warnings = [];
      List<String> recommendations = [];

      if (isOldOS || isOldDevice || isLowRAM) {
        capability = DeviceCapability.low;

        if (isOldOS) {
          warnings.add('⚠️ Your iOS version ($osVersion) is outdated.');
        }
        if (isOldDevice) {
          warnings.add(
              '⚠️ Your device ($deviceModel) may have limited performance.');
        }
        if (isLowRAM) {
          warnings.add('⚠️ Your device has limited memory (RAM).');
        }

        recommendations.addAll([
          '• Reduce animation complexity',
          '• Close other apps before recording',
          '• Use shorter animation durations',
          '• Avoid high-resolution exports',
        ]);
      } else if (version < 15.0) {
        capability = DeviceCapability.medium;
        recommendations
            .add('💡 For best performance, consider updating to iOS 15+');
      } else {
        capability = DeviceCapability.high;
      }

      return DeviceInfo(
        capability: capability,
        osVersion: osVersion,
        deviceModel: deviceModel,
        isLowRAM: isLowRAM,
        isOldOS: isOldOS,
        warnings: warnings,
        recommendations: recommendations,
      );
    } catch (e) {
      // Fallback if platform channel fails
      return _getFallbackIOSInfo();
    }
  }

  /// Android-specific device info
  static Future<DeviceInfo> _getAndroidDeviceInfo() async {
    try {
      final Map<dynamic, dynamic>? info =
          await _channel.invokeMethod('getDeviceInfo');

      String osVersion = 'Unknown';
      String deviceModel = 'Unknown';
      bool isLowRAM = false;

      if (info != null) {
        osVersion = 'Android ${info['sdkInt'] ?? 'Unknown'}';
        deviceModel = info['model'] ?? 'Unknown';

        // Check RAM (in GB)
        final ram = info['ram'] as int?;
        isLowRAM = (ram != null && ram < 3); // Less than 3GB RAM
      }

      // Parse Android SDK version
      final sdkInt = info?['sdkInt'] as int? ?? 0;
      final isOldOS = sdkInt < 26; // Android 8.0 (2017)

      DeviceCapability capability;
      List<String> warnings = [];
      List<String> recommendations = [];

      if (isOldOS || isLowRAM) {
        capability = DeviceCapability.low;

        if (isOldOS) {
          warnings.add('⚠️ Your Android version is outdated.');
        }
        if (isLowRAM) {
          warnings.add('⚠️ Your device has limited memory (RAM).');
        }

        recommendations.addAll([
          '• Reduce animation complexity',
          '• Close other apps before recording',
          '• Use shorter animation durations',
          '• Clear app cache regularly',
        ]);
      } else if (sdkInt < 29) {
        // Android 10
        capability = DeviceCapability.medium;
        recommendations
            .add('💡 For best performance, consider updating Android');
      } else {
        capability = DeviceCapability.high;
      }

      return DeviceInfo(
        capability: capability,
        osVersion: osVersion,
        deviceModel: deviceModel,
        isLowRAM: isLowRAM,
        isOldOS: isOldOS,
        warnings: warnings,
        recommendations: recommendations,
      );
    } catch (e) {
      return _getFallbackAndroidInfo();
    }
  }

  /// Web device info
  static DeviceInfo _getWebDeviceInfo() {
    // Web typically has good performance, but check user agent
    return DeviceInfo(
      capability: DeviceCapability.high,
      osVersion: 'Web',
      deviceModel: 'Browser',
      isLowRAM: false,
      isOldOS: false,
      warnings: [],
      recommendations: [],
    );
  }

  /// Fallback iOS info when platform channel fails
  static DeviceInfo _getFallbackIOSInfo() {
    return DeviceInfo(
      capability: DeviceCapability.medium,
      osVersion: 'iOS (Unknown version)',
      deviceModel: 'iPhone/iPad',
      isLowRAM: false,
      isOldOS: false,
      warnings: ['⚠️ Could not detect device specifications'],
      recommendations: [
        '• If you experience issues, try:',
        '  - Closing other apps',
        '  - Reducing animation complexity',
        '  - Using shorter recordings',
      ],
    );
  }

  /// Fallback Android info
  static DeviceInfo _getFallbackAndroidInfo() {
    return DeviceInfo(
      capability: DeviceCapability.medium,
      osVersion: 'Android (Unknown version)',
      deviceModel: 'Android Device',
      isLowRAM: false,
      isOldOS: false,
      warnings: ['⚠️ Could not detect device specifications'],
      recommendations: [
        '• If you experience issues, try:',
        '  - Closing other apps',
        '  - Clearing app cache',
        '  - Using shorter recordings',
      ],
    );
  }

  /// Parse version string to double
  static double _parseVersion(String version) {
    try {
      final parts = version.split('.');
      if (parts.isEmpty) return 0.0;

      final major = int.tryParse(parts[0]) ?? 0;
      final minor = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

      return major + (minor / 10.0);
    } catch (e) {
      return 0.0;
    }
  }

  /// Check if iOS device is old
  static bool _isOldIOSDevice(String model) {
    final oldModels = [
      'iPad Air',
      'iPad Air 2',
      'iPad mini',
      'iPad mini 2',
      'iPad mini 3',
      'iPad mini 4',
      'iPad (5th generation)',
      'iPad (6th generation)',
      'iPhone 6',
      'iPhone 6 Plus',
      'iPhone 6s',
      'iPhone 6s Plus',
      'iPhone 7',
      'iPhone 7 Plus',
      'iPhone 8',
      'iPhone 8 Plus',
      'iPhone SE (1st generation)',
      'iPhone X',
    ];

    return oldModels.any((old) => model.contains(old));
  }

  /// Get recommended settings based on device capability
  static Map<String, dynamic> getRecommendedSettings(
      DeviceCapability capability) {
    switch (capability) {
      case DeviceCapability.low:
        return {
          'targetFPS': 15.0,
          'maxAnimationDuration': 30.0, // seconds
          'skipFrames': 2, // Capture every 3rd frame
          'resolution': '640x480',
          'showPerformanceWarning': true,
          'enableAutoQualityReduction': true,
        };

      case DeviceCapability.medium:
        return {
          'targetFPS': 24.0,
          'maxAnimationDuration': 60.0,
          'skipFrames': 1, // Capture every 2nd frame
          'resolution': '1280x720',
          'showPerformanceWarning': false,
          'enableAutoQualityReduction': false,
        };

      case DeviceCapability.high:
        return {
          'targetFPS': 30.0,
          'maxAnimationDuration': 120.0,
          'skipFrames': 0, // Capture every frame
          'resolution': '1920x1080',
          'showPerformanceWarning': false,
          'enableAutoQualityReduction': false,
        };

      case DeviceCapability.unknown:
        return {
          'targetFPS': 30.0,
          'maxAnimationDuration': 120.0,
          'skipFrames': 0, // Capture every frame
          'resolution': '1920x1080',
          'showPerformanceWarning': false,
          'enableAutoQualityReduction': false,
        };
    }
  }
}
