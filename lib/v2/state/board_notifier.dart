import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/v2/commands/board_command.dart';
import 'package:zporter_tactical_board/v2/commands/element_commands.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/state/board_state.dart';

/// StateNotifier for the V2 tactical board.
///
/// Replaces V1's [BoardController]. Uses the command pattern for
/// all undoable element operations (add, remove, move, update, reorder),
/// and direct state mutations for transient UI state (selection, drag,
/// guides, fullscreen, etc.).
///
/// Key difference from V1: move operations during drag are NOT
/// individually tracked. Only the final position (on drag end) creates
/// a command. Intermediate positions update the scene directly for
/// smooth visual feedback.
class BoardNotifier extends StateNotifier<BoardStateV2> {
  final CommandHistory _history;

  /// Callback invoked after every undoable command. Allows external
  /// persistence layers to react (e.g., auto-save to Firestore).
  final void Function(BoardStateV2 state)? onStateChanged;

  /// Captured when drag starts; used to create a single MoveElementCommand
  /// on drag end (start → end position delta).
  Offset? _dragStartOffset;

  /// Captured when resize starts; used to create a single undoable command.
  Size? _resizeStartSize;

  /// Captured when rotation starts; used to create a single undoable command.
  double? _rotationStartAngle;

  BoardNotifier({
    required BoardStateV2 initialState,
    CommandHistory? history,
    this.onStateChanged,
  })  : _history = history ?? CommandHistory(),
        super(initialState);

  // ---------------------------------------------------------------------------
  // Command history
  // ---------------------------------------------------------------------------

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  /// Execute an undoable command.
  void _executeCommand(BoardCommand command) {
    final newScene = _history.execute(command, state.currentScene);
    state = state.copyWith(currentScene: newScene);
    onStateChanged?.call(state);
  }

  void undo() {
    final newScene = _history.undo(state.currentScene);
    if (newScene != null) {
      state = state.copyWith(
        currentScene: newScene,
        selectedElementId: null,
      );
      onStateChanged?.call(state);
    }
  }

  void redo() {
    final newScene = _history.redo(state.currentScene);
    if (newScene != null) {
      state = state.copyWith(currentScene: newScene);
      onStateChanged?.call(state);
    }
  }

  void clearHistory() {
    _history.clear();
  }

  // ---------------------------------------------------------------------------
  // Element CRUD (undoable)
  // ---------------------------------------------------------------------------

  /// Add a new element to the board.
  void addElement(BoardElement element) {
    _executeCommand(AddElementCommand(element));
    state = state.copyWith(selectedElementId: element.id);
  }

  /// Remove the element with the given ID.
  void removeElement(String elementId) {
    _executeCommand(RemoveElementCommand(elementId));
    // Clear selection if removed element was selected
    if (state.selectedElementId == elementId) {
      state = state.copyWith(selectedElementId: null);
    }
  }

  /// Remove the currently selected element.
  void removeSelectedElement() {
    final id = state.selectedElementId;
    if (id != null) {
      removeElement(id);
    }
  }

  /// Move an element to a new relative position (undoable).
  ///
  /// For drag-end commits. During drag, use [updateElementPositionLive]
  /// for smooth visual feedback without creating undo entries.
  void moveElement(String elementId, Offset newOffset) {
    _executeCommand(MoveElementCommand(
      elementId: elementId,
      newOffset: newOffset,
    ));
  }

  /// Update an element's properties (undoable).
  void updateElement(BoardElement updatedElement) {
    _executeCommand(UpdateElementCommand(updatedElement));
  }

  /// Update multiple elements at once (undoable, single undo step).
  void batchUpdateElements({
    required String label,
    required List<BoardElement> updatedElements,
  }) {
    _executeCommand(BatchUpdateCommand(
      label: label,
      updatedElements: updatedElements,
    ));
  }

  /// Execute a custom command.
  void executeCommand(BoardCommand command) {
    _executeCommand(command);
  }

  // ---------------------------------------------------------------------------
  // Z-order (undoable)
  // ---------------------------------------------------------------------------

  void moveElementUp(String elementId) {
    final element = _findElement(elementId);
    if (element == null) return;

    final currentZ = element.zIndex ?? 0;
    _executeCommand(ReorderElementCommand(
      elementId: elementId,
      newZIndex: currentZ + 1,
    ));
  }

  void moveElementDown(String elementId) {
    final element = _findElement(elementId);
    if (element == null) return;

    final currentZ = element.zIndex ?? 0;
    _executeCommand(ReorderElementCommand(
      elementId: elementId,
      newZIndex: (currentZ - 1).clamp(0, currentZ),
    ));
  }

  void moveElementToFront(String elementId) {
    final maxZ = _maxZIndex();
    _executeCommand(ReorderElementCommand(
      elementId: elementId,
      newZIndex: maxZ + 1,
    ));
  }

