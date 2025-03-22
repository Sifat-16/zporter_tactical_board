import 'package:flame/components.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';

class FormUtils {
  static final List<FormModel> _forms = [
    FormModel(
      id: ObjectId(),
      name: "TEXT",
      imagePath: "text.png",
      formItemModel: FormTextModel(text: "T"),
    ),

    FormModel(
      id: ObjectId(),
      name: "STRAIGHT-LINE",
      imagePath: "diagonal-line.png",
      formItemModel: LineModel(
        start: Vector2.zero(),
        end: Vector2.zero(),
        color: ColorManager.black,
      ),
    ),
  ];
  static List<FormModel> generateForms() {
    return _forms;
  }
}
