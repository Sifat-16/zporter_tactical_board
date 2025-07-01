// import 'package:flame/components.dart';
// import 'package:zporter_tactical_board/app/generator/random_generator.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
//
// class LineUtils {
//   static final List<LineModelV2> _lines = [
//     LineModelV2(
//       id: RandomGenerator.generateId(),
//       start: Vector2.zero(),
//       end: Vector2.zero(),
//       fieldItemType: FieldItemType.LINE,
//       lineType: LineType.STRAIGHT_LINE,
//       color: ColorManager.black,
//       name: "STRAIGHT-LINE",
//       imagePath: "diagonal-line.png",
//     ),
//     LineModelV2(
//       id: RandomGenerator.generateId(),
//       start: Vector2.zero(),
//       end: Vector2.zero(),
//       fieldItemType: FieldItemType.LINE,
//       lineType: LineType.STRAIGHT_LINE_DASHED,
//       color: ColorManager.black,
//       name: "STRAIGHT-LINE-DASHED",
//       imagePath: "diagonal-line-dashed.png",
//     ),
//     LineModelV2(
//       id: RandomGenerator.generateId(),
//       start: Vector2.zero(),
//       end: Vector2.zero(),
//       fieldItemType: FieldItemType.LINE,
//       lineType: LineType.STRAIGHT_LINE_ZIGZAG,
//       color: ColorManager.black,
//       name: "STRAIGHT-LINE-ZIGZAG",
//       imagePath: "diagonal-line-zigzag.png",
//     ),
//     LineModelV2(
//       id: RandomGenerator.generateId(),
//       start: Vector2.zero(),
//       end: Vector2.zero(),
//       fieldItemType: FieldItemType.LINE,
//       lineType: LineType.STRAIGHT_LINE_ZIGZAG_ARROW,
//       color: ColorManager.black,
//       name: "STRAIGHT-LINE-ZIGZAG-ARROW",
//       imagePath: "diagonal-line-zigzag-arrow.png",
//     ),
//     LineModelV2(
//       id: RandomGenerator.generateId(),
//       start: Vector2.zero(),
//       end: Vector2.zero(),
//       fieldItemType: FieldItemType.LINE,
//       lineType: LineType.STRAIGHT_LINE_ARROW,
//       color: ColorManager.black,
//       name: "STRAIGHT-LINE-ARROW",
//       imagePath: "diagonal-line-arrow.png",
//     ),
//     LineModelV2(
//       id: RandomGenerator.generateId(),
//       start: Vector2.zero(),
//       end: Vector2.zero(),
//       fieldItemType: FieldItemType.LINE,
//       lineType: LineType.STRAIGHT_LINE_ARROW_DOUBLE,
//       color: ColorManager.black,
//       name: "STRAIGHT-LINE-ARROW-DOUBLE",
//       imagePath: "diagonal-line-arrow-double.png",
//     ),
//   ];
//   static List<LineModelV2> generateLines() {
//     return _lines;
//   }
//
//   static bool isPresentFreeDraw(AnimationItemModel scene) {
//     List<FieldItemModel> items = scene.components;
//     return items.indexWhere((t) {
//           if (t is FreeDrawModelV2) {
//             return true;
//           }
//           return false;
//         }) !=
//         -1;
//   }
// }
//
// // import 'package:flame/components.dart';
// // import 'package:zporter_tactical_board/app/generator/random_generator.dart';
// // import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// // import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// // import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// // import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
// // import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// //
// // // ---
// // // NOTE: This file has been updated to map semantic actions to EXISTING image assets.
// // // Some actions will share the same icon, differentiated by their text label in the UI.
// // // This is a compromise to work within the available asset library.
// // // ---
// //
// // class LineUtils {
// //   static final List<LineModelV2> _lines = [
// //     // --- Player Movements ---
// //     LineModelV2(
// //       id: RandomGenerator.generateId(),
// //       start: Vector2.zero(),
// //       end: Vector2.zero(),
// //       fieldItemType: FieldItemType.LINE,
// //       lineType: LineType.STRAIGHT_LINE_DASHED,
// //       color: ColorManager.black,
// //       name: "Walk", // Closest visual is the dashed line.
// //       imagePath: "diagonal-line-dashed.png",
// //     ),
// //     LineModelV2(
// //       id: RandomGenerator.generateId(),
// //       start: Vector2.zero(),
// //       end: Vector2.zero(),
// //       fieldItemType: FieldItemType.LINE,
// //       lineType: LineType.STRAIGHT_LINE_ARROW,
// //       color: ColorManager.black,
// //       name: "Jog", // Perfect match.
// //       imagePath: "diagonal-line-arrow.png",
// //     ),
// //     LineModelV2(
// //       id: RandomGenerator.generateId(),
// //       start: Vector2.zero(),
// //       end: Vector2.zero(),
// //       fieldItemType: FieldItemType.LINE,
// //       lineType: LineType.STRAIGHT_LINE_ARROW_DOUBLE,
// //       color: ColorManager.black,
// //       name: "Sprint", // Perfect match.
// //       imagePath: "diagonal-line-arrow-double.png",
// //     ),
// //     LineModelV2(
// //       id: RandomGenerator.generateId(),
// //       start: Vector2.zero(),
// //       end: Vector2.zero(),
// //       fieldItemType: FieldItemType.LINE,
// //       lineType: LineType
// //           .STRAIGHT_LINE_ARROW, // No curved asset, using arrow to show movement.
// //       color: ColorManager.black,
// //       name: "Jump",
// //       imagePath: "diagonal-line-arrow.png",
// //     ),
// //
// //     // --- Ball Movements ---
// //     LineModelV2(
// //       id: RandomGenerator.generateId(),
// //       start: Vector2.zero(),
// //       end: Vector2.zero(),
// //       fieldItemType: FieldItemType.LINE,
// //       lineType: LineType.STRAIGHT_LINE,
// //       color: ColorManager.black,
// //       name: "Pass", // Perfect match.
// //       imagePath: "diagonal-line.png",
// //     ),
// //     LineModelV2(
// //       id: RandomGenerator.generateId(),
// //       start: Vector2.zero(),
// //       end: Vector2.zero(),
// //       fieldItemType: FieldItemType.LINE,
// //       lineType: LineType.STRAIGHT_LINE, // No curved asset, using basic line.
// //       color: ColorManager.black,
// //       name: "Pass high",
// //       imagePath: "diagonal-line.png",
// //     ),
// //     LineModelV2(
// //       id: RandomGenerator.generateId(),
// //       start: Vector2.zero(),
// //       end: Vector2.zero(),
// //       fieldItemType: FieldItemType.LINE,
// //       lineType: LineType.STRAIGHT_LINE_ZIGZAG_ARROW,
// //       color: ColorManager.black,
// //       name: "Dribble", // Perfect match.
// //       imagePath: "diagonal-line-zigzag-arrow.png",
// //     ),
// //     LineModelV2(
// //       id: RandomGenerator.generateId(),
// //       start: Vector2.zero(),
// //       end: Vector2.zero(),
// //       fieldItemType: FieldItemType.LINE,
// //       lineType: LineType.STRAIGHT_LINE_ARROW,
// //       color: ColorManager.black,
// //       name: "Shoot", // Visually same as 'Jog', differentiated by name.
// //       imagePath: "diagonal-line-arrow.png",
// //     ),
// //   ];
// //
// //   static List<LineModelV2> generateLines() {
// //     // This function now returns the new, standardized list of lines.
// //     return _lines;
// //   }
// //
// //   static bool isPresentFreeDraw(AnimationItemModel scene) {
// //     List<FieldItemModel> items = scene.components;
// //     return items.indexWhere((t) {
// //           if (t is FreeDrawModelV2) {
// //             return true;
// //           }
// //           return false;
// //         }) !=
// //         -1;
// //   }
// // }

