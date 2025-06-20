import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class EquipmentItem extends ConsumerStatefulWidget {
  const EquipmentItem({super.key, required this.equipmentModel});

  final EquipmentModel equipmentModel;

  @override
  ConsumerState<EquipmentItem> createState() => _EquipmentItemState();
}

class _EquipmentItemState extends ConsumerState<EquipmentItem> {
  bool _isFocused = false;

  void _setFocus(bool focus) {
    setState(() {
      _isFocused = focus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _setFocus(!_isFocused),
      child: Draggable<EquipmentModel>(
        data: widget.equipmentModel,
        onDragStarted: () {
          _setFocus(true);
          ref
              .read(boardProvider.notifier)
              .updateDraggingToBoard(isDragging: true);
        },
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

  Widget _buildEquipmentComponent() {
    return RepaintBoundary(
      key: UniqueKey(),
      child: Center(
        child: Image.asset(
          "assets/images/${widget.equipmentModel.imagePath}",
          color: ColorManager.white,
          height: AppSize.s32,
          width: AppSize.s32,
        ),
      ),
    );
  }
}
