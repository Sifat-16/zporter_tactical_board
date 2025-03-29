import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_all_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart';

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
      animationCollectionModel.animations.add(animationModel);
      animationCollectionModel = await _saveAnimationCollectionUseCase.call(
        animationCollectionModel,
      );

      selectAnimationCollection(
        animationCollectionModel,
        animationSelect: animationModel,
      );
      // state = state.copyWith(
      //   selectedAnimationModel: animationModel,
      //   selectedAnimationCollectionModel: animationCollectionModel,
      // );
    } catch (e) {
      zlog(data: "Animation creating issue ${e}");
    } finally {
      BotToast.cleanAll();
    }
  }

  void selectAnimation(AnimationModel? s) {
    zlog(data: "Animation model came ${s}");
    state = state.copyWith(selectedAnimationModel: s);
  }
}
