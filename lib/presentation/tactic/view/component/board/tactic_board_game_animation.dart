import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';

// --- Helper class for Manual Velocity Animation ---
class ManualVelocityAnimation {
  final PositionComponent component;
  final FieldItemModel itemModel;
  Vector2 targetPositionInGameCoords;
  Vector2 _currentVelocity;
  bool isMoving;
  bool isPaused;
  double
      currentSpeedMagnitude; // Speed for this specific animation instance (pixels/second)

  static const double arrivalThresholdSquared = 1.0 * 1.0;

  ManualVelocityAnimation({
    required this.component,
    required this.itemModel,
    required Vector2 initialTargetPositionGameCoords,
    required double speedMagnitude,
  })  : targetPositionInGameCoords = initialTargetPositionGameCoords.clone(),
        _currentVelocity = Vector2.zero(),
        isMoving = false,
        isPaused = false,
        currentSpeedMagnitude = speedMagnitude;

  void updateSpeedMagnitude(double newSpeedMagnitude) {
    if (currentSpeedMagnitude == newSpeedMagnitude && newSpeedMagnitude >= 0)
      return;
    currentSpeedMagnitude = newSpeedMagnitude >= 0 ? newSpeedMagnitude : 0;

    if (isMoving && !isPaused) {
      _recalculateVelocity();
      if (currentSpeedMagnitude <= 0) {
        isMoving = false;
      }
    } else if (currentSpeedMagnitude <= 0) {
      isMoving = false;
      _currentVelocity = Vector2.zero();
    }
  }

  void _recalculateVelocity() {
    Vector2 direction = targetPositionInGameCoords - component.position;
    if (direction.length2 < arrivalThresholdSquared ||
        currentSpeedMagnitude <= 0) {
      isMoving = false;
      _currentVelocity = Vector2.zero();
    } else {
      direction.normalize();
      _currentVelocity = direction * currentSpeedMagnitude;
    }
  }

  void moveTo(Vector2 newTargetPositionGameCoords) {
    targetPositionInGameCoords = newTargetPositionGameCoords.clone();
    _recalculateVelocity();
    if (_currentVelocity.length2 > 0.001 &&
        (targetPositionInGameCoords - component.position).length2 >
            arrivalThresholdSquared) {
      isMoving = true;
      isPaused = false;
    } else {
      isMoving = false;
      component.position.setFrom(targetPositionInGameCoords);
    }
  }

  bool update(double dt) {
    if (!isMoving || isPaused || currentSpeedMagnitude <= 0) {
      return false;
    }
    Vector2 currentPosition = component.position;
    if (_currentVelocity.length2 < 0.0001) {
      _recalculateVelocity();
      if (!isMoving) return true;
      if (_currentVelocity.length2 < 0.0001) return false;
    }

    Vector2 movementStep = _currentVelocity * dt;
    Vector2 nextPotentialPosition = currentPosition + movementStep;
    Vector2 vectorToTarget = targetPositionInGameCoords - currentPosition;

    if (vectorToTarget.length2 <= arrivalThresholdSquared) {
      if (component.position != targetPositionInGameCoords)
        component.position.setFrom(targetPositionInGameCoords);
      isMoving = false;
      _currentVelocity = Vector2.zero();
      // zlog(data: "ManualVelocityAnimation for ${itemModel.id}: Reached target (very close) $targetPositionInGameCoords.");
      return true;
    }
    if (movementStep.length2 >= vectorToTarget.length2 &&
        vectorToTarget.length2 > 0) {
      component.position.setFrom(targetPositionInGameCoords);
      isMoving = false;
      _currentVelocity = Vector2.zero();
      // zlog(data: "ManualVelocityAnimation for ${itemModel.id}: Reached target (snapped by step) $targetPositionInGameCoords.");
      return true;
    } else {
      Vector2 vectorToTargetAfterStep =
          targetPositionInGameCoords - nextPotentialPosition;
      if (vectorToTarget.length2 > 0.001 &&
          vectorToTarget.dot(vectorToTargetAfterStep) < 0) {
        component.position.setFrom(targetPositionInGameCoords);
        isMoving = false;
        _currentVelocity = Vector2.zero();
        // zlog(data: "ManualVelocityAnimation for ${itemModel.id}: Reached target (overshot) $targetPositionInGameCoords.");
        return true;
      } else {
        component.position.setFrom(nextPotentialPosition);
      }
    }
    return false;
  }

