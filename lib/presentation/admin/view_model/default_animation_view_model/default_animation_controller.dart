import 'package:flame/components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart'; // Your zlog
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart'; // Your GetIt instance (sl)
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/domain/admin/default_animation/default_animation_repository.dart'; // Your Abstract Repo for Default Animations

import 'default_animation_state.dart';

const String DEFAULT_ANIMATIONS_FIRESTORE_COLLECTION = "defaultAnimations";

const String SYSTEM_USER_ID_FOR_DEFAULTS = "system_default_user_for_animations";

final defaultAnimationControllerProvider =
    StateNotifierProvider<DefaultAnimationController, DefaultAnimationState>((
  ref,
) {
  return DefaultAnimationController();
});

// --- Controller ---
class DefaultAnimationController extends StateNotifier<DefaultAnimationState> {
  DefaultAnimationController() : super(const DefaultAnimationState()) {
    loadAllDefaultAnimations();
  }

  final DefaultAnimationRepository _repository = sl.get();

  // Future<void> loadAllDefaultAnimations() async {
  //   state = state.copyWith(
  //     status: DefaultAnimationStatus.loading,
  //     clearError: true,
  //   );
  //   zlog(data: "Controller: Loading all default animations...");
  //   try {
  //     final animations = await _repository.getAllDefaultAnimations();
  //     zlog(data: "Controller: Loaded ${animations.length} default animations.");
  //     state = state.copyWith(
  //       status: DefaultAnimationStatus.success,
  //       defaultAnimations: animations,
  //     );
  //   } catch (e, stackTrace) {
  //     zlog(
  //       data: "Controller: Error loading default animations: $e\n$stackTrace",
  //     );
  //     state = state.copyWith(
  //       status: DefaultAnimationStatus.error,
  //       errorMessage: e.toString(),
  //     );
  //   }
  // }

