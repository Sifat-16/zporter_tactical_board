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
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class PlayerComponent extends FieldComponent<PlayerModel>
    with DoubleTapCallbacks {
  PlayerComponent({required super.object});

  final Paint _backgroundPaint = Paint();
  final TextPainter _textPainter =
      TextPainter(textDirection: TextDirection.ltr);
  final TextPainter _jerseyTextPainter =
      TextPainter(textDirection: TextDirection.ltr);
  final TextPainter _nameTextPainter = TextPainter(
      textDirection: TextDirection.ltr, textAlign: TextAlign.center);

  Sprite? _playerImageSprite;

  Future<void> _loadPlayerImage() async {
    _playerImageSprite = null;
    final imageBase64 = object.imageBase64;

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(imageBase64);
        final ui.Image image = await decodeImageFromList(bytes);
        _playerImageSprite = Sprite(image);
        return;
      } catch (e) {
        zlog(data: "Failed to decode player image from Base64. Error: $e");
        _playerImageSprite = null;
      }
    }

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

  @override
  void onMount() {
    super.onMount();
    _syncWithDatabase();
  }

  Future<void> _syncWithDatabase() async {
    try {
      final dbPlayer = await PlayerUtilsV2.getPlayerFromDbById(object.id);
      if (dbPlayer == null) return;

      // --- CHANGE 1: Also check if displayNumber has changed ---
      final bool needsUpdate = dbPlayer.role != object.role ||
          dbPlayer.displayNumber != object.displayNumber ||
          dbPlayer.imageBase64 != object.imageBase64 ||
          dbPlayer.name != object.name;

      if (needsUpdate) {
        zlog(data: "Syncing player ${object.id}: Data mismatch found.");
        final oldImage = object.imageBase64;

        final newModelInstance = object.copyWith(
          role: dbPlayer.role,
          // Sync both numbers to be safe, though jerseyNumber shouldn't change
          jerseyNumber: dbPlayer.jerseyNumber,
          displayNumber: dbPlayer.displayNumber,
          imageBase64: dbPlayer.imageBase64,
          name: dbPlayer.name,
        );

        object = newModelInstance;

        ref
            .read(boardProvider.notifier)
            .updatePlayerModel(newModel: newModelInstance);

        if (dbPlayer.imageBase64 != oldImage) {
          await _loadPlayerImage();
        }
      }
    } catch (e) {
      zlog(data: "Error during player sync: $e");
    }
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
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: object);
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    super.onDoubleTapDown(event);
    _executeEditAction();
  }

  void _executeEditAction() async {
    if (game.buildContext == null) return;

    final boardState = ref.read(boardProvider);
    final allPlayersOnTeamFromDb = await (object.playerType == PlayerType.HOME
        ? PlayerUtilsV2.getOrInitializeHomePlayers()
        : PlayerUtilsV2.getOrInitializeAwayPlayers());

    final Set<String> fieldPlayerIds = boardState.players
        .where((p) => p.playerType == object.playerType)
        .map((p) => p.id)
        .toSet();

    final List<PlayerModel> rosterPlayers = allPlayersOnTeamFromDb
        .where((p) => !fieldPlayerIds.contains(p.id))
        .toList();

    final result = await PlayerUtilsV2.showEditPlayerDialog(
        context: game.buildContext!,
        player: object,
        rosterPlayers: rosterPlayers,
        showReplace: true);

    if (result is PlayerSwapResult) {
      final TacticBoard tacticBoard = game as TacticBoard;
      final playerToBringIn = result.playerToBringIn.copyWith(
        offset: result.playerToBench.offset,
      );
      tacticBoard.removeFieldItems([result.playerToBench]);
      tacticBoard.addItem(playerToBringIn);
      zlog(
          data:
              "Swapped player ${result.playerToBench.id} with ${result.playerToBringIn.id}");
    } else if (result is PlayerUpdateResult) {
      object = result.updatedPlayer;
      await _loadPlayerImage();
      ref
          .read(boardProvider.notifier)
          .updatePlayerModel(newModel: result.updatedPlayer);
      zlog(data: "Updated player details for ${result.updatedPlayer.id}");
    }
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
  void onComponentScale(Vector2 newSize) {
    super.onComponentScale(newSize);
    object.size = newSize;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
    final baseOpacity = (object.opacity ?? 1.0).clamp(0.0, 1.0);

    final rect = size.toRect();
    const cornerRadiusValue = 6.0;
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(cornerRadiusValue));

    canvas.save();
    canvas.clipRRect(rrect);

    if (object.showImage && _playerImageSprite != null) {
      _playerImageSprite!.render(
        canvas,
        size: size,
        overridePaint: Paint()..color = Colors.white.withOpacity(baseOpacity),
      );
    } else {
      final Color baseColor = object.color ??
          (object.playerType == PlayerType.HOME
              ? ColorManager.blue
              : (object.playerType == PlayerType.AWAY
                  ? ColorManager.red
                  : ColorManager.grey));
      _backgroundPaint.color = baseColor.withOpacity(baseOpacity);
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

    // --- CHANGE 2: Logic to determine which number to display ---
    // Prioritize the editable 'displayNumber', but fall back to the permanent 'jerseyNumber'.
    String numberToRender =
        (object.displayNumber ?? object.jerseyNumber).toString();
    if (numberToRender == "-1") numberToRender = "";

    if (object.showNr && numberToRender.isNotEmpty) {
      final double jerseyFontSize = size.x * 0.3;
      _jerseyTextPainter.text = TextSpan(
        text: numberToRender, // Use the determined number
        style: TextStyle(
          color: Colors.white.withOpacity(baseOpacity),
          fontSize: jerseyFontSize,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.8))
          ],
        ),
      );
      _jerseyTextPainter.layout();
      _jerseyTextPainter.paint(
          canvas, Offset(size.x - (size.x * .1), -size.y * .15));
    }

    final playerName = object.name;
    if (object.showName && playerName != null && playerName.isNotEmpty) {
      final nameTextStyle = TextStyle(
        color: Colors.white.withOpacity(baseOpacity),
        fontSize: size.x * 0.25,
        fontWeight: FontWeight.w600,
        shadows: [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.9))],
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
      final nameOffset =
          Offset((size.x - _nameTextPainter.width) / 2, size.y + 4.0);
      _nameTextPainter.paint(canvas, nameOffset);
    }
  }
}
