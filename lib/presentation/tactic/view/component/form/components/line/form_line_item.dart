import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

class FormLineItem extends ConsumerStatefulWidget {
  const FormLineItem({super.key, required this.formModel, required this.onTap});
  final FormModel formModel;
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

        widget.onTap();
      },
      child: _buildLineComponent(
        isFocused:
            lp.isLineActiveToAddIntoGameField &&
            lp.activatedFormId == widget.formModel.id,
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

class FormItemSpeedDial extends ConsumerStatefulWidget {
  const FormItemSpeedDial({super.key, required this.formModel});
  final FormModel formModel;

  @override
  ConsumerState<FormItemSpeedDial> createState() => _FormItemSpeedDialState();
}

class _FormItemSpeedDialState extends ConsumerState<FormItemSpeedDial> {
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
            lp.activatedFormId == widget.formModel.id,
      ),
    );
  }

  Widget _buildLineComponent({required bool isFocused}) {
    return RepaintBoundary(
      key: UniqueKey(),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ColorManager.white),
          ),
          child: Stack(
            children: [
              Image.asset(
                "assets/images/${widget.formModel.imagePath}",
                color: ColorManager.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
