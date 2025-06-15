// // file: data/tutorials/datasource/tutorial_datasource_impl.dart
//
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:logger/logger.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart'; // Your zlog helper
// import 'package:zporter_tactical_board/data/admin/datasource/tutorial_datasource.dart';
// import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
//
// const String DEFAULT_TUTORIALS_COLLECTION = "defaultTutorials";
//
// class TutorialDatasourceImpl implements TutorialDatasource {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   late final CollectionReference<Map<String, dynamic>> _tutorialsRef;
//
//   TutorialDatasourceImpl() {
//     _tutorialsRef = _firestore.collection(DEFAULT_TUTORIALS_COLLECTION);
//   }
//
//   @override
//   Future<List<Tutorial>> getAllTutorials() async {
//     zlog(level: Level.info, data: "Firestore DS: Fetching all tutorials...");
//     try {
//       final snapshot = await _tutorialsRef.get();
//       if (snapshot.docs.isEmpty) {
//         zlog(level: Level.debug, data: "Firestore DS: No tutorials found.");
//         return [];
//       }
//       return snapshot.docs.map((doc) => Tutorial.fromJson(doc.data())).toList();
//     } catch (e) {
//       zlog(
//           level: Level.error,
//           data: "Firestore DS: Error getting tutorials: $e");
//       throw Exception("Failed to fetch tutorials.");
//     }
//   }
//
//   @override
//   Future<Tutorial> saveTutorial(Tutorial tutorial) async {
//     try {
//       String docId = tutorial.id.isEmpty ? _tutorialsRef.doc().id : tutorial.id;
//       final tutorialToSave = tutorial.copyWith(id: docId);
//       await _tutorialsRef.doc(docId).set(tutorialToSave.toJson());
//       zlog(level: Level.debug, data: "Firestore DS: Saved tutorial ID: $docId");
//       return tutorialToSave;
//     } catch (e) {
//       zlog(
//           level: Level.error,
//           data: "Firestore DS: Error saving tutorial ${tutorial.id}: $e");
//       throw Exception("Failed to save tutorial.");
//     }
//   }
//
//   @override
//   Future<void> deleteTutorial(String tutorialId) async {
//     try {
//       await _tutorialsRef.doc(tutorialId).delete();
//       zlog(
//           level: Level.debug,
//           data: "Firestore DS: Deleted tutorial ID: $tutorialId");
//     } catch (e) {
//       zlog(
//           level: Level.error,
//           data: "Firestore DS: Error deleting tutorial $tutorialId: $e");
//       throw Exception("Failed to delete tutorial.");
//     }
//   }
//
//   @override
//   Future<String> uploadVideo(File videoFile, String tutorialId) async {
//     try {
//       final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
//       final storagePath = 'tutorials/$tutorialId/$fileName';
//       final ref = _storage.ref().child(storagePath);
//
//       zlog(
//           level: Level.info,
//           data: "Storage DS: Uploading video to $storagePath");
//
//       UploadTask uploadTask = ref.putFile(videoFile);
//       TaskSnapshot snapshot = await uploadTask;
//       String downloadUrl = await snapshot.ref.getDownloadURL();
//
//       zlog(
//           level: Level.debug,
//           data: "Storage DS: Upload complete. URL: $downloadUrl");
//       return downloadUrl;
//     } on FirebaseException catch (e) {
//       zlog(
//           level: Level.error,
//           data: "Storage DS: Firebase error uploading video: ${e.message}");
//       throw Exception("Video upload failed: ${e.message}");
//     } catch (e) {
//       zlog(
//           level: Level.error,
//           data: "Storage DS: Generic error uploading video: $e");
//       throw Exception("An unknown error occurred during video upload.");
//     }
//   }
// }

// file: data/tutorials/datasource/tutorial_datasource_appwrite_impl.dart

// file: data/tutorials/datasource/tutorial_datasource_hybrid_impl.dart

import 'dart:io';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/admin/datasource/tutorial_datasource.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart'; // Your zlog helper

// --- Appwrite & Firebase Constants ---
const String _videosBucketId = "684e06ba00040901ce09";
const String _tutorialsCollection = "defaultTutorials";

class TutorialDatasourceHybridImpl implements TutorialDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final appwrite.Storage _appwriteStorage;
  // We need the Appwrite endpoint and project ID to construct the final URL
  final String _appwriteEndpoint;
  final String _appwriteProjectId;

  late final CollectionReference<Map<String, dynamic>> _tutorialsRef;

  TutorialDatasourceHybridImpl({
    required appwrite.Storage appwriteStorage,
    required String appwriteEndpoint,
    required String appwriteProjectId,
  })  : _appwriteStorage = appwriteStorage,
        _appwriteEndpoint = appwriteEndpoint,
        _appwriteProjectId = appwriteProjectId {
    _tutorialsRef = _firestore.collection(_tutorialsCollection);
  }

  // --- Firestore Methods ---

  @override
  Future<List<Tutorial>> getAllTutorials() async {
    zlog(data: "Firestore DS: Fetching all tutorials...");
    final snapshot = await _tutorialsRef.get();
    return snapshot.docs.map((doc) => Tutorial.fromJson(doc.data())).toList();
  }

  @override
  Future<Tutorial> saveTutorial(Tutorial tutorial) async {
    zlog(data: "Firestore DS: Saving tutorial ${tutorial.name}");
    String docId = tutorial.id.isEmpty ? _tutorialsRef.doc().id : tutorial.id;
    final tutorialToSave = tutorial.copyWith(id: docId);
    await _tutorialsRef.doc(docId).set(tutorialToSave.toJson());
    return tutorialToSave;
  }

  @override
  Future<void> deleteTutorial(String tutorialId) async {
    zlog(data: "Firestore DS: Deleting tutorial ID: $tutorialId");
    await _tutorialsRef.doc(tutorialId).delete();
  }

  // --- Appwrite Method ---

  @override
  Future<String> uploadVideo(File videoFile, String tutorialId) async {
    zlog(data: "Appwrite Storage: Uploading video for tutorial $tutorialId");
    try {
      final file = await _appwriteStorage.createFile(
        bucketId: _videosBucketId,
        fileId: appwrite.ID.unique(),
        file: appwrite.InputFile.fromPath(
            path: videoFile.path, filename: 'tutorial_video.mp4'),
      );

      // Manually construct the public URL for the file
      final fileId = file.$id;
      final url =
          "$_appwriteEndpoint/storage/buckets/$_videosBucketId/files/$fileId/view?project=$_appwriteProjectId";

      zlog(data: "Appwrite Storage: Upload complete. URL: $url");
      return url;
    } on appwrite.AppwriteException catch (e) {
      zlog(data: "Appwrite Storage: Error uploading video: ${e.message}");
      throw Exception("Video upload failed.");
    }
  }
}
