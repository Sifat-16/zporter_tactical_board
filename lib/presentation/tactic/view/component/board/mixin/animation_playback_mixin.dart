//
// import 'dart:async' as a;
// import 'dart:math';
// import 'package:flame/components.dart';
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/extensions/data_structure_extensions.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/circle_shape_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/polygon_shape_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/square_shape_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/text_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/game_field.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/ball_trail_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/text_field_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/circle_shape_plugin.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/drawing_board_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/line_plugin.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/polygon_shape_plugin.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_plugins/square_shape_plugin.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/player/player_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
//
// class AnimatingObj {
//   final bool isAnimating;
//   final bool isExporting;
//   AnimatingObj({required this.isAnimating, required this.isExporting});
//   factory AnimatingObj.animate() {
//     return AnimatingObj(isAnimating: true, isExporting: false);
//   }
//   factory AnimatingObj.export() {
//     return AnimatingObj(isAnimating: false, isExporting: true);
//   }
// }
//
// abstract class ComponentAnimation {
//   final PositionComponent component;
//   final FieldItemModel itemModel;
//   bool get isMoving;
//   ComponentAnimation({required this.component, required this.itemModel});
//   bool update(double dt);
//   void stop();
//   void pause();
//   void resume();
// }
//
// class ArcingAnimation extends ComponentAnimation {
//   final Vector2 startPosition;
//   final Vector2 targetPosition;
//   final double duration;
//   double _elapsedTime = 0;
//   bool _isPaused = false;
//
//   // MODIFIED: Made 'late final' to allow initialization in the constructor body
//   late final double arcHeight;
//
//   final double sizeMultiplier;
//   final Vector2 originalSize;
//   static const double AIR_ROTATION_SPEED_RADS_PER_SEC = 0.5;
//
//   final BallSpin spin;
//   final TacticBoardGame game;
//   BallTrailComponent? _trailComponent;
//
//   @override
//   bool get isMoving => _elapsedTime < duration && !_isPaused;
//
//   ArcingAnimation({
//     required super.component,
//     required super.itemModel,
//     required this.targetPosition,
//     required this.duration,
//     required this.game,
//     this.sizeMultiplier = 1.3,
//   })  : startPosition = component.position.clone(),
//         originalSize = component.size.clone(),
//         spin = (itemModel as EquipmentModel).spin ?? BallSpin.none {
//     // REMOVED: arcHeight calculation was moved from the initializer list.
//
//     // NEW: Calculate arcHeight here, after startPosition has been initialized.
//     final distance = startPosition.distanceTo(targetPosition);
//     arcHeight = (distance * 0.2).clamp(20.0, 120.0);
//
//     if (component is EquipmentComponent) {
//       _trailComponent =
//           BallTrailComponent(ball: component as EquipmentComponent);
//       game.add(_trailComponent!);
//     }
//   }
//
//   @override
//   bool update(double dt) {
//     if (_isPaused || duration <= 0) return false;
//     _elapsedTime += dt;
//     double progress = (_elapsedTime / duration).clamp(0.0, 1.0);
//
//     Vector2 groundPosition;
//     switch (spin) {
//       case BallSpin.left:
//       case BallSpin.right:
//         final diff = targetPosition - startPosition;
//         final midPoint = startPosition + diff * 0.5;
//         final perpendicular = Vector2(diff.y, -diff.x).normalized();
//         final curveAmount = diff.length * 0.2;
//
//         final controlPoint = midPoint +
//             (perpendicular *
//                 (spin == BallSpin.left ? -curveAmount : curveAmount));
//
//         final t = progress;
//         final oneMinusT = 1 - t;
//         groundPosition = (startPosition * (oneMinusT * oneMinusT)) +
//             (controlPoint * (2 * oneMinusT * t)) +
//             (targetPosition * (t * t));
//         break;
//
//       case BallSpin.knuckleball:
//         final linearPosition = startPosition.clone()
//           ..lerp(targetPosition, progress);
//         final diff = targetPosition - startPosition;
//         final perpendicular = Vector2(diff.y, -diff.x).normalized();
//         final wobble = sin(progress * pi * 8) * (originalSize.x * 0.25);
//         groundPosition = linearPosition + (perpendicular * wobble);
//         break;
//
//       case BallSpin.none:
//       default:
//         groundPosition = startPosition.clone()..lerp(targetPosition, progress);
//         break;
//     }
//     component.position = groundPosition;
//
//     double arcFactor = sin(progress * pi);
//     double currentAltitude = arcHeight * arcFactor;
//     double currentSize =
//         originalSize.x * (1 + (sizeMultiplier - 1) * arcFactor);
//
//     if (component is EquipmentComponent) {
//       (component as EquipmentComponent).altitude = currentAltitude;
//       (component as EquipmentComponent).visualSize = Vector2.all(currentSize);
//     }
//
//     component.angle += AIR_ROTATION_SPEED_RADS_PER_SEC * dt;
//
//     if (_elapsedTime >= duration) {
//       stop();
//       return true;
//     }
//     return false;
//   }
//
//   @override
//   void stop() {
//     _trailComponent?.removeFromParent();
//     _trailComponent = null;
//
//     _elapsedTime = duration;
//     component.position.setFrom(targetPosition);
//     if (component is EquipmentComponent) {
//       (component as EquipmentComponent).altitude = 0;
//       (component as EquipmentComponent).visualSize = originalSize;
//     }
//   }
//
//   @override
//   void pause() => _isPaused = true;
//   @override
//   void resume() => _isPaused = false;
// }
//
// class ManualVelocityAnimation extends ComponentAnimation {
//   static const double arrivalThresholdSquared = 1.0;
//   Vector2 _targetPosition;
//   double _speedMagnitude;
//   Vector2 _velocity;
//   bool _isPaused = false;
//   ManualVelocityAnimation({
//     required super.component,
//     required super.itemModel,
//     required Vector2 initialTargetPositionGameCoords,
//     required double speedMagnitude,
//   })  : _targetPosition = initialTargetPositionGameCoords,
//         _speedMagnitude = speedMagnitude,
//         _velocity = Vector2.zero() {
//     _recalculateVelocity();
//   }
//   @override
//   bool get isMoving => _velocity.length2 > 0 && !_isPaused;
//   void _recalculateVelocity() {
//     final direction = (_targetPosition - component.position);
//     if (direction.length2 > arrivalThresholdSquared) {
//       _velocity = direction.normalized() * _speedMagnitude;
//     } else {
//       _velocity = Vector2.zero();
//     }
//   }
//
//   @override
//   bool update(double dt) {
//     if (!isMoving) return true;
//     final displacement = _velocity * dt;
//     if ((_targetPosition - component.position).length2 < displacement.length2) {
//       component.position.setFrom(_targetPosition);
//       _velocity = Vector2.zero();
//       return true;
//     } else {
//       component.position += displacement;
//     }
//     return false;
//   }
//
//   void moveTo(Vector2 newTargetPosition) {
//     _targetPosition = newTargetPosition;
//     _recalculateVelocity();
//   }
//
//   void updateSpeedMagnitude(double newSpeed) {
//     _speedMagnitude = newSpeed;
//     _recalculateVelocity();
//   }
//
//   @override
//   void stop() {
//     _velocity = Vector2.zero();
//     component.position.setFrom(_targetPosition);
//   }
//
//   @override
//   void pause() => _isPaused = true;
//   @override
//   void resume() => _isPaused = false;
// }
//
// mixin AnimationPlaybackMixin on TacticBoardGame {
//   late TacticBoard _tacticBoard;
//   static const double VERY_LARGE_DT_THRESHOLD = 0.1;
//   static const double REASONABLE_TIME_STEP_AFTER_FREEZE = 1.0 / 30.0;
//   static const double BASE_BALL_ROTATION_SPEED_RADS_PER_SEC = 2 * 3.14159;
//   late AnimationModel animationModel;
//   late bool autoPlay;
//   late bool isForExportMode;
//   late Function(double progress)? onExportProgressUpdate;
//   List<FieldItemModel> _components = [];
//   bool _isAnimationPlaying = false;
//   @override
//   bool get isAnimationCurrentlyPlaying => _isAnimationPlaying;
//   bool _isAnimationPaused = false;
//   @override
//   bool get isAnimationCurrentlyPaused => _isAnimationPaused;
//   double _scenePaceFactor = 1.0;
//   int _currentSceneIndex = 0;
//   bool _wasHardResetRecently = false;
//   a.Timer? _sceneProgressionTimer;
//   Duration _baseSceneDelay = const Duration(milliseconds: 500);
//   final List<ComponentAnimation> _activeAnimations = [];
//   Set<String> _activeMovingItemIdsInCurrentScene = {};
//   bool _currentSceneDelayTimerActive = false;
//
//   void startAnimation({
//     required AnimationModel am,
//     bool ap = false,
//     bool isForE = false,
//     Function(double progress)? onExportP,
//   }) {
//     WidgetsBinding.instance.addPostFrameCallback((t) {
//       animationModel = am;
//       autoPlay = ap;
//       isForExportMode = isForE;
//       onExportProgressUpdate = onExportP;
//       if (isForExportMode) {
//         _scenePaceFactor = 2.0;
//       }
//
//       _tacticBoard = (this as TacticBoard);
//       _tacticBoard.isAnimating = false;
//       _tacticBoard.removeAll(children.whereType<FieldComponent>());
//       if (animationModel.animationScenes.isEmpty) {
//         _isAnimationPlaying = false;
//         return;
//       }
//       if (autoPlay) {
//         _setupInitialSceneStatically();
//         performStartAnimationFromBeginning();
//       } else {
//         _setupInitialSceneStatically();
//         _isAnimationPlaying = false;
//         _isAnimationPaused = false;
//         _currentSceneIndex = 0;
//         _wasHardResetRecently = false;
//       }
//     });
//   }
//
//   @override
//   void update(double dt) {
//     double effectiveDt = dt;
//     if (dt > VERY_LARGE_DT_THRESHOLD) {
//       effectiveDt = REASONABLE_TIME_STEP_AFTER_FREEZE;
//     }
//     if (effectiveDt <= 0) {
//       effectiveDt = 1.0 / 60.0;
//     }
//
//     super.update(effectiveDt);
//
//     if (_isAnimationPlaying && !_isAnimationPaused && !this.paused) {
//       bool anAnimationCompletedThisFrame = false;
//
//       for (int i = _activeAnimations.length - 1; i >= 0; i--) {
//         final anim = _activeAnimations[i];
//
//         if (anim.component is EquipmentComponent) {
//           final equipmentComponent = anim.component as EquipmentComponent;
//           final equipmentModel = equipmentComponent.object;
//
//           if (equipmentModel.name == "BALL" &&
//               anim.isMoving &&
//               !equipmentModel.isAerialArrival) {
//             double rotationThisFrame = BASE_BALL_ROTATION_SPEED_RADS_PER_SEC *
//                 effectiveDt *
//                 _scenePaceFactor;
//             equipmentComponent.angle -= rotationThisFrame;
//           }
//         }
//
//         if (anim.update(effectiveDt)) {
//           _activeMovingItemIdsInCurrentScene.remove(anim.itemModel.id);
//           _activeAnimations.removeAt(i);
//           anAnimationCompletedThisFrame = true;
//         }
//       }
//       if (anAnimationCompletedThisFrame ||
//           (_activeAnimations.isEmpty &&
//               _activeMovingItemIdsInCurrentScene.isEmpty)) {
//         _checkSceneCompletionAndProceed();
//       }
//     }
//   }
//
//   double get currentScenePaceFactor => _scenePaceFactor;
//
//   @override
//   void performStartAnimationFromBeginning() {
//     if (_wasHardResetRecently) {
//       _wasHardResetRecently = false;
//     }
//     if (paused) resumeEngine();
//     _isAnimationPlaying = true;
//     _isAnimationPaused = false;
//     _currentSceneIndex = 0;
//     _clearAllAnimations();
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
//     for (final anim in _activeAnimations) anim.resume();
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
//     for (final anim in _activeAnimations) anim.pause();
//     if (isMounted && !paused) pauseEngine();
//   }
//
//   @override
//   void performStopAnimation({bool hardReset = false}) {
//     if (paused) resumeEngine();
//     _isAnimationPlaying = false;
//     _isAnimationPaused = false;
//     _sceneProgressionTimer?.cancel();
//     _currentSceneDelayTimerActive = false;
//     _clearAllAnimations();
//     _activeMovingItemIdsInCurrentScene.clear();
//     _currentSceneIndex = 0;
//     _scenePaceFactor = 1;
//     if (hardReset) {
//     } else {
//       WidgetsBinding.instance.addPostFrameCallback((t) {
//         _tacticBoard.removeAll(children.whereType<FieldComponent>());
//         ref.read(boardProvider.notifier).toggleAnimating(animatingObj: null);
//         _tacticBoard.addInitialItems(_tacticBoard.scene?.components ?? []);
//         _tacticBoard.isAnimating = false;
//       });
//     }
//   }
//
//   @override
//   void performSetAnimationPace(double newPaceFactor) {
//     if (newPaceFactor <= 0.0) return;
//     final oldPaceFactor = _scenePaceFactor;
//     _scenePaceFactor = newPaceFactor;
//     if (oldPaceFactor > 0 &&
//         oldPaceFactor != newPaceFactor &&
//         _isAnimationPlaying &&
//         !_isAnimationPaused) {
//       double paceScaleFactor = newPaceFactor / oldPaceFactor;
//       for (final anim in _activeAnimations) {
//         if (anim is ManualVelocityAnimation) {
//           double newIndividualSpeed = anim._speedMagnitude * paceScaleFactor;
//           anim.updateSpeedMagnitude(newIndividualSpeed);
//         }
//       }
//     }
//   }
//
//   @override
//   void performHardResetAnimation() {
//     performStopAnimation(hardReset: true);
//     final List<Component> componentsToRemove = children
//         .where(
//           (child) =>
//               child is PlayerComponent ||
//               child is EquipmentComponent ||
//               child is LineDrawerComponentV2 ||
//               child is SquareShapeDrawerComponent ||
//               child is CircleShapeDrawerComponent ||
//               child is PolygonShapeDrawerComponent ||
//               child is TextFieldComponent,
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
//   Color backgroundColor() {
//     return (ColorManager.white).withAlpha(128);
//   }
//
//   addItemForAnimation(FieldItemModel item, {bool save = true}) async {
//     if (item is PlayerModel) {
//       add(PlayerComponent(object: item));
//     } else if (item is EquipmentModel) {
//       add(EquipmentComponent(object: item));
//     } else if (item is LineModelV2) {
//       await add(LineDrawerComponentV2(lineModelV2: item));
//     } else if (item is CircleShapeModel) {
//       await add(CircleShapeDrawerComponent(circleModel: item));
//     } else if (item is SquareShapeModel) {
//       await add(SquareShapeDrawerComponent(squareModel: item));
//     } else if (item is PolygonShapeModel) {
//       await add(PolygonShapeDrawerComponent(polygonModel: item));
//     } else if (item is TextModel) {
//       await add(TextFieldComponent(object: item));
//     }
//   }
//
//   void _clearAllAnimations() {
//     for (var anim in _activeAnimations) anim.stop();
//     _activeAnimations.clear();
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
//       if (c is TextFieldComponent) return c.object.id == modelId;
//       return false;
//     });
//   }
//
//   void _startOrUpdateComponentAnimation({
//     required PositionComponent component,
//     required FieldItemModel itemModel,
//     required Vector2 targetPositionInGameCoords,
//     required double duration,
//   }) {
//     var existingAnim = _activeAnimations.firstWhereOrNull(
//       (a) => a.component == component,
//     );
//     bool alreadyAtTarget =
//         (component.position - targetPositionInGameCoords).length2 <
//             ManualVelocityAnimation.arrivalThresholdSquared;
//     if (alreadyAtTarget) {
//       component.position.setFrom(targetPositionInGameCoords);
//       if (existingAnim != null) {
//         existingAnim.stop();
//         _activeAnimations.remove(existingAnim);
//       }
//       _activeMovingItemIdsInCurrentScene.remove(itemModel.id);
//       return;
//     }
//     if (itemModel is EquipmentModel &&
//         itemModel.name == "BALL" &&
//         itemModel.isAerialArrival) {
//       if (existingAnim != null) {
//         _activeAnimations.remove(existingAnim);
//       }
//       final arcingAnim = ArcingAnimation(
//         component: component,
//         itemModel: itemModel,
//         targetPosition: targetPositionInGameCoords,
//         duration: duration,
//         game: this,
//       );
//       _activeAnimations.add(arcingAnim);
//       if (arcingAnim.isMoving) {
//         _activeMovingItemIdsInCurrentScene.add(itemModel.id);
//       }
//     } else {
//       double distance =
//           (targetPositionInGameCoords - component.position).length;
//       double requiredSpeed =
//           (distance > 0.01 && duration > 0) ? (distance / duration) : 0;
//       if (requiredSpeed < 0.01 && !alreadyAtTarget) {
//         component.position.setFrom(targetPositionInGameCoords);
//         if (existingAnim != null) {
//           existingAnim.stop();
//           _activeAnimations.remove(existingAnim);
//         }
//         _activeMovingItemIdsInCurrentScene.remove(itemModel.id);
//         return;
//       }
//       if (existingAnim is ManualVelocityAnimation) {
//         existingAnim.updateSpeedMagnitude(requiredSpeed);
//         existingAnim.moveTo(targetPositionInGameCoords);
//       } else {
//         if (existingAnim != null) _activeAnimations.remove(existingAnim);
//         existingAnim = ManualVelocityAnimation(
//           component: component,
//           itemModel: itemModel,
//           initialTargetPositionGameCoords: targetPositionInGameCoords,
//           speedMagnitude: requiredSpeed,
//         );
//         _activeAnimations.add(existingAnim);
//       }
//       if (existingAnim.isMoving) {
//         _activeMovingItemIdsInCurrentScene.add(itemModel.id);
//       } else {
//         _activeMovingItemIdsInCurrentScene.remove(itemModel.id);
//       }
//     }
//   }
//
//   Future<void> _setupInitialSceneStatically() async {
//     if (animationModel.animationScenes.isEmpty) return;
//     _currentSceneIndex = 0;
//     AnimationItemModel firstScene = animationModel.animationScenes[0];
//     _activeMovingItemIdsInCurrentScene.clear();
//     _currentSceneDelayTimerActive = false;
//     _sceneProgressionTimer?.cancel();
//     _clearAllAnimations();
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
//               gameScreenSize: _tacticBoard.gameField.size,
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
//         addItemForAnimation(itemModel).then((_) async {
//           await Future.delayed(Duration.zero);
//           Component? comp = _findComponentByModelId(itemModel.id);
//           if (comp is PositionComponent && itemModel.offset != null) {
//             comp.position = SizeHelper.getBoardActualVector(
//               gameScreenSize: _tacticBoard.gameField.size,
//               actualPosition: itemModel.offset!,
//             );
//           }
//         }),
//       );
//     }
//     await Future.wait(addItemFutures);
//     await Future.delayed(Duration.zero);
//   }
//
//   Future<void> _processScene(AnimationItemModel animationItem) async {
//     if (_wasHardResetRecently || (this.paused && _isAnimationPaused)) return;
//     if (!_isAnimationPlaying || _isAnimationPaused) return;
//
//     List<FieldItemModel> itemsDefinedInCurrentScene = animationItem.components;
//     Set<String> idsInCurrentScene =
//         itemsDefinedInCurrentScene.map((e) => e.id).toSet();
//
//     _activeMovingItemIdsInCurrentScene.clear();
//     _currentSceneDelayTimerActive = false;
//     _sceneProgressionTimer?.cancel();
//
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
//         _activeAnimations.removeWhere(
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
//     List<FreeDrawModelV2> freeLinesInCurrentScene =
//         itemsDefinedInCurrentScene.whereType<FreeDrawModelV2>().toList();
//     List<FreeDrawModelV2> processedFreeLines = freeLinesInCurrentScene.map((e) {
//       var cloned = e.clone();
//       cloned.points = cloned.points
//           .map(
//             (p) => SizeHelper.getBoardActualVector(
//               gameScreenSize: _tacticBoard.gameField.size,
//               actualPosition: p,
//             ),
//           )
//           .toList();
//       return cloned;
//     }).toList();
//     drawingBoard.loadLines(processedFreeLines, suppressNotification: true);
//
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
//           addItemForAnimation(itemModel).then((_) async {
//             await Future.delayed(Duration.zero);
//             Component? newComp = _findComponentByModelId(itemModel.id);
//             if (newComp is PositionComponent) {
//               Vector2 initialPos = itemModel.offset != null
//                   ? SizeHelper.getBoardActualVector(
//                       gameScreenSize: _tacticBoard.gameField.size,
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
//                 gameScreenSize: _tacticBoard.gameField.size,
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
//                 _activeAnimations.removeWhere(
//                   (anim) => anim.component == existingComponent,
//                 );
//               }
//             } else {
//               _activeAnimations.removeWhere(
//                 (anim) => anim.component == existingComponent,
//               );
//             }
//           } else {
//             FieldItemModel? currentComponentModelInComponent =
//                 _getModelFromComponent(existingComponent);
//             if (currentComponentModelInComponent != null &&
//                 itemModel == currentComponentModelInComponent) {
//               if (itemModel.offset != null) {
//                 existingComponent.position = SizeHelper.getBoardActualVector(
//                   gameScreenSize: _tacticBoard.gameField.size,
//                   actualPosition: itemModel.offset!,
//                 );
//               }
//             } else {
//               _activeAnimations.removeWhere(
//                 (anim) => anim.component == existingComponent,
//               );
//               addItemFutures.add(() async {
//                 if (existingComponent.isMounted) remove(existingComponent);
//                 await Future.delayed(Duration.zero);
//                 await addItemForAnimation(itemModel);
//                 Component? newShapeComp = _findComponentByModelId(itemModel.id);
//                 if (newShapeComp is PositionComponent &&
//                     itemModel.offset != null) {
//                   newShapeComp.position = SizeHelper.getBoardActualVector(
//                     gameScreenSize: _tacticBoard.gameField.size,
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
//         Vector2 targetPositionGameCoords = SizeHelper.getBoardActualVector(
//           gameScreenSize: _tacticBoard.gameField.size,
//           actualPosition: targetModelOffset,
//         );
//
//         double finalDuration = actualSceneMovementDurationSeconds;
//         if (itemModel is EquipmentModel && itemModel.name == "BALL") {
//           final speedMultiplier = itemModel.passSpeedMultiplier ?? 1.0;
//           if (speedMultiplier > 0) {
//             finalDuration =
//                 actualSceneMovementDurationSeconds / speedMultiplier;
//           }
//         }
//
//         _startOrUpdateComponentAnimation(
//           component: component,
//           itemModel: itemModel,
//           targetPositionInGameCoords: targetPositionGameCoords,
//           duration: finalDuration,
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
//     if (component is TextFieldComponent) return component.object.id;
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
//     if (component is TextFieldComponent) return component.object;
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
//     if (isMounted && paused) resumeEngine();
//     if (_currentSceneIndex < animationModel.animationScenes.length) {
//       final AnimationItemModel sceneToProcess =
//           animationModel.animationScenes[_currentSceneIndex];
//       _currentSceneIndex++;
//       if (isForExportMode && animationModel.animationScenes.isNotEmpty) {
//         double progress = (_currentSceneIndex - 1) /
//             animationModel.animationScenes.length.toDouble();
//         if (_currentSceneIndex == 1 &&
//             _activeMovingItemIdsInCurrentScene.isEmpty &&
//             !_currentSceneDelayTimerActive) {
//           progress = 0.05;
//         }
//         onExportProgressUpdate?.call(progress.clamp(0.0, 1.0));
//       }
//       _processScene(sceneToProcess);
//     } else {
//       _isAnimationPlaying = false;
//       if (isForExportMode) {
//         onExportProgressUpdate?.call(1.0);
//       }
//     }
//   }
//
//   void setInterSceneDelayDuration(Duration newDelay) {
//     _baseSceneDelay = newDelay;
//   }
// }

