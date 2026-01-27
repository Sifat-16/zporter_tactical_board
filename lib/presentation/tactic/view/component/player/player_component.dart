import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/app/services/image_migration/image_migration_service.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/model/guide_line.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

final Map<String, ui.Image> _playerImageCache = {};

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

  // Cached team border color - updated by listener when boardProvider state changes
  Color? _cachedTeamBorderColor;

  bool _isLoadingImage = false; // Tracks the loading state
  double _loadingArcAngle = 0.0;

  final double _snapTolerance =
      5.0; // How close to be before snapping (in pixels)
  final double _gridSize = 50.0; // Must match the gridSize in GridComponent
  final List<GuideLine> _activeGuides = [];

  /// Public method to reload player image when model data changes
  /// Called from board_riverpod_integration when player state updates
  void reloadImageIfNeeded(PlayerModel oldModel) {
    if (oldModel.imageBase64 != object.imageBase64 ||
        oldModel.imagePath != object.imagePath) {
      zlog(data: "Player ${object.id} image changed, reloading...");
      _loadPlayerImage();
    }
  }

  Future<void> _loadPlayerImage() async {
    _playerImageSprite = null;
    final imageSourceIdentifier = _getImageSourceIdentifier();

    if (imageSourceIdentifier == null || imageSourceIdentifier.isEmpty) {
      _isLoadingImage = false; // No image to load
      return;
    }

    // 1. Check cache.
    if (_playerImageCache.containsKey(imageSourceIdentifier)) {
      _playerImageSprite = Sprite(_playerImageCache[imageSourceIdentifier]!);
      _isLoadingImage = false; // Found in cache, not loading.
      return;
    }

    // 2. Not in cache. _isLoadingImage was already set to true in onLoad.
    // Start loading from source.
    try {
      Uint8List? imageBytes;
      final imageBase64 = object.imageBase64;
      final imagePath = object.imagePath;
      final isNetworkUrl = imagePath != null && (imagePath.startsWith('http'));

      if (imageBase64 != null && imageBase64.isNotEmpty) {
        // Trigger lazy migration in background (non-blocking)
        ImageMigrationService().queueForMigration(object);

        imageBytes = base64Decode(imageBase64);
      } else if (isNetworkUrl) {
        // Use CachedNetworkImageProvider for disk caching
        final imageProvider = CachedNetworkImageProvider(imagePath!);
        final imageStream = imageProvider.resolve(const ImageConfiguration());

        // Create a completer to wait for the image to load
        final completer = Completer<ui.Image>();
        imageStream.addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            completer.complete(info.image);
          }, onError: (error, stackTrace) {
            completer.completeError(error, stackTrace);
          }),
        );

        final ui.Image cachedImage = await completer.future;
        _playerImageCache[imageSourceIdentifier] = cachedImage;
        _playerImageSprite = Sprite(cachedImage);
        _isLoadingImage = false;
        return; // Early return for network images
      } else if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          imageBytes = await file.readAsBytes();
        }
      }

      if (imageBytes != null) {
        final ui.Image decodedImage = await decodeImageFromList(imageBytes);
        _playerImageCache[imageSourceIdentifier] = decodedImage;
        _playerImageSprite = Sprite(decodedImage);
      }
    } catch (e) {
      zlog(level: Level.error, data: "Failed to load/cache player image: $e");
      _playerImageSprite = null;
    } finally {
      // 3. ALWAYS set loading to false when done (or failed)
      _isLoadingImage = false;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite("ball.png", srcSize: Vector2.zero());
    // await _loadPlayerImage();

    size = object.size ?? Vector2(AppSize.s32, AppSize.s32);
    position = SizeHelper.getBoardActualVector(
      gameScreenSize: game.gameField.size,
      actualPosition: object.offset ?? Vector2(x, y),
    );
    angle = object.angle ?? 0;

    // Set priority from model's zIndex for persistence across reloads
    if (object.zIndex != null) {
      priority = object.zIndex!;
    }

    // Check if we need to load data (logic moved from your _loadPlayerImage)
    final imageKey = _getImageSourceIdentifier();
    if (imageKey != null && !_playerImageCache.containsKey(imageKey)) {
      // Image isn't in cache. Set the flag so the render() method shows the spinner.
      _isLoadingImage = true;
    }

    // Call the load function but DO NOT await it.
    // Let it run in the background. onLoad will now finish instantly.
    _loadPlayerImage();
  }

  @override
  void onMount() {
    super.onMount();

    // Initialize cached team border color
    _updateCachedTeamBorderColor();

    _syncWithDatabase();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check if team border color changed in state and update cached value
    final boardState = ref.read(boardProvider);
    Color? newColor;

    switch (object.playerType) {
      case PlayerType.HOME:
        newColor = boardState.homeTeamBorderColor;
        break;
      case PlayerType.AWAY:
        newColor = boardState.awayTeamBorderColor;
        break;
      case PlayerType.OTHER:
      case PlayerType.UNKNOWN:
        // These don't use global colors, skip check
        return;
    }

    // If color changed, update cache
    if (newColor != null && _cachedTeamBorderColor != newColor) {
      _cachedTeamBorderColor = newColor;
    }

    if (_isLoadingImage) {
      // This spins the start-angle of the arc, creating a rotation effect.
      _loadingArcAngle +=
          dt * 4; // You can change '4' to make it faster or slower
      if (_loadingArcAngle > (3.14159 * 2)) {
        _loadingArcAngle -= (3.14159 * 2);
      }
    }
  }

  /// Initialize the cached team border color from current state
  void _updateCachedTeamBorderColor() {
    final boardState = ref.read(boardProvider);
    switch (object.playerType) {
      case PlayerType.HOME:
        _cachedTeamBorderColor = boardState.homeTeamBorderColor;
        break;
      case PlayerType.AWAY:
        _cachedTeamBorderColor = boardState.awayTeamBorderColor;
        break;
      case PlayerType.OTHER:
      case PlayerType.UNKNOWN:
        _cachedTeamBorderColor = ColorManager.grey;
        break;
    }
  }

  Future<void> _syncWithDatabase() async {
    try {
      final dbPlayer = await PlayerUtilsV2.getPlayerFromDbById(object.id);
      if (dbPlayer == null) return;

      // Check if any relevant field has changed
      final bool needsUpdate = dbPlayer.role != object.role ||
          dbPlayer.displayNumber != object.displayNumber ||
          dbPlayer.imageBase64 != object.imageBase64 ||
          dbPlayer.imagePath !=
              object.imagePath || // Also check imagePath for URL updates
          dbPlayer.name != object.name;

      if (needsUpdate) {
        zlog(data: "Syncing player ${object.id}: Data mismatch found.");
        final oldImageBase64 = object.imageBase64;
        final oldImagePath = object.imagePath;

        final newModelInstance = object.copyWith(
          role: dbPlayer.role,
          // Sync both numbers to be safe, though jerseyNumber shouldn't change
          jerseyNumber: dbPlayer.jerseyNumber,
          displayNumber: dbPlayer.displayNumber,
          imageBase64: dbPlayer.imageBase64,
          imagePath: dbPlayer.imagePath, // Sync the image URL as well
          name: dbPlayer.name,
        );

        object = newModelInstance;

        ref
            .read(boardProvider.notifier)
            .updatePlayerModel(newModel: newModelInstance);

        // Reload image if either base64 or URL changed
        if (dbPlayer.imageBase64 != oldImageBase64 ||
            dbPlayer.imagePath != oldImagePath) {
          await _loadPlayerImage();
        }
      }
    } catch (e) {
      zlog(data: "Error during player sync: $e");
    }
  }

  // In class PlayerComponent

  // In class PlayerComponent

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    // Deselect component when drag starts
    ref.read(boardProvider.notifier).toggleSelectItemEvent(
          fieldItemModel: null,
          camefrom: 'PlayerComponent.onDragStart',
        );

    ref.read(boardProvider.notifier).toggleItemDrag(true); // <-- RESTORE THIS
    ref.read(boardProvider.notifier).clearGuides(); // <-- Good to add this here

    // Show drop zone visual indicator
    if (game is TacticBoard) {
      (game as TacticBoard).dropZone.show();
    }

    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    ref.read(boardProvider.notifier).toggleItemDrag(false); // <-- RESTORE THIS
    ref.read(boardProvider.notifier).clearGuides();

    // Hide drop zone visual indicator
    if (game is TacticBoard) {
      (game as TacticBoard).dropZone.hide();
    }

    // Check if player was dragged to the drop zone (left of field)
    final fieldLeftBoundary = game.gameField.position.x;
    if (position.x < fieldLeftBoundary) {
      // Player dragged to roster area - remove from pitch
      // 1. Remove from game canvas
      game.remove(this);
      // 2. Remove from state using existing method (will auto-return to roster via filtering)
      ref.read(boardProvider.notifier).removeFieldItems([object]);

      // 3. Trigger save
      if (game is TacticBoard) {
        (game as TacticBoard)
            .triggerImmediateSave(reason: 'Player removed via drag');
      }
      return; // Don't save position, player is being removed
    }

    // Phase 1: Trigger immediate save after drag
    if (game is TacticBoard) {
      (game as TacticBoard).triggerImmediateSave(reason: 'Player drag end');
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    ref.read(boardProvider.notifier).toggleItemDrag(false); // <-- RESTORE THIS
    ref.read(boardProvider.notifier).clearGuides();

    // Hide drop zone visual indicator
    if (game is TacticBoard) {
      (game as TacticBoard).dropZone.hide();
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isRotationHandleDragged) {
      super.onDragUpdate(event); // Let the base class handle rotation
      return;
    }
    _activeGuides.clear(); // Clear old guides from last frame

    // 1. Apply the drag (no snapping)
    position.add(event.canvasDelta);

    // 2. Get my new alignment points
    final myCenter = center - Vector2(10, 10);
    // final myTop = myCenter.y - (size.y / 2);
    // final myBottom = myCenter.y + (size.y / 2);
    // final myLeft = myCenter.x - (size.x / 2);
    // final myRight = myCenter.x + (size.x / 2);

    bool didSmartAlign = false; // Flag to track if we found an alignment

    // 3. Find other items to check against
    final otherItems = game.children.where(
        (c) => (c is PlayerComponent || c is EquipmentComponent) && c != this);

    for (final item in otherItems) {
      if (item is! PositionComponent) continue;

      final otherCenter = item.center - Vector2(10, 10);
      final otherTop = otherCenter.y - (item.size.y / 2);
      final otherBottom = otherCenter.y + (item.size.y / 2);
      final otherLeft = otherCenter.x - (item.size.x / 2);
      final otherRight = otherCenter.x + (item.size.x / 2);

      // --- Check X-axis Guides ---
      if ((myCenter.x - otherCenter.x).abs() < _snapTolerance) {
        _activeGuides.add(GuideLine(
          start: Vector2(otherCenter.x, myCenter.y),
          end: Vector2(otherCenter.x, otherCenter.y),
        ));
        didSmartAlign = true;
      }
      // if ((myLeft - otherLeft).abs() < _snapTolerance) {
      //   _activeGuides.add(GuideLine(
      //     start: Vector2(otherLeft, myTop),
      //     end: Vector2(otherLeft, otherTop),
      //   ));
      //   didSmartAlign = true;
      // }
      // if ((myRight - otherRight).abs() < _snapTolerance) {
      //   _activeGuides.add(GuideLine(
      //     start: Vector2(otherRight, myTop),
      //     end: Vector2(otherRight, otherTop),
      //   ));
      //   didSmartAlign = true;
      // }

      // --- Check Y-axis Guides ---
      if ((myCenter.y - otherCenter.y).abs() < _snapTolerance) {
        _activeGuides.add(GuideLine(
          start: Vector2(myCenter.x, otherCenter.y),
          end: Vector2(otherCenter.x, otherCenter.y),
        ));
        didSmartAlign = true;
      }
      // if ((myTop - otherTop).abs() < _snapTolerance) {
      //   _activeGuides.add(GuideLine(
      //     start: Vector2(myLeft, otherTop),
      //     end: Vector2(otherLeft, otherTop),
      //   ));
      //   didSmartAlign = true;
      // }
      // if ((myBottom - otherBottom).abs() < _snapTolerance) {
      //   _activeGuides.add(GuideLine(
      //     start: Vector2(myLeft, otherBottom),
      //     end: Vector2(otherLeft, otherBottom),
      //   ));
      //   didSmartAlign = true;
      // }
    }

    // 4. Update the providers
    ref.read(boardProvider.notifier).updateGuides(_activeGuides);

    // *** THIS IS THE KEY ***
    // Show the grid ONLY if we are NOT showing smart guides
    ref.read(boardProvider.notifier).toggleItemDrag(!didSmartAlign);

    // 5. Update the model
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
      try {
        // This is the missing step: Save the update to the master Sembast DB
        await PlayerUtilsV2.updatePlayerInDb(result.updatedPlayer);
        zlog(
            data:
                "Successfully updated master player DB for ${result.updatedPlayer.id}");
      } catch (e) {
        zlog(data: "Failed to update master player DB: $e");
        // We can still continue to update the local state to keep the UI responsive
      }

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

    // Apply red tint when component is in drop zone
    final fieldLeftBoundary = game.gameField.position.x;
    if (position.x < fieldLeftBoundary) {
      final redTint = ColorFilter.mode(
        ColorManager.red.withOpacity(0.5),
        BlendMode.srcATop,
      );
      canvas.saveLayer(rect, Paint()..colorFilter = redTint);
    }

    // --- THIS IS THE CRITICAL LOGIC ---
    if (_isLoadingImage) {
      // State 1: We are downloading the image. Draw a spinner.
      final spinnerPaint = Paint()
        ..color = ColorManager.yellow // Spinner color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3; // Spinner thickness

      // Draw a spinning arc
      canvas.drawArc(
        size.toRect().deflate(
            size.x * 0.3), // Make the spinner smaller than the component
        _loadingArcAngle, // This is the rotating start angle from our update() loop
        3.14159 * 1.5, // This is the length of the arc (270 degrees)
        false,
        spinnerPaint,
      );
    } else if (object.showImage && _playerImageSprite != null) {
      // State 2: Image is loaded. Draw it.
      _playerImageSprite!.render(
        canvas,
        size: size,
        overridePaint: Paint()..color = Colors.white.withOpacity(baseOpacity),
      );

      // Draw team border when image is shown
      canvas.restore(); // Restore from clip to draw border on top
      canvas.save();

      final Color teamBorderColor = _getTeamBorderColor();
      final borderPaint = Paint()
        ..color = teamBorderColor.withOpacity(baseOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0; // Border thickness

      canvas.drawRRect(rrect, borderPaint);
    } else {
      // State 3: No image to show OR loading failed. Draw the colored placeholder.
      // Use the team border color as the fill color for players without images
      final Color baseColor = _getTeamBorderColor();
      _backgroundPaint.color = baseColor.withOpacity(baseOpacity);
      _backgroundPaint.style = PaintingStyle.fill;
      canvas.drawRRect(rrect, _backgroundPaint);

      // Only show role if showRole is true AND role is not "-" (neutral)
      if (object.showRole && object.role != '-') {
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
    // --- END NEW RENDER LOGIC ---

    // Restore layer if red tint was applied
    if (position.x < fieldLeftBoundary) {
      canvas.restore();
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
    // Only show name if showName is true AND name is not empty/null AND name is not "-" (neutral)
    if (object.showName &&
        playerName != null &&
        playerName.isNotEmpty &&
        playerName != '-') {
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

  String? _getImageSourceIdentifier() {
    final imageBase64 = object.imageBase64;
    final imagePath = object.imagePath;

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      return imageBase64;
    }
    if (imagePath != null && imagePath.isNotEmpty) {
      // This key works whether it's a local path OR a network URL
      return imagePath;
    }
    return null;
  }

  /// Gets the border color for the player based on their team
  /// Priority: 1) Individual player color, 2) Cached global team color, 3) Fallback
  Color _getTeamBorderColor() {
    // Priority 1: Check if player has a custom border color set (individual override)
    if (object.borderColor != null) {
      return object.borderColor!;
    }

    // Priority 2: Use cached team color (updated by listener)
    if (_cachedTeamBorderColor != null) {
      return _cachedTeamBorderColor!;
    }

    // Priority 3: Fallback - read directly from state (for initial render before listener sets up)
    final boardState = ref.read(boardProvider);
    switch (object.playerType) {
      case PlayerType.HOME:
        return boardState.homeTeamBorderColor;
      case PlayerType.AWAY:
        return boardState.awayTeamBorderColor;
      case PlayerType.OTHER:
        return ColorManager.grey;
      case PlayerType.UNKNOWN:
        return ColorManager.grey;
    }
  }
}