  Future<void> loadAllDefaultAnimations() async {
    state = state.copyWith(
      status: DefaultAnimationStatus.loading,
      clearError: true,
    );
    zlog(data: "Controller: Loading all default animations...");
    try {
      final animations = await _repository.getAllDefaultAnimations();

      // ## THE FIX: Sort the list here in the controller ##
      animations.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      zlog(
          data:
              "Controller: Loaded and sorted ${animations.length} default animations.");
      state = state.copyWith(
        status: DefaultAnimationStatus.success,
        defaultAnimations: animations,
      );
    } catch (e, stackTrace) {
      zlog(
        data: "Controller: Error loading default animations: $e\n$stackTrace",
      );
      state = state.copyWith(
        status: DefaultAnimationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addDefaultAnimation(
    AnimationModel animationDataFromDialog,
  ) async {
    state = state.copyWith(
      status: DefaultAnimationStatus.loading,
      clearError: true,
    );
    try {
      // Ensure the new animation has a unique ID and the system user ID
      final animationToAdd = AnimationModel(
        id: RandomGenerator.generateId(), // Generate new ID
        name: animationDataFromDialog.name, // Name from dialog
        userId: SYSTEM_USER_ID_FOR_DEFAULTS, // Enforce system user ID
        fieldColor: animationDataFromDialog
            .fieldColor, // Color from dialog (or default if not set there)
        orderIndex: state.defaultAnimations.length,
        animationScenes: [
          AnimationItemModel(
            id: RandomGenerator.generateId(),
            index: 0,
            components: [],
            createdAt: DateTime.now(),
            userId: SYSTEM_USER_ID_FOR_DEFAULTS,
            fieldColor: ColorManager.grey,
            updatedAt: DateTime.now(),
            fieldSize: Vector2(1280, 720),
          ),
        ], // New default animations start with no scenes
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final savedAnimation = await _repository.saveDefaultAnimation(
        animationToAdd,
      );

      // Add to local state list
      final updatedList = List<AnimationModel>.from(state.defaultAnimations)
        ..add(savedAnimation);
      state = state.copyWith(
        status: DefaultAnimationStatus.success,
        defaultAnimations: updatedList,
      );
      zlog(
        data:
            "Controller: Added default animation '${savedAnimation.name}' with ID ${savedAnimation.id}.",
      );
    } catch (e, stackTrace) {
      zlog(data: "Controller: Error adding default animation: $e\n$stackTrace");
      state = state.copyWith(
        status: DefaultAnimationStatus.error,
        errorMessage: e.toString(),
      );
      // Optionally, reload all to ensure consistency if partial save is a concern
      // await loadAllDefaultAnimations();
    }
  }

  Future<void> editDefaultAnimation(
    AnimationModel animationToUpdateFromDialog,
  ) async {
    if (animationToUpdateFromDialog.id.isEmpty) {
      zlog(data: "Controller: Animation ID is empty. Cannot edit.");
      state = state.copyWith(
        status: DefaultAnimationStatus.error,
        errorMessage: "Animation ID for edit is empty.",
      );
      return;
    }
    state = state.copyWith(
      status: DefaultAnimationStatus.loading,
      clearError: true,
    );
    try {
      // Ensure system userId and update timestamp
      final animationWithSystemData = animationToUpdateFromDialog.copyWith(
        userId: SYSTEM_USER_ID_FOR_DEFAULTS,
        updatedAt: DateTime.now(),
      );

      final savedAnimation = await _repository.saveDefaultAnimation(
        animationWithSystemData,
      );

      // Update in local state list
      final updatedList = List<AnimationModel>.from(state.defaultAnimations);
      final index = updatedList.indexWhere(
        (anim) => anim.id == savedAnimation.id,
      );
      if (index != -1) {
        updatedList[index] = savedAnimation;
        state = state.copyWith(
          status: DefaultAnimationStatus.success,
          defaultAnimations: updatedList,
        );
        zlog(
          data:
              "Controller: Edited default animation '${savedAnimation.name}'.",
        );
      } else {
        zlog(
          data:
              "Controller: Edited animation '${savedAnimation.name}' but it was not found in local state. Reloading.",
        );
        await loadAllDefaultAnimations(); // Reload if not found (should ideally not happen)
      }
    } catch (e, stackTrace) {
      zlog(
        data: "Controller: Error editing default animation: $e\n$stackTrace",
      );
      state = state.copyWith(
        status: DefaultAnimationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Future<void> deleteDefaultAnimation(String animationId) async {
  //   state = state.copyWith(
  //     status: DefaultAnimationStatus.loading,
  //     clearError: true,
  //   );
  //   try {
  //     await _repository.deleteDefaultAnimation(animationId);
  //
  //     // Remove from local state list
  //     final updatedList = List<AnimationModel>.from(state.defaultAnimations)
  //       ..removeWhere((anim) => anim.id == animationId);
  //     state = state.copyWith(
  //       status: DefaultAnimationStatus.success,
  //       defaultAnimations: updatedList,
  //     );
  //     zlog(
  //       data: "Controller: Deleted default animation with ID '$animationId'.",
  //     );
  //   } catch (e, stackTrace) {
  //     zlog(
  //       data: "Controller: Error deleting default animation: $e\n$stackTrace",
  //     );
  //     state = state.copyWith(
  //       status: DefaultAnimationStatus.error,
  //       errorMessage: e.toString(),
  //     );
  //   }
  // }

  Future<void> deleteDefaultAnimation(String animationId) async {
    state = state.copyWith(
        status: DefaultAnimationStatus.loading, clearError: true);
    try {
      await _repository.deleteDefaultAnimation(animationId);

      final updatedList = List<AnimationModel>.from(state.defaultAnimations)
        ..removeWhere((anim) => anim.id == animationId);

      // MODIFIED: Re-index the remaining items after deletion
      for (int i = 0; i < updatedList.length; i++) {
        updatedList[i] = updatedList[i].copyWith(orderIndex: i);
      }

      // Save the updated order of the remaining items
      await _repository.saveAllDefaultAnimations(updatedList);

      state = state.copyWith(
          status: DefaultAnimationStatus.success,
          defaultAnimations: updatedList);
      zlog(
          data:
              "Controller: Deleted default animation with ID '$animationId' and re-indexed list.");
    } catch (e, stackTrace) {
      zlog(
          data:
              "Controller: Error deleting default animation: $e\n$stackTrace");
      state = state.copyWith(
          status: DefaultAnimationStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> reorderDefaultAnimations(int oldIndex, int newIndex) async {
    // This adjustment is needed for ReorderableListView's logic
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final list = List<AnimationModel>.from(state.defaultAnimations);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    // Re-assign the correct orderIndex to all items in the list
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(orderIndex: i);
    }

    // Optimistically update the UI with the new order
    state = state.copyWith(
        defaultAnimations: list, status: DefaultAnimationStatus.success);

    // Persist the entire re-ordered list to the database
    try {
      // Assumes your repository has a method to save all animations at once.
      // This is more efficient than saving one by one.
      await _repository.saveAllDefaultAnimations(list);
      zlog(
          data:
              "Controller: Successfully saved new order of default animations.");
    } catch (e) {
      zlog(data: "Controller: Failed to save new animation order: $e");
      // If saving fails, revert by reloading from the database to ensure consistency
      await loadAllDefaultAnimations();
    }
  }

  updateAnimationModel({required AnimationModel animationToUpdate}) {
    List<AnimationModel> animations = state.defaultAnimations;

    int index = animations.indexWhere((a) => a.id == animationToUpdate.id);
    if (index != -1) {
      animations[index] = animationToUpdate;
      state = state.copyWith(defaultAnimations: animations);
    }
  }
}
