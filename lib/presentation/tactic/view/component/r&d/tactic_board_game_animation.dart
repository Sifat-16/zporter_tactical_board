import 'dart:async' as a;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_bloc.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_event.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

import 'game_field.dart';

class TacticBoardGameAnimation extends TacticBoardGame {
  TacticBoardGameAnimation({required this.boardBloc});

  final BoardBloc boardBloc;
  AnimationModel? _animationModel;
  final List<FieldItemModel> _components =
      []; // Keep track of added components.

  @override
  a.FutureOr<void> onLoad() async {
    await add(
      FlameMultiBlocProvider(
        providers: [
          FlameBlocProvider<BoardBloc, BoardState>.value(value: boardBloc),
        ],
      ),
    );
    _initiateField();

    _animationModel = boardBloc.state.animationModel;
    // No _startAnimation call here. It's called externally.

    startAnimation();

    return super.onLoad();
  }

  void _initiateField() {
    gameField = GameField(size: Vector2(size.x - 20, size.y - 20));
    add(gameField);
  }

  @override
  Color backgroundColor() {
    return ColorManager.white;
  }

  Future<void> addItem(FieldItemModel item) async {
    _components.add(item); // Add to list for tracking
    if (item is PlayerModel) {
      await add(PlayerComponent(object: item));
    } else if (item is EquipmentModel) {
      await add(EquipmentComponent(object: item));
    } else if (item is FormModel) {
      await add(FormComponent(object: item));
    }
    await lifecycleEventsProcessed;
  }

  @override
  bool get debugMode => false; // Consider making this configurable

  // Make startAnimation return a Future<void>
  Future<void> startAnimation() async {
    if (_animationModel == null) {
      return; // No animation to play.
    }

    List<AnimationItemModel> animations = _animationModel!.animations;

    zlog(
      data:
          "Adding effect to component ${animations.map((t) => t.components.map((c) => c.toJson()).toList()).toList()}",
    );

    // *** Key Change: Collect effects, don't apply them immediately ***

    for (AnimationItemModel animationItem in animations) {
      List<FieldItemModel> items = animationItem.components;

      for (var i in items) {
        int fieldItemIndex = _components.indexWhere((e) => e.id == i.id);
        if (fieldItemIndex == -1) {
          // Item not present, add it.
          await addItem(i);
          zlog(data: "Adding components ${i.toJson()}");
        } else {
          // Item exists.
          zlog(
            data:
                "Existing components ${i.toJson()} - ${children.map((e) => e.runtimeType).toList()}",
          );
          Component? component;
          try {
            // Use try-catch for error handling during component lookup.
            if (i is PlayerModel) {
              component = children.query<PlayerComponent>().firstWhere(
                (element) => element.object.id == i.id,
              );
            } else if (i is EquipmentModel) {
              component = children.query<EquipmentComponent>().firstWhere(
                (element) => element.object.id == i.id,
              );
            } else if (i is FormModel) {
              component = children.query<FormComponent>().firstWhere(
                (element) => element.object.id == i.id,
              );
            }
          } catch (e) {
            zlog(
              data:
                  "Component not found for item ${i.id}, skipping animation for this item.",
            );
            continue; //Skip and process next component
          }

          if (component != null) {
            zlog(
              data:
                  "Adding effect to component ${DateTime.now()} - ${i.offset}",
            );
            final effect = MoveToEffect(
              i.offset!,
              EffectController(duration: 3), // Use your desired duration
              onComplete: () {
                // We don't need a Completer anymore!
              },
            );
            // *** Key Change:  COLLECT, don't add directly ***
            // collectedEffects.add((component: component, effect: effect));
            component.add(effect);
          }
        }
        if (fieldItemIndex != -1) {
          _components[fieldItemIndex] = i;
        }
      }
      await Future.delayed(Duration(seconds: 3));
      zlog(data: "Check lifecycleEventsProcessed effect is processed or not");
      // *** Key Change:  Apply all effects AFTER collection ***
      // List<Future<void>> effectFutures = [];
      // for (final collectedEffect in collectedEffects) {
      //   final completer = a.Completer<void>(); // Use a Completer for awaiting
      //   collectedEffect.effect.onComplete = () {
      //     completer.complete(); // Resolve when effect is done.
      //   };
      //   collectedEffect.component.add(
      //     collectedEffect.effect,
      //   ); // NOW add the effect.
      //   effectFutures.add(completer.future);
      // }
      // await Future.wait(effectFutures);
      // zlog(data: "One animation is complete ${animationItem.id}");
    } // End of outer loop (animations)

    // After ALL AnimationItemModels and their effects are complete:
    boardBloc.add(CompleteAnimationEvent()); // Dispatch the event.
    zlog(data: "All animations completed."); // Log completion.
  }
}
