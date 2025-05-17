import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class PlayerComponent extends FieldComponent<PlayerModel> {
  PlayerComponent({required super.object});

  final Paint _backgroundPaint = Paint();
  final Paint _trianglePaint = Paint()..style = PaintingStyle.fill;

  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );
  final TextPainter _jerseyTextPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite("ball.png", srcSize: Vector2.zero());
    size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
    position = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: object.offset ?? Vector2(x, y),
    );
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
    object.offset = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
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
  void render(Canvas canvas) {
    super.render(canvas);
    size = object.size ?? Vector2(AppSize.s32, AppSize.s32);

    // --- Shared calculations ---
    final double baseOpacity = (object.opacity ?? 1.0).clamp(0.0, 1.0);
    final Color baseColor =
        object.color ??
        (object.playerType == PlayerType.HOME
            ? ColorManager.blue
            : (object.playerType == PlayerType.AWAY
                ? ColorManager.red
                : ColorManager.grey));
    final Color effectiveColor = baseColor.withOpacity(baseOpacity);

    // --- 1. Draw Rounded Rectangle Background ---
    _backgroundPaint.color = effectiveColor;
    _backgroundPaint.style = PaintingStyle.fill;

    const double cornerRadiusValue = 6.0;
    final Radius cornerRadius = Radius.circular(cornerRadiusValue);
    final Rect rect = size.toRect();
    final RRect roundedRect = RRect.fromRectAndRadius(rect, cornerRadius);

    canvas.drawRRect(roundedRect, _backgroundPaint);

    // --- 2. Draw Indicator Triangle (Conditional - POINTING OUTWARD) ---
    // if (object.playerType == PlayerType.HOME ||
    //     object.playerType == PlayerType.AWAY) {
    //   // Triangle Geometry (adjust size as needed)
    //   final double tHeight =
    //       size.x * 0.18; // How far the triangle points OUTWARD
    //   final double tBase =
    //       size.y * 0.35; // The width of the triangle's base along the edge
    //   _trianglePaint.color = ColorManager.white.withOpacity(
    //     baseOpacity,
    //   ); // White for visibility
    //
    //   final path = Path();
    //   final double halfWidth = size.x;
    //   double centerY = size.y / 2; // Y center in local coords (Anchor.center)
    //
    //   if (object.playerType == PlayerType.HOME) {
    //     // HOME: Draw on RIGHT edge, pointing RIGHT
    //     final double edgeX = halfWidth;
    //     path.moveTo(edgeX, centerY - tBase / 2); // Top base point on edge
    //     path.lineTo(
    //       edgeX + tHeight,
    //       centerY,
    //     ); // Peak point OUTSIDE (to the right)
    //     path.lineTo(edgeX, centerY + tBase / 2); // Bottom base point on edge
    //     path.close(); // Connect back to start
    //   } else {
    //     // AWAY
    //     // AWAY: Draw on LEFT edge, pointing LEFT
    //     final double edgeX = 0;
    //
    //     path.moveTo(edgeX, centerY - tBase / 2); // Top base point on edge
    //     path.lineTo(
    //       edgeX - tHeight,
    //       centerY,
    //     ); // Peak point OUTSIDE (to the left)
    //     path.lineTo(edgeX, centerY + tBase / 2); // Bottom base point on edge
    //     path.close(); // Connect back to start
    //   }
    //   canvas.drawPath(path, _trianglePaint);
    // }

    final fontSize = (size.x / 2) * 0.7; // Using your existing calculation
    final textPainter = TextPainter(
      text: TextSpan(
        text: object.role,
        style: TextStyle(
          color: Colors.white.withValues(
            alpha: opacity,
          ), // Using your existing method
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
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

    // --- 4. Draw Jersey Number (Top Right, slightly outside) ---
    String jerseyNumber =
        object.jerseyNumber.toString(); // Get number as string
    if (jerseyNumber == "-1") {
      jerseyNumber = "";
    }

    if (jerseyNumber.isNotEmpty) {
      final double jerseyFontSize =
          size.x * 0.3; // Adjust size for jersey number
      // Use a fixed contrasting color, e.g., white with a black outline/bg
      final jerseyTextColor = Colors.white.withValues(alpha: baseOpacity);
      const double nudge =
          3.0; // How far outside the corner to place the number's center

      // Prepare jersey number text style
      _jerseyTextPainter.text = TextSpan(
        text: jerseyNumber,
        style: TextStyle(
          color: jerseyTextColor,
          fontSize: jerseyFontSize,
          fontWeight: FontWeight.w900, // Make it very bold
        ),
      );
      _jerseyTextPainter.layout();

      // Calculate the target center position for the number text block
      final Offset cornerPos = Offset(
        size.x / 2,
        -size.y / 2,
      ); // Top-right corner in local coords
      final Offset numberCenterTarget = Offset(
        cornerPos.dx +
            nudge +
            (_jerseyTextPainter.width /
                2), // Nudge right based on text width too
        cornerPos.dy -
            nudge -
            (_jerseyTextPainter.height / 2), // Nudge up based on text height
      );

      // Calculate the drawing offset (top-left) for the text painter relative to canvas origin (0,0)
      final Offset numberTextDrawOffset = Offset(
        size.x - (size.x * .1),
        -size.y * .15,
      );

      // Draw the number
      _jerseyTextPainter.paint(canvas, numberTextDrawOffset);
    }
  }

  void moveTo(Vector2 newPosition) {
    position.setFrom(newPosition); // Directly update the position
  }

  @override
  void onComponentScale(Vector2 size) {
    // TODO: implement onComponentScale
    super.onComponentScale(size);
    object.size = size;
  }
}
