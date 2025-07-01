// import 'package:flame/components.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/generator/random_generator.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart'; // Your zlog
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/app/services/injection_container.dart'; // Your GetIt instance (sl)
// import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
// import 'package:zporter_tactical_board/domain/admin/default_animation/default_animation_repository.dart'; // Your Abstract Repo for Default Animations
//
// import 'default_animation_state.dart';
//
// const String DEFAULT_ANIMATIONS_FIRESTORE_COLLECTION = "defaultAnimations";
//
// const String SYSTEM_USER_ID_FOR_DEFAULTS = "system_default_user_for_animations";
//
// final defaultAnimationControllerProvider =
//     StateNotifierProvider<DefaultAnimationController, DefaultAnimationState>((
//   ref,
// ) {
//   return DefaultAnimationController();
// });
//
// // --- Controller ---
// class DefaultAnimationController extends StateNotifier<DefaultAnimationState> {
//   DefaultAnimationController() : super(const DefaultAnimationState()) {
//     loadAllDefaultAnimations();
//   }
//
//   final DefaultAnimationRepository _repository = sl.get();
//
//   static const String _otherCollectionName = "Other";
//
//   Future<void> _runMigrationIfNeeded() async {
//     final orphanedAnimations = await _repository.getOrphanedDefaultAnimations();
//     if (orphanedAnimations.isEmpty) return;
//
//     zlog(
//         data:
//             "Controller: Migrating ${orphanedAnimations.length} old animations...");
//
//     final collections = await _repository.getAllDefaultAnimationCollections();
//     AnimationCollectionModel otherCollection = collections.firstWhere(
//       (c) => c.name == _otherCollectionName,
//       orElse: () => AnimationCollectionModel(
//         id: '',
//         name: _otherCollectionName,
//         animations: [],
//         userId: SYSTEM_USER_ID_FOR_DEFAULTS,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//         orderIndex: collections.length,
//       ),
//     );
//
//     otherCollection =
//         await _repository.saveDefaultAnimationCollection(otherCollection);
//
//     for (var animation in orphanedAnimations) {
//       final updatedAnimation =
//           animation.copyWith(collectionId: otherCollection.id);
//       await _repository.saveDefaultAnimation(updatedAnimation);
//     }
//     zlog(data: "Controller: Migration complete.");
//   }
//
//   Future<void> loadAllDefaultCollections() async {
//     state = state.copyWith(
//         status: DefaultAnimationStatus.loading, clearError: true);
//     try {
//       await _runMigrationIfNeeded();
//
//       final collections = await _repository.getAllDefaultAnimationCollections();
//       final allAnimations = await _repository.getAllDefaultAnimations();
//
//       for (var collection in collections) {
//         final animationsForThisCollection = allAnimations
//             .where((anim) => anim.collectionId == collection.id)
//             .toList();
//         animationsForThisCollection
//             .sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
//         collection.animations = animationsForThisCollection;
//       }
//
//       state = state.copyWith(
//         status: DefaultAnimationStatus.success,
//         defaultAnimationCollections: collections,
//       );
//     } catch (e) {
//       state = state.copyWith(
//           status: DefaultAnimationStatus.error, errorMessage: e.toString());
//     }
//   }
//
//   // Future<void> loadAllDefaultAnimations() async {
//   //   state = state.copyWith(
//   //     status: DefaultAnimationStatus.loading,
//   //     clearError: true,
//   //   );
//   //   zlog(data: "Controller: Loading all default animations...");
//   //   try {
//   //     final animations = await _repository.getAllDefaultAnimations();
//   //     zlog(data: "Controller: Loaded ${animations.length} default animations.");
//   //     state = state.copyWith(
//   //       status: DefaultAnimationStatus.success,
//   //       defaultAnimations: animations,
//   //     );
//   //   } catch (e, stackTrace) {
//   //     zlog(
//   //       data: "Controller: Error loading default animations: $e\n$stackTrace",
//   //     );
//   //     state = state.copyWith(
//   //       status: DefaultAnimationStatus.error,
//   //       errorMessage: e.toString(),
//   //     );
//   //   }
//   // }
//
//   Future<void> loadAllDefaultAnimations() async {
//     state = state.copyWith(
//       status: DefaultAnimationStatus.loading,
//       clearError: true,
//     );
//     zlog(data: "Controller: Loading all default animations...");
//     try {
//       final animations = await _repository.getAllDefaultAnimations();
//
//       // ## THE FIX: Sort the list here in the controller ##
//       animations.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
//
//       zlog(
//           data:
//               "Controller: Loaded and sorted ${animations.length} default animations.");
//       state = state.copyWith(
//         status: DefaultAnimationStatus.success,
//         defaultAnimations: animations,
//       );
//     } catch (e, stackTrace) {
//       zlog(
//         data: "Controller: Error loading default animations: $e\n$stackTrace",
//       );
//       state = state.copyWith(
//         status: DefaultAnimationStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }
//
//   Future<void> addDefaultAnimation(
//     AnimationModel animationDataFromDialog,
//   ) async {
//     state = state.copyWith(
//       status: DefaultAnimationStatus.loading,
//       clearError: true,
//     );
//     try {
//       // Ensure the new animation has a unique ID and the system user ID
//       final animationToAdd = AnimationModel(
//         id: RandomGenerator.generateId(), // Generate new ID
//         name: animationDataFromDialog.name, // Name from dialog
//         userId: SYSTEM_USER_ID_FOR_DEFAULTS, // Enforce system user ID
//         fieldColor: animationDataFromDialog
//             .fieldColor, // Color from dialog (or default if not set there)
//         orderIndex: state.defaultAnimations.length,
//         animationScenes: [
//           AnimationItemModel(
//             id: RandomGenerator.generateId(),
//             index: 0,
//             components: [],
//             createdAt: DateTime.now(),
//             userId: SYSTEM_USER_ID_FOR_DEFAULTS,
//             fieldColor: ColorManager.grey,
//             updatedAt: DateTime.now(),
//             fieldSize: Vector2(1280, 720),
//           ),
//         ], // New default animations start with no scenes
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//
//       final savedAnimation = await _repository.saveDefaultAnimation(
//         animationToAdd,
//       );
//
//       // Add to local state list
//       final updatedList = List<AnimationModel>.from(state.defaultAnimations)
//         ..add(savedAnimation);
//       state = state.copyWith(
//         status: DefaultAnimationStatus.success,
//         defaultAnimations: updatedList,
//       );
//       zlog(
//         data:
//             "Controller: Added default animation '${savedAnimation.name}' with ID ${savedAnimation.id}.",
//       );
//     } catch (e, stackTrace) {
//       zlog(data: "Controller: Error adding default animation: $e\n$stackTrace");
//       state = state.copyWith(
//         status: DefaultAnimationStatus.error,
//         errorMessage: e.toString(),
//       );
//       // Optionally, reload all to ensure consistency if partial save is a concern
//       // await loadAllDefaultAnimations();
//     }
//   }
//
//   Future<void> editDefaultAnimation(
//     AnimationModel animationToUpdateFromDialog,
//   ) async {
//     if (animationToUpdateFromDialog.id.isEmpty) {
//       zlog(data: "Controller: Animation ID is empty. Cannot edit.");
//       state = state.copyWith(
//         status: DefaultAnimationStatus.error,
//         errorMessage: "Animation ID for edit is empty.",
//       );
//       return;
//     }
//     state = state.copyWith(
//       status: DefaultAnimationStatus.loading,
//       clearError: true,
//     );
//     try {
//       // Ensure system userId and update timestamp
//       final animationWithSystemData = animationToUpdateFromDialog.copyWith(
//         userId: SYSTEM_USER_ID_FOR_DEFAULTS,
//         updatedAt: DateTime.now(),
//       );
//
//       final savedAnimation = await _repository.saveDefaultAnimation(
//         animationWithSystemData,
//       );
//
//       // Update in local state list
//       final updatedList = List<AnimationModel>.from(state.defaultAnimations);
//       final index = updatedList.indexWhere(
//         (anim) => anim.id == savedAnimation.id,
//       );
//       if (index != -1) {
//         updatedList[index] = savedAnimation;
//         state = state.copyWith(
//           status: DefaultAnimationStatus.success,
//           defaultAnimations: updatedList,
//         );
//         zlog(
//           data:
//               "Controller: Edited default animation '${savedAnimation.name}'.",
//         );
//       } else {
//         zlog(
//           data:
//               "Controller: Edited animation '${savedAnimation.name}' but it was not found in local state. Reloading.",
//         );
//         await loadAllDefaultAnimations(); // Reload if not found (should ideally not happen)
//       }
//     } catch (e, stackTrace) {
//       zlog(
//         data: "Controller: Error editing default animation: $e\n$stackTrace",
//       );
//       state = state.copyWith(
//         status: DefaultAnimationStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }
//
//   // Future<void> deleteDefaultAnimation(String animationId) async {
//   //   state = state.copyWith(
//   //     status: DefaultAnimationStatus.loading,
//   //     clearError: true,
//   //   );
//   //   try {
//   //     await _repository.deleteDefaultAnimation(animationId);
//   //
//   //     // Remove from local state list
//   //     final updatedList = List<AnimationModel>.from(state.defaultAnimations)
//   //       ..removeWhere((anim) => anim.id == animationId);
//   //     state = state.copyWith(
//   //       status: DefaultAnimationStatus.success,
//   //       defaultAnimations: updatedList,
//   //     );
//   //     zlog(
//   //       data: "Controller: Deleted default animation with ID '$animationId'.",
//   //     );
//   //   } catch (e, stackTrace) {
//   //     zlog(
//   //       data: "Controller: Error deleting default animation: $e\n$stackTrace",
//   //     );
//   //     state = state.copyWith(
//   //       status: DefaultAnimationStatus.error,
//   //       errorMessage: e.toString(),
//   //     );
//   //   }
//   // }
//
//   Future<void> deleteDefaultAnimation(String animationId) async {
//     state = state.copyWith(
//         status: DefaultAnimationStatus.loading, clearError: true);
//     try {
//       await _repository.deleteDefaultAnimation(animationId);
//
//       final updatedList = List<AnimationModel>.from(state.defaultAnimations)
//         ..removeWhere((anim) => anim.id == animationId);
//
//       // MODIFIED: Re-index the remaining items after deletion
//       for (int i = 0; i < updatedList.length; i++) {
//         updatedList[i] = updatedList[i].copyWith(orderIndex: i);
//       }
//
//       // Save the updated order of the remaining items
//       await _repository.saveAllDefaultAnimations(updatedList);
//
//       state = state.copyWith(
//           status: DefaultAnimationStatus.success,
//           defaultAnimations: updatedList);
//       zlog(
//           data:
//               "Controller: Deleted default animation with ID '$animationId' and re-indexed list.");
//     } catch (e, stackTrace) {
//       zlog(
//           data:
//               "Controller: Error deleting default animation: $e\n$stackTrace");
//       state = state.copyWith(
//           status: DefaultAnimationStatus.error, errorMessage: e.toString());
//     }
//   }
//
//   Future<void> reorderDefaultAnimations(int oldIndex, int newIndex) async {
//     // This adjustment is needed for ReorderableListView's logic
//     if (newIndex > oldIndex) {
//       newIndex -= 1;
//     }
//
//     final list = List<AnimationModel>.from(state.defaultAnimations);
//     final item = list.removeAt(oldIndex);
//     list.insert(newIndex, item);
//
//     // Re-assign the correct orderIndex to all items in the list
//     for (int i = 0; i < list.length; i++) {
//       list[i] = list[i].copyWith(orderIndex: i);
//     }
//
//     // Optimistically update the UI with the new order
//     state = state.copyWith(
//         defaultAnimations: list, status: DefaultAnimationStatus.success);
//
//     // Persist the entire re-ordered list to the database
//     try {
//       // Assumes your repository has a method to save all animations at once.
//       // This is more efficient than saving one by one.
//       await _repository.saveAllDefaultAnimations(list);
//       zlog(
//           data:
//               "Controller: Successfully saved new order of default animations.");
//     } catch (e) {
//       zlog(data: "Controller: Failed to save new animation order: $e");
//       // If saving fails, revert by reloading from the database to ensure consistency
//       await loadAllDefaultAnimations();
//     }
//   }
//
//   updateAnimationModel({required AnimationModel animationToUpdate}) {
//     List<AnimationModel> animations = state.defaultAnimations;
//
//     int index = animations.indexWhere((a) => a.id == animationToUpdate.id);
//     if (index != -1) {
//       animations[index] = animationToUpdate;
//       state = state.copyWith(defaultAnimations: animations);
//     }
//   }
// }

