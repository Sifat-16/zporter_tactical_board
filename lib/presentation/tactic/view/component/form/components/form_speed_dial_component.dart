import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/animation/model/history_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_history_stream_usecase.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/shapes/form_shape_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/line_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/shape_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/animation_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart'; // Ensure ActiveTool is here or imported
import 'package:zporter_tactical_board/presentation/tutorials/tutorial_keys.dart';

import 'form_item_speed_dial.dart';
import 'line/form_line_item.dart';

class FormSpeedDialComponent extends ConsumerStatefulWidget {
  const FormSpeedDialComponent({super.key, required this.tacticBoardGame});

  final TacticBoardGame tacticBoardGame;

  @override
  ConsumerState<FormSpeedDialComponent> createState() =>
      _FormSpeedDialComponentState();
}

class _FormSpeedDialComponentState
    extends ConsumerState<FormSpeedDialComponent> {
  List<LineModelV2> lines = [];
  List<ShapeModel> shapes = [];

  final GetHistoryStreamUseCase _historyStream =
      sl.get<GetHistoryStreamUseCase>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setupForms();
    });
  }

  void setupForms() {
    setState(() {
      lines = LineUtils.generateLines();
      shapes = ShapeUtils.generateShapes();
    });
  }

  void _showActionGrid(BuildContext context) {
    if (lines.isEmpty && shapes.isEmpty) {
      setupForms();
    }

    final totalItems = lines.length + shapes.length;
    final lineNotifier = ref.read(lineProvider.notifier); // Get notifier

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: ColorManager.dark2.withValues(alpha: 0.8),
      builder: (BuildContext bottomSheetContext) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          height: screenHeight * 0.6,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: ColorManager.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                'Select Action',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: totalItems,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (BuildContext gridContext, int index) {
                    if (index < lines.length) {
                      final lineModel = lines[index];
                      return FormLineItem(
                        lineModelV2: lineModel,
                        onTap: () {
                          // Use the lineNotifier to load the selected line
                          lineNotifier
                              .loadActiveLineModelToAddIntoGameFieldEvent(
                                lineModelV2: lineModel,
                              );
                          Navigator.pop(bottomSheetContext);
                        },
                      );
                    } else {
                      final shapeIndex = index - lines.length;
                      if (shapeIndex < shapes.length) {
                        final shapeModel = shapes[shapeIndex];
                        return FormShapeItem(
                          shapeModel: shapeModel,
                          onTap: () {
                            // Use the lineNotifier to load the selected shape
                            lineNotifier
                                .loadActiveShapeModelToAddIntoGameFieldEvent(
                                  shapeModel: shapeModel,
                                );
                            Navigator.pop(bottomSheetContext);
                          },
                        );
                      } else {
                        return Container(color: Colors.red); // Error indicator
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lpState = ref.watch(lineProvider);
    final lpNotifier = ref.read(lineProvider.notifier);
    final ap = ref.watch(animationProvider);
    final bp = ref.watch(boardProvider);
    final AnimationItemModel? selectedScene = ap.selectedScene;
    AnimationCollectionModel? collectionModel =
        ap.selectedAnimationCollectionModel;
    AnimationModel? animationModel = ap.selectedAnimationModel;
    final GetHistoryStreamUseCase historyStream =
        sl.get<GetHistoryStreamUseCase>();

    final currentActiveTool = lpState.activeTool;
    final bool isPlacingItem =
        lpState.activeForm != null && currentActiveTool == ActiveTool.pointer;

    // Define colors for active, inactive, and dimmed states
    Color activeColor = ColorManager.white;
    Color defaultInactiveColor = ColorManager.white;
    Color dimmedInactiveColor = ColorManager.white;

    return Container(
      width: context.widthPercent(90),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          // --- LEFT SIDE BUTTONS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  ref.read(boardProvider.notifier).toggleFullScreen();
                },
                child: Icon(
                  bp.showFullScreen == false
                      ? Icons.fullscreen
                      : Icons.fullscreen_exit,
                  color: ColorManager.white,
                ),
              ),
              const SizedBox(width: 10), // Spacing
              GestureDetector(
                onTap: () {
                  // TODO: Implement share functionality
                },
                child: Icon(Icons.share, color: ColorManager.grey),
              ),
            ],
          ),

          // --- CENTER TOOL BUTTONS ---
          Row(
            mainAxisSize: MainAxisSize.min,
            // spacing: 20, // Use SizedBox for spacing
            children: [
              // --- Pointer / Select Item Button ---
              GestureDetector(
                onTap: () {
                  if (isPlacingItem) {
                    lpNotifier.dismissActiveFormItem();
                  } else if (currentActiveTool == ActiveTool.pointer) {
                    _showActionGrid(context);
                  } else {
                    lpNotifier.setActiveTool(ActiveTool.pointer);
                    _showActionGrid(context);
                  }
                },
                child:
                    lpState.activeForm != null &&
                            currentActiveTool == ActiveTool.pointer
                        ? _buildFormWidget(fieldItemModel: lpState.activeForm!)
                        : Center(
                          child: Icon(
                            FontAwesomeIcons.arrowPointer,
                            color:
                                (currentActiveTool == ActiveTool.pointer &&
                                        !isPlacingItem)
                                    ? activeColor
                                    : isPlacingItem
                                    ? activeColor // Highlight if pointer is busy placing an item
                                    : defaultInactiveColor,
                          ),
                        ),
              ),
              const SizedBox(width: 20),

              // --- Free Draw Button ---
              GestureDetector(
                onTap: () {
                  lpNotifier.toggleFreeDraw();
                },
                child: _buildFreeDrawComponent(
                  isFocused: currentActiveTool == ActiveTool.freeDraw,
                  isDimmed:
                      (currentActiveTool != ActiveTool.freeDraw &&
                          currentActiveTool != ActiveTool.pointer) ||
                      isPlacingItem,
                ),
              ),
              const SizedBox(width: 20),

              // --- Eraser Button ---
              GestureDetector(
                onTap: () {
                  lpNotifier.toggleEraser();
                },
                child: Icon(
                  FontAwesomeIcons.eraser,
                  color:
                      currentActiveTool == ActiveTool.eraser
                          ? ColorManager.red
                          : (currentActiveTool != ActiveTool.eraser &&
                                  currentActiveTool != ActiveTool.pointer) ||
                              isPlacingItem
                          ? dimmedInactiveColor
                          : defaultInactiveColor,
                ),
              ),
              const SizedBox(width: 20),

              // --- Undo Button ---
              if (selectedScene != null)
                StreamBuilder(
                  stream: _historyStream.call(selectedScene.id),
                  builder: (context, snapshot) {
                    HistoryModel? history = snapshot.data;

                    if (history == null) {
                      return SizedBox.shrink();
                    } else {
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(animationProvider.notifier)
                              .performUndoOperation();
                        },
                        child: Icon(
                          FontAwesomeIcons.arrowRotateLeft,
                          color: ColorManager.white,
                        ),
                      );
                    }
                  },
                ),
              if (selectedScene != null) const SizedBox(width: 20),

              // --- Trash Button ---
              GestureDetector(
                onTap: () {
                  ref.read(boardProvider.notifier).removeElement();
                },
                child: _buildTrashComponent(
                  isFocused: currentActiveTool == ActiveTool.trash,
                  isDimmed:
                      (currentActiveTool != ActiveTool.trash &&
                          currentActiveTool != ActiveTool.pointer) ||
                      isPlacingItem,
                ),
              ),
            ],
          ),

          // --- RIGHT SIDE BUTTONS ---
          Row(
            // spacing: 10, // Use SizedBox
            children: [
              if (animationModel != null)
                Builder(
                  builder: (context) {
                    final Object heroTag =
                        'anim_${animationModel.id.toString()}';
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AnimationScreen(
                                  animationModel: animationModel,
                                  heroTag: heroTag,
                                ),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.play_circle_outline,
                        color: ColorManager.white,
                      ),
                    );
                  },
                ),
              if (animationModel != null) const SizedBox(width: 10),
              _buildAddNewScene(
                keyForTutorial: TutorialKeys.addNewSceneButtonKey,
                selectedCollection: collectionModel,
                selectedAnimation: animationModel,
                selectedScene: selectedScene,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormWidget({required FieldItemModel fieldItemModel}) {
    return FormItemSpeedDial(formItem: fieldItemModel);
  }

  // Widget _buildAddNewScene({
  //   required AnimationCollectionModel? selectedCollection,
  //   required AnimationModel? selectedAnimation,
  //   required AnimationItemModel? selectedScene,
  // }) {
  //   return GestureDetector(
  //     onTap: () {
  //       if (selectedCollection == null || selectedAnimation == null) {
  //         if (ref.read(boardProvider).showFullScreen) {
  //           ref.read(boardProvider.notifier).toggleFullScreen();
  //         }
  //         ref.read(animationProvider.notifier).showQuickSave();
  //       } else {
  //         try {
  //           // Ensure selectedScene is not null before calling addNewScene if it's required
  //           if (selectedScene != null) {
  //             ref
  //                 .read(animationProvider.notifier)
  //                 .addNewScene(
  //                   selectedCollection: selectedCollection,
  //                   selectedAnimation: selectedAnimation,
  //                   selectedScene: selectedScene,
  //                 );
  //           } else {
  //             BotToast.showText(
  //               text: "Cannot add new scene: No current scene selected.",
  //             );
  //           }
  //         } catch (e) {
  //           BotToast.showText(text: "Error adding new scene: $e");
  //         }
  //       }
  //     },
  //     child: Icon(Icons.add_circle_outline, color: ColorManager.white),
  //   );
  // }

  Widget _buildAddNewScene({
    required AnimationCollectionModel? selectedCollection,
    required AnimationModel? selectedAnimation,
    required AnimationItemModel? selectedScene,
    GlobalKey? keyForTutorial, // Add key parameter
  }) {
    return GestureDetector(
      key: keyForTutorial, // Assign the key here
      onTap: () {
        // This is the action we need to trigger from the tutorial
        if (selectedCollection == null || selectedAnimation == null) {
          if (ref.read(boardProvider).showFullScreen) {
            ref.read(boardProvider.notifier).toggleFullScreen();
          }
          ref.read(animationProvider.notifier).showQuickSave();
        } else {
          try {
            if (selectedScene != null) {
              ref
                  .read(animationProvider.notifier)
                  .addNewScene(
                    selectedCollection: selectedCollection,
                    selectedAnimation: selectedAnimation,
                    selectedScene: selectedScene,
                  );
            } else {
              BotToast.showText(
                text: "Cannot add new scene: No current scene selected.",
              );
            }
          } catch (e) {
            BotToast.showText(text: "Error adding new scene: $e");
          }
        }
      },
      child: Icon(Icons.add_circle_outline, color: ColorManager.white),
    );
  }

  Widget _buildFreeDrawComponent({
    required bool isFocused,
    required bool isDimmed,
  }) {
    Color activeColor = ColorManager.red;
    Color defaultColor = ColorManager.white;
    Color dimmedColor = ColorManager.white;

    Color colorToUse;
    BoxBorder? borderToUse;

    if (isFocused) {
      colorToUse = activeColor;
      borderToUse = Border.all(color: activeColor);
    } else if (isDimmed) {
      colorToUse = dimmedColor;
      borderToUse = null;
    } else {
      colorToUse = defaultColor;
      borderToUse = null;
    }

    return RepaintBoundary(
      key: UniqueKey(), // If performance dictates or specific repaint is needed
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(5), // Original padding
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Keep original shape for consistency
            border: borderToUse,
          ),
          child: Stack(
            // Original Stack structure
            children: [
              Image.asset(
                "assets/images/free-draw.png",
                color: colorToUse,
                width: 24, // Example size, adjust as needed
                height: 24, // Example size, adjust as needed
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrashComponent({
    required bool isFocused,
    required bool isDimmed,
  }) {
    Color defaultColor = ColorManager.white;
    return Center(
      child: Icon(
        CupertinoIcons.trash,
        color: defaultColor,
        size: 24, // Example size, adjust as needed
      ),
    );
  }
}
