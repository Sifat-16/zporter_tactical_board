// // --- Mixin for Player Drawing ---
// import 'dart:math' as math;
//
// import 'package:flame/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
//
// mixin PlayerPainterMixin {
//   void drawPlayerItem({
//     required PlayerModel player,
//     required Canvas canvas,
//     required Size visualPlayerSize,
//     required Paint itemPaint, // Main paint for player body
//     required TextPainter textPainter, // For role and jersey number
//     required Size fieldSize,
//   }) {
//     Offset centerOfPlayer =
//         SizeHelper.getBoardActualVector(
//           gameScreenSize: fieldSize.toVector2(),
//           actualPosition: player.offset ?? Vector2.zero(),
//         ).toOffset();
//
//     final double baseOpacity = (player.opacity ?? 1.0).clamp(0.0, 1.0);
//     final Color baseColor =
//         player.color ??
//         (player.playerType == PlayerType.HOME
//             ? ColorManager.blue
//             : (player.playerType == PlayerType.AWAY
//                 ? ColorManager.red
//                 : ColorManager.grey));
//     final Color effectiveColor = baseColor.withOpacity(baseOpacity);
//
//     itemPaint.color = effectiveColor;
//     itemPaint.style = PaintingStyle.fill;
//
//     final double cornerRadiusValue =
//         math.min(visualPlayerSize.width, visualPlayerSize.height) * 0.2;
//     final Radius cornerRadius = Radius.circular(
//       cornerRadiusValue.clamp(1.0, 4.0),
//     );
//
//     visualPlayerSize = (player.size?.toSize() ?? Size(32, 32)) * .2;
//     final Rect playerRect = Rect.fromCenter(
//       center: centerOfPlayer,
//       width: visualPlayerSize.width,
//       height: visualPlayerSize.height,
//     );
//     final RRect roundedRect = RRect.fromRectAndRadius(playerRect, cornerRadius);
//     canvas.drawRRect(roundedRect, itemPaint);
//
//     // Role Text
//     final double roleFontSize =
//         math.min(visualPlayerSize.width, visualPlayerSize.height) * 0.6;
//     if (player.role.isNotEmpty && roleFontSize >= 1.5) {
//       final roleTextColor =
//           ThemeData.estimateBrightnessForColor(baseColor) == Brightness.dark
//               ? Colors.white.withOpacity(baseOpacity)
//               : Colors.black.withOpacity(baseOpacity);
//       textPainter.text = TextSpan(
//         text: player.role.isNotEmpty ? player.role[0].toUpperCase() : "?",
//         style: TextStyle(
//           color: roleTextColor,
//           fontSize: roleFontSize,
//           fontWeight: FontWeight.bold,
//         ),
//       );
//       textPainter.layout(minWidth: 0, maxWidth: visualPlayerSize.width);
//       // textPainter.paint(
//       //   canvas,
//       //   Offset(
//       //     (centerOfPlayer.dx - textPainter.width) / 2,
//       //     (centerOfPlayer.dy - textPainter.height) / 2,
//       //   ),
//       // );
//     }
//
//     // Jersey Number
//     String jerseyNumber = player.jerseyNumber.toString();
//     if (jerseyNumber == "-1" || jerseyNumber == "0") jerseyNumber = "";
//     if (jerseyNumber.isNotEmpty) {
//       final double jerseyFontSize = visualPlayerSize.width * 0.35;
//       if (jerseyFontSize >= 1.0) {
//         final jerseyTextColor = Colors.white.withOpacity(baseOpacity * 0.85);
//         textPainter.text = TextSpan(
//           text: jerseyNumber,
//           style: TextStyle(
//             color: jerseyTextColor,
//             fontSize: jerseyFontSize,
//             fontWeight: FontWeight.w900,
//           ),
//         );
//         textPainter.layout();
//         final double nudge = visualPlayerSize.width * 0.05;
//         final Offset numberTextDrawOffset = Offset(
//           visualPlayerSize.width -
//               textPainter.width +
//               nudge -
//               (visualPlayerSize.width * 0.075),
//           0 - textPainter.height + nudge + (jerseyFontSize * 0.3),
//         );
//         // textPainter.paint(canvas, numberTextDrawOffset);
//       }
//     }
//   }
// }

import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart'; // Assuming you use zlog
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';

