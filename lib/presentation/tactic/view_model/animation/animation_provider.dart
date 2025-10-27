import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flame/components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/core/component/z_loader.dart';
import 'package:zporter_tactical_board/app/core/constants/board_constant.dart';
import 'package:zporter_tactical_board/app/core/dialogs/animation_copy_dialog.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/animation/model/history_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/domain/admin/default_animation/default_animation_repository.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/delete_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/delete_history_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_all_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_all_default_animation_items_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_default_scene_from_id_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_history_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_default_animation_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_history_usecase.dart';
import 'package:zporter_tactical_board/presentation/admin/view/animation/default_animation_constants.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/default_animation_view_model/default_animation_controller.dart';
import 'package:zporter_tactical_board/presentation/auth/view_model/auth_controller.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/animation_data_input_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

final animationProvider =
    StateNotifierProvider<AnimationController, AnimationState>(
  (ref) => AnimationController(ref),
);

class AnimationController extends StateNotifier<AnimationState> {
  AnimationController(this.ref) : super(AnimationState());

  Ref ref;

  // Lock to prevent concurrent undo operations
  bool _isUndoInProgress = false;
  // Lock to prevent undo during save operations
  bool _isSaveInProgress = false;
  // History size limit to prevent memory issues on older devices
  static const int _maxHistorySize = 30;

  final SaveAnimationCollectionUseCase _saveAnimationCollectionUseCase =
      sl.get<SaveAnimationCollectionUseCase>();
  final GetAllAnimationCollectionUseCase _getAllAnimationCollectionUseCase =
      sl.get<GetAllAnimationCollectionUseCase>();

  final GetAllDefaultAnimationItemsUseCase _getAllDefaultAnimationItemsUseCase =
      sl.get<GetAllDefaultAnimationItemsUseCase>();

  final SaveDefaultAnimationUseCase _saveDefaultAnimationUseCase =
      sl.get<SaveDefaultAnimationUseCase>();

  final GetDefaultSceneFromIdUseCase _getDefaultSceneFromIdUseCase =
      sl.get<GetDefaultSceneFromIdUseCase>();

  final DeleteAnimationCollectionUseCase _deleteAnimationCollectionUseCase =
      sl.get<DeleteAnimationCollectionUseCase>();

  final SaveHistoryUseCase _saveHistoryUseCase = sl.get<SaveHistoryUseCase>();
  final GetHistoryUseCase _getHistoryUseCase = sl.get<GetHistoryUseCase>();
  final DeleteHistoryUseCase _deleteHistoryUseCase =
      sl.get<DeleteHistoryUseCase>();
  final DefaultAnimationRepository _defaultAnimationRepository =
      sl.get<DefaultAnimationRepository>();

  // void selectAnimationCollection(
  //   AnimationCollectionModel? animationCollectionModel, {
  //   AnimationModel? animationSelect,
  //   bool changeSelectedScene = true,
  // }) {
  //   AnimationModel? selectedAnimation = animationSelect;
  //   state = state.copyWith(
  //     selectedAnimationCollectionModel: animationCollectionModel,
  //     animations: animationCollectionModel?.animations ?? [],
  //     selectedAnimationModel: selectedAnimation,
  //     selectedScene: changeSelectedScene == true
  //         ? selectedAnimation?.animationScenes.first
  //         : state.selectedScene,
  //     showNewCollectionInput: false,
  //     showNewAnimationInput: false,
  //     showQuickSave: false,
  //   );
  // }

  void selectAnimationCollection(
    AnimationCollectionModel? animationCollectionModel, {
    AnimationModel? animationSelect,
    bool changeSelectedScene = true,
  }) {
    AnimationModel? selectedAnimation = animationSelect;

    // --- THE FIX IS HERE ---
    // Get the animations list from the selected collection
    final animationsToSort = animationCollectionModel?.animations ?? [];
    // Sort this list by the orderIndex before updating the state
    animationsToSort.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    state = state.copyWith(
      selectedAnimationCollectionModel: animationCollectionModel,
      animations: animationsToSort, // Use the new sorted list
      selectedAnimationModel: selectedAnimation,
      selectedScene: changeSelectedScene == true
          ? selectedAnimation?.animationScenes.firstOrNull
          : state.selectedScene,
      showNewCollectionInput: false,
      showNewAnimationInput: false,
      showQuickSave: false,
    );
  }

  // Future<void> getAllCollections() async {
  //   state = state.copyWith(isLoadingAnimationCollections: true);
  //
  //   try {
  //     // Step 1: Fetch both user collections and default collections concurrently.
  //     final results = await Future.wait([
  //       _getAllAnimationCollectionUseCase
  //           .call(_getUserId()), // User's personal collections
  //       _defaultAnimationRepository
  //           .getAllDefaultAnimationCollections(), // Admin-created collections
  //       _defaultAnimationRepository
  //           .getAllDefaultAnimations(), // All individual default animations
  //     ]);
  //
  //     final userCollections = results[0] as List<AnimationCollectionModel>;
  //     final defaultCollections = results[1] as List<AnimationCollectionModel>;
  //     final allDefaultAnimations = results[2] as List<AnimationModel>;
  //
  //     // Step 2: Populate the default collections with their animations
  //     for (var collection in defaultCollections) {
  //       final animationsForThisCollection = allDefaultAnimations
  //           .where((anim) => anim.collectionId == collection.id)
  //           .toList();
  //       animationsForThisCollection
  //           .sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  //       collection.animations = animationsForThisCollection;
  //     }
  //
  //     // Step 3: Merge the two lists
  //     final combinedCollections = [...userCollections, ...defaultCollections];
  //
  //     // Step 4: Sort the final merged list of collections
  //     combinedCollections.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  //
  //     // Step 5: Update the state with the complete list
  //     AnimationCollectionModel? selectedCollection =
  //         state.selectedAnimationCollectionModel;
  //     if (selectedCollection != null) {
  //       if (!combinedCollections.any((c) => c.id == selectedCollection!.id)) {
  //         selectedCollection = combinedCollections.firstOrNull;
  //       }
  //     } else {
  //       selectedCollection = combinedCollections.firstOrNull;
  //     }
  //
  //     state = state.copyWith(
  //       animationCollections: combinedCollections,
  //       isLoadingAnimationCollections: false,
  //     );
  //
  //     // This will correctly select the first collection and populate its animations
  //     selectAnimationCollection(selectedCollection);
  //   } catch (e) {
  //     zlog(data: "Animation collection fetching issue: $e");
  //     state = state.copyWith(isLoadingAnimationCollections: false);
  //   }
  // }

