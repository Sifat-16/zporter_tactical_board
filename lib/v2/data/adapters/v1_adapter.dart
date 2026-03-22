import 'package:zporter_tactical_board/v2/models/animation_collection.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';

/// Converts V1 data (JSON maps produced by V1 models) to V2 immutable models.
///
/// V2 [fromJson] methods are already V1-compatible by design:
/// - Same JSON keys (`_id`, `offset` as `{dx,dy}`, `size` as `{x,y}`)
/// - Same color encoding (ARGB int)
/// - Same enum serialization (`.name`)
/// - Graceful defaults for missing fields
///
/// This adapter wraps those conversions with error handling, batch
/// operations, and validation — providing a single entry point for
/// all V1→V2 data migration paths (Firestore reads, Sembast migration,
/// clipboard paste, etc.).
class V1Adapter {
  const V1Adapter();

  // ===========================================================================
  // Board Elements
  // ===========================================================================

  /// Convert a single V1 FieldItemModel JSON to a V2 BoardElement.
  ///
  /// Returns null if the JSON is malformed or missing `fieldItemType`.
  BoardElement? boardElementFromV1(Map<String, dynamic> json) {
    try {
      return BoardElement.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Convert a list of V1 FieldItemModel JSONs to V2 BoardElements.
  ///
  /// Silently skips malformed entries (matches V1 error handling).
  List<BoardElement> boardElementsFromV1(List<dynamic> jsonList) {
    final elements = <BoardElement>[];
    for (final item in jsonList) {
      if (item is Map<String, dynamic>) {
        final element = boardElementFromV1(item);
        if (element != null) elements.add(element);
      }
    }
    return elements;
  }

  // ===========================================================================
  // Scenes
  // ===========================================================================

  /// Convert a single V1 AnimationItemModel JSON to a V2 SceneModelV2.
  ///
  /// Returns null if the JSON is fundamentally malformed.
  SceneModelV2? sceneFromV1(Map<String, dynamic> json) {
    try {
      return SceneModelV2.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Convert a list of V1 AnimationItemModel JSONs to V2 SceneModelV2s.
  ///
  /// Handles V1 migration: if any scene has null index, assigns
  /// list order as index (done inside AnimationModelV2.fromJson, but
  /// replicated here for standalone scene list conversion).
  List<SceneModelV2> scenesFromV1(List<dynamic> jsonList) {
    final scenes = <SceneModelV2>[];
    bool hasNullIndex = false;

    for (final item in jsonList) {
      if (item is Map<String, dynamic>) {
        final scene = sceneFromV1(item);
        if (scene != null) {
          if (item['index'] == null) hasNullIndex = true;
          scenes.add(scene);
        }
      }
    }

    // V1 migration: auto-assign indices if any are missing
    final orderedScenes = hasNullIndex
        ? scenes
            .asMap()
            .entries
            .map((e) => e.value.copyWith(index: e.key))
            .toList()
        : scenes;

    orderedScenes.sort((a, b) => a.index.compareTo(b.index));
    return orderedScenes;
  }

  // ===========================================================================
  // Animations
  // ===========================================================================

  /// Convert a V1 AnimationModel JSON to a V2 AnimationModelV2.
  ///
  /// Returns null if fundamentally malformed.
  AnimationModelV2? animationFromV1(Map<String, dynamic> json) {
    try {
      return AnimationModelV2.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Convert a list of V1 AnimationModel JSONs to V2 AnimationModelV2s.
  List<AnimationModelV2> animationsFromV1(List<dynamic> jsonList) {
    final animations = <AnimationModelV2>[];
    for (final item in jsonList) {
      if (item is Map<String, dynamic>) {
        final animation = animationFromV1(item);
        if (animation != null) animations.add(animation);
      }
    }
    return animations;
  }

  // ===========================================================================
  // Animation Collections
  // ===========================================================================

  /// Convert a V1 AnimationCollectionModel JSON to V2.
  AnimationCollectionModelV2? collectionFromV1(Map<String, dynamic> json) {
    try {
      return AnimationCollectionModelV2.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Convert a list of V1 AnimationCollectionModel JSONs to V2.
  List<AnimationCollectionModelV2> collectionsFromV1(List<dynamic> jsonList) {
    final collections = <AnimationCollectionModelV2>[];
    for (final item in jsonList) {
      if (item is Map<String, dynamic>) {
        final collection = collectionFromV1(item);
        if (collection != null) collections.add(collection);
      }
    }
    return collections;
  }

  // ===========================================================================
  // Validation
  // ===========================================================================

  /// Validate round-trip: V1 JSON → V2 model → toJson() → V2 model.
  ///
  /// Returns true if the model survives a round-trip without data loss.
  /// Useful for migration verification tests.
  bool validateBoardElementRoundTrip(Map<String, dynamic> v1Json) {
    try {
      final v2Model = BoardElement.fromJson(v1Json);
      final v2Json = v2Model.toJson();
      final roundTripped = BoardElement.fromJson(v2Json);
      return v2Model == roundTripped;
    } catch (_) {
      return false;
    }
  }

  /// Validate animation round-trip.
  bool validateAnimationRoundTrip(Map<String, dynamic> v1Json) {
    try {
      final v2Model = AnimationModelV2.fromJson(v1Json);
      final v2Json = v2Model.toJson();
      final roundTripped = AnimationModelV2.fromJson(v2Json);
      return v2Model == roundTripped;
    } catch (_) {
      return false;
    }
  }

  /// Validate scene round-trip.
  bool validateSceneRoundTrip(Map<String, dynamic> v1Json) {
    try {
      final v2Model = SceneModelV2.fromJson(v1Json);
      final v2Json = v2Model.toJson();
      final roundTripped = SceneModelV2.fromJson(v2Json);
      return v2Model == roundTripped;
    } catch (_) {
      return false;
    }
  }
}
