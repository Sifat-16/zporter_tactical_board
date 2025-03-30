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
import 'package:zporter_tactical_board/domain/animation/usecase/save_animation_collection_usecase.dart';
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

  void selectAnimationCollection(
    AnimationCollectionModel? animationCollectionModel, {
    AnimationModel? animationSelect,
  }) {
    if (animationSelect != null) {
      int index =
          animationCollectionModel?.animations.indexWhere(
            (a) => a.id == animationSelect?.id,
          ) ??
          -1;
      if (index == -1) {
        animationSelect = null;
      }
    }
    AnimationModel? selectedAnimation = animationSelect;
    state = state.copyWith(
      selectedAnimationCollectionModel: animationCollectionModel,
      animations: animationCollectionModel?.animations ?? [],
      selectedAnimationModel: selectedAnimation,
      selectedScene: selectedAnimation?.animationScenes.first,
    );
  }

  void getAllCollections() async {
    state = state.copyWith(isLoadingAnimationCollections: true);
    List<AnimationCollectionModel> collections = state.animationCollections;
    try {
      collections = await _getAllAnimationCollectionUseCase.call(null);
    } catch (e) {
      zlog(data: "Animation collection fetching issue ${e}");
    } finally {
      AnimationCollectionModel? selectedAnimation =
          state.selectedAnimationCollectionModel ?? collections.firstOrNull;
      state = state.copyWith(
        animationCollections: collections,
        isLoadingAnimationCollections: false,
      );
      selectAnimationCollection(selectedAnimation);
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
      selectAnimationCollection(newAnimationCollectionModel);
    } catch (e) {
      zlog(data: "Animation collection creating issue ${e}");
    } finally {
      BotToast.cleanAll();
    }
  }

  void createNewAnimation(String newAnimationName) async {
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
          components: [],
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

  Future<bool> onAnimationSave({
    required AnimationCollectionModel selectedCollection,
    required AnimationModel selectedAnimation,
    required AnimationItemModel selectedScene,
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

        BotToast.showLoading();
        try {
          selectedCollection = await _saveAnimationCollectionUseCase.call(
            selectedCollection,
          );

          state = state.copyWith(
            selectedAnimationCollectionModel: selectedCollection,
            selectedAnimationModel: selectedAnimation,
            selectedScene: selectedScene,
          );
          BotToast.showText(text: "Scene Saved Successfully");
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
    bool savedAnimationSuccessfully = await onAnimationSave(
      selectedCollection: selectedCollection,
      selectedAnimation: selectedAnimation,
      selectedScene: selectedScene,
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
    selectAnimationCollection(selectedCollectionModel);
  }
}
