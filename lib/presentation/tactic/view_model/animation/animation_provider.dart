import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flame/components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/constants/board_constant.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/animation/model/history_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/delete_history_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_all_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_all_default_animation_items_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_default_scene_from_id_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_history_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_default_animation_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_history_usecase.dart';
import 'package:zporter_tactical_board/presentation/auth/view_model/auth_controller.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/default_animation_utils.dart';
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

  final SaveHistoryUseCase _saveHistoryUseCase = sl.get<SaveHistoryUseCase>();
  final GetHistoryUseCase _getHistoryUseCase = sl.get<GetHistoryUseCase>();
  final DeleteHistoryUseCase _deleteHistoryUseCase =
      sl.get<DeleteHistoryUseCase>();

  void selectAnimationCollection(
    AnimationCollectionModel? animationCollectionModel, {
    AnimationModel? animationSelect,
    bool changeSelectedScene = true,
  }) {
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

    try {
      collections = await _getAllAnimationCollectionUseCase.call(_getUserId());

      if (collections.isEmpty) {
        await _saveAnimationCollectionUseCase.call(
          AnimationCollectionModel(
            id: RandomGenerator.generateId(),
            name: "General",
            animations: [],
            userId: ref.read(authProvider).userId ?? "",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        collections = await _getAllAnimationCollectionUseCase.call(
          _getUserId(),
        );
      }

      try {
        int index = collections.indexWhere(
          (t) => t.id.toLowerCase() == 'default_animation_id',
        );

        if (index == -1) {
          AnimationCollectionModel animationCollectionModel =
              AnimationCollectionModel(
                id: 'default_animation_id',
                name: "Default Animation",
                animations: [
                  ...DefaultAnimationUtils.getAllDefaultAnimations(),
                ],
                userId: ref.read(authProvider).userId ?? "",
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

          collections.insert(0, animationCollectionModel);
        }
      } catch (e) {}

      AnimationCollectionModel? selectedAnimation =
          state.selectedAnimationCollectionModel ?? collections.firstOrNull;
      state = state.copyWith(
        animationCollections: collections,
        isLoadingAnimationCollections: false,
      );

      zlog(data: "All collection ${collections}");

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

  void createNewAnimation(
    String newAnimationName, {
    AnimationItemModel? dummyAnimationPassed,
  }) async {
    BotToast.showLoading();
    try {
      AnimationModel animationModel = AnimationModel(
        userId: _getUserId(),
        fieldColor: BoardConstant.field_color,
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
          fieldColor: BoardConstant.field_color,
          id: RandomGenerator.generateId(),
          userId: _getUserId(),
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

  Future<AnimationItemModel?> _onAnimationSave({
    required AnimationCollectionModel selectedCollection,
    required AnimationModel selectedAnimation,
    required AnimationItemModel selectedScene,
    bool showLoading = true,
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

  void addNewScene({
    required AnimationCollectionModel selectedCollection,
    required AnimationModel selectedAnimation,
    required AnimationItemModel selectedScene,
  }) async {
    selectedCollection = state.selectedAnimationCollectionModel!;
    selectedAnimation = state.selectedAnimationModel!;
    AnimationItemModel newAnimationItemModel = selectedScene.clone(
      addHistory: false,
    );
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
      );
    } catch (e) {}
    // if (savedAnimationSuccessfully) {
    //
    // } else {
    //   BotToast.showText(text: "Server error!!!");
    // }
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
            fieldColor: BoardConstant.field_color,
            id: RandomGenerator.generateId(),
            components: [],
            userId: _getUserId(),
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
      fieldColor: BoardConstant.field_color,
      userId: _getUserId(),
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
      animationItems = await _getAllDefaultAnimationItemsUseCase.call(
        _getUserId(),
      );
    } catch (e) {
      zlog(data: "Animation item fetch issue");
    }
    if (animationItems.isEmpty) {
      animationItems.add(
        AnimationItemModel(
          id: RandomGenerator.generateId(),
          fieldColor: BoardConstant.field_color,
          components: [],
          userId: _getUserId(),
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

  Future<AnimationItemModel?> _onSaveDefault() async {
    try {
      int index = state.defaultAnimationItemIndex;
      List<AnimationItemModel> defaultAnimations = state.defaultAnimationItems;

      AnimationItemModel changeModel = defaultAnimations[index].clone();

      changeModel.components =
          ref.read(boardProvider.notifier).onAnimationSave();
      changeModel.fieldSize =
          ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero();
      // changeModel.fieldColor = ref.read(boardProvider).boardColor;
      defaultAnimations[index] = changeModel;
      zlog(data: "Default animation model List ${changeModel.components}");
      SaveDefaultAnimationParam defaultAnimationParam =
          SaveDefaultAnimationParam(
            animationItems: defaultAnimations,
            userId: _getUserId(),
          );
      _saveDefaultAnimationUseCase.call(defaultAnimationParam);

      state = state.copyWith(selectedScene: changeModel);
      return changeModel;
    } catch (e) {
      zlog(data: "Default Auto save failed $e");
    }
    return null;
  }

  Future<AnimationItemModel?> updateDatabaseOnChange() async {
    AnimationModel? selectedAnimationModel = state.selectedAnimationModel;
    if (selectedAnimationModel == null) {
      try {
        return await _onSaveDefault();
      } catch (e) {
        zlog(data: "Auto save error");
      }
    } else {
      /// working on saved animation
      try {
        return await _onAnimationSave(
          selectedCollection: state.selectedAnimationCollectionModel!,
          selectedAnimation: state.selectedAnimationModel!,
          selectedScene: state.selectedScene!,
          showLoading: false,
        );
      } catch (e) {
        zlog(data: "Auto save error");
      }
    }
    return null;
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
      fieldColor: BoardConstant.field_color,
      id: RandomGenerator.generateId(),
      userId: _getUserId(),
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
    AnimationItemModel deletedItem = defaultItems.removeAt(index);

    BotToast.showLoading();
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
    AnimationItemModel? selectedScene = state.selectedScene;
    // AnimationModel? selectedAnimationModel = state.selectedAnimationModel;
    try {
      HistoryModel? history = await _getHistoryUseCase.call(selectedScene!.id);
      zlog(
        data:
            "Last animation offsets ${history?.history.map((e) => e.components.map((c) => c.offset))}",
      );
      if (history == null) return;
      List<AnimationItemModel> historyList = history.history;
      historyList.removeLast();
      AnimationItemModel? lastAnimation = historyList.lastOrNull;
      history.history = historyList;

      _saveHistoryUseCase.call(history);

      state = state.copyWith(
        selectedScene: lastAnimation,
        isPerformingUndo: true,
      );
    } catch (e) {}

    zlog(data: "Undo operation called ${selectedScene?.id}");
  }

  void toggleUndo({required bool undo}) {
    state = state.copyWith(isPerformingUndo: undo);
  }

  String _getUserId() {
    String? userId = ref.read(authProvider).userId;
    if (userId == null) {
      throw Exception("User Id Not Found");
    }
    return userId;
  }

  void _saveToHistory({required AnimationItemModel scene}) async {
    HistoryModel? historyModel = await _getHistoryUseCase.call(scene.id);
    historyModel ??= HistoryModel(id: scene.id, history: []);
    historyModel.history.add(scene);
    _saveHistoryUseCase.call(historyModel);
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
}