// lib/presentation/admin/view_model/default_animation_view_model/default_animation_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/domain/admin/default_animation/default_animation_repository.dart';
import 'default_animation_state.dart';

const String SYSTEM_USER_ID_FOR_DEFAULTS = "system_default_user_for_animations";

final defaultAnimationControllerProvider =
    StateNotifierProvider<DefaultAnimationController, DefaultAnimationState>(
        (ref) {
  return DefaultAnimationController();
});

class DefaultAnimationController extends StateNotifier<DefaultAnimationState> {
  DefaultAnimationController() : super(const DefaultAnimationState()) {
    loadAllDefaultCollections();
  }

  final DefaultAnimationRepository _repository = sl.get();
  static const String _otherCollectionName = "Other";

  Future<void> _runMigrationIfNeeded() async {
    final orphanedAnimations = await _repository.getOrphanedDefaultAnimations();

    if (orphanedAnimations.isEmpty) return;

    zlog(
        data:
            "Controller: Migrating ${orphanedAnimations.length} old animations...",
        show: true);

    var collections = await _repository.getAllDefaultAnimationCollections();
    AnimationCollectionModel otherCollection = collections.firstWhere(
      (c) => c.name == _otherCollectionName,
      orElse: () => AnimationCollectionModel(
        id: '',
        name: _otherCollectionName,
        animations: [],
        userId: SYSTEM_USER_ID_FOR_DEFAULTS,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        orderIndex: collections.length,
      ),
    );

    otherCollection =
        await _repository.saveDefaultAnimationCollection(otherCollection);

    for (var animation in orphanedAnimations) {
      final updatedAnimation =
          animation.copyWith(collectionId: otherCollection.id);
      await _repository.saveDefaultAnimation(updatedAnimation);
    }
    zlog(data: "Controller: Migration complete.");
  }

