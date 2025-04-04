import 'package:bot_toast/bot_toast.dart';
import 'package:flame/components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_all_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_all_default_animation_items_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_default_scene_from_id_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_default_animation_usecase.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

final animationProvider =
    StateNotifierProvider<AnimationController, AnimationState>(
      (ref) => AnimationController(ref),
    );

class AnimationController extends StateNotifier<AnimationState> {
  AnimationController(this.ref) : super(AnimationState());

  Ref ref;

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

  void selectAnimationCollection(
    AnimationCollectionModel? animationCollectionModel, {
    AnimationModel? animationSelect,
    bool changeSelectedScene = true,
  }) {
    // if (animationSelect != null) {
    //   int index =
    //       animationCollectionModel?.animations.indexWhere(
    //         (a) => a.id == animationSelect?.id,
    //       ) ??
    //       -1;
    //   if (index == -1) {
    //     animationSelect = null;
    //   }
    // }
    AnimationModel? selectedAnimation = animationSelect;
    state = state.copyWith(
      selectedAnimationCollectionModel: animationCollectionModel,
      animations: animationCollectionModel?.animations ?? [],
      selectedAnimationModel: selectedAnimation,
      selectedScene:
          changeSelectedScene == true
              ? selectedAnimation?.animationScenes.first
              : state.selectedScene,
      showNewCollectionInput: false,
      showNewAnimationInput: false,
      showQuickSave: false,
    );
  }

  Future<void> getAllCollections() async {
    state = state.copyWith(isLoadingAnimationCollections: true);
    List<AnimationCollectionModel> collections = state.animationCollections;
    zlog(data: "Animation collection fetching issue ");
    try {
      collections = await _getAllAnimationCollectionUseCase.call(null);
      AnimationCollectionModel? selectedAnimation =
          state.selectedAnimationCollectionModel ?? collections.firstOrNull;
      state = state.copyWith(
        animationCollections: collections,
        isLoadingAnimationCollections: false,
      );
      selectAnimationCollection(selectedAnimation);
    } catch (e) {
      zlog(data: "Animation collection fetching issue ${e}");
    }
  }

