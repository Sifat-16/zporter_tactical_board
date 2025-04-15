import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/scaling_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/selection_border_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

// Interface for selectable components
abstract class Selectable {
  bool get isSelected;
  set isSelected(bool value);
  void updateSelectionBorder();
  void setRotationHandleDragged(bool value);
}

// Interface for draggable components
abstract class Draggable {
  void onDragUpdate(DragUpdateEvent event);
}

// Interface for scalable components
abstract class Scalable {
  void onScaleUpdate(DragUpdateEvent event);
}

// Base component for field elements
abstract class FieldComponent<T extends FieldItemModel> extends SpriteComponent
    with
        HasGameReference<TacticBoardGame>,
        DragCallbacks,
        TapCallbacks,
        RiverpodComponentMixin
    implements Selectable, Draggable, Scalable {
  T object;

  SelectionBorder? selectionBorder;
  bool _isRotationHandleDragged = false;
  bool _isSelected = false;

  FieldComponent({super.priority = 1, required this.object});

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    anchor = Anchor.center;
    position = Vector2(
      game.gameField.size.x / 2,
      game.gameField.size.y / 2,
    ); // Default position
  }

  @override
  void onMount() {
    addToGameWidgetBuild(() {
      ref.listen(boardProvider, (p0, p1) {
        if (p1.selectedItemOnTheBoard == null ||
            p1.selectedItemOnTheBoard?.id != object.id) {
          _isSelected = false;
        } else {
          _isSelected = true;
        }
        updateSelectionBorder();
      });
    });
    super.onMount();
  }

  // @override
  // void onTapDown(TapDownEvent event) {
  //   super.onTapDown(event);
  //
  //
  //
  //   // _isSelected = !_isSelected;
  //   // updateSelectionBorder();
  // }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_isRotationHandleDragged) {
      position += event.canvasDelta;
    }
  }

  @override
  void onScaleUpdate(DragUpdateEvent event) {
    Vector2 delta = event.localDelta;

    double scaleX = 1.0;
    double scaleY = 1.0;

    if (selectionBorder != null) {
      final anchor = getScalingAnchor(event.localStartPosition);

      if (anchor == Anchor.topLeft || anchor == Anchor.bottomLeft) {
        scaleX -= delta.x / size.x;
      } else {
        scaleX += delta.x / size.x;
      }

      if (anchor == Anchor.topLeft || anchor == Anchor.topRight) {
        scaleY -= delta.y / size.y;
      } else {
        scaleY += delta.y / size.y;
      }

      size.x *= scaleX;
      size.y *= scaleY;

      size.x = size.x.clamp(10, double.infinity);
      size.y = size.y.clamp(10, double.infinity);

      selectionBorder!.size = size + Vector2.all(20);
      selectionBorder!.position.setFrom(Vector2(size.x / 2, size.y / 2));
      selectionBorder!.updateHandlePositions();
    }
  }

  Anchor getScalingAnchor(Vector2 localPosition) {
    if (selectionBorder != null) {
      final handles =
          selectionBorder!.children.whereType<ScalingHandle>().toList();
      for (final handle in handles) {
        if ((handle.position +
                    selectionBorder!.position -
                    size / 2 -
                    handle.size / 2)
                .distanceTo(localPosition) <
            handle.radius * 2) {
          return handle.anchor;
        }
      }
    }
    return Anchor.center;
  }

  @override
  void updateSelectionBorder() {
    if (_isSelected) {
      if (selectionBorder == null) {
        selectionBorder = SelectionBorder(component: this, symmetrically: true);
        add(selectionBorder!);
      }
    } else {
      if (selectionBorder != null) {
        remove(selectionBorder!);
        selectionBorder = null;
      }
    }
  }

  @override
  void setRotationHandleDragged(bool value) {
    _isRotationHandleDragged = value;
  }

  @override
  bool get isSelected => _isSelected;

  @override
  set isSelected(bool value) {
    _isSelected = value;
    updateSelectionBorder();
  }

  void onRotationUpdate() {
    // Default implementation, can be overridden
    zlog(data: "Rotation updated to ${angle}");
  }

  bool containsRecursivePoint(Vector2 point) {
    if (containsPoint(point)) {
      return true;
    }

    for (final child in children) {
      if (child is PositionComponent) {
        if (child.toRect().contains(point.toOffset())) {
          return true;
        }
      } else if (child is CircleComponent) {
        final center = child.position + child.size / 2;
        if (center.distanceTo(point) <= child.radius) {
          return true;
        }
      }

      // Add more checks here for other component types if needed, such as PolygonComponent, etc.
    }

    return false;
  }
}
