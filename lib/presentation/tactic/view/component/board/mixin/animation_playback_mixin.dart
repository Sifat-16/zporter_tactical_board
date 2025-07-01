import 'dart:async' as a;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
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
import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/game_field.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game_animation.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/text_field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/circle_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/polygon_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/square_shape_plugin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class AnimatingObj {
  final bool isAnimating;
  final bool isExporting;
  AnimatingObj({required this.isAnimating, required this.isExporting});

  factory AnimatingObj.animate() {
    return AnimatingObj(isAnimating: true, isExporting: false);
  }
  factory AnimatingObj.export() {
    return AnimatingObj(isAnimating: false, isExporting: true);
  }
}

mixin AnimationPlaybackMixin on TacticBoardGame {
  late TacticBoard _tacticBoard;
  // MODIFIED: update method with new dt capping
  static const double VERY_LARGE_DT_THRESHOLD =
      0.1; // 100ms (10 FPS equivalent)
  static const double REASONABLE_TIME_STEP_AFTER_FREEZE =
      1.0 / 30.0; // Cap to process at ~30FPS after a long freeze

  static const double BASE_BALL_ROTATION_SPEED_RADS_PER_SEC = 2 * 3.14159;

  late AnimationModel animationModel;
  late bool autoPlay;

  late bool isForExportMode;
  late Function(double progress)? onExportProgressUpdate;

  List<FieldItemModel> _components = [];

  bool _isAnimationPlaying = false;
  @override
  bool get isAnimationCurrentlyPlaying => _isAnimationPlaying;
  bool _isAnimationPaused = false;
  @override
  bool get isAnimationCurrentlyPaused => _isAnimationPaused;

  double _scenePaceFactor = 1.0;
  int _currentSceneIndex = 0;
  bool _wasHardResetRecently = false;
  a.Timer? _sceneProgressionTimer;
  Duration _baseSceneDelay = const Duration(milliseconds: 500); // User's value
  Duration _baseMovementDuration = const Duration(
    seconds: 1,
  ); // This is now per-scene via AnimationItemModel
  final List<ManualVelocityAnimation> _activeManualAnimations = [];
  Set<String> _activeMovingItemIdsInCurrentScene = {};
  bool _currentSceneDelayTimerActive = false;
  void startAnimation({
    required AnimationModel am,
    bool ap = false,
    bool isForE = false, // Default to not being in export mode
    Function(double progress)? onExportP,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      animationModel = am;
      autoPlay = ap;
      isForExportMode = isForE;
      onExportProgressUpdate = onExportP;
      if (isForExportMode) {
        _scenePaceFactor = 2.0; // Run faster for export (adjust as needed)
        zlog(
          data:
              "TacticBoardGameAnimation: INSTANTIATED IN EXPORT MODE. Pace: $_scenePaceFactor, Scene Delay: ${_baseSceneDelay.inMilliseconds}ms",
        );
      }

      /// before start animating, we have to erase all components from the board, and then
      _tacticBoard = (this as TacticBoard);
      _tacticBoard.isAnimating = false;
      _tacticBoard.removeAll(children.whereType<FieldComponent>());
      zlog(data: "TacticBoardGameAnimation: Field initiated.");
      if (animationModel.animationScenes.isEmpty) {
        _isAnimationPlaying = false;
        return;
      }
      if (autoPlay) {
        zlog(data: "Autoplaye is true now performing animation from start");
        _setupInitialSceneStatically();
        performStartAnimationFromBeginning();
      } else {
        _setupInitialSceneStatically();
        _isAnimationPlaying = false;
        _isAnimationPaused = false;
        _currentSceneIndex = 0;
        _wasHardResetRecently = false;
      }

      zlog(
        data:
            "TacticBoardGameAnimation: onLoad finished. Animation playing: $_isAnimationPlaying",
      );
    });
  }

  @override
  void update(double dt) {
    double effectiveDt = dt;
    if (dt > VERY_LARGE_DT_THRESHOLD) {
      // zlog(
      //   data:
      //       "TacticBoardGameAnimation: Very large dt detected: $dt. Capping to $REASONABLE_TIME_STEP_AFTER_FREEZE for this frame.",
      // );
      effectiveDt = REASONABLE_TIME_STEP_AFTER_FREEZE;
    }
    // Ensure effectiveDt is positive for safety in calculations, though Flame usually provides positive dt
    if (effectiveDt <= 0) {
      effectiveDt = 1.0 /
          60.0; // Fallback to a small positive value if dt is zero/negative
    }

    super.update(effectiveDt);

    if (_isAnimationPlaying && !_isAnimationPaused && !this.paused) {
      bool anAnimationCompletedThisFrame = false;
      for (int i = _activeManualAnimations.length - 1; i >= 0; i--) {
        final anim = _activeManualAnimations[i];

        if (anim.component is EquipmentComponent) {
          final equipmentComponent = anim.component as EquipmentComponent;
          // Assuming your ManualVelocityAnimation instance (`anim`) has an `isMoving` getter.
          // Your code in `_startOrUpdateManualAnimation` already uses `existingAnim.isMoving`,
          // so this property should be available.
          if (equipmentComponent.object.name == "BALL" && anim.isMoving) {
            // Calculate rotation for this frame.
            // The rotation speed is determined by the base rotation speed,
            // the time delta (effectiveDt), and the current scene's pace factor.
            double rotationThisFrame = BASE_BALL_ROTATION_SPEED_RADS_PER_SEC *
                effectiveDt *
                _scenePaceFactor;

            equipmentComponent.angle -= rotationThisFrame;

            // Optional: Keep the angle within 0 to 2*PI range if desired,
            // though Flame typically handles larger angle values correctly.
            // equipmentComponent.angle %= (2 * 3.14159);
          }
        }

        if (anim.update(effectiveDt)) {
          // Pass the same effectiveDt here
          _activeMovingItemIdsInCurrentScene.remove(anim.itemModel.id);
          _activeManualAnimations.removeAt(i);
          anAnimationCompletedThisFrame = true;
        }
      }
      if (anAnimationCompletedThisFrame ||
          (_activeManualAnimations.isEmpty &&
              _activeMovingItemIdsInCurrentScene.isEmpty)) {
        _checkSceneCompletionAndProceed();
      }
    }
  }

  double get currentScenePaceFactor => _scenePaceFactor;

  @override
  void performStartAnimationFromBeginning() {
    zlog(data: "TacticBoardGameAnimation: performStartAnimationFromBeginning.");
    if (_wasHardResetRecently) {
      _wasHardResetRecently = false;
    }
    if (paused) resumeEngine();
    _isAnimationPlaying = true;
    _isAnimationPaused = false;
    _currentSceneIndex = 0;
    _clearAllManualAnimations();
    _activeMovingItemIdsInCurrentScene.clear();
    _currentSceneDelayTimerActive = false;
    _sceneProgressionTimer?.cancel();

    _proceedToNextScene();
  }

  @override
  Future<void> performResumeAnimation() async {
    if (!_isAnimationPlaying || !_isAnimationPaused) return;
    _isAnimationPaused = false;
    if (isMounted && this.paused) {
      this.resumeEngine();
      await Future.delayed(Duration.zero);
    }
    for (final anim in _activeManualAnimations) anim.resume();
    _checkSceneCompletionAndProceed();
  }

  @override
  void performPauseAnimation() {
    if (!_isAnimationPlaying || _isAnimationPaused) {
      if (_isAnimationPlaying &&
          _isAnimationPaused &&
          isMounted &&
          !this.paused) this.pauseEngine();
      _isAnimationPaused = true;
      _sceneProgressionTimer?.cancel();
      _currentSceneDelayTimerActive = false;
      return;
    }
    _isAnimationPaused = true;
    _sceneProgressionTimer?.cancel();
    _currentSceneDelayTimerActive = false;
    for (final anim in _activeManualAnimations) anim.pause();
    if (isMounted && !paused) pauseEngine();
  }

  @override
  void performStopAnimation({bool hardReset = false}) {
    if (paused) resumeEngine();
    _isAnimationPlaying = false;
    _isAnimationPaused = false;
    _sceneProgressionTimer?.cancel();
    _currentSceneDelayTimerActive = false;
    _clearAllManualAnimations();
    _activeMovingItemIdsInCurrentScene.clear();
    _currentSceneIndex = 0;
    _scenePaceFactor = 1;
    if (hardReset) {
    } else {
      WidgetsBinding.instance.addPostFrameCallback((t) {
        _tacticBoard.removeAll(children.whereType<FieldComponent>());
        ref.read(boardProvider.notifier).toggleAnimating(animatingObj: null);
        _tacticBoard.addInitialItems(_tacticBoard.scene?.components ?? []);
        _tacticBoard.isAnimating = false;
      });
      zlog(data: "TacticBoardGameAnimation: Animation System Stopped.");
    }
  }

  @override
  void performSetAnimationPace(double newPaceFactor) {
    if (newPaceFactor <= 0.0) return;
    final oldPaceFactor = _scenePaceFactor;
    _scenePaceFactor = newPaceFactor;
    zlog(
      data:
          "TacticBoardGameAnimation: Global pace factor changed from $oldPaceFactor to $newPaceFactor.",
    );
    if (oldPaceFactor > 0 &&
        oldPaceFactor != newPaceFactor &&
        _isAnimationPlaying &&
        !_isAnimationPaused) {
      double paceScaleFactor = newPaceFactor / oldPaceFactor;
      for (final anim in _activeManualAnimations) {
        double newIndividualSpeed =
            anim.currentSpeedMagnitude * paceScaleFactor;
        anim.updateSpeedMagnitude(newIndividualSpeed);
      }
    }
  }

  @override
  void performHardResetAnimation() {
    performStopAnimation(hardReset: true);
    final List<Component> componentsToRemove = children
        .where(
          (child) =>
              child is PlayerComponent ||
              child is EquipmentComponent ||
              child is LineDrawerComponentV2 ||
              child is SquareShapeDrawerComponent ||
              child is CircleShapeDrawerComponent ||
              child is PolygonShapeDrawerComponent ||
              child is TextFieldComponent,
        )
        .toList();
    if (componentsToRemove.isNotEmpty) removeAll(componentsToRemove);
    _components.clear();
    if (isLoaded && children.contains(drawingBoard)) {
      drawingBoard.loadLines([], suppressNotification: true);
    }
    _wasHardResetRecently = true;
    _isAnimationPlaying = false;
    _isAnimationPaused = false;
    _setupInitialSceneStatically();
  }

  @override
  Color backgroundColor() {
    return (ColorManager.white).withAlpha(128);
  }

  addItemForAnimation(FieldItemModel item, {bool save = true}) async {
    if (item is PlayerModel) {
      add(PlayerComponent(object: item)); // add() is available via FlameGame
    } else if (item is EquipmentModel) {
      add(EquipmentComponent(object: item)); // add() is available via FlameGame
    } else if (item is LineModelV2) {
      await add(LineDrawerComponentV2(lineModelV2: item));
    } else if (item is CircleShapeModel) {
      await add(CircleShapeDrawerComponent(circleModel: item));
    } else if (item is SquareShapeModel) {
      await add(SquareShapeDrawerComponent(squareModel: item));
    } else if (item is PolygonShapeModel) {
      await add(PolygonShapeDrawerComponent(polygonModel: item));
    } else if (item is TextModel) {
      await add(TextFieldComponent(object: item));
    }
  }

  void _clearAllManualAnimations() {
    for (var anim in _activeManualAnimations) anim.stop();
    _activeManualAnimations.clear();
  }

  Component? _findComponentByModelId(String modelId) {
    return children.firstWhereOrNull((c) {
      if (c is PlayerComponent) return c.object.id == modelId;
      if (c is EquipmentComponent) return c.object.id == modelId;
      if (c is LineDrawerComponentV2) return c.lineModelV2.id == modelId;
      if (c is SquareShapeDrawerComponent) return c.squareModel.id == modelId;
      if (c is CircleShapeDrawerComponent) return c.circleModel.id == modelId;
      if (c is PolygonShapeDrawerComponent) return c.polygonModel.id == modelId;
      if (c is TextFieldComponent) return c.object.id == modelId;
      return false;
    });
  }

  void _startOrUpdateManualAnimation(
    PositionComponent component,
    FieldItemModel itemModel,
    Vector2 targetPositionInGameCoords,
    double calculatedSpeedMagnitude,
  ) {
    var existingAnim = _activeManualAnimations.firstWhereOrNull(
      (a) => a.component == component,
    );
    bool alreadyAtTarget =
        (component.position - targetPositionInGameCoords).length2 <
            ManualVelocityAnimation.arrivalThresholdSquared;
    if (alreadyAtTarget ||
        (calculatedSpeedMagnitude < 0.01 && !alreadyAtTarget)) {
      component.position.setFrom(targetPositionInGameCoords);
      if (existingAnim != null) {
        existingAnim.stop();
        _activeManualAnimations.remove(existingAnim);
      }
      _activeMovingItemIdsInCurrentScene.remove(itemModel.id);
      return;
    }
    if (existingAnim != null) {
      existingAnim.updateSpeedMagnitude(calculatedSpeedMagnitude);
      existingAnim.moveTo(targetPositionInGameCoords);
    } else {
      existingAnim = ManualVelocityAnimation(
        component: component,
        itemModel: itemModel,
        initialTargetPositionGameCoords: targetPositionInGameCoords,
        speedMagnitude: calculatedSpeedMagnitude,
      );
      _activeManualAnimations.add(existingAnim);
      existingAnim.moveTo(targetPositionInGameCoords);
    }
    if (existingAnim.isMoving)
      _activeMovingItemIdsInCurrentScene.add(itemModel.id);
    else
      _activeMovingItemIdsInCurrentScene.remove(itemModel.id);
  }

  Future<void> _setupInitialSceneStatically() async {
    if (animationModel.animationScenes.isEmpty) return;
    _currentSceneIndex = 0;
    AnimationItemModel firstScene = animationModel.animationScenes[0];
    _activeMovingItemIdsInCurrentScene.clear();
    _currentSceneDelayTimerActive = false;
    _sceneProgressionTimer?.cancel();
    _clearAllManualAnimations();
    final List<Component> componentsToRemove = children
        .where(
          (child) => !(child is GameField || child is DrawingBoardComponent),
        )
        .toList();
    if (componentsToRemove.isNotEmpty) removeAll(componentsToRemove);
    _components.clear();
    List<FreeDrawModelV2> freeLines =
        firstScene.components.whereType<FreeDrawModelV2>().toList();
    List<FreeDrawModelV2> processedFreeLines = freeLines.map((e) {
      var cloned = e.clone();
      cloned.points = cloned.points
          .map(
            (p) => SizeHelper.getBoardActualVector(
              gameScreenSize: _tacticBoard.gameField.size,
              actualPosition: p,
            ),
          )
          .toList();
      return cloned;
    }).toList();
    drawingBoard.loadLines(processedFreeLines, suppressNotification: true);
    List<Future<void>> addItemFutures = [];
    for (var itemModel in firstScene.components) {
      if (itemModel is FreeDrawModelV2) continue;
      addItemFutures.add(
        addItemForAnimation(itemModel).then((_) async {
          // Using your game's addItem override
          await Future.delayed(Duration.zero);
          Component? comp = _findComponentByModelId(itemModel.id);
          if (comp is PositionComponent && itemModel.offset != null) {
            comp.position = SizeHelper.getBoardActualVector(
              gameScreenSize: _tacticBoard.gameField.size,
              actualPosition: itemModel.offset!,
            );
          }
        }),
      );
    }
    await Future.wait(addItemFutures);
    await Future.delayed(Duration.zero);
    zlog(
      data: "TacticBoardGameAnimation: Initial scene 0 static setup complete.",
    );
  }

  Future<void> _processScene(AnimationItemModel animationItem) async {
    if (_wasHardResetRecently || (this.paused && _isAnimationPaused)) return;
    if (!_isAnimationPlaying || _isAnimationPaused) return;

    zlog(
      data:
          "TacticBoardGameAnimation: _processScene START for scene index: ${_currentSceneIndex - 1}. Pace: $_scenePaceFactor",
    );

    List<FieldItemModel> itemsDefinedInCurrentScene = animationItem.components;
    Set<String> idsInCurrentScene =
        itemsDefinedInCurrentScene.map((e) => e.id).toSet();

    _activeMovingItemIdsInCurrentScene.clear();
    _currentSceneDelayTimerActive = false;
    _sceneProgressionTimer?.cancel();

    // --- 1. Remove Stale Components ---
    List<Component> flameComponentsToRemove = [];
    for (var component in List.from(children)) {
      if (component is GameField || component is DrawingBoardComponent)
        continue;
      String? componentModelId = _getComponentModelId(component);
      if (componentModelId != null &&
          !idsInCurrentScene.contains(componentModelId)) {
        flameComponentsToRemove.add(component);
      }
    }
    if (flameComponentsToRemove.isNotEmpty) {
      for (var compToRemove in flameComponentsToRemove) {
        _activeManualAnimations.removeWhere(
          (anim) => anim.component == compToRemove,
        );
        String? idToRemove = _getComponentModelId(compToRemove);
        if (idToRemove != null)
          _components.removeWhere((m) => m.id == idToRemove);
        remove(compToRemove);
      }
      await Future.delayed(Duration.zero);
    }

    // --- 2. Process FreeDraw lines for the current scene ---
    List<FreeDrawModelV2> freeLinesInCurrentScene =
        itemsDefinedInCurrentScene.whereType<FreeDrawModelV2>().toList();
    List<FreeDrawModelV2> processedFreeLines = freeLinesInCurrentScene.map((e) {
      var cloned = e.clone();
      cloned.points = cloned.points
          .map(
            (p) => SizeHelper.getBoardActualVector(
              gameScreenSize: _tacticBoard.gameField.size,
              actualPosition: p,
            ),
          )
          .toList();
      return cloned;
    }).toList();
    drawingBoard.loadLines(processedFreeLines, suppressNotification: true);

    // --- 3. Add or Update other components ---
    List<Future<void>> addItemFutures = [];
    List<Map<String, dynamic>> componentsToAnimateDetails = [];

    for (var itemModel in itemsDefinedInCurrentScene) {
      if (itemModel is FreeDrawModelV2) continue;
      if (!_isAnimationPlaying) break;
      Component? existingComponent = _findComponentByModelId(itemModel.id);

      if (existingComponent == null) {
        addItemFutures.add(
          addItemForAnimation(itemModel).then((_) async {
            // Using your game's addItem override
            await Future.delayed(Duration.zero);
            Component? newComp = _findComponentByModelId(itemModel.id);
            if (newComp is PositionComponent) {
              Vector2 initialPos = itemModel.offset != null
                  ? SizeHelper.getBoardActualVector(
                      gameScreenSize: _tacticBoard.gameField.size,
                      actualPosition: itemModel.offset!,
                    )
                  : newComp.position;
              newComp.position = initialPos;
              if ((newComp is PlayerComponent ||
                      newComp is EquipmentComponent) &&
                  itemModel.offset != null) {
                componentsToAnimateDetails.add({
                  'component': newComp,
                  'itemModel': itemModel,
                  'targetModelOffset': itemModel.offset!,
                });
              }
            }
          }),
        );
      } else {
        if (existingComponent is PositionComponent) {
          bool isPlayerOrEquipment = existingComponent is PlayerComponent ||
              existingComponent is EquipmentComponent;
          if (isPlayerOrEquipment && existingComponent is FieldComponent) {
            (existingComponent).object = itemModel;
            if (itemModel.offset != null) {
              Vector2 targetPos = SizeHelper.getBoardActualVector(
                gameScreenSize: _tacticBoard.gameField.size,
                actualPosition: itemModel.offset!,
              );
              if ((existingComponent.position - targetPos).length2 >
                  ManualVelocityAnimation.arrivalThresholdSquared) {
                componentsToAnimateDetails.add({
                  'component': existingComponent,
                  'itemModel': itemModel,
                  'targetModelOffset': itemModel.offset!,
                });
              } else {
                existingComponent.position.setFrom(targetPos);
                _activeManualAnimations.removeWhere(
                  (anim) => anim.component == existingComponent,
                );
              }
            } else {
              _activeManualAnimations.removeWhere(
                (anim) => anim.component == existingComponent,
              );
            }
          } else {
            FieldItemModel? currentComponentModelInComponent =
                _getModelFromComponent(existingComponent);
            // IMPORTANT: Ensure your FieldItemModel subclasses (LineModelV2, SquareShapeModel, etc.)
            // correctly override operator == and hashCode for this comparison to work as intended.
            if (currentComponentModelInComponent != null &&
                itemModel == currentComponentModelInComponent) {
              zlog(
                data:
                    "TacticBoardGameAnimation: Shape/Line ${itemModel.id} is UNCHANGED, leaving as is.",
              );
              if (itemModel.offset != null) {
                // Ensure static position is up-to-date
                existingComponent.position = SizeHelper.getBoardActualVector(
                  gameScreenSize: _tacticBoard.gameField.size,
                  actualPosition: itemModel.offset!,
                );
              }
            } else {
              zlog(
                data:
                    "TacticBoardGameAnimation: Shape/Line ${itemModel.id} HAS CHANGED or cannot compare. Re-adding.",
              );
              _activeManualAnimations.removeWhere(
                (anim) => anim.component == existingComponent,
              );
              addItemFutures.add(() async {
                if (existingComponent.isMounted) remove(existingComponent);
                await Future.delayed(Duration.zero);
                await addItemForAnimation(
                    itemModel); // Using your game's addItem override
                Component? newShapeComp = _findComponentByModelId(itemModel.id);
                if (newShapeComp is PositionComponent &&
                    itemModel.offset != null) {
                  newShapeComp.position = SizeHelper.getBoardActualVector(
                    gameScreenSize: _tacticBoard.gameField.size,
                    actualPosition: itemModel.offset!,
                  );
                }
              }());
            }
          }
        }
      }
    }

    await Future.wait(addItemFutures);
    await Future.delayed(Duration.zero);

    if (itemsDefinedInCurrentScene.isNotEmpty &&
        componentsToAnimateDetails.isNotEmpty) {
      // Use current scene's configured duration, adjusted by pace factor
      double currentSceneConfiguredDurationSeconds =
          animationItem.sceneDuration.inMilliseconds / 1000.0;
      double actualSceneMovementDurationSeconds =
          currentSceneConfiguredDurationSeconds / _scenePaceFactor;

      if (actualSceneMovementDurationSeconds <= 0.01)
        actualSceneMovementDurationSeconds = 0.01;

      for (var detail in componentsToAnimateDetails) {
        PositionComponent component = detail['component'];
        FieldItemModel itemModel = detail['itemModel'];
        Vector2 targetModelOffset = detail['targetModelOffset'];
        Vector2 currentActualPos = component.position.clone();
        Vector2 targetPositionGameCoords = SizeHelper.getBoardActualVector(
          gameScreenSize: _tacticBoard.gameField.size,
          actualPosition: targetModelOffset,
        );
        double distance = (targetPositionGameCoords - currentActualPos).length;
        double requiredSpeedForComponent =
            (distance > 0.01 && actualSceneMovementDurationSeconds > 0)
                ? (distance / actualSceneMovementDurationSeconds)
                : 0;
        _startOrUpdateManualAnimation(
          component,
          itemModel,
          targetPositionGameCoords,
          requiredSpeedForComponent,
        );
      }
    }
    _checkSceneCompletionAndProceed();
  }

  String? _getComponentModelId(Component component) {
    if (component is PlayerComponent) return component.object.id;
    if (component is EquipmentComponent) return component.object.id;
    if (component is LineDrawerComponentV2) return component.lineModelV2.id;
    if (component is SquareShapeDrawerComponent)
      return component.squareModel.id;
    if (component is CircleShapeDrawerComponent)
      return component.circleModel.id;
    if (component is PolygonShapeDrawerComponent)
      return component.polygonModel.id;
    if (component is TextFieldComponent) return component.object.id;
    return null;
  }

  FieldItemModel? _getModelFromComponent(Component component) {
    if (component is PlayerComponent) return component.object;
    if (component is EquipmentComponent) return component.object;
    if (component is LineDrawerComponentV2) return component.lineModelV2;
    if (component is SquareShapeDrawerComponent) return component.squareModel;
    if (component is CircleShapeDrawerComponent) return component.circleModel;
    if (component is PolygonShapeDrawerComponent) return component.polygonModel;
    if (component is TextFieldComponent) return component.object;
    return null;
  }

  void _checkSceneCompletionAndProceed() {
    if (_wasHardResetRecently ||
        !_isAnimationPlaying ||
        _isAnimationPaused ||
        _currentSceneDelayTimerActive) return;
    if (_activeMovingItemIdsInCurrentScene.isEmpty) {
      if (isForExportMode && animationModel.animationScenes.isNotEmpty) {
        int completedSceneCount = _currentSceneIndex;
        double progress = completedSceneCount /
            animationModel.animationScenes.length.toDouble();
        onExportProgressUpdate?.call(progress.clamp(0.0, 1.0));
      }
      _currentSceneDelayTimerActive = true;
      final int delayMilliseconds = (_baseSceneDelay.inMilliseconds);
      if (delayMilliseconds <= 0) {
        _currentSceneDelayTimerActive = false;
        Future.delayed(Duration.zero, () {
          if (_isAnimationPlaying &&
              !_isAnimationPaused &&
              !_wasHardResetRecently) _proceedToNextScene();
        });
        return;
      }
      _sceneProgressionTimer = a.Timer(
        Duration(milliseconds: delayMilliseconds),
        () {
          _currentSceneDelayTimerActive = false;
          if (_isAnimationPlaying &&
              !_isAnimationPaused &&
              !_wasHardResetRecently) _proceedToNextScene();
        },
      );
    }
  }

  void _proceedToNextScene() {
    if (_wasHardResetRecently) {
      _isAnimationPlaying = false;
      _isAnimationPaused = false;
      return;
    }
    _sceneProgressionTimer?.cancel();
    _currentSceneDelayTimerActive = false;
    if (_isAnimationPaused || !_isAnimationPlaying) return;
    if (isMounted && paused) resumeEngine();

    if (_currentSceneIndex < animationModel.animationScenes.length) {
      final AnimationItemModel sceneToProcess =
          animationModel.animationScenes[_currentSceneIndex];
      _currentSceneIndex++;
      // Report progress as we are about to process the new currentSceneIndex (which is now 1-based for display)
      if (isForExportMode && animationModel.animationScenes.isNotEmpty) {
        // Progress based on which scene *number* we are starting
        double progress = (_currentSceneIndex - 1) /
            animationModel.animationScenes.length.toDouble();
        if (_currentSceneIndex == 1 &&
            _activeMovingItemIdsInCurrentScene.isEmpty &&
            !_currentSceneDelayTimerActive) {
          // Special case for the very start of the first scene processing
          progress = 0.05; // Small initial progress
        }
        onExportProgressUpdate?.call(progress.clamp(0.0, 1.0));
      }
      _processScene(sceneToProcess);
    } else {
      _isAnimationPlaying = false;
      if (isForExportMode) {
        // Animation sequence finished
        onExportProgressUpdate?.call(1.0);
      }
    }
  }

  void setInterSceneDelayDuration(Duration newDelay) {
    _baseSceneDelay = newDelay;
  }
}
