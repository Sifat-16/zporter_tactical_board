import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';

class FormUtils {
  static final List<FormModel> _forms = [
    FormModel(
      id: RandomGenerator.generateId(),
      name: "TEXT",
      imagePath: "text.png",
      formItemModel: FormTextModel(text: "T"),
    ),

    FormModel(
      id: RandomGenerator.generateId(),
      name: "STRAIGHT-LINE",
      imagePath: "diagonal-line.png",
      formItemModel: LineModel(
        start: Vector2.zero(),
        lineType: LineType.STRAIGHT_LINE,
        end: Vector2.zero(),
        color: ColorManager.black,
      ),
    ),

    FormModel(
      id: RandomGenerator.generateId(),
      name: "STRAIGHT-LINE-DASHED",
      imagePath: "diagonal-line-dashed.png",
      formItemModel: LineModel(
        start: Vector2.zero(),
        lineType: LineType.STRAIGHT_LINE_DASHED,
        end: Vector2.zero(),
        color: ColorManager.black,
      ),
    ),

    FormModel(
      id: RandomGenerator.generateId(),
      name: "STRAIGHT-LINE-ZIGZAG",
      imagePath: "diagonal-line-zigzag.png",
      formItemModel: LineModel(
        start: Vector2.zero(),
        lineType: LineType.STRAIGHT_LINE_ZIGZAG,
        end: Vector2.zero(),
        color: ColorManager.black,
      ),
    ),

    FormModel(
      id: RandomGenerator.generateId(),
      name: "STRAIGHT-LINE-ZIGZAG-ARROW",
      imagePath: "diagonal-line-zigzag-arrow.png",
      formItemModel: LineModel(
        start: Vector2.zero(),
        lineType: LineType.STRAIGHT_LINE_ZIGZAG_ARROW,
        end: Vector2.zero(),
        color: ColorManager.black,
      ),
    ),

    FormModel(
      id: RandomGenerator.generateId(),
      name: "STRAIGHT-LINE-ARROW",
      imagePath: "diagonal-line-arrow.png",
      formItemModel: LineModel(
        start: Vector2.zero(),
        lineType: LineType.STRAIGHT_LINE_ARROW,
        end: Vector2.zero(),
        color: ColorManager.black,
      ),
    ),

    FormModel(
      id: RandomGenerator.generateId(),
      name: "STRAIGHT-LINE-ARROW-DOUBLE",
      imagePath: "diagonal-line-arrow-double.png",
      formItemModel: LineModel(
        start: Vector2.zero(),
        lineType: LineType.STRAIGHT_LINE_ARROW_DOUBLE,
        end: Vector2.zero(),
        color: ColorManager.black,
      ),
    ),

    FormModel(
      id: RandomGenerator.generateId(),
      name: "FREE-DRAW",
      imagePath: "free-draw.png",
      formItemModel: FreeDrawModel(
        points: [],
        color: ColorManager.black,
        thickness: 5,
      ),
    ),

    // FormModel(
    //   id: ObjectId(),
    //   name: "RIGHT_TURN_ARROW",
    //   imagePath: "diagonal-line-right-turn.png",
    //   formItemModel: LineModel(
    //     start: Vector2.zero(),
    //     lineType: LineType.RIGHT_TURN_ARROW,
    //     end: Vector2.zero(),
    //     color: ColorManager.black,
    //   ),
    // ),
  ];
  static List<FormModel> generateForms() {
    return _forms;
  }

  static bool isPresentFreeDraw(AnimationItemModel scene) {
    List<FieldItemModel> items = scene.components;
    return items.indexWhere((t) {
          if (t is FormModel) {
            if (t.formItemModel is FreeDrawModel) {
              return true;
            }
          }
          return false;
        }) !=
        -1;
  }
}