  Future<void> getAllCollections() async {
    state = state.copyWith(isLoadingAnimationCollections: true);

    final List<Future<void>> backgroundSaveTasks = [];

    try {
      // Step 1: Fetch all data sources
      final results = await Future.wait([
        _getAllAnimationCollectionUseCase.call(_getUserId()),
        _defaultAnimationRepository.getAllDefaultAnimationCollections(),
        _defaultAnimationRepository.getAllDefaultAnimations(),
      ]);

      final userCollections = results[0] as List<AnimationCollectionModel>;
      final rawAdminCollections = results[1] as List<AnimationCollectionModel>;
      final allDefaultAnimations = results[2] as List<AnimationModel>;

      // Step 2: Build the Admin Template Map
      final Map<String, AnimationCollectionModel> adminTemplateMap = {};
      for (var adminCol in rawAdminCollections) {
        final animationsForThisCollection = allDefaultAnimations
            .where((anim) => anim.collectionId == adminCol.id)
            .toList();
        animationsForThisCollection
            .sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

        adminCol.animations = animationsForThisCollection;
        adminCol.isTemplate = true;
        adminTemplateMap[adminCol.id] = adminCol;
      }

      // --- AUTOMATIC SYNC & MERGE LOGIC (ALWAYS RUNS) ---

      final List<AnimationCollectionModel> finalCombinedList = [];

      // Step 3: Iterate USER collections and auto-sync
      for (final userCol in userCollections) {
        userCol.isTemplate = false;
        bool wasUpdated = false;
        AnimationCollectionModel finalCollectionToUse = userCol;

        if (adminTemplateMap.containsKey(userCol.id)) {
          final matchingAdminTemplate = adminTemplateMap[userCol.id]!;

          // --- NOTE: The TIMESTAMP 'IF' CHECK IS NOW GONE ---
          // This sync logic will now run EVERY time for every shadow copy.

          // 1. Create a map of all NEWEST admin animations
          final Map<String, AnimationModel> adminAnimationMap = {
            for (var adminAnim in matchingAdminTemplate.animations)
              adminAnim.id: adminAnim.clone()
          };

          // 2. Create the new list we will build
          final List<AnimationModel> newlySyncedList = [];

          // 3. Go through the user's CURRENT animations
          for (final userAnim in userCol.animations) {
            if (adminAnimationMap.containsKey(userAnim.id)) {
              // IT'S AN ADMIN ANIMATION. Replace it with the new version.
              newlySyncedList.add(adminAnimationMap[userAnim.id]!);
              adminAnimationMap.remove(userAnim.id);
            } else {
              // IT'S A USER-CREATED ANIMATION. Keep it.
              newlySyncedList.add(userAnim);
            }
          }

          // 4. Anything left in adminAnimationMap is a NEW admin animation. Add them.
          newlySyncedList.addAll(adminAnimationMap.values);

          // 5. Create the final, updated collection
          newlySyncedList.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

          finalCollectionToUse = userCol.copyWith(
            animations: newlySyncedList,
            updatedAt: DateTime.now(), // Always update timestamp to now
          );
          finalCollectionToUse.isTemplate = false;

          wasUpdated = true; // Mark that this collection needs to be saved
          // --- END OF SYNC LOGIC ---

          adminTemplateMap.remove(userCol.id);
        }

        finalCombinedList.add(finalCollectionToUse);

        if (wasUpdated) {
          // Add the save task. This will now happen on every load for every shadow copy.
          backgroundSaveTasks
              .add(_saveAnimationCollectionUseCase.call(finalCollectionToUse));
        }
      }

      // Step 4: Add any remaining (non-copied) admin templates
      finalCombinedList.addAll(adminTemplateMap.values);

      // Step 5: Sort and update the state ONCE
      finalCombinedList.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      AnimationCollectionModel? selectedCollection =
          state.selectedAnimationCollectionModel;
      if (selectedCollection != null) {
        selectedCollection = finalCombinedList
            .firstWhereOrNull((c) => c.id == selectedCollection!.id);
      }
      selectedCollection ??= finalCombinedList.firstOrNull;

      state = state.copyWith(
        animationCollections: finalCombinedList,
        isLoadingAnimationCollections: false,
      );

      selectAnimationCollection(selectedCollection);
    } catch (e) {
      zlog(data: "Animation collection fetching/syncing issue: $e");
      state = state.copyWith(isLoadingAnimationCollections: false);
    }

    // STEP 6: Run all pending saves in the background
    if (backgroundSaveTasks.isNotEmpty) {
      zlog(
          data:
              "Performing ${backgroundSaveTasks.length} background collection (re-sync) saves...");
      Future.wait(backgroundSaveTasks).catchError((e) {
        zlog(data: "Error during background sync save: $e", level: Level.error);
      });
    }
  }

