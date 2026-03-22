import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/engine/scene_interpolator.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/models/equipment_element.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/models/trajectory_model.dart';

void main() {
  late SceneModelV2 sceneA;
  late SceneModelV2 sceneB;

  setUp(() {
    sceneA = SceneModelV2.empty(id: 'scene-a', userId: 'u1').copyWith(
      components: [
        const PlayerElement(
          id: 'p1',
          offset: Offset(0.2, 0.3),
          role: 'ST',
          jerseyNumber: 9,
          playerType: PlayerType.HOME,
          size: Size(0.04, 0.06),
        ),
        const PlayerElement(
          id: 'p2',
          offset: Offset(0.5, 0.5),
          role: 'GK',
          jerseyNumber: 1,
          playerType: PlayerType.AWAY,
          size: Size(0.04, 0.06),
        ),
      ],
    );

    sceneB = SceneModelV2.empty(id: 'scene-b', userId: 'u1').copyWith(
      components: [
        const PlayerElement(
          id: 'p1',
          offset: Offset(0.8, 0.7),
          role: 'ST',
          jerseyNumber: 9,
          playerType: PlayerType.HOME,
          size: Size(0.04, 0.06),
        ),
        const PlayerElement(
          id: 'p2',
          offset: Offset(0.5, 0.1),
          role: 'GK',
          jerseyNumber: 1,
          playerType: PlayerType.AWAY,
          size: Size(0.04, 0.06),
        ),
      ],
    );
  });

  group('SceneInterpolator - basic interpolation', () {
    test('progress 0.0 returns from positions', () {
      final result = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneB,
        progress: 0.0,
      );

      expect(result.components[0].offset!.dx, closeTo(0.2, 0.001));
      expect(result.components[0].offset!.dy, closeTo(0.3, 0.001));
    });

    test('progress 1.0 returns to positions', () {
      final result = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneB,
        progress: 1.0,
      );

      expect(result.components[0].offset!.dx, closeTo(0.8, 0.001));
      expect(result.components[0].offset!.dy, closeTo(0.7, 0.001));
    });

    test('progress 0.5 returns midpoint', () {
      final result = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneB,
        progress: 0.5,
      );

      // p1: (0.2,0.3) → (0.8,0.7) midpoint = (0.5, 0.5)
      expect(result.components[0].offset!.dx, closeTo(0.5, 0.001));
      expect(result.components[0].offset!.dy, closeTo(0.5, 0.001));

      // p2: (0.5,0.5) → (0.5,0.1) midpoint = (0.5, 0.3)
      expect(result.components[1].offset!.dx, closeTo(0.5, 0.001));
      expect(result.components[1].offset!.dy, closeTo(0.3, 0.001));
    });

    test('clamps progress to 0.0-1.0', () {
      final result = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneB,
        progress: 1.5,
      );
      expect(result.components[0].offset!.dx, closeTo(0.8, 0.001));

      final result2 = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneB,
        progress: -0.5,
      );
      expect(result2.components[0].offset!.dx, closeTo(0.2, 0.001));
    });
  });

  group('SceneInterpolator - element lifecycle', () {
    test('elements only in to appear at their position', () {
      final sceneBWithNew = sceneB.copyWith(
        components: [
          ...sceneB.components,
          const EquipmentElement(
            id: 'e-new',
            offset: Offset(0.9, 0.9),
            name: 'Ball',
            imagePath: '',
            size: Size(0.03, 0.03),
          ),
        ],
      );

      final result = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneBWithNew,
        progress: 0.5,
      );

      expect(result.components.length, 3);
      // New element appears at its target position (no interpolation)
      final newEl = result.components.firstWhere((c) => c.id == 'e-new');
      expect(newEl.offset!.dx, closeTo(0.9, 0.001));
      expect(newEl.offset!.dy, closeTo(0.9, 0.001));
    });

    test('elements only in from are omitted', () {
      final sceneBWithout = sceneB.copyWith(
        components: [sceneB.components[0]], // only p1, not p2
      );

      final result = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneBWithout,
        progress: 0.5,
      );

      expect(result.components.length, 1);
      expect(result.components[0].id, 'p1');
    });
  });

  group('SceneInterpolator - properties', () {
    test('non-position properties come from to scene', () {
      final sceneBUpdated = sceneB.copyWith(
        components: [
          const PlayerElement(
            id: 'p1',
            offset: Offset(0.8, 0.7),
            role: 'CM', // changed from ST
            jerseyNumber: 8, // changed from 9
            playerType: PlayerType.HOME,
            size: Size(0.04, 0.06),
          ),
          sceneB.components[1],
        ],
      );

      final result = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneBUpdated,
        progress: 0.5,
      );

      final p1 = result.components[0] as PlayerElement;
      expect(p1.role, 'CM'); // from 'to'
      expect(p1.jerseyNumber, 8); // from 'to'
      // But position is interpolated
      expect(p1.offset!.dx, closeTo(0.5, 0.001));
    });

    test('scene metadata comes from to scene', () {
      final result = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneB,
        progress: 0.5,
      );

      expect(result.id, 'scene-b');
    });

    test('preserves element order from to scene', () {
      final sceneBReversed = sceneB.copyWith(
        components: [sceneB.components[1], sceneB.components[0]],
      );

      final result = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneBReversed,
        progress: 0.5,
      );

      expect(result.components[0].id, 'p2');
      expect(result.components[1].id, 'p1');
    });
  });

  group('SceneInterpolator - trajectory paths', () {
    test('uses trajectory path when available and enabled', () {
      final trajectory = TrajectoryPathV2(
        pathType: PathType.catmullRom,
        enabled: true,
        controlPoints: [
          ControlPointV2(position: const Offset(0.5, 0.8)),
        ],
      );

      final sceneBWithTrajectory = sceneB.copyWith(
        trajectoryData: TrajectoryDataV2(
          componentTrajectories: {'p1': trajectory},
        ),
      );

      final straight = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneB,
        progress: 0.5,
      );

      final curved = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneBWithTrajectory,
        progress: 0.5,
      );

      // Curved path should differ from straight path at midpoint
      final straightPos = straight.components[0].offset!;
      final curvedPos = curved.components[0].offset!;
      final distance = (straightPos - curvedPos).distance;
      expect(distance, greaterThan(0.01));
    });

    test('ignores trajectory when disabled', () {
      final trajectory = TrajectoryPathV2(
        pathType: PathType.catmullRom,
        enabled: false, // disabled
        controlPoints: [
          ControlPointV2(position: const Offset(0.5, 0.8)),
        ],
      );

      final sceneBWithDisabled = sceneB.copyWith(
        trajectoryData: TrajectoryDataV2(
          componentTrajectories: {'p1': trajectory},
        ),
      );

      final straight = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneB,
        progress: 0.5,
      );

      final withDisabled = SceneInterpolator.interpolate(
        from: sceneA,
        to: sceneBWithDisabled,
        progress: 0.5,
      );

      // Should be the same as straight (trajectory disabled)
      expect(
        withDisabled.components[0].offset!.dx,
        closeTo(straight.components[0].offset!.dx, 0.001),
      );
    });
  });

  group('SceneInterpolator - edge cases', () {
    test('empty scenes produce empty result', () {
      final emptyA = SceneModelV2.empty(id: 'a', userId: 'u');
      final emptyB = SceneModelV2.empty(id: 'b', userId: 'u');

      final result = SceneInterpolator.interpolate(
        from: emptyA,
        to: emptyB,
        progress: 0.5,
      );

      expect(result.components, isEmpty);
    });

    test('element with null offset in from uses to position', () {
      final sceneANull = sceneA.copyWith(
        components: [
          const PlayerElement(
            id: 'p1',
            offset: null,
            role: 'ST',
            jerseyNumber: 9,
            playerType: PlayerType.HOME,
          ),
        ],
      );

      final result = SceneInterpolator.interpolate(
        from: sceneANull,
        to: sceneB,
        progress: 0.5,
      );

      // Can't interpolate null offset — uses 'to' position
      expect(result.components[0].offset!.dx, closeTo(0.8, 0.001));
    });
  });
}
