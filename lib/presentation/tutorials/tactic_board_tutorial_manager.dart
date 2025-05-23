// lib/app/tutorial/tactic_board_tutorial_manager.dart
import 'dart:async'; // For StreamSubscription

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart' as tcm;
import 'package:zporter_tactical_board/app/core/dialogs/confirmation_dialog.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tutorials/tutorial_utils.dart';
import 'package:zporter_tactical_board/presentation/tutorials/tutorial_events.dart';
import 'package:zporter_tactical_board/presentation/tutorials/tutorial_keys.dart';

import 'animated_tutorial_content.dart';

class TutorialStepIdentifiers {
  static const String leftPanelIntro = 'leftPanelIntro';
  static const String dragFirstPlayer = 'dragFirstPlayer';
  static const String addNewScene = 'addNewScene';
}

class TacticBoardTutorialManager {
  tcm.TutorialCoachMark? _coachMarkInstance;
  StreamSubscription? _playerSuccessfullyDraggedSubscription; // For the event

  static const String _interactiveTutorialPromptId =
      'tacticBoardScreen_interactiveTutorialPrompt_v1';

  void _cleanupSubscriptions() {
    _playerSuccessfullyDraggedSubscription?.cancel();
    _playerSuccessfullyDraggedSubscription = null;
  }

  void dismissCurrentCoachMarkTutorial() {
    if (_coachMarkInstance?.isShowing ?? false) {
      zlog(data: "TutorialManager: Dismissing current coach mark via skip().");
      _coachMarkInstance?.skip(); // This will trigger onSkip or onFinish
    }
    _coachMarkInstance = null;
    _cleanupSubscriptions(); // Also clean up event listeners
  }

  // --- Step 1: Open Left Panel (remains the same) ---
  Future<void> checkAndShowOpenLeftPanelTutorial({
    required BuildContext context,
    required VoidCallback onLeftPanelButtonTutorialTap,
    required VoidCallback onTutorialStepFinished,
  }) async {
    if (!Navigator.of(context).mounted) return;
    bool tutorialSequenceShown = await TutorialUtils.isTutorialShown(
      _interactiveTutorialPromptId,
    );
    if (!tutorialSequenceShown) {
      final takeTour = await showConfirmationDialog(
        context: context,
        title: "Tactical Board Tour",
        content:
            "Welcome! Would you like a quick interactive tour? You'll need to tap on the highlighted items to proceed.",
        confirmButtonText: "Start Tour",
        cancelButtonText: "No, Thanks",
      );
      if (takeTour == true && Navigator.of(context).mounted) {
        zlog(data: "User opted IN for tutorial (Step 1: Open Left Panel).");
        await TutorialUtils.markTutorialAsShown(_interactiveTutorialPromptId);
        _showOpenLeftPanelTutorialInternal(
          context,
          onLeftPanelButtonTutorialTap,
          onTutorialStepFinished,
        );
      } else {
        zlog(data: "User opted OUT of or dismissed tutorial prompt.");
        if (takeTour == false)
          await TutorialUtils.markTutorialAsShown(_interactiveTutorialPromptId);
      }
    } else {
      zlog(data: "Tutorial prompt already dealt with.");
    }
  }

