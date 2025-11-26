import 'dart:io';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/admin/datasource/tutorial_datasource.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';

// --- Appwrite & Firebase Constants ---
const String _videosBucketId = "684e06ba00040901ce09";
const String _thumbnailsBucketId = "684e06ba00040901ce09";
// --- NEW BUCKET ID FOR MEDIA GALLERY ---
const String _mediaBucketId =
    "684e06ba00040901ce09"; // Assuming a new bucket for media
const String _tutorialsCollection = "defaultTutorials";

class TutorialDatasourceHybridImpl implements TutorialDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final appwrite.Storage _appwriteStorage;
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

  @override
  Future<String> uploadThumbnail(File imageFile, String tutorialId) async {
    zlog(
        data: "Appwrite Storage: Uploading thumbnail for tutorial $tutorialId");
    try {
      final file = await _appwriteStorage.createFile(
        bucketId: _thumbnailsBucketId,
        fileId: appwrite.ID.unique(),
        file: appwrite.InputFile.fromPath(path: imageFile.path),
      );
      final fileId = file.$id;
      final url =
          "$_appwriteEndpoint/storage/buckets/$_thumbnailsBucketId/files/$fileId/view?project=$_appwriteProjectId";
      zlog(data: "Appwrite Storage: Thumbnail upload complete. URL: $url");
      return url;
    } on appwrite.AppwriteException catch (e) {
      zlog(data: "Appwrite Storage: Error uploading thumbnail: ${e.message}");
      throw Exception("Thumbnail upload failed.");
    }
  }

  @override
  Future<void> saveAllTutorials(List<Tutorial> tutorials) async {
    zlog(data: "Firestore DS: Batch-saving ${tutorials.length} tutorials...");
    final batch = _firestore.batch();
    try {
      for (final tutorial in tutorials) {
        final docRef = _tutorialsRef.doc(tutorial.id);
        batch.set(docRef, tutorial.toJson());
      }
      await batch.commit();
      zlog(data: "Firestore DS: Batch-save for tutorials complete.");
    } catch (e) {
      zlog(data: "Firestore DS: Error batch-saving tutorials: $e");
      throw Exception("Error saving tutorial order: $e");
    }
  }

  // --- NEW METHOD IMPLEMENTATIONS ---

  @override
  Future<String> uploadMediaFile(File mediaFile, String tutorialId) async {
    zlog(data: "Appwrite Storage: Uploading media for tutorial $tutorialId");
    try {
      final file = await _appwriteStorage.createFile(
        bucketId: _mediaBucketId, // Use the dedicated media bucket
        fileId: appwrite.ID.unique(),
        file: appwrite.InputFile.fromPath(path: mediaFile.path),
      );
      final fileId = file.$id;
      final url =
          "$_appwriteEndpoint/storage/buckets/$_mediaBucketId/files/$fileId/view?project=$_appwriteProjectId";
      zlog(data: "Appwrite Storage: Media upload complete. URL: $url");
      return url;
    } on appwrite.AppwriteException catch (e) {
      zlog(data: "Appwrite Storage: Error uploading media: ${e.message}");
      throw Exception("Media file upload failed.");
    }
  }

  @override
  Future<void> deleteMediaFile(String mediaUrl) async {
    zlog(data: "Appwrite Storage: Deleting media file: $mediaUrl");
    try {
      // Extract the bucketId and fileId from the URL
      final uri = Uri.parse(mediaUrl);
      final pathSegments = uri.pathSegments;
      // Expected path: /storage/buckets/{bucketId}/files/{fileId}/view
      if (pathSegments.length >= 5) {
        final bucketId = pathSegments[2];
        final fileId = pathSegments[4];
        await _appwriteStorage.deleteFile(bucketId: bucketId, fileId: fileId);
        zlog(
            data:
                "Appwrite Storage: Successfully deleted file $fileId from bucket $bucketId");
      } else {
        throw Exception("Invalid media URL format.");
      }
    } on appwrite.AppwriteException catch (e) {
      zlog(data: "Appwrite Storage: Error deleting media file: ${e.message}");
      // Don't throw an exception here, as the user might be deleting a URL
      // that was already deleted. Just log the error.
    }
  }
}
