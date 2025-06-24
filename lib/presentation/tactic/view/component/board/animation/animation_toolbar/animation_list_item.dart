// import 'package:flame/components.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
// import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust path
// // Import necessary models, components, managers
// import 'package:zporter_tactical_board/data/animation/model/animation_model.dart'; // Adjust path
// import 'package:zporter_tactical_board/presentation/tactic/view/component/field/mini/mini_gamefield_widget.dart';
//
// class AnimationListItem extends StatelessWidget {
//   final AnimationModel animation;
//   final VoidCallback onCopy;
//   final VoidCallback onOpen;
//   final VoidCallback onMoreOptions;
//   final Color fieldColor;
//   final Color borderColor;
//   final VoidCallback onDelete;
//
//   const AnimationListItem({
//     super.key,
//     required this.animation,
//     required this.onDelete,
//     required this.onCopy,
//     required this.onOpen,
//     required this.onMoreOptions,
//     this.fieldColor = ColorManager.grey, // Default field color
//     this.borderColor = ColorManager.black, // Default border color
//   });
//
//   double calculateTime(AnimationModel animationModel) {
//     int seconds = 0;
//     for (var a in animationModel.animationScenes) {
//       seconds += a.sceneDuration.inMilliseconds;
//     }
//     return seconds / 1000;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Define styles based on image (adjust as needed)
//     final textTheme = Theme.of(context).textTheme;
//     final titleStyle = textTheme.titleSmall?.copyWith(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//     );
//     final durationStyle = textTheme.bodyMedium?.copyWith(color: Colors.white);
//     final indexStyle = textTheme.titleMedium?.copyWith(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//     );
//     final buttonTextStyle = textTheme.labelMedium!.copyWith(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//     );
//
//     // Calculate duration text (handle potential null)
//     final String durationText =
//         "${calculateTime(animation).toStringAsFixed(1)}s"; // Assuming durationSeconds exists
//
//     return Card(
//       color: ColorManager.transparent, // Dark card background
//       elevation: 5,
//       margin: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//       clipBehavior: Clip.antiAlias,
//       child: Padding(
//         padding: EdgeInsets.all(8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Stack(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 14.0),
//                     child: MiniGameFieldWidget(
//                       fieldColor: fieldColor,
//                       borderColor: borderColor,
//                       items: [],
//                       logicalFieldSize: Vector2(10000, 10000),
//                       // aspectRatio: MiniGameFieldWidget.defaultAspectRatio, // Use default
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.topCenter,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 5,
//                         vertical: 4,
//                       ),
//                       child: Text(
//                         animation.name,
//                         maxLines: 2,
//                         style: Theme.of(context).textTheme.labelLarge!.copyWith(
//                               color: ColorManager.white,
//                             ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     left: 5,
//                     child: CustomButton(
//                       onTap: onCopy, // Use callback
//                       fillColor: ColorManager.darkGrey,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 5,
//                         horizontal: 10,
//                       ),
//                       borderRadius: 4,
//                       child: Text("COPY", style: buttonTextStyle),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 5,
//                     child: CustomButton(
//                       onTap: onOpen, // Use callback
//                       fillColor: ColorManager.blue,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 5,
//                         horizontal: 10,
//                       ),
//                       borderRadius: 4,
//                       child: Text("OPEN", style: buttonTextStyle),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 10),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 PopupMenuButton(
//                   color: ColorManager.dark2,
//                   itemBuilder: (context) {
//                     return [
//                       PopupMenuItem(
//                         child: TextButton(
//                           onPressed: () async {
//                             Navigator.pop(context);
//                             bool? confirm = await showConfirmationDialog(
//                               context: context,
//                               title: "Delete Animation",
//                               content: "This animation will be removed",
//                               confirmButtonText: "Delete",
//                               confirmButtonColor: ColorManager.red,
//                             );
//                             if (confirm == true) {
//                               onDelete();
//                             }
//                           },
//                           child: Text(
//                             "Delete",
//                             style: Theme.of(
//                               context,
//                             ).textTheme.labelLarge!.copyWith(
//                                   color: ColorManager.red,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                           ),
//                         ),
//                       ),
//                     ];
//                   },
//                   child: Icon(Icons.more_vert, color: Colors.white),
//                 ),
//                 SizedBox(height: 10),
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       FontAwesomeIcons.minus,
//                       color: Colors.white,
//                     ), // TODO: Add functionality
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 2.0),
//                       child: Text(durationText, style: durationStyle),
//                     ),
//                     const Icon(
//                       FontAwesomeIcons.minus,
//                       color: Colors.white,
//                     ), // TODO: Add functionality// Use passed index string
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   animation.animationScenes.length.toString(),
//                   style: indexStyle,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
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
    this.fieldColor = ColorManager.grey,
    this.borderColor = ColorManager.black,
  });

  static const double kButtonHeight = 28.0;
  static const double listItemHeight = 180.0; // Adjust as needed

  double calculateTime(AnimationModel animationModel) {
    int seconds = 0;
    for (var a in animationModel.animationScenes) {
      seconds += a.sceneDuration.inMilliseconds;
    }
    return seconds / 1000;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final durationStyle = textTheme.bodyMedium?.copyWith(color: Colors.white);
    final indexStyle = textTheme.titleMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    final buttonTextStyle = textTheme.labelMedium!.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    final String durationText =
        "${calculateTime(animation).toStringAsFixed(1)}s";

    return SizedBox(
      height: listItemHeight,
      child: Card(
        color: ColorManager.transparent,
        elevation: 5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double availableHeight = constraints.maxHeight;

                    if (!constraints.hasBoundedHeight || availableHeight <= 0) {
                      return const Center(
                        child: Text("Error: Invalid constraints",
                            style: TextStyle(color: Colors.red)),
                      );
                    }

                    final double fieldHeight = availableHeight * 0.9;
                    final double buttonBottomOffset =
                        (availableHeight * 0.1) - (kButtonHeight / 2);

                    return Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: fieldHeight,
                          child: MiniGameFieldWidget(
                            fieldColor: fieldColor,
                            boardBackground: animation.boardBackground,
                            borderColor: borderColor,
                            items: animation
                                    .animationScenes.firstOrNull?.components ??
                                [],
                            logicalFieldSize: animation.animationScenes
                                        .firstOrNull?.fieldSize ==
                                    Vector2.zero()
                                ? Vector2(10000, 10000)
                                : animation.animationScenes.firstOrNull
                                        ?.fieldSize ??
                                    Vector2(10000, 10000),
                          ),
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
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(
                                    color: ColorManager.white,
                                  ),
                            ),
                          ),
                        ),

                        // --- MODIFIED BUTTONS SECTION ---
                        Positioned(
                          bottom: buttonBottomOffset,
                          left:
                              5, // Keep overall padding from the edges of the card for the button area
                          right:
                              5, // Keep overall padding from the edges of the card for the button area
                          height:
                              kButtonHeight, // Constrain the height of the Row itself
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly, // This will space the buttons evenly
                            children: [
                              // COPY Button
                              // No need for SizedBox here if CustomButton has fixed height or Row constrains it
                              // but if CustomButton can vary, wrap with Flexible or Expanded if they need to grow.
                              // For just spacing intrinsic sized buttons, this is fine.
                              CustomButton(
                                // Assuming CustomButton takes the height from the Row or has intrinsic kButtonHeight
                                onTap: onCopy,
                                fillColor: ColorManager.darkGrey,
                                padding: const EdgeInsets.symmetric(
                                  vertical:
                                      5, // Internal padding of CustomButton
                                  horizontal: 20,
                                ),
                                borderRadius: 4,
                                child: Text("COPY", style: buttonTextStyle),
                              ),

                              // OPEN Button
                              CustomButton(
                                // Assuming CustomButton takes the height from the Row or has intrinsic kButtonHeight
                                onTap: onOpen,
                                fillColor: ColorManager.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical:
                                      5, // Internal padding of CustomButton
                                  horizontal: 20,
                                ),
                                borderRadius: 4,
                                child: Text("OPEN", style: buttonTextStyle),
                              ),
                            ],
                          ),
                        ),
                        // --- END OF MODIFIED BUTTONS SECTION ---
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PopupMenuButton(
                    color: ColorManager.dark2,
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'delete',
                          padding: EdgeInsets.zero,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              alignment: Alignment.centerLeft,
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              bool? confirm = await showConfirmationDialog(
                                context: context,
                                title: "Delete Animation",
                                content: "This animation will be removed",
                                confirmButtonText: "Delete",
                                confirmButtonColor: ColorManager.red,
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
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        FontAwesomeIcons.minus,
                        color: Colors.white,
                        size: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(durationText, style: durationStyle),
                      ),
                      const Icon(
                        FontAwesomeIcons.minus,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
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
