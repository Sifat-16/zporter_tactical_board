//
// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data'; // Required for Uint8List
// import 'dart:ui' as ui; // Required for ui.Image and decodeImageFromList
//
// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/app/helper/size_helper.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/app/manager/values_manager.dart';
// import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
//
// class PlayerComponent extends FieldComponent<PlayerModel> {
//   PlayerComponent({required super.object});
//
//   final Paint _backgroundPaint = Paint();
//   final TextPainter _textPainter =
//       TextPainter(textDirection: TextDirection.ltr);
//   final TextPainter _jerseyTextPainter =
//       TextPainter(textDirection: TextDirection.ltr);
//   // NEW: Add a dedicated TextPainter for the player's name.
//   final TextPainter _nameTextPainter = TextPainter(
//       textDirection: TextDirection.ltr, textAlign: TextAlign.center);
//
//   // This will hold the custom player image if it exists.
//   Sprite? _playerImageSprite;
//
//   /// Loads the player image from a local file path.
//   Future<void> _loadPlayerImage() async {
//     _playerImageSprite = null;
//     final imagePath = object.imagePath;
//     if (imagePath == null || imagePath.isEmpty) return;
//     try {
//       final file = File(imagePath);
//       if (await file.exists()) {
//         final Uint8List bytes = await file.readAsBytes();
//         final ui.Image image = await decodeImageFromList(bytes);
//         _playerImageSprite = Sprite(image);
//       } else {
//         zlog(data: "Player image file does not exist at path: $imagePath");
//       }
//     } catch (e) {
//       zlog(data: "Failed to load/decode player image. Error: $e");
//       _playerImageSprite = null;
//     }
//   }
//
//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     sprite = await game.loadSprite("ball.png", srcSize: Vector2.zero());
//     await _loadPlayerImage();
//     size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
//     position = SizeHelper.getBoardActualVector(
//       gameScreenSize: game.gameField.size,
//       actualPosition: object.offset ?? Vector2(x, y),
//     );
//     angle = object.angle ?? 0;
//   }
//
//   // onTapDown, onDragUpdate, onScaleUpdate, and onRotationUpdate are unchanged.
//   @override
//   void onTapDown(TapDownEvent event) {
//     super.onTapDown(event);
//     ref
//         .read(boardProvider.notifier)
//         .toggleSelectItemEvent(fieldItemModel: object);
//   }
//
//   @override
//   void onDragUpdate(DragUpdateEvent event) {
//     super.onDragUpdate(event);
//     object.offset = SizeHelper.getBoardRelativeVector(
//       gameScreenSize: game.gameField.size,
//       actualPosition: position,
//     );
//   }
//
//   @override
//   void onScaleUpdate(DragUpdateEvent event) {
//     super.onScaleUpdate(event);
//     object.offset = SizeHelper.getBoardRelativeVector(
//       gameScreenSize: game.gameField.size,
//       actualPosition: position,
//     );
//   }
//
//   @override
//   void onRotationUpdate() {
//     super.onRotationUpdate();
//     object.angle = angle;
//   }
//
//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     // We don't call super.render() to have full control over the drawing.
//     size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
//     final baseOpacity = (object.opacity ?? 1.0).clamp(0.0, 1.0);
//     final rect = size.toRect();
//     const cornerRadiusValue = 6.0;
//     final rrect =
//         RRect.fromRectAndRadius(rect, Radius.circular(cornerRadiusValue));
//
//     // --- Render Player Body (Image or Color) ---
//     canvas.save();
//     canvas.clipRRect(rrect);
//     if (_playerImageSprite != null) {
//       _playerImageSprite!.render(
//         canvas,
//         size: size,
//         overridePaint: Paint()..color = Colors.white.withOpacity(baseOpacity),
//       );
//     } else {
//       // Your original code for background and role
//       final Color baseColor = object.color ??
//           (object.playerType == PlayerType.HOME
//               ? ColorManager.blue
//               : (object.playerType == PlayerType.AWAY
//                   ? ColorManager.red
//                   : ColorManager.grey));
//       final Color effectiveColor = baseColor.withOpacity(baseOpacity);
//       _backgroundPaint.color = effectiveColor;
//       _backgroundPaint.style = PaintingStyle.fill;
//       canvas.drawRRect(rrect, _backgroundPaint);
//       final fontSize = (size.x / 2) * 0.7;
//       _textPainter.text = TextSpan(
//         text: object.role,
//         style: TextStyle(
//           color: Colors.white.withOpacity(baseOpacity),
//           fontSize: fontSize,
//           fontWeight: FontWeight.bold,
//         ),
//       );
//       _textPainter.layout();
//       _textPainter.paint(
//         canvas,
//         (size.toOffset() / 2) -
//             Offset(_textPainter.width / 2, _textPainter.height / 2),
//       );
//     }
//     canvas.restore();
//
//     // --- Render Jersey Number ---
//     // Your original, working code for the jersey number.
//     String jerseyNumber = object.jerseyNumber.toString();
//     if (jerseyNumber == "-1") {
//       jerseyNumber = "";
//     }
//     if (jerseyNumber.isNotEmpty) {
//       final double jerseyFontSize = size.x * 0.3;
//       final jerseyTextColor = Colors.white.withOpacity(baseOpacity);
//       _jerseyTextPainter.text = TextSpan(
//         text: jerseyNumber,
//         style: TextStyle(
//           color: jerseyTextColor,
//           fontSize: jerseyFontSize,
//           fontWeight: FontWeight.w900,
//           shadows: [
//             Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.8)),
//           ],
//         ),
//       );
//       _jerseyTextPainter.layout();
//       final Offset numberTextDrawOffset = Offset(
//         size.x - (size.x * .1),
//         -size.y * .15,
//       );
//       _jerseyTextPainter.paint(canvas, numberTextDrawOffset);
//     }
//
//     // --- NEW: Render Player Name ---
//     final playerName = object.name;
//     if (playerName != null && playerName.isNotEmpty) {
//       // Set up the text style for the name.
//       final nameTextStyle = TextStyle(
//         color: Colors.white.withOpacity(baseOpacity),
//         fontSize: size.x * 0.25, // Slightly smaller than jersey number
//         fontWeight: FontWeight.w600,
//         shadows: [
//           Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.9)),
//         ],
//       );
//
//       // Use the TextPainter's maxLines and ellipsis properties.
//       _nameTextPainter.text = TextSpan(text: playerName, style: nameTextStyle);
//       _nameTextPainter.maxLines = 1;
//       _nameTextPainter.ellipsis = '...';
//
//       // Layout the text, constraining its width to the player component's width.
//       // This will cause it to wrap to a new line if necessary.
//       _nameTextPainter.layout(maxWidth: size.x);
//
//       // Calculate the position to draw the name.
//       // Horizontally centered, and vertically placed below the component.
//       final nameOffset = Offset(
//         (size.x - _nameTextPainter.width) / 2, // Center horizontally
//         size.y + 4.0, // Place below the component with a small margin
//       );
//
//       _nameTextPainter.paint(canvas, nameOffset);
//     }
//   }
//
//   @override
//   void onComponentScale(Vector2 size) {
//     super.onComponentScale(size);
//     object.size = size;
//   }
//
//   @override
//   Future<void> onLongTapDown(TapDownEvent event) async {
//     super.onLongTapDown(event);
//
//     PlayerModel? updatedPlayer = await PlayerUtilsV2.showEditPlayerDialog(
//       context: game.buildContext!,
//       player: object,
//     );
//
//     if (updatedPlayer != null) {
//       object = updatedPlayer;
//       // After editing, attempt to reload the image in case it was added/changed.
//       await _loadPlayerImage();
//       ref
//           .read(boardProvider.notifier)
//           .updatePlayerModel(newModel: updatedPlayer);
//     } else {
//       zlog(data: 'Player edit cancelled.');
//     }
//   }
// }

