import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart'; // Adjust path
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust path
import 'package:zporter_tactical_board/app/services/injection_container.dart'; // Adjust path
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart'; // Adjust path
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart'; // Adjust path
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart'; // Adjust path
import 'package:zporter_tactical_board/data/animation/model/history_model.dart'; // Adjust path
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart'; // Adjust path
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart'; // Adjust path
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart'; // Adjust path
import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_history_stream_usecase.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/shapes/form_shape_item.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/form_text_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/text_field_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/line_utils.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/shape_utils.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/animation_screen.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tutorials/tutorial_keys.dart'; // Adjust path

import 'form_item_speed_dial.dart'; // Adjust path
import 'line/form_line_item.dart'; // Adjust path

// --- Configuration Class for Button Visibility ---
class FormSpeedDialConfig {
  final bool showFullScreenButton;
  final bool showShareButton;
  final bool showPointerActionsButton;
  final bool showFreeDrawButton;
  final bool showEraserButton;
  final bool showUndoButton;
  final bool showTrashButton;
  final bool showPlayAnimationButton;
  final bool showAddNewSceneButton;
  final Function? addNewSceneForAdmin;
  final bool showBackButton;
  final Function? onShare;

  const FormSpeedDialConfig({
    this.showFullScreenButton = true,
    this.showShareButton = true,
    this.showPointerActionsButton = true,
    this.showFreeDrawButton = true,
    this.showEraserButton = true,
    this.showUndoButton = true,
    this.showTrashButton = true,
    this.showPlayAnimationButton = true,
    this.showAddNewSceneButton = true,
    this.addNewSceneForAdmin,
    this.showBackButton = false,
    this.onShare,
  });

  // Example of a more restrictive config
  static const viewOnly = FormSpeedDialConfig(
    showFullScreenButton: true,
    showShareButton: false,
    showPointerActionsButton: false,
    showFreeDrawButton: false,
    showEraserButton: false,
    showUndoButton:
        true, // Assuming undo might still be relevant for view changes if any
    showTrashButton: false,
    showPlayAnimationButton: true,
    showAddNewSceneButton: false,
  );

  static const fullEdit = FormSpeedDialConfig(); // All default to true
}
// --- End of Configuration Class ---

class FormSpeedDialComponent extends ConsumerStatefulWidget {
  const FormSpeedDialComponent({
    super.key,
    required this.tacticBoardGame,
    this.config = const FormSpeedDialConfig(), // Add config parameter
  });

  final TacticBoardGame tacticBoardGame;
  final FormSpeedDialConfig config; // Store the config

  @override
  ConsumerState<FormSpeedDialComponent> createState() =>
      _FormSpeedDialComponentState();
}

