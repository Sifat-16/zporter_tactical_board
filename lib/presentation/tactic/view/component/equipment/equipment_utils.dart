import 'package:mongo_dart/mongo_dart.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';

class EquipmentUtils {
  static final List<EquipmentModel> _equipments = [
    EquipmentModel(id: ObjectId(), name: "BALL", imagePath: "ball.png"),
    EquipmentModel(
      id: ObjectId(),
      name: "REFEREE-JERSEY",
      imagePath: "referee-jersey.png",
    ),
    EquipmentModel(
      id: ObjectId(),
      name: "HALF-CIRCLE",
      imagePath: "half-circle.png",
    ),

    EquipmentModel(
      id: ObjectId(),
      name: "GOAL-POST",
      imagePath: "goal-post.png",
    ),

    EquipmentModel(id: ObjectId(), name: "CONE", imagePath: "cone.png"),

    EquipmentModel(
      id: ObjectId(),
      name: "TRAFFIC-CONE",
      imagePath: "traffic-cone.png",
    ),

    EquipmentModel(id: ObjectId(), name: "BULLSEYE", imagePath: "bullseye.png"),

    EquipmentModel(id: ObjectId(), name: "CIRCLE", imagePath: "circle.png"),

    EquipmentModel(
      id: ObjectId(),
      name: "POLE-DANCE",
      imagePath: "pole-dance.png",
    ),

    EquipmentModel(id: ObjectId(), name: "DUMMY", imagePath: "dummy.png"),

    EquipmentModel(id: ObjectId(), name: "LADDER", imagePath: "ladder.png"),

    EquipmentModel(id: ObjectId(), name: "BLOCK", imagePath: "block.png"),

    EquipmentModel(id: ObjectId(), name: "DUMBBELL", imagePath: "dumbbell.png"),

    EquipmentModel(
      id: ObjectId(),
      name: "DIGITAL-CLOCK",
      imagePath: "digital-clock.png",
    ),

    EquipmentModel(
      id: ObjectId(),
      name: "SCOREBOARD",
      imagePath: "scoreboard.png",
    ),

    EquipmentModel(
      id: ObjectId(),
      name: "STOPWATCH",
      imagePath: "stopwatch.png",
    ),

    EquipmentModel(
      id: ObjectId(),
      name: "SMARTPHONE",
      imagePath: "smartphone.png",
    ),

    EquipmentModel(id: ObjectId(), name: "WHISTLE", imagePath: "whistle.png"),

    EquipmentModel(
      id: ObjectId(),
      name: "WORLD-CUP",
      imagePath: "world-cup.png",
    ),

    EquipmentModel(id: ObjectId(), name: "MEDAL", imagePath: "medal.png"),

    EquipmentModel(id: ObjectId(), name: "PODIUM", imagePath: "podium.png"),
  ];

  static List<EquipmentModel> generateEquipments() {
    return _equipments;
  }
}
