import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

class FormLineItem extends ConsumerStatefulWidget {
  const FormLineItem({super.key, required this.formModel});
  final FormModel formModel;

  @override
  ConsumerState<FormLineItem> createState() => _FormLineItemState();
}

class _FormLineItemState extends ConsumerState<FormLineItem> {
  @override
  Widget build(BuildContext context) {
    final lp = ref.watch(lineProvider);
    return GestureDetector(
      onTap: () {
        if (lp.isLineActiveToAddIntoGameField) {
          ref
              .read(lineProvider.notifier)
              .dismissActiveLineModelToAddIntoGameFieldEvent();
        } else {
          ref
              .read(lineProvider.notifier)
              .loadActiveLineModelToAddIntoGameFieldEvent(
                formModel: widget.formModel,
              );
        }
      },
      child: _buildLineComponent(
        isFocused:
            lp.isLineActiveToAddIntoGameField &&
            lp.activatedLineForm == widget.formModel,
      ),
    );
  }

  Widget _buildLineComponent({required bool isFocused}) {
    return RepaintBoundary(
      key: UniqueKey(),
      child: Center(
        child: Image.asset(
          "assets/images/${widget.formModel.imagePath}",
          color: isFocused ? ColorManager.yellowLight : ColorManager.white,
          height: AppSize.s32,
          width: AppSize.s32,
        ),
      ),
    );
  }
}
