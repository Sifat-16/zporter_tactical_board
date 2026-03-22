import 'dart:ui';

import 'package:zporter_tactical_board/v2/commands/board_command.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';

/// Add a single element to the scene.
class AddElementCommand extends BoardCommand {
  final BoardElement element;

  AddElementCommand(this.element);

  @override
  String get label => 'Add ${element.fieldItemType.name}';

  @override
  SceneModelV2 execute(SceneModelV2 scene) {
    return scene.copyWith(
      components: [...scene.components, element],
    );
  }

  @override
  SceneModelV2 undo(SceneModelV2 scene) {
    return scene.copyWith(
      components:
          scene.components.where((c) => c.id != element.id).toList(),
    );
  }
}

/// Remove a single element from the scene.
///
/// Captures the removed element so undo can restore it at the correct position.
class RemoveElementCommand extends BoardCommand {
  final String elementId;

  /// The element that was removed — captured on first execute.
  BoardElement? _removedElement;

  /// The index where the element lived in the list — for undo reinsertion.
  int? _removedIndex;

  RemoveElementCommand(this.elementId);

  @override
  String get label => 'Remove element';

  @override
  SceneModelV2 execute(SceneModelV2 scene) {
    final components = scene.components;
    final index = components.indexWhere((c) => c.id == elementId);
    if (index == -1) return scene;

    _removedElement = components[index];
    _removedIndex = index;

    final updated = List<BoardElement>.of(components);
    updated.removeAt(index);
    return scene.copyWith(components: updated);
  }

  @override
  SceneModelV2 undo(SceneModelV2 scene) {
    if (_removedElement == null) return scene;

    final updated = List<BoardElement>.of(scene.components);
    final insertAt = _removedIndex!.clamp(0, updated.length);
    updated.insert(insertAt, _removedElement!);
    return scene.copyWith(components: updated);
  }
}

/// Move an element to a new relative position (center-anchored).
class MoveElementCommand extends BoardCommand {
  final String elementId;
  final Offset newOffset;

  /// The old offset — captured on first execute.
  Offset? _oldOffset;

  MoveElementCommand({
    required this.elementId,
    required this.newOffset,
  });

  @override
  String get label => 'Move element';

  @override
  SceneModelV2 execute(SceneModelV2 scene) {
    final components = scene.components;
    final index = components.indexWhere((c) => c.id == elementId);
    if (index == -1) return scene;

    _oldOffset ??= components[index].offset;

    final updated = List<BoardElement>.of(components);
    updated[index] = updated[index].copyWithBase(offset: newOffset);
    return scene.copyWith(components: updated);
  }

  @override
  SceneModelV2 undo(SceneModelV2 scene) {
    if (_oldOffset == null) return scene;

    final components = scene.components;
    final index = components.indexWhere((c) => c.id == elementId);
    if (index == -1) return scene;

    final updated = List<BoardElement>.of(components);
    updated[index] = updated[index].copyWithBase(offset: _oldOffset);
    return scene.copyWith(components: updated);
  }
}

/// Replace an element with an updated version (same ID).
///
/// Used for property changes: color, name, jersey number, line type, etc.
class UpdateElementCommand extends BoardCommand {
  final BoardElement updatedElement;

  /// The element before the update — captured on first execute.
  BoardElement? _previousElement;

  UpdateElementCommand(this.updatedElement);

  @override
  String get label => 'Update ${updatedElement.fieldItemType.name}';

  @override
  SceneModelV2 execute(SceneModelV2 scene) {
    final components = scene.components;
    final index = components.indexWhere((c) => c.id == updatedElement.id);
    if (index == -1) return scene;

    _previousElement ??= components[index];

    final updated = List<BoardElement>.of(components);
    updated[index] = updatedElement;
    return scene.copyWith(components: updated);
  }

  @override
  SceneModelV2 undo(SceneModelV2 scene) {
    if (_previousElement == null) return scene;

    final components = scene.components;
    final index = components.indexWhere((c) => c.id == updatedElement.id);
    if (index == -1) return scene;

    final updated = List<BoardElement>.of(components);
    updated[index] = _previousElement!;
    return scene.copyWith(components: updated);
  }
}

/// Change an element's z-index (layer ordering).
class ReorderElementCommand extends BoardCommand {
  final String elementId;
  final int newZIndex;

  int? _oldZIndex;

  ReorderElementCommand({
    required this.elementId,
    required this.newZIndex,
  });

  @override
  String get label => 'Reorder element';

  @override
  SceneModelV2 execute(SceneModelV2 scene) {
    final components = scene.components;
    final index = components.indexWhere((c) => c.id == elementId);
    if (index == -1) return scene;

    _oldZIndex ??= components[index].zIndex ?? 0;

    final updated = List<BoardElement>.of(components);
    updated[index] = updated[index].copyWithBase(zIndex: newZIndex);
    return scene.copyWith(components: updated);
  }

  @override
  SceneModelV2 undo(SceneModelV2 scene) {
    final components = scene.components;
    final index = components.indexWhere((c) => c.id == elementId);
    if (index == -1) return scene;

    final updated = List<BoardElement>.of(components);
    updated[index] = updated[index].copyWithBase(zIndex: _oldZIndex ?? 0);
    return scene.copyWith(components: updated);
  }
}

/// Update multiple elements at once (e.g., bulk team color change).
///
/// Undoable as a single atomic operation.
class BatchUpdateCommand extends BoardCommand {
  @override
  final String label;
  final List<BoardElement> updatedElements;

  /// The elements before the update — captured on first execute.
  List<BoardElement>? _previousElements;

  BatchUpdateCommand({
    required this.label,
    required this.updatedElements,
  });

  @override
  SceneModelV2 execute(SceneModelV2 scene) {
    final updatedIds = {for (final e in updatedElements) e.id: e};

    if (_previousElements == null) {
      _previousElements = scene.components
          .where((c) => updatedIds.containsKey(c.id))
          .toList();
    }

    final updated = scene.components.map((c) {
      return updatedIds[c.id] ?? c;
    }).toList();

    return scene.copyWith(components: updated);
  }

  @override
  SceneModelV2 undo(SceneModelV2 scene) {
    if (_previousElements == null) return scene;

    final previousIds = {for (final e in _previousElements!) e.id: e};
    final restored = scene.components.map((c) {
      return previousIds[c.id] ?? c;
    }).toList();

    return scene.copyWith(components: restored);
  }
}
