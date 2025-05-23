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

  Future<void> loadAllDefaultAnimations() async {
    state = state.copyWith(
      status: DefaultAnimationStatus.loading,
      clearError: true,
    );
    zlog(data: "Controller: Loading all default animations...");
    try {
      final animations = await _repository.getAllDefaultAnimations();
      zlog(data: "Controller: Loaded ${animations.length} default animations.");
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
        fieldColor:
            animationDataFromDialog
                .fieldColor, // Color from dialog (or default if not set there)
        animationScenes: [
          AnimationItemModel(
            id: RandomGenerator.generateId(),
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

  Future<void> deleteDefaultAnimation(String animationId) async {
    state = state.copyWith(
      status: DefaultAnimationStatus.loading,
      clearError: true,
    );
    try {
      await _repository.deleteDefaultAnimation(animationId);

      // Remove from local state list
      final updatedList = List<AnimationModel>.from(state.defaultAnimations)
        ..removeWhere((anim) => anim.id == animationId);
      state = state.copyWith(
        status: DefaultAnimationStatus.success,
        defaultAnimations: updatedList,
      );
      zlog(
        data: "Controller: Deleted default animation with ID '$animationId'.",
      );
    } catch (e, stackTrace) {
      zlog(
        data: "Controller: Error deleting default animation: $e\n$stackTrace",
      );
      state = state.copyWith(
        status: DefaultAnimationStatus.error,
        errorMessage: e.toString(),
      );
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
