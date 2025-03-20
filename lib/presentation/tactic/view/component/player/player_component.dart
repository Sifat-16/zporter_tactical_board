import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';

class PlayerComponent extends FieldComponent<PlayerModel> {
  PlayerComponent({required super.object});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2(AppSize.s32, AppSize.s32);
    position = object.offset;
    angle = object.angle ?? 0;

    zlog(data: "Trying to add Player ${size}");
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

    // Determine color based on player type
    Color circleColor =
        object.playerType == PlayerType.HOME
            ? ColorManager
                .blue // Home color
            : ColorManager.red; // Away color

    // Draw the circle
    final circlePaint = Paint()..color = circleColor;
    canvas.drawCircle(size.toOffset() / 2, size.x / 2, circlePaint);

    final fontSize = (size.x / 2) * 0.5;
    // Draw the jersey number
    final textPainter = TextPainter(
      text: TextSpan(
        text: object.role, // Assuming role is the jersey number
        style: TextStyle(color: Colors.white, fontSize: fontSize),
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
}