import 'dart:async' as a;
import 'dart:math';
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
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/ball_trail_component.dart';
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

abstract class ComponentAnimation {
  final PositionComponent component;
  final FieldItemModel itemModel;
  bool get isMoving;
  ComponentAnimation({required this.component, required this.itemModel});
  bool update(double dt);
  void stop();
  void pause();
  void resume();
}

// PASTE THIS NEW CLASS IN ITS PLACE
// In your file with AnimationPlaybackMixin...

class ArcingAnimation extends ComponentAnimation {
  final Vector2 startPosition;
  final Vector2 targetPosition;
  final double duration;
  double _elapsedTime = 0;
  bool _isPaused = false;
  late final double arcHeight;
  final double sizeMultiplier;
  final Vector2 originalSize;
  static const double AIR_ROTATION_SPEED_RADS_PER_SEC = 0.5;
  final BallSpin spin;
  final TacticBoardGame game;
  BallTrailComponent? _trailComponent;

  // ADDED: Timer for spawning segments, now controlled here.
  late final Timer _spawnTimer;
  static const double spawnInterval = 0.02;

  @override
  bool get isMoving => _elapsedTime < duration && !_isPaused;

  ArcingAnimation({
    required super.component,
    required super.itemModel,
    required this.targetPosition,
    required this.duration,
    required this.game,
    this.sizeMultiplier = 1.3,
  })  : startPosition = component.position.clone(),
        originalSize = component.size.clone(),
        spin = (itemModel as EquipmentModel).spin ?? BallSpin.none {
    final distance = startPosition.distanceTo(targetPosition);
    arcHeight = (distance * 0.12).clamp(20.0, 120.0);

    // ADDED: Initialize the trail and the timer here.
    if (component is EquipmentComponent) {
      _trailComponent =
          BallTrailComponent(ball: component as EquipmentComponent);
      game.add(_trailComponent!);

      // The timer calls the trail's public spawnSegment method.
      _spawnTimer = Timer(
        spawnInterval,
        onTick: () => _trailComponent?.spawnSegment(),
        repeat: true,
      );
    }
  }

