import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';

// --- IMPORTS ---
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/shape_generator.dart';
import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';
// --- END IMPORTS ---

class FormShapeItem extends ConsumerStatefulWidget {
  const FormShapeItem({
    super.key,
    required this.shapeModel,
    required this.onTap,
  });
  final ShapeModel shapeModel;
  final VoidCallback onTap;

  @override
  ConsumerState<FormShapeItem> createState() => _FormShapeItemState();
}

class _FormShapeItemState extends ConsumerState<FormShapeItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 1. Get game instance and ALL relevant sizes
        final TacticBoardGame? game = ref.read(boardProvider).tacticBoardGame;
        final Vector2? gameWidgetSize =
            game?.size; // The size of the whole game area
        final Vector2? gameFieldSize =
            game?.gameField.size; // The size of the field itself

        // 2. Safety check
        if (game == null ||
            gameWidgetSize == null ||
            gameFieldSize == null ||
            gameWidgetSize == Vector2.zero() ||
            gameFieldSize == Vector2.zero()) {
          zlog(data: "Game not ready, cannot add shape.");
          return;
        }

        // 3. Calculate center
        //
        //    *** THIS IS THE FINAL, CORRECT LOGIC ***
        //    We must use the center of the WIDGET (gameWidgetSize).
        //
        final Vector2 visualCenter = (gameWidgetSize - Vector2(0, 22.5)) / 2;

        // 4. Determine which shape to create
        final ShapeModel shape = widget.shapeModel;
        FieldItemModel? newShape;

        // We use gameFieldSize for relative conversion, but visualCenter for positioning
        if (shape.imagePath == 'circle.png') {
          newShape = createDefaultCircle(
            gameSize: gameFieldSize,
            visualCenter: visualCenter,
          );
        } else if (shape.imagePath == 'square.png') {
          newShape = createDefaultSquare(
            gameSize: gameFieldSize,
            visualCenter: visualCenter,
          );
        } else if (shape.imagePath == 'triangle.png') {
          newShape = createDefaultTriangle(
            gameSize: gameFieldSize,
            center: visualCenter,
          );
        } else if (shape.imagePath == 'polygon.png') {
          newShape = createDefaultOctagon(
            gameSize: gameFieldSize,
            center: visualCenter,
          );
        }

        // 5. Add the new shape to the game
        if (newShape != null) {
          game.addItem(newShape);
        } else {
          zlog(data: "Could not create default shape for ${shape.name}");
        }

        // 6. Dismiss any active tool
        ref.read(lineProvider.notifier).dismissActiveFormItem();

        // 7. Call original onTap
        widget.onTap();
      },
      child: _buildShapeComponent(),
    );
  }

  // This component now just displays the icon
  Widget _buildShapeComponent() {
    return RepaintBoundary(
      key: UniqueKey(),
      child: Center(
        child: Image.asset(
          "assets/images/${widget.shapeModel.imagePath}",
          color: ColorManager.white,
          height: AppSize.s32,
          width: AppSize.s32,
        ),
      ),
    );
  }
}
