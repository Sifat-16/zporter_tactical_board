import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/history_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_history_stream_usecase.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

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
    });
  }

  // Not needed if SpeedDial doesn't manage open/close state itself
  // var isDialOpen = ValueNotifier<bool>(false);

  // --- Function to show the grid in a bottom sheet ---
  void _showActionGrid(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // Optional: customize shape, background color, etc.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: ColorManager.dark2.withValues(
        alpha: 0.8,
      ), // Or your desired background
      builder: (BuildContext bottomSheetContext) {
        // Use MediaQuery to constrain height if needed, e.g., half screen
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          // Constrain height to prevent full screen takeover
          height: screenHeight * 0.6, // Example: 60% of screen height
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Take minimum necessary height
            children: [
              // Optional: Add a title or drag handle
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
                'Select Action', // Title for the grid
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // --- Use Expanded to make GridView fill available space ---
              Expanded(
                child: GridView.builder(
                  itemCount: lines.length, // Your total number of items
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Adjust number of columns
                    crossAxisSpacing: 10.0, // Spacing between columns
                    mainAxisSpacing: 10.0, // Spacing between rows
                    childAspectRatio:
                        1.0, // Adjust aspect ratio (1.0 makes items square)
                  ),
                  itemBuilder: (BuildContext gridContext, int index) {
                    // Replace with your actual item data and logic
                    return FormLineItem(
                      lineModelV2: lines[index],
                      onTap: () {
                        Navigator.pop(context);
                      },
                    );
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
    final AnimationItemModel? selectedScene = ap.selectedScene;
    final GetHistoryStreamUseCase _historyStream =
        sl.get<GetHistoryStreamUseCase>();
    return Row(
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
              lp.activatedLineForm !=
                      null // Assuming lp is available in this scope
                  ? _buildFormWidget(
                    activatedLineForm: lp.activatedLineForm!,
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
                          .dismissActiveLineModelToAddIntoGameFieldEvent();
                    } else {
                      ref
                          .read(lineProvider.notifier)
                          .loadActiveFreeDrawModelToAddIntoGameFieldEvent();
                    }
                  },
          child: _buildFreeDrawComponent(isFocused: lp.isFreeDrawingActive),
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

              zlog(data: "History data ${history?.history}");

              if (history == null) {
                return SizedBox.shrink();
              } else {
                return GestureDetector(
                  onTap: () {
                    ref.read(animationProvider.notifier).performUndoOperation();
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
    );
  }

  _buildFormWidget({required LineModelV2 activatedLineForm}) {
    return FormItemSpeedDial(lineModelV2: activatedLineForm);
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
