import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';

/// Ghost component that shows where a component was in the previous scene
///
/// PRO FEATURE: Shows semi-transparent preview of component's previous position
/// Used in trajectory path editing to visualize start point
///
/// Visual appearance:
/// - Semi-transparent (opacity 0.3-0.4)
/// - Dashed border to distinguish from real component
/// - Same size and shape as the original component
/// - Cannot be interacted with (tap/drag disabled)
class GhostComponent extends PositionComponent
    with HasGameReference<TacticBoardGame> {
  /// The field item model from the previous scene
  final FieldItemModel previousSceneItem;

  /// Opacity of the ghost (0.0 to 1.0)
  final double ghostOpacity;

  /// Whether to show a dashed border around the ghost
  final bool showDashedBorder;

  /// Paint for rendering the ghost
  final Paint _ghostPaint = Paint();

  GhostComponent({
    required this.previousSceneItem,
    this.ghostOpacity = 0.35,
    this.showDashedBorder = true,
    super.priority = 100, // HIGH PRIORITY - Render on top for debugging
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Convert logical coordinates to screen coordinates
    final fieldSize = game.gameField.size;
    final fieldPosition = game.gameField.position;

    final logicalPos = previousSceneItem.offset ?? Vector2.zero();
    final relativePosition = SizeHelper.getBoardActualVector(
      gameScreenSize: fieldSize,
      actualPosition: logicalPos,
    );

    // Add gameField position offset since we're added to game, not gameField
    position = relativePosition + fieldPosition;

    // Set size from previous scene
    size = previousSceneItem.size ?? Vector2(32, 32);

    // Set anchor to center (same as real components)
    anchor = Anchor.center;

    // Set angle if component was rotated
    angle = previousSceneItem.angle ?? 0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Equipment components are handled differently - they don't need custom ghost rendering
    // because they use sprite system which handles opacity automatically
    if (previousSceneItem is EquipmentModel) {
      // Just draw dashed border, sprite will be rendered by parent
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      );
      if (showDashedBorder) {
        _drawDashedCircleBorder(canvas, rect);
      }
      return;
    }

    // FOR PLAYERS: Render as rounded rectangle with role/number
    Color baseColor = ColorManager.grey;

    if (previousSceneItem is PlayerModel) {
      final player = previousSceneItem as PlayerModel;
      baseColor = player.color ??
          (player.playerType == PlayerType.HOME
              ? ColorManager.blue
              : ColorManager.red);
    }

    // Apply ghost opacity
    final ghostColor = baseColor.withOpacity(ghostOpacity);
    _ghostPaint.color = ghostColor;
    _ghostPaint.style = PaintingStyle.fill;

    // Render as ROUNDED RECTANGLE (same as actual player components)
    // Since anchor is Anchor.center, render centered at origin
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.x,
      height: size.y,
    );
    const cornerRadius = 6.0;
    final rrect =
        RRect.fromRectAndRadius(rect, const Radius.circular(cornerRadius));

    canvas.drawRRect(rrect, _ghostPaint);

    // Draw dashed border
    if (showDashedBorder) {
      _drawDashedRectBorder(canvas, rect, cornerRadius);
    }

    // If it's a player, draw role/number text
    if (previousSceneItem is PlayerModel) {
      final player = previousSceneItem as PlayerModel;

      // Draw role if enabled and not neutral
      if (player.showRole && player.role != '-') {
        final fontSize = (size.x / 2) * 0.7;
        final textPainter = TextPainter(textDirection: TextDirection.ltr);
        textPainter.text = TextSpan(
          text: player.role,
          style: TextStyle(
            color: Colors.white.withOpacity(ghostOpacity),
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            -textPainter.width / 2,
            -textPainter.height / 2,
          ),
        );
      }

      // Draw jersey number if enabled
      if (player.showNr) {
        final displayNumber = player.displayNumber ?? player.jerseyNumber;
        if (displayNumber > 0) {
          final numberFontSize = size.x * 0.20;
          final textPainter = TextPainter(textDirection: TextDirection.ltr);
          textPainter.text = TextSpan(
            text: displayNumber.toString(),
            style: TextStyle(
              color: Colors.white.withOpacity(ghostOpacity),
              fontSize: numberFontSize,
              fontWeight: FontWeight.w900,
            ),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              (size.x / 2) - textPainter.width - 2,
              -(size.y / 2) + 2,
            ),
          );
        }
      }
    }
  }

  /// Draw dashed border around rounded rectangle
  void _drawDashedRectBorder(Canvas canvas, Rect rect, double cornerRadius) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;

    final paint = Paint()
      ..color = ColorManager.grey.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));
    final path = Path()..addRRect(rrect);

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;

      while (distance < metric.length) {
        final nextDistance = distance + (draw ? dashWidth : dashSpace);
        if (nextDistance > metric.length) {
          if (draw) {
            final extractPath = metric.extractPath(distance, metric.length);
            canvas.drawPath(extractPath, paint);
          }
          break;
        }

        if (draw) {
          final extractPath = metric.extractPath(distance, nextDistance);
          canvas.drawPath(extractPath, paint);
        }

        distance = nextDistance;
        draw = !draw;
      }
    }
  }

  /// Draw dashed border around circle (for equipment)
  void _drawDashedCircleBorder(Canvas canvas, Rect rect) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;

    final paint = Paint()
      ..color = ColorManager.grey.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()..addOval(rect);

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;

      while (distance < metric.length) {
        final nextDistance = distance + (draw ? dashWidth : dashSpace);
        if (nextDistance > metric.length) {
          if (draw) {
            final extractPath = metric.extractPath(distance, metric.length);
            canvas.drawPath(extractPath, paint);
          }
          break;
        }

        if (draw) {
          final extractPath = metric.extractPath(distance, nextDistance);
          canvas.drawPath(extractPath, paint);
        }

        distance = nextDistance;
        draw = !draw;
      }
    }
  }

  /// Update ghost position (useful when previous scene changes)
  void updatePosition(Vector2 newPosition) {
    position = newPosition.clone();
  }

  /// Update ghost opacity
  void updateOpacity(double newOpacity) {
    // Recreate component with new opacity would be needed
    // For now, just note that this would require rebuilding
  }
}