class _FormSpeedDialComponentState
    extends ConsumerState<FormSpeedDialComponent> {
  List<LineModelV2> lines = [];
  List<ShapeModel> shapes = [];
  List<TextModel> texts = [];

  final GetHistoryStreamUseCase _historyStream =
      sl.get<GetHistoryStreamUseCase>(); // Assuming sl is your service locator
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
      texts = TextFieldUtils.generateTexts();
    });
  }

  void _showActionGrid(BuildContext context) {
    if (lines.isEmpty && shapes.isEmpty && texts.isEmpty) {
      setupForms();
    }

    final totalItems = lines.length + shapes.length + texts.length;
    final lineNotifier = ref.read(lineProvider.notifier);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: ColorManager.dark2.withOpacity(
        0.8,
      ), // Adjusted from withValues
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
                    if (index < texts.length) {
                      final textModel = texts[index];
                      return FormTextItem(
                        textModel: textModel,
                        onTap: () async {
                          Navigator.pop(bottomSheetContext);
                          TextModel? textModel =
                              await TextFieldUtils.insertTextDialog(context);
                          if (textModel != null) {
                            TacticBoardGame? tacticBoardGame =
                                ref.read(boardProvider).tacticBoardGame;
                            if (tacticBoardGame is TacticBoard) {
                              tacticBoardGame.addNewTextOnTheField(
                                object: textModel,
                              );
                            }
                          }
                          zlog(
                            data:
                                "The text model generated ${textModel?.toJson()}",
                          );
                        },
                      );
                    } else if (index < (lines.length + texts.length)) {
                      final lineIndex = index - texts.length;
                      final lineModel = lines[lineIndex];
                      return FormLineItem(
                        lineModelV2: lineModel,
                        onTap: () {
                          lineNotifier
                              .loadActiveLineModelToAddIntoGameFieldEvent(
                                lineModelV2: lineModel,
                              );
                          Navigator.pop(bottomSheetContext);
                        },
                      );
                    } else {
                      final shapeIndex = index - lines.length - texts.length;
                      if (shapeIndex < shapes.length) {
                        final shapeModel = shapes[shapeIndex];
                        return FormShapeItem(
                          shapeModel: shapeModel,
                          onTap: () {
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
    // _historyStream is already an instance variable

    final currentActiveTool = lpState.activeTool;
    final bool isPlacingItem =
        lpState.activeForm != null && currentActiveTool == ActiveTool.pointer;

    Color activeColor = ColorManager.white;
    Color defaultInactiveColor = ColorManager.white;
    Color dimmedInactiveColor = ColorManager.white.withOpacity(0.5);

    // Access the config from the widget property
    final config = widget.config;

    return SizedBox(
      width: context.widthPercent(90), // Your original width
      child: Row(
        mainAxisSize: MainAxisSize.max, // Your original mainAxisSize
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 30,
        children: [
          // --- LEFT SIDE BUTTONS ---
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Your original alignment
            spacing: 10,
            children: [
              if (config.showBackButton)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.arrow_back, color: ColorManager.white),
                ),
              if (config.showFullScreenButton)
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

              if (config.showShareButton)
                GestureDetector(
                  onTap: () {
                    widget.config.onShare?.call();
                  },
                  child: Icon(
                    Icons.share,
                    color: ColorManager.white,
                  ), // Your original color
                ),
            ],
          ),

          // --- CENTER TOOL BUTTONS ---
          Row(
            mainAxisSize: MainAxisSize.min, // Your original mainAxisSize
            spacing: 10,
            children: [
              if (config.showPointerActionsButton)
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
                          ? _buildFormWidget(
                            fieldItemModel: lpState.activeForm!,
                          )
                          : Center(
                            // Your original Center widget
                            child: Icon(
                              FontAwesomeIcons.arrowPointer,
                              color:
                                  (currentActiveTool == ActiveTool.pointer &&
                                          !isPlacingItem)
                                      ? activeColor
                                      : isPlacingItem
                                      ? activeColor
                                      : defaultInactiveColor,
                            ),
                          ),
                ),

              if (config.showFreeDrawButton)
                GestureDetector(
                  onTap: () {
                    lpNotifier.toggleFreeDraw();
                  },
                  child: _buildFreeDrawComponent(
                    // Your original component call
                    isFocused: currentActiveTool == ActiveTool.freeDraw,
                    isDimmed:
                        (currentActiveTool != ActiveTool.freeDraw &&
                            currentActiveTool != ActiveTool.pointer) ||
                        isPlacingItem,
                  ),
                ),

              if (config.showEraserButton)
                GestureDetector(
                  onTap: () {
                    lpNotifier.toggleEraser();
                  },
                  child: Icon(
                    // Your original Icon
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

              if (config.showUndoButton && selectedScene != null)
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

              if (config.showTrashButton)
                GestureDetector(
                  onTap: () {
                    ref.read(boardProvider.notifier).removeElement();
                  },
                  child: _buildTrashComponent(
                    // Your original component call
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
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (config.showPlayAnimationButton && animationModel != null)
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
                        // Your original Icon
                        Icons.play_circle_outline,
                        color: ColorManager.white,
                      ),
                    );
                  },
                ),

              if (config.showAddNewSceneButton)
                _buildAddNewScene(
                  // Your original component call
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

  Widget _buildAddNewScene({
    required AnimationCollectionModel? selectedCollection,
    required AnimationModel? selectedAnimation,
    required AnimationItemModel? selectedScene,
    GlobalKey? keyForTutorial,
  }) {
    return GestureDetector(
      key: keyForTutorial,
      onTap: () {
        if (widget.config.addNewSceneForAdmin != null) {
          widget.config.addNewSceneForAdmin?.call();
          return;
        }
        if (selectedCollection == null || selectedAnimation == null) {
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
    Color dimmedColor = ColorManager.white.withOpacity(0.5);

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
      key: UniqueKey(),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: borderToUse,
          ),
          child: Stack(
            children: [
              Image.asset(
                "assets/images/free-draw.png", // Ensure this path is correct
                color: colorToUse,
                width: 24,
                height: 24,
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
    Color dimmedColor = ColorManager.white.withOpacity(0.5);

    return Center(
      child: Icon(
        CupertinoIcons.trash,
        color: isDimmed ? dimmedColor : defaultColor,
        size: 24,
      ),
    );
  }
}
