import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';

class ShapeUtils {
  static final List<ShapeModel> _shapes = [
    CircleShapeModel(
      id: RandomGenerator.generateId(),
      name: "CIRCLE",
      imagePath: "circle.png",
      center: Vector2.zero(),
      canBeCopied: false,
      radius: 1,
    ),
  ];
  static List<ShapeModel> generateShapes() {
    return _shapes;
  }
}
