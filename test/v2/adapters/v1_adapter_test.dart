import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/data/adapters/v1_adapter.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/equipment_element.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';

void main() {
  const adapter = V1Adapter();

  // ===========================================================================
  // V1 JSON fixtures
  // ===========================================================================

  final v1PlayerJson = <String, dynamic>{
    '_id': 'player-1',
    'offset': {'dx': 100.0, 'dy': 200.0},
    'scaleSymmetrically': true,
    'fieldItemType': 'PLAYER',
    'role': 'Striker',
    'jerseyNumber': 9,
    'playerType': 'HOME',
    'name': 'Test Player',
  };

  final v1EquipmentJson = <String, dynamic>{
    '_id': 'equip-1',
    'offset': {'dx': 300.0, 'dy': 400.0},
    'fieldItemType': 'EQUIPMENT',
    'name': 'Ball',
  };

  final v1SceneJson = <String, dynamic>{
    'id': 'scene-1',
    'index': 0,
    'components': [v1PlayerJson, v1EquipmentJson],
    'fieldColor': 0xFF9E9E9E,
    'createdAt': '2024-01-15T10:00:00.000Z',
    'updatedAt': '2024-01-15T10:00:00.000Z',
    'userId': 'user-1',
    'fieldSize': {'x': 1050.0, 'y': 680.0},
    'sceneDurationMilliseconds': 2000,
    'boardBackground': 'full',
  };

  final v1AnimationJson = <String, dynamic>{
    '_id': 'anim-1',
    'name': 'Test Animation',
    'userId': 'user-1',
    'fieldColor': 0xFF9E9E9E,
    'animationScenes': [v1SceneJson],
    'createdAt': '2024-01-15T10:00:00.000Z',
    'updatedAt': '2024-01-15T10:00:00.000Z',
    'boardBackground': 'full',
    'orderIndex': 0,
  };

  final v1CollectionJson = <String, dynamic>{
    '_id': 'coll-1',
    'name': 'Test Collection',
    'userId': 'user-1',
    'animations': [v1AnimationJson],
    'createdAt': '2024-01-15T10:00:00.000Z',
    'updatedAt': '2024-01-15T10:00:00.000Z',
    'orderIndex': 0,
  };

  // ===========================================================================
  // Board Element conversion
  // ===========================================================================

  group('V1Adapter - boardElement', () {
    test('converts valid V1 player JSON', () {
      final element = adapter.boardElementFromV1(v1PlayerJson);

      expect(element, isNotNull);
      expect(element, isA<PlayerElement>());
      expect(element!.id, 'player-1');
    });

    test('returns null for malformed JSON', () {
      final result = adapter.boardElementFromV1({'bad': 'data'});
      expect(result, null);
    });

    test('batch converts list of V1 elements', () {
      final elements = adapter.boardElementsFromV1([
        v1PlayerJson,
        v1EquipmentJson,
        'not a map', // skipped
        42, // skipped
      ]);

      expect(elements.length, 2);
      expect(elements[0], isA<PlayerElement>());
      expect(elements[1], isA<EquipmentElement>());
    });

    test('batch skips malformed entries silently', () {
      final elements = adapter.boardElementsFromV1([
        {'_id': 'bad', 'fieldItemType': 'UNKNOWN_GARBAGE'},
      ]);

      expect(elements.length, 0);
    });
  });

  // ===========================================================================
  // Scene conversion
  // ===========================================================================

  group('V1Adapter - scene', () {
    test('converts valid V1 scene JSON', () {
      final scene = adapter.sceneFromV1(v1SceneJson);

      expect(scene, isNotNull);
      expect(scene!.id, 'scene-1');
      expect(scene.components.length, 2);
    });

    test('batch converts scenes with auto-indexing', () {
      final scene1 = Map<String, dynamic>.from(v1SceneJson);
      scene1.remove('index');
      final scene2 = Map<String, dynamic>.from(v1SceneJson);
      scene2['id'] = 'scene-2';
      scene2.remove('index');

      final scenes = adapter.scenesFromV1([scene1, scene2]);

      expect(scenes.length, 2);
      expect(scenes[0].index, 0);
      expect(scenes[1].index, 1);
    });

    test('batch sorts scenes by index', () {
      final scene1 = Map<String, dynamic>.from(v1SceneJson);
      scene1['index'] = 1;
      scene1['id'] = 'scene-second';
      final scene2 = Map<String, dynamic>.from(v1SceneJson);
      scene2['index'] = 0;
      scene2['id'] = 'scene-first';

      // Put index=1 first in list
      final scenes = adapter.scenesFromV1([scene1, scene2]);

      expect(scenes[0].index, 0);
      expect(scenes[1].index, 1);
    });
  });

  // ===========================================================================
  // Animation conversion
  // ===========================================================================

  group('V1Adapter - animation', () {
    test('converts valid V1 animation JSON', () {
      final anim = adapter.animationFromV1(v1AnimationJson);

      expect(anim, isNotNull);
      expect(anim!.id, 'anim-1');
      expect(anim.name, 'Test Animation');
      expect(anim.animationScenes.length, 1);
    });

    test('batch converts animations', () {
      final anims = adapter.animationsFromV1([
        v1AnimationJson,
        'not a map', // skipped
      ]);

      expect(anims.length, 1);
    });
  });

  // ===========================================================================
  // Collection conversion
  // ===========================================================================

  group('V1Adapter - collection', () {
    test('converts valid V1 collection JSON', () {
      final coll = adapter.collectionFromV1(v1CollectionJson);

      expect(coll, isNotNull);
      expect(coll!.id, 'coll-1');
      expect(coll.animations.length, 1);
    });

    test('batch converts collections', () {
      final colls = adapter.collectionsFromV1([
        v1CollectionJson,
        42, // skipped
      ]);

      expect(colls.length, 1);
    });
  });

  // ===========================================================================
  // Round-trip validation
  // ===========================================================================

  group('V1Adapter - round-trip validation', () {
    test('board element round-trip succeeds', () {
      expect(adapter.validateBoardElementRoundTrip(v1PlayerJson), true);
      expect(adapter.validateBoardElementRoundTrip(v1EquipmentJson), true);
    });

    test('board element round-trip fails for malformed JSON', () {
      expect(
        adapter.validateBoardElementRoundTrip({'bad': 'data'}),
        false,
      );
    });

    test('animation round-trip succeeds', () {
      expect(adapter.validateAnimationRoundTrip(v1AnimationJson), true);
    });

    test('scene round-trip succeeds', () {
      expect(adapter.validateSceneRoundTrip(v1SceneJson), true);
    });
  });
}