  Future<void> loadAllDefaultCollections() async {
    state = state.copyWith(
        status: DefaultAnimationStatus.loading, clearError: true);
    await _runMigrationIfNeeded();
    try {
      final collections = await _repository.getAllDefaultAnimationCollections();
      final allAnimations = await _repository.getAllDefaultAnimations();

      for (var collection in collections) {
        final animationsForThisCollection = allAnimations
            .where((anim) => anim.collectionId == collection.id)
            .toList();
        animationsForThisCollection
            .sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        collection.animations = animationsForThisCollection;
      }

      state = state.copyWith(
        status: DefaultAnimationStatus.success,
        defaultAnimationCollections: collections,
      );
    } catch (e) {
      state = state.copyWith(
          status: DefaultAnimationStatus.error, errorMessage: e.toString());
    }
  }

  // --- COLLECTION MANAGEMENT ---

  Future<void> createCollection(String name) async {
    final newCollection = AnimationCollectionModel(
      id: RandomGenerator.generateId(),
      name: name,
      userId: SYSTEM_USER_ID_FOR_DEFAULTS,
      animations: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      orderIndex: state.defaultAnimationCollections.length,
    );
    final savedCollection =
        await _repository.saveDefaultAnimationCollection(newCollection);

    final updatedList =
        List<AnimationCollectionModel>.from(state.defaultAnimationCollections)
          ..add(savedCollection);
    state = state.copyWith(
        defaultAnimationCollections: updatedList,
        status: DefaultAnimationStatus.success);
  }

