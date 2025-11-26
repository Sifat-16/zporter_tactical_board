import 'dart:io';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:zporter_tactical_board/app/helper/logger.dart';

/// Manages local caching of downloaded images for offline access
class ImageCacheManager {
  static const String _cacheDir = 'image_cache';
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50 MB
  static const int _maxCacheAge = 7; // days

  /// Get cached image if available
  Future<Uint8List?> getCachedImage(String imageUrl) async {
    try {
      final file = await _getCacheFile(imageUrl);

      if (!await file.exists()) {
        zlog(
          level: Level.debug,
          data: 'Cache miss: $imageUrl',
        );
        return null;
      }

      // Check if cache is expired
      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified).inDays;

      if (age > _maxCacheAge) {
        zlog(
          level: Level.debug,
          data: 'Cache expired (${age}d): $imageUrl',
        );
        await file.delete();
        return null;
      }

      final data = await file.readAsBytes();
      zlog(
        level: Level.debug,
        data: 'Cache hit: $imageUrl (${data.length} bytes)',
      );

      return data;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error reading cached image: $e\n$stackTrace',
      );
      return null;
    }
  }

  /// Cache image data
  Future<void> cacheImage(String imageUrl, Uint8List data) async {
    try {
      final file = await _getCacheFile(imageUrl);

      // Ensure directory exists
      await file.parent.create(recursive: true);

      // Write data
      await file.writeAsBytes(data);

      zlog(
        level: Level.debug,
        data: 'Cached image: $imageUrl (${data.length} bytes)',
      );

      // Check cache size and clean if needed
      await _cleanCacheIfNeeded();
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error caching image: $e\n$stackTrace',
      );
    }
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    try {
      final dir = await _getCacheDirectory();

      if (await dir.exists()) {
        await dir.delete(recursive: true);
        zlog(
          level: Level.info,
          data: 'Image cache cleared',
        );
      }
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error clearing cache: $e\n$stackTrace',
      );
    }
  }

  /// Get total cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final dir = await _getCacheDirectory();

      if (!await dir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error calculating cache size: $e\n$stackTrace',
      );
      return 0;
    }
  }

  /// Get number of cached images
  Future<int> getCachedImageCount() async {
    try {
      final dir = await _getCacheDirectory();

      if (!await dir.exists()) {
        return 0;
      }

      int count = 0;
      await for (final entity in dir.list()) {
        if (entity is File) {
          count++;
        }
      }

      return count;
    } catch (e) {
      return 0;
    }
  }

  /// Delete specific cached image
  Future<void> deleteCachedImage(String imageUrl) async {
    try {
      final file = await _getCacheFile(imageUrl);

      if (await file.exists()) {
        await file.delete();
        zlog(
          level: Level.debug,
          data: 'Deleted cached image: $imageUrl',
        );
      }
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error deleting cached image: $e\n$stackTrace',
      );
    }
  }

  /// Get cache directory
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(appDir.path, _cacheDir));
  }

  /// Get cache file for URL
  Future<File> _getCacheFile(String imageUrl) async {
    final dir = await _getCacheDirectory();

    // Create safe filename from URL
    final filename = _sanitizeFilename(imageUrl);

    return File(path.join(dir.path, filename));
  }

  /// Clean cache if it exceeds max size (LRU eviction)
  Future<void> _cleanCacheIfNeeded() async {
    try {
      final size = await getCacheSize();

      if (size <= _maxCacheSize) {
        return;
      }

      zlog(
        level: Level.info,
        data:
            'Cache size (${size ~/ 1024}KB) exceeds limit (${_maxCacheSize ~/ 1024}KB), cleaning...',
      );

      final dir = await _getCacheDirectory();

      // Get all files with their last accessed time
      final files = <MapEntry<File, DateTime>>[];
      await for (final entity in dir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          files.add(MapEntry(entity, stat.accessed));
        }
      }

      // Sort by access time (oldest first)
      files.sort((a, b) => a.value.compareTo(b.value));

      // Delete oldest files until under limit
      int currentSize = size;
      int deletedCount = 0;

      for (final entry in files) {
        if (currentSize <= _maxCacheSize * 0.8) {
          // Keep 80% of max to avoid frequent cleaning
          break;
        }

        final stat = await entry.key.stat();
        await entry.key.delete();
        currentSize -= stat.size;
        deletedCount++;
      }

      zlog(
        level: Level.info,
        data:
            'Cache cleaned: deleted $deletedCount files, new size: ${currentSize ~/ 1024}KB',
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error cleaning cache: $e\n$stackTrace',
      );
    }
  }

  /// Sanitize URL to create safe filename
  String _sanitizeFilename(String url) {
    // Extract meaningful parts and create hash
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;

    if (pathSegments.isNotEmpty) {
      final lastSegment = pathSegments.last;
      // Remove query params and keep just filename
      return lastSegment.split('?').first;
    }

    // Fallback: use hash of full URL
    return url.hashCode.abs().toString() + '.jpg';
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final size = await getCacheSize();
    final count = await getCachedImageCount();

    return {
      'size': size,
      'sizeKB': size ~/ 1024,
      'sizeMB': size ~/ (1024 * 1024),
      'count': count,
      'maxSize': _maxCacheSize,
      'maxSizeMB': _maxCacheSize ~/ (1024 * 1024),
      'percentFull': size / _maxCacheSize * 100,
    };
  }
}
