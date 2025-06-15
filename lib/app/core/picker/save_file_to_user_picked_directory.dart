import 'dart:io'; // For File operations

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

Future<String?> saveAppFileToUserSelectedLocation({
  required String sourceFilePath,
  required String suggestedFileName,
  MimeType mimeType =
      MimeType.other, // Default, specify for known types like MimeType.png
}) async {
  try {
    File sourceFile = File(sourceFilePath);
    if (!await sourceFile.exists()) {
      if (kDebugMode) {
        print('Source file does not exist: $sourceFilePath');
      }
      return null;
    }

    Uint8List fileBytes = await sourceFile.readAsBytes();
    String baseName =
        "${p.basenameWithoutExtension(suggestedFileName)}${DateTime.now().millisecondsSinceEpoch}";
    String extension = p.extension(suggestedFileName);
    if (extension.startsWith('.')) {
      extension = extension.substring(1);
    }

    // FileSaver.instance.saveFile will open a system dialog.
    // The user chooses the directory AND can confirm/edit the file name.
    // This process handles permissions correctly for Android's Scoped Storage.
    String? savedPath = await FileSaver.instance.saveAs(
      name: baseName, // Name without extension
      bytes: fileBytes,
      ext: extension, // File extension
      mimeType: mimeType,
    );

    if (kDebugMode) {
      if (savedPath!.isNotEmpty) {
        print('File saved successfully at: $savedPath');
      } else {
        print('File saving cancelled by user or failed.');
      }
    }
    return savedPath;
  } catch (e) {
    if (kDebugMode) {
      print('Error using FileSaver: $e');
    }
    return null;
  }
}
