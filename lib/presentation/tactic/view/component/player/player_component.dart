// import 'dart:async' as a;
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data'; // Required for Uint8List
// import 'dart:ui' as ui; // Required for ui.Image and decodeImageFromList
//
// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flutter/gestures.dart'; // Required for kLongPressTimeout
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
//   final TextPainter _nameTextPainter = TextPainter(
//       textDirection: TextDirection.ltr, textAlign: TextAlign.center);
//
//   // --- MODIFIED: State variables for gesture differentiation ---
//   a.Timer? _longPressTimer;
//   bool _isDragging = false;
//   bool _longPressFired = false;
//   final Duration _longPressDelay = kLongPressTimeout;
//
//   Sprite? _playerImageSprite;
//
//   Future<void> _loadPlayerImage() async {
//     _playerImageSprite = null;
//     final imageBase64 = object.imageBase64;
//
//     // 1. Try to load from Base64 string first.
//     if (imageBase64 != null && imageBase64.isNotEmpty) {
//       try {
//         final Uint8List bytes = base64Decode(imageBase64);
//         final ui.Image image = await decodeImageFromList(bytes);
//         _playerImageSprite = Sprite(image);
//         return; // Success, no need to check file path.
//       } catch (e) {
//         zlog(data: "Failed to decode/load player image from Base64. Error: $e");
//         _playerImageSprite = null;
//       }
//     }
//
//     // 2. Fallback to imagePath for backward compatibility (optional).
//     final imagePath = object.imagePath;
//     if (imagePath != null && imagePath.isNotEmpty) {
//       try {
//         final file = File(imagePath);
//         if (await file.exists()) {
//           final Uint8List bytes = await file.readAsBytes();
//           final ui.Image image = await decodeImageFromList(bytes);
//           _playerImageSprite = Sprite(image);
//         } else {
//           zlog(data: "Player image file does not exist at path: $imagePath");
//         }
//       } catch (e) {
//         zlog(
//             data:
//                 "Failed to load/decode player image from file path. Error: $e");
//         _playerImageSprite = null;
//       }
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
//   // --- NEW: Corrected Gesture Handling Logic ---
//
//   @override
//   void onTapDown(TapDownEvent event) {
//     super.onTapDown(event);
//     // Reset flags at the beginning of a new gesture.
//
//     ref
//         .read(boardProvider.notifier)
//         .toggleSelectItemEvent(fieldItemModel: object);
//     _isDragging = false;
//     _longPressFired = false;
//
//     // Start the long-press timer.
//     _longPressTimer = a.Timer(_longPressDelay, () {
//       _executeLongPress();
//     });
//   }
//
//   @override
//   void onDragStart(DragStartEvent event) {
//     super.onDragStart(event);
//     _isDragging = true;
//     // A drag has started, so it's not a long press.
//     _longPressTimer?.cancel();
//   }
//
//   @override
//   void onDragEnd(DragEndEvent event) {
//     super.onDragEnd(event);
//     // Reset the dragging flag.
//     _isDragging = false;
//   }
//
//   @override
//   void onTapUp(TapUpEvent event) {
//     super.onTapUp(event);
//     // The finger was lifted, so it's not a long press.
//     _longPressTimer?.cancel();
//
//     // // A tap is only valid if the user was not dragging AND the long press did not fire.
//     // if (!_isDragging && !_longPressFired) {
//     //   // This is a confirmed tap, execute the selection logic.
//     //
//     // }
//   }
//
//   @override
//   void onTapCancel(TapCancelEvent event) {
//     super.onTapCancel(event);
//     // Also cancel the timer if the tap is canceled.
//     _longPressTimer?.cancel();
//     _isDragging = false;
//     _longPressFired = false;
//   }
//
//   /// This function contains the logic that was previously in onLongTapDown.
//   void _executeLongPress() async {
//     // A long press has occurred. Set the flag to true.
//     _longPressFired = true;
//     zlog(data: "Long press executed for player ${object.id}");
//
//     PlayerModel? updatedPlayer = await PlayerUtilsV2.showEditPlayerDialog(
//       context: game.buildContext!,
//       player: object,
//     );
//
//     if (updatedPlayer != null) {
//       object = updatedPlayer;
//       await _loadPlayerImage();
//       ref
//           .read(boardProvider.notifier)
//           .updatePlayerModel(newModel: updatedPlayer);
//     } else {
//       zlog(data: 'Player edit cancelled.');
//     }
//   }
//
//   // --- The rest of the component is unchanged ---
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
//     size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
//     final baseOpacity = (object.opacity ?? 1.0).clamp(0.0, 1.0);
//     final rect = size.toRect();
//     const cornerRadiusValue = 6.0;
//     final rrect =
//         RRect.fromRectAndRadius(rect, Radius.circular(cornerRadiusValue));
//
//     canvas.save();
//     canvas.clipRRect(rrect);
//
//     if (object.showImage && _playerImageSprite != null) {
//       _playerImageSprite!.render(
//         canvas,
//         size: size,
//         overridePaint: Paint()..color = Colors.white.withOpacity(baseOpacity),
//       );
//     } else {
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
//
//       if (object.showRole) {
//         final fontSize = (size.x / 2) * 0.7;
//         _textPainter.text = TextSpan(
//           text: object.role,
//           style: TextStyle(
//             color: Colors.white.withOpacity(baseOpacity),
//             fontSize: fontSize,
//             fontWeight: FontWeight.bold,
//           ),
//         );
//         _textPainter.layout();
//         _textPainter.paint(
//           canvas,
//           (size.toOffset() / 2) -
//               Offset(_textPainter.width / 2, _textPainter.height / 2),
//         );
//       }
//     }
//     canvas.restore();
//
//     String jerseyNumber = object.jerseyNumber.toString();
//     if (jerseyNumber == "-1") {
//       jerseyNumber = "";
//     }
//     if (object.showNr && jerseyNumber.isNotEmpty) {
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
//     final playerName = object.name;
//     if (object.showName && playerName != null && playerName.isNotEmpty) {
//       final nameTextStyle = TextStyle(
//         color: Colors.white.withOpacity(baseOpacity),
//         fontSize: size.x * 0.25,
//         fontWeight: FontWeight.w600,
//         shadows: [
//           Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.9)),
//         ],
//       );
//
//       // String textToRender = playerName;
//       // if (playerName.contains(' ')) {
//       //   textToRender = playerName.replaceFirst(' ', '\n');
//       // }
//
//       // --- START: MODIFIED NAME LOGIC ---
//       String truncate(String s) => s.length > 9 ? s.substring(0, 9) : s;
//
//       final parts =
//           playerName.trim().split(' ').where((p) => p.isNotEmpty).toList();
//       String textToRender;
//
//       if (parts.length > 1) {
//         final firstName = truncate(parts.first);
//         // Join the rest back together in case of multiple last/middle names
//         final lastName = truncate(parts.sublist(1).join(' '));
//         textToRender = '$firstName\n$lastName';
//       } else {
//         textToRender = truncate(playerName);
//       }
//
//       _nameTextPainter.text =
//           TextSpan(text: textToRender, style: nameTextStyle);
//       _nameTextPainter.maxLines = 2;
//
//       // Requirement 1: Centralize the text
//       _nameTextPainter.textAlign = TextAlign.center;
//
//       // Requirement 2: Take away ellipsis (by not setting the ellipsis property)
//       _nameTextPainter.ellipsis = null;
//
//       // Give the layout a bit more horizontal space than the icon itself
//       _nameTextPainter.layout(maxWidth: size.x * 1.5);
//
//       final nameOffset = Offset(
//         (size.x - _nameTextPainter.width) /
//             2, // This centers the entire text block
//         size.y + 4.0, // Position below the icon
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
//   Future<void> _syncWithDatabase() async {
//     try {
//       final dbPlayer = await PlayerUtilsV2.getPlayerFromDbById(object.id);
//
//       if (dbPlayer == null) {
//         return;
//       }
//
//       final bool needsUpdate = dbPlayer.role != object.role ||
//           dbPlayer.jerseyNumber != object.jerseyNumber ||
//           dbPlayer.imagePath != object.imagePath;
//
//       if (needsUpdate) {
//         zlog(
//             data:
//                 "Syncing player ${object.id}: Data mismatch found. Updating component.");
//
//         final oldImagePath = object.imagePath;
//
//         object = object.copyWith(
//           role: dbPlayer.role,
//           jerseyNumber: dbPlayer.jerseyNumber,
//           imagePath: dbPlayer.imagePath,
//         );
//
//         if (dbPlayer.imagePath != oldImagePath) {
//           await _loadPlayerImage();
//         }
//       }
//     } catch (e) {}
//   }
//
//   @override
//   void onMount() {
//     super.onMount();
//     _syncWithDatabase();
//   }
// }

