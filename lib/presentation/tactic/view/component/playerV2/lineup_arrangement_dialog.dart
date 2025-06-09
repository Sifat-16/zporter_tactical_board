// import 'dart:math' as math;
//
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
//
// //==============================================================================
// // Main Dialog Widget
// //==============================================================================
//
// class LineupArrangementDialog extends StatefulWidget {
//   /// The list of positions to be filled on the field. Each model contains the
//   /// target offset, role, and jersey number.
//   final List<PlayerModel> targetPositions;
//
//   /// The full list of players available for assignment (the coach's roster for the team).
//   final List<PlayerModel> coachsRoster;
//
//   /// A pre-computed map of initial assignments, linking a target position's ID
//   /// to an already matched player from the roster.
//   final Map<String, PlayerModel?> initialAssignments;
//
//   const LineupArrangementDialog({
//     super.key,
//     required this.targetPositions,
//     required this.coachsRoster,
//     required this.initialAssignments,
//   });
//
//   @override
//   State<LineupArrangementDialog> createState() =>
//       _LineupArrangementDialogState();
// }
//
// class _LineupArrangementDialogState extends State<LineupArrangementDialog> {
//   // The state of assignments, initialized from the widget.
//   late final Map<String, PlayerModel?> _assignments;
//
//   @override
//   void initState() {
//     super.initState();
//     // The dialog's state is a direct copy of the initial assignments passed in.
//     // This makes the dialog stateless regarding the logic of how assignments are made.
//     _assignments = Map.from(widget.initialAssignments);
//   }
//
//   /// A getter that checks if every position on the field has a player assigned.
//   /// The "Apply" button is enabled based on this.
//   bool get _allPositionsFilled => !_assignments.containsValue(null);
//
//   /// Handles tapping a position on the field to assign or change a player.
//   Future<void> _pickPlayerForPosition(String targetPositionId) async {
//     final currentlyAssignedPlayer = _assignments[targetPositionId];
//
//     // Create a list of choices for the popup dialog:
//     // It includes all unassigned players PLUS the player currently in this spot (if any).
//     final Set<String> assignedIds = _assignments.values
//         .where((p) => p != null && p.id != currentlyAssignedPlayer?.id)
//         .map((p) => p!.id)
//         .toSet();
//
//     final List<PlayerModel> availableChoices =
//         widget.coachsRoster.where((p) => !assignedIds.contains(p.id)).toList();
//
//     // Show a simple dialog to pick a player.
//     final PlayerModel? selectedPlayer = await showDialog<PlayerModel>(
//       context: context,
//       builder: (context) {
//         return SimpleDialog(
//           title: const Text('Assign Player to Position'),
//           backgroundColor: ColorManager.dark2,
//           titleTextStyle: TextStyle(color: ColorManager.white, fontSize: 18),
//           children: availableChoices.isEmpty
//               ? [
//                   Padding(
//                     padding: const EdgeInsets.all(24.0),
//                     child: Text("No available players to assign.",
//                         style: TextStyle(color: ColorManager.white)),
//                   )
//                 ]
//               : availableChoices.map((player) {
//                   return SimpleDialogOption(
//                     onPressed: () => Navigator.pop(context, player),
//                     child: Text(
//                       '#${player.jerseyNumber} - ${player.name ?? player.role}',
//                       style: TextStyle(
//                         color: player.id == currentlyAssignedPlayer?.id
//                             ? ColorManager
//                                 .yellow // Highlight the current player
//                             : ColorManager.white,
//                         fontWeight: player.id == currentlyAssignedPlayer?.id
//                             ? FontWeight.bold
//                             : FontWeight.normal,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//         );
//       },
//     );
//
//     // If the user selected a player, update the state.
//     if (selectedPlayer != null) {
//       setState(() {
//         // If the selected player was already in another spot, that spot becomes vacant.
//         _assignments.updateAll(
//             (key, value) => value?.id == selectedPlayer.id ? null : value);
//
//         // Assign the newly selected player to the tapped position.
//         _assignments[targetPositionId] = selectedPlayer;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: ColorManager.dark1,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Column(
//               children: [
//                 Text(
//                   'Arrange Lineup',
//                   style: Theme.of(context)
//                       .textTheme
//                       .headlineSmall
//                       ?.copyWith(color: ColorManager.white),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Tap a position to assign a player from your roster.',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyMedium
//                       ?.copyWith(color: ColorManager.white.withOpacity(0.8)),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: AspectRatio(
//                 aspectRatio: 68 / 105,
//                 child: LayoutBuilder(builder: (context, constraints) {
//                   return Stack(
//                     children: [
//                       CustomPaint(
//                         size: Size.infinite,
//                         painter: FullFieldPainter(
//                           fieldColor: ColorManager.grey.withOpacity(0.4),
//                           borderColor: Colors.white.withOpacity(0.6),
//                         ),
//                       ),
//                       // The build now iterates over the generic `targetPositions`.
//                       ...widget.targetPositions.map(
//                         (targetPos) => _buildPlayerMarker(
//                           targetPos, // The model defining the position and target role/number
//                           _assignments[
//                               targetPos.id], // The currently assigned player
//                           constraints,
//                         ),
//                       ),
//                     ],
//                   );
//                 }),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 CustomButton(
//                   onTap: () => Navigator.of(context).pop(null),
//                   fillColor: ColorManager.dark2,
//                   child: Text("Cancel",
//                       style: TextStyle(color: ColorManager.white)),
//                 ),
//                 const SizedBox(width: 8),
//                 CustomButton(
//                   onTap: _allPositionsFilled
//                       ? () {
//                           final List<PlayerModel> finalLineup = [];
//                           _assignments
//                               .forEach((targetPositionId, assignedPlayer) {
//                             // Find the original target position to get the correct offset.
//                             final targetPos = widget.targetPositions
//                                 .firstWhere((p) => p.id == targetPositionId);
//                             // Combine the assigned player's data with the target's position.
//                             finalLineup.add(assignedPlayer!
//                                 .copyWith(offset: targetPos.offset));
//                           });
//                           Navigator.of(context).pop(finalLineup);
//                         }
//                       : null,
//                   fillColor: _allPositionsFilled
//                       ? ColorManager.blue
//                       : ColorManager.grey,
//                   child: Text("Apply",
//                       style: TextStyle(color: ColorManager.white)),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   /// Builds a single player marker widget. It now takes a generic `targetPosition`.
//   Widget _buildPlayerMarker(PlayerModel targetPosition,
//       PlayerModel? assignedPlayer, BoxConstraints constraints) {
//     const double markerSize = 40.0;
//     // The position is determined by the targetPosition model's offset.
//     final double left =
//         (targetPosition.offset?.x ?? 0.5) * constraints.maxWidth -
//             (markerSize / 2);
//     final double top =
//         (targetPosition.offset?.y ?? 0.5) * constraints.maxHeight -
//             (markerSize / 2);
//
//     return Positioned(
//       left: left,
//       top: top,
//       child: GestureDetector(
//         onTap: () => _pickPlayerForPosition(targetPosition.id),
//         child: Tooltip(
//           message: assignedPlayer != null
//               ? '#${assignedPlayer.jerseyNumber} ${assignedPlayer.name ?? assignedPlayer.role}'
//               // The placeholder shows the role from the `targetPosition` model.
//               : 'Unassigned (${targetPosition.role})',
//           child: (assignedPlayer != null)
//               // If a player is assigned, show their normal component.
//               ? PlayerComponentV2(
//                   playerModel: assignedPlayer,
//                 )
//               // If the spot is EMPTY (unassigned), show the placeholder.
//               : Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Show the "ghost" of the target player.
//                     Opacity(
//                       opacity: 0.4,
//                       child: PlayerComponentV2(
//                         playerModel: targetPosition,
//                       ),
//                     ),
//                     // Overlay a "missing" icon.
//                     Container(
//                       width: markerSize * 0.6,
//                       height: markerSize * 0.6,
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.6),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.question_mark,
//                         color: Colors.white,
//                         size: markerSize * 0.4,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }
//
// //==============================================================================
// // Full Field Painter
// //==============================================================================
// class FullFieldPainter extends CustomPainter {
//   final Color fieldColor;
//   final Color borderColor;
//
//   FullFieldPainter({
//     required this.fieldColor,
//     required this.borderColor,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final fieldPaint = Paint()..color = fieldColor;
//     final borderPaint = Paint()
//       ..color = borderColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = math.max(1.0, size.shortestSide * 0.008);
//     final spotPaint = Paint()
//       ..color = borderColor
//       ..style = PaintingStyle.fill;
//
//     // Dimensions relative to the full canvas size
//     final double centerCircleRadius = size.width * 0.12;
//     final double penaltyBoxWidth = size.width * 0.18;
//     final double penaltyBoxHeight = size.height * 0.4;
//     final double goalBoxWidth = size.width * 0.08;
//     final double goalBoxHeight = size.height * 0.18;
//     final double penaltySpotRadius = math.max(1.5, size.shortestSide * 0.01);
//     final Offset center = size.center(Offset.zero);
//     final double penaltyDistX = size.width * 0.11;
//
//     // Field and border
//     canvas.drawRect(Offset.zero & size, fieldPaint);
//     canvas.drawRect(Offset.zero & size, borderPaint);
//
//     // Center line and circle
//     canvas.drawLine(
//         Offset(center.dx, 0), Offset(center.dx, size.height), borderPaint);
//     canvas.drawCircle(center, centerCircleRadius, borderPaint);
//     canvas.drawCircle(center, penaltySpotRadius, spotPaint);
//
//     // Left side markings
//     canvas.drawRect(
//       Rect.fromLTWH(0, center.dy - penaltyBoxHeight / 2, penaltyBoxWidth,
//           penaltyBoxHeight),
//       borderPaint,
//     );
//     canvas.drawRect(
//       Rect.fromLTWH(
//           0, center.dy - goalBoxHeight / 2, goalBoxWidth, goalBoxHeight),
//       borderPaint,
//     );
//     canvas.drawCircle(
//         Offset(penaltyDistX, center.dy), penaltySpotRadius, spotPaint);
//
//     // Right side markings
//     canvas.drawRect(
//       Rect.fromLTWH(size.width - penaltyBoxWidth,
//           center.dy - penaltyBoxHeight / 2, penaltyBoxWidth, penaltyBoxHeight),
//       borderPaint,
//     );
//     canvas.drawRect(
//       Rect.fromLTWH(size.width - goalBoxWidth, center.dy - goalBoxHeight / 2,
//           goalBoxWidth, goalBoxHeight),
//       borderPaint,
//     );
//     canvas.drawCircle(Offset(size.width - penaltyDistX, center.dy),
//         penaltySpotRadius, spotPaint);
//
//     // Penalty Arcs
//     final double penaltyArcRadius = size.width * 0.1;
//     canvas.drawArc(
//         Rect.fromCircle(
//             center: Offset(penaltyDistX, center.dy), radius: penaltyArcRadius),
//         -math.pi / 2.5,
//         math.pi / 1.25,
//         false,
//         borderPaint);
//     canvas.drawArc(
//         Rect.fromCircle(
//             center: Offset(size.width - penaltyDistX, center.dy),
//             radius: penaltyArcRadius),
//         math.pi / 2 - math.pi / 2.5,
//         math.pi / 1.25,
//         false,
//         borderPaint);
//   }
//
//   @override
//   bool shouldRepaint(covariant FullFieldPainter oldDelegate) {
//     return oldDelegate.fieldColor != fieldColor ||
//         oldDelegate.borderColor != borderColor;
//   }
// }

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';

