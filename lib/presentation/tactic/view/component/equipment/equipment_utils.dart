import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';

import 'ball_animation_settings_dialog.dart';

class EquipmentUtils {
  static final List<EquipmentModel> _equipments = [
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "BALL",
      imagePath: "ball.png",
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
        name: "REFEREE-JERSEY",
        imagePath: "referee-jersey.png",
        color: Color(0xffE5432D)),
    EquipmentModel(
        id: RandomGenerator.generateId(),
        name: "REFEREE-JERSEY",
        imagePath: "referee-jersey.png",
        color: Color(0xffE5B32D)),
    EquipmentModel(
        id: RandomGenerator.generateId(),
        name: "REFEREE-JERSEY",
        imagePath: "referee-jersey.png",
        color: Color(0xff4A4DDE)),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "REFEREE-JERSEY",
      imagePath: "referee-jersey.png",
    ),
    EquipmentModel(
        id: RandomGenerator.generateId(),
        name: "REFEREE-JERSEY",
        imagePath: "referee-jersey.png",
        color: Color(0xff5FDCA9)),
    EquipmentModel(
        id: RandomGenerator.generateId(),
        name: "REFEREE-JERSEY",
        imagePath: "referee-jersey.png",
        color: Color(0xffA75FDC)),
    EquipmentModel(
        id: RandomGenerator.generateId(),
        name: "CONE-FLAT",
        imagePath: "cone-flat.png",
        color: Color(0xffE5432D)),
    EquipmentModel(
        id: RandomGenerator.generateId(),
        name: "CONE-FLAT",
        imagePath: "cone-flat.png",
        color: Color(0xffE5B32D)),
    EquipmentModel(
        id: RandomGenerator.generateId(),
        name: "CONE-FLAT",
        imagePath: "cone-flat.png",
        color: Color(0xff4A4DDE)),
    EquipmentModel(
        id: RandomGenerator.generateId(),
        name: "CONE",
        imagePath: "cone.png",
        color: Color(0xffE5432D)),
    EquipmentModel(
        id: RandomGenerator.generateId(),
        name: "CONE",
        imagePath: "cone.png",
        color: Color(0xffE5B32D)),
    EquipmentModel(
        id: RandomGenerator.generateId(),
        name: "CONE",
        imagePath: "cone.png",
        color: Color(0xff4A4DDE)),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "CIRCLE",
      imagePath: "circle.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "LADDER",
      imagePath: "ladder.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "HURDLE",
      imagePath: "hurdle.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "MANNEQUIN",
      imagePath: "mannequin.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "POLE",
      imagePath: "pole.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "TENNIS-NET",
      imagePath: "tennis-net.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "IBOX2-JUMP",
      imagePath: "ibox2-jump.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "RESISTANCE-BANDS",
      imagePath: "resistance-bands.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "DUMBBELL",
      imagePath: "dumbbell.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "WHISTLE",
      imagePath: "whistle.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "FLAG",
      imagePath: "flag.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "SEAT",
      imagePath: "seat.png",
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
      name: "TACTICS",
      imagePath: "tactics.png",
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
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "TABLET",
      imagePath: "tablet.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "SMARTPHONE",
      imagePath: "smartphone.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "STOPWATCH",
      imagePath: "stopwatch.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "VIDEO-CAMERA",
      imagePath: "video-camera.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "CAMERA",
      imagePath: "camera.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "SPEAKER-GROUP",
      imagePath: "speaker-group.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "TAPE",
      imagePath: "tape.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "WEIGHT",
      imagePath: "weight.png",
    ),
    EquipmentModel(
      id: RandomGenerator.generateId(),
      name: "LIVE",
      imagePath: "live.png",
    ),
    EquipmentModel(
        id: RandomGenerator.generateId(),
        name: "GOAL-POST-DENSE",
        imagePath: "goal-post-dense.png",
        size: Vector2(192, 96)),
    EquipmentModel(
        id: RandomGenerator.generateId(),
        name: "GOAL-POST-DENSE-TOP",
        imagePath: "goal-post-top.png",
        size: Vector2(192, 96)),
  ];

  static List<EquipmentModel> generateEquipments() {
    return _equipments
        .map(
          (e) => e.copyWith(
              color: e.color ?? ColorManager.white,
              size: e.size ?? Vector2(32, 32)),
        )
        .toList();
  }

  static Future<EquipmentModel?> showBallAnimationSettingsDialog({
    required BuildContext context,
    required EquipmentModel ballModel,
  }) async {
    // This will show the dialog and wait for it to be closed.
    // The dialog will return either the updated EquipmentModel on "Save"
    // or null on "Cancel".
    final result = await showDialog<EquipmentModel>(
      context: context,
      barrierDismissible: false, // User must tap a button to close
      builder: (BuildContext dialogContext) {
        return BallAnimationSettingsDialog(
          initialBallModel: ballModel,
        );
      },
    );
    return result;
  }
}
