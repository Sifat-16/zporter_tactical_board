import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_bloc.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_event.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart';

class FormLineItem extends StatefulWidget {
  const FormLineItem({super.key, required this.formModel});
  final FormModel formModel;

  @override
  State<FormLineItem> createState() => _FormLineItemState();
}

class _FormLineItemState extends State<FormLineItem> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LineBloc, LineState>(
      listener: (BuildContext context, LineState state) {},
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            if (state.isLineActiveToAddIntoGameField) {
              context.read<LineBloc>().add(
                DismissActiveLineModelToAddIntoGameFieldEvent(),
              );
            } else {
              context.read<LineBloc>().add(
                LoadActiveLineModelToAddIntoGameFieldEvent(
                  formModel: widget.formModel,
                ),
              );
            }
          },
          child: _buildLineComponent(
            isFocused: state.isLineActiveToAddIntoGameField,
          ),
        );
      },
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