//==============================================================================
// Main Dialog Widget
//==============================================================================

class LineupArrangementDialog extends StatefulWidget {
  /// The list of positions to be filled on the field. Each model contains the
  /// target offset, role, and jersey number.
  final List<PlayerModel> targetPositions;

  /// The full list of players available for assignment (the coach's roster for the team).
  final List<PlayerModel> coachsRoster;

  /// A pre-computed map of initial assignments, linking a target position's ID
  /// to an already matched player from the roster.
  final Map<String, PlayerModel?> initialAssignments;

  const LineupArrangementDialog({
    super.key,
    required this.targetPositions,
    required this.coachsRoster,
    required this.initialAssignments,
  });

  @override
  State<LineupArrangementDialog> createState() =>
      _LineupArrangementDialogState();
}

//==============================================================================
// Full State Implementation
//==============================================================================

class _LineupArrangementDialogState extends State<LineupArrangementDialog> {
  // The state of assignments, initialized from the widget.
  late final Map<String, PlayerModel?> _assignments;

  @override
  void initState() {
    super.initState();
    // The dialog's state is a direct copy of the initial assignments passed in.
    _assignments = Map.from(widget.initialAssignments);
  }

  /// A getter that checks if every position on the field has a player assigned.
  bool get _allPositionsFilled => !_assignments.containsValue(null);