  @override
  bool update(double dt) {
    if (_isPaused || duration <= 0) return false;
    _elapsedTime += dt;
    double progress = (_elapsedTime / duration).clamp(0.0, 1.0);

    // [ ... The existing logic for calculating groundPosition and currentAltitude ... ]
    // This part is unchanged.
    Vector2 groundPosition;
    double currentAltitude;
    switch (spin) {
      case BallSpin.left:
        groundPosition = startPosition.clone()..lerp(targetPosition, progress);
        currentAltitude = arcHeight * sin(progress * pi);
        break;
      case BallSpin.right:
        groundPosition = startPosition.clone()..lerp(targetPosition, progress);
        currentAltitude = -arcHeight * sin(progress * pi);
        break;
      // case BallSpin.knuckleball:
      //   currentAltitude = arcHeight * sin(progress * pi);
      //   final linearPosition = startPosition.clone()
      //     ..lerp(targetPosition, progress);
      //   final diff = targetPosition - startPosition;
      //   final perpendicular = Vector2(diff.y, -diff.x).normalized();
      //   final wobble = sin(progress * pi * 3) * (originalSize.x * 0.5);
      //   groundPosition = linearPosition + (perpendicular * wobble);
      //   break;

      case BallSpin.knuckleball:
        // Altitude still follows a standard upward arc
        currentAltitude = arcHeight * sin(progress * pi);

        // NEW: Use a cubic Bezier S-curve for a smoother, more deliberate wave
        final diff = targetPosition - startPosition;
        final perpendicular = Vector2(diff.y, -diff.x).normalized();
        // This controls how wide the "S" curve is
        final curveAmount = diff.length * 0.15;

        // Define two control points to create the "S" shape
        final controlPoint1 =
            startPosition + (diff * 0.5) + (perpendicular * curveAmount);
        final controlPoint2 =
            startPosition + (diff * 0.5) - (perpendicular * curveAmount);

        // Cubic Bezier curve formula
        final t = progress;
        final oneMinusT = 1 - t;
        groundPosition = (startPosition * (oneMinusT * oneMinusT * oneMinusT)) +
            (controlPoint1 * (3 * (oneMinusT * oneMinusT) * t)) +
            (controlPoint2 * (3 * oneMinusT * (t * t))) +
            (targetPosition * (t * t * t));
        break;
      case BallSpin.none:
      default:
        groundPosition = startPosition.clone()..lerp(targetPosition, progress);
        currentAltitude = arcHeight * sin(progress * pi);
        break;
    }

    // === CRITICAL CHANGE LOCATION ===
    // First, update the ball's position.
    component.position = groundPosition;
    double arcFactor = sin(progress * pi);
    double currentSize =
        originalSize.x * (1 + (sizeMultiplier - 1) * arcFactor);

    if (component is EquipmentComponent) {
      (component as EquipmentComponent).altitude = currentAltitude;
      (component as EquipmentComponent).visualSize = Vector2.all(currentSize);
    }

    component.angle += AIR_ROTATION_SPEED_RADS_PER_SEC * dt;

    // Second, AFTER the ball has moved, update the timer to spawn a segment.
    _spawnTimer.update(dt);
    // === END OF CRITICAL CHANGE ===

    if (_elapsedTime >= duration) {
      stop();
      return true;
    }
    return false;
  }

