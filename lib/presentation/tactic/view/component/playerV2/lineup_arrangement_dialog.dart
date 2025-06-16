import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';

class LineupArrangementDialog extends StatefulWidget {
  /// The list of positions to be filled on the field.
  final List<PlayerModel> targetPositions;

  /// The list of players to be arranged (either the full roster or just those on the field).
  final List<PlayerModel> playersToArrange;

  /// The list of players available for substitution (those on the bench).
  final List<PlayerModel> benchPlayers;

  /// A pre-computed map of initial assignments.
  final Map<String, PlayerModel?> initialAssignments;

  const LineupArrangementDialog({
    super.key,
    required this.targetPositions,
    required this.playersToArrange,
    required this.benchPlayers,
    required this.initialAssignments,
  });

  @override
  State<LineupArrangementDialog> createState() =>
      _LineupArrangementDialogState();
}

class _LineupArrangementDialogState extends State<LineupArrangementDialog> {
  late final Map<String, PlayerModel?> _assignments;

  @override
  void initState() {
    super.initState();
    _assignments = Map.from(widget.initialAssignments);
  }

  bool get _allPositionsFilled => !_assignments.containsValue(null);

  Future<void> _pickPlayerForPosition(String targetPositionId) async {
    final currentlyAssignedPlayer = _assignments[targetPositionId];

    // --- MODIFIED: The choice list now includes players to arrange AND bench players for substitution ---
    // Create a combined list of all possible players.
    final List<PlayerModel> allAvailablePlayers = [
      ...widget.playersToArrange,
      ...widget.benchPlayers,
    ];
    // Create a Set of unique players by their ID to handle potential duplicates
    final Map<String, PlayerModel> uniquePlayerMap = {
      for (var p in allAvailablePlayers) p.id: p
    };
    final List<PlayerModel> uniquePlayers = uniquePlayerMap.values.toList();

    // Filter out players who are already assigned to a DIFFERENT position.
    final Set<String> assignedIds = _assignments.values
        .where((p) => p != null && p.id != currentlyAssignedPlayer?.id)
        .map((p) => p!.id)
        .toSet();

    final List<PlayerModel> availableChoices =
        uniquePlayers.where((p) => !assignedIds.contains(p.id)).toList();

    availableChoices.sort((a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));

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
              : availableChoices.map((player) {
                  final bool isCurrentlySelected =
                      player.id == currentlyAssignedPlayer?.id;
                  final imagePath = player.imagePath;
                  final bool hasImage = imagePath != null &&
                      imagePath.isNotEmpty &&
                      File(imagePath).existsSync();

                  // Highlight players from the bench to distinguish them
                  final bool isBenchPlayer =
                      widget.benchPlayers.any((p) => p.id == player.id);

                  return SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, player),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '#${player.jerseyNumber} - ${player.name ?? player.role}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrentlySelected
                                  ? ColorManager.yellow
                                  : isBenchPlayer
                                      ? Colors.lightGreenAccent.withOpacity(0.8)
                                      : ColorManager.white,
                              fontWeight: isCurrentlySelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isBenchPlayer)
                          Text("(Sub) ",
                              style: TextStyle(
                                  color:
                                      Colors.lightGreenAccent.withOpacity(0.6),
                                  fontSize: 12)),
                        const SizedBox(width: 8),
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

    if (selectedPlayer != null) {
      setState(() {
        _assignments.updateAll(
            (key, value) => value?.id == selectedPlayer.id ? null : value);
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
                  'Tap a position to assign a player. Green players are substitutes.',
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
                      ...widget.targetPositions.map(
                        (targetPos) => _buildPlayerMarker(
                          targetPos,
                          _assignments[targetPos.id],
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
                            final targetPos = widget.targetPositions
                                .firstWhere((p) => p.id == targetPositionId);
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

  Widget _buildPlayerMarker(PlayerModel targetPosition,
      PlayerModel? assignedPlayer, BoxConstraints constraints) {
    const double markerSize = 40.0;
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
              : 'Unassigned (${targetPosition.role})',
          child: (assignedPlayer != null)
              ? PlayerComponentV2(
                  playerModel: assignedPlayer,
                )
              : Stack(
                  children: [
                    Opacity(
                      opacity: 0.4,
                      child: PlayerComponentV2(
                        playerModel: targetPosition,
                      ),
                    ),
                    // Container(
                    //   width: markerSize * .8,
                    //   height: markerSize * .8,
                    //   decoration: BoxDecoration(
                    //     color: Colors.black.withOpacity(0.1),
                    //     shape: BoxShape.circle,
                    //   ),
                    //   child: Icon(
                    //     Icons.question_mark,
                    //     color: Colors.white.withValues(alpha: 0.1),
                    //     size: markerSize * 0.4,
                    //   ),
                    // ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Keep FullFieldPainter unchanged
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

///3rd