  void pause() {
    isPaused = true;
  }

  void resume() {
    isPaused = false;
    if (isMoving) _recalculateVelocity();
  }

  void stop() {
    isMoving = false;
    isPaused = false;
    _currentVelocity = Vector2.zero();
  }
}

// --- Mixin for Animation Playback Controls ---
mixin AnimationPlaybackControls on FlameGame {
  void performStartAnimationFromBeginning();
  void performResumeAnimation();
  void performPauseAnimation();
  void performStopAnimation();
  void performSetAnimationPace(double paceFactor);
  void performHardResetAnimation();

  bool get isAnimationCurrentlyPlaying;
  bool get isAnimationCurrentlyPaused;

  void playAnimation() {
    // Minimal logging in mixin, more detailed in perform method
    if (isAnimationCurrentlyPlaying && !isAnimationCurrentlyPaused) return;
    if (isAnimationCurrentlyPaused)
      performResumeAnimation();
    else
      performStartAnimationFromBeginning();
  }

  void pauseAnimation() {
    performPauseAnimation();
  }

  void resumeAnimation() {
    performResumeAnimation();
  }

  void stopAnimation() {
    performStopAnimation();
  }

  void restartAnimation() {
    performStartAnimationFromBeginning();
  }

  void resetAnimation() {
    performHardResetAnimation();
  }

  void setAnimationPace(double paceFactor) {
    performSetAnimationPace(paceFactor);
  }
}

