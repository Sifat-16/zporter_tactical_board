import 'dart:async' as a;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/circle_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/polygon_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/square_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

import 'game_field.dart';

class TacticBoardGameAnimation extends TacticBoardGame {
  TacticBoardGameAnimation({required this.animationModel});
  AnimationModel animationModel;
  final List<FieldItemModel> _components =
      []; // Keep track of added components.

  Vector2 gameFieldSize = Vector2.zero();
  late DrawingBoardComponent
  drawingBoard; // Declare the component instance variable

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
    gameField = GameField(
      size: Vector2(size.x - 20, size.y - 20),
      initialColor: animationModel.fieldColor,
    );
    gameFieldSize = gameField.size;
    await add(gameField);

    drawingBoard = DrawingBoardComponent(
      position: gameField.position,
      size: gameField.size,
    );
    await add(drawingBoard);
  }

  @override
  Color backgroundColor() {
    return ColorManager.white.withValues(alpha: 0.5);
  }

  Future<void> addItem(FieldItemModel item) async {
    _components.add(item); // Add to list for tracking
    if (item is PlayerModel) {
      await add(PlayerComponent(object: item));
    } else if (item is EquipmentModel) {
      await add(EquipmentComponent(object: item));
    } else if (item is LineModelV2) {
      await add(LineDrawerComponentV2(lineModelV2: item));
    } else if (item is SquareShapeModel) {
      await add(SquareShapeDrawerComponent(squareModel: item));
    } else if (item is CircleShapeModel) {
      await add(CircleShapeDrawerComponent(circleModel: item));
    } else if (item is PolygonShapeModel) {
      await add(PolygonShapeDrawerComponent(polygonModel: item));
    }
    await lifecycleEventsProcessed;
  }

  @override
  bool get debugMode => false; // Consider making this configurable

  // Make startAnimation return a Future<void>
  Future<void> startAnimation() async {
    List<AnimationItemModel> animations = animationModel.animationScenes;

    for (AnimationItemModel animationItem in animations) {
      List<FieldItemModel> items = animationItem.components;
      List<FreeDrawModelV2> freeLines =
          items.whereType<FreeDrawModelV2>().toList();

      List<FreeDrawModelV2> duplicateLines =
          freeLines.map((e) => e.clone()).toList();

      duplicateLines =
          duplicateLines.map((l) {
            List<Vector2> points = l.points;
            points =
                points
                    .map(
                      (p) => SizeHelper.getBoardActualVector(
                        gameScreenSize: gameField.size,
                        actualPosition: p,
                      ),
                    )
                    .toList();
            l.points = points;
            return l;
          }).toList();

      drawingBoard.loadLines(duplicateLines, suppressNotification: true);
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
            } else if (i is LineModelV2) {
              component = children.query<LineDrawerComponentV2>().firstWhere(
                (element) => element.lineModelV2.id == i.id,
              );
            } else if (i is CircleShapeModel) {
              component = children
                  .query<CircleShapeDrawerComponent>()
                  .firstWhere((element) => element.circleModel.id == i.id);
            } else if (i is SquareShapeModel) {
              component = children
                  .query<SquareShapeDrawerComponent>()
                  .firstWhere((element) => element.squareModel.id == i.id);
            } else if (i is PolygonShapeModel) {
              component = children
                  .query<PolygonShapeDrawerComponent>()
                  .firstWhere((element) => element.polygonModel.id == i.id);
            }
            // else if (i is FreeDrawModelV2) {
            //   component = children.query<FreeDrawerComponentV2>().firstWhere(
            //     (element) => element.freeDrawModelV2.id == i.id,
            //   );
            // }
          } catch (e) {
            zlog(
              data:
                  "Component not found for item ${i.id}, skipping animation for this item.",
            );
            continue; //Skip and process next component
          }

          zlog(data: "Component added effect ${component.runtimeType}");

          if (component != null) {
            if (component is LineDrawerComponentV2) {
              if (i is LineModelV2) {
                component.lineModelV2 = i;
              }
            } else if (component is SquareShapeDrawerComponent) {
              if (i is SquareShapeModel) {
                component.squareModel = i;
              }
            } else if (component is CircleShapeDrawerComponent) {
              if (i is CircleShapeModel) {
                component.circleModel = i;
              }
            } else if (component is PolygonShapeDrawerComponent) {
              if (i is PolygonShapeModel) {
                component.polygonModel = i;
              }
            } else if (component is FieldComponent) {
              component.object = i;
            }

            if (component is LineDrawerComponentV2 ||
                component is SquareShapeDrawerComponent ||
                component is CircleShapeDrawerComponent ||
                component is PolygonShapeDrawerComponent) {
              zlog(data: "Line drawer component stat ${i.toJson()}");
              remove(component);
              addItem(i);
            } else {
              final effect = MoveToEffect(
                SizeHelper.getBoardActualVector(
                  gameScreenSize: gameFieldSize,
                  actualPosition: i.offset ?? Vector2.zero(),
                ),
                EffectController(duration: 2), // Use your desired duration
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
      await Future.delayed(Duration(seconds: 2));
      zlog(data: "Check lifecycleEventsProcessed effect is processed or not");
    } // End of outer loop (animations)

    // After ALL AnimationItemModels and their effects are complete:
    try {
      ref.read(boardProvider.notifier).completeAnimationEvent();
      zlog(data: "All animations completed."); // Log completion.
    } catch (e) {}
  }
}
