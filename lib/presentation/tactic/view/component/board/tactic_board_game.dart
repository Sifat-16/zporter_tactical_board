import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/draggable_circle_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/form_line_plugin.dart'; // Assuming LineModel, FreeDrawModel are here or in models
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

// Assuming GameField is defined in 'game_field.dart' as per your import
import 'game_field.dart';
import 'mixin/board_riverpod_integration.dart';
import 'mixin/drawing_input_handler.dart';
import 'mixin/item_management.dart';
import 'mixin/layering_management.dart'; // Make sure this import points to the correct file

// --- Base Abstract Class (Unchanged) ---
abstract class TacticBoardGame extends FlameGame
    with DragCallbacks, TapDetector, RiverpodGameMixin {
  late GameField gameField;
}

// ---- The Refactored TacticBoard Class ----
class TacticBoard extends TacticBoardGame
    with
        DrawingInputHandler, // Provides drawing state and drag handlers
        ItemManagement, // Provides addItem, _checkAndRemoveComponent, _copyItem
        LayeringManagement, // Provides layering helpers and _moveUp/DownElement
        BoardRiverpodIntegration // Provides setupBoardListeners
        {
  AnimationItemModel? scene;
  TacticBoard({required this.scene});

  // --- Variables for the 1-second timer ---
  double _timerAccumulator = 0.0; // Accumulates delta time
  final double _checkInterval = 1.0; // Desired interval in seconds

  // --- Variable to store the previous state for comparison ---
  // Ensure this is a member variable if used across update calls
  String? _comparator;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    _initiateField(); // Field setup specific to this game
    setupBoardListeners(); // Call the listener setup method from the mixin
  }

  // Methods specific to TacticBoard remain here
  _initiateField() {
    gameField = GameField(size: Vector2(size.x - 20, size.y - 20));
    ref.read(boardProvider.notifier).updateFieldSize(size: gameField.size);
    add(gameField); // add() is available via FlameGame
    addInitialItems(scene?.components ?? []);
  }

  // updateScene({required AnimationItemModel? newScene}) {
  //   scene = newScene;
  // }

  @override
  Color backgroundColor() {
    return ColorManager.grey;
  }

  @override
  bool get debugMode => false; // Unchanged

  @override
  void onTapDown(TapDownInfo info) {
    // TODO: implement onTapDown // Keep original comment
    super.onTapDown(info);
    final tapPosition = info.raw.localPosition; // Position in game coordinates

    final components = componentsAtPoint(tapPosition.toVector2());

    if (components.isNotEmpty) {
      if (!components.any((t) => t is FieldComponent) &&
          !components.any((t) => t is DraggableCircleComponent) &&
          !components.any((t) => t is LineDrawerComponent)) {
        ref // ref is available via RiverpodGameMixin
            .read(boardProvider.notifier)
            .toggleSelectItemEvent(fieldItemModel: null);
      } else {
        zlog(data: "Animate to design tab called");
        ref.read(boardProvider.notifier).animateToDesignTab();
      }
    }
  }

  // --- Updated update method with Timer Logic ---
  @override
  void update(double dt) {
    super.update(dt); // Always call super.update!

    // Accumulate the time passed since the last frame
    _timerAccumulator += dt;

    // Check if the accumulated time has reached or exceeded the interval
    if (_timerAccumulator >= _checkInterval) {
      // --- Your change detection logic goes here ---
      zlog(
        data: "[TacticBoard] Running 1-second check...",
      ); // Log that the check is running

      // Assuming FieldItemModel is the correct type here
      List<FieldItemModel> items =
          ref.read(boardProvider.notifier).onAnimationSave();

      // Consider if toJson() is expensive; maybe compare models directly if possible
      String current = items
          .map((e) => e.toJson())
          .join(
            ',',
          ); // Use join for a more stable string representation if order matters

      if (_comparator == null) {
        _comparator = current;
      } else {
        if (_comparator != current) {
          // --- ACTION: Do something when a change is detected ---
          // e.g., trigger autosave, update external UI, etc.
          _comparator = current; // Update comparator to the new state
          updateDatabase();
        } else {}
      }
      // --- End of your change detection logic ---

      // Reset the accumulator. Subtracting the interval handles cases where dt might be
      // larger than the interval, keeping timing more consistent.
      _timerAccumulator -= _checkInterval;
      // Alternatively, reset to zero if precise timing isn't critical:
      // _timerAccumulator = 0.0;
    }

    // Other update logic can remain here and run every frame if needed
  }

  updateDatabase() {
    zlog(data: "Updated database..."); // Log that the check is running
    ref.read(animationProvider.notifier).updateDatabaseOnChange();
  }
}
