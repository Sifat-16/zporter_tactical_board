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
      tutorials.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      state =
          state.copyWith(status: TutorialStatus.success, tutorials: tutorials);
    } catch (e) {
      state = state.copyWith(
          status: TutorialStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> updateTutorial(Tutorial tutorial) async {
    try {
      final savedTutorial = await _repository.saveTutorial(tutorial);

      final tutorials = List<Tutorial>.from(state.tutorials);
      final index = tutorials.indexWhere((t) => t.id == savedTutorial.id);

      if (index != -1) {
        tutorials[index] = savedTutorial;
      } else {
        tutorials.add(savedTutorial);
      }

      state = state.copyWith(tutorials: tutorials);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteTutorial(String tutorialId) async {
    try {
      await _repository.deleteTutorial(tutorialId);
      final listAfterDelete =
          state.tutorials.where((t) => t.id != tutorialId).toList();
      for (int i = 0; i < listAfterDelete.length; i++) {
        listAfterDelete[i] = listAfterDelete[i].copyWith(orderIndex: i);
      }
      await _repository.saveAllTutorials(listAfterDelete);
      state = state.copyWith(tutorials: listAfterDelete);
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
      return '';
    }
  }

  Future<void> uploadThumbnailForTutorial(
      File imageFile, String tutorialId) async {
    state = state.copyWith(status: TutorialStatus.uploading);
    try {
      final thumbnailUrl =
          await _repository.uploadThumbnail(imageFile, tutorialId);
      final tutorialToUpdate =
          state.tutorials.firstWhere((t) => t.id == tutorialId);
      final updatedTutorial =
          tutorialToUpdate.copyWith(thumbnailUrl: thumbnailUrl);
      await updateTutorial(updatedTutorial);
      state = state.copyWith(status: TutorialStatus.success);
    } catch (e) {
      state = state.copyWith(
          status: TutorialStatus.error, errorMessage: e.toString());
    }
  }

  Future<Tutorial?> addAndReturnTutorial(Tutorial tutorial) async {
    try {
      final tutorialToSave =
          tutorial.copyWith(orderIndex: state.tutorials.length);
      final newTutorial = await _repository.saveTutorial(tutorialToSave);
      state = state.copyWith(tutorials: [...state.tutorials, newTutorial]);
      return newTutorial;
    } catch (e) {
      return null;
    }
  }

  // --- NEW METHOD 1: UPLOAD MULTIPLE MEDIA ---
  Future<List<String>> uploadMultipleMediaForTutorial(
      List<File> files, String tutorialId) async {
    state = state.copyWith(status: TutorialStatus.uploading);
    try {
      final uploadTasks = files
          .map((file) => _repository.uploadMediaFile(file, tutorialId))
          .toList();

      final urls = await Future.wait(uploadTasks);

      final tutorialToUpdate =
          state.tutorials.firstWhere((t) => t.id == tutorialId);
      List<String> updatedMediaUrls = [
        ...tutorialToUpdate.mediaUrls ?? [],
        ...urls
      ];
      final updatedTutorial =
          tutorialToUpdate.copyWith(mediaUrls: updatedMediaUrls);
      await updateTutorial(updatedTutorial);

      state = state.copyWith(status: TutorialStatus.success);
      return urls;
    } catch (e) {
      state = state.copyWith(
          status: TutorialStatus.error, errorMessage: e.toString());
      return [];
    }
  }

  // --- NEW METHOD 2: DELETE A SINGLE MEDIA ITEM ---
  Future<void> deleteMediaFromTutorial(
      String tutorialId, String mediaUrl) async {
    try {
      await _repository.deleteMediaFile(mediaUrl);

      final tutorialToUpdate =
          state.tutorials.firstWhere((t) => t.id == tutorialId);
      final updatedMediaUrls =
          List<String>.from(tutorialToUpdate.mediaUrls ?? []);
      updatedMediaUrls.remove(mediaUrl);

      final updatedTutorial =
          tutorialToUpdate.copyWith(mediaUrls: updatedMediaUrls);
      await updateTutorial(updatedTutorial);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> reorderTutorials(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final list = List<Tutorial>.from(state.tutorials);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(orderIndex: i);
    }
    state = state.copyWith(tutorials: list, status: TutorialStatus.success);
    try {
      await _repository.saveAllTutorials(list);
    } catch (e) {
      fetchTutorials();
    }
  }
}

final tutorialsProvider =
    StateNotifierProvider<TutorialsController, TutorialsState>((ref) {
  return TutorialsController();
});