import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';

class LineUtils {
  static final List<LineModelV2> _lines = [
    // --- Player Movements ---
    LineModelV2(
        id: RandomGenerator.generateId(),
        start: Vector2.zero(),
        end: Vector2.zero(),
        lineType: LineType.WALK_ONE_WAY,
        name: "Walk",
        imagePath: "player-walk-oneway.png"),
    LineModelV2(
        id: RandomGenerator.generateId(),
        start: Vector2.zero(),
        end: Vector2.zero(),
        lineType: LineType.WALK_TWO_WAY,
        name: "Walk Return",
        imagePath: "player-walk-twoway.png"),

    LineModelV2(
        id: RandomGenerator.generateId(),
        start: Vector2.zero(),
        end: Vector2.zero(),
        lineType: LineType.JOG_ONE_WAY,
        name: "Jog",
        imagePath: "player-jog-oneway.png"),
    LineModelV2(
        id: RandomGenerator.generateId(),
        start: Vector2.zero(),
        end: Vector2.zero(),
        lineType: LineType.JOG_TWO_WAY,
        name: "Jog Return",
        imagePath: "player-jog-twoway.png"),

    LineModelV2(
        id: RandomGenerator.generateId(),
        start: Vector2.zero(),
        end: Vector2.zero(),
        lineType: LineType.SPRINT_ONE_WAY,
        name: "Sprint",
        imagePath: "player-sprint-oneway.png"),
    LineModelV2(
        id: RandomGenerator.generateId(),
        start: Vector2.zero(),
        end: Vector2.zero(),
        lineType: LineType.SPRINT_TWO_WAY,
        name: "Sprint Return",
        imagePath: "player-sprint-twoway.png"),

    LineModelV2(
        id: RandomGenerator.generateId(),
        start: Vector2.zero(),
        end: Vector2.zero(),
        lineType: LineType.JUMP,
        name: "Jump",
        imagePath: "player-jump.png"),

    // --- Ball Movements ---
    LineModelV2(
        id: RandomGenerator.generateId(),
        start: Vector2.zero(),
        end: Vector2.zero(),
        lineType: LineType.PASS,
        name: "Pass",
        imagePath: "ball-pass.png"),

    LineModelV2(
        id: RandomGenerator.generateId(),
        start: Vector2.zero(),
        end: Vector2.zero(),
        lineType: LineType.PASS_HIGH_CROSS,
        name: "Pass high/cross",
        imagePath: "ball-pass-high.png"),

    LineModelV2(
        id: RandomGenerator.generateId(),
        start: Vector2.zero(),
        end: Vector2.zero(),
        lineType: LineType.DRIBBLE,
        name: "Dribble",
        imagePath: "ball-dribble.png"),

    LineModelV2(
        id: RandomGenerator.generateId(),
        start: Vector2.zero(),
        end: Vector2.zero(),
        lineType: LineType.SHOOT,
        name: "Shoot",
        imagePath: "ball-shoot.png",
        thickness: 5.0),
  ];

  static List<LineModelV2> generateLines() {
    return _lines;
  }

  static bool isPresentFreeDraw(AnimationItemModel scene) {
    List<FieldItemModel> items = scene.components;
    return items.indexWhere((t) {
          if (t is FreeDrawModelV2) {
            return true;
          }
          return false;
        }) !=
        -1;
  }
}
