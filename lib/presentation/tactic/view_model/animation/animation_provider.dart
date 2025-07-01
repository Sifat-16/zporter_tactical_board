// import 'dart:ui';
//
// import 'package:bot_toast/bot_toast.dart';
// import 'package:flame/components.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/core/component/z_loader.dart';
// import 'package:zporter_tactical_board/app/core/constants/board_constant.dart';
// import 'package:zporter_tactical_board/app/core/dialogs/animation_copy_dialog.dart';
// import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
// import 'package:zporter_tactical_board/app/generator/random_generator.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/services/injection_container.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/history_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
// import 'package:zporter_tactical_board/domain/admin/default_animation/default_animation_repository.dart';
// import 'package:zporter_tactical_board/domain/animation/usecase/delete_history_usecase.dart';
// import 'package:zporter_tactical_board/domain/animation/usecase/get_all_animation_collection_usecase.dart';
// import 'package:zporter_tactical_board/domain/animation/usecase/get_all_default_animation_items_usecase.dart';
// import 'package:zporter_tactical_board/domain/animation/usecase/get_default_scene_from_id_usecase.dart';
// import 'package:zporter_tactical_board/domain/animation/usecase/get_history_usecase.dart';
// import 'package:zporter_tactical_board/domain/animation/usecase/save_animation_collection_usecase.dart';
// import 'package:zporter_tactical_board/domain/animation/usecase/save_default_animation_usecase.dart';
// import 'package:zporter_tactical_board/domain/animation/usecase/save_history_usecase.dart';
// import 'package:zporter_tactical_board/presentation/admin/view/animation/default_animation_constants.dart';
// import 'package:zporter_tactical_board/presentation/admin/view_model/default_animation_view_model/default_animation_controller.dart';
// import 'package:zporter_tactical_board/presentation/auth/view_model/auth_controller.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/animation_data_input_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';
//
// final animationProvider =
//     StateNotifierProvider<AnimationController, AnimationState>(
//   (ref) => AnimationController(ref),
// );
//
// class AnimationController extends StateNotifier<AnimationState> {
//   AnimationController(this.ref) : super(AnimationState());
//
//   Ref ref;
//
//   final SaveAnimationCollectionUseCase _saveAnimationCollectionUseCase =
//       sl.get<SaveAnimationCollectionUseCase>();
//   final GetAllAnimationCollectionUseCase _getAllAnimationCollectionUseCase =
//       sl.get<GetAllAnimationCollectionUseCase>();
//
//   final GetAllDefaultAnimationItemsUseCase _getAllDefaultAnimationItemsUseCase =
//       sl.get<GetAllDefaultAnimationItemsUseCase>();
//
//   final SaveDefaultAnimationUseCase _saveDefaultAnimationUseCase =
//       sl.get<SaveDefaultAnimationUseCase>();
//
//   final GetDefaultSceneFromIdUseCase _getDefaultSceneFromIdUseCase =
//       sl.get<GetDefaultSceneFromIdUseCase>();
//
//   final SaveHistoryUseCase _saveHistoryUseCase = sl.get<SaveHistoryUseCase>();
//   final GetHistoryUseCase _getHistoryUseCase = sl.get<GetHistoryUseCase>();
//   final DeleteHistoryUseCase _deleteHistoryUseCase =
//       sl.get<DeleteHistoryUseCase>();
//   final DefaultAnimationRepository _defaultAnimationRepository =
//       sl.get<DefaultAnimationRepository>();
//
//   void selectAnimationCollection(
//     AnimationCollectionModel? animationCollectionModel, {
//     AnimationModel? animationSelect,
//     bool changeSelectedScene = true,
//   }) {
//     AnimationModel? selectedAnimation = animationSelect;
//     state = state.copyWith(
//       selectedAnimationCollectionModel: animationCollectionModel,
//       animations: animationCollectionModel?.animations ?? [],
//       selectedAnimationModel: selectedAnimation,
//       selectedScene: changeSelectedScene == true
//           ? selectedAnimation?.animationScenes.first
//           : state.selectedScene,
//       showNewCollectionInput: false,
//       showNewAnimationInput: false,
//       showQuickSave: false,
//     );
//   }
//
//   Future<void> getAllCollections() async {
//     state = state.copyWith(isLoadingAnimationCollections: true);
//     List<AnimationCollectionModel> collections = state.animationCollections;
//
//     try {
//       collections = await _getAllAnimationCollectionUseCase.call(_getUserId());
//
//       // collections = AnimationCollectionDefaultUtils.addDefaultCollections(
//       //     collections: collections,
//       //     userId: ref.read(authProvider).userId ?? "");
//
//       // if (collections.isEmpty) {
//       //   await _saveAnimationCollectionUseCase.call(
//       //     AnimationCollectionModel(
//       //       id: RandomGenerator.generateId(),
//       //       name: "General",
//       //       animations: [],
//       //       userId: ref.read(authProvider).userId ?? "",
//       //       createdAt: DateTime.now(),
//       //       updatedAt: DateTime.now(),
//       //     ),
//       //   );
//       //   collections = await _getAllAnimationCollectionUseCase.call(
//       //     _getUserId(),
//       //   );
//       // }
//
//       try {
//         int index = collections.indexWhere(
//           (t) =>
//               t.id.toLowerCase() ==
//               DefaultAnimationConstants.default_animation_collection_id,
//         );
//
//         if (index == -1) {
//           List<AnimationModel> default_animations =
//               await _defaultAnimationRepository.getAllDefaultAnimations();
//           AnimationCollectionModel animationCollectionModel =
//               AnimationCollectionModel(
//             id: DefaultAnimationConstants.default_animation_collection_id,
//             name: "Other",
//             animations: default_animations,
//             userId: ref.read(authProvider).userId ?? "",
//             createdAt: DateTime.now(),
//             updatedAt: DateTime.now(),
//           );
//
//           collections.add(animationCollectionModel);
//         }
//       } catch (e) {}
//
//       AnimationCollectionModel? selectedAnimation =
//           state.selectedAnimationCollectionModel ?? collections.firstOrNull;
//       state = state.copyWith(
//         animationCollections: collections,
//         isLoadingAnimationCollections: false,
//       );
//
//       zlog(data: "All collection ${collections}");
//
//       selectAnimationCollection(selectedAnimation);
//     } catch (e) {
//       zlog(data: "Animation collection fetching issue ${e}");
//     }
//   }
//
//   void createNewCollection(String newCollectionName) async {
//     // BotToast.showLoading();
//     showZLoader();
//     try {
//       AnimationCollectionModel animationCollectionModel =
//           AnimationCollectionModel(
//         id: RandomGenerator.generateId(),
//         userId: _getUserId(),
//         name: newCollectionName,
//         animations: [],
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//
//       List<AnimationCollectionModel> collections = state.animationCollections;
//
//       if (_isDuplicateAnimationCollection(
//         collections,
//         animationCollectionModel,
//       )) {
//         BotToast.showText(
//           text: "Duplicate collection name. Collection name must be unique.",
//         );
//         return;
//       }
//
//       AnimationCollectionModel newAnimationCollectionModel =
//           await _saveAnimationCollectionUseCase.call(animationCollectionModel);
//       collections.add(newAnimationCollectionModel);
//       state = state.copyWith(animationCollections: collections);
//       selectAnimationCollection(
//         newAnimationCollectionModel,
//         changeSelectedScene: false,
//       );
//     } catch (e) {
//       zlog(data: "Animation collection creating issue ${e}");
//     } finally {
//       BotToast.cleanAll();
//     }
//   }
//
//   void createNewAnimation({required AnimationCreateItem newAnimation}) async {
//     // BotToast.showLoading();
//     showZLoader();
//     try {
//       AnimationModel animationModel = AnimationModel(
//         userId: _getUserId(),
//         fieldColor: BoardConstant.field_color,
//         id: RandomGenerator.generateId(),
//         name: newAnimation.newAnimationName,
//         animationScenes: [],
//         boardBackground: ref.read(boardProvider).boardBackground,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//
//       AnimationCollectionModel animationCollectionModel =
//           newAnimation.animationCollectionModel;
//
//       if (_isDuplicateAnimation(
//         animationCollectionModel.animations,
//         animationModel,
//       )) {
//         BotToast.showText(
//           text: "Duplicate animation name. Animation name must be unique.",
//         );
//         return;
//       }
//
//       animationModel.animationScenes.add(
//         AnimationItemModel(
//           fieldColor: BoardConstant.field_color,
//           id: RandomGenerator.generateId(),
//           userId: _getUserId(),
//           fieldSize: ref.read(boardProvider.notifier).fetchFieldSize() ??
//               Vector2(0, 0),
//           boardBackground: ref.read(boardProvider).boardBackground,
//           components: newAnimation.items,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//       );
//
//       animationCollectionModel.animations.add(animationModel);
//       animationCollectionModel = await _saveAnimationCollectionUseCase.call(
//         animationCollectionModel,
//       );
//
//       selectAnimationCollection(
//         animationCollectionModel,
//         animationSelect: animationModel,
//       );
//     } catch (e) {
//       zlog(data: "Animation creating issue ${e}");
//     } finally {
//       BotToast.cleanAll();
//     }
//   }
//
//   void selectAnimation(AnimationModel? s) {
//     zlog(data: "Animation model came ${s}");
//     state = state.copyWith(
//       selectedAnimationModel: s,
//       selectedScene: s?.animationScenes.firstOrNull,
//     );
//     ref
//         .read(boardProvider.notifier)
//         .updateBoardBackground(s?.boardBackground ?? BoardBackground.full);
//   }
//
//   void clearAnimation() {
//     state = state.copyWith(
//       selectedAnimationModel: null,
//       selectedScene: state.defaultAnimationItems[0],
//       defaultAnimationItemIndex: 0,
//     );
//   }
//
//   void copyAnimation(AnimationCopyItem animationCopyItem) async {
//     AnimationCollectionModel? animationCollectionModel =
//         animationCopyItem.animationCollectionModel;
//     if (animationCollectionModel == null) {
//       BotToast.showText(text: "Please select a collection");
//       return;
//     }
//     AnimationModel newAnimationModel = animationCopyItem.animationModel.clone();
//     newAnimationModel.id = RandomGenerator.generateId();
//     newAnimationModel.name = animationCopyItem.newAnimationName;
//     newAnimationModel.createdAt = DateTime.now();
//     newAnimationModel.updatedAt = DateTime.now();
//
//     if (_isDuplicateAnimation(
//       animationCollectionModel.animations,
//       newAnimationModel,
//     )) {
//       BotToast.showText(
//         text: "Duplicate animation name. Animation name must be unique.",
//       );
//       return;
//     }
//     // BotToast.showLoading();
//     showZLoader();
//     try {
//       animationCollectionModel.animations.add(newAnimationModel);
//       animationCollectionModel = await _saveAnimationCollectionUseCase.call(
//         animationCollectionModel,
//       );
//
//       selectAnimationCollection(
//         animationCollectionModel,
//         animationSelect: newAnimationModel,
//       );
//     } catch (e) {
//       zlog(data: "Animation creating issue ${e}");
//     } finally {
//       BotToast.cleanAll();
//     }
//   }
//
//   bool _isDuplicateAnimation(
//     List<AnimationModel> animations,
//     AnimationModel newAnimation,
//   ) {
//     List<String> animationNames =
//         animations.map((a) => a.name.toLowerCase()).toList();
//     if (animationNames.contains(newAnimation.name.toLowerCase())) {
//       return true;
//     }
//     return false;
//   }
//
//   bool _isDuplicateAnimationCollection(
//     List<AnimationCollectionModel> animations,
//     AnimationCollectionModel newAnimation,
//   ) {
//     List<String> animationNames =
//         animations.map((a) => a.name.toLowerCase()).toList();
//     if (animationNames.contains(newAnimation.name.toLowerCase())) {
//       return true;
//     }
//     return false;
//   }
//
//   Future<void> saveAnimationTime({
//     required Duration newDuration,
//     required String sceneId,
//   }) async {
//     AnimationCollectionModel? selectedCollection =
//         state.selectedAnimationCollectionModel;
//     AnimationModel? selectedAnimation = state.selectedAnimationModel;
//     int index =
//         selectedAnimation?.animationScenes.indexWhere((a) => a.id == sceneId) ??
//             -1;
//     if (index != -1) {
//       try {
//         AnimationItemModel scene = selectedAnimation!.animationScenes[index];
//         scene = scene.copyWith(sceneDuration: newDuration);
//         selectedAnimation.animationScenes[index] = scene;
//         int animationIndex = selectedCollection!.animations.indexWhere(
//           (a) => a.id == selectedAnimation.id,
//         );
//         if (animationIndex != -1) {
//           selectedCollection.animations[animationIndex] = selectedAnimation;
//           try {
//             _saveAnimationCollectionUseCase.call(selectedCollection);
//           } catch (e) {}
//         } else {}
//       } catch (e) {}
//     }
//   }
//
//   Future<AnimationItemModel?> _onAnimationSave({
//     required AnimationCollectionModel selectedCollection,
//     required AnimationModel selectedAnimation,
//     required AnimationItemModel selectedScene,
//     bool showLoading = true,
//     bool saveToDb = true,
//   }) async {
//     List<FieldItemModel> components =
//         ref.read(boardProvider.notifier).onAnimationSave();
//
//     selectedScene.components = components;
//     selectedScene.fieldSize =
//         ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero();
//     int sceneIndex = selectedAnimation.animationScenes.indexWhere(
//       (a) => a.id == selectedScene.id,
//     );
//     if (sceneIndex != -1) {
//       selectedAnimation.animationScenes[sceneIndex] = selectedScene;
//       int animationIndex = selectedCollection.animations.indexWhere(
//         (a) => a.id == selectedAnimation.id,
//       );
//
//       if (animationIndex != -1) {
//         selectedCollection.animations[animationIndex] = selectedAnimation;
//
//         if (showLoading) {
//           // BotToast.showLoading();
//           showZLoader();
//         }
//
//         try {
//           if (saveToDb) {
//             selectedCollection = await _saveAnimationCollectionUseCase.call(
//               selectedCollection,
//             );
//           }
//
//           state = state.copyWith(
//             selectedAnimationCollectionModel: selectedCollection,
//             selectedAnimationModel: selectedAnimation,
//             selectedScene: selectedScene,
//           );
//           BotToast.showText(text: "Scene Saved Successfully ${selectedScene}");
//           return selectedScene;
//         } catch (e) {
//           BotToast.showText(text: "Unexpected server error ${e}");
//         } finally {
//           BotToast.cleanAll();
//         }
//       } else {
//         BotToast.showText(text: "No Animation found!!");
//       }
//     } else {
//       BotToast.showText(text: "No scene found!!");
//     }
//     return null;
//   }
//
//   void addNewScene({
//     required AnimationCollectionModel selectedCollection,
//     required AnimationModel selectedAnimation,
//     required AnimationItemModel selectedScene,
//   }) async {
//     selectedCollection = state.selectedAnimationCollectionModel!;
//     selectedAnimation = state.selectedAnimationModel!;
//     AnimationItemModel newAnimationItemModel = selectedScene.clone(
//       addHistory: false,
//     );
//     newAnimationItemModel.id = RandomGenerator.generateId();
//     newAnimationItemModel.createdAt = DateTime.now();
//     newAnimationItemModel.updatedAt = DateTime.now();
//     selectedAnimation.animationScenes.add(newAnimationItemModel);
//
//     state = state.copyWith(
//       selectedAnimationCollectionModel: selectedCollection,
//       selectedAnimationModel: selectedAnimation,
//       selectedScene: selectedAnimation.animationScenes.last,
//     );
//     try {
//       _onAnimationSave(
//         selectedCollection: state.selectedAnimationCollectionModel!,
//         selectedAnimation: state.selectedAnimationModel!,
//         selectedScene: state.selectedScene!,
//         showLoading: false,
//       );
//     } catch (e) {}
//   }
//
//   void selectScene({required AnimationItemModel scene}) {
//     zlog(data: "Copy with method called check");
//     state = state.copyWith(selectedScene: scene);
//     ref
//         .read(boardProvider.notifier)
//         .updateBoardBackground(scene.boardBackground);
//   }
//
//   void toggleAnimation() {
//     state = state.copyWith(showAnimation: !state.showAnimation);
//   }
//
//   void deleteScene({required AnimationItemModel scene}) async {
//     AnimationCollectionModel? selectedCollectionModel =
//         state.selectedAnimationCollectionModel;
//     AnimationModel? selectedAnimationModel = state.selectedAnimationModel;
//     if (selectedCollectionModel != null && selectedAnimationModel != null) {
//       selectedAnimationModel.animationScenes.removeWhere(
//         (t) => t.id == scene.id,
//       );
//
//       if (selectedAnimationModel.animationScenes.isEmpty) {
//         selectedAnimationModel.animationScenes.add(
//           AnimationItemModel(
//             fieldColor: BoardConstant.field_color,
//             id: RandomGenerator.generateId(),
//             components: [],
//             userId: _getUserId(),
//             createdAt: DateTime.now(),
//             updatedAt: DateTime.now(),
//             fieldSize: ref.read(boardProvider.notifier).fetchFieldSize() ??
//                 Vector2(0, 0),
//           ),
//         );
//       }
//       int index = selectedCollectionModel.animations.indexWhere(
//         (t) => t.id == selectedAnimationModel.id,
//       );
//       if (index != -1) {
//         selectedCollectionModel.animations[index] = selectedAnimationModel;
//       }
//       selectedCollectionModel = await _saveAnimationCollectionUseCase.call(
//         selectedCollectionModel,
//       );
//       state = state.copyWith(
//         selectedAnimationCollectionModel: selectedCollectionModel,
//         selectedAnimationModel: selectedAnimationModel,
//         selectedScene: selectedAnimationModel.animationScenes.lastOrNull,
//       );
//     } else {
//       BotToast.showText(text: "No animation found");
//     }
//   }
//
//   void deleteAnimation({required AnimationModel animation}) async {
//     AnimationCollectionModel? selectedCollectionModel =
//         state.selectedAnimationCollectionModel;
//
//     if (selectedCollectionModel == null) {
//       BotToast.showText(text: "No Collection is selected");
//       return;
//     }
//
//     selectedCollectionModel.animations.removeWhere((t) => t.id == animation.id);
//
//     selectedCollectionModel = await _saveAnimationCollectionUseCase.call(
//       selectedCollectionModel,
//     );
//     selectAnimationCollection(
//       selectedCollectionModel,
//       changeSelectedScene: false,
//     );
//   }
//
//   void toggleNewCollectionInputShow(bool show) {
//     state = state.copyWith(showNewCollectionInput: show);
//   }
//
//   void toggleNewAnimationInputShow(bool show) {
//     state = state.copyWith(showNewAnimationInput: show);
//   }
//
//   void showQuickSave() {
//     List<FieldItemModel> components =
//         ref.read(boardProvider.notifier).onAnimationSave();
//     AnimationItemModel quickSaveAnimation = AnimationItemModel(
//       fieldColor: BoardConstant.field_color,
//       userId: _getUserId(),
//       id: RandomGenerator.generateId(),
//       components: components,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//       fieldSize:
//           ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2(0, 0),
//     );
//     state = state.copyWith(
//       showQuickSave: true,
//       selectedScene: quickSaveAnimation,
//     );
//   }
//
//   void cancelQuickSave() {
//     state = state.copyWith(showQuickSave: false);
//   }
//
//   Future<void> configureDefaultAnimations() async {
//     List<AnimationItemModel> animationItems = [];
//     try {
//       animationItems = await _getAllDefaultAnimationItemsUseCase.call(
//         _getUserId(),
//       );
//     } catch (e) {
//       zlog(data: "Animation item fetch issue");
//     }
//     if (animationItems.isEmpty) {
//       animationItems.add(
//         AnimationItemModel(
//           id: RandomGenerator.generateId(),
//           fieldColor: BoardConstant.field_color,
//           components: [],
//           userId: _getUserId(),
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//           fieldSize: ref.read(boardProvider.notifier).fetchFieldSize() ??
//               Vector2.zero(),
//         ),
//       );
//     }
//
//     state = state.copyWith(
//       defaultAnimationItems: animationItems,
//       selectedScene: animationItems.first,
//       defaultAnimationItemIndex: 0,
//     );
//   }
//
//   void changeDefaultAnimationIndex(int index) {
//     zlog(data: 'Default animation index ${index}');
//     state = state.copyWith(
//       defaultAnimationItemIndex: index,
//       selectedScene: state.defaultAnimationItems[index],
//     );
//   }
//
//   Future<AnimationItemModel?> _onSaveDefault() async {
//     try {
//       int index = state.defaultAnimationItemIndex;
//       List<AnimationItemModel> defaultAnimations = state.defaultAnimationItems;
//
//       AnimationItemModel changeModel = defaultAnimations[index].clone();
//
//       changeModel.components =
//           ref.read(boardProvider.notifier).onAnimationSave();
//       changeModel.fieldSize =
//           ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero();
//       // changeModel.fieldColor = ref.read(boardProvider).boardColor;
//       defaultAnimations[index] = changeModel;
//       zlog(
//           data:
//               "Default animation model List ${changeModel.components} - ${changeModel.boardBackground}");
//       SaveDefaultAnimationParam defaultAnimationParam =
//           SaveDefaultAnimationParam(
//         animationItems: defaultAnimations,
//         userId: _getUserId(),
//       );
//       _saveDefaultAnimationUseCase.call(defaultAnimationParam);
//
//       state = state.copyWith(selectedScene: changeModel);
//       return changeModel;
//     } catch (e) {
//       zlog(data: "Default Auto save failed $e");
//     }
//     return null;
//   }
//
//   Future<AnimationItemModel?> updateDatabaseOnChange({
//     required bool saveToDb,
//   }) async {
//     if (saveToDb == false) {
//       AnimationItemModel? changeModel =
//           state.selectedScene ?? AnimationItemModel.createEmptyAnimationItem();
//       changeModel.components =
//           ref.read(boardProvider.notifier).onAnimationSave();
//       changeModel.fieldSize =
//           ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero();
//       state = state.copyWith(selectedScene: changeModel);
//       return changeModel;
//     }
//     AnimationModel? selectedAnimationModel = state.selectedAnimationModel;
//     if (selectedAnimationModel == null) {
//       try {
//         return await _onSaveDefault();
//       } catch (e) {
//         zlog(data: "Auto save error");
//       }
//     } else {
//       /// working on saved animation
//       try {
//         return await _onAnimationSave(
//           selectedCollection: state.selectedAnimationCollectionModel!,
//           selectedAnimation: state.selectedAnimationModel!,
//           selectedScene: state.selectedScene!,
//           showLoading: false,
//           saveToDb: saveToDb,
//         );
//       } catch (e) {
//         zlog(data: "Auto save error");
//       }
//     }
//     return null;
//   }
//
//   void createNewDefaultAnimationItem() {
//     List<AnimationItemModel> defaultItems = state.defaultAnimationItems;
//     defaultItems.add(_generateDummyAnimationItem());
//     zlog(data: 'Default animation index ${defaultItems.length - 1}');
//     state = state.copyWith(
//       defaultAnimationItems: defaultItems,
//       defaultAnimationItemIndex: defaultItems.length - 1,
//       selectedScene: defaultItems.last,
//     );
//   }
//
//   void copyCurrentDefaultScene() {
//     AnimationItemModel? selectedScene = state.selectedScene;
//     if (selectedScene != null) {
//       List<AnimationItemModel> defaultItems = state.defaultAnimationItems;
//
//       AnimationItemModel item =
//           _generateDummyAnimationItem(items: selectedScene.components);
//       int index = defaultItems.indexWhere((t) => t.id == selectedScene.id);
//       if (index == -1) {
//         index = 0;
//       } else {
//         index += 1;
//       }
//
//       defaultItems.insert(index, item);
//
//       zlog(data: 'Default animation index ${defaultItems.length - 1}');
//       state = state.copyWith(
//         defaultAnimationItems: defaultItems,
//         defaultAnimationItemIndex: index,
//         selectedScene: defaultItems[index],
//       );
//     }
//   }
//
//   AnimationItemModel _generateDummyAnimationItem(
//       {List<FieldItemModel> items = const []}) {
//     return AnimationItemModel(
//       fieldColor: BoardConstant.field_color,
//       id: RandomGenerator.generateId(),
//       userId: _getUserId(),
//       components: items,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//       fieldSize:
//           ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero(),
//     );
//   }
//
//   void deleteDefaultAnimation() async {
//     int index = state.defaultAnimationItemIndex;
//     List<AnimationItemModel> defaultItems = state.defaultAnimationItems;
//     AnimationItemModel deletedItem = defaultItems.removeAt(index);
//
//     // BotToast.showLoading();
//     showZLoader();
//     try {
//       SaveDefaultAnimationParam defaultAnimationParam =
//           SaveDefaultAnimationParam(
//         animationItems: defaultItems,
//         userId: _getUserId(),
//       );
//
//       defaultItems = await _saveDefaultAnimationUseCase.call(
//         defaultAnimationParam,
//       );
//       index = index >= defaultItems.length ? defaultItems.length - 1 : index;
//       if (defaultItems.isEmpty) {
//         defaultItems.add(_generateDummyAnimationItem());
//         index = 0;
//       }
//
//       _deleteHistoryUseCase.call(deletedItem.id);
//
//       state = state.copyWith(
//         defaultAnimationItems: defaultItems,
//         defaultAnimationItemIndex: index,
//         selectedScene: defaultItems[index],
//       );
//       ref.read(boardProvider.notifier).clearItems();
//     } catch (e) {}
//     BotToast.cleanAll();
//   }
//
//   void performUndoOperation() async {
//     AnimationItemModel? selectedScene = state.selectedScene;
//     // AnimationModel? selectedAnimationModel = state.selectedAnimationModel;
//     try {
//       HistoryModel? history = await _getHistoryUseCase.call(selectedScene!.id);
//       zlog(
//         data:
//             "Last animation offsets ${history?.history.map((e) => e.components.map((c) => c.offset))}",
//       );
//       if (history == null) return;
//       List<AnimationItemModel> historyList = history.history;
//       historyList.removeLast();
//       AnimationItemModel? lastAnimation = historyList.lastOrNull;
//       history.history = historyList;
//
//       _saveHistoryUseCase.call(history);
//
//       state = state.copyWith(
//         selectedScene: lastAnimation,
//         isPerformingUndo: true,
//       );
//     } catch (e) {}
//
//     zlog(data: "Undo operation called ${selectedScene?.id}");
//   }
//
//   void toggleUndo({required bool undo}) {
//     state = state.copyWith(isPerformingUndo: undo);
//   }
//
//   String _getUserId() {
//     String? userId = ref.read(authProvider).userId;
//     if (userId == null) {
//       throw Exception("User Id Not Found");
//     }
//     return userId;
//   }
//
//   void _saveToHistory({required AnimationItemModel scene}) async {
//     HistoryModel? historyModel = await _getHistoryUseCase.call(scene.id);
//     historyModel ??= HistoryModel(id: scene.id, history: []);
//     historyModel.history.add(scene);
//     _saveHistoryUseCase.call(historyModel);
//   }
//
//   void saveHistory({AnimationItemModel? scene}) {
//     if (scene != null) {
//       _saveToHistory(scene: scene);
//     }
//   }
//
//   Color getFieldColor() {
//     AnimationModel? selectedAnimation = state.selectedAnimationModel;
//     AnimationItemModel? selectedScene = state.selectedScene;
//     if (selectedAnimation != null) {
//       return selectedAnimation.fieldColor;
//     } else if (selectedScene != null) {
//       return selectedScene.fieldColor;
//     } else {
//       return BoardConstant.field_color;
//     }
//   }
//
//   void updateBoardColor(Color c) {
//     AnimationModel? selectedAnimation = state.selectedAnimationModel;
//     AnimationItemModel? selectedScene = state.selectedScene;
//     selectedAnimation?.fieldColor = c;
//     selectedScene?.fieldColor = c;
//     state = state.copyWith(
//       selectedScene: selectedScene,
//       selectedAnimationModel: selectedAnimation,
//     );
//   }
//
//   /// Admin area
//
//   void activateDefaultAnimation({required AnimationModel animationModel}) {
//     state = state.copyWith(
//       selectedAnimationModel: animationModel,
//       selectedScene: animationModel.animationScenes.firstOrNull,
//     );
//   }
//
//   void addNewSceneFromAdmin({
//     required AnimationModel selectedAnimation,
//     required AnimationItemModel selectedScene,
//   }) async {
//     selectedAnimation = state.selectedAnimationModel!;
//     AnimationItemModel newAnimationItemModel = selectedScene.clone(
//       addHistory: false,
//     );
//     newAnimationItemModel.id = RandomGenerator.generateId();
//     newAnimationItemModel.createdAt = DateTime.now();
//     newAnimationItemModel.updatedAt = DateTime.now();
//     selectedAnimation.animationScenes.add(newAnimationItemModel);
//
//     state = state.copyWith(
//       selectedAnimationModel: selectedAnimation,
//       selectedScene: selectedAnimation.animationScenes.last,
//     );
//     ref
//         .read(defaultAnimationControllerProvider.notifier)
//         .updateAnimationModel(animationToUpdate: selectedAnimation);
//     try {
//       _onAnimationSaveAdmin(
//         selectedAnimation: state.selectedAnimationModel!,
//         selectedScene: state.selectedScene!,
//         showLoading: false,
//       );
//     } catch (e) {}
//   }
//
//   _onAnimationSaveAdmin({
//     required AnimationModel selectedAnimation,
//     required AnimationItemModel selectedScene,
//     bool showLoading = true,
//     bool saveToDb = true,
//   }) async {
//     List<FieldItemModel> components =
//         ref.read(boardProvider.notifier).onAnimationSave();
//
//     selectedScene.components = components;
//     selectedScene.fieldSize =
//         ref.read(boardProvider.notifier).fetchFieldSize() ?? Vector2.zero();
//     int sceneIndex = selectedAnimation.animationScenes.indexWhere(
//       (a) => a.id == selectedScene.id,
//     );
//     if (sceneIndex != -1) {
//       selectedAnimation.animationScenes[sceneIndex] = selectedScene;
//
//       selectedAnimation = await _defaultAnimationRepository
//           .saveDefaultAnimation(selectedAnimation);
//
//       state = state.copyWith(
//         selectedAnimationModel: selectedAnimation,
//         selectedScene: selectedScene,
//       );
//     } else {
//       BotToast.showText(text: "No scene found!!");
//     }
//     return null;
//   }
//
//   triggerAutoSaveForAdmin() {
//     try {
//       _onAnimationSaveAdmin(
//         selectedAnimation: state.selectedAnimationModel!,
//         selectedScene: state.selectedScene!,
//       );
//     } catch (e) {}
//   }
//
//   void deleteAdminScene({required AnimationItemModel scene}) async {
//     AnimationModel? selectedAnimationModel = state.selectedAnimationModel;
//     if (selectedAnimationModel != null) {
//       selectedAnimationModel.animationScenes.removeWhere(
//         (t) => t.id == scene.id,
//       );
//
//       if (selectedAnimationModel.animationScenes.isEmpty) {
//         selectedAnimationModel.animationScenes.add(
//           AnimationItemModel(
//             fieldColor: BoardConstant.field_color,
//             id: RandomGenerator.generateId(),
//             components: [],
//             userId: _getUserId(),
//             createdAt: DateTime.now(),
//             updatedAt: DateTime.now(),
//             fieldSize: ref.read(boardProvider.notifier).fetchFieldSize() ??
//                 Vector2(0, 0),
//           ),
//         );
//       }
//       selectedAnimationModel = await _defaultAnimationRepository
//           .saveDefaultAnimation(selectedAnimationModel);
//
//       ref
//           .read(defaultAnimationControllerProvider.notifier)
//           .updateAnimationModel(animationToUpdate: selectedAnimationModel);
//
//       state = state.copyWith(
//         selectedAnimationModel: selectedAnimationModel,
//         selectedScene: selectedAnimationModel.animationScenes.lastOrNull,
//       );
//     } else {
//       zlog(data: "Coming here for no animation found");
//       BotToast.showText(text: "No animation found");
//     }
//   }
//
//   AnimationItemModel _updateSceneWithPlayer(
//       AnimationItemModel scene, PlayerModel newPlayerModel) {
//     bool sceneModified = false;
//     List<FieldItemModel> updatedComponents = scene.components.map((component) {
//       if (component is PlayerModel && component.id == newPlayerModel.id) {
//         if (component != newPlayerModel) {
//           // Only mark modified if it's actually different
//           sceneModified = true;
//           return newPlayerModel; // Replace with the new model
//         }
//       }
//       return component; // Keep existing component
//     }).toList();
//
//     if (sceneModified) {
//       // Create a new scene instance with updated components
//       return scene.copyWith(
//           components: updatedComponents, updatedAt: DateTime.now());
//     }
//     return scene; // Return original scene if no relevant player was updated or if newModel was identical
//   }
//
//   // Helper function to update scenes within an AnimationModel
//   AnimationModel _updateAnimationWithPlayer(
//       AnimationModel animation, PlayerModel newPlayerModel) {
//     bool animationModified = false;
//     List<AnimationItemModel> updatedScenes =
//         animation.animationScenes.map((scene) {
//       AnimationItemModel updatedScene =
//           _updateSceneWithPlayer(scene, newPlayerModel);
//       if (updatedScene != scene) {
//         // Check if the scene instance changed
//         animationModified = true;
//       }
//       return updatedScene;
//     }).toList();
//
//     if (animationModified) {
//       return animation.copyWith(
//           animationScenes: updatedScenes, updatedAt: DateTime.now());
//     }
//     return animation;
//   }
//
//   // Helper function to update animations within an AnimationCollectionModel
//   AnimationCollectionModel _updateCollectionWithPlayer(
//       AnimationCollectionModel collection, PlayerModel newPlayerModel) {
//     bool collectionModified = false;
//     List<AnimationModel> updatedAnimations =
//         collection.animations.map((animation) {
//       AnimationModel updatedAnimation =
//           _updateAnimationWithPlayer(animation, newPlayerModel);
//       if (updatedAnimation != animation) {
//         // Check if the animation instance changed
//         collectionModified = true;
//       }
//       return updatedAnimation;
//     }).toList();
//
//     if (collectionModified) {
//       return collection.copyWith(
//           animations: updatedAnimations, updatedAt: DateTime.now());
//     }
//     return collection;
//   }
//
//   // The main method to update the player model across various state parts
//   void updatePlayerModel({
//     required PlayerModel newModel,
//   }) {
//     // 1. Process List<AnimationCollectionModel>
//     List<AnimationCollectionModel> updatedCollectionModelList =
//         state.animationCollections.map((collection) {
//       return _updateCollectionWithPlayer(collection, newModel);
//     }).toList();
//
//     // 2. Process List<AnimationModel> (top-level animations)
//     List<AnimationModel> updatedAnimationList =
//         state.animations.map((animation) {
//       return _updateAnimationWithPlayer(animation, newModel);
//     }).toList();
//
//     // 3. Process List<AnimationItemModel> (default animations/scenes)
//     List<AnimationItemModel> updatedDefaultAnimationsList =
//         state.defaultAnimationItems.map((scene) {
//       return _updateSceneWithPlayer(scene, newModel);
//     }).toList();
//
//     // 4. Process selected items, ensuring they point to the updated instances from the lists if applicable
//     AnimationCollectionModel? finalSelectedCollection;
//     if (state.selectedAnimationCollectionModel != null) {
//       // Try to find the selected collection in the updated list first
//       finalSelectedCollection = updatedCollectionModelList.firstWhereOrNull(
//         (c) => c.id == state.selectedAnimationCollectionModel!.id,
//       );
//       // If not found in the list (e.g., it was a standalone object), or if found but was the original instance, process it directly
//       if (finalSelectedCollection == null ||
//           finalSelectedCollection == state.selectedAnimationCollectionModel) {
//         AnimationCollectionModel directlyProcessed =
//             _updateCollectionWithPlayer(
//                 state.selectedAnimationCollectionModel!, newModel);
//         // Prefer the list version if it exists and was updated, otherwise use the directly processed one if it changed.
//         if (finalSelectedCollection != null &&
//             finalSelectedCollection != directlyProcessed &&
//             directlyProcessed != state.selectedAnimationCollectionModel) {
//           // This case is tricky, implies the one in the list was not updated but direct processing did.
//           // Usually, if it's in the list, list's version is canonical.
//         }
//         finalSelectedCollection = (finalSelectedCollection != null &&
//                 finalSelectedCollection !=
//                     state.selectedAnimationCollectionModel)
//             ? finalSelectedCollection
//             : directlyProcessed;
//       }
//     }
//
//     AnimationModel? finalSelectedAnimation;
//     if (state.selectedAnimationModel != null) {
//       // Prefer finding in the selected collection's updated animations, then in the top-level updated animation list
//       finalSelectedAnimation =
//           finalSelectedCollection?.animations.firstWhereOrNull(
//                 (a) => a.id == state.selectedAnimationModel!.id,
//               ) ??
//               updatedAnimationList.firstWhereOrNull(
//                 (a) => a.id == state.selectedAnimationModel!.id,
//               );
//
//       if (finalSelectedAnimation == null ||
//           finalSelectedAnimation == state.selectedAnimationModel) {
//         AnimationModel directlyProcessed =
//             _updateAnimationWithPlayer(state.selectedAnimationModel!, newModel);
//         finalSelectedAnimation = (finalSelectedAnimation != null &&
//                 finalSelectedAnimation != state.selectedAnimationModel)
//             ? finalSelectedAnimation
//             : directlyProcessed;
//       }
//     }
//
//     AnimationItemModel? finalSelectedScene;
//     if (state.selectedScene != null) {
//       // Prefer finding in the selected animation's updated scenes, then in the updated default animations list
//       finalSelectedScene =
//           finalSelectedAnimation?.animationScenes.firstWhereOrNull(
//                 (s) => s.id == state.selectedScene!.id,
//               ) ??
//               updatedDefaultAnimationsList.firstWhereOrNull(
//                 (s) => s.id == state.selectedScene!.id,
//               );
//       if (finalSelectedScene == null ||
//           finalSelectedScene == state.selectedScene) {
//         AnimationItemModel directlyProcessed =
//             _updateSceneWithPlayer(state.selectedScene!, newModel);
//         finalSelectedScene = (finalSelectedScene != null &&
//                 finalSelectedScene != state.selectedScene)
//             ? finalSelectedScene
//             : directlyProcessed;
//       }
//     }
//
//     // Create the new state. This assumes your state object has a copyWith method or similar.
//     // Replace 'YourAppState' and its fields with your actual state class and properties.
//     state = state.copyWith(
//       animationCollections: updatedCollectionModelList,
//       animations: updatedAnimationList,
//       selectedAnimationCollectionModel: finalSelectedCollection,
//       selectedAnimationModel: finalSelectedAnimation,
//       selectedScene: finalSelectedScene,
//       defaultAnimationItems: updatedDefaultAnimationsList,
//     );
//   }
//
//   // void updatePlayerModel({required PlayerModel newModel}) {
//   //   List<AnimationCollectionModel> collectionModel = state.animationCollections;
//   //   List<AnimationModel> animationList = state.animations;
//   //   AnimationCollectionModel? selectedCollection =
//   //       state.selectedAnimationCollectionModel;
//   //   AnimationModel? selectedAnimation = state.selectedAnimationModel;
//   //   AnimationItemModel? selectedScene = state.selectedScene;
//   //   List<AnimationItemModel> defaultAnimations = state.defaultAnimationItems;
//   // }
//
//   void updateBoardBackground(BoardBackground newBackground) {
//     final selectedAnim = state.selectedAnimationModel;
//     final selectedScene = state.selectedScene;
//
//     if (selectedAnim != null && selectedScene != null) {
//       // --- Case 1: An animation with scenes is selected ---
//       // Update the main animation model
//       selectedAnim.boardBackground = newBackground;
//
//       // Ensure all child scenes also have the new background for consistency
//       for (var i = 0; i < selectedAnim.animationScenes.length; i++) {
//         selectedAnim.animationScenes[i].boardBackground = newBackground;
//       }
//
//       // The existing autosave function will handle saving this change to the database.
//       updateDatabaseOnChange(saveToDb: true);
//     } else if (selectedScene != null) {
//       // --- Case 2: Only a default scene is selected ---
//       selectedScene.boardBackground = newBackground;
//
//       // The existing autosave function for default scenes will handle this.
//       updateDatabaseOnChange(saveToDb: true);
//     }
//
//     // Finally, update the UI provider so the GameField redraws itself.
//     ref.read(boardProvider.notifier).updateBoardBackground(newBackground);
//   }
// }

