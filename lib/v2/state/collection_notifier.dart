import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/v2/data/repositories/animation_repository_v2.dart';
import 'package:zporter_tactical_board/v2/models/animation_collection.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';

/// Immutable state for the collection/animation/scene browser.
class CollectionState {
  final List<AnimationCollectionModelV2> collections;
  final AnimationCollectionModelV2? selectedCollection;
  final AnimationModelV2? selectedAnimation;
  final int selectedSceneIndex;
  final bool isLoading;
  final String? error;

  const CollectionState({
    this.collections = const [],
    this.selectedCollection,
    this.selectedAnimation,
    this.selectedSceneIndex = 0,
    this.isLoading = false,
    this.error,
  });

  /// The currently selected scene, derived from the selected animation.
  SceneModelV2? get selectedScene {
    final anim = selectedAnimation;
    if (anim == null) return null;
    if (selectedSceneIndex < 0 ||
        selectedSceneIndex >= anim.animationScenes.length) {
      return null;
    }
    return anim.animationScenes[selectedSceneIndex];
  }

  CollectionState copyWith({
    List<AnimationCollectionModelV2>? collections,
    Object? selectedCollection = _sentinel,
    Object? selectedAnimation = _sentinel,
    int? selectedSceneIndex,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return CollectionState(
      collections: collections ?? this.collections,
      selectedCollection: selectedCollection == _sentinel
          ? this.selectedCollection
          : selectedCollection as AnimationCollectionModelV2?,
      selectedAnimation: selectedAnimation == _sentinel
          ? this.selectedAnimation
          : selectedAnimation as AnimationModelV2?,
      selectedSceneIndex: selectedSceneIndex ?? this.selectedSceneIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CollectionState) return false;
    return collections == other.collections &&
        selectedCollection == other.selectedCollection &&
        selectedAnimation == other.selectedAnimation &&
        selectedSceneIndex == other.selectedSceneIndex &&
        isLoading == other.isLoading &&
        error == other.error;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(collections),
        selectedCollection,
        selectedAnimation,
        selectedSceneIndex,
        isLoading,
        error,
      );
}

const Object _sentinel = Object();

/// Manages animation collection data and bridges persistence to the board.
///
/// When a scene is selected, it pushes the scene to [BoardNotifier.loadScene()].
/// This is the V2 equivalent of V1's `AnimationController` (Riverpod notifier),
/// focused on data management without UI concerns.
class CollectionNotifier extends StateNotifier<CollectionState> {
  final AnimationRepositoryV2 _repository;
  final BoardNotifier _boardNotifier;

