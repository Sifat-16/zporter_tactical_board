// import 'package:flame/components.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust path
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/field/mini/mini_gamefield_widget.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
//
// class AnimationSceneItem extends ConsumerStatefulWidget {
//   final AnimationItemModel animation;
//   final VoidCallback onMoreOptions;
//   final Color fieldColor;
//   final Color borderColor;
//   final bool isSelected;
//   final VoidCallback onItemTap;
//   final VoidCallback onDelete;
//
//   const AnimationSceneItem({
//     super.key,
//     required this.onDelete,
//     required this.animation,
//     required this.isSelected,
//     required this.onItemTap,
//     required this.onMoreOptions,
//     this.fieldColor = ColorManager.grey, // Default field color
//     this.borderColor = ColorManager.black, // Default border color
//   });
//
//   @override
//   ConsumerState<AnimationSceneItem> createState() => _AnimationSceneItemState();
// }
//
// class _AnimationSceneItemState extends ConsumerState<AnimationSceneItem> {
//   String durationText = "";
//   int durationStepMilliseconds = 500;
//   int minDurationMilliseconds = 500; // 0.5 seconds
//   int maxDurationMilliseconds = 4000; // 4.0 seconds
//   int currentDurationInMills = 0;
//   @override
//   void initState() {
//     currentDurationInMills = widget.animation.sceneDuration.inMilliseconds;
//     durationText = "${(currentDurationInMills / 1000.0).toStringAsFixed(1)}s";
//     super.initState();
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
//     return GestureDetector(
//       onTap: widget.onItemTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//         child: Card(
//           color: ColorManager.black.withOpacity(0.8), // Dark card background
//           elevation: 0,
//           margin: EdgeInsets.zero,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(4),
//             side: BorderSide(
//               color: widget.isSelected
//                   ? ColorManager.yellowLight.withValues(alpha: 0.6)
//                   : ColorManager.transparent,
//             ),
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: Padding(
//             padding: EdgeInsets.all(12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Stack(
//                     children: [
//                       MiniGameFieldWidget(
//                         fieldColor: widget.fieldColor,
//                         borderColor: widget.borderColor,
//                         items: widget.animation.components,
//                         boardBackground: widget.animation.boardBackground,
//                         logicalFieldSize:
//                             widget.animation.fieldSize == Vector2.zero()
//                                 ? Vector2(10000, 10000)
//                                 : widget.animation.fieldSize,
//                         // aspectRatio: MiniGameFieldWidget.defaultAspectRatio, // Use default
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     PopupMenuButton(
//                       color: ColorManager.dark2,
//                       itemBuilder: (context) {
//                         return [
//                           PopupMenuItem(
//                             child: TextButton(
//                               onPressed: () async {
//                                 Navigator.pop(context);
//                                 bool? confirm = await showConfirmationDialog(
//                                   context: context,
//                                   title: "Delete Scene",
//                                   content:
//                                       "This animation scene will be removed",
//                                 );
//                                 if (confirm == true) {
//                                   widget.onDelete();
//                                 }
//                               },
//                               child: Text(
//                                 "Delete",
//                                 style: Theme.of(
//                                   context,
//                                 ).textTheme.labelLarge!.copyWith(
//                                       color: ColorManager.red,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                               ),
//                             ),
//                           ),
//                         ];
//                       },
//                       child: Icon(Icons.more_vert, color: Colors.white),
//                     ),
//                     SizedBox(height: 10),
//                     Column(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             int currentMillis = currentDurationInMills;
//                             int newMillis =
//                                 currentMillis + durationStepMilliseconds;
//                             if (newMillis > maxDurationMilliseconds) {
//                               newMillis = maxDurationMilliseconds;
//                             } else {
//                               if (newMillis != currentMillis) {
//                                 setState(() {
//                                   currentDurationInMills = newMillis;
//                                   durationText =
//                                       "${(currentDurationInMills / 1000.0).toStringAsFixed(1)}s";
//                                 });
//                                 ref
//                                     .read(animationProvider.notifier)
//                                     .saveAnimationTime(
//                                       newDuration: Duration(
//                                         milliseconds: newMillis,
//                                       ),
//                                       sceneId: widget.animation.id,
//                                     );
//                                 zlog(
//                                   data:
//                                       "Increase duration tapped. New duration: ${newMillis}ms",
//                                 );
//                               }
//                             }
//                           },
//                           child: const Icon(
//                             Icons.keyboard_arrow_up,
//                             color: Colors.white,
//                           ),
//                         ), // TODO: Add functionality
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 2.0),
//                           child: Text(durationText, style: durationStyle),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             int currentMillis = currentDurationInMills;
//                             int newMillis =
//                                 currentMillis - durationStepMilliseconds;
//                             if (newMillis < minDurationMilliseconds) {
//                               newMillis = minDurationMilliseconds;
//                             } else {
//                               if (newMillis != currentMillis) {
//                                 setState(() {
//                                   currentDurationInMills = newMillis;
//                                   durationText =
//                                       "${(currentDurationInMills / 1000.0).toStringAsFixed(1)}s";
//                                 });
//
//                                 ref
//                                     .read(animationProvider.notifier)
//                                     .saveAnimationTime(
//                                       newDuration: Duration(
//                                         milliseconds: newMillis,
//                                       ),
//                                       sceneId: widget.animation.id,
//                                     );
//                               }
//                               zlog(
//                                 data:
//                                     "Decrease duration tapped. New duration: ${newMillis}ms",
//                               );
//                             }
//                           },
//                           child: const Icon(
//                             Icons.keyboard_arrow_down,
//                             color: Colors.white,
//                           ),
//                         ), // TODO: Add functionality// Use passed index string
//                       ],
//                     ),
//                     SizedBox(height: 10),
//                     Container(),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/mini/mini_gamefield_widget.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';

class AnimationSceneItem extends ConsumerStatefulWidget {
  final AnimationItemModel animation;
  final VoidCallback onMoreOptions;
  final Color fieldColor;
  final Color borderColor;
  final bool isSelected;
  final VoidCallback onItemTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate; // ADDED
  final VoidCallback onInsertBlank; // ADDED
  final int sceneIndex;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  const AnimationSceneItem({
    super.key,
    required this.onDelete,
    required this.animation,
    required this.isSelected,
    required this.onItemTap,
    required this.onMoreOptions,
    required this.sceneIndex,
    required this.isFirst,
    required this.isLast,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDuplicate, // ADDED
    required this.onInsertBlank, // ADDED
    this.fieldColor = ColorManager.grey, // Default field color
    this.borderColor = ColorManager.black, // Default border color
  });

  @override
  ConsumerState<AnimationSceneItem> createState() => _AnimationSceneItemState();
}

class _AnimationSceneItemState extends ConsumerState<AnimationSceneItem> {
  String durationText = "";
  int durationStepMilliseconds = 500;
  int minDurationMilliseconds = 500; // 0.5 seconds
  int maxDurationMilliseconds = 4000; // 4.0 seconds
  int currentDurationInMills = 0;
  @override
  void initState() {
    currentDurationInMills = widget.animation.sceneDuration.inMilliseconds;
    durationText = "${(currentDurationInMills / 1000.0).toStringAsFixed(1)}s";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Define styles
    final textTheme = Theme.of(context).textTheme;
    final durationStyle = textTheme.bodyMedium?.copyWith(color: Colors.white);
    final indexStyle = textTheme.titleMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    return GestureDetector(
      onTap: widget.onItemTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Card(
          color: ColorManager.black.withOpacity(0.8),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: widget.isSelected
                  ? ColorManager.yellowLight.withValues(alpha: 0.6)
                  : ColorManager.transparent,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mini Game Field Preview
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: MiniGameFieldWidget(
                      fieldColor: widget.fieldColor,
                      borderColor: widget.borderColor,
                      items: widget.animation.components,
                      boardBackground: widget.animation.boardBackground,
                      logicalFieldSize: widget.animation.fieldSize ==
                              Vector2.zero()
                          ? Vector2(1280, 720) // Provide a default logical size
                          : widget.animation.fieldSize,
                    ),
                  ),
                ),
                SizedBox(width: 10),

                // All controls on the right side
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // More options (Delete)
                    PopupMenuButton(
                      color: ColorManager.dark2,
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            onTap: widget.onDuplicate,
                            // child: Text(
                            //   "Duplicate Scene",
                            //   style: Theme.of(context)
                            //       .textTheme
                            //       .labelMedium!
                            //       .copyWith(
                            //         color: ColorManager.white,
                            //       ),
                            // ),
                            child: TextButton(
                              onPressed: null,
                              child: Text(
                                "Duplicate Scene",
                                style: Theme.of(
                                  context,
                                ).textTheme.labelLarge!.copyWith(
                                      color: ColorManager.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            onTap: widget.onInsertBlank,
                            child: TextButton(
                              onPressed: null,
                              child: Text(
                                "Insert Blank Scene",
                                style: Theme.of(
                                  context,
                                ).textTheme.labelLarge!.copyWith(
                                      color: ColorManager.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            child: TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                bool? confirm = await showConfirmationDialog(
                                  context: context,
                                  title: "Delete Scene",
                                  content:
                                      "This animation scene will be removed",
                                );
                                if (confirm == true) {
                                  widget.onDelete();
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

                    // Timing Controls
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            int currentMillis = currentDurationInMills;
                            int newMillis =
                                currentMillis + durationStepMilliseconds;
                            if (newMillis > maxDurationMilliseconds) {
                              newMillis = maxDurationMilliseconds;
                            }
                            if (newMillis != currentMillis) {
                              setState(() {
                                currentDurationInMills = newMillis;
                                durationText =
                                    "${(currentDurationInMills / 1000.0).toStringAsFixed(1)}s";
                              });
                              ref
                                  .read(animationProvider.notifier)
                                  .saveAnimationTime(
                                    newDuration: Duration(
                                      milliseconds: newMillis,
                                    ),
                                    sceneId: widget.animation.id,
                                  );
                            }
                          },
                          child: const Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(durationText, style: durationStyle),
                        ),
                        GestureDetector(
                          onTap: () {
                            int currentMillis = currentDurationInMills;
                            int newMillis =
                                currentMillis - durationStepMilliseconds;
                            if (newMillis < minDurationMilliseconds) {
                              newMillis = minDurationMilliseconds;
                            }
                            if (newMillis != currentMillis) {
                              setState(() {
                                currentDurationInMills = newMillis;
                                durationText =
                                    "${(currentDurationInMills / 1000.0).toStringAsFixed(1)}s";
                              });

                              ref
                                  .read(animationProvider.notifier)
                                  .saveAnimationTime(
                                    newDuration: Duration(
                                      milliseconds: newMillis,
                                    ),
                                    sceneId: widget.animation.id,
                                  );
                            }
                          },
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    // NEW: Index and Reorder Controls
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // InkWell(
                        //   onTap: widget.isFirst ? null : widget.onMoveUp,
                        //   child: Icon(
                        //     Icons.keyboard_arrow_up_sharp,
                        //     size: 28,
                        //     color: widget.isFirst
                        //         ? Colors.white.withOpacity(0.3)
                        //         : Colors.white,
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '${widget.sceneIndex}', // Display index
                            style: indexStyle,
                          ),
                        ),
                        // InkWell(
                        //   onTap: widget.isLast ? null : widget.onMoveDown,
                        //   child: Icon(
                        //     Icons.keyboard_arrow_down_sharp,
                        //     size: 28,
                        //     color: widget.isLast
                        //         ? Colors.white.withOpacity(0.3)
                        //         : Colors.white,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
