import 'dart:io';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';

abstract class TutorialDatasource {
  Future<List<Tutorial>> getAllTutorials();
  Future<Tutorial> saveTutorial(Tutorial tutorial);
  Future<void> deleteTutorial(String tutorialId);
  Future<String> uploadVideo(File videoFile, String tutorialId);
}
