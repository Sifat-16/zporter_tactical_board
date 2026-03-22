import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/equipment_element.dart';
import 'package:zporter_tactical_board/v2/models/free_draw_element.dart';
import 'package:zporter_tactical_board/v2/models/line_element.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/models/shape_elements.dart';
import 'package:zporter_tactical_board/v2/models/text_element.dart';

void main() {
  // ===========================================================================
  // V1-format JSON fixtures (matching exact V1 toJson() output)
  // ===========================================================================

  final v1PlayerJson = <String, dynamic>{
    '_id': 'player-1',
    'offset': {'dx': 100.0, 'dy': 200.0},
    'scaleSymmetrically': true,
    'fieldItemType': 'PLAYER',
    'angle': 45.0,
    'canBeCopied': false,
    'createdAt': '2024-01-15T10:30:00.000Z',
    'updatedAt': '2024-01-15T10:30:00.000Z',
    'size': {'x': 40.0, 'y': 40.0},
    'color': 0xFF0000FF,
    'opacity': 0.8,
    'zIndex': 5,
    'role': 'Striker',
    'jerseyNumber': 9,
    'displayNumber': 9,
    'playerType': 'HOME',
    'name': 'Test Player',
    'showName': true,
    'showNr': true,
    'showRole': false,
    'showImage': true,
    'imagePath': 'assets/player.png',
    'imageBase64': 'iVBORw0KGgo=',
    'imageUrl': 'https://example.com/player.png',
    'borderColor': 0xFFFF0000,
  };

  final v1EquipmentJson = <String, dynamic>{
    '_id': 'equip-1',
    'offset': {'dx': 300.0, 'dy': 400.0},
    'scaleSymmetrically': true,
    'fieldItemType': 'EQUIPMENT',
    'angle': null,
    'canBeCopied': true,
    'size': {'x': 20.0, 'y': 20.0},
    'color': 0xFFFFFFFF,
    'opacity': 1.0,
    'name': 'Ball',
    'imagePath': 'assets/ball.png',
    'imageUrl': null,
    'isAerialArrival': true,
    'passSpeedMultiplier': 2.0,
    'spin': 'left',
  };

  final v1LineJson = <String, dynamic>{
    '_id': 'line-1',
    'offset': {'dx': 0.0, 'dy': 0.0},
    'scaleSymmetrically': false,
    'fieldItemType': 'LINE',
    'canBeCopied': true,
    'color': 0xFFFF0000,
    'start': {'x': 100.0, 'y': 200.0},
    'end': {'x': 300.0, 'y': 400.0},
    'thickness': 3.0,
    'lineType': 'PASS',
    'name': 'Pass Line',
    'imagePath': 'assets/line.png',
    'controlPoint1': {'x': 150.0, 'y': 250.0},
    'controlPoint2': {'x': 250.0, 'y': 350.0},
  };

  final v1FreeDrawJson = <String, dynamic>{
    '_id': 'draw-1',
    'offset': {'dx': 0.0, 'dy': 0.0},
    'scaleSymmetrically': true,
    'fieldItemType': 'FREEDRAW',
    'canBeCopied': false,
    'lineColor': 0xFF00FF00, // V1 uses 'lineColor' key
    'color': 0xFF00FF00,
    'opacity': 1.0,
    'points': [
      {'x': 10.0, 'y': 20.0},
      {'x': 30.0, 'y': 40.0},
      {'x': 50.0, 'y': 60.0},
    ],
    'thickness': 4.0,
    'name': 'FREE-DRAW',
    'imagePath': 'assets/images/free-draw.png',
  };

  final v1TextJson = <String, dynamic>{
    '_id': 'text-1',
    'offset': {'dx': 50.0, 'dy': 50.0},
    'scaleSymmetrically': false,
    'fieldItemType': 'TEXT',
    'canBeCopied': true,
    'color': 0xFF000000,
    'size': {'x': 120.0, 'y': 30.0},
    'text': 'Formation 4-3-3',
    'name': 'Label',
    'imagePath': '',
  };

  final v1CircleJson = <String, dynamic>{
    '_id': 'circle-1',
    'offset': {'dx': 500.0, 'dy': 300.0},
    'fieldItemType': 'CIRCLE',
    'canBeCopied': true,
    'color': 0xFF0000FF,
    'fillColor': 0x5500FF00,
    'strokeWidth': 3.0,
    'radius': 50.0,
    'opacity': 0.9,
    'name': 'Zone',
    'imagePath': 'assets/circle.png',
  };

  final v1SquareJson = <String, dynamic>{
    '_id': 'square-1',
    'offset': {'dx': 200.0, 'dy': 200.0},
    'fieldItemType': 'SQUARE',
    'canBeCopied': true,
    'color': 0xFFFF0000,
    'fillColor': null,
    'strokeWidth': 2.0,
    'side': 0.15,
    'angle': 30.0,
    'name': 'Box',
    'imagePath': 'assets/square.png',
  };

  final v1TriangleJson = <String, dynamic>{
    '_id': 'tri-1',
    'offset': {'dx': 400.0, 'dy': 400.0},
    'fieldItemType': 'TRIANGLE',
    'canBeCopied': false,
    'color': 0xFF00FFFF,
    'strokeWidth': 1.5,
    'vertexA': {'x': 0.0, 'y': -50.0},
    'vertexB': {'x': -40.0, 'y': 30.0},
    'vertexC': {'x': 40.0, 'y': 30.0},
    'name': 'Arrow',
    'imagePath': 'assets/triangle.png',
  };

  final v1PolygonJson = <String, dynamic>{
    '_id': 'poly-1',
    'offset': {'dx': 600.0, 'dy': 300.0},
    'fieldItemType': 'POLYGON',
    'canBeCopied': true,
    'color': 0xFFAA00AA,
    'fillColor': 0x33FF00FF,
    'strokeWidth': 2.5,
    'relativeVertices': [
      {'x': 0.0, 'y': -0.1},
      {'x': 0.1, 'y': 0.0},
      {'x': 0.0, 'y': 0.1},
      {'x': -0.1, 'y': 0.0},
    ],
    'maxVertices': 8,
    'minVertices': 3,
    'name': 'Diamond',
    'imagePath': 'assets/polygon.png',
  };

  // ===========================================================================
  // PlayerElement
  // ===========================================================================

  group('PlayerElement', () {
    test('fromJson parses V1 JSON correctly', () {
      final player = PlayerElement.fromJson(v1PlayerJson);

      expect(player.id, 'player-1');
      expect(player.offset, const Offset(100.0, 200.0));
      expect(player.fieldItemType, FieldItemType.PLAYER);
      expect(player.scaleSymmetrically, true);
      expect(player.angle, 45.0);
      expect(player.canBeCopied, false);
      expect(player.size, const Size(40.0, 40.0));
      expect(player.color, const Color(0xFF0000FF));
      expect(player.opacity, 0.8);
      expect(player.zIndex, 5);
      expect(player.role, 'Striker');
      expect(player.jerseyNumber, 9);
      expect(player.displayNumber, 9);
      expect(player.playerType, PlayerType.HOME);
      expect(player.name, 'Test Player');
      expect(player.showName, true);
      expect(player.showNr, true);
      expect(player.showRole, false);
      expect(player.showImage, true);
      expect(player.imagePath, 'assets/player.png');
      expect(player.imageBase64, 'iVBORw0KGgo=');
      expect(player.imageUrl, 'https://example.com/player.png');
      expect(player.borderColor, const Color(0xFFFF0000));
    });

    test('V1 migration: displayNumber defaults to jerseyNumber', () {
      final jsonWithoutDisplay = Map<String, dynamic>.from(v1PlayerJson);
      jsonWithoutDisplay.remove('displayNumber');

      final player = PlayerElement.fromJson(jsonWithoutDisplay);
      expect(player.displayNumber, player.jerseyNumber);
    });

    test('toJson round-trip preserves all fields', () {
      final original = PlayerElement.fromJson(v1PlayerJson);
      final json = original.toJson();
      final restored = PlayerElement.fromJson(json);

      expect(restored, original);
    });

    test('toJsonForFirestore excludes imageBase64', () {
      final player = PlayerElement.fromJson(v1PlayerJson);
      final firestoreJson = player.toJsonForFirestore();

      expect(firestoreJson.containsKey('imageBase64'), false);
      expect(firestoreJson['_id'], 'player-1');
      expect(firestoreJson['role'], 'Striker');
    });

    test('copyWith with sentinel preserves nullable fields', () {
      final player = PlayerElement.fromJson(v1PlayerJson);

      // Update name to null explicitly
      final updated = player.copyWith(name: null);
      expect(updated.name, null);

      // Leave name unchanged (sentinel)
      final unchanged = player.copyWith(role: 'Midfielder');
      expect(unchanged.name, 'Test Player');
      expect(unchanged.role, 'Midfielder');
    });

    test('equality works correctly', () {
      final p1 = PlayerElement.fromJson(v1PlayerJson);
      final p2 = PlayerElement.fromJson(v1PlayerJson);
      final p3 = p1.copyWith(role: 'Goalkeeper');

      expect(p1, p2);
      expect(p1, isNot(p3));
      expect(p1.hashCode, p2.hashCode);
    });

    test('clone creates independent copy', () {
      final original = PlayerElement.fromJson(v1PlayerJson);
      final cloned = original.clone();

      expect(cloned, original);
      expect(identical(cloned, original), false);
    });

    test('helper getters work', () {
      final player = PlayerElement.fromJson(v1PlayerJson);

      expect(player.hasBase64Image, true);
      expect(player.hasImageUrl, true);
      expect(player.needsImageMigration, false);

      final noUrl = player.copyWith(imageUrl: null);
      expect(noUrl.needsImageMigration, true);
    });
  });

  // ===========================================================================
  // EquipmentElement
  // ===========================================================================

  group('EquipmentElement', () {
    test('fromJson parses V1 JSON correctly', () {
      final equip = EquipmentElement.fromJson(v1EquipmentJson);

      expect(equip.id, 'equip-1');
      expect(equip.offset, const Offset(300.0, 400.0));
      expect(equip.fieldItemType, FieldItemType.EQUIPMENT);
      expect(equip.name, 'Ball');
      expect(equip.isAerialArrival, true);
      expect(equip.passSpeedMultiplier, 2.0);
      expect(equip.spin, BallSpin.left);
    });

    test('toJson round-trip preserves all fields', () {
      final original = EquipmentElement.fromJson(v1EquipmentJson);
      final json = original.toJson();
      final restored = EquipmentElement.fromJson(json);

      expect(restored, original);
    });

    test('defaults for missing fields', () {
      final minimal = EquipmentElement.fromJson({
        '_id': 'eq-min',
        'fieldItemType': 'EQUIPMENT',
      });

      expect(minimal.name, 'Unnamed Equipment');
      expect(minimal.isAerialArrival, false);
      expect(minimal.passSpeedMultiplier, 1.0);
      expect(minimal.spin, BallSpin.none);
      expect(minimal.canBeCopied, true);
    });
  });

  // ===========================================================================
  // LineElement
  // ===========================================================================

  group('LineElement', () {
    test('fromJson parses V1 JSON with {x,y} start/end', () {
      final line = LineElement.fromJson(v1LineJson);

      expect(line.id, 'line-1');
      expect(line.start, const Offset(100.0, 200.0));
      expect(line.end, const Offset(300.0, 400.0));
      expect(line.thickness, 3.0);
      expect(line.lineType, LineType.PASS);
      expect(line.controlPoint1, const Offset(150.0, 250.0));
      expect(line.controlPoint2, const Offset(250.0, 350.0));
    });

    test('toJson round-trip preserves all fields', () {
      final original = LineElement.fromJson(v1LineJson);
      final json = original.toJson();
      final restored = LineElement.fromJson(json);

      expect(restored, original);
    });

    test('copyWith clearControlPoints sets both to null', () {
      final line = LineElement.fromJson(v1LineJson);
      final cleared = line.copyWith(clearControlPoints: true);

      expect(cleared.controlPoint1, null);
      expect(cleared.controlPoint2, null);
      expect(cleared.start, line.start); // preserved
    });

    test('line without control points', () {
      final jsonNoCP = Map<String, dynamic>.from(v1LineJson);
      jsonNoCP.remove('controlPoint1');
      jsonNoCP.remove('controlPoint2');

      final line = LineElement.fromJson(jsonNoCP);
      expect(line.controlPoint1, null);
      expect(line.controlPoint2, null);
    });
  });

  // ===========================================================================
  // FreeDrawElement
  // ===========================================================================

  group('FreeDrawElement', () {
    test('fromJson parses V1 JSON with lineColor key', () {
      final draw = FreeDrawElement.fromJson(v1FreeDrawJson);

      expect(draw.id, 'draw-1');
      expect(draw.points.length, 3);
      expect(draw.points[0], const Offset(10.0, 20.0));
      expect(draw.points[1], const Offset(30.0, 40.0));
      expect(draw.points[2], const Offset(50.0, 60.0));
      expect(draw.thickness, 4.0);
      expect(draw.color, const Color(0xFF00FF00));
    });

    test('fromJson reads lineColor when color is missing', () {
      final jsonOnlyLineColor = <String, dynamic>{
        '_id': 'draw-2',
        'fieldItemType': 'FREEDRAW',
        'lineColor': 0xFFABCDEF,
        'points': [],
      };

      final draw = FreeDrawElement.fromJson(jsonOnlyLineColor);
      expect(draw.color, const Color(0xFFABCDEF));
    });

    test('toJson outputs lineColor key for V1 compatibility', () {
      final draw = FreeDrawElement.fromJson(v1FreeDrawJson);
      final json = draw.toJson();

      expect(json.containsKey('lineColor'), true);
    });

    test('toJson round-trip preserves all fields', () {
      final original = FreeDrawElement.fromJson(v1FreeDrawJson);
      final json = original.toJson();
      final restored = FreeDrawElement.fromJson(json);

      expect(restored, original);
    });

    test('points list is unmodifiable', () {
      final draw = FreeDrawElement.fromJson(v1FreeDrawJson);

      expect(
        () => (draw.points as List).add(Offset.zero),
        throwsUnsupportedError,
      );
    });
  });

  // ===========================================================================
  // TextElement
  // ===========================================================================

  group('TextElement', () {
    test('fromJson parses V1 JSON correctly', () {
      final text = TextElement.fromJson(v1TextJson);

      expect(text.id, 'text-1');
      expect(text.text, 'Formation 4-3-3');
      expect(text.name, 'Label');
      expect(text.offset, const Offset(50.0, 50.0));
      expect(text.size, const Size(120.0, 30.0));
    });

    test('toJson round-trip preserves all fields', () {
      final original = TextElement.fromJson(v1TextJson);
      final json = original.toJson();
      final restored = TextElement.fromJson(json);

      expect(restored, original);
    });
  });

  // ===========================================================================
  // CircleElement
  // ===========================================================================

  group('CircleElement', () {
    test('fromJson parses V1 JSON correctly', () {
      final circle = CircleElement.fromJson(v1CircleJson);

      expect(circle.id, 'circle-1');
      expect(circle.center, const Offset(500.0, 300.0));
      expect(circle.radius, 50.0);
      expect(circle.fillColor, const Color(0x5500FF00));
      expect(circle.strokeWidth, 3.0);
      expect(circle.strokeColor, const Color(0xFF0000FF));
      expect(circle.opacity, 0.9);
      expect(circle.size, const Size(100.0, 100.0)); // radius * 2
    });

    test('toJson round-trip preserves all fields', () {
      final original = CircleElement.fromJson(v1CircleJson);
      final json = original.toJson();
      final restored = CircleElement.fromJson(json);

      expect(restored, original);
    });

    test('copyWith clearFillColor sets fillColor to null', () {
      final circle = CircleElement.fromJson(v1CircleJson);
      final cleared = circle.copyWith(clearFillColor: true);

      expect(cleared.fillColor, null);
      expect(cleared.radius, circle.radius); // preserved
    });
  });

  // ===========================================================================
  // SquareElement
  // ===========================================================================

  group('SquareElement', () {
    test('fromJson parses V1 JSON correctly', () {
      final square = SquareElement.fromJson(v1SquareJson);

      expect(square.id, 'square-1');
      expect(square.center, const Offset(200.0, 200.0));
      expect(square.side, 0.15);
      expect(square.angle, 30.0);
    });

    test('toJson round-trip preserves all fields', () {
      final original = SquareElement.fromJson(v1SquareJson);
      final json = original.toJson();
      final restored = SquareElement.fromJson(json);

      expect(restored, original);
    });
  });

  // ===========================================================================
  // TriangleElement
  // ===========================================================================

  group('TriangleElement', () {
    test('fromJson parses V1 JSON with vertices', () {
      final tri = TriangleElement.fromJson(v1TriangleJson);

      expect(tri.id, 'tri-1');
      expect(tri.center, const Offset(400.0, 400.0));
      expect(tri.vertexA, const Offset(0.0, -50.0));
      expect(tri.vertexB, const Offset(-40.0, 30.0));
      expect(tri.vertexC, const Offset(40.0, 30.0));
      expect(tri.size, Size.zero); // triangles always have Size.zero
    });

    test('toJson round-trip preserves all fields', () {
      final original = TriangleElement.fromJson(v1TriangleJson);
      final json = original.toJson();
      final restored = TriangleElement.fromJson(json);

      expect(restored, original);
    });
  });

  // ===========================================================================
  // PolygonElement
  // ===========================================================================

  group('PolygonElement', () {
    test('fromJson parses V1 JSON with relativeVertices', () {
      final poly = PolygonElement.fromJson(v1PolygonJson);

      expect(poly.id, 'poly-1');
      expect(poly.center, const Offset(600.0, 300.0));
      expect(poly.relativeVertices.length, 4);
      expect(poly.maxVertices, 8);
      expect(poly.minVertices, 3);
      expect(poly.fillColor, const Color(0x33FF00FF));
    });

    test('toJson round-trip preserves all fields', () {
      final original = PolygonElement.fromJson(v1PolygonJson);
      final json = original.toJson();
      final restored = PolygonElement.fromJson(json);

      expect(restored, original);
    });

    test('relativeVertices list is unmodifiable', () {
      final poly = PolygonElement.fromJson(v1PolygonJson);

      expect(
        () => (poly.relativeVertices as List).add(Offset.zero),
        throwsUnsupportedError,
      );
    });
  });

  // ===========================================================================
  // BoardElement.fromJson dispatcher
  // ===========================================================================

  group('BoardElement.fromJson dispatcher', () {
    test('dispatches PLAYER correctly', () {
      final element = BoardElement.fromJson(v1PlayerJson);
      expect(element, isA<PlayerElement>());
    });

    test('dispatches EQUIPMENT correctly', () {
      final element = BoardElement.fromJson(v1EquipmentJson);
      expect(element, isA<EquipmentElement>());
    });

    test('dispatches LINE correctly', () {
      final element = BoardElement.fromJson(v1LineJson);
      expect(element, isA<LineElement>());
    });

    test('dispatches FREEDRAW correctly', () {
      final element = BoardElement.fromJson(v1FreeDrawJson);
      expect(element, isA<FreeDrawElement>());
    });

    test('dispatches TEXT correctly', () {
      final element = BoardElement.fromJson(v1TextJson);
      expect(element, isA<TextElement>());
    });

    test('dispatches CIRCLE correctly', () {
      final element = BoardElement.fromJson(v1CircleJson);
      expect(element, isA<CircleElement>());
    });

    test('dispatches SQUARE correctly', () {
      final element = BoardElement.fromJson(v1SquareJson);
      expect(element, isA<SquareElement>());
    });

    test('dispatches TRIANGLE correctly', () {
      final element = BoardElement.fromJson(v1TriangleJson);
      expect(element, isA<TriangleElement>());
    });

    test('dispatches POLYGON correctly', () {
      final element = BoardElement.fromJson(v1PolygonJson);
      expect(element, isA<PolygonElement>());
    });

    test('throws on missing fieldItemType', () {
      expect(
        () => BoardElement.fromJson({'_id': 'bad'}),
        throwsFormatException,
      );
    });

    test('throws on unknown fieldItemType', () {
      expect(
        () => BoardElement.fromJson({
          '_id': 'bad',
          'fieldItemType': 'UNKNOWN_TYPE',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ===========================================================================
  // V1 JSON edge cases
  // ===========================================================================

  group('V1 JSON edge cases', () {
    test('offset with {x,y} format is parsed correctly', () {
      final json = Map<String, dynamic>.from(v1PlayerJson);
      json['offset'] = {'x': 150.0, 'y': 250.0}; // {x,y} instead of {dx,dy}

      final player = PlayerElement.fromJson(json);
      expect(player.offset, const Offset(150.0, 250.0));
    });

    test('missing optional fields get defaults', () {
      final minimal = <String, dynamic>{
        '_id': 'min-1',
        'fieldItemType': 'PLAYER',
        'role': 'GK',
        'jerseyNumber': 1,
        'playerType': 'HOME',
      };

      final player = PlayerElement.fromJson(minimal);
      expect(player.offset, Offset.zero);
      expect(player.opacity, 1.0);
      expect(player.canBeCopied, false);
      expect(player.showName, true);
    });

    test('color as int is parsed correctly', () {
      final json = Map<String, dynamic>.from(v1PlayerJson);
      json['color'] = 0xFFFF00FF; // magenta as ARGB int

      final player = PlayerElement.fromJson(json);
      expect(player.color, const Color(0xFFFF00FF));
    });
  });
}
