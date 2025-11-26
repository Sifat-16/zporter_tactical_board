import 'dart:io';

import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';

abstract class TutorialRepository {
  Future<List<Tutorial>> getAllTutorials();
  Future<Tutorial> saveTutorial(Tutorial tutorial);
  Future<void> deleteTutorial(String tutorialId);
  Future<String> uploadVideo(File videoFile, String tutorialId);
  Future<String> uploadThumbnail(File imageFile, String tutorialId);
  Future<void> saveAllTutorials(List<Tutorial> tutorials);

  // --- NEW METHODS ---
  Future<String> uploadMediaFile(File mediaFile, String tutorialId);
  Future<void> deleteMediaFile(String mediaUrl);
}
