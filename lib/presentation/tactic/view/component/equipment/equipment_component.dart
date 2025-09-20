import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/model/guide_line.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class EquipmentComponent extends FieldComponent<EquipmentModel> {
  EquipmentComponent({required super.object});

  final double _snapTolerance = 5.0;
  final double _gridSize = 50.0;
  final List<GuideLine> _activeGuides = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite("${object.imagePath}");
    size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
    position = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: object.offset ?? Vector2(x, y),
    );
    angle = object.angle ?? 0;
    tint(object.color ?? ColorManager.white);
    opacity = object.opacity ?? 1;
  }

  // In class PlayerComponent
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isRotationHandleDragged) {
      super.onDragUpdate(event); // Let the base class handle rotation
      return;
    }
    _activeGuides.clear(); // Clear old guides from last frame

    // 1. Apply the drag (no snapping)
    position.add(event.canvasDelta);

    // 2. Get my new alignment points
    final myCenter = center - Vector2(10, 10);
    // final myTop = myCenter.y - (size.y / 2);
    // final myBottom = myCenter.y + (size.y / 2);
    // final myLeft = myCenter.x - (size.x / 2);
    // final myRight = myCenter.x + (size.x / 2);

    bool didSmartAlign = false; // Flag to track if we found an alignment

    // 3. Find other items to check against
    final otherItems = game.children.where(
        (c) => (c is PlayerComponent || c is EquipmentComponent) && c != this);

    for (final item in otherItems) {
      if (item is! PositionComponent) continue;

      final otherCenter = item.center - Vector2(10, 10);
      final otherTop = otherCenter.y - (item.size.y / 2);
      final otherBottom = otherCenter.y + (item.size.y / 2);
      final otherLeft = otherCenter.x - (item.size.x / 2);
      final otherRight = otherCenter.x + (item.size.x / 2);

      // --- Check X-axis Guides ---
      if ((myCenter.x - otherCenter.x).abs() < _snapTolerance) {
        _activeGuides.add(GuideLine(
          start: Vector2(otherCenter.x, myCenter.y),
          end: Vector2(otherCenter.x, otherCenter.y),
        ));
        didSmartAlign = true;
      }
      // if ((myLeft - otherLeft).abs() < _snapTolerance) {
      //   _activeGuides.add(GuideLine(
      //     start: Vector2(otherLeft, myTop),
      //     end: Vector2(otherLeft, otherTop),
      //   ));
      //   didSmartAlign = true;
      // }
      // if ((myRight - otherRight).abs() < _snapTolerance) {
      //   _activeGuides.add(GuideLine(
      //     start: Vector2(otherRight, myTop),
      //     end: Vector2(otherRight, otherTop),
      //   ));
      //   didSmartAlign = true;
      // }

      // --- Check Y-axis Guides ---
      if ((myCenter.y - otherCenter.y).abs() < _snapTolerance) {
        _activeGuides.add(GuideLine(
          start: Vector2(myCenter.x, otherCenter.y),
          end: Vector2(otherCenter.x, otherCenter.y),
        ));
        didSmartAlign = true;
      }
      // if ((myTop - otherTop).abs() < _snapTolerance) {
      //   _activeGuides.add(GuideLine(
      //     start: Vector2(myLeft, otherTop),
      //     end: Vector2(otherLeft, otherTop),
      //   ));
      //   didSmartAlign = true;
      // }
      // if ((myBottom - otherBottom).abs() < _snapTolerance) {
      //   _activeGuides.add(GuideLine(
      //     start: Vector2(myLeft, otherBottom),
      //     end: Vector2(otherLeft, otherBottom),
      //   ));
      //   didSmartAlign = true;
      // }
    }

    // 4. Update the providers
    ref.read(boardProvider.notifier).updateGuides(_activeGuides);

    // *** THIS IS THE KEY ***
    // Show the grid ONLY if we are NOT showing smart guides
    ref.read(boardProvider.notifier).toggleItemDrag(!didSmartAlign);

    // 5. Update the model
    object.offset = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    // TODO: implement onTapDown
    super.onTapDown(event);
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: object);
  }

  @override
  void onScaleUpdate(DragUpdateEvent event) {
    super.onScaleUpdate(event);
    object.offset = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
  }

  @override
  void onRotationUpdate() {
    super.onRotationUpdate();
    object.angle = angle;
  }

  @override
  render(Canvas canvas) {
    super.render(canvas);
    tint(object.color ?? ColorManager.white);
    size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
    opacity = object.opacity ?? 1;
  }

  @override
  void onComponentScale(Vector2 size) {
    // TODO: implement onComponentScale
    super.onComponentScale(size);
    object.size = size;
  }

  // In class EquipmentComponent

  // (This method should already be here from the last step)
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    ref.read(boardProvider.notifier).toggleItemDrag(true); // <-- RESTORE THIS
    ref.read(boardProvider.notifier).clearGuides(); // <-- Good to add this here
    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    ref.read(boardProvider.notifier).toggleItemDrag(false); // <-- RESTORE THIS
    ref.read(boardProvider.notifier).clearGuides();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    ref.read(boardProvider.notifier).toggleItemDrag(false); // <-- RESTORE THIS
    ref.read(boardProvider.notifier).clearGuides();
  }

// --- END ADD ---
}
