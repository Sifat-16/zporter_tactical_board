import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
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
import 'package:zporter_tactical_board/presentation/admin/view/tutorials/tutorial_selection_dialogue.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/tutorials/tutorials_controller.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/shapes/form_shape_item.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/form_text_item.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/text_field_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/line_utils.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/shape_utils.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/animation_data_input_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart'; // Adjust path
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_state.dart'; // Adjust path

import 'form_item_speed_dial.dart'; // Adjust path
import 'line/form_line_item.dart'; // Adjust path

FToast fToast = FToast();

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
  final bool showDownloadButton;
  final Function? onDownload;

  const FormSpeedDialConfig(
      {this.showFullScreenButton = true,
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
      this.showDownloadButton = true,
      this.onDownload});

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

  // Add debouncing for undo button
  DateTime? _lastUndoClickTime;
  static const Duration _undoDebounceDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setupForms();
      try {
        fToast.init(context);
      } catch (e) {}
    });
  }

  void setupForms() {
    setState(() {
      lines = LineUtils.generateLines()
          .where((line) =>
              line.name.contains(' ') ||
              ['Walk', 'Jog', 'Sprint', 'Jump', 'Pass', 'Dribble', 'Shoot']
                  .contains(line.name))
          .toList();
      shapes = ShapeUtils.generateShapes();
      texts = TextFieldUtils.generateTexts();
    });
  }

  // --- HELPER WIDGETS ---

  // UPDATED: Now accepts an alignment parameter
  Widget _buildMovementColumn(String title, List<Widget> items,
      {CrossAxisAlignment alignment = CrossAxisAlignment.start}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: alignment, // Use the provided alignment
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMovementItem(
      String label, List<LineModelV2> models, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ...models.map((line) {
            return FormLineItem(
                lineModelV2: line, onTap: () => Navigator.pop(context));
          }).toList(),
        ],
      ),
    );
  }

  void _showActionGrid(BuildContext context) {
    if (lines.isEmpty && shapes.isEmpty) {
      setupForms();
    }

    final playerMovements = {
      'Walk': lines.where((l) => l.name.contains('Walk')).toList(),
      'Jog': lines.where((l) => l.name.contains('Jog')).toList(),
      'Sprint': lines.where((l) => l.name.contains('Sprint')).toList(),
      'Jump': lines.where((l) => l.name == 'Jump').toList(),
    };
    final ballMovements = {
      'Pass': lines.where((l) => l.name == 'Pass').toList(),
      'Pass high/cross':
          lines.where((l) => l.name == 'Pass high/cross').toList(),
      'Dribble': lines.where((l) => l.name == 'Dribble').toList(),
      'Shoot': lines.where((l) => l.name == 'Shoot').toList(),
    };

    // UPDATED: Build the list for the "Other" column with spacing
    final otherItemsWithSpacing = <Widget>[
      ...shapes.map((shape) => Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: FormShapeItem(
                shapeModel: shape, onTap: () => Navigator.pop(context)),
          )),
      FormTextItem(
        textModel: texts.first,
        onTap: () async {
          Navigator.pop(context);
          TextModel? textModel = await TextFieldUtils.insertTextDialog(context);
          if (textModel != null) {
            final TacticBoardGame? tacticBoardGame =
                ref.read(boardProvider).tacticBoardGame;
            if (tacticBoardGame is TacticBoard) {
              tacticBoardGame.addNewTextOnTheField(object: textModel);
            }
          }
        },
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: ColorManager.black,
      builder: (BuildContext bottomSheetContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Text(
                    'Select action or form',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Player Movements Column (left-aligned)
                    _buildMovementColumn(
                      'Player movements',
                      playerMovements.entries
                          .where((e) => e.value.isNotEmpty)
                          .map((entry) => _buildMovementItem(
                              entry.key, entry.value, bottomSheetContext))
                          .toList(),
                    ),
                    const SizedBox(width: 32),
                    // Ball Movements Column (left-aligned)
                    _buildMovementColumn(
                      'Ball movements',
                      ballMovements.entries
                          .where((e) => e.value.isNotEmpty)
                          .map((entry) => _buildMovementItem(
                              entry.key, entry.value, bottomSheetContext))
                          .toList(),
                    ),
                    const SizedBox(width: 32),
                    // Other Column (UPDATED to be center-aligned)
                    _buildMovementColumn(
                      'Other',
                      otherItemsWithSpacing, // Use the new list with spacing
                      alignment: CrossAxisAlignment
                          .center, // Center this column's content
                    ),
                  ],
                ),
              ],
            ),
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
    List<AnimationCollectionModel> collectionList = ap.animationCollections;
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
      // width: context.widthPercent(90), // Your original width
      child: Row(
        mainAxisSize: MainAxisSize.max, // Your original mainAxisSize
        mainAxisAlignment: MainAxisAlignment.center,
        // spacing: 30,
        children: [
          // --- LEFT SIDE BUTTONS ---
          Container(
            // color: Colors.white,
            width: context.widthPercent(22),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Your original alignment
              children: [
                if (config.showBackButton)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back, color: ColorManager.white),
                  ),
                // if (config.showFullScreenButton)
                //   if (ap.showLoadingOnSave)
                //     SizedBox(
                //       height: 16,
                //       width: 16,
                //       child: CircularProgressIndicator(
                //         color: ColorManager.white,
                //       ),
                //     )
                //   else
                //     GestureDetector(
                //       onTap: () {
                //         ref.read(boardProvider.notifier).toggleFullScreen();
                //       },
                //       child: Icon(
                //         bp.showFullScreen == false
                //             ? Icons.fullscreen
                //             : Icons.fullscreen_exit,
                //         color: ColorManager.white,
                //       ),
                //     ),

                if (config.showFullScreenButton)
                  // --- THIS IS THE FIX ---
                  // We check both the general auto-save flag (ap.showLoadingOnSave)
                  // AND the new toggle-specific flag (bp.isTogglingFullscreen).
                  if (ap.showLoadingOnSave || bp.isTogglingFullscreen)
                    SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: ColorManager.white,
                      ),
                    )
                  else
                    // If no saves are happening, show the normal button.
                    GestureDetector(
                      onTap: () {
                        // This now correctly calls your new ASYNC method in the controller.
                        ref.read(boardProvider.notifier).toggleFullScreen();
                      },
                      child: Icon(
                        bp.showFullScreen == false
                            ? Icons.fullscreen
                            : Icons.fullscreen_exit,
                        color: ColorManager.white,
                      ),
                    ),
                const SizedBox(width: 10),
                if (config.showShareButton)
                  GestureDetector(
                    onTap: () async {
                      widget.config.onShare?.call();
                    },
                    child: Icon(
                      Icons.share,
                      color: ColorManager.white,
                    ), // Your original color
                  ),
                const SizedBox(width: 10),
                if (config.showDownloadButton)
                  GestureDetector(
                    onTap: () {
                      widget.config.onDownload?.call();
                    },
                    child: Icon(
                      Icons.download_sharp,
                      color: ColorManager.white,
                    ), // Your original color
                  ),
                // const SizedBox(width: 10),
                // GestureDetector(
                //   onTap: () {
                //     ref.read(tutorialsProvider.notifier).fetchTutorials();
                //     _showTutorialSelectionDialog(context);
                //   },
                //   child: Center(
                //     child: Icon(
                //       CupertinoIcons.info,
                //       color: ColorManager.white,
                //       size: 24,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          // --- CENTER TOOL BUTTONS ---
          Container(
            // color: Colors.green,
            width: context.widthPercent(22),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Your original mainAxisSize
              mainAxisAlignment: MainAxisAlignment.center,
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
                    child: lpState.activeForm != null &&
                            currentActiveTool == ActiveTool.pointer
                        ? _buildFormWidget(
                            fieldItemModel: lpState.activeForm!,
                          )
                        : Center(
                            // Your original Center widget
                            child: Icon(
                              Icons.arrow_upward,
                              color: (currentActiveTool == ActiveTool.pointer &&
                                      !isPlacingItem)
                                  ? activeColor
                                  : isPlacingItem
                                      ? activeColor
                                      : defaultInactiveColor,
                            ),
                          ),
                  ),
                const SizedBox(width: 15),
                if (config.showFreeDrawButton)
                  GestureDetector(
                    onTap: () {
                      lpNotifier.toggleFreeDraw();
                    },
                    child: _buildFreeDrawComponent(
                      // Your original component call
                      isFocused: currentActiveTool == ActiveTool.freeDraw,
                      isDimmed: (currentActiveTool != ActiveTool.freeDraw &&
                              currentActiveTool != ActiveTool.pointer) ||
                          isPlacingItem,
                    ),
                  ),
                const SizedBox(width: 15),
                if (config.showEraserButton)
                  GestureDetector(
                    onTap: () {
                      lpNotifier.toggleEraser();
                    },
                    child: Icon(
                      // Your original Icon
                      FontAwesomeIcons.eraser,
                      color: currentActiveTool == ActiveTool.eraser
                          ? ColorManager.red
                          : (currentActiveTool != ActiveTool.eraser &&
                                      currentActiveTool !=
                                          ActiveTool.pointer) ||
                                  isPlacingItem
                              ? dimmedInactiveColor
                              : defaultInactiveColor,
                    ),
                  ),
                const SizedBox(width: 15),
                if (config.showUndoButton && selectedScene != null)
                  // StreamBuilder(
                  //   stream: _historyStream.call(selectedScene.id),
                  //   builder: (context, snapshot) {
                  //     HistoryModel? history = snapshot.data;
                  //
                  //     if (history == null) {
                  //       return SizedBox.shrink();
                  //     } else {
                  //       return GestureDetector(
                  //         onTap: () {
                  //           ref
                  //               .read(animationProvider.notifier)
                  //               .performUndoOperation();
                  //         },
                  //         child: Icon(
                  //           FontAwesomeIcons.arrowRotateLeft,
                  //           color: ColorManager.white,
                  //         ),
                  //       );
                  //     }
                  //   },
                  // ),
                  StreamBuilder(
                    stream: _historyStream.call(selectedScene.id),
                    builder: (context, snapshot) {
                      HistoryModel? history = snapshot.data;

                      // --- NEW, CORRECTED LOGIC ---
                      // The button should only be visible if the history object exists
                      // AND its list of states is NOT empty.
                      final bool canUndo =
                          history != null && history.history.isNotEmpty;

                      if (canUndo) {
                        return GestureDetector(
                          onTap: () {
                            // Debouncing logic to prevent rapid clicks
                            final now = DateTime.now();
                            if (_lastUndoClickTime != null &&
                                now.difference(_lastUndoClickTime!) <
                                    _undoDebounceDelay) {
                              zlog(
                                data:
                                    "Undo button clicked too quickly, ignoring.",
                              );
                              return;
                            }
                            _lastUndoClickTime = now;

                            // Perform the undo operation
                            ref
                                .read(animationProvider.notifier)
                                .performUndoOperation();
                          },
                          child: Icon(
                            FontAwesomeIcons.arrowRotateLeft,
                            color: ColorManager.white,
                          ),
                        );
                      } else {
                        // If there's no history or the history is empty, show nothing.
                        return const SizedBox.shrink();
                      }
                    },
                  ),
              ],
            ),
          ),

          // --- RIGHT SIDE BUTTONS ---
          Container(
            // color: Colors.red,
            width: context.widthPercent(22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: bp.selectedItemOnTheBoard?.canBeCopied == true
                      ? () {
                          ref.read(boardProvider.notifier).copyElement();
                        }
                      : null,
                  child: Icon(Icons.copy,
                      color: bp.selectedItemOnTheBoard?.canBeCopied == true
                          ? ColorManager.white
                          : ColorManager.white.withOpacity(0.7)),
                ),
                const SizedBox(width: 10),
                if (config.showAddNewSceneButton)
                  if (ap.showLoadingOnSave)
                    Icon(CupertinoIcons.add_circled,
                        color: ColorManager.white.withValues(alpha: 0.6))
                  else
                    _buildAddNewScene(
                      selectedCollection: collectionModel,
                      collectionList: collectionList,
                      selectedAnimation: animationModel,
                      selectedScene: selectedScene,
                    ),
                const SizedBox(width: 10),
                if (config.showTrashButton)
                  GestureDetector(
                    onTap: () {
                      ref.read(boardProvider.notifier).removeElement();
                    },
                    child: _buildTrashComponent(
                      // Your original component call
                      isFocused: bp.selectedItemOnTheBoard != null,
                      isDimmed: (currentActiveTool != ActiveTool.trash &&
                              currentActiveTool != ActiveTool.pointer) ||
                          isPlacingItem,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormWidget({required FieldItemModel fieldItemModel}) {
    return FormItemSpeedDial(formItem: fieldItemModel);
  }

  Widget _buildAddNewScene({
    required List<AnimationCollectionModel> collectionList,
    required AnimationCollectionModel? selectedCollection,
    required AnimationModel? selectedAnimation,
    required AnimationItemModel? selectedScene,
    GlobalKey? keyForTutorial,
  }) {
    return GestureDetector(
      key: keyForTutorial,
      onTap: () async {
        if (widget.config.addNewSceneForAdmin != null) {
          widget.config.addNewSceneForAdmin?.call();
          return;
        }
        if (selectedCollection == null || selectedAnimation == null) {
          AnimationCreateItem? animationCreateItem =
              await showNewAnimationInputDialog(
            context,
            collectionList: collectionList,
            selectedCollection: selectedCollection,
          );
          if (animationCreateItem != null) {
            animationCreateItem.items = selectedScene?.components ?? [];
            ref
                .read(animationProvider.notifier)
                .createNewAnimation(newAnimation: animationCreateItem);
          }
        } else {
          try {
            if (selectedScene != null) {
              ref.read(animationProvider.notifier).addNewScene(
                    selectedCollection: selectedCollection,
                    selectedAnimation: selectedAnimation,
                    selectedScene: selectedScene,
                  );

              _showToast();

              // Fluttertoast.showToast(
              //     msg: "Image added to animation",
              //     toastLength: Toast.LENGTH_LONG,
              //     gravity: ToastGravity.BOTTOM,
              //     timeInSecForIosWeb: 1,
              //     backgroundColor: ColorManager.black,
              //     textColor: Colors.white,
              //     fontSize: 16.0);

              // BotToast.showText(
              //     text: "Image added to animation",
              //     contentColor: ColorManager.black,
              //     duration: Duration(seconds: 5));
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
      child: Icon(CupertinoIcons.add_circled, color: ColorManager.white),
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
    Color focusedColor = ColorManager.red;

    return Center(
      child: Icon(
        Icons.delete_sweep_outlined,
        color: isFocused ? focusedColor : defaultColor,
        size: 24,
      ),
    );
  }

  // void _showTutorialSelectionDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       // We return a dedicated widget for the dialog's content.
  //       return const TutorialSelectionDialog();
  //     },
  //   );
  // }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: ColorManager.white.withValues(alpha: 0.1)),
        color: Colors.black,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check,
            color: ColorManager.white,
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            "Image added to animation",
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: ColorManager.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    // fToast.showToast(
    //   child: toast,
    //   gravity: ToastGravity.BOTTOM,
    //   toastDuration: Duration(seconds: 2),
    // );

    // Custom Toast Position
    fToast.showToast(
      child: toast,
      toastDuration: Duration(seconds: 3),
      positionedToastBuilder: (context, child, gravity) {
        return Positioned(
          bottom: context.screenHeight * .1,
          left: 0.0,
          right: 0.0,
          child: Align(
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }
}
