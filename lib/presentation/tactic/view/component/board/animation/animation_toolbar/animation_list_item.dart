// --- Create a new file: animation_list_item.dart ---

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart'; // Adjust path
import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust path
// Import necessary models, components, managers
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/mini/mini_gamefield_widget.dart';

class AnimationListItem extends StatelessWidget {
  final AnimationModel animation;
  final VoidCallback onCopy;
  final VoidCallback onOpen;
  final VoidCallback onMoreOptions;
  final Color fieldColor;
  final Color borderColor;
  final VoidCallback onDelete;

  const AnimationListItem({
    super.key,
    required this.animation,
    required this.onDelete,
    required this.onCopy,
    required this.onOpen,
    required this.onMoreOptions,
    this.fieldColor = ColorManager.grey, // Default field color
    this.borderColor = ColorManager.black, // Default border color
  });

  @override
  Widget build(BuildContext context) {
    // Define styles based on image (adjust as needed)
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleSmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    final durationStyle = textTheme.bodyMedium?.copyWith(color: Colors.white);
    final indexStyle = textTheme.titleMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    final buttonTextStyle = textTheme.labelMedium!.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    // Calculate duration text (handle potential null)
    final String durationText =
        "${animation.animationScenes.length * 3}s"; // Assuming durationSeconds exists

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        color: ColorManager.black.withOpacity(0.8), // Dark card background
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    MiniGameFieldWidget(
                      fieldColor: fieldColor,
                      borderColor: borderColor,
                      items: [],
                      logicalFieldSize: Vector2(10000, 10000),
                      // aspectRatio: MiniGameFieldWidget.defaultAspectRatio, // Use default
                    ),

                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 4,
                        ),
                        child: Text(
                          animation.name,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(color: ColorManager.white),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 5,
                      child: CustomButton(
                        onTap: onCopy, // Use callback
                        fillColor: ColorManager.dark2,
                        padding: const EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 4,
                        ),
                        borderRadius: 4,
                        child: Text("COPY", style: buttonTextStyle),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 5,
                      child: CustomButton(
                        onTap: onOpen, // Use callback
                        fillColor: ColorManager.blue,
                        padding: const EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 4,
                        ),
                        borderRadius: 4,
                        child: Text("OPEN", style: buttonTextStyle),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10),

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PopupMenuButton(
                    color: ColorManager.dark2,
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              bool? confirm = await showConfirmationDialog(
                                context: context,
                                title: "Delete Animation",
                                content: "This animation will be removed",
                              );
                              if (confirm == true) {
                                onDelete();
                              }
                            },
                            child: Text(
                              "Delete",
                              style: Theme.of(
                                context,
                              ).textTheme.labelLarge!.copyWith(
                                color: ColorManager.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    child: Icon(Icons.more_vert, color: Colors.white),
                  ),

                  SizedBox(height: 10),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                      ), // TODO: Add functionality
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(durationText, style: durationStyle),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ), // TODO: Add functionality// Use passed index string
                    ],
                  ),

                  SizedBox(height: 10),

                  Text(
                    animation.animationScenes.length.toString(),
                    style: indexStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