  CollectionNotifier({
    required AnimationRepositoryV2 repository,
    required BoardNotifier boardNotifier,
  })  : _repository = repository,
        _boardNotifier = boardNotifier,
        super(const CollectionState());

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  /// Load all collections for a user from the repository.
  Future<void> loadCollections(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final collections = await _repository.getAllCollections(userId);

      // Sort by orderIndex
      final sorted = List<AnimationCollectionModelV2>.of(collections)
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      state = state.copyWith(
        collections: sorted,
        isLoading: false,
      );
    } catch (e) {
      developer.log(
        'Error loading collections for userId=$userId',
        name: 'CollectionNotifier',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load collections',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  /// Select a collection. Clears animation and scene selection.
  void selectCollection(AnimationCollectionModelV2? collection) {
    state = state.copyWith(
      selectedCollection: collection,
      selectedAnimation: null,
      selectedSceneIndex: 0,
    );
  }

  /// Select an animation within the currently selected collection.
  /// Automatically selects the first scene and pushes it to the board.
  void selectAnimation(AnimationModelV2? animation) {
    state = state.copyWith(
      selectedAnimation: animation,
      selectedSceneIndex: 0,
    );
    _pushSelectedSceneToBoard();
  }

  /// Select a scene by index within the current animation.
  /// Pushes the selected scene to the board.
  void selectScene(int index) {
    final anim = state.selectedAnimation;
    if (anim == null) return;
    if (index < 0 || index >= anim.animationScenes.length) return;

    state = state.copyWith(selectedSceneIndex: index);
    _pushSelectedSceneToBoard();
  }

  // ---------------------------------------------------------------------------
  // Collection CRUD
  // ---------------------------------------------------------------------------

  /// Create a new empty collection.
  Future<void> createCollection(String name, String userId) async {
    try {
      final now = DateTime.now();
      final collection = AnimationCollectionModelV2(
        id: RandomGenerator.generateId(),
        name: name,
        userId: userId,
        animations: const [],
        createdAt: now,
        updatedAt: now,
        orderIndex: state.collections.length,
      );

      final saved = await _repository.saveCollection(collection);

      state = state.copyWith(
        collections: [...state.collections, saved],
      );
    } catch (e) {
      developer.log(
        'Error creating collection',
        name: 'CollectionNotifier',
        error: e,
      );
      state = state.copyWith(error: 'Failed to create collection');
    }
  }

  /// Delete a collection by ID.
  Future<void> deleteCollection(String collectionId) async {
    try {
      await _repository.deleteCollection(collectionId);

      final updated = state.collections
          .where((c) => c.id != collectionId)
          .toList();

      // Clear selection if deleted collection was selected
      final clearSelection =
          state.selectedCollection?.id == collectionId;

      state = state.copyWith(
        collections: updated,
        selectedCollection: clearSelection ? null : state.selectedCollection,
        selectedAnimation: clearSelection ? null : state.selectedAnimation,
        selectedSceneIndex: clearSelection ? 0 : state.selectedSceneIndex,
      );
    } catch (e) {
      developer.log(
        'Error deleting collection id=$collectionId',
        name: 'CollectionNotifier',
        error: e,
      );
      state = state.copyWith(error: 'Failed to delete collection');
    }
  }

  // ---------------------------------------------------------------------------
  // Animation CRUD
  // ---------------------------------------------------------------------------

  /// Create a new animation within the selected collection.
  Future<void> createAnimation(String name, String userId) async {
    final collection = state.selectedCollection;
    if (collection == null) return;

    try {
      final now = DateTime.now();
      final animation = AnimationModelV2(
        id: RandomGenerator.generateId(),
        name: name,
        userId: userId,
        collectionId: collection.id,
        fieldColor: const Color(0xFF9E9E9E),
        animationScenes: [
          SceneModelV2.empty(
            id: RandomGenerator.generateId(),
            userId: userId,
          ),
        ],
        createdAt: now,
        updatedAt: now,
        orderIndex: collection.animations.length,
      );

      final saved = await _repository.saveAnimation(
        animation,
        collection.id,
      );

      // Update the collection in our state
      _updateCollectionInState(collection.id, (c) {
        return c.copyWith(
          animations: [...c.animations, saved],
          updatedAt: DateTime.now(),
        );
      });
    } catch (e) {
      developer.log(
        'Error creating animation',
        name: 'CollectionNotifier',
        error: e,
      );
      state = state.copyWith(error: 'Failed to create animation');
    }
  }

  /// Delete an animation from the selected collection.
  Future<void> deleteAnimation(String animationId) async {
    final collection = state.selectedCollection;
    if (collection == null) return;

    try {
      await _repository.deleteAnimation(animationId, collection.id);

      final clearSelection =
          state.selectedAnimation?.id == animationId;

      _updateCollectionInState(collection.id, (c) {
        return c.copyWith(
          animations:
              c.animations.where((a) => a.id != animationId).toList(),
          updatedAt: DateTime.now(),
        );
      });

      if (clearSelection) {
        state = state.copyWith(
          selectedAnimation: null,
          selectedSceneIndex: 0,
        );
      }
    } catch (e) {
      developer.log(
        'Error deleting animation id=$animationId',
        name: 'CollectionNotifier',
        error: e,
      );
      state = state.copyWith(error: 'Failed to delete animation');
    }
  }

  // ---------------------------------------------------------------------------
  // Scene CRUD
  // ---------------------------------------------------------------------------

  /// Save (update) the current scene. Called when the user edits the board.
  Future<void> saveCurrentScene(SceneModelV2 scene) async {
    final collection = state.selectedCollection;
    final animation = state.selectedAnimation;
    if (collection == null || animation == null) return;

    try {
      final saved = await _repository.saveScene(
        scene,
        animation.id,
        collection.id,
      );

      // Update animation scenes in state
      _updateAnimationInState(collection.id, animation.id, (a) {
        final scenes = List<SceneModelV2>.of(a.animationScenes);
        final idx = scenes.indexWhere((s) => s.id == saved.id);
        if (idx >= 0) {
          scenes[idx] = saved;
        } else {
          scenes.add(saved);
        }
        return a.copyWith(
          animationScenes: scenes,
          updatedAt: DateTime.now(),
        );
      });
    } catch (e) {
      developer.log(
        'Error saving scene',
        name: 'CollectionNotifier',
        error: e,
      );
      state = state.copyWith(error: 'Failed to save scene');
    }
  }

  /// Add a new scene to the current animation.
  Future<void> addScene(SceneModelV2 scene) async {
    final collection = state.selectedCollection;
    final animation = state.selectedAnimation;
    if (collection == null || animation == null) return;

    try {
      final saved = await _repository.saveScene(
        scene,
        animation.id,
        collection.id,
      );

      _updateAnimationInState(collection.id, animation.id, (a) {
        return a.copyWith(
          animationScenes: [...a.animationScenes, saved],
          updatedAt: DateTime.now(),
        );
      });
    } catch (e) {
      developer.log(
        'Error adding scene',
        name: 'CollectionNotifier',
        error: e,
      );
      state = state.copyWith(error: 'Failed to add scene');
    }
  }

  /// Delete a scene from the current animation.
  Future<void> deleteScene(String sceneId) async {
    final collection = state.selectedCollection;
    final animation = state.selectedAnimation;
    if (collection == null || animation == null) return;

    try {
      await _repository.deleteScene(sceneId, animation.id, collection.id);

      _updateAnimationInState(collection.id, animation.id, (a) {
        return a.copyWith(
          animationScenes:
              a.animationScenes.where((s) => s.id != sceneId).toList(),
          updatedAt: DateTime.now(),
        );
      });

      // Adjust scene index if needed
      final anim = state.selectedAnimation;
      if (anim != null &&
          state.selectedSceneIndex >= anim.animationScenes.length) {
        state = state.copyWith(
          selectedSceneIndex:
              (anim.animationScenes.length - 1).clamp(0, anim.animationScenes.length),
        );
      }
    } catch (e) {
      developer.log(
        'Error deleting scene id=$sceneId',
        name: 'CollectionNotifier',
        error: e,
      );
      state = state.copyWith(error: 'Failed to delete scene');
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _pushSelectedSceneToBoard() {
    final scene = state.selectedScene;
    if (scene != null) {
      _boardNotifier.loadScene(scene);
    }
  }

  void _updateCollectionInState(
    String collectionId,
    AnimationCollectionModelV2 Function(AnimationCollectionModelV2) updater,
  ) {
    final collections = state.collections.map((c) {
      if (c.id == collectionId) return updater(c);
      return c;
    }).toList();

    final updatedSelected = state.selectedCollection?.id == collectionId
        ? collections.firstWhere((c) => c.id == collectionId)
        : state.selectedCollection;

    state = state.copyWith(
      collections: collections,
      selectedCollection: updatedSelected,
    );
  }

  void _updateAnimationInState(
    String collectionId,
    String animationId,
    AnimationModelV2 Function(AnimationModelV2) updater,
  ) {
    _updateCollectionInState(collectionId, (c) {
      final animations = c.animations.map((a) {
        if (a.id == animationId) return updater(a);
        return a;
      }).toList();
      return c.copyWith(animations: animations);
    });

    // Also update the selected animation if it matches
    if (state.selectedAnimation?.id == animationId) {
      final updatedCollection = state.selectedCollection;
      if (updatedCollection != null) {
        try {
          final updatedAnim = updatedCollection.animations
              .firstWhere((a) => a.id == animationId);
          state = state.copyWith(selectedAnimation: updatedAnim);
        } catch (_) {
          // Animation may have been removed
        }
      }
    }
  }
}
