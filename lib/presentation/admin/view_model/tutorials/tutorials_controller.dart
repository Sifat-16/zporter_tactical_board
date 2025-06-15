import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';
import 'package:zporter_tactical_board/domain/admin/tutorial/tutorial_repository.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_state.dart';

class TutorialsController extends StateNotifier<TutorialsState> {
  final TutorialRepository _repository = sl.get();

  TutorialsController() : super(const TutorialsState()) {
    fetchTutorials();
  }

  Future<void> fetchTutorials() async {
    try {
      state = state.copyWith(status: TutorialStatus.loading);
      final tutorials = await _repository.getAllTutorials();
      state =
          state.copyWith(status: TutorialStatus.success, tutorials: tutorials);
    } catch (e) {
      state = state.copyWith(
          status: TutorialStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> addTutorial(String name) async {
    try {
      final newTutorial =
          await _repository.saveTutorial(Tutorial(id: '', name: name));
      state = state.copyWith(tutorials: [...state.tutorials, newTutorial]);
    } catch (e) {
      // Handle error, maybe show a snackbar
    }
  }

  Future<void> updateTutorial(Tutorial tutorial) async {
    try {
      await _repository.saveTutorial(tutorial);
      final updatedList = [
        for (final t in state.tutorials)
          if (t.id == tutorial.id) tutorial else t
      ];
      state = state.copyWith(tutorials: updatedList);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteTutorial(String tutorialId) async {
    try {
      await _repository.deleteTutorial(tutorialId);
      final updatedList =
          state.tutorials.where((t) => t.id != tutorialId).toList();
      state = state.copyWith(tutorials: updatedList);
    } catch (e) {
      // Handle error
    }
  }

  Future<String> uploadVideoForTutorial(
      File videoFile, String tutorialId) async {
    state = state.copyWith(status: TutorialStatus.uploading);
    try {
      final url = await _repository.uploadVideo(videoFile, tutorialId);
      state = state.copyWith(status: TutorialStatus.success);
      return url;
    } catch (e) {
      state = state.copyWith(
          status: TutorialStatus.error, errorMessage: e.toString());
      return ''; // Return empty string on failure
    }
  }
}

// --- PROVIDER ---
final tutorialsProvider =
    StateNotifierProvider<TutorialsController, TutorialsState>((ref) {
  return TutorialsController();
});
