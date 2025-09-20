// import 'dart:math' as math;
//
// import 'package:flame/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/generator/random_generator.dart';
// import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart';
//
// /// Creates a default-sized equilateral triangle model.
// PolygonShapeModel createDefaultTriangle({
//   required Vector2 gameSize,
//   required Vector2 center, // This is the desired center in ACTUAL pixels
//   double size = 80.0, // This is the side length in ACTUAL pixels
// }) {
//   // Calculate actual vertex positions from the center
//   final double height = size * (math.sqrt(3) / 2); // Height
//   final Vector2 v1 = center + Vector2(0, -height / 2); // Top
//   final Vector2 v2 = center + Vector2(-size / 2, height / 2); // Bottom-left
//   final Vector2 v3 = center + Vector2(size / 2, height / 2); // Bottom-right
//
//   // Convert actual positions to relative positions for the model
//   final List<Vector2> relativeVertices = [
//     SizeHelper.getBoardRelativeVector(
//         gameScreenSize: gameSize, actualPosition: v1),
//     SizeHelper.getBoardRelativeVector(
//         gameScreenSize: gameSize, actualPosition: v2),
//     SizeHelper.getBoardRelativeVector(
//         gameScreenSize: gameSize, actualPosition: v3),
//   ];
//
//   return PolygonShapeModel(
//     id: RandomGenerator.generateId(),
//     center: SizeHelper.getBoardRelativeVector(
//       gameScreenSize: gameSize,
//       actualPosition: center,
//     ),
//     relativeVertices: relativeVertices,
//     maxVertices: 3,
//     minVertices: 3,
//     name: 'Triangle',
//     imagePath: 'triangle.png', // Updated
//     strokeWidth: 2.0,
//     strokeColor: Colors.white,
//     fillColor: Colors.white.withOpacity(0.1),
//     canBeCopied: true,
//   );
// }
//
// /// Creates a default-sized regular octagon model.
// PolygonShapeModel createDefaultOctagon({
//   required Vector2 gameSize,
//   required Vector2 center, // This is the desired center in ACTUAL pixels
//   double radius = 50.0, // Radius in ACTUAL pixels
// }) {
//   final List<Vector2> relativeVertices = [];
//   const int sides = 8;
//
//   for (int i = 0; i < sides; i++) {
//     final double angle = (i / sides) * 2 * math.pi;
//     final Vector2 v =
//         center + Vector2(math.cos(angle), math.sin(angle)) * radius;
//     relativeVertices.add(
//       SizeHelper.getBoardRelativeVector(
//           gameScreenSize: gameSize, actualPosition: v),
//     );
//   }
//
//   return PolygonShapeModel(
//     id: RandomGenerator.generateId(),
//     center: SizeHelper.getBoardRelativeVector(
//       gameScreenSize: gameSize,
//       actualPosition: center,
//     ),
//     relativeVertices: relativeVertices,
//     maxVertices: 8,
//     minVertices: 3,
//     name: 'Octagon',
//     imagePath: 'polygon.png', // Updated (using 'polygon.png' from your utils)
//     strokeWidth: 2.0,
//     strokeColor: Colors.white,
//     fillColor: Colors.white.withOpacity(0.1),
//     canBeCopied: true,
//   );
// }
//
// /// Creates a default-sized square model.
// SquareShapeModel createDefaultSquare({
//   required Vector2 gameSize,
//   required Vector2 center, // ACTUAL pixels
//   double side = 80.0, // ACTUAL pixels
// }) {
//   return SquareShapeModel(
//     id: RandomGenerator.generateId(),
//     center: SizeHelper.getBoardRelativeVector(
//       gameScreenSize: gameSize,
//       actualPosition: center,
//     ),
//     side: SizeHelper.getBoardRelativeDimension(
//       gameScreenSize: gameSize,
//       actualSize: side,
//     ),
//     angle: 0.0,
//     name: 'Square',
//     imagePath: 'square.png', // Updated
//     strokeWidth: 2.0,
//     strokeColor: Colors.white,
//     fillColor: Colors.white.withOpacity(0.1),
//     canBeCopied: true,
//   );
// }
//
// /// Creates a default-sized circle model.
// CircleShapeModel createDefaultCircle({
//   required Vector2 gameSize,
//   required Vector2 center, // ACTUAL pixels
//   double radius = 40.0, // ACTUAL pixels
// }) {
//   return CircleShapeModel(
//     id: RandomGenerator.generateId(),
//     center: SizeHelper.getBoardRelativeVector(
//       gameScreenSize: gameSize,
//       actualPosition: center,
//     ),
//     radius: SizeHelper.getBoardRelativeDimension(
//       gameScreenSize: gameSize,
//       actualSize: radius,
//     ),
//     name: 'Circle',
//     imagePath: 'circle.png', // Updated
//     strokeWidth: 2.0,
//     strokeColor: Colors.white,
//     fillColor: Colors.white.withOpacity(0.1),
//     canBeCopied: true,
//   );
// }

