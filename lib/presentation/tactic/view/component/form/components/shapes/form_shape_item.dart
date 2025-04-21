import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

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
          ref.read(lineProvider.notifier).dismissActiveFormItem();
        } else {
          ref
              .read(lineProvider.notifier)
              .loadActiveShapeModelToAddIntoGameFieldEvent(
                shapeModel: widget.shapeModel,
              );
        }

        widget.onTap();
      },
      child: _buildShapeComponent(),
    );
  }

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