  // The rest of the ArcingAnimation class (stop, pause, resume) remains the same.
  @override
  void stop() {
    _trailComponent?.removeFromParent();
    _trailComponent = null;
    _elapsedTime = duration;
    component.position.setFrom(targetPosition);
    if (component is EquipmentComponent) {
      (component as EquipmentComponent).altitude = 0;
      (component as EquipmentComponent).visualSize = originalSize;
    }
  }

  @override
  void pause() => _isPaused = true;
  @override
  void resume() => _isPaused = false;
}

class ManualVelocityAnimation extends ComponentAnimation {
  static const double arrivalThresholdSquared = 1.0;
  Vector2 _targetPosition;
  double _speedMagnitude;
  Vector2 _velocity;
  bool _isPaused = false;
  ManualVelocityAnimation(
      {required super.component,
      required super.itemModel,
      required Vector2 initialTargetPositionGameCoords,
      required double speedMagnitude})
      : _targetPosition = initialTargetPositionGameCoords,
        _speedMagnitude = speedMagnitude,
        _velocity = Vector2.zero() {
    _recalculateVelocity();
  }
  @override
  bool get isMoving => _velocity.length2 > 0 && !_isPaused;
  void _recalculateVelocity() {
    final direction = (_targetPosition - component.position);
    if (direction.length2 > arrivalThresholdSquared) {
      _velocity = direction.normalized() * _speedMagnitude;
    } else {
      _velocity = Vector2.zero();
    }
  }

