// import 'dart:ui';
//
// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/app/manager/values_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/model/guide_line.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
//
// class EquipmentComponent extends FieldComponent<EquipmentModel> {
//   EquipmentComponent({required super.object});
//
//   final double _snapTolerance = 5.0;
//   final List<GuideLine> _activeGuides = [];
//
//   // NEW: Properties for aerial animation
//   double altitude = 0.0;
//   Vector2? visualSize;
//   SpriteComponent? shadow;
//   Vector2? _originalShadowSize;
//   final double maxAltitudeForShadow =
//       60.0; // Corresponds to ArcingAnimation's arcHeight
//
//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     sprite = await game.loadSprite("${object.imagePath}");
//     size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
//     position = SizeHelper.getBoardActualVector(
//       gameScreenSize: game.gameField.size,
//       actualPosition: object.offset ?? Vector2(x, y),
//     );
//     angle = object.angle ?? 0;
//     tint(object.color ?? ColorManager.white);
//     opacity = object.opacity ?? 1;
//   }
//
//   // NEW: Update method to control the shadow's appearance
//   @override
//   void update(double dt) {
//     super.update(dt);
//
//     if (shadow != null) {
//       // Calculate shadow properties based on altitude
//       final altitudeProgress =
//           (altitude / maxAltitudeForShadow).clamp(0.0, 1.0);
//
//       // Shadow becomes more transparent and larger as the ball goes higher
//       shadow!.paint.color =
//           Colors.black.withOpacity(0.4 * (1 - altitudeProgress * 0.7));
//       shadow!.size = _originalShadowSize! * (1 + altitudeProgress * 0.5);
//     }
//   }
//
//   // MODIFIED: The render method now handles altitude and dynamic size
//   @override
//   void render(Canvas canvas) {
//     // Apply general properties from the model
//     tint(object.color ?? ColorManager.white);
//     opacity = object.opacity ?? 1;
//
//     // Use visualSize from animation if available, otherwise use model size
//     size = visualSize ?? object.size ?? Vector2(AppSize.s32, AppSize.s32);
//
//     // If the ball is in the air, offset its rendering position upwards
//     if (altitude > 0) {
//       canvas.save();
//       canvas.translate(0, -altitude); // Translate canvas upwards
//       super.render(
//           canvas); // Render the ball (and its child shadow) in the translated canvas
//       canvas.restore();
//     } else {
//       super.render(canvas); // Render normally on the ground
//     }
//   }
//
//   // Drag and tap methods remain unchanged
//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     if (isRotationHandleDragged) {
//       super.onDragUpdate(event);
//       return;
//     }
//     _activeGuides.clear();
//     position.add(event.canvasDelta);
//
//     final myCenter = center - Vector2(10, 10);
//     bool didSmartAlign = false;
//     final otherItems = game.children.where(
//         (c) => (c is PlayerComponent || c is EquipmentComponent) && c != this);
//
//     for (final item in otherItems) {
//       if (item is! PositionComponent) continue;
//       final otherCenter = item.center - Vector2(10, 10);
//
//       if ((myCenter.x - otherCenter.x).abs() < _snapTolerance) {
//         _activeGuides.add(GuideLine(
//           start: Vector2(otherCenter.x, myCenter.y),
//           end: Vector2(otherCenter.x, otherCenter.y),
//         ));
//         didSmartAlign = true;
//       }
//
//       if ((myCenter.y - otherCenter.y).abs() < _snapTolerance) {
//         _activeGuides.add(GuideLine(
//           start: Vector2(myCenter.x, otherCenter.y),
//           end: Vector2(otherCenter.x, otherCenter.y),
//         ));
//         didSmartAlign = true;
//       }
//     }
//
//     ref.read(boardProvider.notifier).updateGuides(_activeGuides);
//     ref.read(boardProvider.notifier).toggleItemDrag(!didSmartAlign);
//     object.offset = SizeHelper.getBoardRelativeVector(
//       gameScreenSize: game.gameField.size,
//       actualPosition: position,
//     );
//   }
//
//   @override
//   void onTapDown(TapDownEvent event) {
//     super.onTapDown(event);
//     ref
//         .read(boardProvider.notifier)
//         .toggleSelectItemEvent(fieldItemModel: object);
//   }
//
//   @override
//   void onScaleUpdate(DragUpdateEvent event) {
//     super.onScaleUpdate(event);
//     object.offset = SizeHelper.getBoardRelativeVector(
//       gameScreenSize: game.gameField.size,
//       actualPosition: position,
//     );
//   }
//
//   @override
//   void onRotationUpdate() {
//     super.onRotationUpdate();
//     object.angle = angle;
//   }
//
//   @override
//   void onComponentScale(Vector2 size) {
//     super.onComponentScale(size);
//     object.size = size;
//   }
//
//   @override
//   void onDragStart(DragStartEvent event) {
//     super.onDragStart(event);
//     ref.read(boardProvider.notifier).toggleItemDrag(true);
//     ref.read(boardProvider.notifier).clearGuides();
//     event.continuePropagation = false;
//   }
//
//   @override
//   void onDragEnd(DragEndEvent event) {
//     super.onDragEnd(event);
//     ref.read(boardProvider.notifier).toggleItemDrag(false);
//     ref.read(boardProvider.notifier).clearGuides();
//   }
//
//   @override
//   void onDragCancel(DragCancelEvent event) {
//     super.onDragCancel(event);
//     ref.read(boardProvider.notifier).toggleItemDrag(false);
//     ref.read(boardProvider.notifier).clearGuides();
//   }
// }

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/model/guide_line.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class EquipmentComponent extends FieldComponent<EquipmentModel>
    with DoubleTapCallbacks {
  EquipmentComponent({required super.object});

  final double _snapTolerance = 5.0;
  final List<GuideLine> _activeGuides = [];

  // Properties for aerial animation (personal shadow is removed)
  double altitude = 0.0;
  Vector2? visualSize;

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

  @override
  void render(Canvas canvas) {
    tint(object.color ?? ColorManager.white);
    opacity = object.opacity ?? 1;
    size = visualSize ?? object.size ?? Vector2(AppSize.s32, AppSize.s32);

    // This logic correctly handles the altitude for both up and down arcs
    if (altitude != 0) {
      canvas.save();
      canvas.translate(0, -altitude);
      super.render(canvas);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    super.onDoubleTapDown(event);
    if (object.name == "BALL") {
      _executeBallEditAction();
    }
  }

  void _executeBallEditAction() async {
    if (game.context == null) return;
    final result = await EquipmentUtils.showBallAnimationSettingsDialog(
      context: game.context,
      ballModel: object,
    );
    if (result != null) {
      object = result;
      ref.read(boardProvider.notifier).updateEquipmentModel(newModel: result);
    }
  }

  // ... All other methods like onDragUpdate, etc., are unchanged ...
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isRotationHandleDragged) {
      super.onDragUpdate(event);
      return;
    }
    _activeGuides.clear();
    position.add(event.canvasDelta);
    final myCenter = center - Vector2(10, 10);
    bool didSmartAlign = false;
    final otherItems = game.children.where(
        (c) => (c is PlayerComponent || c is EquipmentComponent) && c != this);
    for (final item in otherItems) {
      if (item is! PositionComponent) continue;
      final otherCenter = item.center - Vector2(10, 10);
      if ((myCenter.x - otherCenter.x).abs() < _snapTolerance) {
        _activeGuides.add(GuideLine(
          start: Vector2(otherCenter.x, myCenter.y),
          end: Vector2(otherCenter.x, otherCenter.y),
        ));
        didSmartAlign = true;
      }
      if ((myCenter.y - otherCenter.y).abs() < _snapTolerance) {
        _activeGuides.add(GuideLine(
          start: Vector2(myCenter.x, otherCenter.y),
          end: Vector2(otherCenter.x, otherCenter.y),
        ));
        didSmartAlign = true;
      }
    }
    ref.read(boardProvider.notifier).updateGuides(_activeGuides);
    ref.read(boardProvider.notifier).toggleItemDrag(!didSmartAlign);
    object.offset = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
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
  void onComponentScale(Vector2 size) {
    super.onComponentScale(size);
    object.size = size;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    ref.read(boardProvider.notifier).toggleItemDrag(true);
    ref.read(boardProvider.notifier).clearGuides();
    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    ref.read(boardProvider.notifier).toggleItemDrag(false);
    ref.read(boardProvider.notifier).clearGuides();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    ref.read(boardProvider.notifier).toggleItemDrag(false);
    ref.read(boardProvider.notifier).clearGuides();
  }
}
