import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';

class AnimationCollectionDefault {
  String id;
  String collectionName;
  AnimationCollectionDefault({required this.id, required this.collectionName});

  @override
  String toString() {
    return 'AnimationCollectionDefault(id: $id, collectionName: $collectionName)';
  }
}

class AnimationCollectionDefaultUtils {
  static List<AnimationCollectionDefault> _list = [];

  AnimationCollectionDefaultUtils() {
    _initializeList();
  }

  static void _initializeList() {
    _list = [
      AnimationCollectionDefault(
          id: "ballcontrol_default_animation_id",
          collectionName: "Ballcontrol"),
      AnimationCollectionDefault(
          id: "build_up_default_animation_id", collectionName: "Build up"),
      AnimationCollectionDefault(
          id: "activation_default_animation_id", collectionName: "Activation"),
      AnimationCollectionDefault(
          id: "set_pieces_default_animation_id", collectionName: "Set pieces"),
      AnimationCollectionDefault(
          id: "passing_default_animation_id", collectionName: "Passing"),
      AnimationCollectionDefault(
          id: "possession_default_animation_id", collectionName: "Possession"),
      AnimationCollectionDefault(
          id: "strength_default_animation_id", collectionName: "Strength"),
      AnimationCollectionDefault(
          id: "games_default_animation_id", collectionName: "Games"),
      AnimationCollectionDefault(
          id: "dribble_default_animation_id", collectionName: "Dribble"),
      AnimationCollectionDefault(
          id: "attack_default_animation_id", collectionName: "Attack"),
      AnimationCollectionDefault(
          id: "speed_default_animation_id", collectionName: "Speed"),
      AnimationCollectionDefault(
          id: "perception_default_animation_id", collectionName: "Perception"),
      AnimationCollectionDefault(
          id: "shooting_default_animation_id", collectionName: "Shooting"),
      AnimationCollectionDefault(
          id: "finish_default_animation_id", collectionName: "Finish"),
      AnimationCollectionDefault(
          id: "power_default_animation_id", collectionName: "Power"),
      AnimationCollectionDefault(
          id: "aerobt_default_animation_id",
          collectionName: "Aerobt"), // "Aerobt" might be "Aerobic"
      AnimationCollectionDefault(
          id: "1v1_default_animation_id", collectionName: "1v1"),
      AnimationCollectionDefault(
          id: "heading_default_animation_id", collectionName: "Heading"),
      AnimationCollectionDefault(
          id: "turnovers_default_animation_id", collectionName: "Turnovers"),
      AnimationCollectionDefault(
          id: "anaerobt_default_animation_id",
          collectionName: "Anaerobt"), // "Anaerobt" might be "Anaerobic"
      AnimationCollectionDefault(
          id: "rondo_default_animation_id", collectionName: "Rondo"),
      AnimationCollectionDefault(
          id: "defence_default_animation_id", collectionName: "Defence"),
      AnimationCollectionDefault(
          id: "press_default_animation_id", collectionName: "Press"),
      AnimationCollectionDefault(
          id: "match_default_animation_id", collectionName: "Match"),
      AnimationCollectionDefault(
          id: "rehab_default_animation_id", collectionName: "Rehab"),
      AnimationCollectionDefault(
          id: "2v1_plus_default_animation_id",
          collectionName: "2v1+"), // ID for "2v1+"
    ];
  }

  static List<AnimationCollectionDefault> get animationCollections => _list;

  static List<AnimationCollectionModel> addDefaultCollections(
      {required List<AnimationCollectionModel> collections,
      required String userId}) {
    if (animationCollections.isEmpty) {
      _initializeList();
    }
    for (var a in animationCollections) {
      int index = collections.indexWhere((c) => c.id == a.id);
      if (index == -1) {
        collections.add(AnimationCollectionModel(
            id: a.id,
            name: a.collectionName,
            animations: [],
            userId: userId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now()));
      }
    }
    return collections;
  }
}