import 'dart:async';
import 'dart:io';
import 'dart:typed_data'; // Required for Uint8List
import 'dart:ui' as ui; // Required for ui.Image and decodeImageFromList

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class PlayerComponent extends FieldComponent<PlayerModel> {
  PlayerComponent({required super.object});

  final Paint _backgroundPaint = Paint();
  final TextPainter _textPainter =
      TextPainter(textDirection: TextDirection.ltr);
  final TextPainter _jerseyTextPainter =
      TextPainter(textDirection: TextDirection.ltr);
  final TextPainter _nameTextPainter = TextPainter(
      textDirection: TextDirection.ltr, textAlign: TextAlign.center);

  // This will hold the custom player image if it exists.
  Sprite? _playerImageSprite;

  /// Loads the player image from a local file path.
  Future<void> _loadPlayerImage() async {
    _playerImageSprite = null;
    final imagePath = object.imagePath;
    if (imagePath == null || imagePath.isEmpty) return;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        final Uint8List bytes = await file.readAsBytes();
        final ui.Image image = await decodeImageFromList(bytes);
        _playerImageSprite = Sprite(image);
      } else {
        zlog(data: "Player image file does not exist at path: $imagePath");
      }
    } catch (e) {
      zlog(data: "Failed to load/decode player image. Error: $e");
      _playerImageSprite = null;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite("ball.png", srcSize: Vector2.zero());
    await _loadPlayerImage();
    size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
    position = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: object.offset ?? Vector2(x, y),
    );
    angle = object.angle ?? 0;
  }

  // onTapDown, onDragUpdate, onScaleUpdate, and onRotationUpdate are unchanged.
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: object);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    object.offset = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
  }

  @override
  void onScaleUpdate(DragUpdateEvent event) {
    super.onScaleUpdate(event);
    object.offset = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
  }

  @override
  void onRotationUpdate() {
    super.onRotationUpdate();
    object.angle = angle;
  }

  @override
  void render(Canvas canvas) {
    // We don't call super.render() to have full control over the drawing.
    size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
    final baseOpacity = (object.opacity ?? 1.0).clamp(0.0, 1.0);
    final rect = size.toRect();
    const cornerRadiusValue = 6.0;
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(cornerRadiusValue));

    // --- Render Player Body (Image or Role/Color) based on flags ---
    canvas.save();
    canvas.clipRRect(rrect);

    // **UPDATED CONDITIONAL LOGIC**
    // Priority 1: Show image if toggled on and available.
    if (object.showImage && _playerImageSprite != null) {
      _playerImageSprite!.render(
        canvas,
        size: size,
        overridePaint: Paint()..color = Colors.white.withOpacity(baseOpacity),
      );
    } else {
      // Priority 2: Show role if toggled on (or if image is off/unavailable).
      final Color baseColor = object.color ??
          (object.playerType == PlayerType.HOME
              ? ColorManager.blue
              : (object.playerType == PlayerType.AWAY
                  ? ColorManager.red
                  : ColorManager.grey));
      final Color effectiveColor = baseColor.withOpacity(baseOpacity);
      _backgroundPaint.color = effectiveColor;
      _backgroundPaint.style = PaintingStyle.fill;
      canvas.drawRRect(rrect, _backgroundPaint);

      if (object.showRole) {
        final fontSize = (size.x / 2) * 0.7;
        _textPainter.text = TextSpan(
          text: object.role,
          style: TextStyle(
            color: Colors.white.withOpacity(baseOpacity),
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        );
        _textPainter.layout();
        _textPainter.paint(
          canvas,
          (size.toOffset() / 2) -
              Offset(_textPainter.width / 2, _textPainter.height / 2),
        );
      }
    }
    canvas.restore();

    // --- Render Jersey Number if showNr is true ---
    String jerseyNumber = object.jerseyNumber.toString();
    if (jerseyNumber == "-1") {
      jerseyNumber = "";
    }
    if (object.showNr && jerseyNumber.isNotEmpty) {
      final double jerseyFontSize = size.x * 0.3;
      final jerseyTextColor = Colors.white.withOpacity(baseOpacity);
      _jerseyTextPainter.text = TextSpan(
        text: jerseyNumber,
        style: TextStyle(
          color: jerseyTextColor,
          fontSize: jerseyFontSize,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.8)),
          ],
        ),
      );
      _jerseyTextPainter.layout();
      final Offset numberTextDrawOffset = Offset(
        size.x - (size.x * .1),
        -size.y * .15,
      );
      _jerseyTextPainter.paint(canvas, numberTextDrawOffset);
    }

    // --- Render Player Name if showName is true ---
    final playerName = object.name;
    if (object.showName && playerName != null && playerName.isNotEmpty) {
      final nameTextStyle = TextStyle(
        color: Colors.white.withOpacity(baseOpacity),
        fontSize: size.x * 0.25,
        fontWeight: FontWeight.w600,
        shadows: [
          Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.9)),
        ],
      );

      _nameTextPainter.text = TextSpan(text: playerName, style: nameTextStyle);
      // **REVERTED to 1 line for your original request**
      _nameTextPainter.maxLines = 1;
      _nameTextPainter.ellipsis = '...';

      _nameTextPainter.layout(maxWidth: size.x);

      final nameOffset = Offset(
        (size.x - _nameTextPainter.width) / 2,
        size.y + 4.0,
      );

      _nameTextPainter.paint(canvas, nameOffset);
    }
  }

  @override
  void onComponentScale(Vector2 size) {
    super.onComponentScale(size);
    object.size = size;
  }

  @override
  Future<void> onLongTapDown(TapDownEvent event) async {
    super.onLongTapDown(event);

    PlayerModel? updatedPlayer = await PlayerUtilsV2.showEditPlayerDialog(
      context: game.buildContext!,
      player: object,
    );

    if (updatedPlayer != null) {
      object = updatedPlayer;
      await _loadPlayerImage();
      ref
          .read(boardProvider.notifier)
          .updatePlayerModel(newModel: updatedPlayer);
    } else {
      zlog(data: 'Player edit cancelled.');
    }
  }
}