  void moveElementToBack(String elementId) {
    _executeCommand(ReorderElementCommand(
      elementId: elementId,
      newZIndex: 0,
    ));
  }

  // ---------------------------------------------------------------------------
  // Copy / Paste (undoable add)
  // ---------------------------------------------------------------------------

  void copyElement(String elementId) {
    state = state.copyWith(copiedElementId: elementId);
  }

  /// Paste the copied element at the given offset with a new ID.
  void pasteElement({required String newId, required Offset offset}) {
    final copiedId = state.copiedElementId;
    if (copiedId == null) return;

    final original = _findElement(copiedId);
    if (original == null) return;

    final pasted = original.copyWithBase(
      id: newId,
      offset: offset,
      zIndex: _maxZIndex() + 1,
    );
    addElement(pasted);
  }

  // ---------------------------------------------------------------------------
  // Selection (non-undoable)
  // ---------------------------------------------------------------------------

  void selectElement(String? elementId) {
    state = state.copyWith(selectedElementId: elementId);
  }

  void deselectElement() {
    state = state.copyWith(selectedElementId: null);
  }

  // ---------------------------------------------------------------------------
  // Drag handling (non-undoable during drag, undoable on end)
  // ---------------------------------------------------------------------------

  /// Start dragging an element. Records start position for undo.
  void startDrag(String elementId) {
    final element = _findElement(elementId);
    _dragStartOffset = element?.offset;
    state = state.copyWith(
      isDraggingItem: true,
      selectedElementId: elementId,
    );
  }

  /// Update element position live during drag (no undo entry).
  void updateElementPositionLive(String elementId, Offset newOffset) {
    final components = state.components;
    final index = components.indexWhere((c) => c.id == elementId);
    if (index == -1) return;

    final updated = List<BoardElement>.of(components);
    updated[index] = updated[index].copyWithBase(offset: newOffset);
    state = state.copyWith(
      currentScene: state.currentScene.copyWith(components: updated),
    );
  }

  /// End drag. Creates a single undoable MoveElementCommand
  /// from start position → final position.
  void endDrag(String elementId) {
    final element = _findElement(elementId);
    if (element != null && _dragStartOffset != null) {
      final finalOffset = element.offset;
      if (finalOffset != null && finalOffset != _dragStartOffset) {
        // Temporarily restore start position, then execute move command
        // so the command captures the correct old→new transition.
        final components = state.components;
        final index = components.indexWhere((c) => c.id == elementId);
        if (index != -1) {
          final restored = List<BoardElement>.of(components);
          restored[index] =
              restored[index].copyWithBase(offset: _dragStartOffset);
          state = state.copyWith(
            currentScene:
                state.currentScene.copyWith(components: restored),
          );
          _executeCommand(MoveElementCommand(
            elementId: elementId,
            newOffset: finalOffset,
          ));
        }
      }
    }

    _dragStartOffset = null;
    state = state.copyWith(isDraggingItem: false);
    clearGuides();
  }

  /// Cancel drag without creating an undo entry.
  void cancelDrag(String elementId) {
    if (_dragStartOffset != null) {
      updateElementPositionLive(elementId, _dragStartOffset!);
    }
    _dragStartOffset = null;
    state = state.copyWith(isDraggingItem: false);
    clearGuides();
  }

  // ---------------------------------------------------------------------------
  // Resize handling (non-undoable during resize, undoable on end)
  // ---------------------------------------------------------------------------

  /// Start resizing an element. Records start size for undo.
  void startResize(String elementId) {
    final element = _findElement(elementId);
    _resizeStartSize = element?.size;
  }

  /// Update element size live during resize (no undo entry).
  void updateElementSizeLive(String elementId, Size newSize) {
    final components = state.components;
    final index = components.indexWhere((c) => c.id == elementId);
    if (index == -1) return;

    final updated = List<BoardElement>.of(components);
    updated[index] = updated[index].copyWithBase(size: newSize);
    state = state.copyWith(
      currentScene: state.currentScene.copyWith(components: updated),
    );
  }

  /// End resize. Creates a single undoable UpdateElementCommand.
  void endResize(String elementId) {
    final element = _findElement(elementId);
    if (element != null && _resizeStartSize != null) {
      final finalSize = element.size;
      if (finalSize != null && finalSize != _resizeStartSize) {
        // Restore start size, then execute undoable update
        final components = state.components;
        final index = components.indexWhere((c) => c.id == elementId);
        if (index != -1) {
          final restored = List<BoardElement>.of(components);
          restored[index] =
              restored[index].copyWithBase(size: _resizeStartSize);
          state = state.copyWith(
            currentScene:
                state.currentScene.copyWith(components: restored),
          );
          _executeCommand(UpdateElementCommand(
            element.copyWithBase(size: finalSize),
          ));
        }
      }
    }
    _resizeStartSize = null;
  }

