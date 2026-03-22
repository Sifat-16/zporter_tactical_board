import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/models/animation_collection.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/models/trajectory_model.dart';

void main() {
  // ===========================================================================
  // Shared V1 JSON fixtures
  // ===========================================================================

  final v1PlayerComponentJson = <String, dynamic>{
    '_id': 'comp-player-1',
    'fieldItemType': 'PLAYER',
    'offset': {'dx': 0.5, 'dy': 0.3},
    'role': 'CM',
    'jerseyNumber': 8,
    'playerType': 'HOME',
  };

  final v1EquipmentComponentJson = <String, dynamic>{
    '_id': 'comp-equip-1',
    'fieldItemType': 'EQUIPMENT',
    'offset': {'dx': 0.5, 'dy': 0.5},
    'name': 'Ball',
  };

  final v1TrajectoryDataJson = <String, dynamic>{
    'componentTrajectories': {
      'comp-player-1': {
        'id': 'traj-1',
        'pathType': 'catmullRom',
        'trajectoryType': 'running',
        'lineStyle': 'dashed',
        'controlPoints': [
          {
            'id': 'cp-1',
            'position': {'x': 0.3, 'y': 0.4},
            'type': 'smooth',
            'tension': 0.5,
          },
          {
            'id': 'cp-2',
            'position': {'x': 0.6, 'y': 0.7},
            'type': 'sharp',
            'tension': 0.3,
          },
        ],
        'enabled': true,
        'pathColor': 0xFFFFC107,
        'pathWidth': 2.0,
        'showControlPoints': true,
        'smoothness': 0.5,
      },
    },
  };

  final v1SceneJson = <String, dynamic>{
    'id': 'scene-1',
    'index': 0,
    'components': [v1PlayerComponentJson, v1EquipmentComponentJson],
    'fieldColor': 0xFF9E9E9E,
    'createdAt': '2024-01-15T10:00:00.000Z',
    'updatedAt': '2024-01-15T10:00:00.000Z',
    'userId': 'user-1',
    'fieldSize': {'x': 1050.0, 'y': 680.0},
    'sceneDurationMilliseconds': 3000,
    'boardBackground': 'full',
    'trajectoryData': v1TrajectoryDataJson,
  };

  final v1SceneJson2 = <String, dynamic>{
    'id': 'scene-2',
    'index': 1,
    'components': [v1PlayerComponentJson],
    'fieldColor': 0xFF9E9E9E,
    'createdAt': '2024-01-15T10:01:00.000Z',
    'updatedAt': '2024-01-15T10:01:00.000Z',
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
    'collectionId': 'coll-1',
    'animationScenes': [v1SceneJson, v1SceneJson2],
    'createdAt': '2024-01-15T10:00:00.000Z',
    'updatedAt': '2024-01-15T10:00:00.000Z',
    'boardBackground': 'full',
    'orderIndex': 3,
  };

  final v1CollectionJson = <String, dynamic>{
    '_id': 'coll-1',
    'name': 'Test Collection',
    'userId': 'user-1',
    'animations': [v1AnimationJson],
    'createdAt': '2024-01-15T10:00:00.000Z',
    'updatedAt': '2024-01-15T10:00:00.000Z',
    'orderIndex': 1,
  };

  // ===========================================================================
  // TrajectoryDataV2
  // ===========================================================================

  group('TrajectoryDataV2', () {
    test('fromJson parses V1 trajectory data', () {
      final data = TrajectoryDataV2.fromJson(v1TrajectoryDataJson);

      expect(data.componentTrajectories.length, 1);
      expect(data.hasTrajectory('comp-player-1'), true);
      expect(data.hasAnyTrajectories, true);

      final traj = data.getTrajectory('comp-player-1')!;
      expect(traj.pathType, PathType.catmullRom);
      expect(traj.trajectoryType, TrajectoryType.running);
      expect(traj.lineStyle, TrajectoryLineStyle.dashed);
      expect(traj.enabled, true);
      expect(traj.controlPoints.length, 2);
      expect(traj.isCustomPath, true);
    });

    test('ControlPointV2 parses position and type', () {
      final cp = ControlPointV2.fromJson({
        'id': 'cp-test',
        'position': {'x': 0.3, 'y': 0.4},
        'type': 'sharp',
        'tension': 0.7,
      });

      expect(cp.id, 'cp-test');
      expect(cp.position, const Offset(0.3, 0.4));
      expect(cp.type, ControlPointType.sharp);
      expect(cp.tension, 0.7);
    });

    test('TrajectoryPathV2 speedMultiplier delegates to enum', () {
      final path = TrajectoryPathV2(
        trajectoryType: TrajectoryType.shooting,
        enabled: true,
        pathType: PathType.catmullRom,
      );

      expect(path.speedMultiplier, 2.5);
    });

    test('setTrajectory returns new instance', () {
      final data = TrajectoryDataV2.empty();
      final newPath = TrajectoryPathV2(
        enabled: true,
        pathType: PathType.catmullRom,
      );

      final updated = data.setTrajectory('comp-1', newPath);

      expect(data.componentTrajectories.isEmpty, true);
      expect(updated.componentTrajectories.length, 1);
      expect(updated.getTrajectory('comp-1'), newPath);
    });

    test('removeTrajectory returns new instance', () {
      final data = TrajectoryDataV2.fromJson(v1TrajectoryDataJson);
      final removed = data.removeTrajectory('comp-player-1');

      expect(data.componentTrajectories.length, 1);
      expect(removed.componentTrajectories.isEmpty, true);
    });

    test('toJson round-trip preserves all fields', () {
      final original = TrajectoryDataV2.fromJson(v1TrajectoryDataJson);
      final json = original.toJson();
      final restored = TrajectoryDataV2.fromJson(json);

      expect(restored, original);
    });

    test('equality works', () {
      final a = TrajectoryDataV2.fromJson(v1TrajectoryDataJson);
      final b = TrajectoryDataV2.fromJson(v1TrajectoryDataJson);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  // ===========================================================================
  // SceneModelV2
  // ===========================================================================

  group('SceneModelV2', () {
    test('fromJson parses V1 scene JSON', () {
      final scene = SceneModelV2.fromJson(v1SceneJson);

      expect(scene.id, 'scene-1');
      expect(scene.index, 0);
      expect(scene.components.length, 2);
      expect(scene.fieldColor, const Color(0xFF9E9E9E));
      expect(scene.userId, 'user-1');
      expect(scene.fieldSize, const Size(1050.0, 680.0));
      expect(scene.sceneDuration, const Duration(milliseconds: 3000));
      expect(scene.boardBackground, BoardBackground.full);
      expect(scene.trajectoryData, isNotNull);
    });

    test('fromJson handles both id and _id keys', () {
      final withId = SceneModelV2.fromJson(v1SceneJson);
      expect(withId.id, 'scene-1');

      final jsonWithUnderscore = Map<String, dynamic>.from(v1SceneJson);
      jsonWithUnderscore.remove('id');
      jsonWithUnderscore['_id'] = 'scene-alt';
      final withUnderscore = SceneModelV2.fromJson(jsonWithUnderscore);
      expect(withUnderscore.id, 'scene-alt');
    });

    test('fromJson defaults sceneDuration to 2 seconds', () {
      final json = Map<String, dynamic>.from(v1SceneJson);
      json.remove('sceneDurationMilliseconds');

      final scene = SceneModelV2.fromJson(json);
      expect(scene.sceneDuration, const Duration(seconds: 2));
    });

    test('fromJson defaults fieldSize to 1050x680', () {
      final json = Map<String, dynamic>.from(v1SceneJson);
      json.remove('fieldSize');

      final scene = SceneModelV2.fromJson(json);
      expect(scene.fieldSize, const Size(1050.0, 680.0));
    });

    test('fromJson skips malformed components', () {
      final json = Map<String, dynamic>.from(v1SceneJson);
      json['components'] = [
        v1PlayerComponentJson,
        {'bad': 'data'}, // malformed — missing fieldItemType
        v1EquipmentComponentJson,
      ];

      final scene = SceneModelV2.fromJson(json);
      expect(scene.components.length, 2); // malformed one skipped
    });

    test('toJson only includes trajectoryData when present', () {
      final sceneWithTraj = SceneModelV2.fromJson(v1SceneJson);
      final jsonWith = sceneWithTraj.toJson();
      expect(jsonWith.containsKey('trajectoryData'), true);

      final sceneWithout = SceneModelV2.fromJson(v1SceneJson2);
      final jsonWithout = sceneWithout.toJson();
      expect(jsonWithout.containsKey('trajectoryData'), false);
    });

    test('toJson round-trip preserves all fields', () {
      final original = SceneModelV2.fromJson(v1SceneJson);
      final json = original.toJson();
      final restored = SceneModelV2.fromJson(json);

      expect(restored, original);
    });

    test('components list is unmodifiable', () {
      final scene = SceneModelV2.fromJson(v1SceneJson);

      expect(
        () => (scene.components as List).add(
          BoardElement.fromJson(v1PlayerComponentJson),
        ),
        throwsUnsupportedError,
      );
    });

    test('SceneModelV2.empty creates default scene', () {
      final scene = SceneModelV2.empty(id: 'new-1', userId: 'u1');

      expect(scene.id, 'new-1');
      expect(scene.userId, 'u1');
      expect(scene.index, 0);
      expect(scene.components, isEmpty);
      expect(scene.fieldSize, const Size(1050.0, 680.0));
      expect(scene.sceneDuration, const Duration(seconds: 2));
    });

    test('copyWith clearTrajectoryData sets it to null', () {
      final scene = SceneModelV2.fromJson(v1SceneJson);
      expect(scene.trajectoryData, isNotNull);

      final cleared = scene.copyWith(clearTrajectoryData: true);
      expect(cleared.trajectoryData, null);
    });

    test('equality works', () {
      final a = SceneModelV2.fromJson(v1SceneJson);
      final b = SceneModelV2.fromJson(v1SceneJson);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  // ===========================================================================
  // AnimationModelV2
  // ===========================================================================

  group('AnimationModelV2', () {
    test('fromJson parses V1 animation JSON', () {
      final anim = AnimationModelV2.fromJson(v1AnimationJson);

      expect(anim.id, 'anim-1');
      expect(anim.name, 'Test Animation');
      expect(anim.userId, 'user-1');
      expect(anim.fieldColor, const Color(0xFF9E9E9E));
      expect(anim.collectionId, 'coll-1');
      expect(anim.animationScenes.length, 2);
      expect(anim.boardBackground, BoardBackground.full);
      expect(anim.orderIndex, 3);
      expect(anim.schemaVersion, 1); // V1 data has no schemaVersion
    });

    test('fromJson V1 migration: auto-assigns indices when missing', () {
      final scenesNoIndex = [
        Map<String, dynamic>.from(v1SceneJson)..remove('index'),
        Map<String, dynamic>.from(v1SceneJson2)..remove('index'),
      ];

      final json = Map<String, dynamic>.from(v1AnimationJson);
      json['animationScenes'] = scenesNoIndex;

      final anim = AnimationModelV2.fromJson(json);
      expect(anim.animationScenes[0].index, 0);
      expect(anim.animationScenes[1].index, 1);
    });

    test('fromJson sorts scenes by index', () {
      // Put scene with index 1 first, index 0 second
      final json = Map<String, dynamic>.from(v1AnimationJson);
      json['animationScenes'] = [v1SceneJson2, v1SceneJson]; // reversed

      final anim = AnimationModelV2.fromJson(json);
      expect(anim.animationScenes[0].index, 0);
      expect(anim.animationScenes[1].index, 1);
    });

    test('fromJson skips malformed scenes', () {
      final json = Map<String, dynamic>.from(v1AnimationJson);
      json['animationScenes'] = [
        v1SceneJson,
        'not a map', // should be skipped
        42, // should be skipped
        v1SceneJson2,
      ];

      final anim = AnimationModelV2.fromJson(json);
      expect(anim.animationScenes.length, 2);
    });

    test('toJson round-trip preserves all fields', () {
      final original = AnimationModelV2.fromJson(v1AnimationJson);
      final json = original.toJson();
      final restored = AnimationModelV2.fromJson(json);

      expect(restored, original);
    });

    test('schemaVersion defaults to 2 in constructor, 1 from V1 JSON', () {
      // fromJson with no schemaVersion → defaults to 1 (V1 data)
      final fromV1 = AnimationModelV2.fromJson(v1AnimationJson);
      expect(fromV1.schemaVersion, 1);

      // Constructor default is 2
      final now = DateTime.now();
      final fresh = AnimationModelV2(
        id: 'new',
        name: 'New',
        userId: 'u1',
        fieldColor: const Color(0xFF000000),
        animationScenes: [],
        createdAt: now,
        updatedAt: now,
      );
      expect(fresh.schemaVersion, 2);
    });

    test('animationScenes list is unmodifiable', () {
      final anim = AnimationModelV2.fromJson(v1AnimationJson);

      expect(
        () => (anim.animationScenes as List).add(
          SceneModelV2.empty(id: 'x', userId: 'u'),
        ),
        throwsUnsupportedError,
      );
    });

    test('copyWith allows setting collectionId to null via sentinel', () {
      final anim = AnimationModelV2.fromJson(v1AnimationJson);
      expect(anim.collectionId, 'coll-1');

      final nulled = anim.copyWith(collectionId: null);
      expect(nulled.collectionId, null);

      // Leaving it unchanged (no argument)
      final unchanged = anim.copyWith(name: 'Renamed');
      expect(unchanged.collectionId, 'coll-1');
    });

    test('clone creates deep copy', () {
      final original = AnimationModelV2.fromJson(v1AnimationJson);
      final cloned = original.clone();

      expect(cloned, original);
      expect(identical(cloned, original), false);
      expect(identical(cloned.animationScenes, original.animationScenes),
          false);
    });

    test('equality works', () {
      final a = AnimationModelV2.fromJson(v1AnimationJson);
      final b = AnimationModelV2.fromJson(v1AnimationJson);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  // ===========================================================================
  // AnimationCollectionModelV2
  // ===========================================================================

  group('AnimationCollectionModelV2', () {
    test('fromJson parses V1 collection JSON', () {
      final coll = AnimationCollectionModelV2.fromJson(v1CollectionJson);

      expect(coll.id, 'coll-1');
      expect(coll.name, 'Test Collection');
      expect(coll.userId, 'user-1');
      expect(coll.animations.length, 1);
      expect(coll.orderIndex, 1);
      expect(coll.isTemplate, false);
      expect(coll.hasPendingUpdates, false);
      expect(coll.schemaVersion, 1); // V1 data
    });

    test('fromJson skips malformed animations', () {
      final json = Map<String, dynamic>.from(v1CollectionJson);
      json['animations'] = [
        v1AnimationJson,
        'bad', // skipped
        42, // skipped
      ];

      final coll = AnimationCollectionModelV2.fromJson(json);
      expect(coll.animations.length, 1);
    });

    test('toJson round-trip preserves all fields', () {
      final original = AnimationCollectionModelV2.fromJson(v1CollectionJson);
      final json = original.toJson();
      final restored = AnimationCollectionModelV2.fromJson(json);

      expect(restored, original);
    });

    test('animations list is unmodifiable', () {
      final coll = AnimationCollectionModelV2.fromJson(v1CollectionJson);

      expect(
        () => (coll.animations as List).add(
          AnimationModelV2.fromJson(v1AnimationJson),
        ),
        throwsUnsupportedError,
      );
    });

    test('clone creates deep copy', () {
      final original = AnimationCollectionModelV2.fromJson(v1CollectionJson);
      final cloned = original.clone();

      expect(cloned, original);
      expect(identical(cloned, original), false);
    });

    test('equality works', () {
      final a = AnimationCollectionModelV2.fromJson(v1CollectionJson);
      final b = AnimationCollectionModelV2.fromJson(v1CollectionJson);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('V1 fields isTemplate and hasPendingUpdates parsed', () {
      final json = Map<String, dynamic>.from(v1CollectionJson);
      json['isTemplate'] = true;
      json['hasPendingUpdates'] = true;

      final coll = AnimationCollectionModelV2.fromJson(json);
      expect(coll.isTemplate, true);
      expect(coll.hasPendingUpdates, true);
    });
  });

  // ===========================================================================
  // Enums
  // ===========================================================================

  group('Enums', () {
    test('FieldItemType.fromString parses all types', () {
      expect(FieldItemType.fromString('PLAYER'), FieldItemType.PLAYER);
      expect(FieldItemType.fromString('EQUIPMENT'), FieldItemType.EQUIPMENT);
      expect(FieldItemType.fromString('LINE'), FieldItemType.LINE);
      expect(FieldItemType.fromString('FREEDRAW'), FieldItemType.FREEDRAW);
      expect(FieldItemType.fromString('CIRCLE'), FieldItemType.CIRCLE);
      expect(FieldItemType.fromString('SQUARE'), FieldItemType.SQUARE);
      expect(FieldItemType.fromString('TRIANGLE'), FieldItemType.TRIANGLE);
      expect(FieldItemType.fromString('POLYGON'), FieldItemType.POLYGON);
      expect(FieldItemType.fromString('TEXT'), FieldItemType.TEXT);
    });

    test('FieldItemType.fromString throws on unknown', () {
      expect(
        () => FieldItemType.fromString('UNKNOWN'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('PlayerType.fromString defaults to UNKNOWN', () {
      expect(PlayerType.fromString(null), PlayerType.UNKNOWN);
      expect(PlayerType.fromString('INVALID'), PlayerType.UNKNOWN);
      expect(PlayerType.fromString('HOME'), PlayerType.HOME);
    });

    test('BallSpin.fromString defaults to none', () {
      expect(BallSpin.fromString(null), BallSpin.none);
      expect(BallSpin.fromString('left'), BallSpin.left);
      expect(BallSpin.fromString('knuckleball'), BallSpin.knuckleball);
    });

    test('LineType.fromString defaults to UNKNOWN', () {
      expect(LineType.fromString(null), LineType.UNKNOWN);
      expect(LineType.fromString('PASS'), LineType.PASS);
      expect(LineType.fromString('SHOOT'), LineType.SHOOT);
    });

    test('BoardBackground.fromString defaults to full', () {
      expect(BoardBackground.fromString(null), BoardBackground.full);
      expect(BoardBackground.fromString('halfUp'), BoardBackground.halfUp);
      expect(BoardBackground.fromString('clean'), BoardBackground.clean);
    });

    test('TrajectoryType speed multipliers', () {
      expect(TrajectoryType.passing.speedMultiplier, 2.0);
      expect(TrajectoryType.shooting.speedMultiplier, 2.5);
      expect(TrajectoryType.dribbling.speedMultiplier, 1.2);
      expect(TrajectoryType.running.speedMultiplier, 1.5);
      expect(TrajectoryType.defending.speedMultiplier, 1.0);
    });

    test('PathType.fromString defaults to straight', () {
      expect(PathType.fromString(null), PathType.straight);
      expect(PathType.fromString('catmullRom'), PathType.catmullRom);
    });

    test('ControlPointType.fromString defaults to smooth', () {
      expect(ControlPointType.fromString(null), ControlPointType.smooth);
      expect(ControlPointType.fromString('sharp'), ControlPointType.sharp);
    });
  });
}
