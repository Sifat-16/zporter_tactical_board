import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // If you plan to use Riverpod here
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // Adjust path
import 'package:zporter_tactical_board/data/admin/model/default_lineup_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/lineup_view_model/lineup_controller.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/form_speed_dial_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/players_toolbar/players_toolbar_home.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';

class DefaultLineupFieldScreen extends ConsumerStatefulWidget {
  final FormationTemplate template;

  const DefaultLineupFieldScreen({super.key, required this.template});

  @override
  ConsumerState<DefaultLineupFieldScreen> createState() =>
      _DefaultLineupFieldScreenState();
}

class _DefaultLineupFieldScreenState
    extends ConsumerState<DefaultLineupFieldScreen> {
  bool _isLeftPanelOpen = false;
  bool _isRightPanelOpen = false;
  late double _leftPanelWidth;
  late double _rightPanelWidth;
  final Duration _panelAnimationDuration = const Duration(milliseconds: 250);
  late FormationTemplate saveTemplate;

  void _toggleLeftPanel() {
    setState(() {
      _isLeftPanelOpen = !_isLeftPanelOpen;
    });
    zlog(data: "Left panel toggled. Is open: $_isLeftPanelOpen");
  }

  void _toggleRightPanel() {
    setState(() {
      _isRightPanelOpen = !_isRightPanelOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    _leftPanelWidth = 200.0;
    _rightPanelWidth = 250.0;
    saveTemplate = widget.template;

    // zlog(
    //     data: "Saved template data ${saveTemplate.scene.toJson()}", show: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {
          _leftPanelWidth = context.widthPercent(20);
          _rightPanelWidth = context.widthPercent(20);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screenContent;
    screenContent = Scaffold(
      appBar: AppBar(
        title: Text(
          widget.template.name, // Display the template name
          style: const TextStyle(
            color: ColorManager.white,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: ColorManager.dark2, // Dark theme for AppBar
        elevation: 2.0, // Subtle shadow
        iconTheme: const IconThemeData(
          color: ColorManager.white,
        ), // For back button
        actions: [
          TextButton(
            child: Text(
              "SAVE",
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorManager.yellow,
                  ),
            ),
            onPressed: () {
              ref
                  .read(lineupProvider.notifier)
                  .editLineupTemplate(saveTemplate)
                  .then((s) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Save action for ${widget.template.name}',
                    ),
                    backgroundColor: ColorManager.green.withOpacity(0.9),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              });

              zlog(
                data:
                    "Save button pressed for template: ${widget.template.name}",
              );
            },
          ),
          // You can add more actions here if needed
        ],
      ),
      backgroundColor: ColorManager.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. The Scaffold is now a child of the root Stack
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                // height: context.screenHeight * .92,
                width: context.widthPercent(100),
                child: Scaffold(
                  backgroundColor: ColorManager.black,
                  body: _buildCentralContent(context),
                ),
              ),
            ),

            // 2. AnimatedPositioned widgets are now direct children of the root Stack,
            //    overlaying the Scaffold.
            AnimatedPositioned(
              duration: _panelAnimationDuration,
              curve: Curves.easeInOut,
              left: _isLeftPanelOpen ? 0 : -_leftPanelWidth,
              top: 0,
              bottom: 0,
              width: _leftPanelWidth,
              child: SafeArea(
                child: Material(
                  elevation: 4.0,
                  color: ColorManager.dark2,
                  child: const PlayersToolbarHome(showFooter: false),
                ),
              ),
            ),

            AnimatedPositioned(
              duration: _panelAnimationDuration,
              curve: Curves.easeInOut,
              left: _isLeftPanelOpen ? _leftPanelWidth - 20 : 5,
              top: (context.heightPercent(92) / 2) -
                  25, // Consider if context here refers to the correct one
              // It should be the context of the build method where screenContent is defined
              child: Material(
                color: ColorManager.grey.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                elevation: 6.0,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  onTap: _toggleLeftPanel,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    child: Icon(
                      _isLeftPanelOpen
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return screenContent;
  }

  Widget _buildCentralContent(BuildContext context) {
    return GameScreen(
      scene: widget.template.scene,
      onSceneSave: (a) {
        zlog(
          data:
              "GameScreen onSceneSave triggered for template: ${widget.template.name}",
        );
        zlog(
          data:
              "Received scene ID: ${a?.id}, components: ${a?.components.length}",
        );
        // Create an updated FormationTemplate with the new scene
        final updatedTemplateWithScene = widget.template.copyWith(
          scene: widget.template.scene.copyWith(
            components: a?.components,
          ), // Use the scene received from GameScreen
        );
        saveTemplate = updatedTemplateWithScene;
        // Call the LineupController to update the template in the repository/state
      },
      saveToDb: false,
      config: FormSpeedDialConfig(
        showFullScreenButton: false,
        showAddNewSceneButton: false,
        showEraserButton: false,
        showFreeDrawButton: false,
        showPlayAnimationButton: false,
        showPointerActionsButton: false,
        showShareButton: false,
        showUndoButton: false,
        showTrashButton: true,
      ),
    );
  }
}