import 'dart:async' as a;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

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

/// PlayerComponent represents a single player on the tactical board.
///
/// It handles rendering the player (either as a custom image or a colored circle),
/// and manages user interactions:
/// - **Single Tap**: Selects or deselects the player.
/// - **Double Tap**: Opens the editor dialog to change player details.
/// - **Drag**: Moves the player around the board.
class PlayerComponent extends FieldComponent<PlayerModel>
    with DoubleTapCallbacks {
  PlayerComponent({required super.object});

  // Painting and text rendering utilities.
  final Paint _backgroundPaint = Paint();
  final TextPainter _textPainter =
      TextPainter(textDirection: TextDirection.ltr);
  final TextPainter _jerseyTextPainter =
      TextPainter(textDirection: TextDirection.ltr);
  final TextPainter _nameTextPainter = TextPainter(
      textDirection: TextDirection.ltr, textAlign: TextAlign.center);

  // Holds the rendered image of the player if one exists.
  Sprite? _playerImageSprite;

  /// Loads the player's image.
  ///
  /// This method first attempts to decode a Base64 string from the `object.imageBase64`
  /// field for persistent storage. If that fails or is not present, it falls back
  /// to loading from a file path for backward compatibility.
  Future<void> _loadPlayerImage() async {
    _playerImageSprite = null;
    final imageBase64 = object.imageBase64;

    // 1. Prioritize loading from the persistent Base64 string.
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(imageBase64);
        final ui.Image image = await decodeImageFromList(bytes);
        _playerImageSprite = Sprite(image);
        return; // Exit successfully after loading from Base64.
      } catch (e) {
        zlog(data: "Failed to decode player image from Base64. Error: $e");
        _playerImageSprite = null;
      }
    }

    // 2. Fallback to loading from a file path if Base64 is not available.
    final imagePath = object.imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          final Uint8List bytes = await file.readAsBytes();
          final ui.Image image = await decodeImageFromList(bytes);
          _playerImageSprite = Sprite(image);
        }
      } catch (e) {
        zlog(data: "Failed to load player image from file path. Error: $e");
        _playerImageSprite = null;
      }
    }
  }

  /// Called once when the component is first added to the game.
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite("ball.png", srcSize: Vector2.zero());
    await _loadPlayerImage(); // Load the player's visual representation.

    // Set initial size and position based on the PlayerModel data.
    size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
    position = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: object.offset ?? Vector2.zero(),
    );
    angle = object.angle ?? 0;
  }

  //============================================================================
  // GESTURE HANDLING
  //============================================================================

  /// Handles a single tap to select the item.
  /// Flame's gesture system automatically distinguishes this from a double tap.
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // This action selects or deselects the player.
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: object);
  }

  /// Handles a double tap to open the player editor.
  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    super.onDoubleTapDown(event);
    zlog(data: "Double tap detected on player ${object.id}. Opening editor.");
    _executeEditAction();
  }

  /// Contains the logic to show the player editor dialog.
  void _executeEditAction() async {
    // Call the utility method to show the editing dialog.
    PlayerModel? updatedPlayer = await PlayerUtilsV2.showEditPlayerDialog(
      context: game.buildContext!,
      player: object,
    );

    // If the dialog returns an updated player model, apply the changes.
    if (updatedPlayer != null) {
      object = updatedPlayer; // Update the component's internal model.
      await _loadPlayerImage(); // Reload the image in case it was changed.
      // Notify the global state provider of the update.
      ref
          .read(boardProvider.notifier)
          .updatePlayerModel(newModel: updatedPlayer);
    } else {
      zlog(data: 'Player edit dialog was cancelled.');
    }
  }

  /// Updates the player's position in the model as it's being dragged.
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    object.offset = SizeHelper.getBoardRelativeVector(
      gameScreenSize: game.gameField.size,
      actualPosition: position,
    );
  }

  //============================================================================
  // RENDERING
  //============================================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Ensure size and opacity are up-to-date with the model.
    size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
    final baseOpacity = (object.opacity ?? 1.0).clamp(0.0, 1.0);

    // Create a rounded rectangle for the player's background/clipping mask.
    final rect = size.toRect();
    const cornerRadiusValue = 6.0;
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(cornerRadiusValue));

    canvas.save();
    canvas.clipRRect(rrect); // Clip all drawing to the rounded rectangle shape.

    // If a custom image exists, render it.
    if (object.showImage && _playerImageSprite != null) {
      _playerImageSprite!.render(
        canvas,
        size: size,
        overridePaint: Paint()..color = Colors.white.withOpacity(baseOpacity),
      );
    } else {
      // Otherwise, render the default colored circle with the player's role.
      final Color baseColor = object.color ??
          (object.playerType == PlayerType.HOME
              ? ColorManager.blue
              : (object.playerType == PlayerType.AWAY
                  ? ColorManager.red
                  : ColorManager.grey));
      _backgroundPaint.color = baseColor.withOpacity(baseOpacity);
      _backgroundPaint.style = PaintingStyle.fill;
      canvas.drawRRect(rrect, _backgroundPaint);

      // Render the role text (e.g., "ST", "GK") in the center.
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
    canvas.restore(); // Restore the canvas from the clipping operation.

    // Render the jersey number in the top-right corner.
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

    // Render the player's name below the component.
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

      String truncate(String s) => s.length > 9 ? s.substring(0, 9) : s;

      final parts =
          playerName.trim().split(' ').where((p) => p.isNotEmpty).toList();
      String textToRender;

      if (parts.length > 1) {
        final firstName = truncate(parts.first);
        final lastName = truncate(parts.sublist(1).join(' '));
        textToRender = '$firstName\n$lastName';
      } else {
        textToRender = truncate(playerName);
      }

      _nameTextPainter.text =
          TextSpan(text: textToRender, style: nameTextStyle);
      _nameTextPainter.maxLines = 2;
      _nameTextPainter.textAlign = TextAlign.center;
      _nameTextPainter.ellipsis = null;
      _nameTextPainter.layout(maxWidth: size.x * 1.5);

      final nameOffset = Offset(
        (size.x - _nameTextPainter.width) / 2,
        size.y + 4.0,
      );

      _nameTextPainter.paint(canvas, nameOffset);
    }
  }

  //============================================================================
  // LIFECYCLE AND SYNC
  //============================================================================

  @override
  void onMount() {
    super.onMount();
    _syncWithDatabase(); // Sync with DB when component is mounted.
  }

  /// Periodically syncs the component's state with the database.
  Future<void> _syncWithDatabase() async {
    try {
      final dbPlayer = await PlayerUtilsV2.getPlayerFromDbById(object.id);
      if (dbPlayer == null) return;

      // Check if any visual data has changed in the database.
      final bool needsUpdate = dbPlayer.role != object.role ||
          dbPlayer.jerseyNumber != object.jerseyNumber ||
          dbPlayer.imageBase64 != object.imageBase64 ||
          dbPlayer.name != object.name;

      if (needsUpdate) {
        zlog(data: "Syncing player ${object.id}: Data mismatch found.");
        final oldImage = object.imageBase64;
        object = object.copyWith(
          role: dbPlayer.role,
          jerseyNumber: dbPlayer.jerseyNumber,
          imageBase64: dbPlayer.imageBase64,
          name: dbPlayer.name,
        );

        // If the image itself changed, reload it.
        if (dbPlayer.imageBase64 != oldImage) {
          await _loadPlayerImage();
        }
      }
    } catch (e) {
      zlog(data: "Error during player sync: $e");
    }
  }

  // Other event handlers like onScaleUpdate, onRotationUpdate, etc.
  @override
  void onScaleUpdate(DragUpdateEvent event) {
    super.onScaleUpdate(event);
    object.size = size;
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
}