import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flame/components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  //   List<AnimationCollectionModel> collections = state.animationCollections;
  //
  //   try {
  //     collections = await _getAllAnimationCollectionUseCase.call(_getUserId());
  //
  //     try {
  //       int index = collections.indexWhere(
  //         (t) =>
  //             t.id.toLowerCase() ==
  //             DefaultAnimationConstants.default_animation_collection_id,
  //       );
  //
  //       if (index == -1) {
  //         List<AnimationModel> default_animations =
  //             await _defaultAnimationRepository.getAllDefaultAnimations();
  //         AnimationCollectionModel animationCollectionModel =
  //             AnimationCollectionModel(
  //           id: DefaultAnimationConstants.default_animation_collection_id,
  //           name: "Other",
  //           animations: default_animations,
  //           userId: ref.read(authProvider).userId ?? "",
  //           createdAt: DateTime.now(),
  //           updatedAt: DateTime.now(),
  //         );
  //
  //         collections.add(animationCollectionModel);
  //       }
  //     } catch (e) {}
  //
  //     // AnimationCollectionModel? selectedAnimation =
  //     //     state.selectedAnimationCollectionModel ?? collections.firstOrNull;
  //     // state = state.copyWith(
  //     //   animationCollections: collections,
  //     //   isLoadingAnimationCollections: false,
  //     // );
  //     //
  //     // zlog(data: "All collection ${collections}");
  //     //
  //     // selectAnimationCollection(selectedAnimation);
  //
  //     // --- ADDED SORTING FOR COLLECTIONS ---
  //     // This ensures the collection dropdown is also in order.
  //     collections.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  //
  //     AnimationCollectionModel? selectedCollection =
  //         state.selectedAnimationCollectionModel;
  //
  //     // Ensure the selected collection is still valid
  //     if (selectedCollection != null) {
  //       if (!collections.any((c) => c.id == selectedCollection!.id)) {
  //         selectedCollection = collections.firstOrNull;
  //       }
  //     } else {
  //       selectedCollection = collections.firstOrNull;
  //     }
  //
  //     state = state.copyWith(
  //       animationCollections: collections,
  //       isLoadingAnimationCollections: false,
  //     );
  //
  //     zlog(data: "All collection ${collections}");
  //
  //     // This will now correctly sort the animations within the selected collection
  //     selectAnimationCollection(selectedCollection);
  //   } catch (e) {
  //     zlog(data: "Animation collection fetching issue ${e}");
  //   }
  // }

  Future<void> getAllCollections() async {
    state = state.copyWith(isLoadingAnimationCollections: true);

    try {
      // Step 1: Fetch both user collections and default collections concurrently.
      final results = await Future.wait([
        _getAllAnimationCollectionUseCase
            .call(_getUserId()), // User's personal collections
        _defaultAnimationRepository
            .getAllDefaultAnimationCollections(), // Admin-created collections
        _defaultAnimationRepository
            .getAllDefaultAnimations(), // All individual default animations
      ]);

      final userCollections = results[0] as List<AnimationCollectionModel>;
      final defaultCollections = results[1] as List<AnimationCollectionModel>;
      final allDefaultAnimations = results[2] as List<AnimationModel>;

      // Step 2: Populate the default collections with their animations
      for (var collection in defaultCollections) {
        final animationsForThisCollection = allDefaultAnimations
            .where((anim) => anim.collectionId == collection.id)
            .toList();
        animationsForThisCollection
            .sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        collection.animations = animationsForThisCollection;
      }

      // Step 3: Merge the two lists
      final combinedCollections = [...userCollections, ...defaultCollections];

      // Step 4: Sort the final merged list of collections
      combinedCollections.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      // Step 5: Update the state with the complete list
      AnimationCollectionModel? selectedCollection =
          state.selectedAnimationCollectionModel;
      if (selectedCollection != null) {
        if (!combinedCollections.any((c) => c.id == selectedCollection!.id)) {
          selectedCollection = combinedCollections.firstOrNull;
        }
      } else {
        selectedCollection = combinedCollections.firstOrNull;
      }

      state = state.copyWith(
        animationCollections: combinedCollections,
        isLoadingAnimationCollections: false,
      );

      // This will correctly select the first collection and populate its animations
      selectAnimationCollection(selectedCollection);
    } catch (e) {
      zlog(data: "Animation collection fetching issue: $e");
      state = state.copyWith(isLoadingAnimationCollections: false);
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
    newAnimationItemModel.index = selectedAnimation.animationScenes.length;
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
      zlog(data: "Animation item fetch issue");
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
      defaultAnimations[index] = changeModel;
      zlog(
          data:
              "Default animation model List ${changeModel.components} - ${changeModel.boardBackground}");
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

  Future<AnimationItemModel?> updateDatabaseOnChange({
    required bool saveToDb,
  }) async {
    if (saveToDb == false) {
      AnimationItemModel? changeModel =
          state.selectedScene ?? AnimationItemModel.createEmptyAnimationItem();
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
          saveToDb: saveToDb,
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
    AnimationItemModel? selectedScene = state.selectedScene;
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
      await _deleteAnimationCollectionUseCase.call(collectionToDelete.id);

      // Create a new list without the deleted collection
      final currentCollections = state.animationCollections;
      currentCollections.removeWhere((c) => c.id == collectionToDelete.id);

      // If the deleted collection was the selected one, select the first available collection
      if (state.selectedAnimationCollectionModel?.id == collectionToDelete.id) {
        selectAnimationCollection(currentCollections.firstOrNull);
      } else {
        // Otherwise, just update the list but keep the current selection
        state = state.copyWith(animationCollections: currentCollections);
      }
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
}
