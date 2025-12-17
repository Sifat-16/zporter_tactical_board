import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart'; // Using your logger

class FirebaseStorageService {
  static const String _storageAppName =
      'StorageProject'; // A unique name for our 2nd project

  // 1. This function initializes your secondary Firebase Project (Project B)
  static Future<void> initializeSecondaryApp(FirebaseOptions options) async {
    try {
      // Check if it's already initialized to avoid errors on hot reload
      Firebase.app(_storageAppName);
    } catch (e) {
      // If not found, initialize it
      await Firebase.initializeApp(
        name: _storageAppName,
        options: options,
      );
    }
  }

  // 2. This is the upload function we will call from your dialog
  Future<String> uploadPlayerImage({
    required File imageFile,
    required String playerId,
  }) async {
    try {
      // 3. Get the FirebaseApp instance we just initialized
      final FirebaseApp storageApp = Firebase.app(_storageAppName);

      // 4. Get the Storage service for THAT specific app instance
      final FirebaseStorage storage =
          FirebaseStorage.instanceFor(app: storageApp);

      // 5. Create a unique path in your storage bucket
      final String filePath = 'football_pad/player_images/$playerId.jpg';
      final Reference ref = storage.ref().child(filePath);

      // 6. Upload the file
      zlog(
          data: "Uploading image to $filePath in bucket: ${storage.bucket}...");
      UploadTask task = ref.putFile(imageFile);
      TaskSnapshot snapshot = await task;

      // 7. Get the permanent download URL and return it
      String downloadURL = await snapshot.ref.getDownloadURL();
      zlog(data: "Upload complete. URL: $downloadURL");
      return downloadURL;
    } on FirebaseException catch (e) {
      zlog(
          level: Level.error,
          data: "Firebase Storage upload error: ${e.message}");
      rethrow; // Re-throw to be caught by the UI
    } catch (e) {
      zlog(level: Level.error, data: "General upload error: $e");
      rethrow;
    }
  }

  // Upload player image from bytes (for base64 migration)
  Future<String> uploadPlayerImageFromBytes({
    required List<int> imageBytes,
    required String playerId,
  }) async {
    try {
      final FirebaseApp storageApp = Firebase.app(_storageAppName);
      final FirebaseStorage storage =
          FirebaseStorage.instanceFor(app: storageApp);

      final String filePath = 'football_pad/player_images/$playerId.jpg';
      final Reference ref = storage.ref().child(filePath);

      zlog(
          data:
              "[Migration] Uploading image bytes to $filePath in bucket: ${storage.bucket}...");

      // Upload bytes directly
      UploadTask task = ref.putData(
        Uint8List.fromList(imageBytes),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      TaskSnapshot snapshot = await task;

      String downloadURL = await snapshot.ref.getDownloadURL();
      zlog(data: "[Migration] Upload complete. URL: $downloadURL");
      return downloadURL;
    } on FirebaseException catch (e) {
      zlog(
          level: Level.error,
          data: "[Migration] Firebase Storage upload error: ${e.message}");
      rethrow;
    } catch (e) {
      zlog(level: Level.error, data: "[Migration] General upload error: $e");
      rethrow;
    }
  }
}
