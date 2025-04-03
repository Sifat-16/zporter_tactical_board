import 'dart:async' as a;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/form_line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

import 'game_field.dart';

class TacticBoardGameAnimation extends TacticBoardGame {
  TacticBoardGameAnimation({required this.animationModel});
  AnimationModel animationModel;
  final List<FieldItemModel> _components =
      []; // Keep track of added components.

  Vector2 gameFieldSize = Vector2.zero();

  @override
  a.FutureOr<void> onLoad() async {
    await _initiateField();
    // final bp = ref.read(boardProvider);

    Future.delayed(Duration(seconds: 0), () {
      startAnimation();
    });

    return super.onLoad();
  }

  Future<void> _initiateField() async {
    gameField = GameField(size: Vector2(size.x - 20, size.y - 20));
    gameFieldSize = gameField.size;
    await add(gameField);
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
      if (item.formItemModel is LineModel) {
        await add(
          LineDrawerComponent(
            // lineModel: (item.formItemModel as LineModel),
            formModel: item,
          ),
        );
      } else if (item.formItemModel is FreeDrawModel) {
        await add(FreeDrawerComponent(formModel: item));
      } else {
        await add(FormComponent(object: item));
      }
    }
    await lifecycleEventsProcessed;
  }

  @override
  bool get debugMode => false; // Consider making this configurable

  // Make startAnimation return a Future<void>
  Future<void> startAnimation() async {
    List<AnimationItemModel> animations = animationModel.animationScenes;

    animations = adjustAnimationItemsForFieldSize(
      originalAnimations: animations,
      currentGameFieldSize: gameFieldSize,
    );

    // *** Key Change: Collect effects, don't apply them immediately ***

    for (AnimationItemModel animationItem in animations) {
      List<FieldItemModel> items = animationItem.components;
      zlog(
        data:
            "Adding effect to component ${animationItem.fieldSize} - ${gameFieldSize}",
      );
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
              if (i.formItemModel is LineModel) {
                component = children.query<LineDrawerComponent>().firstWhere(
                  (element) => element.formModel.id == i.id,
                );
              } else if (i.formItemModel is FreeDrawModel) {
                component = children.query<FreeDrawerComponent>().firstWhere(
                  (element) => element.formModel.id == i.id,
                );
              } else {
                component = children.query<FormComponent>().firstWhere(
                  (element) => element.object.id == i.id,
                );
              }
            }
          } catch (e) {
            zlog(
              data:
                  "Component not found for item ${i.id}, skipping animation for this item.",
            );
            continue; //Skip and process next component
          }

          zlog(data: "Component added effect ${component.runtimeType}");

          if (component != null) {
            if (component is FieldComponent) {
              component.object = i;
            } else if (component is LineDrawerComponent) {
              if (i is FormModel) {
                component.formModel = i;
              }
            }

            // zlog(data: "Component added effect ${i.runtimeType} - ${i.offset}");
            // *** Key Change:  COLLECT, don't add directly ***
            // collectedEffects.add((component: component, effect: effect));
            if (component is LineDrawerComponent) {
              zlog(data: "Line drawer component stat ${i.toJson()}");
              remove(component);
              addItem(i);
            } else if (component is FreeDrawerComponent) {
              zlog(data: "Free drawer component stat ${i.toJson()}");
              remove(component);
              addItem(i);
            } else {
              final effect = MoveToEffect(
                i.offset ?? Vector2.zero(),
                EffectController(duration: 3), // Use your desired duration
                onComplete: () {
                  // We don't need a Completer anymore!
                },
              );
              component.add(effect);
            }
          }
        }
        if (fieldItemIndex != -1) {
          _components[fieldItemIndex] = i;
        }
      }
      await Future.delayed(Duration(seconds: 3));
      zlog(data: "Check lifecycleEventsProcessed effect is processed or not");
    } // End of outer loop (animations)

    // After ALL AnimationItemModels and their effects are complete:
    ref.read(boardProvider.notifier).completeAnimationEvent();
    zlog(data: "All animations completed."); // Log completion.
  }

  List<AnimationItemModel> adjustAnimationItemsForFieldSize({
    required List<AnimationItemModel> originalAnimations,
    required Vector2 currentGameFieldSize,
  }) {
    if (currentGameFieldSize.x <= 0 || currentGameFieldSize.y <= 0) {
      zlog(
        data: "Error: Current game field size has zero or negative dimensions.",
      );
      return originalAnimations; // Return original list if current size is invalid
    }

    List<AnimationItemModel> adjustedAnimations = [];

    for (final originalAnimationItem in originalAnimations) {
      // Clone the animation item structure first (excluding components list initially)
      final AnimationItemModel
      adjustedAnimationItem = originalAnimationItem.copyWith(
        components: [], // Start with empty components list in the copy
        fieldSize:
            currentGameFieldSize, // Update the field size for the adjusted scene
      );

      final Vector2 savedFieldSize =
          originalAnimationItem.fieldSize; // Now required

      // Check if saved field size is valid for scaling
      if (savedFieldSize.x <= 0 || savedFieldSize.y <= 0) {
        zlog(
          data:
              "Warning: Skipping adjustments for scene ${originalAnimationItem.id} due to invalid saved field size: $savedFieldSize",
        );
        // Add original components (cloned) without scaling if saved size is invalid?
        adjustedAnimationItem.components =
            originalAnimationItem.components
                .map((item) => item.clone())
                .toList();
        adjustedAnimations.add(adjustedAnimationItem);
        continue; // Move to the next animation item
      }

      // Calculate scaling factors
      final double scaleX = currentGameFieldSize.x / savedFieldSize.x;
      final double scaleY = currentGameFieldSize.y / savedFieldSize.y;

      // Process each component within the original animation item
      for (final originalItem in originalAnimationItem.components) {
        // Clone the original item to modify it
        final FieldItemModel adjustedItem = originalItem.clone();

        // Adjust offset (assuming offset is relative to top-left 0,0)
        if (adjustedItem.offset != null) {
          adjustedItem.offset = Vector2(
            adjustedItem.offset!.x * scaleX,
            adjustedItem.offset!.y * scaleY,
          );

          if (adjustedItem is FormModel) {
            FormItemModel? formItem = adjustedItem.formItemModel?.clone();
            if (formItem is LineModel) {
              formItem.start = Vector2(
                formItem.start.x * scaleX,
                formItem.start.y * scaleY,
              );

              formItem.end = Vector2(
                formItem.end.x * scaleX,
                formItem.end.y * scaleY,
              );
            } else if (formItem is FreeDrawModel) {
              zlog(data: "freedraw points before ${formItem.points}");
              formItem.points =
                  formItem.points
                      .map((e) => Vector2(e.x * scaleX, e.y * scaleY))
                      .toList();

              zlog(data: "freedraw points after ${formItem.points}");
            }
            adjustedItem.formItemModel = formItem;
          }

          /// handle if the line drawer component
        } else {
          if (adjustedItem is FormModel) {
            FormItemModel? formItem = adjustedItem.formItemModel?.clone();
            if (formItem is FreeDrawModel) {
              formItem.points =
                  formItem.points
                      .map((e) => Vector2(e.x * scaleX, e.y * scaleY))
                      .toList();
            }
            adjustedItem.formItemModel = formItem;
          }
        }
        // Add the modified clone to the new animation item's component list
        adjustedAnimationItem.components.add(adjustedItem);
      }
      // Add the fully adjusted animation item (with its adjusted components) to the result list
      adjustedAnimations.add(adjustedAnimationItem);
    }

    return adjustedAnimations;
  }
}
