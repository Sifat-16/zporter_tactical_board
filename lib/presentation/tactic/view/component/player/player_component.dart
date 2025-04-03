import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
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
    // Assuming super.render(canvas) is correctly called if needed
    // Assuming 'object' and 'opacity' are defined and available in this scope
    // YourObject object = YourObject(); // Example instance
    // double opacity = 1.0; // Example opacity

    size = object.size ?? Vector2(32, 32);
    Color circleColor = object.color ?? Colors.transparent; // Away color

    // --- Draw the rounded rectangle (existing code - UNCHANGED) ---
    final rectPaint = Paint()..color = circleColor.withValues(alpha: opacity);
    final Rect rect = size.toRect(); // Using your existing method
    const double cornerRadiusValue = 8.0;
    final Radius cornerRadius = Radius.circular(cornerRadiusValue);
    final RRect roundedRect = RRect.fromRectAndRadius(rect, cornerRadius);
    canvas.drawRRect(roundedRect, rectPaint);

    // --- Draw the Triangle at the Top Center ---
    // 1. Define triangle properties (UNCHANGED)
    final double triangleBaseWidth = size.x * 0.3;
    final double triangleHeight = size.y * 0.2;
    final Color triangleColor = ColorManager.yellowLight;

    // 2. Define triangle paint (UNCHANGED)
    final trianglePaint =
        Paint()
          ..color = triangleColor.withValues(
            alpha: opacity,
          ) // Using your existing method
          ..style = PaintingStyle.fill;

    // 3. Define triangle path (>>> CHANGED AS REQUESTED <<<)
    //    Draws an UPWARD pointing triangle with its BASE centered on the TOP edge.
    final path = Path();
    final double topCenterX = size.x / 2;
    final double topEdgeY = 0; // Y-coordinate of the top edge is 0
    // Calculate the Y coordinate of the peak (negative value means above the top edge)
    final double peakY = topEdgeY - triangleHeight;

    // Move to the left vertex of the base (on the top edge)
    path.moveTo(topCenterX - triangleBaseWidth / 2, topEdgeY);

    // Line to the top peak vertex (above the rectangle)
    path.lineTo(topCenterX, peakY);

    // Line to the right vertex of the base (on the top edge)
    path.lineTo(topCenterX + triangleBaseWidth / 2, topEdgeY);

    // Close the path (draws the base line along the top edge)
    path.close();

    // 4. Draw the triangle (UNCHANGED)
    canvas.drawPath(path, trianglePaint);

    // --- Draw the jersey number (existing code - UNCHANGED) ---
    final fontSize = (size.x / 2) * 0.5; // Using your existing calculation
    final textPainter = TextPainter(
      text: TextSpan(
        text: object.role,
        style: TextStyle(
          color: Colors.white.withValues(
            alpha: opacity,
          ), // Using your existing method
          fontSize: fontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      (size.toOffset() / 2) - // Using your existing offset calculation
          Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void moveTo(Vector2 newPosition) {
    position.setFrom(newPosition); // Directly update the position
  }
}
