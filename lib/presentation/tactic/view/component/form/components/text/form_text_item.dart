import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

class FormTextItem extends ConsumerStatefulWidget {
  const FormTextItem({super.key, required this.textModel, required this.onTap});
  final TextModel textModel;
  final VoidCallback onTap;

  @override
  ConsumerState<FormTextItem> createState() => _FormTextItemState();
}

class _FormTextItemState extends ConsumerState<FormTextItem> {
  @override
  Widget build(BuildContext context) {
    final lp = ref.watch(lineProvider);
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: _buildLineComponent(),
    );
  }

  Widget _buildLineComponent() {
    return RepaintBoundary(
      key: UniqueKey(),
      child: Center(
        child: Image.asset(
          "assets/images/${widget.textModel.imagePath}",
          color: ColorManager.white,
          height: AppSize.s32,
          width: AppSize.s32,
        ),
      ),
    );
  }
}
