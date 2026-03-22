import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/commands/board_command.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';

/// Test command that adds a component to a scene.
class AddComponentCommand extends BoardCommand {
  @override
  final String label;
  final BoardElement element;

  AddComponentCommand({required this.label, required this.element});

  @override
  SceneModelV2 execute(SceneModelV2 scene) {
    return scene.copyWith(
      components: [...scene.components, element],
    );
  }

  @override
  SceneModelV2 undo(SceneModelV2 scene) {
    return scene.copyWith(
      components: scene.components
          .where((c) => c.id != element.id)
          .toList(),
    );
  }
}

/// Test command that removes a component from a scene.
class RemoveComponentCommand extends BoardCommand {
  @override
  final String label;
  final String elementId;
  BoardElement? _removedElement;

  RemoveComponentCommand({required this.label, required this.elementId});

  @override
  SceneModelV2 execute(SceneModelV2 scene) {
    _removedElement = scene.components.firstWhere((c) => c.id == elementId);
    return scene.copyWith(
      components: scene.components
          .where((c) => c.id != elementId)
          .toList(),
    );
  }

  @override
  SceneModelV2 undo(SceneModelV2 scene) {
    if (_removedElement == null) return scene;
    return scene.copyWith(
      components: [...scene.components, _removedElement!],
    );
  }
}