// class TacticBoardGameAnimation extends TacticBoardGame
//     with AnimationPlaybackControls {
//   // MODIFIED: update method with new dt capping
//   static const double VERY_LARGE_DT_THRESHOLD =
//       0.1; // 100ms (10 FPS equivalent)
//   static const double REASONABLE_TIME_STEP_AFTER_FREEZE =
//       1.0 / 30.0; // Cap to process at ~30FPS after a long freeze
//
//   @override
//   void update(double dt) {
//     double effectiveDt = dt;
//     if (dt > VERY_LARGE_DT_THRESHOLD) {
//       zlog(
//         data:
//             "TacticBoardGameAnimation: Very large dt detected: $dt. Capping to $REASONABLE_TIME_STEP_AFTER_FREEZE for this frame.",
//       );
//       effectiveDt = REASONABLE_TIME_STEP_AFTER_FREEZE;
//     }
//     // Ensure effectiveDt is positive for safety in calculations, though Flame usually provides positive dt
//     if (effectiveDt <= 0) {
//       effectiveDt = 1.0 /
//           60.0; // Fallback to a small positive value if dt is zero/negative
//     }
//
//     super.update(effectiveDt);
//
//     if (_isAnimationPlaying && !_isAnimationPaused && !this.paused) {
//       bool anAnimationCompletedThisFrame = false;
//       for (int i = _activeManualAnimations.length - 1; i >= 0; i--) {
//         final anim = _activeManualAnimations[i];
//         if (anim.update(effectiveDt)) {
//           // Pass the same effectiveDt here
//           _activeMovingItemIdsInCurrentScene.remove(anim.itemModel.id);
//           _activeManualAnimations.removeAt(i);
//           anAnimationCompletedThisFrame = true;
//         }
//       }
//       if (anAnimationCompletedThisFrame ||
//           (_activeManualAnimations.isEmpty &&
//               _activeMovingItemIdsInCurrentScene.isEmpty)) {
//         _checkSceneCompletionAndProceed();
//       }
//     }
//   }
//
//   final AnimationModel animationModel;
//   final bool autoPlay;
//
//   final bool isForExportMode;
//   final Function(double progress)? onExportProgressUpdate;
//
//   final List<FieldItemModel> _components = [];
//   late GameField gameField;
//   late Vector2 gameFieldSize;
//   late DrawingBoardComponent drawingBoard;
//
//   bool _isAnimationPlaying = false;
//   @override
//   bool get isAnimationCurrentlyPlaying => _isAnimationPlaying;
//   bool _isAnimationPaused = false;
//   @override
//   bool get isAnimationCurrentlyPaused => _isAnimationPaused;
//
//   double _scenePaceFactor = 1.0;
//   int _currentSceneIndex = 0;
//   bool _wasHardResetRecently = false;
//   a.Timer? _sceneProgressionTimer;
//   Duration _baseSceneDelay = const Duration(milliseconds: 500); // User's value
//   Duration _baseMovementDuration = const Duration(
//     seconds: 1,
//   ); // This is now per-scene via AnimationItemModel
//   final List<ManualVelocityAnimation> _activeManualAnimations = [];
//   Set<String> _activeMovingItemIdsInCurrentScene = {};
//   bool _currentSceneDelayTimerActive = false;
//
//   TacticBoardGameAnimation({
//     required this.animationModel,
//     this.autoPlay = false,
//     this.isForExportMode = false, // Default to not being in export mode
//     this.onExportProgressUpdate,
//   }) {
//     if (isForExportMode) {
//       _scenePaceFactor = 2.0; // Run faster for export (adjust as needed)
//       zlog(
//         data:
//             "TacticBoardGameAnimation: INSTANTIATED IN EXPORT MODE. Pace: $_scenePaceFactor, Scene Delay: ${_baseSceneDelay.inMilliseconds}ms",
//       );
//     }
//   }
//
//   double get currentScenePaceFactor => _scenePaceFactor;
//
//   @override
//   void performStartAnimationFromBeginning() {
//     zlog(data: "TacticBoardGameAnimation: performStartAnimationFromBeginning.");
//     if (_wasHardResetRecently) {
//       _wasHardResetRecently = false;
//     }
//     if (this.paused) this.resumeEngine();
//     _isAnimationPlaying = true;
//     _isAnimationPaused = false;
//     _currentSceneIndex = 0;
//     _clearAllManualAnimations();
//     _activeMovingItemIdsInCurrentScene.clear();
//     _currentSceneDelayTimerActive = false;
//     _sceneProgressionTimer?.cancel();
//     _proceedToNextScene();
//   }
//
//   @override
//   Future<void> performResumeAnimation() async {
//     if (!_isAnimationPlaying || !_isAnimationPaused) return;
//     _isAnimationPaused = false;
//     if (isMounted && this.paused) {
//       this.resumeEngine();
//       await Future.delayed(Duration.zero);
//     }
//     for (final anim in _activeManualAnimations) anim.resume();
//     _checkSceneCompletionAndProceed();
//   }
//
//   @override
//   void performPauseAnimation() {
//     if (!_isAnimationPlaying || _isAnimationPaused) {
//       if (_isAnimationPlaying &&
//           _isAnimationPaused &&
//           isMounted &&
//           !this.paused) this.pauseEngine();
//       _isAnimationPaused = true;
//       _sceneProgressionTimer?.cancel();
//       _currentSceneDelayTimerActive = false;
//       return;
//     }
//     _isAnimationPaused = true;
//     _sceneProgressionTimer?.cancel();
//     _currentSceneDelayTimerActive = false;
//     for (final anim in _activeManualAnimations) anim.pause();
//     if (isMounted && !paused) pauseEngine();
//   }
//
//   @override
//   void performStopAnimation() {
//     if (paused) resumeEngine();
//     _isAnimationPlaying = false;
//     _isAnimationPaused = false;
//     _sceneProgressionTimer?.cancel();
//     _currentSceneDelayTimerActive = false;
//     _clearAllManualAnimations();
//     _activeMovingItemIdsInCurrentScene.clear();
//     _currentSceneIndex = 0;
//     zlog(data: "TacticBoardGameAnimation: Animation System Stopped.");
//   }
//
//   @override
//   void performSetAnimationPace(double newPaceFactor) {
//     if (newPaceFactor <= 0.0) return;
//     final oldPaceFactor = _scenePaceFactor;
//     _scenePaceFactor = newPaceFactor;
//     zlog(
//       data:
//           "TacticBoardGameAnimation: Global pace factor changed from $oldPaceFactor to $newPaceFactor.",
//     );
//     if (oldPaceFactor > 0 &&
//         oldPaceFactor != newPaceFactor &&
//         _isAnimationPlaying &&
//         !_isAnimationPaused) {
//       double paceScaleFactor = newPaceFactor / oldPaceFactor;
//       for (final anim in _activeManualAnimations) {
//         double newIndividualSpeed =
//             anim.currentSpeedMagnitude * paceScaleFactor;
//         anim.updateSpeedMagnitude(newIndividualSpeed);
//       }
//     }
//   }
//
//   @override
//   void performHardResetAnimation() {
//     performStopAnimation();
//     final List<Component> componentsToRemove = children
//         .where(
//           (child) =>
//               child is PlayerComponent ||
//               child is EquipmentComponent ||
//               child is LineDrawerComponentV2 ||
//               child is SquareShapeDrawerComponent ||
//               child is CircleShapeDrawerComponent ||
//               child is PolygonShapeDrawerComponent,
//         )
//         .toList();
//     if (componentsToRemove.isNotEmpty) removeAll(componentsToRemove);
//     _components.clear();
//     if (isLoaded && children.contains(drawingBoard)) {
//       drawingBoard.loadLines([], suppressNotification: true);
//     }
//     _wasHardResetRecently = true;
//     _isAnimationPlaying = false;
//     _isAnimationPaused = false;
//     _setupInitialSceneStatically();
//   }
//
//   @override
//   a.FutureOr<void> onLoad() {
//     zlog(data: "TacticBoardGameAnimation: onLoad started. autoPlay: $autoPlay");
//     _initiateField().then((_) {
//       zlog(data: "TacticBoardGameAnimation: Field initiated.");
//       if (animationModel.animationScenes.isEmpty) {
//         _isAnimationPlaying = false;
//         return;
//       }
//       if (this.autoPlay) {
//         performStartAnimationFromBeginning();
//       } else {
//         _setupInitialSceneStatically();
//         _isAnimationPlaying = false;
//         _isAnimationPaused = false;
//         _currentSceneIndex = 0;
//         _wasHardResetRecently = false;
//       }
//       zlog(
//         data:
//             "TacticBoardGameAnimation: onLoad finished. Animation playing: $_isAnimationPlaying",
//       );
//     });
//     return super.onLoad();
//   }
//
//   Future<void> _initiateField() async {
//     gameField = GameField(
//       size: Vector2(size.x - 20, size.y - 20),
//       initialColor: animationModel.fieldColor,
//     );
//     gameFieldSize = gameField.size;
//     await add(gameField);
//     drawingBoard = DrawingBoardComponent(
//       position: gameField.position,
//       size: gameField.size,
//     );
//     await add(drawingBoard);
//   }
//
//   @override
//   Color backgroundColor() {
//     return (ColorManager.white).withAlpha(128);
//   }
//
//   @override
//   addItem(FieldItemModel item, {bool save = true}) async {
//     if (item is PlayerModel) {
//       add(PlayerComponent(object: item)); // add() is available via FlameGame
//     } else if (item is EquipmentModel) {
//       add(EquipmentComponent(object: item)); // add() is available via FlameGame
//     } else if (item is LineModelV2) {
//       await add(LineDrawerComponentV2(lineModelV2: item));
//     } else if (item is CircleShapeModel) {
//       await add(CircleShapeDrawerComponent(circleModel: item));
//     } else if (item is SquareShapeModel) {
//       await add(SquareShapeDrawerComponent(squareModel: item));
//     } else if (item is PolygonShapeModel) {
//       await add(PolygonShapeDrawerComponent(polygonModel: item));
//     }
//   }
//
//   void _clearAllManualAnimations() {
//     for (var anim in _activeManualAnimations) anim.stop();
//     _activeManualAnimations.clear();
//   }
//
//   Component? _findComponentByModelId(String modelId) {
//     return children.firstWhereOrNull((c) {
//       if (c is PlayerComponent) return c.object.id == modelId;
//       if (c is EquipmentComponent) return c.object.id == modelId;
//       if (c is LineDrawerComponentV2) return c.lineModelV2.id == modelId;
//       if (c is SquareShapeDrawerComponent) return c.squareModel.id == modelId;
//       if (c is CircleShapeDrawerComponent) return c.circleModel.id == modelId;
//       if (c is PolygonShapeDrawerComponent) return c.polygonModel.id == modelId;
//       return false;
//     });
//   }
//
//   void _startOrUpdateManualAnimation(
//     PositionComponent component,
//     FieldItemModel itemModel,
//     Vector2 targetPositionInGameCoords,
//     double calculatedSpeedMagnitude,
//   ) {
//     var existingAnim = _activeManualAnimations.firstWhereOrNull(
//       (a) => a.component == component,
//     );
//     bool alreadyAtTarget =
//         (component.position - targetPositionInGameCoords).length2 <
//             ManualVelocityAnimation.arrivalThresholdSquared;
//     if (alreadyAtTarget ||
//         (calculatedSpeedMagnitude < 0.01 && !alreadyAtTarget)) {
//       component.position.setFrom(targetPositionInGameCoords);
//       if (existingAnim != null) {
//         existingAnim.stop();
//         _activeManualAnimations.remove(existingAnim);
//       }
//       _activeMovingItemIdsInCurrentScene.remove(itemModel.id);
//       return;
//     }
//     if (existingAnim != null) {
//       existingAnim.updateSpeedMagnitude(calculatedSpeedMagnitude);
//       existingAnim.moveTo(targetPositionInGameCoords);
//     } else {
//       existingAnim = ManualVelocityAnimation(
//         component: component,
//         itemModel: itemModel,
//         initialTargetPositionGameCoords: targetPositionInGameCoords,
//         speedMagnitude: calculatedSpeedMagnitude,
//       );
//       _activeManualAnimations.add(existingAnim);
//       existingAnim.moveTo(targetPositionInGameCoords);
//     }
//     if (existingAnim.isMoving)
//       _activeMovingItemIdsInCurrentScene.add(itemModel.id);
//     else
//       _activeMovingItemIdsInCurrentScene.remove(itemModel.id);
//   }
//
//   Future<void> _setupInitialSceneStatically() async {
//     if (animationModel.animationScenes.isEmpty) return;
//     _currentSceneIndex = 0;
//     AnimationItemModel firstScene = animationModel.animationScenes[0];
//     _activeMovingItemIdsInCurrentScene.clear();
//     _currentSceneDelayTimerActive = false;
//     _sceneProgressionTimer?.cancel();
//     _clearAllManualAnimations();
//     final List<Component> componentsToRemove = children
//         .where(
//           (child) => !(child is GameField || child is DrawingBoardComponent),
//         )
//         .toList();
//     if (componentsToRemove.isNotEmpty) removeAll(componentsToRemove);
//     _components.clear();
//     List<FreeDrawModelV2> freeLines =
//         firstScene.components.whereType<FreeDrawModelV2>().toList();
//     List<FreeDrawModelV2> processedFreeLines = freeLines.map((e) {
//       var cloned = e.clone();
//       cloned.points = cloned.points
//           .map(
//             (p) => SizeHelper.getBoardActualVector(
//               gameScreenSize: gameFieldSize,
//               actualPosition: p,
//             ),
//           )
//           .toList();
//       return cloned;
//     }).toList();
//     drawingBoard.loadLines(processedFreeLines, suppressNotification: true);
//     List<Future<void>> addItemFutures = [];
//     for (var itemModel in firstScene.components) {
//       if (itemModel is FreeDrawModelV2) continue;
//       addItemFutures.add(
//         addItem(itemModel).then((_) async {
//           // Using your game's addItem override
//           await Future.delayed(Duration.zero);
//           Component? comp = _findComponentByModelId(itemModel.id);
//           if (comp is PositionComponent && itemModel.offset != null) {
//             comp.position = SizeHelper.getBoardActualVector(
//               gameScreenSize: gameFieldSize,
//               actualPosition: itemModel.offset!,
//             );
//           }
//         }),
//       );
//     }
//     await Future.wait(addItemFutures);
//     await Future.delayed(Duration.zero);
//     zlog(
//       data: "TacticBoardGameAnimation: Initial scene 0 static setup complete.",
//     );
//   }
//
//   Future<void> _processScene(AnimationItemModel animationItem) async {
//     if (_wasHardResetRecently || (this.paused && _isAnimationPaused)) return;
//     if (!_isAnimationPlaying || _isAnimationPaused) return;
//
//     zlog(
//       data:
//           "TacticBoardGameAnimation: _processScene START for scene index: ${_currentSceneIndex - 1}. Pace: $_scenePaceFactor",
//     );
//
//     List<FieldItemModel> itemsDefinedInCurrentScene = animationItem.components;
//     Set<String> idsInCurrentScene =
//         itemsDefinedInCurrentScene.map((e) => e.id).toSet();
//
//     _activeMovingItemIdsInCurrentScene.clear();
//     _currentSceneDelayTimerActive = false;
//     _sceneProgressionTimer?.cancel();
//
//     // --- 1. Remove Stale Components ---
//     List<Component> flameComponentsToRemove = [];
//     for (var component in List.from(children)) {
//       if (component is GameField || component is DrawingBoardComponent)
//         continue;
//       String? componentModelId = _getComponentModelId(component);
//       if (componentModelId != null &&
//           !idsInCurrentScene.contains(componentModelId)) {
//         flameComponentsToRemove.add(component);
//       }
//     }
//     if (flameComponentsToRemove.isNotEmpty) {
//       for (var compToRemove in flameComponentsToRemove) {
//         _activeManualAnimations.removeWhere(
//           (anim) => anim.component == compToRemove,
//         );
//         String? idToRemove = _getComponentModelId(compToRemove);
//         if (idToRemove != null)
//           _components.removeWhere((m) => m.id == idToRemove);
//         remove(compToRemove);
//       }
//       await Future.delayed(Duration.zero);
//     }
//
//     // --- 2. Process FreeDraw lines for the current scene ---
//     List<FreeDrawModelV2> freeLinesInCurrentScene =
//         itemsDefinedInCurrentScene.whereType<FreeDrawModelV2>().toList();
//     List<FreeDrawModelV2> processedFreeLines = freeLinesInCurrentScene.map((e) {
//       var cloned = e.clone();
//       cloned.points = cloned.points
//           .map(
//             (p) => SizeHelper.getBoardActualVector(
//               gameScreenSize: gameFieldSize,
//               actualPosition: p,
//             ),
//           )
//           .toList();
//       return cloned;
//     }).toList();
//     drawingBoard.loadLines(processedFreeLines, suppressNotification: true);
//
//     // --- 3. Add or Update other components ---
//     List<Future<void>> addItemFutures = [];
//     List<Map<String, dynamic>> componentsToAnimateDetails = [];
//
//     for (var itemModel in itemsDefinedInCurrentScene) {
//       if (itemModel is FreeDrawModelV2) continue;
//       if (!_isAnimationPlaying) break;
//       Component? existingComponent = _findComponentByModelId(itemModel.id);
//
//       if (existingComponent == null) {
//         addItemFutures.add(
//           addItem(itemModel).then((_) async {
//             // Using your game's addItem override
//             await Future.delayed(Duration.zero);
//             Component? newComp = _findComponentByModelId(itemModel.id);
//             if (newComp is PositionComponent) {
//               Vector2 initialPos = itemModel.offset != null
//                   ? SizeHelper.getBoardActualVector(
//                       gameScreenSize: gameFieldSize,
//                       actualPosition: itemModel.offset!,
//                     )
//                   : newComp.position;
//               newComp.position = initialPos;
//               if ((newComp is PlayerComponent ||
//                       newComp is EquipmentComponent) &&
//                   itemModel.offset != null) {
//                 componentsToAnimateDetails.add({
//                   'component': newComp,
//                   'itemModel': itemModel,
//                   'targetModelOffset': itemModel.offset!,
//                 });
//               }
//             }
//           }),
//         );
//       } else {
//         if (existingComponent is PositionComponent) {
//           bool isPlayerOrEquipment = existingComponent is PlayerComponent ||
//               existingComponent is EquipmentComponent;
//           if (isPlayerOrEquipment && existingComponent is FieldComponent) {
//             (existingComponent).object = itemModel;
//             if (itemModel.offset != null) {
//               Vector2 targetPos = SizeHelper.getBoardActualVector(
//                 gameScreenSize: gameFieldSize,
//                 actualPosition: itemModel.offset!,
//               );
//               if ((existingComponent.position - targetPos).length2 >
//                   ManualVelocityAnimation.arrivalThresholdSquared) {
//                 componentsToAnimateDetails.add({
//                   'component': existingComponent,
//                   'itemModel': itemModel,
//                   'targetModelOffset': itemModel.offset!,
//                 });
//               } else {
//                 existingComponent.position.setFrom(targetPos);
//                 _activeManualAnimations.removeWhere(
//                   (anim) => anim.component == existingComponent,
//                 );
//               }
//             } else {
//               _activeManualAnimations.removeWhere(
//                 (anim) => anim.component == existingComponent,
//               );
//             }
//           } else {
//             FieldItemModel? currentComponentModelInComponent =
//                 _getModelFromComponent(existingComponent);
//             // IMPORTANT: Ensure your FieldItemModel subclasses (LineModelV2, SquareShapeModel, etc.)
//             // correctly override operator == and hashCode for this comparison to work as intended.
//             if (currentComponentModelInComponent != null &&
//                 itemModel == currentComponentModelInComponent) {
//               zlog(
//                 data:
//                     "TacticBoardGameAnimation: Shape/Line ${itemModel.id} is UNCHANGED, leaving as is.",
//               );
//               if (itemModel.offset != null) {
//                 // Ensure static position is up-to-date
//                 existingComponent.position = SizeHelper.getBoardActualVector(
//                   gameScreenSize: gameFieldSize,
//                   actualPosition: itemModel.offset!,
//                 );
//               }
//             } else {
//               zlog(
//                 data:
//                     "TacticBoardGameAnimation: Shape/Line ${itemModel.id} HAS CHANGED or cannot compare. Re-adding.",
//               );
//               _activeManualAnimations.removeWhere(
//                 (anim) => anim.component == existingComponent,
//               );
//               addItemFutures.add(() async {
//                 if (existingComponent.isMounted) remove(existingComponent);
//                 await Future.delayed(Duration.zero);
//                 await addItem(itemModel); // Using your game's addItem override
//                 Component? newShapeComp = _findComponentByModelId(itemModel.id);
//                 if (newShapeComp is PositionComponent &&
//                     itemModel.offset != null) {
//                   newShapeComp.position = SizeHelper.getBoardActualVector(
//                     gameScreenSize: gameFieldSize,
//                     actualPosition: itemModel.offset!,
//                   );
//                 }
//               }());
//             }
//           }
//         }
//       }
//     }
//
//     await Future.wait(addItemFutures);
//     await Future.delayed(Duration.zero);
//
//     if (itemsDefinedInCurrentScene.isNotEmpty &&
//         componentsToAnimateDetails.isNotEmpty) {
//       // Use current scene's configured duration, adjusted by pace factor
//       double currentSceneConfiguredDurationSeconds =
//           animationItem.sceneDuration.inMilliseconds / 1000.0;
//       double actualSceneMovementDurationSeconds =
//           currentSceneConfiguredDurationSeconds / _scenePaceFactor;
//
//       if (actualSceneMovementDurationSeconds <= 0.01)
//         actualSceneMovementDurationSeconds = 0.01;
//
//       for (var detail in componentsToAnimateDetails) {
//         PositionComponent component = detail['component'];
//         FieldItemModel itemModel = detail['itemModel'];
//         Vector2 targetModelOffset = detail['targetModelOffset'];
//         Vector2 currentActualPos = component.position.clone();
//         Vector2 targetPositionGameCoords = SizeHelper.getBoardActualVector(
//           gameScreenSize: gameFieldSize,
//           actualPosition: targetModelOffset,
//         );
//         double distance = (targetPositionGameCoords - currentActualPos).length;
//         double requiredSpeedForComponent =
//             (distance > 0.01 && actualSceneMovementDurationSeconds > 0)
//                 ? (distance / actualSceneMovementDurationSeconds)
//                 : 0;
//         _startOrUpdateManualAnimation(
//           component,
//           itemModel,
//           targetPositionGameCoords,
//           requiredSpeedForComponent,
//         );
//       }
//     }
//     _checkSceneCompletionAndProceed();
//   }
//
//   String? _getComponentModelId(Component component) {
//     if (component is PlayerComponent) return component.object.id;
//     if (component is EquipmentComponent) return component.object.id;
//     if (component is LineDrawerComponentV2) return component.lineModelV2.id;
//     if (component is SquareShapeDrawerComponent)
//       return component.squareModel.id;
//     if (component is CircleShapeDrawerComponent)
//       return component.circleModel.id;
//     if (component is PolygonShapeDrawerComponent)
//       return component.polygonModel.id;
//     return null;
//   }
//
//   FieldItemModel? _getModelFromComponent(Component component) {
//     if (component is PlayerComponent) return component.object;
//     if (component is EquipmentComponent) return component.object;
//     if (component is LineDrawerComponentV2) return component.lineModelV2;
//     if (component is SquareShapeDrawerComponent) return component.squareModel;
//     if (component is CircleShapeDrawerComponent) return component.circleModel;
//     if (component is PolygonShapeDrawerComponent) return component.polygonModel;
//     return null;
//   }
//
//   void _checkSceneCompletionAndProceed() {
//     if (_wasHardResetRecently ||
//         !_isAnimationPlaying ||
//         _isAnimationPaused ||
//         _currentSceneDelayTimerActive) return;
//     if (_activeMovingItemIdsInCurrentScene.isEmpty) {
//       if (isForExportMode && animationModel.animationScenes.isNotEmpty) {
//         int completedSceneCount = _currentSceneIndex;
//         double progress = completedSceneCount /
//             animationModel.animationScenes.length.toDouble();
//         onExportProgressUpdate?.call(progress.clamp(0.0, 1.0));
//       }
//       _currentSceneDelayTimerActive = true;
//       final int delayMilliseconds = (_baseSceneDelay.inMilliseconds);
//       if (delayMilliseconds <= 0) {
//         _currentSceneDelayTimerActive = false;
//         Future.delayed(Duration.zero, () {
//           if (_isAnimationPlaying &&
//               !_isAnimationPaused &&
//               !_wasHardResetRecently) _proceedToNextScene();
//         });
//         return;
//       }
//       _sceneProgressionTimer = a.Timer(
//         Duration(milliseconds: delayMilliseconds),
//         () {
//           _currentSceneDelayTimerActive = false;
//           if (_isAnimationPlaying &&
//               !_isAnimationPaused &&
//               !_wasHardResetRecently) _proceedToNextScene();
//         },
//       );
//     }
//   }
//
//   void _proceedToNextScene() {
//     if (_wasHardResetRecently) {
//       _isAnimationPlaying = false;
//       _isAnimationPaused = false;
//       return;
//     }
//     _sceneProgressionTimer?.cancel();
//     _currentSceneDelayTimerActive = false;
//     if (_isAnimationPaused || !_isAnimationPlaying) return;
//     if (isMounted && this.paused) this.resumeEngine();
//
//     if (_currentSceneIndex < animationModel.animationScenes.length) {
//       final AnimationItemModel sceneToProcess =
//           animationModel.animationScenes[_currentSceneIndex];
//       _currentSceneIndex++;
//       // Report progress as we are about to process the new currentSceneIndex (which is now 1-based for display)
//       if (isForExportMode && animationModel.animationScenes.isNotEmpty) {
//         // Progress based on which scene *number* we are starting
//         double progress = (_currentSceneIndex - 1) /
//             animationModel.animationScenes.length.toDouble();
//         if (_currentSceneIndex == 1 &&
//             _activeMovingItemIdsInCurrentScene.isEmpty &&
//             !_currentSceneDelayTimerActive) {
//           // Special case for the very start of the first scene processing
//           progress = 0.05; // Small initial progress
//         }
//         onExportProgressUpdate?.call(progress.clamp(0.0, 1.0));
//       }
//       _processScene(sceneToProcess);
//     } else {
//       _isAnimationPlaying = false;
//       if (isForExportMode) {
//         // Animation sequence finished
//         onExportProgressUpdate?.call(1.0);
//       }
//     }
//   }
//
//   void setInterSceneDelayDuration(Duration newDelay) {
//     _baseSceneDelay = newDelay;
//   }
//
//   // Removed setBaseMovementDuration as it's per scene now
// }
