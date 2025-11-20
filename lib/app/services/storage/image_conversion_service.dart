import 'dart:convert';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

/// Helper service for image format conversion and validation
class ImageConversionService {
  /// Convert base64 string to Uint8List
  static Uint8List? base64ToBytes(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }

    try {
      // Remove data URL prefix if present
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      return base64Decode(cleanBase64);
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error decoding base64: $e\n$stackTrace',
      );
      return null;
    }
  }

  /// Convert Uint8List to base64 string
  static String? bytesToBase64(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    try {
      return base64Encode(bytes);
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error encoding base64: $e\n$stackTrace',
      );
      return null;
    }
  }

  /// Check if string is a valid base64 image
  static bool isBase64Image(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    // Check for data URL prefix
    if (value.startsWith('data:image/')) {
      return true;
    }

    // Check if it's valid base64
    try {
      base64Decode(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if string is a valid Firebase Storage URL
  static bool isFirebaseStorageUrl(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    // Check for Firebase Storage URL patterns
    return value.contains('firebasestorage.googleapis.com') ||
        value.startsWith('gs://');
  }

  /// Check if string is a network URL
  static bool isNetworkUrl(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    return value.startsWith('http://') || value.startsWith('https://');
  }

  /// Get image size estimation from base64
  static int estimateBase64Size(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return 0;
    }

    // Base64 encoding increases size by ~33%
    // Rough estimate: (length * 3) / 4
    return (base64String.length * 3) ~/ 4;
  }

  /// Get human-readable size
  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Extract image format from base64 data URL
  static String? extractImageFormat(String? base64String) {
    if (base64String == null || !base64String.startsWith('data:image/')) {
      return null;
    }

    try {
      final parts = base64String.split(';')[0].split('/');
      if (parts.length >= 2) {
        return parts[1]; // e.g., 'jpeg', 'png', 'webp'
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  /// Create data URL from bytes and format
  static String createDataUrl(Uint8List bytes, {String format = 'jpeg'}) {
    final base64 = base64Encode(bytes);
    return 'data:image/$format;base64,$base64';
  }

  /// Validate image data
  static bool isValidImageData(Uint8List? data) {
    if (data == null || data.isEmpty) {
      return false;
    }

    // Check for common image file signatures
    // JPEG: FF D8 FF
    if (data.length >= 3 &&
        data[0] == 0xFF &&
        data[1] == 0xD8 &&
        data[2] == 0xFF) {
      return true;
    }

    // PNG: 89 50 4E 47
    if (data.length >= 4 &&
        data[0] == 0x89 &&
        data[1] == 0x50 &&
        data[2] == 0x4E &&
        data[3] == 0x47) {
      return true;
    }

    // WebP: 52 49 46 46 (RIFF)
    if (data.length >= 4 &&
        data[0] == 0x52 &&
        data[1] == 0x49 &&
        data[2] == 0x46 &&
        data[3] == 0x46) {
      return true;
    }

    return false;
  }

  /// Calculate space savings from migration
  static Map<String, dynamic> calculateSavings({
    required int base64Size,
    required int urlSize,
  }) {
    final saved = base64Size - urlSize;
    final percentSaved = (saved / base64Size * 100);

    return {
      'base64Size': base64Size,
      'urlSize': urlSize,
      'savedBytes': saved,
      'percentSaved': percentSaved,
      'base64SizeFormatted': formatBytes(base64Size),
      'urlSizeFormatted': formatBytes(urlSize),
      'savedFormatted': formatBytes(saved),
    };
  }
}
