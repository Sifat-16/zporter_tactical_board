import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/draggable_circle_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/scaling_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/circle_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart'; // Assuming LineModel, FreeDrawModel are here or in models
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/polygon_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/square_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

// Assuming GameField is defined in 'game_field.dart' as per your import
import 'game_field.dart';
import 'mixin/board_riverpod_integration.dart';
import 'mixin/drawing_input_handler.dart';
import 'mixin/item_management.dart';
import 'mixin/layering_management.dart'; // Make sure this import points to the correct file

String? boardComparator;

// --- Base Abstract Class (Unchanged) ---
abstract class TacticBoardGame extends FlameGame
    with DragCallbacks, TapDetector, RiverpodGameMixin {
  late GameField gameField;
  late DrawingBoardComponent drawingBoard;
  addItem(FieldItemModel item, {bool save = true});
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
  bool saveToDb;
  Function(AnimationItemModel?)? onSceneSave;
  TacticBoard({required this.scene, this.saveToDb = true, this.onSceneSave});

  // --- Variables for the 1-second timer ---
  double _timerAccumulator = 0.0; // Accumulates delta time
  final double _checkInterval = 1.0; // Desired interval in seconds

  // --- Variable to store the previous state for comparison ---
  // Ensure this is a member variable if used across update calls

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    setupBoardListeners(); // Call the listener setup method from the mixin
    _initiateField(); // Field setup specific to this game
  }

  // Methods specific to TacticBoard remain here
  _initiateField() {
    gameField = GameField(
      size: Vector2(size.x - 20, size.y - 20),
      initialColor: scene?.fieldColor,
    );
    ref.read(boardProvider.notifier).updateFieldSize(size: gameField.size);
    add(gameField); // add() is available via FlameGame
    addInitialItems(scene?.components ?? []);

    // initiateFieldColor();
  }

  @override
  Color backgroundColor() {
    return ColorManager.grey;
  }

  @override
  bool get debugMode => false; // Unchanged

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    final tapPosition = info.raw.localPosition; // Position in game coordinates

    final components = componentsAtPoint(tapPosition.toVector2());

    if (components.isNotEmpty) {
      if (!components.any((t) => t is FieldComponent) &&
          !components.any((t) => t is DraggableCircleComponent) &&
          !components.any((t) => t is LineDrawerComponentV2) &&
          !components.any((t) => t is CircleShapeDrawerComponent) &&
          !components.any((t) => t is CircleRadiusDraggableDot) &&
          !components.any((t) => t is SquareShapeDrawerComponent) &&
          !components.any((t) => t is SquareRadiusDraggableDot) &&
          !components.any((t) => t is ScalingHandle) &&
          !components.any((t) => t is PolygonShapeDrawerComponent) &&
          !components.any((t) => t is PolygonVertexDotComponent) &&
          ref.read(lineProvider).activeForm is! PolygonShapeModel) {
        bool deselect = true;

        try {
          FieldItemModel? f = ref.read(boardProvider).selectedItemOnTheBoard;
          if (f is FreeDrawModelV2) {
            deselect = false;
          }
        } catch (e) {}

        if (deselect) {
          ref
              .read(boardProvider.notifier)
              .toggleSelectItemEvent(fieldItemModel: null);
        }

        zlog(data: "Tapped components ${components}");
      } else {
        zlog(data: "Animate to design tab called");

        /// detect the trash mode is on or not, if on then remove that widget

        bool isTrashModeActive = false;
        try {
          isTrashModeActive = ref.read(lineProvider).isTrashActive;
        } catch (e) {}

        if (isTrashModeActive) {
          // ref.read(boardProvider.notifier).removeElement();
        } else {
          ref.read(boardProvider.notifier).animateToDesignTab();
        }
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

      // Assuming FieldItemModel is the correct type here
      List<FieldItemModel> items =
          ref.read(boardProvider.notifier).onAnimationSave();

      // Consider if toJson() is expensive; maybe compare models directly if possible
      String current = items
          .map((e) => e.toJson())
          .join(
            ',',
          ); // Use join for a more stable string representation if order matters
      current =
          "$current,${ref.read(animationProvider.notifier).getFieldColor().toARGB32()}";

      if (boardComparator == null) {
        boardComparator = current;
      } else {
        if (boardComparator != current) {
          // --- ACTION: Do something when a change is detected ---
          // e.g., trigger autosave, update external UI, etc.
          boardComparator = current; // Update comparator to the new state

          updateDatabase();
        } else {}
      }
      _timerAccumulator -= _checkInterval;
    }

    // Other update logic can remain here and run every frame if needed
  }

  updateDatabase() {
    zlog(
      data:
          "Updated database... ${ref.read(boardProvider.notifier).onAnimationSave()}",
    ); // Log that the check is running

    ref
        .read(animationProvider.notifier)
        .updateDatabaseOnChange(saveToDb: saveToDb)
        .then((a) {
          zlog(data: "After save coming animation item model ${a?.toJson()}");
          ref.read(animationProvider.notifier).saveHistory(scene: a);
          onSceneSave?.call(a);
        });
  }

  void redrawLines() {
    List<FieldItemModel> items =
        ref.read(boardProvider.notifier).allFieldItems();
    zlog(data: "items detected ${items}");
    resetItems(items);
  }
}