  // ---------------------------------------------------------------------------
  // Rotation handling (non-undoable during rotation, undoable on end)
  // ---------------------------------------------------------------------------

  /// Start rotating an element. Records start angle for undo.
  void startRotation(String elementId) {
    final element = _findElement(elementId);
    _rotationStartAngle = element?.angle ?? 0.0;
  }

  /// Update element angle live during rotation (no undo entry).
  void updateElementAngleLive(String elementId, double newAngle) {
    final components = state.components;
    final index = components.indexWhere((c) => c.id == elementId);
    if (index == -1) return;

    final updated = List<BoardElement>.of(components);
    updated[index] = updated[index].copyWithBase(angle: newAngle);
    state = state.copyWith(
      currentScene: state.currentScene.copyWith(components: updated),
    );
  }

  /// End rotation. Creates a single undoable UpdateElementCommand.
  void endRotation(String elementId) {
    final element = _findElement(elementId);
    if (element != null && _rotationStartAngle != null) {
      final finalAngle = element.angle ?? 0.0;
      if (finalAngle != _rotationStartAngle) {
        final components = state.components;
        final index = components.indexWhere((c) => c.id == elementId);
        if (index != -1) {
          final restored = List<BoardElement>.of(components);
          restored[index] =
              restored[index].copyWithBase(angle: _rotationStartAngle);
          state = state.copyWith(
            currentScene:
                state.currentScene.copyWith(components: restored),
          );
          _executeCommand(UpdateElementCommand(
            element.copyWithBase(angle: finalAngle),
          ));
        }
      }
    }
    _rotationStartAngle = null;
  }

  // ---------------------------------------------------------------------------
  // Playback scene replacement
  // ---------------------------------------------------------------------------

  /// Replace the current scene without clearing history, selection, or drag state.
  /// Used by animation playback to push interpolated frames.
  void replaceSceneForPlayback(SceneModelV2 scene) {
    state = state.copyWith(currentScene: scene);
  }

  // ---------------------------------------------------------------------------
  // Drag from panel to board
  // ---------------------------------------------------------------------------

  void setDraggingToBoard(bool isDragging) {
    state = state.copyWith(isDraggingElementToBoard: isDragging);
  }

  // ---------------------------------------------------------------------------
  // Smart guides (non-undoable)
  // ---------------------------------------------------------------------------

  void updateGuides(List<GuideLine> guides) {
    state = state.copyWith(activeGuides: guides);
  }

  void clearGuides() {
    if (state.activeGuides.isNotEmpty) {
      state = state.copyWith(activeGuides: const []);
    }
  }

  // ---------------------------------------------------------------------------
  // Board configuration (non-undoable — affects display, not scene data)
  // ---------------------------------------------------------------------------

  void updateBoardColor(Color color) {
    state = state.copyWith(boardColor: color);
  }

  void updateBoardBackground(BoardBackground background) {
    state = state.copyWith(boardBackground: background);
  }

  void rotateField() {
    state = state.copyWith(
      boardAngle: state.boardAngle == 0 ? 1 : 0,
    );
  }

  void updateGridSize(double gridSize) {
    state = state.copyWith(gridSize: gridSize);
  }

  void updateHomeTeamBorderColor(Color color) {
    state = state.copyWith(homeTeamBorderColor: color);
  }

  void updateAwayTeamBorderColor(Color color) {
    state = state.copyWith(awayTeamBorderColor: color);
  }

  // ---------------------------------------------------------------------------
  // UI toggles (non-undoable)
  // ---------------------------------------------------------------------------

  void toggleFullScreen() {
    state = state.copyWith(showFullScreen: !state.showFullScreen);
  }

  void setFullScreen(bool value) {
    state = state.copyWith(showFullScreen: value);
  }

  void toggleAnimation() {
    state = state.copyWith(showAnimation: !state.showAnimation);
  }

  void toggleTrajectoryEditing(bool value) {
    state = state.copyWith(trajectoryEditingEnabled: value);
  }

  void toggleApplyDesignToAll(bool value) {
    state = state.copyWith(applyDesignToAll: value);
  }

  // ---------------------------------------------------------------------------
  // Scene management
  // ---------------------------------------------------------------------------

  /// Load a scene onto the board, replacing the current one.
  /// Clears selection and undo history.
  void loadScene(SceneModelV2 scene) {
    _history.clear();
    _dragStartOffset = null;
    state = state.copyWith(
      currentScene: scene,
      selectedElementId: null,
      copiedElementId: null,
      isDraggingItem: false,
      activeGuides: const [],
    );
  }

  /// Get all elements matching a predicate (e.g., same team players).
  List<BoardElement> getMatchingElements(
      bool Function(BoardElement) predicate) {
    return state.components.where(predicate).toList();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  BoardElement? _findElement(String id) {
    try {
      return state.components.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  int _maxZIndex() {
    if (state.components.isEmpty) return 0;
    return state.components
        .map((c) => c.zIndex ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }
}
