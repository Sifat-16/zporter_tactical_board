import 'dart:typed_data';

import 'package:flame/extensions.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/helper/animation_sharer.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/form_speed_dial_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/form/line/line_provider.dart';

import 'animation_export_preview.dart';

enum AnimationShareType { image, video }

final GlobalKey<RiverpodAwareGameWidgetState> gameWidgetKey =
    GlobalKey<RiverpodAwareGameWidgetState>();
final GlobalKey _gameBoundaryKey = GlobalKey();

// final GlobalKey<RiverpodAwareGameWidgetState> largeGameWidgetKey =
//     GlobalKey<RiverpodAwareGameWidgetState>();

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    super.key,
    required this.scene,
    this.config,
    this.saveToDb = true,
    this.onSceneSave,
  });
  final AnimationItemModel? scene;
  final FormSpeedDialConfig? config;
  final bool saveToDb;
  final Function(AnimationItemModel?)? onSceneSave;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late TacticBoard tacticBoardGame;
  bool gameInitialized = false;
  int previousAngle = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateTacticBoardIfNecessary(widget.scene);
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene?.id == widget.scene?.id) {
      WidgetsBinding.instance.addPostFrameCallback((t) {
        if (ref.read(animationProvider).isPerformingUndo == true) {
          updateTacticBoardIfNecessary(widget.scene);
          ref.read(animationProvider.notifier).toggleUndo(undo: false);
        }
      });
    } else {
      updateTacticBoardIfNecessary(widget.scene);
    }
  }

  updateTacticBoardIfNecessary(AnimationItemModel? selectedScene) {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      setState(() {
        boardComparator = null;
        tacticBoardGame = TacticBoard(
          scene: selectedScene,
          saveToDb: widget.saveToDb,
          onSceneSave: widget.onSceneSave,
        );
        zlog(data: "Build new tactic board");
        ref.read(boardProvider.notifier).updateGameBoard(tacticBoardGame);
        ref
            .read(boardProvider.notifier)
            .updateBoardColor(
              ref.read(animationProvider.notifier).getFieldColor(),
            );
        gameInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    final lp = ref.watch(lineProvider);
    int quarterTurns = bp.boardAngle;
    if (quarterTurns != previousAngle) {
      updateTacticBoardIfNecessary(widget.scene);
    }
    ref.listen(boardProvider, (prev, current) {
      if (prev?.showFullScreen != current.showFullScreen) {
        tacticBoardGame.redrawLines();
      }
      if (current.refreshBoard == true) {
        tacticBoardGame.redrawLines();
        ref.read(boardProvider.notifier).toggleRefreshBoard(false);
      }
    });
    previousAngle = quarterTurns;
    return DragTarget<FieldItemModel>(
      onAcceptWithDetails: (DragTargetDetails<FieldItemModel> dragDetails) {
        if (!gameInitialized) return; // Ensure game is ready

        FieldItemModel fieldItemModel = dragDetails.data;
        final RenderBox gameScreenBox = context.findRenderObject() as RenderBox;

        // --- Essential: Get the size of the widget BEFORE rotation ---
        final Vector2 gameScreenSize = gameScreenBox.size.toVector2();
        final double gameScreenWidth = gameScreenSize.x;
        // final double gameScreenHeight = gameScreenSize.height; // Needed for turns 2, 3

        // 1. Calculate offset relative to the GameScreen's top-left (in SCREEN orientation)
        final Offset globalGameScreenOffset = gameScreenBox.localToGlobal(
          Offset.zero,
        );
        final Vector2 screenRelativeOffset =
            dragDetails.offset.toVector2() - globalGameScreenOffset.toVector2();
        final double dx =
            screenRelativeOffset
                .x; // Horizontal distance from left in screen coords
        final double dy =
            screenRelativeOffset
                .y; // Vertical distance from top in screen coords

        Vector2 transformedOffset;
        if (quarterTurns == 1) {
          transformedOffset = Vector2(dy, gameScreenWidth - dx);
        } else {
          transformedOffset = screenRelativeOffset; // Use the original offset
        }

        Vector2 actualPosition =
            transformedOffset + tacticBoardGame.gameField.position;

        fieldItemModel.offset = SizeHelper.getBoardRelativeVector(
          gameScreenSize: gameScreenSize,
          actualPosition: actualPosition,
        );
        tacticBoardGame.addItem(fieldItemModel);
      },
      builder: (
        BuildContext context,
        List<Object?> candidateData,
        List<dynamic> rejectedData,
      ) {
        if (!gameInitialized) {
          return Center(
            child: Text(
              "Field is not initialized. Contact developer!!",
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: ColorManager.white),
            ),
          );
        }
        return RotatedBox(
          quarterTurns: quarterTurns,
          child: Stack(
            children: [
              RepaintBoundary(
                key: _gameBoundaryKey,
                child: Container(
                  padding: EdgeInsets.only(bottom: 0),
                  child: RiverpodAwareGameWidget(
                    game: tacticBoardGame,
                    key: gameWidgetKey,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 30,
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FormSpeedDialComponent(
                        tacticBoardGame: tacticBoardGame,
                        config:
                            widget.config ??
                            FormSpeedDialConfig(
                              onShare: () async {
                                AnimationModel? selectedAnimation =
                                    ref
                                        .read(animationProvider)
                                        .selectedAnimationModel;
                                if (selectedAnimation == null) {
                                  /// no animation here, so direct go for image
                                  await AnimationSharer.captureAndShare(
                                    _gameBoundaryKey,
                                    fileName: "Test scene",
                                  );
                                  zlog(
                                    data: "After sharing tapped, came result",
                                  );
                                } else {
                                  /// animation is here, give user option to export
                                  AnimationShareType? animationShareType =
                                      await _showShareChoiceDialog(context);
                                  if (animationShareType ==
                                      AnimationShareType.image) {
                                    await AnimationSharer.captureAndShare(
                                      _gameBoundaryKey,
                                      fileName: "Test scene",
                                    );
                                    zlog(
                                      data: "After sharing tapped, came result",
                                    );
                                  } else if (animationShareType ==
                                      AnimationShareType.video) {
                                    final GlobalKey captureKeyForExport =
                                        GlobalKey();
                                    List<Uint8List>? capturedFrames;
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (_) => Scaffold(
                                              body: Center(
                                                child: AnimationExportPreview(
                                                  animationModel:
                                                      selectedAnimation, // Pass the current animation model
                                                  repaintBoundaryKey:
                                                      captureKeyForExport, // Pass the key for capturing
                                                  onExportComplete: (
                                                    List<Uint8List> frames,
                                                  ) {
                                                    zlog(
                                                      data:
                                                          "AnimationScreen: Frame capture in dialog COMPLETE. ${frames.length} frames received.",
                                                    );
                                                    capturedFrames = frames;
                                                    if (Navigator.canPop(
                                                      context,
                                                    )) {
                                                      Navigator.of(
                                                        context,
                                                      ).pop(); // Close the preview dialog
                                                    }
                                                  },
                                                  onExportCancelled: () {
                                                    zlog(
                                                      data:
                                                          "AnimationScreen: Export cancelled by user from dialog.",
                                                    );
                                                    // No need to pop, dialog handles its own pop on cancel
                                                  },
                                                ),
                                              ),
                                            ),
                                      ),
                                    );
                                    // After dialog closes, if frames were captured, proceed to encode and share
                                    if (capturedFrames != null &&
                                        capturedFrames!.isNotEmpty &&
                                        mounted) {
                                      await AnimationSharer.createGifAndShare(
                                        capturedFrames!,
                                      );
                                    } else if (mounted) {
                                      zlog(
                                        data:
                                            "AnimationScreen: No frames captured or export was cancelled.",
                                      );
                                      // BotToast.showText(text: "GIF generation cancelled or failed.");
                                    }
                                  }
                                }
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<AnimationShareType?> _showShareChoiceDialog(
    BuildContext context,
  ) async {
    return await showDialog<AnimationShareType>(
      context: context,
      barrierDismissible:
          true, // User can tap outside to dismiss (will return null)
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          backgroundColor: ColorManager.black, // Dark theme background
          title: Text(
            'Share As',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorManager.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  AnimationShareType.image,
                ); // Return the choice
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: ColorManager.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Image (Current Scene)',
                      style: TextStyle(color: ColorManager.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  AnimationShareType.video,
                ); // Return the choice
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.videocam_outlined,
                      color: ColorManager.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Video/GIF (Animation)',
                      style: TextStyle(color: ColorManager.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              // Optional: Add a small divider
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: ColorManager.grey.withOpacity(0.3),
                height: 1,
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext, null); // Return null for cancel
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: ColorManager.grey, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ); // If dismissed, showDialog returns null
  }
}
