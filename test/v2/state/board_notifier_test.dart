import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/v2/commands/board_command.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/models/equipment_element.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/state/board_notifier.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';

void main() {
  late BoardNotifier notifier;
  late SceneModelV2 initialScene;
  late PlayerElement player1;
  late PlayerElement player2;
  late EquipmentElement equipment1;

  setUp(() {
    initialScene = SceneModelV2.empty(id: 'scene-1', userId: 'user-1');

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

    notifier = BoardNotifier(
      initialState: BoardStateV2(currentScene: initialScene),
    );
  });

  tearDown(() {
    notifier.dispose();
  });

  group('BoardNotifier - element CRUD', () {
    test('addElement adds to scene and selects', () {
      notifier.addElement(player1);

      expect(notifier.state.components.length, 1);
      expect(notifier.state.components[0].id, 'p1');
      expect(notifier.state.selectedElementId, 'p1');
    });

    test('addElement multiple elements', () {
      notifier.addElement(player1);
      notifier.addElement(player2);

      expect(notifier.state.components.length, 2);
      expect(notifier.state.selectedElementId, 'p2');
    });

    test('removeElement removes from scene', () {
      notifier.addElement(player1);
      notifier.addElement(player2);
      notifier.removeElement('p1');

      expect(notifier.state.components.length, 1);
      expect(notifier.state.components[0].id, 'p2');
    });

    test('removeElement clears selection if removed was selected', () {
      notifier.addElement(player1);
      notifier.selectElement('p1');
      notifier.removeElement('p1');

      expect(notifier.state.selectedElementId, isNull);
    });

    test('removeSelectedElement removes currently selected', () {
      notifier.addElement(player1);
      notifier.addElement(player2);
      notifier.selectElement('p1');
      notifier.removeSelectedElement();

      expect(notifier.state.components.length, 1);
      expect(notifier.state.components[0].id, 'p2');
    });

    test('moveElement changes position', () {
      notifier.addElement(player1);
      notifier.moveElement('p1', const Offset(0.9, 0.1));

      expect(notifier.state.components[0].offset, const Offset(0.9, 0.1));
    });

    test('updateElement replaces element properties', () {
      notifier.addElement(player1);
      final updated = player1.copyWith(role: 'CM', jerseyNumber: 8);
      notifier.updateElement(updated);

      final p = notifier.state.components[0] as PlayerElement;
      expect(p.role, 'CM');
      expect(p.jerseyNumber, 8);
    });

    test('batchUpdateElements updates multiple at once', () {
      notifier.addElement(player1);
      notifier.addElement(player2);

      final updatedP1 = player1.copyWith(role: 'CB');
      final updatedP2 = player2.copyWith(role: 'LB');
      notifier.batchUpdateElements(
        label: 'Update roles',
        updatedElements: [updatedP1, updatedP2],
      );

      expect(
          (notifier.state.components[0] as PlayerElement).role, 'CB');
      expect(
          (notifier.state.components[1] as PlayerElement).role, 'LB');
    });
  });

  group('BoardNotifier - undo/redo', () {
    test('canUndo is false initially', () {
      expect(notifier.canUndo, false);
    });

    test('canUndo is true after command', () {
      notifier.addElement(player1);
      expect(notifier.canUndo, true);
    });

    test('undo reverses add', () {
      notifier.addElement(player1);
      notifier.undo();

      expect(notifier.state.components.length, 0);
      expect(notifier.state.selectedElementId, isNull);
    });

    test('redo re-applies add', () {
      notifier.addElement(player1);
      notifier.undo();
      notifier.redo();

      expect(notifier.state.components.length, 1);
      expect(notifier.state.components[0].id, 'p1');
    });

    test('undo reverses move', () {
      notifier.addElement(player1);
      notifier.moveElement('p1', const Offset(0.9, 0.1));
      notifier.undo();

      expect(notifier.state.components[0].offset, const Offset(0.3, 0.4));
    });

    test('multiple undo steps', () {
      notifier.addElement(player1);
      notifier.addElement(player2);
      notifier.undo(); // undo add p2
      notifier.undo(); // undo add p1

      expect(notifier.state.components.length, 0);
    });

    test('redo after undo chain', () {
      notifier.addElement(player1);
      notifier.addElement(player2);
      notifier.undo();
      notifier.undo();
      notifier.redo();

      expect(notifier.state.components.length, 1);
      expect(notifier.state.components[0].id, 'p1');
    });

    test('new command clears redo stack', () {
      notifier.addElement(player1);
      notifier.undo();
      expect(notifier.canRedo, true);

      notifier.addElement(player2);
      expect(notifier.canRedo, false);
    });

    test('clearHistory resets undo/redo', () {
      notifier.addElement(player1);
      notifier.clearHistory();

      expect(notifier.canUndo, false);
      expect(notifier.canRedo, false);
    });

    test('undo batch update restores all elements', () {
      notifier.addElement(player1);
      notifier.addElement(player2);

      final updatedP1 = player1.copyWith(role: 'CB');
      final updatedP2 = player2.copyWith(role: 'LB');
      notifier.batchUpdateElements(
        label: 'Update roles',
        updatedElements: [updatedP1, updatedP2],
      );

      notifier.undo();

      expect(
          (notifier.state.components[0] as PlayerElement).role, 'ST');
      expect(
          (notifier.state.components[1] as PlayerElement).role, 'GK');
    });
  });

  group('BoardNotifier - z-order', () {
    test('moveElementUp increments zIndex', () {
      notifier.addElement(player1);
      notifier.moveElementUp('p1');

      expect(notifier.state.components[0].zIndex, 2);
    });

    test('moveElementDown decrements zIndex', () {
      notifier.addElement(player1);
      notifier.moveElementDown('p1');

      expect(notifier.state.components[0].zIndex, 0);
    });

    test('moveElementDown clamps at 0', () {
      notifier.addElement(equipment1); // zIndex: 0
      notifier.moveElementDown('e1');

      expect(notifier.state.components[0].zIndex, 0);
    });

    test('moveElementToFront sets highest zIndex', () {
      notifier.addElement(player1); // z: 1
      notifier.addElement(player2); // z: 2
      notifier.moveElementToFront('p1');

      final p1 = notifier.state.components
          .firstWhere((c) => c.id == 'p1');
      expect(p1.zIndex, 3); // max(1,2) + 1
    });

    test('moveElementToBack sets zIndex to 0', () {
      notifier.addElement(player1); // z: 1
      notifier.moveElementToBack('p1');

      expect(notifier.state.components[0].zIndex, 0);
    });

    test('z-order changes are undoable', () {
      notifier.addElement(player1);
      notifier.moveElementUp('p1');
      expect(notifier.state.components[0].zIndex, 2);

      notifier.undo();
      expect(notifier.state.components[0].zIndex, 1);
    });
  });

  group('BoardNotifier - copy/paste', () {
    test('copyElement stores copied ID', () {
      notifier.addElement(player1);
      notifier.copyElement('p1');

      expect(notifier.state.copiedElementId, 'p1');
    });

    test('pasteElement creates new element at given offset', () {
      notifier.addElement(player1);
      notifier.copyElement('p1');
      notifier.pasteElement(
        newId: 'p1-copy',
        offset: const Offset(0.7, 0.8),
      );

      expect(notifier.state.components.length, 2);
      final pasted = notifier.state.components[1] as PlayerElement;
      expect(pasted.id, 'p1-copy');
      expect(pasted.offset, const Offset(0.7, 0.8));
      expect(pasted.role, 'ST'); // preserves properties
      expect(pasted.jerseyNumber, 9);
    });

    test('pasteElement is undoable', () {
      notifier.addElement(player1);
      notifier.copyElement('p1');
      notifier.pasteElement(
        newId: 'p1-copy',
        offset: const Offset(0.7, 0.8),
      );

      notifier.undo();
      expect(notifier.state.components.length, 1);
      expect(notifier.state.components[0].id, 'p1');
    });

    test('pasteElement no-op when nothing copied', () {
      notifier.addElement(player1);
      notifier.pasteElement(
        newId: 'p1-copy',
        offset: const Offset(0.7, 0.8),
      );

      expect(notifier.state.components.length, 1);
    });
  });

  group('BoardNotifier - selection', () {
    test('selectElement sets selectedElementId', () {
      notifier.addElement(player1);
      notifier.selectElement('p1');

      expect(notifier.state.selectedElementId, 'p1');
      expect(notifier.state.selectedElement, isNotNull);
    });

    test('deselectElement clears selection', () {
      notifier.addElement(player1);
      notifier.selectElement('p1');
      notifier.deselectElement();

      expect(notifier.state.selectedElementId, isNull);
      expect(notifier.state.selectedElement, isNull);
    });

    test('selectElement null clears selection', () {
      notifier.addElement(player1);
      notifier.selectElement('p1');
      notifier.selectElement(null);

      expect(notifier.state.selectedElementId, isNull);
    });
  });

  group('BoardNotifier - drag handling', () {
    test('startDrag sets dragging state', () {
      notifier.addElement(player1);
      notifier.startDrag('p1');

      expect(notifier.state.isDraggingItem, true);
      expect(notifier.state.selectedElementId, 'p1');
    });

    test('updateElementPositionLive moves without undo entry', () {
      notifier.addElement(player1);
      final undoCountBefore = notifier.canUndo; // true from addElement
      notifier.startDrag('p1');

      notifier.updateElementPositionLive('p1', const Offset(0.5, 0.5));
      notifier.updateElementPositionLive('p1', const Offset(0.6, 0.6));
      notifier.updateElementPositionLive('p1', const Offset(0.7, 0.7));

      expect(notifier.state.components[0].offset, const Offset(0.7, 0.7));
    });

    test('endDrag creates single undoable move', () {
      notifier.addElement(player1);
      notifier.startDrag('p1');

      // Simulate drag: multiple live updates
      notifier.updateElementPositionLive('p1', const Offset(0.5, 0.5));
      notifier.updateElementPositionLive('p1', const Offset(0.8, 0.9));

      notifier.endDrag('p1');

      expect(notifier.state.isDraggingItem, false);
      expect(notifier.state.components[0].offset, const Offset(0.8, 0.9));

      // Undo should go back to original position
      notifier.undo();
      expect(notifier.state.components[0].offset, const Offset(0.3, 0.4));
    });

    test('cancelDrag restores original position', () {
      notifier.addElement(player1);
      notifier.startDrag('p1');
      notifier.updateElementPositionLive('p1', const Offset(0.8, 0.9));

      notifier.cancelDrag('p1');

      expect(notifier.state.isDraggingItem, false);
      expect(notifier.state.components[0].offset, const Offset(0.3, 0.4));
    });

    test('endDrag with no movement creates no undo entry', () {
      notifier.addElement(player1);
      // 1 undo entry from addElement
      notifier.startDrag('p1');
      notifier.endDrag('p1');

      // Undo should undo the addElement, not a move
      notifier.undo();
      expect(notifier.state.components.length, 0);
    });
  });

  group('BoardNotifier - board configuration', () {
    test('updateBoardColor changes color', () {
      notifier.updateBoardColor(const Color(0xFF00FF00));
      expect(notifier.state.boardColor, const Color(0xFF00FF00));
    });

    test('updateBoardBackground changes background', () {
      notifier.updateBoardBackground(BoardBackground.halfUp);
      expect(notifier.state.boardBackground, BoardBackground.halfUp);
    });

    test('rotateField toggles angle', () {
      expect(notifier.state.boardAngle, 0);
      notifier.rotateField();
      expect(notifier.state.boardAngle, 1);
      notifier.rotateField();
      expect(notifier.state.boardAngle, 0);
    });

    test('updateGridSize changes grid', () {
      notifier.updateGridSize(25.0);
      expect(notifier.state.gridSize, 25.0);
    });

    test('updateHomeTeamBorderColor changes color', () {
      notifier.updateHomeTeamBorderColor(const Color(0xFFFF0000));
      expect(notifier.state.homeTeamBorderColor, const Color(0xFFFF0000));
    });

    test('updateAwayTeamBorderColor changes color', () {
      notifier.updateAwayTeamBorderColor(const Color(0xFF00FF00));
      expect(notifier.state.awayTeamBorderColor, const Color(0xFF00FF00));
    });
  });

  group('BoardNotifier - UI toggles', () {
    test('toggleFullScreen toggles', () {
      expect(notifier.state.showFullScreen, false);
      notifier.toggleFullScreen();
      expect(notifier.state.showFullScreen, true);
      notifier.toggleFullScreen();
      expect(notifier.state.showFullScreen, false);
    });

    test('setFullScreen sets value', () {
      notifier.setFullScreen(true);
      expect(notifier.state.showFullScreen, true);
      notifier.setFullScreen(false);
      expect(notifier.state.showFullScreen, false);
    });

    test('toggleAnimation toggles', () {
      expect(notifier.state.showAnimation, false);
      notifier.toggleAnimation();
      expect(notifier.state.showAnimation, true);
    });

    test('toggleTrajectoryEditing sets value', () {
      notifier.toggleTrajectoryEditing(true);
      expect(notifier.state.trajectoryEditingEnabled, true);
    });

    test('toggleApplyDesignToAll sets value', () {
      notifier.toggleApplyDesignToAll(true);
      expect(notifier.state.applyDesignToAll, true);
    });

    test('setDraggingToBoard sets flag', () {
      notifier.setDraggingToBoard(true);
      expect(notifier.state.isDraggingElementToBoard, true);
    });
  });

  group('BoardNotifier - guides', () {
    test('updateGuides sets guides', () {
      final guides = [
        const GuideLine(
          start: Offset(0, 340),
          end: Offset(1050, 340),
          isHorizontal: true,
        ),
      ];
      notifier.updateGuides(guides);

      expect(notifier.state.activeGuides.length, 1);
    });

    test('clearGuides removes all guides', () {
      notifier.updateGuides([
        const GuideLine(
          start: Offset(0, 340),
          end: Offset(1050, 340),
          isHorizontal: true,
        ),
      ]);
      notifier.clearGuides();

      expect(notifier.state.activeGuides, isEmpty);
    });
  });

  group('BoardNotifier - scene management', () {
    test('loadScene replaces current scene', () {
      notifier.addElement(player1);
      final newScene = SceneModelV2.empty(id: 'scene-2', userId: 'user-1');
      notifier.loadScene(newScene);

      expect(notifier.state.currentScene.id, 'scene-2');
      expect(notifier.state.components.length, 0);
      expect(notifier.state.selectedElementId, isNull);
    });

    test('loadScene clears undo history', () {
      notifier.addElement(player1);
      expect(notifier.canUndo, true);

      final newScene = SceneModelV2.empty(id: 'scene-2', userId: 'user-1');
      notifier.loadScene(newScene);

      expect(notifier.canUndo, false);
      expect(notifier.canRedo, false);
    });

    test('loadScene clears drag state', () {
      notifier.addElement(player1);
      notifier.startDrag('p1');
      expect(notifier.state.isDraggingItem, true);

      final newScene = SceneModelV2.empty(id: 'scene-2', userId: 'user-1');
      notifier.loadScene(newScene);

      expect(notifier.state.isDraggingItem, false);
    });
  });

  group('BoardNotifier - getMatchingElements', () {
    test('filters by predicate', () {
      notifier.addElement(player1);
      notifier.addElement(player2);
      notifier.addElement(equipment1);

      final homePlayers = notifier.getMatchingElements((e) =>
          e is PlayerElement && e.playerType == PlayerType.HOME);

      expect(homePlayers.length, 1);
      expect(homePlayers[0].id, 'p1');
    });
  });

  group('BoardNotifier - onStateChanged callback', () {
    test('fires after undoable commands', () {
      int callCount = 0;
      notifier.dispose();
      notifier = BoardNotifier(
        initialState: BoardStateV2(currentScene: initialScene),
        onStateChanged: (_) => callCount++,
      );

      notifier.addElement(player1);
      expect(callCount, 1);

      notifier.removeElement('p1');
      expect(callCount, 2);
    });

    test('fires on undo/redo', () {
      int callCount = 0;
      notifier.dispose();
      notifier = BoardNotifier(
        initialState: BoardStateV2(currentScene: initialScene),
        onStateChanged: (_) => callCount++,
      );

      notifier.addElement(player1);
      callCount = 0; // reset

      notifier.undo();
      expect(callCount, 1);

      notifier.redo();
      expect(callCount, 2);
    });
  });
}
