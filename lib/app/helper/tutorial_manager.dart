import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

enum TutorialType {
  placeItems,
  createAnimation,
  deleteItem,
  // Add more tutorial types here
}

// Extension to get a user-friendly title for each tutorial type
extension TutorialTypeExtension on TutorialType {
  String get title {
    switch (this) {
      case TutorialType.placeItems:
        return "Place Items Tutorial";
      case TutorialType.createAnimation:
        return "Create Animation Tutorial";
      case TutorialType.deleteItem:
        return "Delete Item Tutorial";
      // Add cases for new tutorial types
      default:
        return "Unknown Tutorial";
    }
  }
}


class TutorialManager {
  // This class will manage the tutorials using tutorial_coach_mark

  // Define target information for each tutorial type
  static final Map<TutorialType, List<TargetFocus>> _tutorialTargets = {
    TutorialType.placeItems: [
      // Step 1: Tap on leftoolbar open button
      TargetFocus(
        // TODO: Replace with the GlobalKey or BuildContext of the left toolbar open button
        keyTarget: GlobalKey(), // Example placeholder
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "Tap here to open the left toolbar. This is where you'll find players and equipment to add to the board.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      // Step 2: Drag a player item to the field
      TargetFocus(
        // TODO: Replace with the GlobalKey or BuildContext of the first player item in the toolbar
        keyTarget: GlobalKey(), // Example placeholder
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "Now, drag this player icon from the toolbar onto the tactical board to place them on the field.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
    ],
    TutorialType.createAnimation: [
      // TODO: Define TargetFocus for 'Create Animation' tutorial, including titles for each step
    ],
    TutorialType.deleteItem: [
      // TODO: Define TargetFocus for 'Delete Item' tutorial, including titles for each step
    ],
    // Add more tutorial type targets here, each with a list of TargetFocus including titles
  };

  /// Retrieves the list of TargetFocus for a given tutorial type.
  static List<TargetFocus> _getTargetsForType(TutorialType type) {
    return _tutorialTargets[type] ?? [];
  }

  /// Shows a tutorial of the specified type.
  ///
  /// [context]: The BuildContext to show the tutorial in.
  /// [type]: The type of the tutorial to show.
  /// [onFinish]: Callback when the tutorial is finished.
  /// [onSkip]: Callback when the tutorial is skipped.
  static void showTutorial({
    required BuildContext context,
    required TutorialType type,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) {
    List<TargetFocus> targets = _getTargetsForType(type);

    if (targets.isEmpty) {
      // Optionally handle cases where no targets are defined for a type
      print('No targets defined for tutorial type: ${type.toString()}');
      return;
    }

    TutorialCoachMark(
      targets: targets,
      onFinish: onFinish,
      onSkip: onSkip,
    ).show(context: context);
  }

  // Add more methods here to manage different tutorial flows or states (e.g., checking if a tutorial has been shown)
}
