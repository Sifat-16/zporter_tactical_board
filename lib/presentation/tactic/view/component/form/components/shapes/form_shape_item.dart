import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart';

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
    final lp = ref.watch(lineProvider);
    return GestureDetector(
      onTap: () {
        if (lp.isShapeActiveToAddIntoGameField) {
          String? activeId = ref.read(lineProvider).activeId;

          if (activeId == widget.shapeModel.id) {
            ref.read(lineProvider.notifier).dismissActiveFormItem();
          } else {
            ref.read(lineProvider.notifier).dismissActiveFormItem();
            ref
                .read(lineProvider.notifier)
                .loadActiveShapeModelToAddIntoGameFieldEvent(
                  shapeModel: widget.shapeModel,
                );
          }
        } else {
          ref
              .read(lineProvider.notifier)
              .loadActiveShapeModelToAddIntoGameFieldEvent(
                shapeModel: widget.shapeModel,
              );
        }

        widget.onTap();
      },
      child: _buildShapeComponent(isFocusedWidget(lp)),
    );
  }

  bool isFocusedWidget(LineState lsp) {
    if (lsp.isShapeActiveToAddIntoGameField) {
      FieldItemModel? fim = lsp.activeForm;
      if (fim is ShapeModel) {
        if (fim.fieldItemType == widget.shapeModel.fieldItemType) {
          if (fim is PolygonShapeModel) {
            if (fim.imagePath == widget.shapeModel.imagePath) {
              return true;
            } else {
              return false;
            }
          } else {
            return true;
          }
        }
      }
    }
    return false;
  }

  Widget _buildShapeComponent(bool isFocused) {
    return RepaintBoundary(
      key: UniqueKey(),
      child: Center(
        child: Image.asset(
          "assets/images/${widget.shapeModel.imagePath}",
          color: isFocused ? ColorManager.yellow : ColorManager.white,
          height: AppSize.s32,
          width: AppSize.s32,
        ),
      ),
    );
  }
}