mixin PlayerPainterMixin {
  void drawPlayerItem({
    required PlayerModel player,
    required Canvas canvas,
    required Size
    visualPlayerSize, // This is player.size (logical) * overallItemScale
    required Paint itemPaint,
    required TextPainter textPainter,
    required Size fieldSize,
  }) {
    Offset centerOfPlayer =
        SizeHelper.getBoardActualVector(
          gameScreenSize: fieldSize.toVector2(),
          actualPosition: player.offset ?? Vector2.zero(),
        ).toOffset();

    final double baseOpacity = (player.opacity ?? 1.0).clamp(0.0, 1.0);
    final Color baseColor =
        player.color ??
        (player.playerType == PlayerType.HOME
            ? ColorManager.blue
            : (player.playerType == PlayerType.AWAY
                ? ColorManager.red
                : ColorManager.grey));
    final Color effectiveColor = baseColor.withOpacity(baseOpacity);

    itemPaint.color = effectiveColor;
    itemPaint.style = PaintingStyle.fill;

    final double cornerRadiusValue =
        math.min(visualPlayerSize.width, visualPlayerSize.height) * 0.2;
    final Radius cornerRadius = Radius.circular(
      cornerRadiusValue.clamp(1.0, 4.0),
    );

    // IMPORTANT: Using the visualPlayerSize passed as parameter.
    // The line `visualPlayerSize = (player.size?.toSize() ?? Size(32, 32)) * .2;`
    // has been removed to use the consistently scaled size from the main painter.
    // If you need players to be smaller, adjust their logicalSize or overallItemScale for players.

    final Rect playerRect = Rect.fromCenter(
      center: centerOfPlayer,
      width: visualPlayerSize.width,
      height: visualPlayerSize.height,
    );
    final RRect roundedRect = RRect.fromRectAndRadius(playerRect, cornerRadius);
    canvas.drawRRect(roundedRect, itemPaint);

    // --- Role Text ---
    // Positioned at the center of the playerRect
    final double roleFontSize =
        math.min(visualPlayerSize.width, visualPlayerSize.height) * 0.6;
    if (player.role.isNotEmpty && roleFontSize >= 1.5) {
      final roleTextColor =
          ThemeData.estimateBrightnessForColor(baseColor) == Brightness.dark
              ? Colors.white.withOpacity(baseOpacity)
              : Colors.black.withOpacity(baseOpacity);
      textPainter.text = TextSpan(
        text: player.role.isNotEmpty ? player.role[0].toUpperCase() : "?",
        style: TextStyle(
          color: roleTextColor,
          fontSize: roleFontSize,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout(minWidth: 0, maxWidth: visualPlayerSize.width);

      // Calculate top-left for the text to be centered within playerRect
      final Offset roleTextOffset = Offset(
        centerOfPlayer.dx - textPainter.width / 2,
        centerOfPlayer.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, roleTextOffset);
      zlog(
        data:
            "Role text '${textPainter.text?.toPlainText()}' drawn at $roleTextOffset",
      );
    }

    // --- Jersey Number ---
    // Positioned in the top-right area of the playerRect
    String jerseyNumber = player.jerseyNumber.toString();
    if (jerseyNumber == "-1" || jerseyNumber == "0") jerseyNumber = "";
    if (jerseyNumber.isNotEmpty) {
      final double jerseyFontSize = visualPlayerSize.width * 0.35;
      if (jerseyFontSize >= 1.0) {
        final jerseyTextColor = Colors.white.withOpacity(baseOpacity * 0.85);
        textPainter.text = TextSpan(
          text: jerseyNumber,
          style: TextStyle(
            color: jerseyTextColor,
            fontSize: jerseyFontSize,
            fontWeight: FontWeight.w900,
          ),
        );
        textPainter.layout(); // No max width, let it size itself

        final double rectTopRightX =
            centerOfPlayer.dx + visualPlayerSize.width / 2;
        final double rectTopY = centerOfPlayer.dy - visualPlayerSize.height / 2;

        // Nudge from the corner for padding
        final double horizontalNudge =
            visualPlayerSize.width * 0.05; // Small padding from the right edge
        final double verticalNudge =
            visualPlayerSize.height * 0.05; // Small padding from the top edge

        final Offset numberTextDrawOffset = Offset(
          rectTopRightX - textPainter.width - horizontalNudge,
          rectTopY + verticalNudge,
        );
        textPainter.paint(canvas, numberTextDrawOffset);
        zlog(
          data:
              "Jersey number '${textPainter.text?.toPlainText()}' drawn at $numberTextDrawOffset",
        );
      }
    }
  }
}
