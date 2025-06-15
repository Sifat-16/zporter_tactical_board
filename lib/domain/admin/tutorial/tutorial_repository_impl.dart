import 'dart:io';

import 'package:zporter_tactical_board/data/admin/datasource/tutorial_datasource.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
import 'package:zporter_tactical_board/domain/admin/tutorial/tutorial_repository.dart';

class TutorialRepositoryImpl implements TutorialRepository {
  final TutorialDatasource datasource;

  TutorialRepositoryImpl({required this.datasource});

  @override
  Future<List<Tutorial>> getAllTutorials() => datasource.getAllTutorials();

  @override
  Future<Tutorial> saveTutorial(Tutorial tutorial) =>
      datasource.saveTutorial(tutorial);

  @override
  Future<void> deleteTutorial(String tutorialId) =>
      datasource.deleteTutorial(tutorialId);

  @override
  Future<String> uploadVideo(File videoFile, String tutorialId) =>
      datasource.uploadVideo(videoFile, tutorialId);
}
