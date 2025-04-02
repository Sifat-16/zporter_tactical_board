import 'package:flutter/foundation.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';

// Define a private sentinel object constant (can be outside the class)
const Object _sentinel = Object();

class AnimationState {
  AnimationCollectionModel?
  selectedAnimationCollectionModel; // Made final for immutability best practice
  List<AnimationCollectionModel> animationCollections;
  bool isLoadingAnimationCollections;
  List<AnimationModel> animations;
  AnimationModel? selectedAnimationModel;
  AnimationItemModel? selectedScene;
  bool showNewCollectionInput;
  bool showNewAnimationInput;
  bool showQuickSave;
  bool showAnimation;
  int defaultAnimationItemIndex;
  List<AnimationItemModel> defaultAnimationItems;

  // Constructor remains the same, prefer const if possible
  AnimationState({
    this.selectedAnimationCollectionModel,
    this.animationCollections = const [],
    this.isLoadingAnimationCollections = false,
    this.animations = const [],
    this.selectedAnimationModel,
    this.selectedScene,
    this.showNewCollectionInput = false,
    this.showAnimation = false,
    this.showNewAnimationInput = false,
    this.showQuickSave = false,
    this.defaultAnimationItemIndex = 0,
    this.defaultAnimationItems = const [],
  });

  AnimationState copyWith({
    // Parameter type changed to Object?, defaults to sentinel
    Object? selectedAnimationCollectionModel = _sentinel,
    List<AnimationCollectionModel>? animationCollections,
    bool? isLoadingAnimationCollections,
    List<AnimationModel>? animations,
    Object? selectedAnimationModel = _sentinel,
    Object? selectedScene = _sentinel,
    bool? showAnimation,
    bool? showNewCollectionInput,
    bool? showNewAnimationInput,
    bool? showQuickSave,
    int? defaultAnimationItemIndex,
    List<AnimationItemModel>? defaultAnimationItems,
  }) {
    return AnimationState(
      selectedAnimationCollectionModel:
          selectedAnimationCollectionModel == _sentinel
              ? this.selectedAnimationCollectionModel
              : selectedAnimationCollectionModel as AnimationCollectionModel?,
      animationCollections: animationCollections ?? this.animationCollections,
      isLoadingAnimationCollections:
          isLoadingAnimationCollections ?? this.isLoadingAnimationCollections,
      animations: animations ?? this.animations,
      selectedAnimationModel:
          selectedAnimationModel == _sentinel
              ? this.selectedAnimationModel
              : selectedAnimationModel as AnimationModel?,
      selectedScene:
          selectedScene == _sentinel
              ? this.selectedScene
              : selectedScene as AnimationItemModel?,
      showAnimation: showAnimation ?? this.showAnimation,
      showNewCollectionInput:
          showNewCollectionInput ?? this.showNewCollectionInput,
      showNewAnimationInput:
          showNewAnimationInput ?? this.showNewAnimationInput,
      showQuickSave: showQuickSave ?? this.showQuickSave,
      defaultAnimationItemIndex:
          defaultAnimationItemIndex ?? this.defaultAnimationItemIndex,
      defaultAnimationItems:
          defaultAnimationItems ?? this.defaultAnimationItems,
    );
  }

  // --- CORRECTED Equality and HashCode ---
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // Use listEquals for comparing lists
    return other is AnimationState &&
        runtimeType == other.runtimeType &&
        selectedAnimationCollectionModel ==
            other.selectedAnimationCollectionModel &&
        listEquals(
          animationCollections,
          other.animationCollections,
        ) && // Compare list contents
        isLoadingAnimationCollections == other.isLoadingAnimationCollections &&
        listEquals(animations, other.animations) && // Compare list contents
        selectedAnimationModel == other.selectedAnimationModel &&
        selectedScene == other.selectedScene;
  }

  @override
  int get hashCode {
    // Use Object.hash to combine hash codes of all fields checked in ==
    return Object.hash(
      selectedAnimationCollectionModel,
      Object.hashAll(animationCollections), // Hash list content
      isLoadingAnimationCollections,
      Object.hashAll(animations), // Hash list content
      selectedAnimationModel,
      selectedScene,
    );
  }
}