import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart';

// This function is correct and does not need to change.
// It calculates vertices *around* the center.
PolygonShapeModel createDefaultTriangle({
  required Vector2 gameSize,
  required Vector2 center, // This is the visual center
  double size = 80.0,
}) {
  final double height = size * (math.sqrt(3) / 2);
  final Vector2 v1 = center + Vector2(0, -height / 2);
  final Vector2 v2 = center + Vector2(-size / 2, height / 2);
  final Vector2 v3 = center + Vector2(size / 2, height / 2);

  final List<Vector2> relativeVertices = [
    SizeHelper.getBoardRelativeVector(
        gameScreenSize: gameSize, actualPosition: v1),
    SizeHelper.getBoardRelativeVector(
        gameScreenSize: gameSize, actualPosition: v2),
    SizeHelper.getBoardRelativeVector(
        gameScreenSize: gameSize, actualPosition: v3),
  ];

  return PolygonShapeModel(
    id: RandomGenerator.generateId(),
    center: SizeHelper.getBoardRelativeVector(
      gameScreenSize: gameSize,
      actualPosition: center,
    ),
    relativeVertices: relativeVertices,
    maxVertices: 3,
    minVertices: 3,
    name: 'Triangle',
    imagePath: 'triangle.png',
    strokeWidth: 2.0,
    strokeColor: Colors.white,
    fillColor: Colors.white.withOpacity(0.1),
    canBeCopied: true,
  );
}

// This function is also correct and does not need to change.
// It also calculates vertices *around* the center.
PolygonShapeModel createDefaultOctagon({
  required Vector2 gameSize,
  required Vector2 center, // This is the visual center
  double radius = 50.0,
}) {
  final List<Vector2> relativeVertices = [];
  const int sides = 8;
  for (int i = 0; i < sides; i++) {
    final double angle = (i / sides) * 2 * math.pi;
    final Vector2 v =
        center + Vector2(math.cos(angle), math.sin(angle)) * radius;
    relativeVertices.add(
      SizeHelper.getBoardRelativeVector(
          gameScreenSize: gameSize, actualPosition: v),
    );
  }

  return PolygonShapeModel(
    id: RandomGenerator.generateId(),
    center: SizeHelper.getBoardRelativeVector(
      gameScreenSize: gameSize,
      actualPosition: center,
    ),
    relativeVertices: relativeVertices,
    maxVertices: 8,
    minVertices: 3,
    name: 'Octagon',
    imagePath: 'polygon.png',
    strokeWidth: 2.0,
    strokeColor: Colors.white,
    fillColor: Colors.white.withOpacity(0.1),
    canBeCopied: true,
  );
}

/// Creates a default-sized square model.
SquareShapeModel createDefaultSquare({
  required Vector2 gameSize,
  required Vector2 visualCenter, // ACTUAL pixels
  double side = 80.0, // ACTUAL pixels
}) {
  return SquareShapeModel(
    id: RandomGenerator.generateId(),
    //
    // *** THE FIX ***
    // We pass the visualCenter directly, not a calculated top-left corner.
    //
    center: SizeHelper.getBoardRelativeVector(
      gameScreenSize: gameSize,
      actualPosition: visualCenter,
    ),
    side: SizeHelper.getBoardRelativeDimension(
      gameScreenSize: gameSize,
      actualSize: side,
    ),
    angle: 0.0,
    name: 'Square',
    imagePath: 'square.png',
    strokeWidth: 2.0,
    strokeColor: Colors.white,
    fillColor: Colors.white.withOpacity(0.1),
    canBeCopied: true,
  );
}

/// Creates a default-sized circle model.
CircleShapeModel createDefaultCircle({
  required Vector2 gameSize,
  required Vector2 visualCenter, // ACTUAL pixels
  double radius = 40.0, // ACTUAL pixels
}) {
  return CircleShapeModel(
    id: RandomGenerator.generateId(),
    //
    // *** THE FIX ***
    // We pass the visualCenter directly, not a calculated top-left corner.
    //
    center: SizeHelper.getBoardRelativeVector(
      gameScreenSize: gameSize,
      actualPosition: visualCenter,
    ),
    radius: SizeHelper.getBoardRelativeDimension(
      gameScreenSize: gameSize,
      actualSize: radius,
    ),
    name: 'Circle',
    imagePath: 'circle.png',
    strokeWidth: 2.0,
    strokeColor: Colors.white,
    fillColor: Colors.white.withOpacity(0.1),
    canBeCopied: true,
  );
}
