import 'package:flutter/foundation.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
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

  // Constructor remains the same, prefer const if possible
  AnimationState({
    this.selectedAnimationCollectionModel,
    this.animationCollections = const [],
    this.isLoadingAnimationCollections = false,
    this.animations = const [],
    this.selectedAnimationModel,
  });

  AnimationState copyWith({
    // Parameter type changed to Object?, defaults to sentinel
    Object? selectedAnimationCollectionModel = _sentinel,
    List<AnimationCollectionModel>? animationCollections,
    bool? isLoadingAnimationCollections,
    List<AnimationModel>? animations,
    Object? selectedAnimationModel = _sentinel,
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
        selectedAnimationModel == other.selectedAnimationModel;
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
    );
  }
}
