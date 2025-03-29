import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class PlayerComponent extends FieldComponent<PlayerModel> {
  PlayerComponent({required super.object});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite("ball.png", srcSize: Vector2.zero());
    size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
    position = object.offset ?? Vector2(x, y);
    angle = object.angle ?? 0;
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
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    object.offset = position;
  }

  @override
  void onScaleUpdate(DragUpdateEvent event) {
    super.onScaleUpdate(event);
    object.offset = position;
  }

  @override
  void onRotationUpdate() {
    super.onRotationUpdate();
    object.angle = angle;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // // Determine color based on player type
    // Color circleColor =
    //     object.playerType == PlayerType.HOME
    //         ? ColorManager
    //             .blue // Home color
    //         : ColorManager.red; // Away color

    // Determine color based on player type
    size = object.size ?? Vector2(32, 32);
    Color circleColor = object.color ?? Colors.transparent; // Away color

    // Draw the circle
    final rectPaint =
        Paint()..color = circleColor.withValues(alpha: object.opacity);

    // canvas.drawCircle(size.toOffset() / 2, size.x / 2, circlePaint);

    // Assuming 'size' is a Vector2 and 'rectPaint' is your Paint object

    // 1. Define the rectangle bounds (as before)
    final Rect rect = size.toRect();

    // 2. Define the corner radius
    const double cornerRadiusValue = 8.0; // Or your desired radius
    final Radius cornerRadius = Radius.circular(cornerRadiusValue);

    // 3. Create the Rounded Rectangle (RRect) object
    final RRect roundedRect = RRect.fromRectAndRadius(rect, cornerRadius);

    // 4. Draw the rounded rectangle using the existing paint
    canvas.drawRRect(roundedRect, rectPaint);

    final fontSize = (size.x / 2) * 0.5;
    // Draw the jersey number
    final textPainter = TextPainter(
      text: TextSpan(
        text: object.role, // Assuming role is the jersey number
        style: TextStyle(
          color: Colors.white.withValues(alpha: object.opacity),
          fontSize: fontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      (size.toOffset() / 2) -
          Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void moveTo(Vector2 newPosition) {
    position.setFrom(newPosition); // Directly update the position
  }
}