  @override
  bool update(double dt) {
    if (!isMoving) return true;
    final displacement = _velocity * dt;
    if ((_targetPosition - component.position).length2 < displacement.length2) {
      component.position.setFrom(_targetPosition);
      _velocity = Vector2.zero();
      return true;
    } else {
      component.position += displacement;
    }
    return false;
  }

  void moveTo(Vector2 newTargetPosition) {
    _targetPosition = newTargetPosition;
    _recalculateVelocity();
  }

  void updateSpeedMagnitude(double newSpeed) {
    _speedMagnitude = newSpeed;
    _recalculateVelocity();
  }

  @override
  void stop() {
    _velocity = Vector2.zero();
    component.position.setFrom(_targetPosition);
  }

  @override
  void pause() => _isPaused = true;
  @override
  void resume() => _isPaused = false;
}

mixin AnimationPlaybackMixin on TacticBoardGame {
  late TacticBoard _tacticBoard;
  static const double VERY_LARGE_DT_THRESHOLD = 0.1;
  static const double REASONABLE_TIME_STEP_AFTER_FREEZE = 1.0 / 30.0;
  static const double BASE_BALL_ROTATION_SPEED_RADS_PER_SEC = 2 * 3.14159;
  late AnimationModel animationModel;
  late bool autoPlay;
  late bool isForExportMode;
  late Function(double progress)? onExportProgressUpdate;
  List<FieldItemModel> _components = [];
  bool _isAnimationPlaying = false;

  // These are the only two needed, with the correct definitions.
  @override
  bool get isAnimationCurrentlyPlaying => _isAnimationPlaying;
  bool _isAnimationPaused = false;
  @override
  bool get isAnimationCurrentlyPaused => _isAnimationPaused;

  double _scenePaceFactor = 1.0;
  int _currentSceneIndex = 0;
  bool _wasHardResetRecently = false;
  a.Timer? _sceneProgressionTimer;
  Duration _baseSceneDelay = const Duration(milliseconds: 500);
  final List<ComponentAnimation> _activeAnimations = [];
  Set<String> _activeMovingItemIdsInCurrentScene = {};
  bool _currentSceneDelayTimerActive = false;

  void startAnimation({
    required AnimationModel am,
    bool ap = false,
    bool isForE = false,
    Function(double progress)? onExportP,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      animationModel = am;
      autoPlay = ap;
      isForExportMode = isForE;
      onExportProgressUpdate = onExportP;
      if (isForExportMode) {
        _scenePaceFactor = 2.0;
      }
      _tacticBoard = (this as TacticBoard);
      _tacticBoard.isAnimating = false;
      _tacticBoard.removeAll(children.whereType<FieldComponent>());
      if (animationModel.animationScenes.isEmpty) {
        _isAnimationPlaying = false;
        return;
      }
      if (autoPlay) {
        _setupInitialSceneStatically();
        performStartAnimationFromBeginning();
      } else {
        _setupInitialSceneStatically();
        _isAnimationPlaying = false;
        _isAnimationPaused = false;
        _currentSceneIndex = 0;
        _wasHardResetRecently = false;
      }
    });
  }

  @override
  void update(double dt) {
    double effectiveDt = dt;
    if (dt > VERY_LARGE_DT_THRESHOLD) {
      effectiveDt = REASONABLE_TIME_STEP_AFTER_FREEZE;
    }
    if (effectiveDt <= 0) {
      effectiveDt = 1.0 / 60.0;
    }
    super.update(effectiveDt);
    if (_isAnimationPlaying && !_isAnimationPaused && !this.paused) {
      bool anAnimationCompletedThisFrame = false;
      for (int i = _activeAnimations.length - 1; i >= 0; i--) {
        final anim = _activeAnimations[i];
        if (anim.component is EquipmentComponent) {
          final equipmentComponent = anim.component as EquipmentComponent;
          final equipmentModel = equipmentComponent.object;
          if (equipmentModel.name == "BALL" &&
              anim.isMoving &&
              !equipmentModel.isAerialArrival) {
            double rotationThisFrame = BASE_BALL_ROTATION_SPEED_RADS_PER_SEC *
                effectiveDt *
                _scenePaceFactor;
            equipmentComponent.angle -= rotationThisFrame;
          }
        }
        if (anim.update(effectiveDt)) {
          _activeMovingItemIdsInCurrentScene.remove(anim.itemModel.id);
          _activeAnimations.removeAt(i);
          anAnimationCompletedThisFrame = true;
        }
      }
      if (anAnimationCompletedThisFrame ||
          (_activeAnimations.isEmpty &&
              _activeMovingItemIdsInCurrentScene.isEmpty)) {
        _checkSceneCompletionAndProceed();
      }
    }
  }

  double get currentScenePaceFactor => _scenePaceFactor;

  @override
  void performStartAnimationFromBeginning() {
    if (_wasHardResetRecently) {
      _wasHardResetRecently = false;
    }
    if (paused) resumeEngine();
    _isAnimationPlaying = true;
    _isAnimationPaused = false;
    _currentSceneIndex = 0;
    _clearAllAnimations();
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
    for (final anim in _activeAnimations) anim.resume();
    _checkSceneCompletionAndProceed();
  }

  @override
  void performPauseAnimation() {
    if (!_isAnimationPlaying || !_isAnimationPaused) {
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
    for (final anim in _activeAnimations) anim.pause();
    if (isMounted && !paused) pauseEngine();
  }

  @override
  void performStopAnimation({bool hardReset = false}) {
    if (paused) resumeEngine();
    _isAnimationPlaying = false;
    _isAnimationPaused = false;
    _sceneProgressionTimer?.cancel();
    _currentSceneDelayTimerActive = false;
    _clearAllAnimations();
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
    }
  }

  @override
  void performSetAnimationPace(double newPaceFactor) {
    if (newPaceFactor <= 0.0) return;
    final oldPaceFactor = _scenePaceFactor;
    _scenePaceFactor = newPaceFactor;
    if (oldPaceFactor > 0 &&
        oldPaceFactor != newPaceFactor &&
        _isAnimationPlaying &&
        !_isAnimationPaused) {
      double paceScaleFactor = newPaceFactor / oldPaceFactor;
      for (final anim in _activeAnimations) {
        if (anim is ManualVelocityAnimation) {
          double newIndividualSpeed = anim._speedMagnitude * paceScaleFactor;
          anim.updateSpeedMagnitude(newIndividualSpeed);
        }
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
      add(PlayerComponent(object: item));
    } else if (item is EquipmentModel) {
      add(EquipmentComponent(object: item));
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

  void _clearAllAnimations() {
    for (var anim in _activeAnimations) anim.stop();
    _activeAnimations.clear();
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

  void _startOrUpdateComponentAnimation({
    required PositionComponent component,
    required FieldItemModel itemModel,
    required Vector2 targetPositionInGameCoords,
    required double duration,
  }) {
    var existingAnim = _activeAnimations.firstWhereOrNull(
      (a) => a.component == component,
    );
    bool alreadyAtTarget =
        (component.position - targetPositionInGameCoords).length2 <
            ManualVelocityAnimation.arrivalThresholdSquared;
    if (alreadyAtTarget) {
      component.position.setFrom(targetPositionInGameCoords);
      if (existingAnim != null) {
        existingAnim.stop();
        _activeAnimations.remove(existingAnim);
      }
      _activeMovingItemIdsInCurrentScene.remove(itemModel.id);
      return;
    }
    if (itemModel is EquipmentModel &&
        itemModel.name == "BALL" &&
        itemModel.isAerialArrival) {
      if (existingAnim != null) {
        _activeAnimations.remove(existingAnim);
      }
      final arcingAnim = ArcingAnimation(
        component: component,
        itemModel: itemModel,
        targetPosition: targetPositionInGameCoords,
        duration: duration,
        game: this,
      );
      _activeAnimations.add(arcingAnim);
      if (arcingAnim.isMoving) {
        _activeMovingItemIdsInCurrentScene.add(itemModel.id);
      }
    } else {
      double distance =
          (targetPositionInGameCoords - component.position).length;
      double requiredSpeed =
          (distance > 0.01 && duration > 0) ? (distance / duration) : 0;
      if (requiredSpeed < 0.01 && !alreadyAtTarget) {
        component.position.setFrom(targetPositionInGameCoords);
        if (existingAnim != null) {
          existingAnim.stop();
          _activeAnimations.remove(existingAnim);
        }
        _activeMovingItemIdsInCurrentScene.remove(itemModel.id);
        return;
      }
      if (existingAnim is ManualVelocityAnimation) {
        existingAnim.updateSpeedMagnitude(requiredSpeed);
        existingAnim.moveTo(targetPositionInGameCoords);
      } else {
        if (existingAnim != null) _activeAnimations.remove(existingAnim);
        existingAnim = ManualVelocityAnimation(
          component: component,
          itemModel: itemModel,
          initialTargetPositionGameCoords: targetPositionInGameCoords,
          speedMagnitude: requiredSpeed,
        );
        _activeAnimations.add(existingAnim);
      }
      if (existingAnim.isMoving) {
        _activeMovingItemIdsInCurrentScene.add(itemModel.id);
      } else {
        _activeMovingItemIdsInCurrentScene.remove(itemModel.id);
      }
    }
  }

  Future<void> _setupInitialSceneStatically() async {
    if (animationModel.animationScenes.isEmpty) return;
    _currentSceneIndex = 0;
    AnimationItemModel firstScene = animationModel.animationScenes[0];
    _activeMovingItemIdsInCurrentScene.clear();
    _currentSceneDelayTimerActive = false;
    _sceneProgressionTimer?.cancel();
    _clearAllAnimations();
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
  }

  Future<void> _processScene(AnimationItemModel animationItem) async {
    if (_wasHardResetRecently || (this.paused && _isAnimationPaused)) return;
    if (!_isAnimationPlaying || _isAnimationPaused) return;
    List<FieldItemModel> itemsDefinedInCurrentScene = animationItem.components;
    Set<String> idsInCurrentScene =
        itemsDefinedInCurrentScene.map((e) => e.id).toSet();
    _activeMovingItemIdsInCurrentScene.clear();
    _currentSceneDelayTimerActive = false;
    _sceneProgressionTimer?.cancel();
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
        _activeAnimations.removeWhere(
          (anim) => anim.component == compToRemove,
        );
        String? idToRemove = _getComponentModelId(compToRemove);
        if (idToRemove != null)
          _components.removeWhere((m) => m.id == idToRemove);
        remove(compToRemove);
      }
      await Future.delayed(Duration.zero);
    }
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
    List<Future<void>> addItemFutures = [];
    List<Map<String, dynamic>> componentsToAnimateDetails = [];
    for (var itemModel in itemsDefinedInCurrentScene) {
      if (itemModel is FreeDrawModelV2) continue;
      if (!_isAnimationPlaying) break;
      Component? existingComponent = _findComponentByModelId(itemModel.id);
      if (existingComponent == null) {
        addItemFutures.add(
          addItemForAnimation(itemModel).then((_) async {
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
                _activeAnimations.removeWhere(
                  (anim) => anim.component == existingComponent,
                );
              }
            } else {
              _activeAnimations.removeWhere(
                (anim) => anim.component == existingComponent,
              );
            }
          } else {
            FieldItemModel? currentComponentModelInComponent =
                _getModelFromComponent(existingComponent);
            if (currentComponentModelInComponent != null &&
                itemModel == currentComponentModelInComponent) {
              if (itemModel.offset != null) {
                existingComponent.position = SizeHelper.getBoardActualVector(
                  gameScreenSize: _tacticBoard.gameField.size,
                  actualPosition: itemModel.offset!,
                );
              }
            } else {
              _activeAnimations.removeWhere(
                (anim) => anim.component == existingComponent,
              );
              addItemFutures.add(() async {
                if (existingComponent.isMounted) remove(existingComponent);
                await Future.delayed(Duration.zero);
                await addItemForAnimation(itemModel);
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
        Vector2 targetPositionGameCoords = SizeHelper.getBoardActualVector(
          gameScreenSize: _tacticBoard.gameField.size,
          actualPosition: targetModelOffset,
        );
        double finalDuration = actualSceneMovementDurationSeconds;
        if (itemModel is EquipmentModel && itemModel.name == "BALL") {
          final speedMultiplier = itemModel.passSpeedMultiplier ?? 1.0;
          if (speedMultiplier > 0) {
            finalDuration =
                actualSceneMovementDurationSeconds / speedMultiplier;
          }
        }
        _startOrUpdateComponentAnimation(
          component: component,
          itemModel: itemModel,
          targetPositionInGameCoords: targetPositionGameCoords,
          duration: finalDuration,
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
      if (isForExportMode && animationModel.animationScenes.isNotEmpty) {
        double progress = (_currentSceneIndex - 1) /
            animationModel.animationScenes.length.toDouble();
        if (_currentSceneIndex == 1 &&
            _activeMovingItemIdsInCurrentScene.isEmpty &&
            !_currentSceneDelayTimerActive) {
          progress = 0.05;
        }
        onExportProgressUpdate?.call(progress.clamp(0.0, 1.0));
      }
      _processScene(sceneToProcess);
    }
    // else {
    //   _isAnimationPlaying = false;
    //   if (isForExportMode) {
    //     onExportProgressUpdate?.call(1.0);
    //   }
    // }
    else {
      // Animation sequence has finished.
      _isAnimationPlaying = false;

      // 1. ALWAYS notify the UI widget that the animation is complete.
      onExportProgressUpdate?.call(1.0);

      // 2. Automatically reset the animation to the first scene.
      // We only do this for normal playback, not for video exports.
      if (!isForExportMode) {
        performHardResetAnimation();
      }
    }
  }

  void setInterSceneDelayDuration(Duration newDelay) {
    _baseSceneDelay = newDelay;
  }
}
