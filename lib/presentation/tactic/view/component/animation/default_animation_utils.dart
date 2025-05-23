// import 'dart:math';
//
// import 'package:flame/components.dart'; // For Vector2
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/generator/random_generator.dart'; // For generating IDs
// import 'package:zporter_tactical_board/app/manager/color_manager.dart'; // For default colors
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/team_formation_config_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_utils.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
//
// class DefaultAnimationUtils {
//   // --- Common Configuration ---
//   static const String _defaultUserId = "default_user";
//   static final Color _defaultFieldColor = ColorManager.grey;
//   static final Vector2 _defaultFieldSize = Vector2(1000, 600);
//   static const int _defaultDrillScenes =
//       8; // Default number of scenes for simpler drills
//   static const int _defaultTimingMs = 700; // Default time between scenes
//
//   // --- Helper to get base players/equipment ---
//   static List<PlayerModel> _getHomePlayers() =>
//       PlayerUtilsV2.generatePlayerModelList(playerType: PlayerType.HOME);
//   static List<PlayerModel> _getAwayPlayers() =>
//       PlayerUtilsV2.generatePlayerModelList(playerType: PlayerType.AWAY);
//   static List<EquipmentModel> _getEquipment() =>
//       EquipmentUtils.generateEquipments();
//
//   static PlayerModel _findPlayer(
//     List<PlayerModel> list,
//     String role, [
//     int? jerseyNumber,
//   ]) {
//     // Added null check on list for safety
//     if (list.isEmpty) {
//       // Return a default/dummy player or throw an error if the list is unexpectedly empty
//       print("Warning: Player list is empty when trying to find role $role");
//       // Returning a dummy player - adjust as needed
//       return PlayerModel(
//         id: 'dummy',
//         role: role,
//         jerseyNumber: jerseyNumber ?? 0,
//         playerType: PlayerType.UNKNOWN,
//         offset: Vector2.zero(),
//         size: Vector2.zero(),
//         color: Colors.red,
//       );
//     }
//     return list.firstWhere(
//       (p) =>
//           p.role == role &&
//           (jerseyNumber == null || p.jerseyNumber == jerseyNumber),
//       orElse:
//           () => list.firstWhere(
//             (p) => p.role == role,
//             orElse: () => list.first,
//           ), // Fallback
//     );
//   }
//
//   static EquipmentModel _findEquipment(List<EquipmentModel> list, String name) {
//     // Added null check on list for safety
//     if (list.isEmpty) {
//       print("Warning: Equipment list is empty when trying to find $name");
//       return EquipmentModel(
//         id: RandomGenerator.generateId(),
//         name: name,
//         imagePath: "${name.toLowerCase()}.png",
//       ); // Basic fallback
//     }
//     return list.firstWhere(
//       (eq) => eq.name == name,
//       orElse:
//           () => EquipmentModel(
//             id: RandomGenerator.generateId(),
//             name: name,
//             imagePath: "${name.toLowerCase()}.png",
//           ), // Basic fallback
//     );
//   }
//
//   // --- Existing Animation Methods ---
//
//   /// Creates a default animation with 3 players and 12 scenes:
//   /// Pass and move triangle, finishing with a shot.
//   static AnimationModel createDefaultTrianglePassAndShotAnimation() {
//     // --- Configuration ---
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//
//     // --- Select Players and Equipment ---
//     final List<PlayerModel> allHomePlayers = _getHomePlayers();
//     final List<EquipmentModel> allEquipment = _getEquipment();
//     final PlayerModel playerCMStart = _findPlayer(
//       allHomePlayers,
//       "CM",
//       8,
//     ); // Made non-nullable with fallback
//     final PlayerModel playerSTStart = _findPlayer(
//       allHomePlayers,
//       "ST",
//       9,
//     ); // Made non-nullable with fallback
//     final PlayerModel playerRWStart = _findPlayer(
//       allHomePlayers,
//       "RW",
//       7,
//     ); // Made non-nullable with fallback
//     final EquipmentModel ballStart = _findEquipment(
//       allEquipment,
//       "BALL",
//     ); // Made non-nullable with fallback
//
//     // Note: Error animation is handled by _findPlayer/_findEquipment fallbacks now
//
//     // --- Define Scene Positions (12 Scenes) ---
//     final Vector2 pCMPosKickoff = Vector2(PlayerUtilsV2.getKickoffX(0.35), 0.5);
//     final Vector2 pSTPosKickoff = Vector2(PlayerUtilsV2.getKickoffX(0.48), 0.5);
//     final Vector2 pRWPosKickoff = Vector2(PlayerUtilsV2.getKickoffX(0.45), 0.8);
//     final Vector2 goalTargetPos = Vector2(0.98, 0.5);
//     // ... (Scene position calculations S1-S12 as in previous correct version) ...
//     // Scene 1: Start
//     final Vector2 pCMPosS1 = pCMPosKickoff.clone();
//     final Vector2 pSTPosS1 = pSTPosKickoff.clone();
//     final Vector2 pRWPosS1 = pRWPosKickoff.clone();
//     final Vector2 ballPosS1 = pCMPosS1 + Vector2(0.01, 0.01);
//     // Scene 2: CM Pass towards ST
//     final Vector2 pCMPosS2 = pCMPosS1.clone();
//     final Vector2 pSTPosS2 = pSTPosS1.clone();
//     final Vector2 pRWPosS2 = pRWPosS1.clone();
//     final Vector2 ballPosS2 = pCMPosS1 + (pSTPosS1 - pCMPosS1) * 0.5;
//     // Scene 3: ST Receives
//     final Vector2 pCMPosS3 = pCMPosS1.clone();
//     final Vector2 pSTPosS3 = pSTPosS1.clone();
//     final Vector2 pRWPosS3 = pRWPosS1.clone();
//     final Vector2 ballPosS3 = pSTPosS3 + Vector2(0.01, 0.01);
//     // Scene 4: ST Pass towards RW (RW makes run)
//     final Vector2 pCMPosS4 = pCMPosS1.clone();
//     final Vector2 pSTPosS4 = pSTPosS1.clone();
//     final Vector2 pRWPosS4 = Vector2(0.65, 0.85);
//     final Vector2 ballPosS4 = pSTPosS4.clone();
//     // Scene 5: Ball in transit to RW
//     final Vector2 pCMPosS5 = pCMPosS1.clone();
//     final Vector2 pSTPosS5 = pSTPosS1.clone();
//     final Vector2 pRWPosS5 = pRWPosS4.clone();
//     final Vector2 ballPosS5 = pSTPosS4 + (pRWPosS4 - pSTPosS4) * 0.5;
//     // Scene 6: RW Receives
//     final Vector2 pCMPosS6 = pCMPosS1.clone();
//     final Vector2 pSTPosS6 = pSTPosS1.clone();
//     final Vector2 pRWPosS6 = pRWPosS4.clone();
//     final Vector2 ballPosS6 = pRWPosS6 + Vector2(-0.01, 0.01);
//     // Scene 7: RW Dribbles forward
//     final Vector2 pCMPosS7 = pCMPosS1.clone();
//     final Vector2 pSTPosS7 = Vector2(0.60, 0.55);
//     final Vector2 pRWPosS7 = Vector2(0.75, 0.85);
//     final Vector2 ballPosS7 = pRWPosS7 + Vector2(-0.01, 0.01);
//     // Scene 8: RW Passes/Crosses towards ST
//     final Vector2 pCMPosS8 = pCMPosS1.clone();
//     final Vector2 pSTPosS8 = pSTPosS7.clone();
//     final Vector2 pRWPosS8 = pRWPosS7.clone();
//     final Vector2 ballPosS8 = pRWPosS8 + (pSTPosS8 - pRWPosS8) * 0.5;
//     // Scene 9: Ball arrives near ST
//     final Vector2 pCMPosS9 = pCMPosS1.clone();
//     final Vector2 pSTPosS9 = pSTPosS7.clone();
//     final Vector2 pRWPosS9 = pRWPosS7.clone();
//     final Vector2 ballPosS9 = pSTPosS9 + Vector2(0.01, 0.01);
//     // Scene 10: ST prepares to shoot
//     final Vector2 pCMPosS10 = pCMPosS1.clone();
//     final Vector2 pSTPosS10 = pSTPosS9.clone();
//     final Vector2 pRWPosS10 = pRWPosS9.clone();
//     final Vector2 ballPosS10 = pSTPosS10 + Vector2(0.02, 0.0);
//     // Scene 11: ST Shoots
//     final Vector2 pCMPosS11 = pCMPosS1.clone();
//     final Vector2 pSTPosS11 = pSTPosS10.clone();
//     final Vector2 pRWPosS11 = pRWPosS10.clone();
//     final Vector2 ballPosS11 = pSTPosS10 + (goalTargetPos - pSTPosS10) * 0.5;
//     // Scene 12: Ball hits goal area
//     final Vector2 pCMPosS12 = pCMPosS1.clone();
//     final Vector2 pSTPosS12 = pSTPosS11.clone();
//     final Vector2 pRWPosS12 = pRWPosS11.clone();
//     final Vector2 ballPosS12 = goalTargetPos.clone();
//
//     // --- Create Scene Components ---
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     final positions = [
//       [pCMPosS1, pSTPosS1, pRWPosS1, ballPosS1],
//       [pCMPosS2, pSTPosS2, pRWPosS2, ballPosS2],
//       [pCMPosS3, pSTPosS3, pRWPosS3, ballPosS3],
//       [pCMPosS4, pSTPosS4, pRWPosS4, ballPosS4],
//       [pCMPosS5, pSTPosS5, pRWPosS5, ballPosS5],
//       [pCMPosS6, pSTPosS6, pRWPosS6, ballPosS6],
//       [pCMPosS7, pSTPosS7, pRWPosS7, ballPosS7],
//       [pCMPosS8, pSTPosS8, pRWPosS8, ballPosS8],
//       [pCMPosS9, pSTPosS9, pRWPosS9, ballPosS9],
//       [pCMPosS10, pSTPosS10, pRWPosS10, ballPosS10],
//       [pCMPosS11, pSTPosS11, pRWPosS11, ballPosS11],
//       [pCMPosS12, pSTPosS12, pRWPosS12, ballPosS12],
//     ];
//     for (int i = 0; i < 12; i++) {
//       sceneComponentsList.add([
//         playerCMStart.copyWith(offset: positions[i][0]),
//         playerSTStart.copyWith(offset: positions[i][1]),
//         playerRWStart.copyWith(offset: positions[i][2]),
//         ballStart.copyWith(offset: positions[i][3]),
//       ]);
//     }
//
//     // --- Create AnimationItemModel Scenes ---
//     final List<AnimationItemModel> scenes = List.generate(
//       12,
//       (index) => AnimationItemModel(
//         id: RandomGenerator.generateId(),
//         components: sceneComponentsList[index],
//         fieldColor: _defaultFieldColor,
//         createdAt: now.add(Duration(seconds: index)),
//         updatedAt: now.add(Duration(seconds: index)),
//         userId: _defaultUserId,
//         fieldSize: _defaultFieldSize.clone(),
//       ),
//     );
//
//     // --- Create Final AnimationModel ---
//     return AnimationModel(
//       id: animationId,
//       name: "Default Triangle Pass and Shot",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   /// Creates a default Rondo (Piggy in the Middle) animation in the home half.
//   static AnimationModel createRondoDrillAnimation() {
//     // --- Configuration ---
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numCirclePlayers = 5;
//     final Vector2 circleCenter = Vector2(0.25, 0.5); // Center in home half
//     const double circleRadius = 0.12;
//     const int numScenes = 12; // More scenes for smoother passes
//     const double ballOffsetFromPlayerFeet = 0.015;
//
//     // --- Select Players and Equipment ---
//     final List<PlayerModel> allHomePlayers = _getHomePlayers();
//     final List<PlayerModel> allAwayPlayers = _getAwayPlayers();
//     final List<EquipmentModel> allEquipment = _getEquipment();
//     final List<PlayerModel> circlePlayersStart =
//         allHomePlayers.take(numCirclePlayers).toList();
//     final PlayerModel defenderStart = _findPlayer(
//       allAwayPlayers,
//       "CDM",
//     ); // Use CDM as defender
//     final EquipmentModel ballStart = _findEquipment(allEquipment, "BALL");
//
//     if (circlePlayersStart.length < numCirclePlayers) {
//       /* Error handling */
//       return _createErrorAnimation("Rondo");
//     }
//
//     // --- Calculate Initial Positions ---
//     List<Vector2> circlePositions = List.generate(numCirclePlayers, (i) {
//       double angle = (2 * pi / numCirclePlayers) * i - (pi / 2);
//       return circleCenter + Vector2(cos(angle), sin(angle)) * circleRadius;
//     });
//     Vector2 defenderPos = circleCenter.clone();
//     Vector2 directionToCenterP0 =
//         (circleCenter - circlePositions[0])..normalize();
//     Vector2 ballPos =
//         circlePositions[0] + directionToCenterP0 * ballOffsetFromPlayerFeet;
//
//     // --- Generate Scenes ---
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     int ballHolderIndex = 0;
//     for (int sceneIndex = 0; sceneIndex < numScenes; sceneIndex++) {
//       List<PlayerModel> currentCirclePlayers = List.generate(
//         numCirclePlayers,
//         (i) => circlePlayersStart[i].copyWith(offset: circlePositions[i]),
//       );
//       PlayerModel currentDefender = defenderStart.copyWith(offset: defenderPos);
//       EquipmentModel currentBall = ballStart.copyWith(offset: ballPos);
//       sceneComponentsList.add([
//         ...currentCirclePlayers,
//         currentDefender,
//         currentBall,
//       ]);
//
//       if (sceneIndex < numScenes - 1) {
//         int nextPassTargetIndex = (ballHolderIndex + 1) % numCirclePlayers;
//         Vector2 passerPos = circlePositions[ballHolderIndex];
//         Vector2 receiverPos = circlePositions[nextPassTargetIndex];
//         Vector2 passMidpoint = passerPos + (receiverPos - passerPos) * 0.5;
//         Vector2 directionToPassMidpoint =
//             (passMidpoint - defenderPos)..normalize();
//         defenderPos += directionToPassMidpoint * (circleRadius * 0.25);
//         defenderPos.x = defenderPos.x.clamp(
//           circleCenter.x - circleRadius,
//           circleCenter.x + circleRadius,
//         );
//         defenderPos.y = defenderPos.y.clamp(
//           circleCenter.y - circleRadius,
//           circleCenter.y + circleRadius,
//         );
//
//         if (sceneIndex % 2 == 0) {
//           ballPos = passerPos + (receiverPos - passerPos) * 0.5;
//         } // Ball in transit
//         else {
//           // Ball received
//           Vector2 passDirection = (receiverPos - passerPos)..normalize();
//           ballPos =
//               receiverPos -
//               passDirection * ballOffsetFromPlayerFeet; // At receiver's feet
//           ballHolderIndex = nextPassTargetIndex;
//         }
//       }
//     }
//     // --- Create Scenes & Animation ---
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//       timingMs: 700,
//     ); // Adjusted timing
//     return AnimationModel(
//       id: animationId,
//       name: "Rondo Drill",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   /// Creates a default Cone Weaving Drill animation.
//   static AnimationModel createConeWeavingDrillAnimation() {
//     // --- Configuration ---
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numberOfCones = 4;
//     const double coneSpacingX = 0.12;
//     const double startX = 0.15;
//     const double coneY = 0.5;
//     const double playerStartY = 0.5;
//     const double weaveOffsetY = 0.08;
//     // final int totalScenes = 1 + (numberOfCones * 2) + 1; // Start + 2 per cone + Finish
//
//     // --- Select Players and Equipment ---
//     final List<PlayerModel> allHomePlayers = _getHomePlayers();
//     final List<EquipmentModel> allEquipment = _getEquipment();
//     final PlayerModel playerStart = _findPlayer(
//       allHomePlayers,
//       "CM",
//       8,
//     ); // Example player
//     final EquipmentModel ballStart = _findEquipment(allEquipment, "BALL");
//     final EquipmentModel coneModel = _findEquipment(allEquipment, "CONE");
//
//     // --- Create Cone Components ---
//     final List<EquipmentModel> coneComponents = List.generate(
//       numberOfCones,
//       (i) => coneModel.copyWith(
//         id: RandomGenerator.generateId(),
//         offset: Vector2(startX + (i * coneSpacingX), coneY),
//       ),
//     );
//
//     // --- Generate Scenes ---
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 currentPlayerPos = Vector2(
//       startX - coneSpacingX * 0.7,
//       playerStartY,
//     );
//     Vector2 currentBallPos = currentPlayerPos + Vector2(0.01, 0.01);
//     bool weaveLeft = true;
//     sceneComponentsList.add([
//       playerStart.copyWith(offset: currentPlayerPos),
//       ballStart.copyWith(offset: currentBallPos),
//       ...coneComponents.map((c) => c.clone()),
//     ]);
//
//     for (int i = 0; i < numberOfCones; i++) {
//       Vector2 conePos = coneComponents[i].offset!;
//       double targetY =
//           weaveLeft ? (coneY - weaveOffsetY) : (coneY + weaveOffsetY);
//       Vector2 midWeavePos = Vector2(conePos.x, targetY);
//       Vector2 endWeavePos = Vector2(
//         conePos.x + coneSpacingX * 0.5,
//         playerStartY,
//       );
//       // Move abeam
//       currentPlayerPos = midWeavePos;
//       currentBallPos =
//           currentPlayerPos +
//           (weaveLeft ? Vector2(0.01, 0.01) : Vector2(0.01, -0.01));
//       sceneComponentsList.add([
//         playerStart.copyWith(offset: currentPlayerPos),
//         ballStart.copyWith(offset: currentBallPos),
//         ...coneComponents.map((c) => c.clone()),
//       ]);
//       // Move past
//       currentPlayerPos = endWeavePos;
//       currentBallPos = currentPlayerPos + Vector2(0.01, 0.01);
//       sceneComponentsList.add([
//         playerStart.copyWith(offset: currentPlayerPos),
//         ballStart.copyWith(offset: currentBallPos),
//         ...coneComponents.map((c) => c.clone()),
//       ]);
//       weaveLeft = !weaveLeft;
//     }
//     // Finish
//     currentPlayerPos = Vector2(
//       startX + (numberOfCones * coneSpacingX),
//       playerStartY,
//     );
//     currentBallPos = currentPlayerPos + Vector2(0.01, 0.01);
//     sceneComponentsList.add([
//       playerStart.copyWith(offset: currentPlayerPos),
//       ballStart.copyWith(offset: currentBallPos),
//       ...coneComponents.map((c) => c.clone()),
//     ]);
//
//     // --- Create Scenes & Animation ---
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Cone Weaving Drill",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   // ===============================================
//   // == NEW ANIMATIONS BASED ON USER REQUEST LIST ==
//   // ===============================================
//
//   // --- 1. Passing & Possession ---
//
//   static AnimationModel createOneTouchPassingCircuitAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numPlayers = 4; // Example: Square formation
//     final Vector2 center = Vector2(0.25, 0.5);
//     const double radius = 0.15;
//     const int numScenes = 9; // Start + 4 passes (2 scenes each)
//
//     final List<PlayerModel> players =
//         _getHomePlayers().take(numPlayers).toList();
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//     if (players.length < numPlayers)
//       return _createErrorAnimation("One Touch Passing");
//
//     List<Vector2> positions = List.generate(numPlayers, (i) {
//       double angle = (pi / 2) * i; // Square positions
//       return center + Vector2(cos(angle), sin(angle)) * radius;
//     });
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     int ballHolder = 0;
//     Vector2 ballPos = positions[ballHolder] + Vector2(0.01, 0.01);
//
//     for (int scene = 0; scene < numScenes; scene++) {
//       List<PlayerModel> currentPlayers = List.generate(
//         numPlayers,
//         (i) => players[i].copyWith(offset: positions[i]),
//       );
//       EquipmentModel currentBall = ball.copyWith(offset: ballPos);
//       sceneComponentsList.add([...currentPlayers, currentBall]);
//
//       if (scene < numScenes - 1) {
//         int nextReceiver = (ballHolder + 1) % numPlayers;
//         Vector2 passerPos = positions[ballHolder];
//         Vector2 receiverPos = positions[nextReceiver];
//
//         if (scene % 2 == 0) {
//           // Ball in transit
//           ballPos = passerPos + (receiverPos - passerPos) * 0.5;
//         } else {
//           // Ball received
//           Vector2 passDir = (receiverPos - passerPos)..normalize();
//           ballPos = receiverPos - passDir * 0.015; // At feet
//           ballHolder = nextReceiver;
//         }
//       }
//     }
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "One-Touch Passing Circuit",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createTrianglePassingDrillAnimation() {
//     // Reusing the PassAndShot logic but stopping earlier and renaming
//     AnimationModel anim = createDefaultTrianglePassAndShotAnimation();
//     return anim.copyWith(
//       name: "Triangle Passing Drill",
//       // Take only the first 6 scenes (pass CM->ST, ST->RW)
//       animationScenes: anim.animationScenes.take(6).toList(),
//     );
//   }
//
//   static AnimationModel create4v2KeepAwayDrillAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     final Vector2 center = Vector2(0.25, 0.5);
//     const double radius = 0.15;
//     const int numAttackers = 4;
//     const int numDefenders = 2;
//     const int numScenes = 12;
//
//     final List<PlayerModel> attackers =
//         _getHomePlayers().take(numAttackers).toList();
//     final List<PlayerModel> defenders =
//         _getAwayPlayers().take(numDefenders).toList();
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//
//     if (attackers.length < numAttackers || defenders.length < numDefenders)
//       return _createErrorAnimation("4v2 Keep Away");
//
//     // Initial positions
//     List<Vector2> attackerPos = List.generate(numAttackers, (i) {
//       double angle = (2 * pi / numAttackers) * i;
//       return center + Vector2(cos(angle), sin(angle)) * radius;
//     });
//     List<Vector2> defenderPos = [
//       center + Vector2(-radius * 0.3, 0),
//       center + Vector2(radius * 0.3, 0),
//     ];
//     int ballHolder = 0;
//     Vector2 ballPos = attackerPos[ballHolder] + Vector2(0.01, 0.01);
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//
//     for (int scene = 0; scene < numScenes; scene++) {
//       List<PlayerModel> currentAttackers = List.generate(
//         numAttackers,
//         (i) => attackers[i].copyWith(offset: attackerPos[i]),
//       );
//       List<PlayerModel> currentDefenders = List.generate(
//         numDefenders,
//         (i) => defenders[i].copyWith(offset: defenderPos[i]),
//       );
//       EquipmentModel currentBall = ball.copyWith(offset: ballPos);
//       sceneComponentsList.add([
//         ...currentAttackers,
//         ...currentDefenders,
//         currentBall,
//       ]);
//
//       if (scene < numScenes - 1) {
//         int nextReceiver =
//             (ballHolder + 1 + (scene % 2)) % numAttackers; // Pass 1 or 2 away
//         Vector2 passerPos = attackerPos[ballHolder];
//         Vector2 receiverPos = attackerPos[nextReceiver];
//
//         // Move defenders towards ball/pass lane
//         for (int i = 0; i < numDefenders; i++) {
//           Vector2 target =
//               (i == 0)
//                   ? ballPos
//                   : (passerPos + receiverPos) / 2; // One to ball, one to lane
//           Vector2 dir = (target - defenderPos[i])..normalize();
//           defenderPos[i] += dir * (radius * 0.15); // Adjust speed
//           defenderPos[i].x = defenderPos[i].x.clamp(
//             center.x - radius,
//             center.x + radius,
//           );
//           defenderPos[i].y = defenderPos[i].y.clamp(
//             center.y - radius,
//             center.y + radius,
//           );
//         }
//
//         // Move ball
//         if (scene % 2 == 0) {
//           ballPos = passerPos + (receiverPos - passerPos) * 0.5;
//         } else {
//           Vector2 passDir = (receiverPos - passerPos)..normalize();
//           ballPos = receiverPos - passDir * 0.015;
//           ballHolder = nextReceiver;
//         }
//       }
//     }
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "4v2 Keep-Away Drill",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createPassingThroughGatesAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     // const int numPlayers = 2; // Defined below
//     const int numGates = 2;
//     const double gateWidth = 0.05;
//     const int numScenes = 7; // Start, P1->G1, G1->P2, P2->G2, G2->P1_End
//
//     final List<PlayerModel> homePlayers = _getHomePlayers(); // Get the list
//     final PlayerModel p1Start = _findPlayer(
//       homePlayers,
//       "CM",
//       8,
//     ); // Find player 1
//     final PlayerModel p2Start = _findPlayer(
//       homePlayers,
//       "ST",
//       9,
//     ); // Find player 2
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//     final EquipmentModel cone = _findEquipment(
//       _getEquipment(),
//       "CONE",
//     ); // Use cones for gates
//
//     // Gate positions (pairs of cones)
//     Vector2 gate1LeftPos = Vector2(0.3, 0.4);
//     Vector2 gate1RightPos = Vector2(0.3, 0.4 + gateWidth);
//     Vector2 gate2LeftPos = Vector2(0.6, 0.6);
//     Vector2 gate2RightPos = Vector2(0.6, 0.6 + gateWidth);
//
//     List<EquipmentModel> gateCones = [
//       cone.copyWith(id: RandomGenerator.generateId(), offset: gate1LeftPos),
//       cone.copyWith(id: RandomGenerator.generateId(), offset: gate1RightPos),
//       cone.copyWith(id: RandomGenerator.generateId(), offset: gate2LeftPos),
//       cone.copyWith(id: RandomGenerator.generateId(), offset: gate2RightPos),
//     ];
//
//     // Player start/end positions
//     Vector2 p1StartPos = Vector2(0.15, 0.4 + gateWidth / 2);
//     Vector2 p2StartPos = Vector2(0.45, 0.7);
//     Vector2 p1EndPos = Vector2(0.75, 0.6 + gateWidth / 2);
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 p1Pos = p1StartPos.clone();
//     Vector2 p2Pos = p2StartPos.clone();
//     Vector2 ballPos = p1Pos + Vector2(0.01, 0);
//
//     // Scene 0: Start
//     sceneComponentsList.add([
//       p1Start.copyWith(offset: p1Pos),
//       p2Start.copyWith(offset: p2Pos),
//       ball.copyWith(offset: ballPos),
//       ...gateCones.map((c) => c.clone()),
//     ]);
//
//     // Scene 1: P1 passes through Gate 1 (ball halfway)
//     Vector2 gate1Mid = (gate1LeftPos + gate1RightPos) / 2;
//     ballPos = p1Pos + (gate1Mid - p1Pos) * 0.5;
//     sceneComponentsList.add([
//       p1Start.copyWith(offset: p1Pos),
//       p2Start.copyWith(offset: p2Pos),
//       ball.copyWith(offset: ballPos),
//       ...gateCones.map((c) => c.clone()),
//     ]);
//
//     // Scene 2: Ball passes Gate 1, heading to P2
//     ballPos = gate1Mid + (p2Pos - gate1Mid) * 0.5;
//     sceneComponentsList.add([
//       p1Start.copyWith(offset: p1Pos),
//       p2Start.copyWith(offset: p2Pos),
//       ball.copyWith(offset: ballPos),
//       ...gateCones.map((c) => c.clone()),
//     ]);
//
//     // Scene 3: P2 receives
//     ballPos = p2Pos + Vector2(-0.01, 0.01);
//     sceneComponentsList.add([
//       p1Start.copyWith(offset: p1Pos),
//       p2Start.copyWith(offset: p2Pos),
//       ball.copyWith(offset: ballPos),
//       ...gateCones.map((c) => c.clone()),
//     ]);
//
//     // Scene 4: P2 passes through Gate 2 (ball halfway)
//     Vector2 gate2Mid = (gate2LeftPos + gate2RightPos) / 2;
//     ballPos = p2Pos + (gate2Mid - p2Pos) * 0.5;
//     sceneComponentsList.add([
//       p1Start.copyWith(offset: p1Pos),
//       p2Start.copyWith(offset: p2Pos),
//       ball.copyWith(offset: ballPos),
//       ...gateCones.map((c) => c.clone()),
//     ]);
//
//     // Scene 5: Ball passes Gate 2, heading to P1 end pos
//     p1Pos = p1EndPos.clone(); // P1 moves to end pos
//     ballPos = gate2Mid + (p1EndPos - gate2Mid) * 0.5;
//     sceneComponentsList.add([
//       p1Start.copyWith(offset: p1Pos),
//       p2Start.copyWith(offset: p2Pos),
//       ball.copyWith(offset: ballPos),
//       ...gateCones.map((c) => c.clone()),
//     ]);
//
//     // Scene 6: P1 receives at end
//     ballPos = p1EndPos + Vector2(0.01, 0);
//     sceneComponentsList.add([
//       p1Start.copyWith(offset: p1Pos),
//       p2Start.copyWith(offset: p2Pos),
//       ball.copyWith(offset: ballPos),
//       ...gateCones.map((c) => c.clone()),
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Passing Through Gates",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   // --- 2. Dribbling ---
//
//   static AnimationModel create1v1DribblingBattlesAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes =
//         7; // Start, Att moves, Def reacts, Att moves again, Def reacts, Att gets past, Finish
//
//     final PlayerModel attacker = _findPlayer(_getHomePlayers(), "RW", 7);
//     final PlayerModel defender = _findPlayer(_getAwayPlayers(), "LB", 3);
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//
//     // Initial positions (Attacker on wing, Defender facing)
//     Vector2 attStartPos = Vector2(0.6, 0.85);
//     Vector2 defStartPos = Vector2(0.65, 0.80); // Slightly inside and ahead
//     Vector2 ballStartPos = attStartPos + Vector2(-0.01, -0.01);
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 attPos = attStartPos.clone();
//     Vector2 defPos = defStartPos.clone();
//     Vector2 ballPos = ballStartPos.clone();
//
//     // Scene 0: Start
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//
//     // Scene 1: Attacker dribbles slightly inwards
//     attPos = Vector2(0.65, 0.80);
//     ballPos = attPos + Vector2(0.01, -0.01);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//
//     // Scene 2: Defender adjusts position
//     defPos = Vector2(0.70, 0.75);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//
//     // Scene 3: Attacker feints outside
//     attPos = Vector2(0.70, 0.88);
//     ballPos = attPos + Vector2(0.01, 0.01);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//
//     // Scene 4: Defender reacts slightly
//     defPos = Vector2(0.73, 0.80);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//
//     // Scene 5: Attacker cuts back inside and accelerates past
//     attPos = Vector2(0.80, 0.70);
//     ballPos = attPos + Vector2(0.01, 0.0);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//
//     // Scene 6: Attacker clear
//     attPos = Vector2(0.88, 0.68);
//     ballPos = attPos + Vector2(0.01, 0.0);
//     defPos = Vector2(0.80, 0.75); // Defender left behind
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "1v1 Dribbling Battle",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createZigzagDribbleAnimation() {
//     // Similar to Cone Weaving, but maybe wider turns and fewer cones
//     AnimationModel anim =
//         createConeWeavingDrillAnimation(); // Reuse cone weaving logic
//     // Modify parameters if needed (e.g., fewer cones, wider weaveOffsetY)
//     // For now, just rename it
//     return anim.copyWith(name: "Zigzag Dribble");
//   }
//
//   static AnimationModel createSpeedDribbleAndTurnAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes =
//         5; // Start, Dribble fast, Turn point, Dribble back, Finish
//
//     final PlayerModel player = _findPlayer(
//       _getHomePlayers(),
//       "W",
//       22,
//     ); // Winger
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//     final EquipmentModel cone = _findEquipment(
//       _getEquipment(),
//       "CONE",
//     ); // Turning point marker
//
//     Vector2 startPos = Vector2(0.1, 0.5);
//     Vector2 turnPos = Vector2(0.7, 0.5);
//     Vector2 conePos = turnPos.clone();
//     Vector2 finishPos = startPos.clone();
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 pPos = startPos.clone();
//     Vector2 bPos = startPos + Vector2(0.02, 0); // Ball slightly ahead
//
//     // Scene 0: Start
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       cone.copyWith(offset: conePos),
//     ]);
//
//     // Scene 1: Halfway to turn
//     pPos = startPos + (turnPos - startPos) * 0.5;
//     bPos = pPos + Vector2(0.02, 0);
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       cone.copyWith(offset: conePos),
//     ]);
//
//     // Scene 2: At turn point
//     pPos = turnPos;
//     bPos = pPos + Vector2(0, 0.02); // Ball shifted for turn
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       cone.copyWith(offset: conePos),
//     ]);
//
//     // Scene 3: Halfway back
//     pPos = turnPos + (finishPos - turnPos) * 0.5;
//     bPos = pPos + Vector2(-0.02, 0); // Ball ahead going back
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       cone.copyWith(offset: conePos),
//     ]);
//
//     // Scene 4: Finish
//     pPos = finishPos;
//     bPos = pPos + Vector2(-0.02, 0);
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       cone.copyWith(offset: conePos),
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Speed Dribble & Turn",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createLadderAndBallControlComboAnimation() {
//     // This is complex to animate meaningfully without specific ladder equipment/logic.
//     // Representing as player moving quickly over marks, then controlling ball.
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes = 8;
//     const int ladderSteps = 5;
//     const double ladderStartX = 0.1;
//     const double ladderStep = 0.05;
//     const double ladderY = 0.5;
//
//     final PlayerModel player = _findPlayer(_getHomePlayers(), "CM", 8);
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//
//     // Represent ladder with simple markers (cones)
//     List<EquipmentModel> ladderMarkers = List.generate(
//       ladderSteps + 1,
//       (i) => _findEquipment(_getEquipment(), "CONE").copyWith(
//         id: RandomGenerator.generateId(),
//         offset: Vector2(
//           ladderStartX + i * ladderStep,
//           ladderY + 0.05,
//         ), // Offset slightly
//       ),
//     );
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 pPos = Vector2(ladderStartX - 0.05, ladderY);
//     Vector2 bPos = Vector2(
//       ladderStartX + (ladderSteps + 1) * ladderStep,
//       ladderY,
//     ); // Ball waiting at the end
//
//     // Scene 0: Start before ladder
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...ladderMarkers.map((m) => m.clone()),
//     ]);
//
//     // Scenes 1 to ladderSteps: Player moves through ladder steps
//     for (int i = 0; i < ladderSteps; i++) {
//       pPos = Vector2(ladderStartX + (i + 0.5) * ladderStep, ladderY);
//       sceneComponentsList.add([
//         player.copyWith(offset: pPos),
//         ball.copyWith(offset: bPos),
//         ...ladderMarkers.map((m) => m.clone()),
//       ]);
//     }
//
//     // Scene ladderSteps+1: Player reaches ball
//     pPos = bPos + Vector2(-0.02, 0);
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...ladderMarkers.map((m) => m.clone()),
//     ]);
//
//     // Scene ladderSteps+2: Player controls ball briefly
//     bPos = pPos + Vector2(0.01, 0.01);
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...ladderMarkers.map((m) => m.clone()),
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//       timingMs: 400,
//     ); // Faster steps
//     return AnimationModel(
//       id: animationId,
//       name: "Ladder & Ball Control",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   // --- 3. Shooting & Finishing ---
//
//   static AnimationModel createShootingFromDistanceAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes =
//         5; // Start, Prepare, Shoot (ball mid), Shoot (ball near goal), Finish
//
//     final PlayerModel player = _findPlayer(_getHomePlayers(), "ST", 9);
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//     // Add Goal Post equipment if available
//     final EquipmentModel? goal = _findEquipment(_getEquipment(), "GOAL-POST");
//
//     Vector2 startPos = Vector2(0.65, 0.5); // Outside the box
//     Vector2 ballStartPos = startPos + Vector2(0.02, 0);
//     Vector2 goalPos = Vector2(1.0, 0.5); // Center of goal line
//     Vector2 goalPostPos = Vector2(0.99, 0.5); // Position for goal equipment
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 pPos = startPos.clone();
//     Vector2 bPos = ballStartPos.clone();
//
//     List<FieldItemModel> staticItems = [];
//     if (goal != null) staticItems.add(goal.copyWith(offset: goalPostPos));
//
//     // Scene 0: Start
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 1: Prepare shot (slight backswing/adjustment)
//     pPos = startPos + Vector2(-0.01, 0.01);
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 2: Shoot - Ball halfway
//     bPos = ballStartPos + (goalPos - ballStartPos) * 0.5;
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 3: Shoot - Ball near goal
//     bPos = ballStartPos + (goalPos - ballStartPos) * 0.9;
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 4: Ball at goal
//     bPos = goalPos;
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Shooting from Distance",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createFinishingUnderPressureAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes =
//         7; // Receive, Def closes, Att moves, Def adjusts, Att shoots, Ball travel, Finish
//
//     final PlayerModel attacker = _findPlayer(_getHomePlayers(), "CF", 19);
//     final PlayerModel defender = _findPlayer(_getAwayPlayers(), "CB", 4);
//     final PlayerModel goalkeeper = _findPlayer(
//       _getAwayPlayers(),
//       "GK",
//       1,
//     ); // Use away GK
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//     final EquipmentModel? goal = _findEquipment(_getEquipment(), "GOAL-POST");
//
//     Vector2 attStartPos = Vector2(0.75, 0.6); // Attacker receives
//     Vector2 defStartPos = Vector2(0.70, 0.5); // Defender nearby
//     Vector2 gkStartPos = Vector2(0.95, 0.5); // GK on line
//     Vector2 ballStartPos = attStartPos + Vector2(-0.01, 0);
//     Vector2 goalPos = Vector2(1.0, 0.5);
//     Vector2 goalPostPos = Vector2(0.99, 0.5);
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 attPos = attStartPos.clone();
//     Vector2 defPos = defStartPos.clone();
//     Vector2 gkPos = gkStartPos.clone();
//     Vector2 bPos = ballStartPos.clone();
//     List<FieldItemModel> staticItems = [];
//     if (goal != null) staticItems.add(goal.copyWith(offset: goalPostPos));
//
//     // Scene 0: Attacker receives
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 1: Defender closes down
//     defPos = attStartPos + Vector2(-0.03, -0.03);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 2: Attacker takes touch inside
//     attPos = Vector2(0.78, 0.5);
//     bPos = attPos + Vector2(0.01, 0);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 3: Defender adjusts, GK sets
//     defPos = Vector2(0.75, 0.45);
//     gkPos = Vector2(0.95, 0.48); // GK slightly off center
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 4: Attacker shoots
//     Vector2 shotTarget = Vector2(1.0, 0.6); // Aim for corner
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 5: Ball halfway to goal
//     bPos = attPos + (shotTarget - attPos) * 0.5;
//     gkPos =
//         gkStartPos + (shotTarget - gkStartPos) * 0.3; // GK dives slightly late
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 6: Ball goes in
//     bPos = shotTarget;
//     gkPos = gkStartPos + (shotTarget - gkStartPos) * 0.6; // GK full stretch
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Finishing Under Pressure",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createCrossAndFinishDrillAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes = 8; // Winger runs, crosses, ST moves, finishes
//
//     final PlayerModel winger = _findPlayer(_getHomePlayers(), "RW", 7);
//     final PlayerModel striker = _findPlayer(_getHomePlayers(), "ST", 9);
//     final PlayerModel defender = _findPlayer(
//       _getAwayPlayers(),
//       "CB",
//       4,
//     ); // Optional defender
//     final PlayerModel goalkeeper = _findPlayer(_getAwayPlayers(), "GK", 1);
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//     final EquipmentModel? goal = _findEquipment(_getEquipment(), "GOAL-POST");
//
//     Vector2 wingerStartPos = Vector2(0.65, 0.9);
//     Vector2 strikerStartPos = Vector2(0.70, 0.5);
//     Vector2 defenderStartPos = Vector2(0.75, 0.6); // Near striker
//     Vector2 gkStartPos = Vector2(0.95, 0.5);
//     Vector2 ballStartPos = wingerStartPos + Vector2(-0.01, -0.01);
//     Vector2 goalPos = Vector2(1.0, 0.5);
//     Vector2 goalPostPos = Vector2(0.99, 0.5);
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 wPos = wingerStartPos.clone();
//     Vector2 sPos = strikerStartPos.clone();
//     Vector2 dPos = defenderStartPos.clone();
//     Vector2 gkPos = gkStartPos.clone();
//     Vector2 bPos = ballStartPos.clone();
//     List<FieldItemModel> staticItems = [];
//     if (goal != null) staticItems.add(goal.copyWith(offset: goalPostPos));
//
//     // Scene 0: Start
//     sceneComponentsList.add([
//       winger.copyWith(offset: wPos),
//       striker.copyWith(offset: sPos),
//       defender.copyWith(offset: dPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 1: Winger dribbles down wing
//     wPos = Vector2(0.85, 0.9);
//     bPos = wPos + Vector2(-0.01, -0.01);
//     sceneComponentsList.add([
//       winger.copyWith(offset: wPos),
//       striker.copyWith(offset: sPos),
//       defender.copyWith(offset: dPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 2: Striker starts run, Winger prepares cross
//     sPos = Vector2(0.80, 0.55);
//     dPos = Vector2(0.80, 0.65); // Defender tracks
//     sceneComponentsList.add([
//       winger.copyWith(offset: wPos),
//       striker.copyWith(offset: sPos),
//       defender.copyWith(offset: dPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 3: Winger crosses (ball halfway)
//     Vector2 crossTarget = Vector2(0.90, 0.5); // Target area for striker
//     bPos = wPos + (crossTarget - wPos) * 0.5;
//     sceneComponentsList.add([
//       winger.copyWith(offset: wPos),
//       striker.copyWith(offset: sPos),
//       defender.copyWith(offset: dPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 4: Striker attacks ball, Ball near target
//     sPos = Vector2(0.88, 0.5);
//     dPos = Vector2(0.85, 0.55);
//     gkPos = Vector2(0.95, 0.48); // GK adjusts
//     bPos = wPos + (crossTarget - wPos) * 0.9;
//     sceneComponentsList.add([
//       winger.copyWith(offset: wPos),
//       striker.copyWith(offset: sPos),
//       defender.copyWith(offset: dPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 5: Striker shoots (ball at feet)
//     bPos = sPos + Vector2(0.01, 0);
//     sceneComponentsList.add([
//       winger.copyWith(offset: wPos),
//       striker.copyWith(offset: sPos),
//       defender.copyWith(offset: dPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 6: Ball halfway to goal
//     Vector2 shotTarget = Vector2(1.0, 0.4); // Aim low corner
//     bPos = sPos + (shotTarget - sPos) * 0.5;
//     gkPos = Vector2(0.96, 0.45); // GK dives
//     sceneComponentsList.add([
//       winger.copyWith(offset: wPos),
//       striker.copyWith(offset: sPos),
//       defender.copyWith(offset: dPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 7: Goal!
//     bPos = shotTarget;
//     sceneComponentsList.add([
//       winger.copyWith(offset: wPos),
//       striker.copyWith(offset: sPos),
//       defender.copyWith(offset: dPos),
//       goalkeeper.copyWith(offset: gkPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Cross and Finish Drill",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createTurnAndShootAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes =
//         6; // Receive back to goal, Turn, Shoot, Ball travel x2, Finish
//
//     final PlayerModel player = _findPlayer(_getHomePlayers(), "ST", 9);
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//     final PlayerModel gk = _findPlayer(_getAwayPlayers(), "GK", 1);
//     final EquipmentModel? goal = _findEquipment(_getEquipment(), "GOAL-POST");
//
//     Vector2 startPos = Vector2(0.75, 0.5); // Facing away from goal initially
//     Vector2 ballStartPos =
//         startPos + Vector2(-0.02, 0); // Ball passed from behind
//     Vector2 gkPos = Vector2(0.95, 0.5);
//     Vector2 goalPos = Vector2(1.0, 0.5);
//     Vector2 goalPostPos = Vector2(0.99, 0.5);
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 pPos = startPos.clone();
//     Vector2 bPos = ballStartPos.clone();
//     double pAngle = pi; // Start facing away (180 degrees)
//     List<FieldItemModel> staticItems = [gk.copyWith(offset: gkPos)];
//     if (goal != null) staticItems.add(goal.copyWith(offset: goalPostPos));
//
//     // Scene 0: Receive back to goal
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos, angle: pAngle),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 1: Controls and starts turn
//     pAngle = pi * 0.5; // Turning 90 degrees
//     bPos = pPos + Vector2(0, 0.02); // Ball controlled to the side
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos, angle: pAngle),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 2: Completes turn, prepares shot
//     pAngle = 0; // Facing goal
//     pPos = startPos + Vector2(0.01, 0.01); // Slight adjustment
//     bPos = pPos + Vector2(0.02, 0); // Ball ready to shoot
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos, angle: pAngle),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 3: Shoots - ball halfway
//     Vector2 shotTarget = Vector2(1.0, 0.6); // Aim corner
//     bPos = pPos + (shotTarget - pPos) * 0.5;
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos, angle: pAngle),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 4: Ball near goal
//     bPos = pPos + (shotTarget - pPos) * 0.9;
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos, angle: pAngle),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 5: Goal
//     bPos = shotTarget;
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos, angle: pAngle),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Turn and Shoot Drill",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createTwoTouchFinishingAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes =
//         6; // Pass arrives, Control touch, Shoot, Ball travel x2, Finish
//
//     final PlayerModel player = _findPlayer(_getHomePlayers(), "CF", 19);
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//     final PlayerModel gk = _findPlayer(_getAwayPlayers(), "GK", 1);
//     final EquipmentModel? goal = _findEquipment(_getEquipment(), "GOAL-POST");
//
//     Vector2 startPos = Vector2(0.70, 0.4); // Start position
//     Vector2 passOrigin = Vector2(0.55, 0.3); // Where pass comes from
//     Vector2 ballStartPos =
//         passOrigin + (startPos - passOrigin) * 0.5; // Ball arriving
//     Vector2 gkPos = Vector2(0.95, 0.5);
//     Vector2 goalPos = Vector2(1.0, 0.5);
//     Vector2 goalPostPos = Vector2(0.99, 0.5);
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 pPos = startPos.clone();
//     Vector2 bPos = ballStartPos.clone();
//     List<FieldItemModel> staticItems = [gk.copyWith(offset: gkPos)];
//     if (goal != null) staticItems.add(goal.copyWith(offset: goalPostPos));
//
//     // Scene 0: Ball Arriving
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 1: Control Touch
//     bPos = pPos + Vector2(0.03, 0.01); // Touch slightly forward and side
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 2: Prepare Shot
//     pPos = pPos + Vector2(0.01, 0); // Small step
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 3: Shoot - Ball halfway
//     Vector2 shotTarget = Vector2(1.0, 0.55); // Aim corner
//     bPos = bPos + (shotTarget - bPos) * 0.5; // Shoot from controlled position
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 4: Ball near goal
//     bPos =
//         bPos +
//         (shotTarget - bPos) * 0.8; // Near goal (relative to previous pos)
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//     // Scene 5: Goal
//     bPos = shotTarget;
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ball.copyWith(offset: bPos),
//       ...staticItems,
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Two-Touch Finishing",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   // --- 4. Defending ---
//   static AnimationModel create1v1DefendingDrillAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes = 7;
//
//     final PlayerModel attacker = _findPlayer(
//       _getHomePlayers(),
//       "W",
//       22,
//     ); // Winger
//     final PlayerModel defender = _findPlayer(
//       _getAwayPlayers(),
//       "RB",
//       2,
//     ); // Fullback
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//
//     Vector2 attStartPos = Vector2(0.6, 0.15); // Attacker starts wide
//     Vector2 defStartPos = Vector2(0.65, 0.20); // Defender slightly inside
//     Vector2 ballStartPos = attStartPos + Vector2(0.01, 0.01);
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 attPos = attStartPos.clone();
//     Vector2 defPos = defStartPos.clone();
//     Vector2 ballPos = ballStartPos.clone();
//
//     // Scene 0: Start
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//     // Scene 1: Attacker dribbles -> Def jockeys
//     attPos = Vector2(0.7, 0.18);
//     ballPos = attPos + Vector2(0.01, 0.01);
//     defPos = Vector2(0.7, 0.25);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//     // Scene 2: Attacker cuts inside -> Def adjusts
//     attPos = Vector2(0.75, 0.3);
//     ballPos = attPos + Vector2(-0.01, 0.01);
//     defPos = Vector2(0.73, 0.35);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//     // Scene 3: Attacker tries to go outside -> Def shows outside
//     attPos = Vector2(0.78, 0.15);
//     ballPos = attPos + Vector2(0.01, -0.01);
//     defPos = Vector2(0.75, 0.18);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//     // Scene 4: Defender makes tackle attempt
//     defPos = attPos + Vector2(-0.01, 0.01); // Move to tackle
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//     // Scene 5: Tackle successful - Ball loose/with defender
//     ballPos = defPos + Vector2(0.01, -0.01); // Ball near defender
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//     // Scene 6: Defender clears/controls
//     defPos = defPos + Vector2(-0.02, 0); // Defender moves slightly away
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "1v1 Defending Drill",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createPressureCoverBalanceDrillAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes =
//         6; // Ball central, Ball wide, Def shift, Ball central, Def recover, Ball other side, Def shift
//
//     final PlayerModel p1 = _findPlayer(
//       _getAwayPlayers(),
//       "CDM",
//       6,
//     ); // Pressing Mid
//     final PlayerModel p2 = _findPlayer(
//       _getAwayPlayers(),
//       "CB",
//       4,
//     ); // Covering Def
//     final PlayerModel p3 = _findPlayer(
//       _getAwayPlayers(),
//       "CB",
//       5,
//     ); // Balancing Def
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//
//     // Initial positions (defending own goal at X=0)
//     Vector2 p1Start = Vector2(0.4, 0.5); // Pressing player higher
//     Vector2 p2Start = Vector2(0.25, 0.6); // Cover deeper, slightly wider
//     Vector2 p3Start = Vector2(0.25, 0.4); // Balance deeper, slightly wider
//     Vector2 ballStart = Vector2(0.55, 0.5); // Ball central in opponent half
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 p1Pos = p1Start.clone();
//     Vector2 p2Pos = p2Start.clone();
//     Vector2 p3Pos = p3Start.clone();
//     Vector2 bPos = ballStart.clone();
//
//     // Scene 0: Start
//     sceneComponentsList.add([
//       p1.copyWith(offset: p1Pos),
//       p2.copyWith(offset: p2Pos),
//       p3.copyWith(offset: p3Pos),
//       ball.copyWith(offset: bPos),
//     ]);
//     // Scene 1: Ball moves wide right (opponent's left)
//     bPos = Vector2(0.6, 0.2);
//     sceneComponentsList.add([
//       p1.copyWith(offset: p1Pos),
//       p2.copyWith(offset: p2Pos),
//       p3.copyWith(offset: p3Pos),
//       ball.copyWith(offset: bPos),
//     ]);
//     // Scene 2: Def shift - P1 pressure, P3 cover, P2 balance
//     p1Pos = Vector2(0.45, 0.25); // P1 applies pressure
//     p3Pos = Vector2(0.30, 0.30); // P3 provides cover
//     p2Pos = Vector2(0.30, 0.55); // P2 provides balance
//     sceneComponentsList.add([
//       p1.copyWith(offset: p1Pos),
//       p2.copyWith(offset: p2Pos),
//       p3.copyWith(offset: p3Pos),
//       ball.copyWith(offset: bPos),
//     ]);
//     // Scene 3: Ball switched central
//     bPos = Vector2(0.65, 0.5);
//     sceneComponentsList.add([
//       p1.copyWith(offset: p1Pos),
//       p2.copyWith(offset: p2Pos),
//       p3.copyWith(offset: p3Pos),
//       ball.copyWith(offset: bPos),
//     ]);
//     // Scene 4: Def recovers shape
//     p1Pos = Vector2(0.5, 0.5); // P1 recovers centrally
//     p2Pos = Vector2(0.35, 0.6); // P2 recovers position
//     p3Pos = Vector2(0.35, 0.4); // P3 recovers position
//     sceneComponentsList.add([
//       p1.copyWith(offset: p1Pos),
//       p2.copyWith(offset: p2Pos),
//       p3.copyWith(offset: p3Pos),
//       ball.copyWith(offset: bPos),
//     ]);
//     // Scene 5: Ball moves wide left (opponent's right) -> Def shift again (mirror scene 2)
//     bPos = Vector2(0.6, 0.8);
//     p1Pos = Vector2(0.45, 0.75); // P1 pressure
//     p2Pos = Vector2(0.30, 0.70); // P2 cover
//     p3Pos = Vector2(0.30, 0.45); // P3 balance
//     sceneComponentsList.add([
//       p1.copyWith(offset: p1Pos),
//       p2.copyWith(offset: p2Pos),
//       p3.copyWith(offset: p3Pos),
//       ball.copyWith(offset: bPos),
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Pressure, Cover, Balance Drill",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createDefensiveShapeDrillBackFourAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes =
//         5; // Initial Shape, Ball Wide R, Shape Shift R, Ball Wide L, Shape Shift L
//
//     final PlayerModel rb = _findPlayer(_getHomePlayers(), "RB", 2);
//     final PlayerModel rcb = _findPlayer(_getHomePlayers(), "CB", 4);
//     final PlayerModel lcb = _findPlayer(_getHomePlayers(), "CB", 5);
//     final PlayerModel lb = _findPlayer(_getHomePlayers(), "LB", 3);
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//
//     // Initial compact shape in own half
//     Vector2 rbPos1 = Vector2(0.25, 0.75);
//     Vector2 rcbPos1 = Vector2(0.22, 0.60);
//     Vector2 lcbPos1 = Vector2(0.22, 0.40);
//     Vector2 lbPos1 = Vector2(0.25, 0.25);
//     Vector2 ballPos1 = Vector2(0.4, 0.5); // Ball central
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//
//     // Scene 0: Initial Shape
//     sceneComponentsList.add([
//       rb.copyWith(offset: rbPos1),
//       rcb.copyWith(offset: rcbPos1),
//       lcb.copyWith(offset: lcbPos1),
//       lb.copyWith(offset: lbPos1),
//       ball.copyWith(offset: ballPos1),
//     ]);
//
//     // Scene 1: Ball moves wide right (opponent's left)
//     Vector2 ballPos2 = Vector2(0.45, 0.85);
//     sceneComponentsList.add([
//       rb.copyWith(offset: rbPos1),
//       rcb.copyWith(offset: rcbPos1),
//       lcb.copyWith(offset: lcbPos1),
//       lb.copyWith(offset: lbPos1),
//       ball.copyWith(offset: ballPos2),
//     ]);
//
//     // Scene 2: Shape shifts right
//     Vector2 rbPos2 = Vector2(0.30, 0.85); // RB steps out
//     Vector2 rcbPos2 = Vector2(0.26, 0.70); // RCB covers
//     Vector2 lcbPos2 = Vector2(0.24, 0.50); // LCB shifts across
//     Vector2 lbPos2 = Vector2(0.28, 0.30); // LB tucks in
//     sceneComponentsList.add([
//       rb.copyWith(offset: rbPos2),
//       rcb.copyWith(offset: rcbPos2),
//       lcb.copyWith(offset: lcbPos2),
//       lb.copyWith(offset: lbPos2),
//       ball.copyWith(offset: ballPos2),
//     ]);
//
//     // Scene 3: Ball switched wide left
//     Vector2 ballPos3 = Vector2(0.45, 0.15);
//     sceneComponentsList.add([
//       rb.copyWith(offset: rbPos2),
//       rcb.copyWith(offset: rcbPos2),
//       lcb.copyWith(offset: lcbPos2),
//       lb.copyWith(offset: lbPos2),
//       ball.copyWith(offset: ballPos3),
//     ]);
//
//     // Scene 4: Shape shifts left
//     Vector2 rbPos3 = Vector2(0.28, 0.70); // RB tucks in
//     Vector2 rcbPos3 = Vector2(0.24, 0.50); // RCB shifts across
//     Vector2 lcbPos3 = Vector2(0.26, 0.30); // LCB covers
//     Vector2 lbPos3 = Vector2(0.30, 0.15); // LB steps out
//     sceneComponentsList.add([
//       rb.copyWith(offset: rbPos3),
//       rcb.copyWith(offset: rcbPos3),
//       lcb.copyWith(offset: lcbPos3),
//       lb.copyWith(offset: lbPos3),
//       ball.copyWith(offset: ballPos3),
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Defensive Shape Drill (Back Four)",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createTackleAndRecoverAnimation() {
//     // Similar to 1v1 Defending, but emphasize the recovery run after tackle
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes = 8; // Add recovery scene
//
//     final PlayerModel attacker = _findPlayer(_getHomePlayers(), "W", 22);
//     final PlayerModel defender = _findPlayer(_getAwayPlayers(), "RB", 2);
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//
//     Vector2 attStartPos = Vector2(0.6, 0.15);
//     Vector2 defStartPos = Vector2(0.65, 0.20);
//     Vector2 ballStartPos = attStartPos + Vector2(0.01, 0.01);
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 attPos = attStartPos.clone();
//     Vector2 defPos = defStartPos.clone();
//     Vector2 ballPos = ballStartPos.clone();
//
//     // Reuse scenes 0-5 from 1v1 Defending (up to tackle success)
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]); // S0
//     attPos = Vector2(0.7, 0.18);
//     ballPos = attPos + Vector2(0.01, 0.01);
//     defPos = Vector2(0.7, 0.25);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]); // S1
//     attPos = Vector2(0.75, 0.3);
//     ballPos = attPos + Vector2(-0.01, 0.01);
//     defPos = Vector2(0.73, 0.35);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]); // S2
//     attPos = Vector2(0.78, 0.15);
//     ballPos = attPos + Vector2(0.01, -0.01);
//     defPos = Vector2(0.75, 0.18);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]); // S3
//     defPos = attPos + Vector2(-0.01, 0.01);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]); // S4: Tackle attempt
//     ballPos = defPos + Vector2(0.01, -0.01);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]); // S5: Tackle success
//
//     // Scene 6: Defender starts recovery dribble/pass
//     defPos = defPos + Vector2(-0.05, 0.05); // Move back diagonally
//     ballPos = defPos + Vector2(-0.01, 0.01); // Ball controlled
//     attPos = attPos + Vector2(0.02, 0); // Attacker reacts slowly
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//     // Scene 7: Defender further recovered
//     defPos = defPos + Vector2(-0.05, 0.05);
//     ballPos = defPos + Vector2(-0.01, 0.01);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//       ball.copyWith(offset: ballPos),
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Tackle and Recover Drill",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createShadowMarkingAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes = 7; // Attacker moves, Defender mirrors
//
//     final PlayerModel attacker = _findPlayer(_getHomePlayers(), "ST", 9);
//     final PlayerModel defender = _findPlayer(_getAwayPlayers(), "CB", 4);
//
//     Vector2 attStartPos = Vector2(0.6, 0.5);
//     Vector2 defStartPos = Vector2(0.55, 0.5); // Start close
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 attPos = attStartPos.clone();
//     Vector2 defPos = defStartPos.clone();
//
//     // Scene 0: Start
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//     ]);
//     // Scene 1: Attacker moves right
//     attPos = Vector2(0.65, 0.6);
//     defPos = Vector2(0.60, 0.6);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//     ]);
//     // Scene 2: Attacker moves left
//     attPos = Vector2(0.60, 0.4);
//     defPos = Vector2(0.55, 0.4);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//     ]);
//     // Scene 3: Attacker drops deep
//     attPos = Vector2(0.50, 0.5);
//     defPos = Vector2(0.45, 0.5);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//     ]);
//     // Scene 4: Attacker makes run forward right
//     attPos = Vector2(0.70, 0.7);
//     defPos = Vector2(0.65, 0.7);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//     ]);
//     // Scene 5: Attacker checks back
//     attPos = Vector2(0.65, 0.6);
//     defPos = Vector2(0.60, 0.6);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//     ]);
//     // Scene 6: Attacker moves central
//     attPos = Vector2(0.70, 0.5);
//     defPos = Vector2(0.65, 0.5);
//     sceneComponentsList.add([
//       attacker.copyWith(offset: attPos),
//       defender.copyWith(offset: defPos),
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Shadow Marking Drill",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   // --- 5. Fitness & Agility ---
//   static AnimationModel createBeepTestAnimation() {
//     // Simple representation: Player running back and forth between two lines
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numRuns = 5; // Number of back-and-forth runs to show
//     const int numScenes = numRuns * 2 + 1;
//     final PlayerModel player = _findPlayer(_getHomePlayers(), "CM", 8);
//
//     Vector2 lineA = Vector2(0.1, 0.5);
//     Vector2 lineB = Vector2(0.3, 0.5); // Shorter distance for beep test visual
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 pPos = lineA.clone();
//
//     sceneComponentsList.add([player.copyWith(offset: pPos)]); // Start
//     for (int i = 0; i < numRuns; i++) {
//       pPos =
//           (i % 2 == 0) ? lineB.clone() : lineA.clone(); // Run to opposite line
//       sceneComponentsList.add([player.copyWith(offset: pPos)]);
//       pPos = (i % 2 == 0) ? lineA.clone() : lineB.clone(); // Run back
//       sceneComponentsList.add([player.copyWith(offset: pPos)]);
//     }
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//       timingMs: 400,
//     ); // Faster pace
//     return AnimationModel(
//       id: animationId,
//       name: "Beep Test Simulation",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createSprintLadderDrillsAnimation() {
//     // Similar to Ladder & Ball Control, but without the ball
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int ladderSteps = 6;
//     const double ladderStartX = 0.1;
//     const double ladderStep = 0.06;
//     const double ladderY = 0.5;
//     final int numScenes = ladderSteps + 1;
//
//     final PlayerModel player = _findPlayer(_getHomePlayers(), "W", 22);
//
//     List<EquipmentModel> ladderMarkers = List.generate(
//       ladderSteps + 1,
//       (i) => _findEquipment(_getEquipment(), "CONE").copyWith(
//         id: RandomGenerator.generateId(),
//         offset: Vector2(ladderStartX + i * ladderStep, ladderY + 0.05),
//       ),
//     );
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 pPos = Vector2(ladderStartX - 0.05, ladderY);
//
//     // Scene 0: Start
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ...ladderMarkers.map((m) => m.clone()),
//     ]);
//     // Scenes 1 to ladderSteps: Player moves through ladder steps
//     for (int i = 0; i < ladderSteps; i++) {
//       pPos = Vector2(ladderStartX + (i + 0.5) * ladderStep, ladderY);
//       sceneComponentsList.add([
//         player.copyWith(offset: pPos),
//         ...ladderMarkers.map((m) => m.clone()),
//       ]);
//     }
//     // Scene final: Player finishes past ladder
//     pPos = Vector2(ladderStartX + (ladderSteps + 0.5) * ladderStep, ladderY);
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ...ladderMarkers.map((m) => m.clone()),
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//       timingMs: 300,
//     ); // Even faster
//     return AnimationModel(
//       id: animationId,
//       name: "Sprint Ladder Drill",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createShuttleRunsAnimation() {
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes = 7; // Start, Run1, Back1, Run2, Back2, Run3, Back3
//     final PlayerModel player = _findPlayer(_getHomePlayers(), "CM", 8);
//
//     Vector2 startLine = Vector2(0.1, 0.5);
//     Vector2 line1 = Vector2(0.25, 0.5);
//     Vector2 line2 = Vector2(0.4, 0.5);
//     Vector2 line3 = Vector2(0.55, 0.5); // Furthest line
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 pPos = startLine.clone();
//
//     // Scene 0: Start
//     sceneComponentsList.add([player.copyWith(offset: pPos)]);
//     // Scene 1: Run to Line 1
//     pPos = line1.clone();
//     sceneComponentsList.add([player.copyWith(offset: pPos)]);
//     // Scene 2: Back to Start
//     pPos = startLine.clone();
//     sceneComponentsList.add([player.copyWith(offset: pPos)]);
//     // Scene 3: Run to Line 2
//     pPos = line2.clone();
//     sceneComponentsList.add([player.copyWith(offset: pPos)]);
//     // Scene 4: Back to Start
//     pPos = startLine.clone();
//     sceneComponentsList.add([player.copyWith(offset: pPos)]);
//     // Scene 5: Run to Line 3
//     pPos = line3.clone();
//     sceneComponentsList.add([player.copyWith(offset: pPos)]);
//     // Scene 6: Back to Start
//     pPos = startLine.clone();
//     sceneComponentsList.add([player.copyWith(offset: pPos)]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//       timingMs: 500,
//     ); // Faster timing
//     return AnimationModel(
//       id: animationId,
//       name: "Shuttle Runs (Suicides)",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createAgilityConeDrillsAnimation() {
//     // Example: Simple T-Drill
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes = 7; // Start, ->C1, ->C2, <-C1, ->C3, <-C1, <-Start
//
//     final PlayerModel player = _findPlayer(_getHomePlayers(), "CM", 8);
//     final EquipmentModel cone = _findEquipment(_getEquipment(), "CONE");
//
//     Vector2 coneStart = Vector2(0.1, 0.5);
//     Vector2 coneCenter = Vector2(0.3, 0.5);
//     Vector2 coneLeft = Vector2(0.3, 0.3);
//     Vector2 coneRight = Vector2(0.3, 0.7);
//
//     List<EquipmentModel> cones = [
//       cone.copyWith(id: RandomGenerator.generateId(), offset: coneStart),
//       cone.copyWith(id: RandomGenerator.generateId(), offset: coneCenter),
//       cone.copyWith(id: RandomGenerator.generateId(), offset: coneLeft),
//       cone.copyWith(id: RandomGenerator.generateId(), offset: coneRight),
//     ];
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 pPos = coneStart.clone();
//
//     // Scene 0: Start
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ...cones.map((c) => c.clone()),
//     ]);
//     // Scene 1: Sprint to Center Cone
//     pPos = coneCenter.clone();
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ...cones.map((c) => c.clone()),
//     ]);
//     // Scene 2: Shuffle to Left Cone
//     pPos = coneLeft.clone();
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ...cones.map((c) => c.clone()),
//     ]);
//     // Scene 3: Shuffle to Right Cone
//     pPos = coneRight.clone();
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ...cones.map((c) => c.clone()),
//     ]);
//     // Scene 4: Shuffle back to Center Cone
//     pPos = coneCenter.clone();
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ...cones.map((c) => c.clone()),
//     ]);
//     // Scene 5: Backpedal/Turn to Start Cone
//     pPos = coneStart.clone();
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ...cones.map((c) => c.clone()),
//     ]);
//     // Scene 6: Slight pause at start
//     sceneComponentsList.add([
//       player.copyWith(offset: pPos),
//       ...cones.map((c) => c.clone()),
//     ]);
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//       timingMs: 500,
//     );
//     return AnimationModel(
//       id: animationId,
//       name: "Agility Cone Drill (T-Drill)",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static AnimationModel createResistanceBandSprintTrainingAnimation() {
//     // Simple representation: Player sprints forward with implied resistance
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//     const int numScenes = 5; // Start, Sprinting x 4
//
//     final PlayerModel player = _findPlayer(_getHomePlayers(), "ST", 9);
//
//     Vector2 startPos = Vector2(0.1, 0.5);
//     Vector2 endPos = Vector2(0.4, 0.5); // Short sprint distance
//
//     List<List<FieldItemModel>> sceneComponentsList = [];
//     Vector2 pPos = startPos.clone();
//
//     sceneComponentsList.add([player.copyWith(offset: pPos)]); // Start
//     for (int i = 1; i < numScenes; i++) {
//       double progress = i / (numScenes - 1.0);
//       pPos = startPos + (endPos - startPos) * progress;
//       sceneComponentsList.add([player.copyWith(offset: pPos)]);
//     }
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes(
//       sceneComponentsList,
//       now,
//       timingMs: 300,
//     ); // Fast
//     return AnimationModel(
//       id: animationId,
//       name: "Resistance Band Sprint",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   // --- 6. Tactical/Team Play ---
//   static AnimationModel create11v11MatchSimulationAnimation() {
//     // Very complex - show a simple kickoff setup
//     final String animationId = RandomGenerator.generateId();
//     final DateTime now = DateTime.now();
//
//     // Use the kick-off positions from PlayerUtilsV2
//     final TeamFormationConfig? homeConfig = PlayerUtilsV2.getAllConfigurations(
//       playerType: PlayerType.HOME,
//     ).firstWhere((c) => c.numberOfPlayers == 11);
//     final TeamFormationConfig? awayConfig = PlayerUtilsV2.getAllConfigurations(
//       playerType: PlayerType.AWAY,
//     ).firstWhere((c) => c.numberOfPlayers == 11);
//
//     if (homeConfig == null || awayConfig == null)
//       return _createErrorAnimation("11v11 Sim");
//
//     final LineupDetails homeLineup =
//         homeConfig.availableLineups.first; // Default lineup
//     final LineupDetails awayLineup =
//         awayConfig.availableLineups.first; // Default lineup
//
//     final List<PlayerModel> homePlayersFull = _getHomePlayers();
//     final List<PlayerModel> awayPlayersFull = _getAwayPlayers();
//
//     List<FieldItemModel> scene1Components = [];
//
//     // Add home players based on lineup
//     for (var slot in homeLineup.playerSlots) {
//       final player = homePlayersFull.firstWhere(
//         (p) => p.id == slot.designatedPlayerId,
//         orElse: () => _findPlayer(homePlayersFull, slot.roleInFormation),
//       );
//       scene1Components.add(player.copyWith(offset: slot.relativePosition));
//     }
//     // Add away players based on lineup
//     for (var slot in awayLineup.playerSlots) {
//       final player = awayPlayersFull.firstWhere(
//         (p) => p.id == slot.designatedPlayerId,
//         orElse: () => _findPlayer(awayPlayersFull, slot.roleInFormation),
//       );
//       // Note: _awayConfigurations should already contain processed positions
//       scene1Components.add(player.copyWith(offset: slot.relativePosition));
//     }
//
//     // Add ball at center
//     final EquipmentModel ball = _findEquipment(_getEquipment(), "BALL");
//     scene1Components.add(ball.copyWith(offset: Vector2(0.5, 0.5)));
//
//     final List<AnimationItemModel> scenes = _createAnimationScenes([
//       scene1Components,
//     ], now); // Just one scene for setup
//     return AnimationModel(
//       id: animationId,
//       name: "11v11 Match Simulation (Kickoff)",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: scenes,
//       createdAt: now,
//       updatedAt: now,
//     );
//   }
//
//   static List<AnimationItemModel> _createAnimationScenes(
//     List<List<FieldItemModel>> sceneComponentsList,
//     DateTime startTime, {
//     int timingMs = _defaultTimingMs,
//   }) {
//     return List.generate(sceneComponentsList.length, (index) {
//       return AnimationItemModel(
//         id: RandomGenerator.generateId(),
//         components: sceneComponentsList[index],
//         fieldColor: _defaultFieldColor,
//         createdAt: startTime.add(
//           Duration(milliseconds: (index * timingMs).round()),
//         ),
//         updatedAt: startTime.add(
//           Duration(milliseconds: (index * timingMs).round()),
//         ),
//         userId: _defaultUserId,
//         fieldSize: _defaultFieldSize.clone(),
//       );
//     });
//   }
//
//   static AnimationModel _createErrorAnimation(String drillName) {
//     print(
//       "Error: Could not create '$drillName' animation due to missing assets.",
//     );
//     return AnimationModel(
//       id: RandomGenerator.generateId(),
//       name: "Error: $drillName Setup",
//       userId: _defaultUserId,
//       fieldColor: _defaultFieldColor,
//       animationScenes: [],
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );
//   }
//
//   static List<AnimationModel> getAllDefaultAnimations() {
//     List<AnimationModel> animations = [];
//     try {
//       animations.add(createDefaultTrianglePassAndShotAnimation());
//     } catch (e) {
//       print("Error creating TrianglePassAndShot: $e");
//       animations.add(_createErrorAnimation("Triangle Pass Shot"));
//     }
//     try {
//       animations.add(createRondoDrillAnimation());
//     } catch (e) {
//       print("Error creating Rondo: $e");
//       animations.add(_createErrorAnimation("Rondo"));
//     }
//     try {
//       animations.add(createConeWeavingDrillAnimation());
//     } catch (e) {
//       print("Error creating ConeWeaving: $e");
//       animations.add(_createErrorAnimation("Cone Weaving"));
//     }
//     try {
//       animations.add(createOneTouchPassingCircuitAnimation());
//     } catch (e) {
//       print("Error creating OneTouchPassing: $e");
//       animations.add(_createErrorAnimation("One Touch Passing"));
//     }
//     try {
//       animations.add(createTrianglePassingDrillAnimation());
//     } catch (e) {
//       print("Error creating TrianglePassing: $e");
//       animations.add(_createErrorAnimation("Triangle Passing"));
//     }
//     try {
//       animations.add(create4v2KeepAwayDrillAnimation());
//     } catch (e) {
//       print("Error creating 4v2KeepAway: $e");
//       animations.add(_createErrorAnimation("4v2 Keep Away"));
//     }
//     try {
//       animations.add(createPassingThroughGatesAnimation());
//     } catch (e) {
//       print("Error creating PassingGates: $e");
//       animations.add(_createErrorAnimation("Passing Gates"));
//     }
//     try {
//       animations.add(create1v1DribblingBattlesAnimation());
//     } catch (e) {
//       print("Error creating 1v1Dribbling: $e");
//       animations.add(_createErrorAnimation("1v1 Dribbling"));
//     }
//     try {
//       animations.add(createZigzagDribbleAnimation());
//     } catch (e) {
//       print("Error creating ZigzagDribble: $e");
//       animations.add(_createErrorAnimation("Zigzag Dribble"));
//     }
//     try {
//       animations.add(createSpeedDribbleAndTurnAnimation());
//     } catch (e) {
//       print("Error creating SpeedDribble: $e");
//       animations.add(_createErrorAnimation("Speed Dribble"));
//     }
//     try {
//       animations.add(createLadderAndBallControlComboAnimation());
//     } catch (e) {
//       print("Error creating LadderCombo: $e");
//       animations.add(_createErrorAnimation("Ladder Combo"));
//     }
//     try {
//       animations.add(createShootingFromDistanceAnimation());
//     } catch (e) {
//       print("Error creating ShootingDistance: $e");
//       animations.add(_createErrorAnimation("Shooting Distance"));
//     }
//     try {
//       animations.add(createFinishingUnderPressureAnimation());
//     } catch (e) {
//       print("Error creating FinishingPressure: $e");
//       animations.add(_createErrorAnimation("Finishing Pressure"));
//     }
//     try {
//       animations.add(createCrossAndFinishDrillAnimation());
//     } catch (e) {
//       print("Error creating CrossFinish: $e");
//       animations.add(_createErrorAnimation("Cross and Finish"));
//     }
//     try {
//       animations.add(createTurnAndShootAnimation());
//     } catch (e) {
//       print("Error creating TurnShoot: $e");
//       animations.add(_createErrorAnimation("Turn and Shoot"));
//     }
//     try {
//       animations.add(createTwoTouchFinishingAnimation());
//     } catch (e) {
//       print("Error creating TwoTouchFinish: $e");
//       animations.add(_createErrorAnimation("Two Touch Finish"));
//     }
//     try {
//       animations.add(create1v1DefendingDrillAnimation());
//     } catch (e) {
//       print("Error creating 1v1Defending: $e");
//       animations.add(_createErrorAnimation("1v1 Defending"));
//     }
//     try {
//       animations.add(createPressureCoverBalanceDrillAnimation());
//     } catch (e) {
//       print("Error creating PressureCover: $e");
//       animations.add(_createErrorAnimation("Pressure Cover Balance"));
//     }
//     try {
//       animations.add(createDefensiveShapeDrillBackFourAnimation());
//     } catch (e) {
//       print("Error creating DefShape: $e");
//       animations.add(_createErrorAnimation("Defensive Shape"));
//     }
//     try {
//       animations.add(createTackleAndRecoverAnimation());
//     } catch (e) {
//       print("Error creating TackleRecover: $e");
//       animations.add(_createErrorAnimation("Tackle Recover"));
//     }
//     try {
//       animations.add(createShadowMarkingAnimation());
//     } catch (e) {
//       print("Error creating ShadowMarking: $e");
//       animations.add(_createErrorAnimation("Shadow Marking"));
//     }
//     try {
//       animations.add(createBeepTestAnimation());
//     } catch (e) {
//       print("Error creating BeepTest: $e");
//       animations.add(_createErrorAnimation("Beep Test"));
//     }
//     try {
//       animations.add(createSprintLadderDrillsAnimation());
//     } catch (e) {
//       print("Error creating SprintLadder: $e");
//       animations.add(_createErrorAnimation("Sprint Ladder"));
//     }
//     try {
//       animations.add(createShuttleRunsAnimation());
//     } catch (e) {
//       print("Error creating ShuttleRuns: $e");
//       animations.add(_createErrorAnimation("Shuttle Runs"));
//     }
//     try {
//       animations.add(createAgilityConeDrillsAnimation());
//     } catch (e) {
//       print("Error creating AgilityCones: $e");
//       animations.add(_createErrorAnimation("Agility Cones"));
//     }
//     try {
//       animations.add(createResistanceBandSprintTrainingAnimation());
//     } catch (e) {
//       print("Error creating ResistanceSprint: $e");
//       animations.add(_createErrorAnimation("Resistance Sprint"));
//     }
//     try {
//       animations.add(create11v11MatchSimulationAnimation());
//     } catch (e) {
//       print("Error creating 11v11Sim: $e");
//       animations.add(_createErrorAnimation("11v11 Sim"));
//     }
//
//     return animations;
//   }
// }
