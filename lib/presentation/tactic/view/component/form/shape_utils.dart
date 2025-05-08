import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart';

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
    SquareShapeModel(
      id: RandomGenerator.generateId(),
      name: "SQUARE",
      imagePath: "square.png",
      center: Vector2.zero(),
      canBeCopied: false,
      side: 1,
    ),

    PolygonShapeModel(
      id: RandomGenerator.generateId(),
      name: "POLYGON",
      imagePath: "triangle.png",
      center: Vector2.zero(),
      canBeCopied: false,
      relativeVertices: [],
      maxVertices: 3,
    ),

    PolygonShapeModel(
      id: RandomGenerator.generateId(),
      name: "POLYGON",
      imagePath: "polygon.png",
      center: Vector2.zero(),
      canBeCopied: false,
      relativeVertices: [],
      maxVertices: null,
    ),
  ];
  static List<ShapeModel> generateShapes() {
    return _shapes;
  }
}
