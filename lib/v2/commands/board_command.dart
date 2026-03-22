import 'package:zporter_tactical_board/v2/models/scene_model.dart';

/// Reversible command for undo/redo on the tactical board.
///
/// Replaces V1's snapshot-based history (storing full [AnimationItemModel]
/// copies per action) with lightweight, targeted mutations.
///
/// Each command captures only the delta needed to execute and reverse
/// an action, keeping the history stack memory-efficient.
///
/// Commands operate on a single [SceneModelV2] and return a new instance
/// (immutable state transitions).
abstract class BoardCommand {
  /// Human-readable label for the undo/redo UI.
  String get label;

  /// Apply this command to the current scene, returning the new scene.
  SceneModelV2 execute(SceneModelV2 scene);

  /// Reverse this command, returning the scene to its prior state.
  SceneModelV2 undo(SceneModelV2 scene);
}

/// A command composed of multiple sub-commands executed as one atomic unit.
///
/// Useful for operations that logically group several changes
/// (e.g., paste multiple elements, or move + resize in one drag).
class CompositeCommand extends BoardCommand {
  @override
  final String label;
  final List<BoardCommand> _commands;

  CompositeCommand({
    required this.label,
    required List<BoardCommand> commands,
  }) : _commands = List.unmodifiable(commands);

  List<BoardCommand> get commands => _commands;

  @override
  SceneModelV2 execute(SceneModelV2 scene) {
    var current = scene;
    for (final cmd in _commands) {
      current = cmd.execute(current);
    }
    return current;
  }

  @override
  SceneModelV2 undo(SceneModelV2 scene) {
    var current = scene;
    // Undo in reverse order
    for (final cmd in _commands.reversed) {
      current = cmd.undo(current);
    }
    return current;
  }
}

/// Manages a stack of commands for undo/redo.
///
/// Replaces V1's [HistoryModel] which stored full scene snapshots.
/// This stores only the deltas (commands), making it far more
/// memory-efficient for long editing sessions.
class CommandHistory {
  final List<BoardCommand> _undoStack;
  final List<BoardCommand> _redoStack;
  final int maxHistorySize;

  CommandHistory({
    this.maxHistorySize = 50,
  })  : _undoStack = [],
        _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  int get undoCount => _undoStack.length;
  int get redoCount => _redoStack.length;

  /// Execute a command and push it onto the undo stack.
  /// Clears the redo stack (new action invalidates redo history).
  SceneModelV2 execute(BoardCommand command, SceneModelV2 scene) {
    final newScene = command.execute(scene);
    _undoStack.add(command);
    _redoStack.clear();

    // Trim oldest entries if over limit
    if (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }

    return newScene;
  }

  /// Undo the most recent command.
  /// Returns null if nothing to undo.
  SceneModelV2? undo(SceneModelV2 scene) {
    if (!canUndo) return null;
    final command = _undoStack.removeLast();
    final newScene = command.undo(scene);
    _redoStack.add(command);
    return newScene;
  }

  /// Redo the most recently undone command.
  /// Returns null if nothing to redo.
  SceneModelV2? redo(SceneModelV2 scene) {
    if (!canRedo) return null;
    final command = _redoStack.removeLast();
    final newScene = command.execute(scene);
    _undoStack.add(command);
    return newScene;
  }

  /// Clear all history.
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