  /// Handles tapping a position on the field to assign or change a player.
  Future<void> _pickPlayerForPosition(String targetPositionId) async {
    final currentlyAssignedPlayer = _assignments[targetPositionId];

    // Create a list of choices for the popup dialog.
    final Set<String> assignedIds = _assignments.values
        .where((p) => p != null && p.id != currentlyAssignedPlayer?.id)
        .map((p) => p!.id)
        .toSet();

    final List<PlayerModel> availableChoices =
        widget.coachsRoster.where((p) => !assignedIds.contains(p.id)).toList();

    // Show a dialog to pick a player, now with images.
    final PlayerModel? selectedPlayer = await showDialog<PlayerModel>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Assign Player to Position'),
          backgroundColor: ColorManager.dark2,
          titleTextStyle: TextStyle(color: ColorManager.white, fontSize: 18),
          children: availableChoices.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text("No available players to assign.",
                        style: TextStyle(color: Colors.white)),
                  )
                ]
              // --- UPDATED UI LOGIC ---
              : availableChoices.map((player) {
                  final bool isCurrentlySelected =
                      player.id == currentlyAssignedPlayer?.id;
                  final imagePath = player.imagePath;
                  final bool hasImage = imagePath != null &&
                      imagePath.isNotEmpty &&
                      File(imagePath).existsSync();

                  return SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, player),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Player name and number (wrapped to prevent overflow)
                        Expanded(
                          child: Text(
                            '#${player.jerseyNumber} - ${player.name ?? player.role}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrentlySelected
                                  ? ColorManager.yellow
                                  : ColorManager.white,
                              fontWeight: isCurrentlySelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Player image avatar
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: ColorManager.dark1,
                          backgroundImage:
                              hasImage ? FileImage(File(imagePath)) : null,
                          child: !hasImage
                              ? Icon(Icons.person,
                                  size: 24,
                                  color: Colors.white.withOpacity(0.6))
                              : null,
                        ),
                      ],
                    ),
                  );
                }).toList(),
        );
      },
    );

    // If the user selected a player, update the state.
    if (selectedPlayer != null) {
      setState(() {
        // If the selected player was already in another spot, that spot becomes vacant.
        _assignments.updateAll(
            (key, value) => value?.id == selectedPlayer.id ? null : value);

        // Assign the newly selected player to the tapped position.
        _assignments[targetPositionId] = selectedPlayer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManager.dark1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Text(
                  'Arrange Lineup',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: ColorManager.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap a position to assign a player from your roster.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: ColorManager.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: AspectRatio(
                aspectRatio: 68 / 105,
                child: LayoutBuilder(builder: (context, constraints) {
                  return Stack(
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: FullFieldPainter(
                          fieldColor: ColorManager.grey.withOpacity(0.4),
                          borderColor: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      // The build now iterates over the generic `targetPositions`.
                      ...widget.targetPositions.map(
                        (targetPos) => _buildPlayerMarker(
                          targetPos, // The model defining the position and target role/number
                          _assignments[
                              targetPos.id], // The currently assigned player
                          constraints,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  onTap: () => Navigator.of(context).pop(null),
                  fillColor: ColorManager.dark2,
                  child: Text("Cancel",
                      style: TextStyle(color: ColorManager.white)),
                ),
                const SizedBox(width: 15),
                CustomButton(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  onTap: _allPositionsFilled
                      ? () {
                          final List<PlayerModel> finalLineup = [];
                          _assignments
                              .forEach((targetPositionId, assignedPlayer) {
                            // Find the original target position to get the correct offset.
                            final targetPos = widget.targetPositions
                                .firstWhere((p) => p.id == targetPositionId);
                            // Combine the assigned player's data with the target's position.
                            finalLineup.add(assignedPlayer!
                                .copyWith(offset: targetPos.offset));
                          });
                          Navigator.of(context).pop(finalLineup);
                        }
                      : null,
                  fillColor: _allPositionsFilled
                      ? ColorManager.blue
                      : ColorManager.grey,
                  child: Text("Apply",
                      style: TextStyle(color: ColorManager.white)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Builds a single player marker widget. It now takes a generic `targetPosition`.
  Widget _buildPlayerMarker(PlayerModel targetPosition,
      PlayerModel? assignedPlayer, BoxConstraints constraints) {
    const double markerSize = 40.0;
    // The position is determined by the targetPosition model's offset.
    final double left =
        (targetPosition.offset?.x ?? 0.5) * constraints.maxWidth -
            (markerSize / 2);
    final double top =
        (targetPosition.offset?.y ?? 0.5) * constraints.maxHeight -
            (markerSize / 2);

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => _pickPlayerForPosition(targetPosition.id),
        child: Tooltip(
          message: assignedPlayer != null
              ? '#${assignedPlayer.jerseyNumber} ${assignedPlayer.name ?? assignedPlayer.role}'
              // The placeholder shows the role from the `targetPosition` model.
              : 'Unassigned (${targetPosition.role})',
          child: (assignedPlayer != null)
              // If a player is assigned, show their normal component.
              ? PlayerComponentV2(
                  playerModel: assignedPlayer,
                )
              // If the spot is EMPTY (unassigned), show the placeholder.
              : Stack(
                  children: [
                    // Show the "ghost" of the target player.
                    Opacity(
                      opacity: 0.4,
                      child: PlayerComponentV2(
                        playerModel: targetPosition,
                      ),
                    ),
                    // Overlay a "missing" icon.
                    Container(
                      width: markerSize * .8,
                      height: markerSize * .8,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.question_mark,
                        color: Colors.white,
                        size: markerSize * 0.4,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

//==============================================================================
// Full Field Painter
//==============================================================================
class FullFieldPainter extends CustomPainter {
  final Color fieldColor;
  final Color borderColor;

  FullFieldPainter({
    required this.fieldColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fieldPaint = Paint()..color = fieldColor;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, size.shortestSide * 0.008);
    final spotPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    // Dimensions relative to the full canvas size
    final double centerCircleRadius = size.width * 0.12;
    final double penaltyBoxWidth = size.width * 0.18;
    final double penaltyBoxHeight = size.height * 0.4;
    final double goalBoxWidth = size.width * 0.08;
    final double goalBoxHeight = size.height * 0.18;
    final double penaltySpotRadius = math.max(1.5, size.shortestSide * 0.01);
    final Offset center = size.center(Offset.zero);
    final double penaltyDistX = size.width * 0.11;

    // Field and border
    canvas.drawRect(Offset.zero & size, fieldPaint);
    canvas.drawRect(Offset.zero & size, borderPaint);

    // Center line and circle
    canvas.drawLine(
        Offset(center.dx, 0), Offset(center.dx, size.height), borderPaint);
    canvas.drawCircle(center, centerCircleRadius, borderPaint);
    canvas.drawCircle(center, penaltySpotRadius, spotPaint);

    // Left side markings
    canvas.drawRect(
      Rect.fromLTWH(0, center.dy - penaltyBoxHeight / 2, penaltyBoxWidth,
          penaltyBoxHeight),
      borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          0, center.dy - goalBoxHeight / 2, goalBoxWidth, goalBoxHeight),
      borderPaint,
    );
    canvas.drawCircle(
        Offset(penaltyDistX, center.dy), penaltySpotRadius, spotPaint);

    // Right side markings
    canvas.drawRect(
      Rect.fromLTWH(size.width - penaltyBoxWidth,
          center.dy - penaltyBoxHeight / 2, penaltyBoxWidth, penaltyBoxHeight),
      borderPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - goalBoxWidth, center.dy - goalBoxHeight / 2,
          goalBoxWidth, goalBoxHeight),
      borderPaint,
    );
    canvas.drawCircle(Offset(size.width - penaltyDistX, center.dy),
        penaltySpotRadius, spotPaint);
  }

  @override
  bool shouldRepaint(covariant FullFieldPainter oldDelegate) {
    return oldDelegate.fieldColor != fieldColor ||
        oldDelegate.borderColor != borderColor;
  }
}
