import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/engine/playback_engine.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';

void main() {
  PlayerElement _player(String id, Offset offset) => PlayerElement(
        id: id,
        offset: offset,
        role: 'ST',
        jerseyNumber: 9,
        playerType: PlayerType.HOME,
        size: const Size(0.04, 0.06),
      );

  SceneModelV2 _scene(String id, int index, List<PlayerElement> players,
      {Duration duration = const Duration(seconds: 2)}) {
    return SceneModelV2.empty(id: id, userId: 'u1').copyWith(
      index: index,
      components: players,
      sceneDuration: duration,
    );
  }

  AnimationModelV2 _animation(List<SceneModelV2> scenes) {
    final now = DateTime.now();
    return AnimationModelV2(
      id: 'anim-1',
      name: 'Test',
      userId: 'u1',
      fieldColor: const Color(0xFF9E9E9E),
      animationScenes: scenes,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('PlaybackEngine - totalDuration', () {
    test('sums all scene durations', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.2, 0.3))],
              duration: const Duration(seconds: 2)),
          _scene('s1', 1, [_player('p1', const Offset(0.8, 0.7))],
              duration: const Duration(seconds: 3)),
        ]),
      );
      expect(engine.totalDuration, const Duration(seconds: 5));
    });

    test('empty animation has zero duration', () {
      final engine = PlaybackEngine(animation: _animation([]));
      expect(engine.totalDuration, Duration.zero);
    });

    test('single scene has that duration', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.5, 0.5))],
              duration: const Duration(seconds: 4)),
        ]),
      );
      expect(engine.totalDuration, const Duration(seconds: 4));
    });
  });

  group('PlaybackEngine - tick', () {
    test('advances elapsed time by delta * speed', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.2, 0.3))]),
          _scene('s1', 1, [_player('p1', const Offset(0.8, 0.7))]),
        ]),
      );

      engine.tick(const Duration(seconds: 1));
      expect(engine.elapsedTime, const Duration(seconds: 1));
    });

    test('isComplete when elapsed exceeds total', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.2, 0.3))],
              duration: const Duration(seconds: 1)),
          _scene('s1', 1, [_player('p1', const Offset(0.8, 0.7))],
              duration: const Duration(seconds: 1)),
        ]),
      );

      final frame = engine.tick(const Duration(seconds: 3));
      expect(frame.isComplete, true);
    });

    test('clamps elapsed to total duration', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.2, 0.3))],
              duration: const Duration(seconds: 2)),
        ]),
      );

      engine.tick(const Duration(seconds: 10));
      expect(engine.elapsedTime, const Duration(seconds: 2));
    });

    test('speed factor affects advancement', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.2, 0.3))]),
          _scene('s1', 1, [_player('p1', const Offset(0.8, 0.7))]),
        ]),
      );
      engine.setSpeed(2.0);
      engine.tick(const Duration(seconds: 1));
      expect(engine.elapsedTime, const Duration(seconds: 2));
    });

    test('multiple ticks accumulate', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.2, 0.3))]),
          _scene('s1', 1, [_player('p1', const Offset(0.8, 0.7))]),
        ]),
      );

      engine.tick(const Duration(milliseconds: 500));
      engine.tick(const Duration(milliseconds: 500));
      expect(engine.elapsedTime, const Duration(seconds: 1));
    });
  });

  group('PlaybackEngine - scene transitions', () {
    test('first scene has no interpolation', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.2, 0.3))]),
          _scene('s1', 1, [_player('p1', const Offset(0.8, 0.7))]),
        ]),
      );

      final frame = engine.seekToProgress(0.0);
      expect(frame.currentSceneIndex, 0);
      expect(frame.scene.components[0].offset!.dx, closeTo(0.2, 0.001));
    });

    test('transitions between scenes with interpolation', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.0, 0.0))],
              duration: const Duration(seconds: 2)),
          _scene('s1', 1, [_player('p1', const Offset(1.0, 1.0))],
              duration: const Duration(seconds: 2)),
        ]),
      );

      // At t=3s (1s into scene1, which is 50% of scene1's 2s duration)
      final frame = engine.seekToTime(const Duration(seconds: 3));
      expect(frame.currentSceneIndex, 1);
      expect(frame.scene.components[0].offset!.dx, closeTo(0.5, 0.01));
      expect(frame.scene.components[0].offset!.dy, closeTo(0.5, 0.01));
    });

    test('correct sceneIndex at various times', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.0, 0.0))],
              duration: const Duration(seconds: 2)),
          _scene('s1', 1, [_player('p1', const Offset(0.5, 0.5))],
              duration: const Duration(seconds: 2)),
          _scene('s2', 2, [_player('p1', const Offset(1.0, 1.0))],
              duration: const Duration(seconds: 2)),
        ]),
      );

      // t=1s → scene 0
      expect(
          engine.seekToTime(const Duration(seconds: 1)).currentSceneIndex, 0);
      // t=3s → scene 1
      expect(
          engine.seekToTime(const Duration(seconds: 3)).currentSceneIndex, 1);
      // t=5s → scene 2
      expect(
          engine.seekToTime(const Duration(seconds: 5)).currentSceneIndex, 2);
    });
  });

  group('PlaybackEngine - seekToProgress', () {
    test('0.0 seeks to beginning', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.2, 0.3))]),
          _scene('s1', 1, [_player('p1', const Offset(0.8, 0.7))]),
        ]),
      );

      final frame = engine.seekToProgress(0.0);
      expect(frame.progress, closeTo(0.0, 0.001));
      expect(frame.currentSceneIndex, 0);
    });

    test('1.0 seeks to end', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.2, 0.3))]),
          _scene('s1', 1, [_player('p1', const Offset(0.8, 0.7))]),
        ]),
      );

      final frame = engine.seekToProgress(1.0);
      expect(frame.progress, closeTo(1.0, 0.001));
      expect(frame.isComplete, true);
    });

    test('clamps out-of-range values', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.2, 0.3))]),
        ]),
      );

      engine.seekToProgress(5.0);
      expect(engine.currentProgress, closeTo(1.0, 0.001));

      engine.seekToProgress(-1.0);
      expect(engine.currentProgress, closeTo(0.0, 0.001));
    });
  });

  group('PlaybackEngine - speed', () {
    test('setSpeed(2.0) doubles tick advancement', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.0, 0.0))],
              duration: const Duration(seconds: 4)),
          _scene('s1', 1, [_player('p1', const Offset(1.0, 1.0))],
              duration: const Duration(seconds: 4)),
        ]),
      );

      engine.setSpeed(2.0);
      engine.tick(const Duration(seconds: 2));
      // 2s * 2.0 speed = 4s elapsed
      expect(engine.elapsedTime, const Duration(seconds: 4));
      expect(engine.currentProgress, closeTo(0.5, 0.001));
    });

    test('setSpeed(0.5) halves advancement', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.0, 0.0))],
              duration: const Duration(seconds: 4)),
        ]),
      );

      engine.setSpeed(0.5);
      engine.tick(const Duration(seconds: 2));
      // 2s * 0.5 speed = 1s elapsed
      expect(engine.elapsedTime, const Duration(seconds: 1));
    });

    test('speed clamps to valid range', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', Offset.zero)]),
        ]),
      );

      engine.setSpeed(0.0);
      expect(engine.speedFactor, 0.1);

      engine.setSpeed(100.0);
      expect(engine.speedFactor, 10.0);
    });
  });

  group('PlaybackEngine - reset', () {
    test('resets elapsed time to zero', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.2, 0.3))]),
          _scene('s1', 1, [_player('p1', const Offset(0.8, 0.7))]),
        ]),
      );

      engine.tick(const Duration(seconds: 2));
      expect(engine.elapsedTime.inSeconds, greaterThan(0));

      final frame = engine.reset();
      expect(engine.elapsedTime, Duration.zero);
      expect(frame.progress, closeTo(0.0, 0.001));
    });
  });

  group('PlaybackEngine - edge cases', () {
    test('empty animation returns complete immediately', () {
      final engine = PlaybackEngine(animation: _animation([]));
      final frame = engine.tick(const Duration(seconds: 1));
      expect(frame.isComplete, true);
    });

    test('single scene returns that scene (no interpolation)', () {
      final engine = PlaybackEngine(
        animation: _animation([
          _scene('s0', 0, [_player('p1', const Offset(0.5, 0.5))]),
        ]),
      );

      final frame = engine.tick(const Duration(milliseconds: 500));
      expect(frame.scene.components[0].offset!.dx, closeTo(0.5, 0.001));
      expect(frame.currentSceneIndex, 0);
    });
  });
}
