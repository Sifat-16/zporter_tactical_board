import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
// Import necessary models
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
// Import the provider (adjust path/name if needed)
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

class FormItemSpeedDial extends ConsumerStatefulWidget {
  // *** MODIFIED: Accept generic FieldItemModel ***
  const FormItemSpeedDial({super.key, required this.formItem});
  final FieldItemModel formItem;

  @override
  ConsumerState<FormItemSpeedDial> createState() => _FormItemSpeedDialState();
}

class _FormItemSpeedDialState extends ConsumerState<FormItemSpeedDial> {
  @override
  Widget build(BuildContext context) {
    // Assume provider now has activatedFormItem and dismissActiveFormItem
    final lp = ref.watch(lineProvider);
    final bool isActiveItem = lp.activeForm?.id == widget.formItem.id;

    return GestureDetector(
      onTap: () {
        FieldItemModel fieldItemModel = widget.formItem;
        if (fieldItemModel is LineModelV2) {
          if (lp.isLineActiveToAddIntoGameField) {
            ref.read(lineProvider.notifier).dismissActiveFormItem();
          } else {
            ref
                .read(lineProvider.notifier)
                .loadActiveLineModelToAddIntoGameFieldEvent(
                  lineModelV2: fieldItemModel,
                );
          }
        } else if (fieldItemModel is ShapeModel) {
          if (lp.isShapeActiveToAddIntoGameField) {
            ref.read(lineProvider.notifier).dismissActiveFormItem();
          } else {
            ref
                .read(lineProvider.notifier)
                .loadActiveShapeModelToAddIntoGameFieldEvent(
                  shapeModel: fieldItemModel,
                );
          }
        }
      },
      child: _buildItemComponent(isFocused: isActiveItem), // Pass focus state
    );
  }

  // *** RENAMED and MODIFIED: Build based on item type ***
  Widget _buildItemComponent({required bool isFocused}) {
    String imagePath = "default_icon.png"; // Provide a default image path
    Color imageColor =
        isFocused
            ? ColorManager.red
            : ColorManager.white; // Use red when focused

    // Determine image path based on runtime type
    if (widget.formItem is LineModelV2) {
      imagePath = (widget.formItem as LineModelV2).imagePath;
    } else if (widget.formItem is ShapeModel) {
      imagePath = (widget.formItem as ShapeModel).imagePath;
      // You might want different focus color for shapes vs lines
      // imageColor = isFocused ? Colors.blue : ColorManager.white;
    }
    // Add more 'else if' blocks for other FieldItemModel types if needed

    return RepaintBoundary(
      key: UniqueKey(), // Consider using ValueKey(widget.formItem.id) if needed
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Show red border only when this specific item is the active one
            border: isFocused ? Border.all(color: ColorManager.red) : null,
          ),
          child: Image.asset(
            "assets/images/$imagePath", // Construct path
            color: imageColor, // Apply focus/default color
            height: AppSize.s24, // Adjusted size slightly for padding room
            width: AppSize.s24,
            errorBuilder:
                (context, error, stackTrace) => Icon(
                  Icons.error,
                  color: imageColor,
                  size: AppSize.s24, // Fallback icon
                ),
          ),
        ),
      ),
    );
  }
}
