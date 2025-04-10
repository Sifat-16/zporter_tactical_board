import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class GameField extends PositionComponent
    with HasGameReference, RiverpodComponentMixin {
  GameField({required Vector2 size, this.initialColor}) : super(size: size);
  final Color? initialColor;
  // Measurements
  late double centerCircleRadius;
  late double penaltyBoxWidth;
  late double penaltyBoxHeight;
  late double goalBoxWidth;
  late double goalBoxHeight;
  late double penaltySpotRadius;

  final Paint _borderPaint =
      Paint()
        ..color = ColorManager.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

  final Paint _fieldPaint = Paint()..color = ColorManager.grey; // Green Field

  @override
  FutureOr<void> onLoad() {
    addToGameWidgetBuild(() {
      ref.listen(boardProvider, (previous, current) {
        _fieldPaint.color = current.boardColor;
      });
    });

    _fieldPaint.color = initialColor ?? ColorManager.grey;

    _initializePosition();
    _initializeMeasurements();
    size.y -= 20;
    return super.onLoad();
  }

  void _initializePosition() {
    position = (game.size - size) / 2;
  }

  _initializeMeasurements() {
    centerCircleRadius = size.y * 0.12;
    penaltyBoxWidth = size.x * 0.15;
    penaltyBoxHeight = size.y * 0.4;
    goalBoxWidth = size.x * 0.06;
    goalBoxHeight = size.y * 0.15;
    penaltySpotRadius = 4;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _drawFieldBackground(canvas);
    _drawFieldOutline(canvas);
    _drawCenterCircle(canvas);
    _drawHalfwayLine(canvas);
    _drawPenaltyAreas(canvas);
    _drawGoalBoxes(canvas);
    _drawPenaltySpots(canvas);
    // _drawCornerArcs(canvas);
    _drawCenterSpots(canvas);
  }

  /// Draws the green background of the field
  void _drawFieldBackground(Canvas canvas) {
    canvas.drawRect(size.toRect(), _fieldPaint);
  }

  /// Draws the outline of the football field
  void _drawFieldOutline(Canvas canvas) {
    canvas.drawRect(size.toRect(), _borderPaint);
  }

  /// Draws the center circle
  void _drawCenterCircle(Canvas canvas) {
    final Offset center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(center, centerCircleRadius, _borderPaint);
  }

  /// Draws the halfway line (midfield divider)
  void _drawHalfwayLine(Canvas canvas) {
    canvas.drawLine(
      Offset(size.x / 2, 0),
      Offset(size.x / 2, size.y),
      _borderPaint,
    );
  }

  /// Draws the penalty areas on both sides
  void _drawPenaltyAreas(Canvas canvas) {
    // Left Penalty Area
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        (size.y - penaltyBoxHeight) / 2,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      _borderPaint,
    );

    // Right Penalty Area
    canvas.drawRect(
      Rect.fromLTWH(
        size.x - penaltyBoxWidth,
        (size.y - penaltyBoxHeight) / 2,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      _borderPaint,
    );
  }

  /// Draws the goal boxes (small areas near the goals)
  void _drawGoalBoxes(Canvas canvas) {
    // Left Goal Box
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        (size.y - goalBoxHeight) / 2,
        goalBoxWidth,
        goalBoxHeight,
      ),
      _borderPaint,
    );

    // Right Goal Box
    canvas.drawRect(
      Rect.fromLTWH(
        size.x - goalBoxWidth,
        (size.y - goalBoxHeight) / 2,
        goalBoxWidth,
        goalBoxHeight,
      ),
      _borderPaint,
    );
  }

  /// Draws the penalty spots
  void _drawPenaltySpots(Canvas canvas) {
    // Left Penalty Spot
    canvas.drawCircle(
      Offset(
        penaltyBoxWidth - (penaltyBoxWidth - goalBoxWidth) / 2,
        size.y / 2,
      ),
      penaltySpotRadius,
      _borderPaint,
    );

    // Right Penalty Spot
    canvas.drawCircle(
      Offset(
        size.x - penaltyBoxWidth + (penaltyBoxWidth - goalBoxWidth) / 2,
        size.y / 2,
      ),
      penaltySpotRadius,
      _borderPaint,
    );
  }

  /// Draws the Center spots
  void _drawCenterSpots(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      penaltySpotRadius,
      _borderPaint,
    );
  }
}
