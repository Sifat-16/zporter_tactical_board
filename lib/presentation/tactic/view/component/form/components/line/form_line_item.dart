import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart';

class FormLineItem extends ConsumerStatefulWidget {
  const FormLineItem({
    super.key,
    required this.lineModelV2,
    required this.onTap,
  });
  final LineModelV2 lineModelV2;
  final VoidCallback onTap;

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
          String? activeId = ref.read(lineProvider).activeId;
          if (activeId == widget.lineModelV2.id) {
            ref.read(lineProvider.notifier).dismissActiveFormItem();
          } else {
            ref.read(lineProvider.notifier).dismissActiveFormItem();
            ref
                .read(lineProvider.notifier)
                .loadActiveLineModelToAddIntoGameFieldEvent(
                  lineModelV2: widget.lineModelV2,
                );
          }
        } else {
          ref
              .read(lineProvider.notifier)
              .loadActiveLineModelToAddIntoGameFieldEvent(
                lineModelV2: widget.lineModelV2,
              );
        }

        widget.onTap();
      },
      child: _buildLineComponent(isFocused: isFocusedWidget(lp)),
    );
  }

  bool isFocusedWidget(LineState lsp) {
    if (lsp.isLineActiveToAddIntoGameField) {
      FieldItemModel? fim = lsp.activeForm;

      if (fim is LineModelV2) {
        if (fim.lineType == widget.lineModelV2.lineType) {
          return true;
        }
      }
    }
    return false;
  }

  Widget _buildLineComponent({required bool isFocused}) {
    return RepaintBoundary(
      key: UniqueKey(),
      child: Center(
        child: Image.asset(
          "assets/images/${widget.lineModelV2.imagePath}",
          color: isFocused ? ColorManager.yellowLight : ColorManager.white,
          height: AppSize.s32,
          width: AppSize.s32,
        ),
      ),
    );
  }
}