void main() {
  late SceneModelV2 emptyScene;
  late PlayerElement testPlayer;

  setUp(() {
    emptyScene = SceneModelV2.empty(id: 'scene-1', userId: 'user-1');
    testPlayer = const PlayerElement(
      id: 'p1',
      role: 'ST',
      jerseyNumber: 9,
      playerType: PlayerType.HOME,
      offset: Offset(0.5, 0.3),
    );
  });

  // ===========================================================================
  // BoardCommand
  // ===========================================================================

  group('BoardCommand', () {
    test('execute adds element to scene', () {
      final cmd = AddComponentCommand(
        label: 'Add Player',
        element: testPlayer,
      );

      final result = cmd.execute(emptyScene);

      expect(result.components.length, 1);
      expect(result.components[0], testPlayer);
    });

    test('undo reverses execute', () {
      final cmd = AddComponentCommand(
        label: 'Add Player',
        element: testPlayer,
      );

      final after = cmd.execute(emptyScene);
      expect(after.components.length, 1);

      final reverted = cmd.undo(after);
      expect(reverted.components.length, 0);
    });
  });

  // ===========================================================================
  // CompositeCommand
  // ===========================================================================

  group('CompositeCommand', () {
    test('executes all sub-commands in order', () {
      final player2 = testPlayer.copyWith(id: 'p2', jerseyNumber: 10);

      final composite = CompositeCommand(
        label: 'Add Two Players',
        commands: [
          AddComponentCommand(label: 'Add P1', element: testPlayer),
          AddComponentCommand(label: 'Add P2', element: player2),
        ],
      );

      final result = composite.execute(emptyScene);
      expect(result.components.length, 2);
    });

    test('undo reverses all sub-commands in reverse order', () {
      final player2 = testPlayer.copyWith(id: 'p2', jerseyNumber: 10);

      final composite = CompositeCommand(
        label: 'Add Two Players',
        commands: [
          AddComponentCommand(label: 'Add P1', element: testPlayer),
          AddComponentCommand(label: 'Add P2', element: player2),
        ],
      );

      final after = composite.execute(emptyScene);
      final reverted = composite.undo(after);

      expect(reverted.components.length, 0);
    });

    test('commands list is unmodifiable', () {
      final composite = CompositeCommand(
        label: 'Test',
        commands: [
          AddComponentCommand(label: 'Add P1', element: testPlayer),
        ],
      );

      expect(
        () => (composite.commands as List).add(
          AddComponentCommand(label: 'Bad', element: testPlayer),
        ),
        throwsUnsupportedError,
      );
    });
  });

  // ===========================================================================
  // CommandHistory
  // ===========================================================================

  group('CommandHistory', () {
    test('starts empty', () {
      final history = CommandHistory();

      expect(history.canUndo, false);
      expect(history.canRedo, false);
      expect(history.undoCount, 0);
      expect(history.redoCount, 0);
    });

    test('execute pushes command onto undo stack', () {
      final history = CommandHistory();
      final cmd = AddComponentCommand(
        label: 'Add Player',
        element: testPlayer,
      );

      final result = history.execute(cmd, emptyScene);

      expect(result.components.length, 1);
      expect(history.canUndo, true);
      expect(history.canRedo, false);
      expect(history.undoCount, 1);
    });

    test('undo pops command and pushes to redo', () {
      final history = CommandHistory();
      final cmd = AddComponentCommand(
        label: 'Add Player',
        element: testPlayer,
      );

      final afterExec = history.execute(cmd, emptyScene);
      final afterUndo = history.undo(afterExec);

      expect(afterUndo, isNotNull);
      expect(afterUndo!.components.length, 0);
      expect(history.canUndo, false);
      expect(history.canRedo, true);
      expect(history.redoCount, 1);
    });

    test('redo re-applies undone command', () {
      final history = CommandHistory();
      final cmd = AddComponentCommand(
        label: 'Add Player',
        element: testPlayer,
      );

      final afterExec = history.execute(cmd, emptyScene);
      final afterUndo = history.undo(afterExec)!;
      final afterRedo = history.redo(afterUndo);

      expect(afterRedo, isNotNull);
      expect(afterRedo!.components.length, 1);
      expect(history.canUndo, true);
      expect(history.canRedo, false);
    });

    test('new execute clears redo stack', () {
      final history = CommandHistory();
      final cmd1 = AddComponentCommand(
        label: 'Add P1',
        element: testPlayer,
      );
      final cmd2 = AddComponentCommand(
        label: 'Add P2',
        element: testPlayer.copyWith(id: 'p2'),
      );

      final s1 = history.execute(cmd1, emptyScene);
      final s2 = history.undo(s1)!;
      expect(history.canRedo, true);

      // Execute a new command — redo should be cleared
      history.execute(cmd2, s2);
      expect(history.canRedo, false);
      expect(history.undoCount, 1); // only cmd2
    });

    test('undo returns null when stack is empty', () {
      final history = CommandHistory();

      expect(history.undo(emptyScene), null);
    });

    test('redo returns null when stack is empty', () {
      final history = CommandHistory();

      expect(history.redo(emptyScene), null);
    });

    test('respects maxHistorySize', () {
      final history = CommandHistory(maxHistorySize: 3);

      var scene = emptyScene;
      for (int i = 0; i < 5; i++) {
        final cmd = AddComponentCommand(
          label: 'Add P$i',
          element: testPlayer.copyWith(id: 'p$i'),
        );
        scene = history.execute(cmd, scene);
      }

      // Only last 3 commands should remain
      expect(history.undoCount, 3);
    });

    test('clear empties both stacks', () {
      final history = CommandHistory();
      final cmd = AddComponentCommand(
        label: 'Add Player',
        element: testPlayer,
      );

      final s1 = history.execute(cmd, emptyScene);
      history.undo(s1);

      history.clear();

      expect(history.canUndo, false);
      expect(history.canRedo, false);
    });

    test('multiple undo/redo operations work correctly', () {
      final history = CommandHistory();
      final p1 = testPlayer;
      final p2 = testPlayer.copyWith(id: 'p2', jerseyNumber: 10);
      final p3 = testPlayer.copyWith(id: 'p3', jerseyNumber: 7);

      // Execute 3 commands
      var scene = emptyScene;
      scene = history.execute(
        AddComponentCommand(label: 'Add P1', element: p1),
        scene,
      );
      scene = history.execute(
        AddComponentCommand(label: 'Add P2', element: p2),
        scene,
      );
      scene = history.execute(
        AddComponentCommand(label: 'Add P3', element: p3),
        scene,
      );

      expect(scene.components.length, 3);
      expect(history.undoCount, 3);

      // Undo twice
      scene = history.undo(scene)!;
      expect(scene.components.length, 2);
      scene = history.undo(scene)!;
      expect(scene.components.length, 1);

      expect(history.undoCount, 1);
      expect(history.redoCount, 2);

      // Redo once
      scene = history.redo(scene)!;
      expect(scene.components.length, 2);
      expect(history.undoCount, 2);
      expect(history.redoCount, 1);
    });
  });
}
