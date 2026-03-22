import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/state/animation_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';

void main() {
  late BoardNotifier boardNotifier;
  late AnimationNotifier animNotifier;
  late SceneModelV2 editingScene;
  late AnimationModelV2 animation;

  setUp(() {
    editingScene = SceneModelV2.empty(id: 'editing', userId: 'u1').copyWith(
      components: [
        const PlayerElement(
          id: 'edit-p1',
          offset: Offset(0.1, 0.1),
          role: 'GK',
          jerseyNumber: 1,
          playerType: PlayerType.HOME,
        ),
      ],
    );

    boardNotifier = BoardNotifier(
      initialState: BoardStateV2(currentScene: editingScene),
    );

    final now = DateTime.now();
    animation = AnimationModelV2(
      id: 'anim-1',
      name: 'Test Animation',
      userId: 'u1',
      fieldColor: const Color(0xFF9E9E9E),
      animationScenes: [
        SceneModelV2.empty(id: 's0', userId: 'u1').copyWith(
          index: 0,
          components: [
            const PlayerElement(
              id: 'p1',
              offset: Offset(0.2, 0.3),
              role: 'ST',
              jerseyNumber: 9,
              playerType: PlayerType.HOME,
            ),
          ],
          sceneDuration: const Duration(seconds: 2),
        ),
        SceneModelV2.empty(id: 's1', userId: 'u1').copyWith(
          index: 1,
          components: [
            const PlayerElement(
              id: 'p1',
              offset: Offset(0.8, 0.7),
              role: 'ST',
              jerseyNumber: 9,
              playerType: PlayerType.HOME,
            ),
          ],
          sceneDuration: const Duration(seconds: 2),
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    animNotifier = AnimationNotifier(boardNotifier: boardNotifier);
  });

  tearDown(() {
    animNotifier.dispose();
    boardNotifier.dispose();
  });

  group('AnimationNotifier - initial state', () {
    test('starts in stopped state', () {
      expect(animNotifier.state.isStopped, true);
      expect(animNotifier.state.animation, isNull);
    });

    test('loadAnimation sets animation', () {
      animNotifier.loadAnimation(animation);
      expect(animNotifier.state.animation, isNotNull);
      expect(animNotifier.state.animation!.id, 'anim-1');
      expect(animNotifier.state.isStopped, true);
    });
  });

  group('AnimationNotifier - play/pause/stop', () {
    test('play transitions to playing', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();

      expect(animNotifier.state.isPlaying, true);
      expect(animNotifier.state.progress, closeTo(0.0, 0.001));
    });

    test('play without animation is a no-op', () {
      animNotifier.play();
      expect(animNotifier.state.isStopped, true);
    });

    test('pause transitions to paused', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();
      animNotifier.pause();

      expect(animNotifier.state.isPaused, true);
    });

    test('resume from paused continues', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();
      animNotifier.pause();
      animNotifier.resume();

      expect(animNotifier.state.isPlaying, true);
    });

    test('stop transitions to stopped', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();
      animNotifier.stop();

      expect(animNotifier.state.isStopped, true);
      expect(animNotifier.state.progress, closeTo(0.0, 0.001));
    });
  });

  group('AnimationNotifier - scene save/restore', () {
    test('play saves editing scene', () {
      // Board has editing scene
      expect(boardNotifier.state.currentScene.id, 'editing');

      animNotifier.loadAnimation(animation);
      animNotifier.play();

      // Board now has animation scene
      expect(boardNotifier.state.currentScene.id, isNot('editing'));
    });

    test('stop restores editing scene', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();
      animNotifier.stop();

      // Board should be restored to editing scene
      expect(boardNotifier.state.currentScene.id, 'editing');
      expect(boardNotifier.state.components[0].id, 'edit-p1');
    });

    test('animation completion restores editing scene', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();

      // Tick past the total duration (4 seconds)
      animNotifier.onTick(const Duration(seconds: 5));

      expect(animNotifier.state.isStopped, true);
      expect(boardNotifier.state.currentScene.id, 'editing');
    });
  });

  group('AnimationNotifier - onTick', () {
    test('returns false when not playing', () {
      expect(
        animNotifier.onTick(const Duration(milliseconds: 16)),
        false,
      );
    });

    test('returns true while playing', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();

      expect(
        animNotifier.onTick(const Duration(milliseconds: 500)),
        true,
      );
    });

    test('updates board scene on tick', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();

      // Tick 1 second into a 4-second animation
      animNotifier.onTick(const Duration(seconds: 1));

      // Board scene should reflect animation state
      expect(animNotifier.state.progress, greaterThan(0.0));
      expect(animNotifier.state.progress, lessThan(1.0));
    });

    test('returns false when animation completes', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();

      // Tick past total duration
      final result = animNotifier.onTick(const Duration(seconds: 10));

      expect(result, false);
      expect(animNotifier.state.isStopped, true);
    });

    test('updates progress and sceneIndex', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();

      // Tick 3 seconds (1s into scene 1)
      animNotifier.onTick(const Duration(seconds: 3));

      expect(animNotifier.state.currentSceneIndex, 1);
      expect(animNotifier.state.progress, closeTo(0.75, 0.05));
    });
  });

  group('AnimationNotifier - scrubbing', () {
    test('beginScrubbing sets scrubbing state', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();
      animNotifier.beginScrubbing();

      expect(animNotifier.state.isScrubbing, true);
    });

    test('seekToProgress updates progress during scrubbing', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();
      animNotifier.beginScrubbing();

      animNotifier.seekToProgress(0.5);
      expect(animNotifier.state.progress, closeTo(0.5, 0.01));
    });

    test('endScrubbing transitions to paused', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();
      animNotifier.beginScrubbing();
      animNotifier.endScrubbing();

      expect(animNotifier.state.isPaused, true);
    });
  });

  group('AnimationNotifier - speed', () {
    test('setSpeed updates speed factor', () {
      animNotifier.setSpeed(2.0);
      expect(animNotifier.state.speedFactor, 2.0);
    });

    test('speed affects tick advancement', () {
      animNotifier.loadAnimation(animation);
      animNotifier.setSpeed(2.0);
      animNotifier.play();

      // 1 second at 2x speed = 2 seconds of animation
      animNotifier.onTick(const Duration(seconds: 1));

      // Should be at 50% of 4-second animation
      expect(animNotifier.state.progress, closeTo(0.5, 0.05));
    });

    test('speed clamps to valid range', () {
      animNotifier.setSpeed(0.0);
      expect(animNotifier.state.speedFactor, 0.1);

      animNotifier.setSpeed(100.0);
      expect(animNotifier.state.speedFactor, 10.0);
    });
  });

  group('AnimationNotifier - isActive', () {
    test('isActive false when stopped', () {
      expect(animNotifier.state.isActive, false);
    });

    test('isActive true when playing', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();
      expect(animNotifier.state.isActive, true);
    });

    test('isActive true when paused', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();
      animNotifier.pause();
      expect(animNotifier.state.isActive, true);
    });

    test('isActive true when scrubbing', () {
      animNotifier.loadAnimation(animation);
      animNotifier.play();
      animNotifier.beginScrubbing();
      expect(animNotifier.state.isActive, true);
    });
  });
}
