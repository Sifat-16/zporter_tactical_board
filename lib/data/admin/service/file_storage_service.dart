import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';

class FileStorageService {
  final FirebaseStorage _storage;

  FileStorageService(this._storage);

  /// Uploads a file to a specified path in Firebase Storage and returns the download URL.
  Future<String> uploadFile(File file, String path) async {
    try {
      final fileName =
          '${RandomGenerator.generateId()}_${file.path.split('/').last}';
      final fullPath = '$path/$fileName';

      final ref = _storage.ref().child(fullPath);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage Error: ${e.message}');
      rethrow; // Rethrow to be handled by the ViewModel
    } catch (e) {
      debugPrint('General File Upload Error: $e');
      rethrow;
    }
  }
}
