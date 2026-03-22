import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/commands/element_commands.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/models/equipment_element.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';

void main() {
  late SceneModelV2 emptyScene;
  late PlayerElement player1;
  late PlayerElement player2;
  late EquipmentElement equipment1;

  setUp(() {
    emptyScene = SceneModelV2.empty(id: 'scene-1', userId: 'user-1');

    player1 = const PlayerElement(
      id: 'p1',
      offset: Offset(0.3, 0.4),
      role: 'ST',
      jerseyNumber: 9,
      playerType: PlayerType.HOME,
      size: Size(0.04, 0.06),
      zIndex: 1,
    );

    player2 = const PlayerElement(
      id: 'p2',
      offset: Offset(0.6, 0.7),
      role: 'GK',
      jerseyNumber: 1,
      playerType: PlayerType.AWAY,
      size: Size(0.04, 0.06),
      zIndex: 2,
    );

    equipment1 = const EquipmentElement(
      id: 'e1',
      offset: Offset(0.5, 0.5),
      name: 'Ball',
      imagePath: 'assets/ball.png',
      size: Size(0.03, 0.03),
      zIndex: 0,
    );
  });

  group('AddElementCommand', () {
    test('adds element to empty scene', () {
      final cmd = AddElementCommand(player1);
      final result = cmd.execute(emptyScene);

      expect(result.components.length, 1);
      expect(result.components[0].id, 'p1');
    });

    test('adds element to scene with existing elements', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd = AddElementCommand(player2);
      final result = cmd.execute(scene);

      expect(result.components.length, 2);
      expect(result.components[1].id, 'p2');
    });

    test('undo removes the added element', () {
      final cmd = AddElementCommand(player1);
      final afterAdd = cmd.execute(emptyScene);
      final afterUndo = cmd.undo(afterAdd);

      expect(afterUndo.components.length, 0);
    });

    test('undo preserves other elements', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd = AddElementCommand(player2);
      final afterAdd = cmd.execute(scene);
      final afterUndo = cmd.undo(afterAdd);

      expect(afterUndo.components.length, 1);
      expect(afterUndo.components[0].id, 'p1');
    });

    test('label includes element type', () {
      final cmd = AddElementCommand(player1);
      expect(cmd.label, contains('PLAYER'));
    });
  });

  group('RemoveElementCommand', () {
    test('removes element from scene', () {
      final scene = emptyScene.copyWith(components: [player1, player2]);
      final cmd = RemoveElementCommand('p1');
      final result = cmd.execute(scene);

      expect(result.components.length, 1);
      expect(result.components[0].id, 'p2');
    });

    test('no-op when element not found', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd = RemoveElementCommand('nonexistent');
      final result = cmd.execute(scene);

      expect(result.components.length, 1);
    });

    test('undo restores element at original index', () {
      final scene =
          emptyScene.copyWith(components: [player1, player2, equipment1]);
      final cmd = RemoveElementCommand('p2');
      final afterRemove = cmd.execute(scene);
      expect(afterRemove.components.length, 2);

      final afterUndo = cmd.undo(afterRemove);
      expect(afterUndo.components.length, 3);
      expect(afterUndo.components[1].id, 'p2');
    });

    test('undo restores element properties', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd = RemoveElementCommand('p1');
      final afterRemove = cmd.execute(scene);
      final afterUndo = cmd.undo(afterRemove);

      final restored = afterUndo.components[0] as PlayerElement;
      expect(restored.role, 'ST');
      expect(restored.jerseyNumber, 9);
      expect(restored.offset, const Offset(0.3, 0.4));
    });
  });

  group('MoveElementCommand', () {
    test('moves element to new position', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd = MoveElementCommand(
        elementId: 'p1',
        newOffset: const Offset(0.8, 0.9),
      );
      final result = cmd.execute(scene);

      expect(result.components[0].offset, const Offset(0.8, 0.9));
    });

    test('no-op when element not found', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd = MoveElementCommand(
        elementId: 'nonexistent',
        newOffset: const Offset(0.8, 0.9),
      );
      final result = cmd.execute(scene);

      expect(result.components[0].offset, const Offset(0.3, 0.4));
    });

    test('undo restores original position', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd = MoveElementCommand(
        elementId: 'p1',
        newOffset: const Offset(0.8, 0.9),
      );
      final afterMove = cmd.execute(scene);
      final afterUndo = cmd.undo(afterMove);

      expect(afterUndo.components[0].offset, const Offset(0.3, 0.4));
    });

    test('preserves other element properties after move', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd = MoveElementCommand(
        elementId: 'p1',
        newOffset: const Offset(0.8, 0.9),
      );
      final result = cmd.execute(scene);

      final moved = result.components[0] as PlayerElement;
      expect(moved.role, 'ST');
      expect(moved.jerseyNumber, 9);
      expect(moved.zIndex, 1);
    });
  });

  group('UpdateElementCommand', () {
    test('replaces element with updated version', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final updated = player1.copyWith(role: 'CM', jerseyNumber: 8);
      final cmd = UpdateElementCommand(updated);
      final result = cmd.execute(scene);

      final p = result.components[0] as PlayerElement;
      expect(p.role, 'CM');
      expect(p.jerseyNumber, 8);
    });

    test('no-op when element not found', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final orphan = player2.copyWith(id: 'nonexistent');
      final cmd = UpdateElementCommand(orphan);
      final result = cmd.execute(scene);

      expect(result.components.length, 1);
      expect(result.components[0].id, 'p1');
    });

    test('undo restores previous version', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final updated = player1.copyWith(role: 'CM');
      final cmd = UpdateElementCommand(updated);
      final afterUpdate = cmd.execute(scene);
      final afterUndo = cmd.undo(afterUpdate);

      final p = afterUndo.components[0] as PlayerElement;
      expect(p.role, 'ST');
    });
  });

  group('ReorderElementCommand', () {
    test('changes element zIndex', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd = ReorderElementCommand(elementId: 'p1', newZIndex: 10);
      final result = cmd.execute(scene);

      expect(result.components[0].zIndex, 10);
    });

    test('undo restores original zIndex', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd = ReorderElementCommand(elementId: 'p1', newZIndex: 10);
      final afterReorder = cmd.execute(scene);
      final afterUndo = cmd.undo(afterReorder);

      expect(afterUndo.components[0].zIndex, 1);
    });

    test('no-op when element not found', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd =
          ReorderElementCommand(elementId: 'nonexistent', newZIndex: 10);
      final result = cmd.execute(scene);

      expect(result.components[0].zIndex, 1);
    });
  });

  group('BatchUpdateCommand', () {
    test('updates multiple elements at once', () {
      final scene =
          emptyScene.copyWith(components: [player1, player2, equipment1]);
      final updatedP1 = player1.copyWith(role: 'CB');
      final updatedP2 = player2.copyWith(role: 'LB');
      final cmd = BatchUpdateCommand(
        label: 'Update roles',
        updatedElements: [updatedP1, updatedP2],
      );
      final result = cmd.execute(scene);

      expect((result.components[0] as PlayerElement).role, 'CB');
      expect((result.components[1] as PlayerElement).role, 'LB');
      // Equipment unchanged
      expect(result.components[2].id, 'e1');
    });

    test('undo restores all elements to previous state', () {
      final scene =
          emptyScene.copyWith(components: [player1, player2, equipment1]);
      final updatedP1 = player1.copyWith(role: 'CB');
      final updatedP2 = player2.copyWith(role: 'LB');
      final cmd = BatchUpdateCommand(
        label: 'Update roles',
        updatedElements: [updatedP1, updatedP2],
      );
      final afterBatch = cmd.execute(scene);
      final afterUndo = cmd.undo(afterBatch);

      expect((afterUndo.components[0] as PlayerElement).role, 'ST');
      expect((afterUndo.components[1] as PlayerElement).role, 'GK');
    });

    test('ignores elements not in scene', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final orphan = player2.copyWith(id: 'nonexistent', role: 'XX');
      final cmd = BatchUpdateCommand(
        label: 'Update',
        updatedElements: [orphan],
      );
      final result = cmd.execute(scene);

      expect(result.components.length, 1);
      expect((result.components[0] as PlayerElement).role, 'ST');
    });
  });

  group('Command round-trips', () {
    test('add → undo → redo cycle', () {
      final cmd = AddElementCommand(player1);

      final afterAdd = cmd.execute(emptyScene);
      expect(afterAdd.components.length, 1);

      final afterUndo = cmd.undo(afterAdd);
      expect(afterUndo.components.length, 0);

      final afterRedo = cmd.execute(afterUndo);
      expect(afterRedo.components.length, 1);
      expect(afterRedo.components[0].id, 'p1');
    });

    test('remove → undo → redo cycle', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd = RemoveElementCommand('p1');

      final afterRemove = cmd.execute(scene);
      expect(afterRemove.components.length, 0);

      final afterUndo = cmd.undo(afterRemove);
      expect(afterUndo.components.length, 1);

      final afterRedo = cmd.execute(afterUndo);
      expect(afterRedo.components.length, 0);
    });

    test('move → undo → redo preserves positions', () {
      final scene = emptyScene.copyWith(components: [player1]);
      final cmd = MoveElementCommand(
        elementId: 'p1',
        newOffset: const Offset(0.9, 0.1),
      );

      final afterMove = cmd.execute(scene);
      expect(afterMove.components[0].offset, const Offset(0.9, 0.1));

      final afterUndo = cmd.undo(afterMove);
      expect(afterUndo.components[0].offset, const Offset(0.3, 0.4));

      final afterRedo = cmd.execute(afterUndo);
      expect(afterRedo.components[0].offset, const Offset(0.9, 0.1));
    });
  });
}
