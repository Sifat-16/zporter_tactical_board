import 'package:bot_toast/bot_toast.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      setupForms();
    });
  }

  setupForms() {
    setState(() {
      lines = LineUtils.generateLines();
      shapes = ShapeUtils.generateShapes();
    });
  }

  // Not needed if SpeedDial doesn't manage open/close state itself
  // var isDialOpen = ValueNotifier<bool>(false);

  // --- Function to show the grid in a bottom sheet ---
  void _showActionGrid(BuildContext context) {
    // Ensure lists are initialized (although initState should handle this)
    if (lines.isEmpty && shapes.isEmpty) {
      setupForms(); // Recalculate if empty, safety check
    }

    // Calculate total items
    final totalItems = lines.length + shapes.length;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: ColorManager.dark2.withValues(
        alpha: 0.8, // Assuming ColorValues extension exists
      ),
      builder: (BuildContext bottomSheetContext) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          height: screenHeight * 0.6,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: ColorManager.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Title
              Text(
                'Select Action',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // --- GridView with Combined Items ---
              Expanded(
                child: GridView.builder(
                  // *** MODIFIED: itemCount is now the total count ***
                  itemCount: totalItems,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 1.0,
                  ),
                  // *** MODIFIED: itemBuilder handles both lines and shapes ***
                  itemBuilder: (BuildContext gridContext, int index) {
                    if (index < lines.length) {
                      // --- Build Line Item ---
                      final lineModel = lines[index];
                      return FormLineItem(
                        // Assuming FormLineItem exists
                        lineModelV2: lineModel,
                        onTap: () {
                          Navigator.pop(
                            bottomSheetContext,
                          ); // Close bottom sheet
                        },
                      );
                    } else {
                      // --- Build Shape Item ---
                      // Calculate the index within the shapes list
                      final shapeIndex = index - lines.length;
                      if (shapeIndex < shapes.length) {
                        // Safety check
                        final shapeModel = shapes[shapeIndex];
                        // TODO: Replace Placeholder with your actual FormShapeItem widget
                        return FormShapeItem(
                          // Assuming FormLineItem exists
                          shapeModel: shapeModel,
                          onTap: () {
                            Navigator.pop(
                              bottomSheetContext,
                            ); // Close bottom sheet
                          },
                        );
                      } else {
                        // Should not happen if itemCount is correct, but return empty container as fallback
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
    final lp = ref.watch(lineProvider);
    final ap = ref.watch(animationProvider);
    final bp = ref.watch(boardProvider);
    final AnimationItemModel? selectedScene = ap.selectedScene;
    AnimationCollectionModel? collectionModel =
        ap.selectedAnimationCollectionModel;
    AnimationModel? animationModel = ap.selectedAnimationModel;
    final GetHistoryStreamUseCase _historyStream =
        sl.get<GetHistoryStreamUseCase>();
    return Container(
      width: context.widthPercent(90),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            spacing: 10,
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

              GestureDetector(
                onTap: () {},
                child: Icon(Icons.threed_rotation, color: ColorManager.white),
              ),
              GestureDetector(
                onTap: () {},
                child: Icon(Icons.share, color: ColorManager.grey),
              ),
            ],
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              GestureDetector(
                onTap:
                    lp.isFreeDrawingActive || lp.isEraserActivated
                        ? null
                        : () {
                          _showActionGrid(context);
                        },
                child:
                    lp.activeForm !=
                            null // Assuming lp is available in this scope
                        ? _buildFormWidget(
                          fieldItemModel: lp.activeForm!,
                        ) // Assuming this exists
                        : Center(
                          child: Icon(
                            FontAwesomeIcons.arrowPointer,
                            color: ColorManager.white.withValues(
                              alpha:
                                  lp.isFreeDrawingActive || lp.isEraserActivated
                                      ? 0.3
                                      : 0.9,
                            ),
                          ),
                        ),
              ),

              GestureDetector(
                onTap:
                    lp.isLineActiveToAddIntoGameField || lp.isEraserActivated
                        ? null
                        : () {
                          if (lp.isFreeDrawingActive) {
                            ref
                                .read(lineProvider.notifier)
                                .dismissActiveFormItem();
                          } else {
                            ref
                                .read(lineProvider.notifier)
                                .loadActiveFreeDrawModelToAddIntoGameFieldEvent();
                          }
                        },
                child: _buildFreeDrawComponent(
                  isFocused: lp.isFreeDrawingActive,
                ),
              ),

              GestureDetector(
                onTap:
                    lp.isFreeDrawingActive || lp.isLineActiveToAddIntoGameField
                        ? null
                        : () {
                          ref.read(lineProvider.notifier).toggleEraser();
                        },
                child: Icon(
                  FontAwesomeIcons.eraser,
                  color:
                      lp.isEraserActivated
                          ? ColorManager.red
                          : ColorManager.white.withValues(
                            alpha:
                                lp.isFreeDrawingActive ||
                                        lp.isLineActiveToAddIntoGameField
                                    ? 0.3
                                    : 0.7,
                          ),
                ),
              ),
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
            ],
          ),

          Row(
            spacing: 10,
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
                          // Use MaterialPageRoute for standard transitions, or PageRouteBuilder for custom ones
                          MaterialPageRoute(
                            builder:
                                (context) => AnimationScreen(
                                  // Pass the necessary data AND the hero tag
                                  animationModel: animationModel,
                                  heroTag: heroTag, // Pass the SAME tag
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
              _buildAddNewScene(
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

  _buildFormWidget({required FieldItemModel fieldItemModel}) {
    return FormItemSpeedDial(formItem: fieldItemModel);
  }

  _buildAddNewScene({
    required AnimationCollectionModel? selectedCollection,
    required AnimationModel? selectedAnimation,
    required AnimationItemModel? selectedScene,
  }) {
    return GestureDetector(
      onTap: () {
        if (selectedCollection == null || selectedAnimation == null) {
          // no collection or animation is chosen, so show a overlay to add or select item

          ref.read(animationProvider.notifier).showQuickSave();
        } else {
          try {
            ref
                .read(animationProvider.notifier)
                .addNewScene(
                  selectedCollection: selectedCollection,
                  selectedAnimation: selectedAnimation,
                  selectedScene: selectedScene!,
                );
          } catch (e) {
            BotToast.showText(text: "Error $e !!!");
          }
        }
      },
      child: Icon(Icons.add_circle_outline, color: ColorManager.white),
    );
  }

  Widget _buildFreeDrawComponent({required bool isFocused}) {
    if (!isFocused) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(),
          child: Stack(
            children: [
              Image.asset(
                "assets/images/free-draw.png",
                color: ColorManager.white,
              ),
            ],
          ),
        ),
      );
    } else {
      return RepaintBoundary(
        key: UniqueKey(),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ColorManager.red),
            ),
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/free-draw.png",
                  color: ColorManager.red,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
