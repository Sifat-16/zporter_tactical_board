import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/form_speed_dial_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/lefttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/game_screen.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/animation_toolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/righttoolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_state.dart';
import 'package:zporter_tactical_board/presentation/tutorials/tactic_board_tutorial_manager.dart';
import 'package:zporter_tactical_board/presentation/tutorials/tutorial_keys.dart';

class DefaultAnimationFieldScreen extends ConsumerStatefulWidget {
  const DefaultAnimationFieldScreen({super.key, required this.animationModel});

  final AnimationModel animationModel;

  @override
  ConsumerState<DefaultAnimationFieldScreen> createState() =>
      _DefaultAnimationFieldScreenState();
}

class _DefaultAnimationFieldScreenState
    extends ConsumerState<DefaultAnimationFieldScreen> {
  bool _isLeftPanelOpen = false;
  bool _isRightPanelOpen = false;
  late double _leftPanelWidth;
  late double _rightPanelWidth;
  final Duration _panelAnimationDuration = const Duration(milliseconds: 250);

  late final TacticBoardTutorialManager _tutorialManager;
  // Keys are no longer defined here, they are in TutorialKeys

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
    _tutorialManager = TacticBoardTutorialManager();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {
          _leftPanelWidth = context.widthPercent(20);
          _rightPanelWidth = context.widthPercent(20);
        });
      }
      try {
        ref
            .read(animationProvider.notifier)
            .activateDefaultAnimation(animationModel: widget.animationModel);
      } catch (e) {}
    });
  }

  @override
  void dispose() {
    _tutorialManager.dismissCurrentCoachMarkTutorial();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ap = ref.watch(animationProvider);
    final AnimationItemModel? selectedScene = ap.selectedScene;

    Widget screenContent;
    screenContent = SafeArea(
      child: Scaffold(
        backgroundColor: ColorManager.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: _buildCentralContentFullScreen(
                context,
                ref,
                ap,
                selectedScene,
              ),
            ),
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
                  child: const LefttoolbarComponent(),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: _panelAnimationDuration,
              curve: Curves.easeInOut,
              right: _isRightPanelOpen ? 0 : -_rightPanelWidth,
              top: 0,
              bottom: 0,
              width: _rightPanelWidth,
              child: SafeArea(
                child: Material(
                  elevation: 4.0,
                  color: ColorManager.dark2,
                  child: RighttoolbarComponent(
                    animationToolbarConfig: AnimationToolbarConfig(
                      showBackToDefaultButton: false,
                      showCollectionSelector: false,
                      showAnimationSelector: false,
                      showAnimationList: true,
                      onSceneDelete: (a) {
                        ref
                            .read(animationProvider.notifier)
                            .deleteAdminScene(scene: a);
                      },
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: _panelAnimationDuration,
              curve: Curves.easeInOut,
              left: _isLeftPanelOpen ? _leftPanelWidth - 20 : 5,
              top: (context.heightPercent(92) / 2) - 25,
              // Assign the static key directly to the Material widget
              child: Material(
                key: TutorialKeys.leftPanelButtonKey,
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

            AnimatedPositioned(
              duration: _panelAnimationDuration,
              curve: Curves.easeInOut,
              right: _isRightPanelOpen ? _rightPanelWidth - 20 : 5,
              top: (context.heightPercent(92) / 2) - 25,
              child: Material(
                color: ColorManager.grey.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                elevation: 6.0,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  onTap: _toggleRightPanel,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    child: Icon(
                      _isRightPanelOpen
                          ? Icons.chevron_right
                          : Icons.chevron_left,
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

  Widget _buildCentralContentFullScreen(
    BuildContext context,
    WidgetRef ref,
    AnimationState asp,
    AnimationItemModel? selectedScene,
  ) {
    return Padding(
      padding: EdgeInsets.all(5),
      child:
      // asp.showNewCollectionInput == true ||
      //         asp.showNewAnimationInput == true
      //     ? AnimationDataInputComponent()
      //     : asp.showQuickSave
      //     ? ShowQuickSaveComponent()
      //     :
      GameScreen(
        scene: selectedScene,
        saveToDb: false,
        onSceneSave: (a) {
          ref.read(animationProvider.notifier).triggerAutoSaveForAdmin();
          zlog(data: "Animation item found for save triggered ${a?.toJson()}");
        },
        config: FormSpeedDialConfig(
          showFullScreenButton: false,
          showBackButton: true,

          addNewSceneForAdmin: () {
            try {
              ref
                  .read(animationProvider.notifier)
                  .addNewSceneFromAdmin(
                    selectedAnimation: asp.selectedAnimationModel!,
                    selectedScene: asp.selectedScene!,
                  );
            } catch (e) {
              zlog(data: "Issue while saving animation for admin ${e}");
            }
          },
        ),
      ),
    );
  }
}