  void createNewCollection(String newCollectionName) async {
    BotToast.showLoading();
    try {
      AnimationCollectionModel animationCollectionModel =
          AnimationCollectionModel(
            id: RandomGenerator.generateId(),
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

  void createNewAnimation(
    String newAnimationName, {
    AnimationItemModel? dummyAnimationPassed,
  }) async {
    BotToast.showLoading();
    try {
      AnimationModel animationModel = AnimationModel(
        id: RandomGenerator.generateId(),
        name: newAnimationName,
        animationScenes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AnimationCollectionModel? animationCollectionModel =
          state.selectedAnimationCollectionModel;
      if (animationCollectionModel == null) {
        BotToast.showText(text: "No Collection is selected");
        return;
      }

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
          id: RandomGenerator.generateId(),
          fieldSize:
              ref.read(boardProvider.notifier).fetchFieldSize() ??
              Vector2(0, 0),
          components: dummyAnimationPassed?.components ?? [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      animationCollectionModel.animations.add(animationModel);
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
  }

  void clearAnimation() {
    state = state.copyWith(
      selectedAnimationModel: null,
      selectedScene: state.defaultAnimationItems[0],
      defaultAnimationItemIndex: 0,
    );
  }

  void copyAnimation(String name, AnimationModel animation) async {
    AnimationCollectionModel? animationCollectionModel =
        state.selectedAnimationCollectionModel;
    if (animationCollectionModel == null) {
      BotToast.showText(text: "Please select a collection");
      return;
    }
    AnimationModel newAnimationModel = animation.clone();
    newAnimationModel.id = RandomGenerator.generateId();
    newAnimationModel.name = name;
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
    BotToast.showLoading();
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

  Future<bool> _onAnimationSave({
    required AnimationCollectionModel selectedCollection,
    required AnimationModel selectedAnimation,
    required AnimationItemModel selectedScene,
    bool showLoading = true,
    required bool addToHistory,
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
          BotToast.showLoading();
        }

        try {
          selectedCollection = await _saveAnimationCollectionUseCase.call(
            selectedCollection,
          );

          state = state.copyWith(
            selectedAnimationCollectionModel: selectedCollection,
            selectedAnimationModel: selectedAnimation,
            selectedScene: selectedScene,
          );
          BotToast.showText(text: "Scene Saved Successfully ${selectedScene}");
          return true;
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
    return false;
  }

  void addNewScene({
    required AnimationCollectionModel selectedCollection,
    required AnimationModel selectedAnimation,
    required AnimationItemModel selectedScene,
  }) async {
    bool savedAnimationSuccessfully = await _onAnimationSave(
      selectedCollection: selectedCollection,
      selectedAnimation: selectedAnimation,
      selectedScene: selectedScene,
      addToHistory: false,
    );
    if (savedAnimationSuccessfully) {
      selectedCollection = state.selectedAnimationCollectionModel!;
      selectedAnimation = state.selectedAnimationModel!;
      AnimationItemModel newAnimationItemModel = selectedScene.clone();
      newAnimationItemModel.id = RandomGenerator.generateId();
      newAnimationItemModel.createdAt = DateTime.now();
      newAnimationItemModel.updatedAt = DateTime.now();
      selectedAnimation.animationScenes.add(newAnimationItemModel);

      state = state.copyWith(
        selectedAnimationCollectionModel: selectedCollection,
        selectedAnimationModel: selectedAnimation,
        selectedScene: selectedAnimation.animationScenes.last,
      );
      try {
        _onAnimationSave(
          selectedCollection: state.selectedAnimationCollectionModel!,
          selectedAnimation: state.selectedAnimationModel!,
          selectedScene: state.selectedScene!,
          showLoading: false,
          addToHistory: false,
        );
      } catch (e) {}
    } else {
      BotToast.showText(text: "Server error!!!");
    }
  }

  void selectScene({required AnimationItemModel scene}) {
    state = state.copyWith(selectedScene: scene);
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

      if (selectedAnimationModel.animationScenes.isEmpty) {
        selectedAnimationModel.animationScenes.add(
          AnimationItemModel(
            id: RandomGenerator.generateId(),
            components: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            fieldSize:
                ref.read(boardProvider.notifier).fetchFieldSize() ??
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

  void toggleNewCollectionInputShow(bool show) {
    state = state.copyWith(showNewCollectionInput: show);
  }

  void toggleNewAnimationInputShow(bool show) {
    state = state.copyWith(showNewAnimationInput: show);
  }

  void showQuickSave() {
    List<FieldItemModel> components =
        ref.read(boardProvider.notifier).onAnimationSave();
    AnimationItemModel quickSaveAnimation = AnimationItemModel(
      id: RandomGenerator.generateId(),
      components: components,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
      animationItems = await _getAllDefaultAnimationItemsUseCase.call(null);
      zlog(data: "Animation item fetch ${animationItems}");
    } catch (e) {
      zlog(data: "Animation item fetch issue");
    }
    if (animationItems.isEmpty) {
      animationItems.add(
        AnimationItemModel(
          id: RandomGenerator.generateId(),
          components: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          fieldSize:
              ref.read(boardProvider.notifier).fetchFieldSize() ??
              Vector2.zero(),
        ),
      );
    }
    state = state.copyWith(
      defaultAnimationItems: animationItems,
      selectedScene: animationItems.first,
      defaultAnimationItemIndex: 0,
    );
  }

  void changeDefaultAnimationIndex(int index) {
    zlog(data: 'Default animation index ${index}');
    state = state.copyWith(
      defaultAnimationItemIndex: index,
      selectedScene: state.defaultAnimationItems[index],
    );
  }

  void _onSaveDefault({
    required bool addToHistory,
    required bool performUndo,
  }) async {
    try {
      int index = state.defaultAnimationItemIndex;
      List<AnimationItemModel> defaultAnimations = state.defaultAnimationItems;

      AnimationItemModel changeModel = defaultAnimations[index].clone(
        addHistory: true,
      );

      if (addToHistory) {
        AnimationItemModel? dummy = await _getDefaultSceneFromIdUseCase.call(
          changeModel.id,
        );
        changeModel.addToHistory(dummy ?? changeModel);
        // changeModel.addToHistory(dummy.clone());
      }

      if (performUndo) {
        changeModel = changeModel.undo();
      } else {
        changeModel.components =
            ref.read(boardProvider.notifier).onAnimationSave();
      }

      changeModel.fieldSize =
          ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero();
      defaultAnimations[index] = changeModel;

      zlog(data: "Default animation model ${defaultAnimations}");
      _saveDefaultAnimationUseCase.call(defaultAnimations);
      state = state.copyWith(selectedScene: changeModel);
    } catch (e) {
      zlog(data: "Default Auto save failed $e");
    }
  }

  void updateDatabaseOnChange({
    bool addToHistory = true,
    bool performUndo = false,
  }) async {
    AnimationModel? selectedAnimationModel = state.selectedAnimationModel;
    AnimationItemModel? selectedScene = state.selectedScene;

    if (selectedAnimationModel == null) {
      try {
        _onSaveDefault(addToHistory: addToHistory, performUndo: performUndo);
        zlog(data: "Auto save default");
      } catch (e) {
        zlog(data: "Auto save error");
      }
    } else {
      /// working on saved animation
      try {
        _onAnimationSave(
          selectedCollection: state.selectedAnimationCollectionModel!,
          selectedAnimation: state.selectedAnimationModel!,
          selectedScene: state.selectedScene!,
          showLoading: false,
          addToHistory: addToHistory,
        );
        zlog(data: "Auto save complete");
      } catch (e) {
        zlog(data: "Auto save error");
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

  AnimationItemModel _generateDummyAnimationItem() {
    return AnimationItemModel(
      id: RandomGenerator.generateId(),
      components: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      fieldSize:
          ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero(),
    );
  }

  void deleteDefaultAnimation() async {
    int index = state.defaultAnimationItemIndex;
    List<AnimationItemModel> defaultItems = state.defaultAnimationItems;
    defaultItems.removeAt(index);
    BotToast.showLoading();
    try {
      defaultItems = await _saveDefaultAnimationUseCase.call(defaultItems);
      index = index >= defaultItems.length ? defaultItems.length - 1 : index;

      if (defaultItems.isEmpty) {
        defaultItems.add(_generateDummyAnimationItem());
        index = 0;
      }

      state = state.copyWith(
        defaultAnimationItems: defaultItems,
        defaultAnimationItemIndex: index,
        selectedScene: defaultItems[index],
      );
    } catch (e) {}
    BotToast.cleanAll();
  }

  void performUndoOperation() {
    // AnimationItemModel? selectedScene = state.selectedScene;
    // if (selectedScene?.canUndo == true) {
    //   selectedScene?.undo();
    // }
    // state = state.copyWith(selectedScene: selectedScene);
    updateDatabaseOnChange(addToHistory: false, performUndo: true);
  }
}
