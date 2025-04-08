import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';

class LineUtils {
  static final List<LineModelV2> _lines = [
    LineModelV2(
      id: RandomGenerator.generateId(),
      start: Vector2.zero(),
      end: Vector2.zero(),
      fieldItemType: FieldItemType.LINE,
      lineType: LineType.STRAIGHT_LINE,
      color: ColorManager.black,
      name: "STRAIGHT-LINE",
      imagePath: "diagonal-line.png",
    ),

    LineModelV2(
      id: RandomGenerator.generateId(),
      start: Vector2.zero(),
      end: Vector2.zero(),
      fieldItemType: FieldItemType.LINE,
      lineType: LineType.STRAIGHT_LINE_DASHED,
      color: ColorManager.black,
      name: "STRAIGHT-LINE-DASHED",
      imagePath: "diagonal-line-dashed.png",
    ),

    LineModelV2(
      id: RandomGenerator.generateId(),
      start: Vector2.zero(),
      end: Vector2.zero(),
      fieldItemType: FieldItemType.LINE,
      lineType: LineType.STRAIGHT_LINE_ZIGZAG,
      color: ColorManager.black,
      name: "STRAIGHT-LINE-ZIGZAG",
      imagePath: "diagonal-line-zigzag.png",
    ),

    LineModelV2(
      id: RandomGenerator.generateId(),
      start: Vector2.zero(),
      end: Vector2.zero(),
      fieldItemType: FieldItemType.LINE,
      lineType: LineType.STRAIGHT_LINE_ZIGZAG_ARROW,
      color: ColorManager.black,
      name: "STRAIGHT-LINE-ZIGZAG-ARROW",
      imagePath: "diagonal-line-zigzag-arrow.png",
    ),

    LineModelV2(
      id: RandomGenerator.generateId(),
      start: Vector2.zero(),
      end: Vector2.zero(),
      fieldItemType: FieldItemType.LINE,
      lineType: LineType.STRAIGHT_LINE_ARROW,
      color: ColorManager.black,
      name: "STRAIGHT-LINE-ARROW",
      imagePath: "diagonal-line-arrow.png",
    ),

    LineModelV2(
      id: RandomGenerator.generateId(),
      start: Vector2.zero(),
      end: Vector2.zero(),
      fieldItemType: FieldItemType.LINE,
      lineType: LineType.STRAIGHT_LINE_ARROW_DOUBLE,
      color: ColorManager.black,
      name: "STRAIGHT-LINE-ARROW-DOUBLE",
      imagePath: "diagonal-line-arrow-double.png",
    ),
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
