import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/draggable_circle_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/form_line_plugin.dart'; // Assuming LineModel, FreeDrawModel are here or in models
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
  final AnimationItemModel scene;
  TacticBoard({required this.scene});

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
    addInitialItems(scene.components);
  }

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
}