  void _showOpenLeftPanelTutorialInternal(
    BuildContext context,
    VoidCallback onLeftPanelButtonTutorialTap,
    VoidCallback onTutorialStepFinished,
  ) {
    dismissCurrentCoachMarkTutorial();
    List<tcm.TargetFocus> targets = _createOpenLeftPanelTarget(
      context,
      TutorialKeys.leftPanelButtonKey,
    );
    if (targets.isEmpty) {
      onTutorialStepFinished();
      return;
    }
    if (!Navigator.of(context).mounted) return;
    _coachMarkInstance = tcm.TutorialCoachMark(
      targets: targets,
      colorShadow: ColorManager.black.withOpacity(0.85),
      textSkip: "SKIP TOUR",
      skipWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ColorManager.grey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "SKIP TOUR",
          style: TextStyle(
            color: ColorManager.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onFinish: () {
        zlog(data: "TCM: Left Panel step finished.");
        _cleanupSubscriptions();
        onTutorialStepFinished();
      },
      onClickTarget: (target) {
        if (target.identify == TutorialStepIdentifiers.leftPanelIntro)
          onLeftPanelButtonTutorialTap();
      },
      onSkip: () {
        zlog(data: "TCM: Left Panel step skipped.");
        _cleanupSubscriptions();
        onTutorialStepFinished();
        return true;
      },
      pulseEnable: true,
    )..show(context: context);
  }

  List<tcm.TargetFocus> _createOpenLeftPanelTarget(
    BuildContext context,
    GlobalKey key,
  ) {
    List<tcm.TargetFocus> targets = [];
    if (key.currentContext != null) {
      targets.add(
        tcm.TargetFocus(
          identify: TutorialStepIdentifiers.leftPanelIntro,
          keyTarget: key,
          shape: tcm.ShapeLightFocus.RRect,
          radius: 10,
          contents: [
            tcm.TargetContent(
              align: tcm.ContentAlign.bottom,
              builder:
                  (ctx, ctrl) => AnimatedTutorialContent(
                    title: "Open Left Panel",
                    message:
                        "Tap this arrow to open the left panel for drawing tools.",
                  ),
            ),
          ],
        ),
      );
    }
    return targets;
  }

  // --- Step 2: Drag Player ---
  void showDragPlayerTutorial({
    required BuildContext context,
    required VoidCallback
    onTutorialStepFinished, // Called when drag is *actually* completed
  }) {
    dismissCurrentCoachMarkTutorial(); // Clear previous state and listeners

    List<tcm.TargetFocus> targets = _createDragPlayerTarget(
      context,
      TutorialKeys.firstPlayerKey,
    );

    if (targets.isEmpty) {
      zlog(data: "No target for dragging player. Skipping step.");
      onTutorialStepFinished();
      return;
    }
    if (!Navigator.of(context).mounted) return;

    bool highlightDismissedByTap = false;
    bool dragActionCompleted = false;

    // Listen for successful drag completion
    // CORRECTED STREAM NAME HERE:
    _playerSuccessfullyDraggedSubscription = TutorialEvents.onPlayerSuccessfullyDraggedToField.listen((
      event,
    ) {
      // Optional: Check if event.playerKey matches TutorialKeys.firstPlayerKey if needed
      zlog(
        data:
            "TutorialManager: Received PlayerSuccessfullyDraggedToFieldEvent.",
      );
      if (!dragActionCompleted) {
        dragActionCompleted = true;
        // Ensure highlight is gone if it wasn't already by a tap
        if (!highlightDismissedByTap &&
            (_coachMarkInstance?.isShowing ?? false)) {
          zlog(
            data:
                "TutorialManager: Drag completed, highlight was still showing. Forcing skip.",
          );
          _coachMarkInstance
              ?.skip(); // Force dismiss if still showing (will call onSkip/onFinish)
        } else {
          // If highlight already dismissed by tap, and now drag is complete
          zlog(
            data:
                "TutorialManager: Drag completed, highlight already dismissed. Calling onTutorialStepFinished.",
          );
          _cleanupSubscriptions(); // Clean up before calling, as onTutorialStepFinished might start new tutorial
          onTutorialStepFinished();
        }
      }
    });

    _coachMarkInstance = tcm.TutorialCoachMark(
      targets: targets,
      colorShadow: ColorManager.black.withOpacity(0.85),
      textSkip: "SKIP STEP",
      skipWidget: Container(
        /* ... skip widget ... */
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ColorManager.grey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "SKIP STEP",
          style: TextStyle(
            color: ColorManager.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      paddingFocus: 5,
      onFinish: () {
        zlog(data: "TCM: Drag Player highlight step finished (onFinish).");
        highlightDismissedByTap = true;
        // If drag already completed (event came first), then call the main callback
        if (dragActionCompleted) {
          zlog(
            data:
                "TutorialManager: Highlight finished, drag was already complete. Calling onTutorialStepFinished.",
          );
          _cleanupSubscriptions();
          onTutorialStepFinished();
        }
        // If drag not yet completed, we wait for the PlayerSuccessfullyDraggedToFieldEvent.
      },
      onClickTarget: (target) {
        zlog(
          data: "User TAP DOWN on target (player to drag): ${target.identify}",
        );
        if (target.identify == TutorialStepIdentifiers.dragFirstPlayer) {
          zlog(
            data:
                "TutorialManager: onClickTarget for drag player. Advancing tutorial to remove overlay.",
          );
          _coachMarkInstance?.next(); // This dismisses the highlight
          highlightDismissedByTap = true;
        }
      },
      onSkip: () {
        zlog(data: "TCM: Drag Player highlight step skipped.");
        highlightDismissedByTap = true;
        // If skipped, and drag hasn't happened, the overall step is considered skipped.
        _cleanupSubscriptions();
        onTutorialStepFinished();
        return true;
      },
      pulseEnable: true,
    )..show(context: context);
  }

  List<tcm.TargetFocus> _createDragPlayerTarget(
    BuildContext context,
    GlobalKey key,
  ) {
    List<tcm.TargetFocus> targets = [];
    if (key.currentContext != null) {
      targets.add(
        tcm.TargetFocus(
          identify: TutorialStepIdentifiers.dragFirstPlayer,
          keyTarget: key,
          shape: tcm.ShapeLightFocus.RRect,
          radius: 8,
          enableTargetTab: true,
          contents: [
            tcm.TargetContent(
              align: tcm.ContentAlign.bottom,
              builder:
                  (ctx, ctrl) => AnimatedTutorialContent(
                    title: "Drag Player to Field",
                    message:
                        "Now, TAP AND HOLD this player, then drag it onto the tactical board to place it.",
                    showFingerDragAnimation: true,
                    fingerAnimationStartAlign: Alignment.topCenter,
                    fingerDragVector: const Offset(100, -60), // TUNE THIS
                  ),
            ),
          ],
        ),
      );
    }
    return targets;
  }

  // --- Step 3: Add New Scene (remains the same) ---
  void showAddNewSceneTutorial({
    required BuildContext context,
    required VoidCallback onAddNewSceneButtonTutorialTap,
    required VoidCallback onTutorialStepFinished,
  }) {
    dismissCurrentCoachMarkTutorial();
    List<tcm.TargetFocus> targets = _createAddNewSceneTarget(
      context,
      TutorialKeys.addNewSceneButtonKey,
    );
    if (targets.isEmpty) {
      onTutorialStepFinished();
      return;
    }
    if (!Navigator.of(context).mounted) return;
    _coachMarkInstance = tcm.TutorialCoachMark(
      targets: targets,
      colorShadow: ColorManager.black.withOpacity(0.85),
      textSkip: "SKIP STEP",
      skipWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ColorManager.grey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "SKIP STEP",
          style: TextStyle(
            color: ColorManager.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onFinish: () {
        zlog(data: "TCM: Add New Scene step finished.");
        _cleanupSubscriptions();
        onTutorialStepFinished();
      },
      onClickTarget: (target) {
        if (target.identify == TutorialStepIdentifiers.addNewScene)
          onAddNewSceneButtonTutorialTap();
      },
      onSkip: () {
        zlog(data: "TCM: Add New Scene step skipped.");
        _cleanupSubscriptions();
        onTutorialStepFinished();
        return true;
      },
      pulseEnable: true,
    )..show(context: context);
  }

  List<tcm.TargetFocus> _createAddNewSceneTarget(
    BuildContext context,
    GlobalKey key,
  ) {
    List<tcm.TargetFocus> targets = [];
    if (key.currentContext != null) {
      targets.add(
        tcm.TargetFocus(
          identify: TutorialStepIdentifiers.addNewScene,
          keyTarget: key,
          shape: tcm.ShapeLightFocus.Circle,
          radius: 20,
          contents: [
            tcm.TargetContent(
              align: tcm.ContentAlign.top,
              builder:
                  (ctx, ctrl) => AnimatedTutorialContent(
                    title: "Add New Scene",
                    message:
                        "Tap this button to create a new scene or frame in your animation sequence.",
                  ),
            ),
          ],
        ),
      );
    }
    return targets;
  }
}
