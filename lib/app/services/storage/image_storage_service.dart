import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

/// Service for uploading and managing images in Firebase Storage
/// Replaces base64 inline images with cloud URLs to reduce document size
class ImageStorageService {
  final FirebaseStorage _storage;

  ImageStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Upload player image to Firebase Storage
  /// Returns the download URL
  Future<String> uploadPlayerImage({
    required String userId,
    required String playerId,
    required Uint8List imageData,
  }) async {
    try {
      final path = 'users/$userId/players/$playerId.jpg';
      print(
          '[ImageStorage] Uploading player image to: $path (${imageData.length} bytes)');

      final ref = _storage.ref().child(path);
      print('[ImageStorage] Storage reference created: ${ref.fullPath}');

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'playerId': playerId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      print('[ImageStorage] Starting putData...');
      final uploadTask = await ref.putData(imageData, metadata);
      print('[ImageStorage] putData completed, state: ${uploadTask.state}');

      print('[ImageStorage] Getting download URL...');
      final downloadUrl = await ref.getDownloadURL();
      print(
          '[ImageStorage] ✅ Player image uploaded successfully: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      print('[ImageStorage] ❌ Error uploading player image: $e\n$stackTrace');
      throw Exception('Failed to upload player image: $e');
    }
  }

  /// Upload equipment image to Firebase Storage
  /// Returns the download URL
  Future<String> uploadEquipmentImage({
    required String userId,
    required String equipmentId,
    required Uint8List imageData,
  }) async {
    try {
      final path = 'users/$userId/equipment/$equipmentId.jpg';
      zlog(
        level: Level.debug,
        data: 'Uploading equipment image to: $path',
      );

      final ref = _storage.ref().child(path);

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'equipmentId': equipmentId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      await ref.putData(imageData, metadata);
      final downloadUrl = await ref.getDownloadURL();

      zlog(
        level: Level.info,
        data: 'Equipment image uploaded successfully: $downloadUrl',
      );

      return downloadUrl;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error uploading equipment image: $e\n$stackTrace',
      );
      throw Exception('Failed to upload equipment image: $e');
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments.last;

      zlog(
        level: Level.debug,
        data: 'Deleting image: $path',
      );

      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();

      zlog(
        level: Level.info,
        data: 'Image deleted successfully: $path',
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.warning,
        data: 'Error deleting image (may not exist): $e\n$stackTrace',
      );
      // Don't throw - image might already be deleted
    }
  }

  /// Download image from Firebase Storage
  Future<Uint8List?> downloadImage(String imageUrl) async {
    try {
      zlog(
        level: Level.debug,
        data: 'Downloading image from: $imageUrl',
      );

      final ref = _storage.refFromURL(imageUrl);
      final data = await ref.getData();

      zlog(
        level: Level.debug,
        data: 'Image downloaded successfully: ${data?.length ?? 0} bytes',
      );

      return data;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error downloading image: $e\n$stackTrace',
      );
      return null;
    }
  }

  /// Get image metadata
  Future<FullMetadata?> getImageMetadata(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      final metadata = await ref.getMetadata();
      return metadata;
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: 'Error getting image metadata: $e\n$stackTrace',
      );
      return null;
    }
  }

  /// Check if image exists in storage
  Future<bool> imageExists(String imageUrl) async {
    try {
      final metadata = await getImageMetadata(imageUrl);
      return metadata != null;
    } catch (e) {
      return false;
    }
  }

  /// Get storage bucket URL
  String get bucketUrl => 'gs://${_storage.bucket}';
}