  void createNewCollection(String newCollectionName) async {
    showZLoader();
    try {
      AnimationCollectionModel animationCollectionModel =
          AnimationCollectionModel(
        id: RandomGenerator.generateId(),
        userId: _getUserId(),
        name: newCollectionName,
        animations: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      List<AnimationCollectionModel> collections = state.animationCollections;

      if (_isDuplicateAnimationCollection(
        collections,
        animationCollectionModel,
      )) {
        BotToast.showText(
          text: "Duplicate collection name. Collection name must be unique.",
        );
        return;
      }

      AnimationCollectionModel newAnimationCollectionModel =
          await _saveAnimationCollectionUseCase.call(animationCollectionModel);
      collections.add(newAnimationCollectionModel);
      state = state.copyWith(animationCollections: collections);
      selectAnimationCollection(
        newAnimationCollectionModel,
        changeSelectedScene: false,
      );
    } catch (e) {
      zlog(data: "Animation collection creating issue ${e}");
    } finally {
      BotToast.cleanAll();
    }
  }

  // void createNewAnimation({required AnimationCreateItem newAnimation}) async {
  //   showZLoader();
  //   try {
  //     AnimationModel animationModel = AnimationModel(
  //       userId: _getUserId(),
  //       fieldColor: BoardConstant.field_color,
  //       id: RandomGenerator.generateId(),
  //       name: newAnimation.newAnimationName,
  //       animationScenes: [],
  //       boardBackground: ref.read(boardProvider).boardBackground,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //     );
  //
  //     AnimationCollectionModel animationCollectionModel =
  //         newAnimation.animationCollectionModel;
  //
  //     if (_isDuplicateAnimation(
  //       animationCollectionModel.animations,
  //       animationModel,
  //     )) {
  //       BotToast.showText(
  //         text: "Duplicate animation name. Animation name must be unique.",
  //       );
  //       return;
  //     }
  //
  //     animationModel.animationScenes.add(
  //       AnimationItemModel(
  //         index: 0, // It's the first scene, so index is 0
  //         fieldColor: BoardConstant.field_color,
  //         id: RandomGenerator.generateId(),
  //         userId: _getUserId(),
  //         fieldSize: ref.read(boardProvider.notifier).fetchFieldSize() ??
  //             Vector2(0, 0),
  //         boardBackground: ref.read(boardProvider).boardBackground,
  //         components: newAnimation.items,
  //         createdAt: DateTime.now(),
  //         updatedAt: DateTime.now(),
  //       ),
  //     );
  //
  //     animationCollectionModel.animations.add(animationModel);
  //     animationCollectionModel = await _saveAnimationCollectionUseCase.call(
  //       animationCollectionModel,
  //     );
  //
  //     selectAnimationCollection(
  //       animationCollectionModel,
  //       animationSelect: animationModel,
  //     );
  //   } catch (e) {
  //     zlog(data: "Animation creating issue ${e}");
  //   } finally {
  //     BotToast.cleanAll();
  //   }
  // }

  void createNewAnimation({required AnimationCreateItem newAnimation}) async {
    showZLoader();
    try {
      AnimationModel animationModel = AnimationModel(
        userId: _getUserId(),
        fieldColor: BoardConstant.field_color,
        id: RandomGenerator.generateId(),
        name: newAnimation.newAnimationName,
        animationScenes: [],
        boardBackground: ref.read(boardProvider).boardBackground,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AnimationCollectionModel animationCollectionModel =
          newAnimation.animationCollectionModel;

      // --- THIS IS THE NEW "COPY-ON-WRITE" LOGIC ---
      if (animationCollectionModel.isTemplate == true) {
        // This is an admin template. We must create a copy before modifying it.
        // 1. Create a new, separate list of the existing animations.
        final newAnimationList =
            List<AnimationModel>.from(animationCollectionModel.animations);

        // 2. Create a new collection instance using copyWith, passing in the NEW list.
        animationCollectionModel = animationCollectionModel.copyWith(
            animations: newAnimationList, userId: _getUserId());

        // 3. Flip the flag on this new instance. It is now a user copy.
        animationCollectionModel.isTemplate = false;
      }
      // --- END OF NEW LOGIC ---

      // The rest of the function now operates on either the original user
      // collection OR the brand-new shadow copy.

      if (_isDuplicateAnimation(
        animationCollectionModel.animations,
        animationModel,
      )) {
        BotToast.showText(
          text: "Duplicate animation name. Animation name must be unique.",
        );
        return;
      }

      animationModel.animationScenes.add(
        AnimationItemModel(
          index: 0, // It's the first scene, so index is 0
          fieldColor: BoardConstant.field_color,
          id: RandomGenerator.generateId(),
          userId: _getUserId(),
          fieldSize: ref.read(boardProvider.notifier).fetchFieldSize() ??
              Vector2(0, 0),
          boardBackground: ref.read(boardProvider).boardBackground,
          components: newAnimation.items,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // This will now add the animation to the NEW list if it was a template
      animationCollectionModel.animations.add(animationModel);

      // This will save the SHADOW COPY (with the same ID) to the user's database
      animationCollectionModel = await _saveAnimationCollectionUseCase.call(
        animationCollectionModel,
      );

      selectAnimationCollection(
        animationCollectionModel,
        animationSelect: animationModel,
      );
    } catch (e) {
      zlog(data: "Animation creating issue ${e}");
    } finally {
      BotToast.cleanAll();
    }
  }

  void selectAnimation(AnimationModel? s) {
    zlog(data: "Animation model came ${s}");
    state = state.copyWith(
      selectedAnimationModel: s,
      selectedScene: s?.animationScenes.firstOrNull,
    );
    ref
        .read(boardProvider.notifier)
        .updateBoardBackground(s?.boardBackground ?? BoardBackground.full);
  }

  void clearAnimation() {
    state = state.copyWith(
      selectedAnimationModel: null,
      selectedScene: state.defaultAnimationItems[0],
      defaultAnimationItemIndex: 0,
    );
  }

  void copyAnimation(AnimationCopyItem animationCopyItem) async {
    AnimationCollectionModel? animationCollectionModel =
        animationCopyItem.animationCollectionModel;
    if (animationCollectionModel == null) {
      BotToast.showText(text: "Please select a collection");
      return;
    }
    AnimationModel newAnimationModel = animationCopyItem.animationModel.clone();
    newAnimationModel.id = RandomGenerator.generateId();
    newAnimationModel.name = animationCopyItem.newAnimationName;
    newAnimationModel.createdAt = DateTime.now();
    newAnimationModel.updatedAt = DateTime.now();

    if (_isDuplicateAnimation(
      animationCollectionModel.animations,
      newAnimationModel,
    )) {
      BotToast.showText(
        text: "Duplicate animation name. Animation name must be unique.",
      );
      return;
    }
    showZLoader();
    try {
      animationCollectionModel.animations.add(newAnimationModel);
      animationCollectionModel = await _saveAnimationCollectionUseCase.call(
        animationCollectionModel,
      );

      selectAnimationCollection(
        animationCollectionModel,
        animationSelect: newAnimationModel,
      );
    } catch (e) {
      zlog(data: "Animation creating issue ${e}");
    } finally {
      BotToast.cleanAll();
    }
  }

  bool _isDuplicateAnimation(
    List<AnimationModel> animations,
    AnimationModel newAnimation,
  ) {
    List<String> animationNames =
        animations.map((a) => a.name.toLowerCase()).toList();
    if (animationNames.contains(newAnimation.name.toLowerCase())) {
      return true;
    }
    return false;
  }

  bool _isDuplicateAnimationCollection(
    List<AnimationCollectionModel> animations,
    AnimationCollectionModel newAnimation,
  ) {
    List<String> animationNames =
        animations.map((a) => a.name.toLowerCase()).toList();
    if (animationNames.contains(newAnimation.name.toLowerCase())) {
      return true;
    }
    return false;
  }

  Future<void> saveAnimationTime({
    required Duration newDuration,
    required String sceneId,
  }) async {
    AnimationCollectionModel? selectedCollection =
        state.selectedAnimationCollectionModel;
    AnimationModel? selectedAnimation = state.selectedAnimationModel;
    int index =
        selectedAnimation?.animationScenes.indexWhere((a) => a.id == sceneId) ??
            -1;
    if (index != -1) {
      try {
        AnimationItemModel scene = selectedAnimation!.animationScenes[index];
        scene = scene.copyWith(sceneDuration: newDuration);
        selectedAnimation.animationScenes[index] = scene;
        int animationIndex = selectedCollection!.animations.indexWhere(
          (a) => a.id == selectedAnimation.id,
        );
        if (animationIndex != -1) {
          selectedCollection.animations[animationIndex] = selectedAnimation;
          try {
            _saveAnimationCollectionUseCase.call(selectedCollection);
          } catch (e) {}
        } else {}
      } catch (e) {}
    }
  }

  Future<AnimationItemModel?> _onAnimationSave({
    required AnimationCollectionModel selectedCollection,
    required AnimationModel selectedAnimation,
    required AnimationItemModel selectedScene,
    bool showLoading = true,
    bool saveToDb = true,
  }) async {
    List<FieldItemModel> components =
        ref.read(boardProvider.notifier).onAnimationSave();

    selectedScene.components = components;
    selectedScene.fieldSize =
        ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero();
    int sceneIndex = selectedAnimation.animationScenes.indexWhere(
      (a) => a.id == selectedScene.id,
    );
    if (sceneIndex != -1) {
      selectedAnimation.animationScenes[sceneIndex] = selectedScene;
      int animationIndex = selectedCollection.animations.indexWhere(
        (a) => a.id == selectedAnimation.id,
      );

      if (animationIndex != -1) {
        selectedCollection.animations[animationIndex] = selectedAnimation;

        if (showLoading) {
          showZLoader();
        }

        try {
          if (saveToDb) {
            selectedCollection = await _saveAnimationCollectionUseCase.call(
              selectedCollection,
            );
          }

          // state = state.copyWith(
          //   selectedAnimationCollectionModel: selectedCollection,
          //   selectedAnimationModel: selectedAnimation,
          //   selectedScene: selectedScene,
          // );
          BotToast.showText(text: "Scene Saved Successfully ${selectedScene}");
          return selectedScene;
        } catch (e) {
          BotToast.showText(text: "Unexpected server error ${e}");
        } finally {
          BotToast.cleanAll();
        }
      } else {
        BotToast.showText(text: "No Animation found!!");
      }
    } else {
      BotToast.showText(text: "No scene found!!");
    }
    return null;
  }

  // void addNewScene({
  //   required AnimationCollectionModel selectedCollection,
  //   required AnimationModel selectedAnimation,
  //   required AnimationItemModel selectedScene,
  // }) async {
  //   selectedCollection = state.selectedAnimationCollectionModel!;
  //   selectedAnimation = state.selectedAnimationModel!;
  //   AnimationItemModel newAnimationItemModel = selectedScene.clone(
  //     addHistory: false,
  //   );
  //   newAnimationItemModel.id = RandomGenerator.generateId();
  //   newAnimationItemModel.index = selectedAnimation.animationScenes.length;
  //   newAnimationItemModel.createdAt = DateTime.now();
  //   newAnimationItemModel.updatedAt = DateTime.now();
  //   selectedAnimation.animationScenes.add(newAnimationItemModel);
  //
  //   state = state.copyWith(
  //     selectedAnimationCollectionModel: selectedCollection,
  //     selectedAnimationModel: selectedAnimation,
  //     selectedScene: selectedAnimation.animationScenes.last,
  //   );
  //   try {
  //     _onAnimationSave(
  //       selectedCollection: state.selectedAnimationCollectionModel!,
  //       selectedAnimation: state.selectedAnimationModel!,
  //       selectedScene: state.selectedScene!,
  //       showLoading: false,
  //     );
  //   } catch (e) {}
  // }

  void addNewScene({
    required AnimationCollectionModel selectedCollection,
    required AnimationModel selectedAnimation,
    required AnimationItemModel
        selectedScene, // This is the CURRENT scene (Scene A)
  }) async {
    // 1. Get the LIVE components from the board. This is the "dirty" data you just added.
    final List<FieldItemModel> currentComponents =
        ref.read(boardProvider.notifier).onAnimationSave();

    // 2. Find the *current* scene (Scene A) in the animation list AND UPDATE IT with this live data.
    // This is the "Force Save" step that was missing.
    final int currentSceneIndex = selectedAnimation.animationScenes.indexWhere(
      (s) => s.id == selectedScene.id,
    );

    if (currentSceneIndex != -1) {
      // Create an updated copy of Scene A
      selectedScene = selectedScene.copyWith(
        components: currentComponents,
        updatedAt: DateTime.now(),
      );
      // Replace the old stale scene in the list with the updated one
      selectedAnimation.animationScenes[currentSceneIndex] = selectedScene;
    } else {
      // This shouldn't happen, but as a fallback, just update the local copy
      selectedScene.components = currentComponents;
    }

    // 3. NOW that Scene A is fully updated, clone IT to create Scene B.
    AnimationItemModel newAnimationItemModel = selectedScene.clone(
      addHistory: false,
    );
    newAnimationItemModel.id = RandomGenerator.generateId();
    newAnimationItemModel.index = selectedAnimation.animationScenes.length;
    newAnimationItemModel.createdAt = DateTime.now();
    newAnimationItemModel.updatedAt = DateTime.now();

    // 4. Add the new clone (Scene B) to the animation list
    selectedAnimation.animationScenes.add(newAnimationItemModel);

    // 5. Save the ENTIRE collection (which now has the updated Scene A AND the new Scene B)
    try {
      // Show the save spinner that your UI already listens for
      toggleLoadingSave(showLoading: true);
      selectedCollection =
          await _saveAnimationCollectionUseCase.call(selectedCollection);
    } catch (e) {
      zlog(data: "Error saving new scene: $e");
      BotToast.showText(text: "Error saving new scene.");
    } finally {
      // Hide the spinner
      toggleLoadingSave(showLoading: false);
    }

    // 6. FINALLY, update the state ONCE to select the new, correct scene.
    // This happens after the save is complete.
    state = state.copyWith(
      selectedAnimationCollectionModel: selectedCollection,
      selectedAnimationModel: selectedAnimation
          .clone(), // Use a clone to force the UI to refresh the list
      selectedScene: newAnimationItemModel, // Select Scene B
    );
  }

  void selectScene({required AnimationItemModel scene}) {
    zlog(data: "Copy with method called check");
    state = state.copyWith(selectedScene: scene);
    ref
        .read(boardProvider.notifier)
        .updateBoardBackground(scene.boardBackground);
  }

  void toggleAnimation() {
    state = state.copyWith(showAnimation: !state.showAnimation);
  }

  void deleteScene({required AnimationItemModel scene}) async {
    AnimationCollectionModel? selectedCollectionModel =
        state.selectedAnimationCollectionModel;
    AnimationModel? selectedAnimationModel = state.selectedAnimationModel;
    if (selectedCollectionModel != null && selectedAnimationModel != null) {
      selectedAnimationModel.animationScenes.removeWhere(
        (t) => t.id == scene.id,
      );

      // Re-index the list
      for (var i = 0; i < selectedAnimationModel.animationScenes.length; i++) {
        selectedAnimationModel.animationScenes[i] =
            selectedAnimationModel.animationScenes[i].copyWith(index: i);
      }

      if (selectedAnimationModel.animationScenes.isEmpty) {
        selectedAnimationModel.animationScenes.add(
          AnimationItemModel(
            index: 0,
            fieldColor: BoardConstant.field_color,
            id: RandomGenerator.generateId(),
            components: [],
            userId: _getUserId(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            fieldSize: ref.read(boardProvider.notifier).fetchFieldSize() ??
                Vector2(0, 0),
          ),
        );
      }
      int index = selectedCollectionModel.animations.indexWhere(
        (t) => t.id == selectedAnimationModel.id,
      );
      if (index != -1) {
        selectedCollectionModel.animations[index] = selectedAnimationModel;
      }
      selectedCollectionModel = await _saveAnimationCollectionUseCase.call(
        selectedCollectionModel,
      );
      state = state.copyWith(
        selectedAnimationCollectionModel: selectedCollectionModel,
        selectedAnimationModel: selectedAnimationModel,
        selectedScene: selectedAnimationModel.animationScenes.lastOrNull,
      );
    } else {
      BotToast.showText(text: "No animation found");
    }
  }

  void deleteAnimation({required AnimationModel animation}) async {
    AnimationCollectionModel? selectedCollectionModel =
        state.selectedAnimationCollectionModel;

    if (selectedCollectionModel == null) {
      BotToast.showText(text: "No Collection is selected");
      return;
    }

    selectedCollectionModel.animations.removeWhere((t) => t.id == animation.id);

    selectedCollectionModel = await _saveAnimationCollectionUseCase.call(
      selectedCollectionModel,
    );
    selectAnimationCollection(
      selectedCollectionModel,
      changeSelectedScene: false,
    );
  }

  // --- NEW METHODS FOR REORDERING ---

  // Helper to re-apply correct indexes after a modification
  void _reIndexScenes(AnimationModel animation) {
    for (int i = 0; i < animation.animationScenes.length; i++) {
      animation.animationScenes[i] =
          animation.animationScenes[i].copyWith(index: i);
    }
  }

  // New method to handle drag-and-drop reordering from the UI
  Future<void> reorderScene(int oldIndex, int newIndex) async {
    final selectedAnim = state.selectedAnimationModel;
    if (selectedAnim == null) return;

    // This adjustment is needed because ReorderableListView has its own logic
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = selectedAnim.animationScenes.removeAt(oldIndex);
    selectedAnim.animationScenes.insert(newIndex, item);

    // Update the index property for all scenes
    _reIndexScenes(selectedAnim);

    // Save the changes and update the state
    await updateDatabaseOnChange(saveToDb: true);
    zlog(data: "Database changed after re-ordering", show: true);
    state = state.copyWith(
      selectedAnimationModel: selectedAnim.clone(), // Clone to ensure UI update
    );
  }

  // New method to handle moving scenes up or down with buttons
  Future<void> moveScene(String sceneId, {required bool moveUp}) async {
    final selectedAnim = state.selectedAnimationModel;
    if (selectedAnim == null) return;

    final sceneIndex =
        selectedAnim.animationScenes.indexWhere((s) => s.id == sceneId);
    if (sceneIndex == -1) return;

    final int newIndex;
    if (moveUp) {
      if (sceneIndex == 0) return; // Can't move up further
      newIndex = sceneIndex - 1;
    } else {
      if (sceneIndex == selectedAnim.animationScenes.length - 1)
        return; // Can't move down further
      newIndex = sceneIndex + 1;
    }

    final item = selectedAnim.animationScenes.removeAt(sceneIndex);
    selectedAnim.animationScenes.insert(newIndex, item);

    _reIndexScenes(selectedAnim);

    await updateDatabaseOnChange(saveToDb: true);

    state = state.copyWith(
      selectedAnimationModel: selectedAnim.clone(),
    );
  }

  void toggleNewCollectionInputShow(bool show) {
    state = state.copyWith(showNewCollectionInput: show);
  }

  void toggleNewAnimationInputShow(bool show) {
    state = state.copyWith(showNewAnimationInput: show);
  }

  void showQuickSave() {
    List<FieldItemModel> components =
        ref.read(boardProvider.notifier).onAnimationSave();
    AnimationItemModel quickSaveAnimation =
        AnimationItemModel.createEmptyAnimationItem(
      components: components,
      userId: _getUserId(),
      fieldSize:
          ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2(0, 0),
    );
    state = state.copyWith(
      showQuickSave: true,
      selectedScene: quickSaveAnimation,
    );
  }

  void cancelQuickSave() {
    state = state.copyWith(showQuickSave: false);
  }

  Future<void> configureDefaultAnimations() async {
    List<AnimationItemModel> animationItems = [];
    try {
      animationItems = await _getAllDefaultAnimationItemsUseCase.call(
        _getUserId(),
      );
    } catch (e) {
      zlog(data: "Animation item fetch issue", show: true);
    }
    if (animationItems.isEmpty) {
      animationItems.add(
        AnimationItemModel.createEmptyAnimationItem(
          userId: _getUserId(),
          fieldSize: ref.read(boardProvider.notifier).fetchFieldSize() ??
              Vector2.zero(),
        ),
      );
    }
    zlog(data: "Default animation items ${animationItems}", show: true);

    state = state.copyWith(
      defaultAnimationItems: animationItems,
      selectedScene: animationItems.first,
      defaultAnimationItemIndex: 0,
    );
  }

  void changeDefaultAnimationIndex(int index) {
    zlog(data: 'Default animation index ${index}');
    final selectedScene = state.defaultAnimationItems[index];
    state = state.copyWith(
      defaultAnimationItemIndex: index,
      selectedScene: selectedScene,
    );
  }

  Future<AnimationItemModel?> _onSaveDefault() async {
    try {
      int index = state.defaultAnimationItemIndex;
      List<AnimationItemModel> defaultAnimations = state.defaultAnimationItems;

      AnimationItemModel changeModel = defaultAnimations[index].clone();

      changeModel.components =
          ref.read(boardProvider.notifier).onAnimationSave();
      changeModel.fieldSize =
          ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero();

      defaultAnimations[index] = changeModel;
      zlog(
          data:
              "Default animation model List ${changeModel.components} - ${changeModel.boardBackground}");
      SaveDefaultAnimationParam defaultAnimationParam =
          SaveDefaultAnimationParam(
        animationItems: defaultAnimations,
        userId: _getUserId(),
      );
      List<AnimationItemModel> cst =
          await _saveDefaultAnimationUseCase.call(defaultAnimationParam);

      zlog(
          data:
              "After saved the data the CST came ${cst} - ${defaultAnimationParam}",
          show: true);

      state = state.copyWith(selectedScene: changeModel);
      return changeModel;
    } catch (e) {
      zlog(data: "Default Auto save failed $e", show: true);
    }
    return null;
  }

  Future<AnimationItemModel?> updateDatabaseOnChange({
    required bool saveToDb,
  }) async {
    // Set save lock if actually saving to database
    if (saveToDb) {
      _isSaveInProgress = true;
    }

    try {
      // CRITICAL FIX: Save current state to history BEFORE updating
      // This ensures we can undo to the current state
      if (saveToDb && !state.skipHistorySave && state.selectedScene != null) {
        zlog(data: "Saving current state to history before update...");
        await _saveToHistory(scene: state.selectedScene!);
      }

      if (saveToDb == false) {
        AnimationItemModel? changeModel = state.selectedScene ??
            AnimationItemModel.createEmptyAnimationItem();
        changeModel.components =
            ref.read(boardProvider.notifier).onAnimationSave();
        changeModel.fieldSize =
            ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero();
        state = state.copyWith(selectedScene: changeModel);
        return changeModel;
      }
      AnimationModel? selectedAnimationModel = state.selectedAnimationModel;
      if (selectedAnimationModel == null) {
        try {
          zlog(data: "Came on selected animation null", show: true);
          return await _onSaveDefault();
        } catch (e) {
          zlog(data: "Auto save error");
        }
      } else {
        /// working on saved animation
        try {
          zlog(data: "Came on _onAnimationSave", show: true);
          return await _onAnimationSave(
            selectedCollection: state.selectedAnimationCollectionModel!,
            selectedAnimation: state.selectedAnimationModel!,
            selectedScene: state.selectedScene!,
            showLoading: false,
            saveToDb: saveToDb,
          );
        } catch (e) {
          zlog(data: "Auto save error");
        }
      }
      return null;
    } finally {
      // Always release save lock
      if (saveToDb) {
        _isSaveInProgress = false;
      }
    }
  }

  void createNewDefaultAnimationItem() {
    List<AnimationItemModel> defaultItems = state.defaultAnimationItems;
    defaultItems.add(_generateDummyAnimationItem());
    zlog(data: 'Default animation index ${defaultItems.length - 1}');
    state = state.copyWith(
      defaultAnimationItems: defaultItems,
      defaultAnimationItemIndex: defaultItems.length - 1,
      selectedScene: defaultItems.last,
    );
  }

  void copyCurrentDefaultScene() {
    AnimationItemModel? selectedScene = state.selectedScene;
    if (selectedScene != null) {
      List<AnimationItemModel> defaultItems = state.defaultAnimationItems;

      AnimationItemModel item =
          _generateDummyAnimationItem(items: selectedScene.components);
      int index = defaultItems.indexWhere((t) => t.id == selectedScene.id);
      if (index == -1) {
        index = 0;
      } else {
        index += 1;
      }

      defaultItems.insert(index, item);

      zlog(data: 'Default animation index ${defaultItems.length - 1}');
      state = state.copyWith(
        defaultAnimationItems: defaultItems,
        defaultAnimationItemIndex: index,
        selectedScene: defaultItems[index],
      );
    }
  }

  AnimationItemModel _generateDummyAnimationItem(
      {List<FieldItemModel> items = const []}) {
    return AnimationItemModel.createEmptyAnimationItem(
      userId: _getUserId(),
      components: items,
      fieldSize:
          ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero(),
    );
  }

  void deleteDefaultAnimation() async {
    int index = state.defaultAnimationItemIndex;
    List<AnimationItemModel> defaultItems = state.defaultAnimationItems;
    AnimationItemModel deletedItem = defaultItems.removeAt(index);

    showZLoader();
    try {
      SaveDefaultAnimationParam defaultAnimationParam =
          SaveDefaultAnimationParam(
        animationItems: defaultItems,
        userId: _getUserId(),
      );

      defaultItems = await _saveDefaultAnimationUseCase.call(
        defaultAnimationParam,
      );
      index = index >= defaultItems.length ? defaultItems.length - 1 : index;
      if (defaultItems.isEmpty) {
        defaultItems.add(_generateDummyAnimationItem());
        index = 0;
      }

      _deleteHistoryUseCase.call(deletedItem.id);

      state = state.copyWith(
        defaultAnimationItems: defaultItems,
        defaultAnimationItemIndex: index,
        selectedScene: defaultItems[index],
      );
      ref.read(boardProvider.notifier).clearItems();
    } catch (e) {}
    BotToast.cleanAll();
  }

  void performUndoOperation() async {
    // Prevent concurrent undo operations
    if (_isUndoInProgress) {
      zlog(
        level: Level.warning,
        data: "Undo operation already in progress, ignoring duplicate request.",
      );
      return;
    }

    // Prevent undo during active save operations
    if (_isSaveInProgress) {
      zlog(
        level: Level.warning,
        data: "Save operation in progress, cannot perform undo.",
      );
      return;
    }

    final AnimationItemModel? currentScene = state.selectedScene;
    if (currentScene == null) return; // Guard clause

    // --- FIX: Store the ID before any potential nulling ---
    final String sceneId = currentScene.id;

    // Set lock and UI flag
    _isUndoInProgress = true;

    try {
      // Set flags to prevent history save and indicate undo in progress
      state = state.copyWith(
        isPerformingUndo: true,
        skipHistorySave:
            true, // Critical: Don't save to history during undo restoration
      );

      HistoryModel? history = await _getHistoryUseCase.call(sceneId);
      zlog(
        data: "History found for undo: ${history?.history.length ?? 0} items.",
      );

      if (history == null || history.history.isEmpty) {
        // No history to undo from, just toggle the flag off.
        zlog(
          level: Level.warning,
          data: "No history available to undo.",
        );
        toggleUndo(undo: false);
        // Reset the skip flag
        state = state.copyWith(skipHistorySave: false);
        return;
      }

      List<AnimationItemModel> historyList =
          List.from(history.history); // Make a mutable copy

      // Remove the current state from the history
      if (historyList.isNotEmpty) {
        historyList.removeLast();
      }

      // --- THE FIX ---
      // Determine the state to revert to. If history is now empty,
      // create a new blank scene. Otherwise, use the last item in history.
      AnimationItemModel? sceneToRestore = historyList.lastOrNull;

      if (sceneToRestore == null) {
        zlog(
            data:
                "History is empty. Reverting to a blank scene with ID: $sceneId");
        // Create a blank slate but preserve the ID, userId, etc.
        sceneToRestore = AnimationItemModel.createEmptyAnimationItem(
          id: sceneId, // CRITICAL: Use the original ID to maintain history link
          userId: _getUserId(),
          fieldSize: currentScene.fieldSize,
          boardBackground: currentScene.boardBackground,
          fieldColor: currentScene.fieldColor,
        );
      } else {
        zlog(data: "Reverting to previous scene state from history.");
      }

      // Update the history in the database
      history.history = historyList;
      await _saveHistoryUseCase.call(history);

      zlog(
        data:
            "History updated successfully. Remaining items: ${historyList.length}",
      );

      // Update the app's state with the restored scene
      state = state.copyWith(
        selectedScene: sceneToRestore,
        // The isPerformingUndo flag will be set to false by the board watcher
        // Keep skipHistorySave true until the undo is complete
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Error during undo operation: $e\nStackTrace: $stackTrace",
      );
      // Ensure the undo flag is turned off in case of an error
      toggleUndo(undo: false);
      // Reset the skip flag on error
      state = state.copyWith(skipHistorySave: false);
    } finally {
      // Always release the lock
      _isUndoInProgress = false;
    }
  }

  void toggleUndo({required bool undo}) {
    state = state.copyWith(
      isPerformingUndo: undo,
      skipHistorySave: false, // Reset skip flag when toggling undo off
    );
  }

  String _getUserId() {
    String? userId = ref.read(authProvider).userId;
    if (userId == null) {
      throw Exception("User Id Not Found");
    }
    return userId;
  }

  Future<void> _saveToHistory({required AnimationItemModel scene}) async {
    try {
      HistoryModel? historyModel = await _getHistoryUseCase.call(scene.id);
      historyModel ??= HistoryModel(id: scene.id, history: []);

      // Add the new scene to history
      historyModel.history.add(scene);

      // Implement history size limit to prevent memory issues on older devices
      if (historyModel.history.length > _maxHistorySize) {
        // Remove the oldest items, keeping only the most recent ones
        historyModel.history = historyModel.history.sublist(
          historyModel.history.length - _maxHistorySize,
        );
        zlog(
          data:
              "History size limit reached. Trimmed to ${historyModel.history.length} items.",
        );
      }

      await _saveHistoryUseCase.call(historyModel);
      zlog(
        data:
            "History saved successfully for scene: ${scene.id}. Total items: ${historyModel.history.length}",
      );
    } catch (e, stackTrace) {
      zlog(
        level: Level.error,
        data: "Error saving to history: $e\nStackTrace: $stackTrace",
      );
    }
  }

  void saveHistory({AnimationItemModel? scene}) {
    if (scene != null) {
      _saveToHistory(scene: scene);
    }
  }

  Color getFieldColor() {
    AnimationModel? selectedAnimation = state.selectedAnimationModel;
    AnimationItemModel? selectedScene = state.selectedScene;
    if (selectedAnimation != null) {
      return selectedAnimation.fieldColor;
    } else if (selectedScene != null) {
      return selectedScene.fieldColor;
    } else {
      return BoardConstant.field_color;
    }
  }

  void updateBoardColor(Color c) {
    AnimationModel? selectedAnimation = state.selectedAnimationModel;
    AnimationItemModel? selectedScene = state.selectedScene;
    selectedAnimation?.fieldColor = c;
    selectedScene?.fieldColor = c;
    state = state.copyWith(
      selectedScene: selectedScene,
      selectedAnimationModel: selectedAnimation,
    );
  }

  /// Admin area

  void activateDefaultAnimation({required AnimationModel animationModel}) {
    state = state.copyWith(
      selectedAnimationModel: animationModel,
      selectedScene: animationModel.animationScenes.firstOrNull,
    );
  }

  void addNewSceneFromAdmin({
    required AnimationModel selectedAnimation,
    required AnimationItemModel selectedScene,
  }) async {
    selectedAnimation = state.selectedAnimationModel!;
    AnimationItemModel newAnimationItemModel = selectedScene.clone(
      addHistory: false,
    );
    newAnimationItemModel.id = RandomGenerator.generateId();
    newAnimationItemModel.createdAt = DateTime.now();
    newAnimationItemModel.updatedAt = DateTime.now();
    selectedAnimation.animationScenes.add(newAnimationItemModel);

    state = state.copyWith(
      selectedAnimationModel: selectedAnimation,
      selectedScene: selectedAnimation.animationScenes.last,
    );
    ref
        .read(defaultAnimationControllerProvider.notifier)
        .updateAnimationModel(animationToUpdate: selectedAnimation);
    try {
      _onAnimationSaveAdmin(
        selectedAnimation: state.selectedAnimationModel!,
        selectedScene: state.selectedScene!,
        showLoading: false,
      );
    } catch (e) {}
  }

  _onAnimationSaveAdmin({
    required AnimationModel selectedAnimation,
    required AnimationItemModel selectedScene,
    bool showLoading = true,
    bool saveToDb = true,
  }) async {
    List<FieldItemModel> components =
        ref.read(boardProvider.notifier).onAnimationSave();

    selectedScene.components = components;
    selectedScene.fieldSize =
        ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero();
    int sceneIndex = selectedAnimation.animationScenes.indexWhere(
      (a) => a.id == selectedScene.id,
    );
    if (sceneIndex != -1) {
      selectedAnimation.animationScenes[sceneIndex] = selectedScene;

      selectedAnimation = await _defaultAnimationRepository
          .saveDefaultAnimation(selectedAnimation);

      state = state.copyWith(
        selectedAnimationModel: selectedAnimation,
        selectedScene: selectedScene,
      );
    } else {
      BotToast.showText(text: "No scene found!!");
    }
    return null;
  }

  triggerAutoSaveForAdmin() {
    try {
      _onAnimationSaveAdmin(
        selectedAnimation: state.selectedAnimationModel!,
        selectedScene: state.selectedScene!,
      );
    } catch (e) {}
  }

  void deleteAdminScene({required AnimationItemModel scene}) async {
    AnimationModel? selectedAnimationModel = state.selectedAnimationModel;
    if (selectedAnimationModel != null) {
      selectedAnimationModel.animationScenes.removeWhere(
        (t) => t.id == scene.id,
      );

      if (selectedAnimationModel.animationScenes.isEmpty) {
        selectedAnimationModel.animationScenes
            .add(AnimationItemModel.createEmptyAnimationItem(
          userId: _getUserId(),
          fieldSize: ref.read(boardProvider.notifier).fetchFieldSize() ??
              Vector2(0, 0),
        ));
      }
      selectedAnimationModel = await _defaultAnimationRepository
          .saveDefaultAnimation(selectedAnimationModel);

      ref
          .read(defaultAnimationControllerProvider.notifier)
          .updateAnimationModel(animationToUpdate: selectedAnimationModel);

      state = state.copyWith(
        selectedAnimationModel: selectedAnimationModel,
        selectedScene: selectedAnimationModel.animationScenes.lastOrNull,
      );
    } else {
      zlog(data: "Coming here for no animation found");
      BotToast.showText(text: "No animation found");
    }
  }

  AnimationItemModel _updateSceneWithPlayer(
      AnimationItemModel scene, PlayerModel newPlayerModel) {
    bool sceneModified = false;
    List<FieldItemModel> updatedComponents = scene.components.map((component) {
      if (component is PlayerModel && component.id == newPlayerModel.id) {
        if (component != newPlayerModel) {
          // Only mark modified if it's actually different
          sceneModified = true;
          return newPlayerModel; // Replace with the new model
        }
      }
      return component; // Keep existing component
    }).toList();

    if (sceneModified) {
      // Create a new scene instance with updated components
      return scene.copyWith(
          components: updatedComponents, updatedAt: DateTime.now());
    }
    return scene; // Return original scene if no relevant player was updated or if newModel was identical
  }

  // Helper function to update scenes within an AnimationModel
  AnimationModel _updateAnimationWithPlayer(
      AnimationModel animation, PlayerModel newPlayerModel) {
    bool animationModified = false;
    List<AnimationItemModel> updatedScenes =
        animation.animationScenes.map((scene) {
      AnimationItemModel updatedScene =
          _updateSceneWithPlayer(scene, newPlayerModel);
      if (updatedScene != scene) {
        // Check if the scene instance changed
        animationModified = true;
      }
      return updatedScene;
    }).toList();

    if (animationModified) {
      return animation.copyWith(
          animationScenes: updatedScenes, updatedAt: DateTime.now());
    }
    return animation;
  }

  // Helper function to update animations within an AnimationCollectionModel
  AnimationCollectionModel _updateCollectionWithPlayer(
      AnimationCollectionModel collection, PlayerModel newPlayerModel) {
    bool collectionModified = false;
    List<AnimationModel> updatedAnimations =
        collection.animations.map((animation) {
      AnimationModel updatedAnimation =
          _updateAnimationWithPlayer(animation, newPlayerModel);
      if (updatedAnimation != animation) {
        // Check if the animation instance changed
        collectionModified = true;
      }
      return updatedAnimation;
    }).toList();

    if (collectionModified) {
      return collection.copyWith(
          animations: updatedAnimations, updatedAt: DateTime.now());
    }
    return collection;
  }

  // The main method to update the player model across various state parts
  void updatePlayerModel({
    required PlayerModel newModel,
  }) {
    // 1. Process List<AnimationCollectionModel>
    List<AnimationCollectionModel> updatedCollectionModelList =
        state.animationCollections.map((collection) {
      return _updateCollectionWithPlayer(collection, newModel);
    }).toList();

    // 2. Process List<AnimationModel> (top-level animations)
    List<AnimationModel> updatedAnimationList =
        state.animations.map((animation) {
      return _updateAnimationWithPlayer(animation, newModel);
    }).toList();

    // 3. Process List<AnimationItemModel> (default animations/scenes)
    List<AnimationItemModel> updatedDefaultAnimationsList =
        state.defaultAnimationItems.map((scene) {
      return _updateSceneWithPlayer(scene, newModel);
    }).toList();

    // 4. Process selected items, ensuring they point to the updated instances from the lists if applicable
    AnimationCollectionModel? finalSelectedCollection;
    if (state.selectedAnimationCollectionModel != null) {
      finalSelectedCollection = updatedCollectionModelList.firstWhereOrNull(
        (c) => c.id == state.selectedAnimationCollectionModel!.id,
      );
      if (finalSelectedCollection == null ||
          finalSelectedCollection == state.selectedAnimationCollectionModel) {
        AnimationCollectionModel directlyProcessed =
            _updateCollectionWithPlayer(
                state.selectedAnimationCollectionModel!, newModel);
        if (finalSelectedCollection != null &&
            finalSelectedCollection != directlyProcessed &&
            directlyProcessed != state.selectedAnimationCollectionModel) {}
        finalSelectedCollection = (finalSelectedCollection != null &&
                finalSelectedCollection !=
                    state.selectedAnimationCollectionModel)
            ? finalSelectedCollection
            : directlyProcessed;
      }
    }

    AnimationModel? finalSelectedAnimation;
    if (state.selectedAnimationModel != null) {
      finalSelectedAnimation =
          finalSelectedCollection?.animations.firstWhereOrNull(
                (a) => a.id == state.selectedAnimationModel!.id,
              ) ??
              updatedAnimationList.firstWhereOrNull(
                (a) => a.id == state.selectedAnimationModel!.id,
              );

      if (finalSelectedAnimation == null ||
          finalSelectedAnimation == state.selectedAnimationModel) {
        AnimationModel directlyProcessed =
            _updateAnimationWithPlayer(state.selectedAnimationModel!, newModel);
        finalSelectedAnimation = (finalSelectedAnimation != null &&
                finalSelectedAnimation != state.selectedAnimationModel)
            ? finalSelectedAnimation
            : directlyProcessed;
      }
    }

    AnimationItemModel? finalSelectedScene;
    if (state.selectedScene != null) {
      finalSelectedScene =
          finalSelectedAnimation?.animationScenes.firstWhereOrNull(
                (s) => s.id == state.selectedScene!.id,
              ) ??
              updatedDefaultAnimationsList.firstWhereOrNull(
                (s) => s.id == state.selectedScene!.id,
              );
      if (finalSelectedScene == null ||
          finalSelectedScene == state.selectedScene) {
        AnimationItemModel directlyProcessed =
            _updateSceneWithPlayer(state.selectedScene!, newModel);
        finalSelectedScene = (finalSelectedScene != null &&
                finalSelectedScene != state.selectedScene)
            ? finalSelectedScene
            : directlyProcessed;
      }
    }

    state = state.copyWith(
      animationCollections: updatedCollectionModelList,
      animations: updatedAnimationList,
      selectedAnimationCollectionModel: finalSelectedCollection,
      selectedAnimationModel: finalSelectedAnimation,
      selectedScene: finalSelectedScene,
      defaultAnimationItems: updatedDefaultAnimationsList,
    );
  }

  void updateBoardBackground(BoardBackground newBackground) {
    final selectedAnim = state.selectedAnimationModel;
    final selectedScene = state.selectedScene;

    if (selectedAnim != null && selectedScene != null) {
      selectedAnim.boardBackground = newBackground;

      for (var i = 0; i < selectedAnim.animationScenes.length; i++) {
        selectedAnim.animationScenes[i].boardBackground = newBackground;
      }

      updateDatabaseOnChange(saveToDb: true);
    } else if (selectedScene != null) {
      selectedScene.boardBackground = newBackground;
      updateDatabaseOnChange(saveToDb: true);
    }

    ref.read(boardProvider.notifier).updateBoardBackground(newBackground);
  }

  // Update global home team border color
  void updateHomeTeamBorderColor(Color color) {
    ref.read(boardProvider.notifier).updateHomeTeamBorderColor(color);
  }

  // Update global away team border color
  void updateAwayTeamBorderColor(Color color) {
    ref.read(boardProvider.notifier).updateAwayTeamBorderColor(color);
  }

  Future<void> duplicateScene({required String sceneId}) async {
    final selectedAnim = state.selectedAnimationModel;
    if (selectedAnim == null) return;

    final sceneIndex =
        selectedAnim.animationScenes.indexWhere((s) => s.id == sceneId);
    if (sceneIndex == -1) return;

    final originalScene = selectedAnim.animationScenes[sceneIndex];

    // Create a clone and give it a new ID and timestamp
    final newScene = originalScene.clone().copyWith(
          id: RandomGenerator.generateId(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    // Insert the new scene right after the original
    selectedAnim.animationScenes.insert(sceneIndex + 1, newScene);

    // Re-index all scenes to ensure data integrity
    _reIndexScenes(selectedAnim);

    // Save changes and update the state
    await updateDatabaseOnChange(saveToDb: true);
    state = state.copyWith(
      selectedAnimationModel: selectedAnim.clone(),
    );
  }

  Future<void> insertNewBlankScene({required String afterSceneId}) async {
    final selectedAnim = state.selectedAnimationModel;
    if (selectedAnim == null) return;

    final afterSceneIndex =
        selectedAnim.animationScenes.indexWhere((s) => s.id == afterSceneId);
    if (afterSceneIndex == -1) return;

    // Use the existing helper to create a new empty item
    final newBlankScene = _generateDummyAnimationItem();

    // Insert the new scene right after the specified one
    selectedAnim.animationScenes.insert(afterSceneIndex + 1, newBlankScene);

    // Re-index all scenes
    _reIndexScenes(selectedAnim);

    // Save changes and update the state
    await updateDatabaseOnChange(saveToDb: true);
    state = state.copyWith(
      selectedAnimationModel: selectedAnim.clone(),
    );
  }

  Future<void> editCollectionName({
    required AnimationCollectionModel collection,
    required String newName,
  }) async {
    // Prevent editing the name of the default "Other" collection
    if (collection.id ==
        DefaultAnimationConstants.default_animation_collection_id) {
      BotToast.showText(text: "The default collection cannot be renamed.");
      return;
    }

    // Check for duplicate names among other collections
    final otherCollections =
        state.animationCollections.where((c) => c.id != collection.id);
    if (otherCollections
        .any((c) => c.name.toLowerCase() == newName.toLowerCase())) {
      BotToast.showText(text: "A collection with this name already exists.");
      return;
    }

    showZLoader();
    try {
      // 1. Create the updated model with the new name and timestamp
      final updatedCollection =
          collection.copyWith(name: newName, updatedAt: DateTime.now());

      // 2. Save the change to the database
      await _saveAnimationCollectionUseCase.call(updatedCollection);

      // --- THE FIX: Update the state locally instead of re-fetching ---

      // 3. Get a mutable copy of the current collections list from the state
      final currentCollections =
          List<AnimationCollectionModel>.from(state.animationCollections);

      // 4. Find the index of the collection we just edited
      final index = currentCollections.indexWhere((c) => c.id == collection.id);

      // 5. If found, replace the old model with the updated one right in the list
      if (index != -1) {
        currentCollections[index] = updatedCollection;
      }

      // 6. Update the state precisely with the modified list and selected item.
      // This is a much smaller update and will not cause a full screen re-render.
      state = state.copyWith(
        animationCollections: currentCollections,
        // Also update the 'selected' model directly if it was the one being edited
        selectedAnimationCollectionModel:
            state.selectedAnimationCollectionModel?.id == updatedCollection.id
                ? updatedCollection
                : state.selectedAnimationCollectionModel,
      );
    } catch (e) {
      zlog(data: "Failed to edit collection name: $e");
      BotToast.showText(text: "Error updating collection.");
    } finally {
      BotToast.cleanAll();
    }
  }

  // Future<void> deleteCollection(
  //     {required AnimationCollectionModel collectionToDelete}) async {
  //   // Prevent deleting the default "Other" collection
  //   if (collectionToDelete.id ==
  //       DefaultAnimationConstants.default_animation_collection_id) {
  //     BotToast.showText(text: "The default collection cannot be deleted.");
  //     return;
  //   }
  //
  //   showZLoader();
  //   try {
  //     await _deleteAnimationCollectionUseCase.call(collectionToDelete.id);
  //
  //     // Create a new list without the deleted collection
  //     final currentCollections = state.animationCollections;
  //     currentCollections.removeWhere((c) => c.id == collectionToDelete.id);
  //
  //     // If the deleted collection was the selected one, select the first available collection
  //     if (state.selectedAnimationCollectionModel?.id == collectionToDelete.id) {
  //       selectAnimationCollection(currentCollections.firstOrNull);
  //     } else {
  //       // Otherwise, just update the list but keep the current selection
  //       state = state.copyWith(animationCollections: currentCollections);
  //     }
  //   } catch (e) {
  //     zlog(data: "Failed to delete collection: $e");
  //     BotToast.showText(text: "Error deleting collection.");
  //   } finally {
  //     BotToast.cleanAll();
  //   }
  // }

  // AnimationController - The Corrected Method

  Future<void> deleteCollection(
      {required AnimationCollectionModel collectionToDelete}) async {
    // Prevent deleting the default "Other" collection
    if (collectionToDelete.id ==
        DefaultAnimationConstants.default_animation_collection_id) {
      BotToast.showText(text: "The default collection cannot be deleted.");
      return;
    }

    showZLoader();
    try {
      // 1. Perform the deletion operation first.
      await _deleteAnimationCollectionUseCase.call(collectionToDelete.id);

      // 2. Create a NEW list without the deleted item (IMMUTABILITY).
      final updatedCollections = state.animationCollections
          .where((c) => c.id != collectionToDelete.id)
          .toList();

      // 3. Determine the new collection to select.
      AnimationCollectionModel? newSelectedCollection;
      if (state.selectedAnimationCollectionModel?.id == collectionToDelete.id) {
        // If the deleted one was selected, select the first of the remaining, or null.
        newSelectedCollection = updatedCollections.firstOrNull;
      } else {
        // Otherwise, keep the current selection.
        newSelectedCollection = state.selectedAnimationCollectionModel;
      }

      // 4. Update the entire state in one atomic operation.
      // Call selectAnimationCollection to handle derived state (animations, scenes).
      selectAnimationCollection(newSelectedCollection);

      // Then, explicitly update the master list of collections as well.
      // This ensures all parts of the state are consistent.
      state = state.copyWith(animationCollections: updatedCollections);
    } catch (e) {
      zlog(data: "Failed to delete collection: $e");
      BotToast.showText(text: "Error deleting collection.");
    } finally {
      BotToast.cleanAll();
    }
  }

  Future<void> reorderAnimations(int oldIndex, int newIndex) async {
    final selectedCollection = state.selectedAnimationCollectionModel;
    if (selectedCollection == null) return;

    // Use a mutable copy of the animations list from the selected collection
    final animations = List<AnimationModel>.from(selectedCollection.animations);

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = animations.removeAt(oldIndex);
    animations.insert(newIndex, item);

    // Re-assign orderIndex to all items in the list
    for (int i = 0; i < animations.length; i++) {
      animations[i] = animations[i].copyWith(orderIndex: i);
    }

    // Create an updated collection model
    final updatedCollection = selectedCollection.copyWith(
      animations: animations,
      updatedAt: DateTime.now(),
    );

    // Optimistically update the UI
    state = state.copyWith(
      selectedAnimationCollectionModel: updatedCollection,
      animations: animations,
    );

    // Persist the entire updated collection to the database
    try {
      await _saveAnimationCollectionUseCase.call(updatedCollection);
    } catch (e) {
      // Handle error, maybe revert state
      zlog(data: "Failed to save reordered animations: $e");
      // Consider re-fetching to ensure consistency
      getAllCollections();
    }
  }

  void toggleLoadingSave({required bool showLoading}) {
    state = state.copyWith(showLoadingOnSave: showLoading);
  }

  void setRecordingAnimation({required bool isRecording}) {
    zlog(
      data: "Animation recording state changed: $isRecording",
    );
    state = state.copyWith(
      isRecordingAnimation: isRecording,
      skipHistorySave: isRecording, // Also skip history during recording
    );
  }
}
