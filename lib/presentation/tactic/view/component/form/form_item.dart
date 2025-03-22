import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/line/form_line_item.dart';

class FormItem extends StatefulWidget {
  const FormItem({super.key, required this.formModel});

  final FormModel formModel;

  @override
  State<FormItem> createState() => _FormItemState();
}

class _FormItemState extends State<FormItem> {
  bool _isFocused = false;

  void _setFocus(bool focus) {
    setState(() {
      _isFocused = focus;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.formModel.formItemModel is LineModel ||
        widget.formModel.formItemModel is FreeDrawModel) {
      return FormLineItem(formModel: widget.formModel);
    } else {
      return GestureDetector(
        onTap: () => _setFocus(!_isFocused),
        child: Draggable<FormModel>(
          data: widget.formModel,
          onDragStarted: () => _setFocus(true),
          onDragEnd: (DraggableDetails details) {
            _setFocus(false);
          },
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: _buildEquipmentComponent(),
          ),
          feedback: Material(
            color: Colors.transparent,
            child: _buildEquipmentComponent(),
          ),
          child: _buildEquipmentComponent(),
        ),
      );
    }
  }

  Widget _buildEquipmentComponent() {
    return RepaintBoundary(
      key: UniqueKey(),
      child: Center(
        child: Image.asset(
          "assets/images/${widget.formModel.imagePath}",
          color: ColorManager.white,
          height: AppSize.s32,
          width: AppSize.s32,
        ),
      ),
    );
  }
}