  Future<void> editCollectionName(
      {required String collectionId, required String newName}) async {
    final collections =
        List<AnimationCollectionModel>.from(state.defaultAnimationCollections);
    final index = collections.indexWhere((c) => c.id == collectionId);
    if (index == -1) return;

    final updatedCollection =
        collections[index].copyWith(name: newName, updatedAt: DateTime.now());
    await _repository.saveDefaultAnimationCollection(updatedCollection);

    collections[index] = updatedCollection;
    state = state.copyWith(defaultAnimationCollections: collections);
  }

  Future<void> deleteCollection(String collectionId) async {
    await _repository.deleteDefaultAnimationCollection(collectionId);
    final listAfterDelete = state.defaultAnimationCollections
        .where((c) => c.id != collectionId)
        .toList();

    for (int i = 0; i < listAfterDelete.length; i++) {
      listAfterDelete[i] = listAfterDelete[i].copyWith(orderIndex: i);
    }

    await _repository.saveAllDefaultAnimationCollections(listAfterDelete);
    state = state.copyWith(defaultAnimationCollections: listAfterDelete);
  }

  Future<void> reorderCollections(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final list =
        List<AnimationCollectionModel>.from(state.defaultAnimationCollections);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(orderIndex: i);
    }

    state = state.copyWith(defaultAnimationCollections: list);
    await _repository.saveAllDefaultAnimationCollections(list);
  }

  // --- ANIMATION MANAGEMENT ---

  Future<void> addAnimationToCollection(
      {required String name, required String collectionId}) async {
    final collections =
        List<AnimationCollectionModel>.from(state.defaultAnimationCollections);
    final collectionIndex = collections.indexWhere((c) => c.id == collectionId);
    if (collectionIndex == -1) return;

    final targetCollection = collections[collectionIndex];
    final newAnimation = AnimationModel(
      id: RandomGenerator.generateId(),
      name: name,
      collectionId: collectionId,
      userId: SYSTEM_USER_ID_FOR_DEFAULTS,
      orderIndex: targetCollection.animations.length,
      animationScenes: [],
      fieldColor: ColorManager.grey,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.saveDefaultAnimation(newAnimation);

    targetCollection.animations.add(newAnimation);
    state = state.copyWith(defaultAnimationCollections: collections);
  }

  // ## CORRECTED METHOD ##
  // This method now correctly matches what the UI dialog calls.
  Future<void> editAnimation(AnimationModel animationToUpdate) async {
    final collections =
        List<AnimationCollectionModel>.from(state.defaultAnimationCollections);
    final collectionIndex =
        collections.indexWhere((c) => c.id == animationToUpdate.collectionId);
    if (collectionIndex == -1) return;

    final animIndex = collections[collectionIndex]
        .animations
        .indexWhere((a) => a.id == animationToUpdate.id);
    if (animIndex == -1) return;

    final finalModelToSave =
        animationToUpdate.copyWith(updatedAt: DateTime.now());

    await _repository.saveDefaultAnimation(finalModelToSave);

    collections[collectionIndex].animations[animIndex] = finalModelToSave;
    state = state.copyWith(defaultAnimationCollections: collections);
  }

  Future<void> deleteAnimation({required AnimationModel animation}) async {
    await _repository.deleteDefaultAnimation(animation.id);

    final collections =
        List<AnimationCollectionModel>.from(state.defaultAnimationCollections);
    final collectionIndex =
        collections.indexWhere((c) => c.id == animation.collectionId);
    if (collectionIndex == -1) return;

    final targetCollection = collections[collectionIndex];
    targetCollection.animations.removeWhere((a) => a.id == animation.id);

    for (int i = 0; i < targetCollection.animations.length; i++) {
      targetCollection.animations[i] =
          targetCollection.animations[i].copyWith(orderIndex: i);
    }

    await _repository.saveAllDefaultAnimations(targetCollection.animations);
    state = state.copyWith(defaultAnimationCollections: collections);
  }

  Future<void> reorderAnimationsInCollection(
      {required String collectionId,
      required int oldIndex,
      required int newIndex}) async {
    final collections =
        List<AnimationCollectionModel>.from(state.defaultAnimationCollections);
    final collectionIndex = collections.indexWhere((c) => c.id == collectionId);
    if (collectionIndex == -1) return;

    if (newIndex > oldIndex) newIndex -= 1;
    final collectionAnims = collections[collectionIndex].animations;
    final item = collectionAnims.removeAt(oldIndex);
    collectionAnims.insert(newIndex, item);

    for (int i = 0; i < collectionAnims.length; i++) {
      collectionAnims[i] = collectionAnims[i].copyWith(orderIndex: i);
    }

    state = state.copyWith(defaultAnimationCollections: collections);
    await _repository.saveAllDefaultAnimations(collectionAnims);
  }

  void updateAnimationModel({required AnimationModel animationToUpdate}) {
    final collections =
        List<AnimationCollectionModel>.from(state.defaultAnimationCollections);
    final collectionIndex =
        collections.indexWhere((c) => c.id == animationToUpdate.collectionId);
    if (collectionIndex == -1) return;

    final animIndex = collections[collectionIndex]
        .animations
        .indexWhere((a) => a.id == animationToUpdate.id);
    if (animIndex != -1) {
      collections[collectionIndex].animations[animIndex] = animationToUpdate;
      state = state.copyWith(defaultAnimationCollections: collections);
    }
  }
}
