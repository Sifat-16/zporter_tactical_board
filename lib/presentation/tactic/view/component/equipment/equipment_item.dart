// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/app/manager/values_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
//
// class EquipmentItem extends ConsumerStatefulWidget {
//   const EquipmentItem({super.key, required this.equipmentModel});
//
//   final EquipmentModel equipmentModel;
//
//   @override
//   ConsumerState<EquipmentItem> createState() => _EquipmentItemState();
// }
//
// class _EquipmentItemState extends ConsumerState<EquipmentItem> {
//   bool _isFocused = false;
//
//   void _setFocus(bool focus) {
//     setState(() {
//       _isFocused = focus;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _setFocus(!_isFocused),
//       child: Draggable<EquipmentModel>(
//         data: widget.equipmentModel,
//         onDragStarted: () {
//           _setFocus(true);
//           ref
//               .read(boardProvider.notifier)
//               .updateDraggingToBoard(isDragging: true);
//         },
//         onDragEnd: (DraggableDetails details) {
//           _setFocus(false);
//         },
//         childWhenDragging: Opacity(
//           opacity: 0.5,
//           child: _buildEquipmentComponent(),
//         ),
//         feedback: Material(
//           color: Colors.transparent,
//           child: _buildEquipmentComponent(),
//         ),
//         child: _buildEquipmentComponent(),
//       ),
//     );
//   }
//
//   Widget _buildEquipmentComponent() {
//     return RepaintBoundary(
//       key: UniqueKey(),
//       child: Center(
//         child: Image.asset(
//           "assets/images/${widget.equipmentModel.imagePath}",
//           color: widget.equipmentModel.color ?? ColorManager.white,
//           height: AppSize.s32,
//           width: AppSize.s32,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class EquipmentItem extends ConsumerStatefulWidget {
  const EquipmentItem({
    super.key,
    required this.equipmentModel,
    // --- NEW: Add an optional parameter to control layout behavior ---
    this.isExpanded = false,
  });

  final EquipmentModel equipmentModel;
  final bool isExpanded;

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
    // --- MODIFICATION: Check the isExpanded flag to change layout ---
    if (widget.isExpanded) {
      // For the expanded item, we don't fix the size.
      // We let the parent container define the size, and the image will fit
      // within it, preserving its aspect ratio.
      return Padding(
        padding:
            const EdgeInsets.all(8.0), // Add some padding for better visuals
        child: Image.asset(
          "assets/images/${widget.equipmentModel.imagePath}",
          color: widget.equipmentModel.color ?? ColorManager.white,
          fit: BoxFit.contain, // This is key to prevent distortion.
        ),
      );
    }

    // This is the original layout for all standard grid items.
    return RepaintBoundary(
      key: UniqueKey(),
      child: Center(
        child: Image.asset(
          "assets/images/${widget.equipmentModel.imagePath}",
          color: widget.equipmentModel.color ?? ColorManager.white,
          height: AppSize.s32,
          width: AppSize.s32,
        ),
      ),
    );
  }
}
