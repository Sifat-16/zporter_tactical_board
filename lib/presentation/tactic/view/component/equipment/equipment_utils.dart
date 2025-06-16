import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';

class EquipmentUtils {
  static final List<EquipmentModel> _equipments = [
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "BALL",
      imagePath: "ball.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "REFEREE-JERSEY",
      imagePath: "referee-jersey.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "HALF-CIRCLE",
      imagePath: "half-circle.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "GOAL-POST",
      imagePath: "goal-post.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "CONE",
      imagePath: "cone.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "TRAFFIC-CONE",
      imagePath: "traffic-cone.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "BULLSEYE",
      imagePath: "bullseye.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "CIRCLE",
      imagePath: "circle.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "POLE-DANCE",
      imagePath: "pole-dance.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "DUMMY",
      imagePath: "dummy.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "LADDER",
      imagePath: "ladder.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "BLOCK",
      imagePath: "block.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "DUMBBELL",
      imagePath: "dumbbell.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "DIGITAL-CLOCK",
      imagePath: "digital-clock.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "SCOREBOARD",
      imagePath: "scoreboard.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "STOPWATCH",
      imagePath: "stopwatch.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "SMARTPHONE",
      imagePath: "smartphone.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "WHISTLE",
      imagePath: "whistle.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "WORLD-CUP",
      imagePath: "world-cup.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "MEDAL",
      imagePath: "medal.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "PODIUM",
      imagePath: "podium.png",
    ),
  ];

  static List<EquipmentModel> generateEquipments() {
    return _equipments
        .map(
          (e) => e.copyWith(color: ColorManager.white, size: Vector2(32, 32)),
        )
        .toList();
  }
}
