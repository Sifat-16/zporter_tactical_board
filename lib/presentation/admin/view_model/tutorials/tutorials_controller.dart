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

  // Future<void> fetchTutorials() async {
  //   try {
  //     state = state.copyWith(status: TutorialStatus.loading);
  //     final tutorials = await _repository.getAllTutorials();
  //     state =
  //         state.copyWith(status: TutorialStatus.success, tutorials: tutorials);
  //   } catch (e) {
  //     state = state.copyWith(
  //         status: TutorialStatus.error, errorMessage: e.toString());
  //   }
  // }

  Future<void> fetchTutorials() async {
    try {
      state = state.copyWith(status: TutorialStatus.loading);
      final tutorials = await _repository.getAllTutorials();
      // MODIFIED: Sort the list after fetching
      tutorials.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
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

  // Future<void> deleteTutorial(String tutorialId) async {
  //   try {
  //     await _repository.deleteTutorial(tutorialId);
  //     final updatedList =
  //         state.tutorials.where((t) => t.id != tutorialId).toList();
  //     state = state.copyWith(tutorials: updatedList);
  //   } catch (e) {
  //     // Handle error
  //   }
  // }

  Future<void> deleteTutorial(String tutorialId) async {
    try {
      await _repository.deleteTutorial(tutorialId);
      final listAfterDelete =
          state.tutorials.where((t) => t.id != tutorialId).toList();

      // MODIFIED: Re-index the remaining items and save the new order
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
      return ''; // Return empty string on failure
    }
  }

  Future<void> uploadThumbnailForTutorial(
      File imageFile, String tutorialId) async {
    state = state.copyWith(status: TutorialStatus.uploading);
    try {
      // 1. Upload the image and get the URL
      final thumbnailUrl =
          await _repository.uploadThumbnail(imageFile, tutorialId);

      // 2. Find the tutorial to update in the current state
      final tutorialToUpdate =
          state.tutorials.firstWhere((t) => t.id == tutorialId);

      // 3. Create an updated model with the new thumbnail URL
      final updatedTutorial =
          tutorialToUpdate.copyWith(thumbnailUrl: thumbnailUrl);

      // 4. Save the updated tutorial back to Firestore and update the local state
      await updateTutorial(updatedTutorial);

      state = state.copyWith(status: TutorialStatus.success);
    } catch (e) {
      state = state.copyWith(
          status: TutorialStatus.error, errorMessage: e.toString());
    }
  }

  Future<Tutorial?> addAndReturnTutorial(String name) async {
    try {
      // Add orderIndex to the new tutorial
      final newTutorial = await _repository.saveTutorial(
        Tutorial(id: '', name: name, orderIndex: state.tutorials.length),
      );
      state = state.copyWith(tutorials: [...state.tutorials, newTutorial]);
      return newTutorial;
    } catch (e) {
      return null;
    }
  }

  Future<void> reorderTutorials(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final list = List<Tutorial>.from(state.tutorials);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    // Re-assign the correct orderIndex to all items
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(orderIndex: i);
    }

    // Optimistically update the UI
    state = state.copyWith(tutorials: list, status: TutorialStatus.success);

    // Persist the changes
    try {
      await _repository.saveAllTutorials(list);
    } catch (e) {
      // On failure, refetch to revert the UI to the last known good state
      fetchTutorials();
    }
  }
}

// --- PROVIDER ---
final tutorialsProvider =
    StateNotifierProvider<TutorialsController, TutorialsState>((ref) {
  return TutorialsController();
});
