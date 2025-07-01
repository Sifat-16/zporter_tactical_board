import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flame/extensions.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_capture_x_plus/widget_capture_x_plus.dart';
import 'package:widget_capture_x_plus/widget_capture_x_plus_controller.dart';
import 'package:zporter_tactical_board/app/core/component/z_loader.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/app/helper/animation_sharer.dart';
import 'package:zporter_tactical_board/app/helper/file_name_generator.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/app/helper/size_helper.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/animation_controls_widget.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/mixin/animation_playback_mixin.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/form_speed_dial_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/animation/animation_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

enum AnimationShareType { image, video }

final GlobalKey<RiverpodAwareGameWidgetState> gameWidgetKey =
    GlobalKey<RiverpodAwareGameWidgetState>();
final GlobalKey _gameBoundaryKey = GlobalKey();

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
  TacticBoard? tacticBoardGame;
  bool gameInitialized = false;
  int previousAngle = 0;

  final WidgetCaptureXPlusController _widgetCaptureXPlusController =
      WidgetCaptureXPlusController(
          outputBaseFileName:
              FileNameGenerator.generateZporterCaptureFilename());

  final closeButtonColor = Colors.grey[300];
  final closeButtonBackgroundColor = Colors.black;

  final ValueNotifier<double> _exportProgressNotifier =
      ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _isFinalizingVideoNotifier =
      ValueNotifier<bool>(false);

  // This will hold the context of the dialog that is currently shown.
  // It's crucial for popping the correct dialog instance.
  BuildContext? _currentExportDialogContext;

  @override
  void initState() {
    super.initState();
    createTacticBoardIfNecessary(widget.scene);
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene?.id == widget.scene?.id) {
      WidgetsBinding.instance.addPostFrameCallback((t) {
        if (!mounted) return;
        if (ref.read(animationProvider).isPerformingUndo == true) {
          updateTacticBoardIfNecessary(widget.scene);
          ref.read(animationProvider.notifier).toggleUndo(undo: false);
        }
      });
    } else {
      updateTacticBoardIfNecessary(widget.scene);
    }
  }

  @override
  void dispose() {
    _exportProgressNotifier.dispose();
    _isFinalizingVideoNotifier.dispose();
    if (_currentExportDialogContext != null &&
        mounted &&
        Navigator.canPop(_currentExportDialogContext!)) {
      Navigator.of(_currentExportDialogContext!).pop(null);
    }
    _currentExportDialogContext = null;
    super.dispose();
  }

  bool isBoardBusy(BoardState bp) {
    return bp.animatingObj != null;
  }

  createTacticBoardIfNecessary(AnimationItemModel? selectedScene) {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      if (!mounted) return;

      setState(() {
        tacticBoardGame = TacticBoard(
          myContext: context,
          scene: selectedScene,
          saveToDb: widget.saveToDb,
          onSceneSave: widget.onSceneSave,
        );
        zlog(data: "Build new tactic board");
        print("The scene and the screen is updating");
        if (mounted) {
          ref.read(boardProvider.notifier).updateBoardBackground(
              selectedScene?.boardBackground ?? BoardBackground.full);
          ref.read(boardProvider.notifier).updateGameBoard(tacticBoardGame);
          ref.read(boardProvider.notifier).updateBoardColor(
                ref.read(animationProvider.notifier).getFieldColor(),
              );
          gameInitialized = true;
        }
      });
    });
  }

  updateTacticBoardIfNecessary(AnimationItemModel? selectedScene) {
    createTacticBoardIfNecessary(selectedScene);
  }

  Future<RecordingOutput?> _showVideoExportProgressDialog() async {
    // Ensure any previous dialog is closed before showing a new one.
    if (_currentExportDialogContext != null &&
        mounted &&
        Navigator.canPop(_currentExportDialogContext!)) {
      Navigator.of(_currentExportDialogContext!).pop(null);
    }
    _currentExportDialogContext = null;

    _exportProgressNotifier.value = 0.0;
    _isFinalizingVideoNotifier.value = false;

    try {
      zlog(data: "Starting widget recording for video export.");
      await _widgetCaptureXPlusController.startRecording();
      zlog(data: "Widget recording started.");
    } catch (e, s) {
      zlog(data: "Error starting widget recording: $e\n$s");
      BotToast.showText(
          text: "Failed to start video recording. Please try again.");
      // Ensure state is reset if recording fails to start.
      // The caller (onShare) will handle resetting boardProvider state.
      return null;
    }

    RecordingOutput? dialogResult = await showDialog<RecordingOutput?>(
      context: context,
      barrierColor: ColorManager.black,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Store the context for this specific dialog instance.
        _currentExportDialogContext = dialogContext;
        return AlertDialog(
          backgroundColor: ColorManager.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: ValueListenableBuilder<bool>(
            /* ... Title UI ... */
            valueListenable: _isFinalizingVideoNotifier,
            builder: (context, isFinalizing, child) => Text(
                isFinalizing ? 'Finalizing Video' : 'Exporting Animation',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ColorManager.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          content: ValueListenableBuilder<bool>(
            /* ... Content UI (Progress vs Finalizing) ... */
            valueListenable: _isFinalizingVideoNotifier,
            builder: (context, isFinalizing, child) {
              if (isFinalizing) {
                /* ... Finalizing UI with ZLoader ... */
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  ZLoader(logoAssetPath: 'assets/image/logo.png'),
                  const SizedBox(height: 20),
                  Text('Processing...',
                      style: TextStyle(
                          color: ColorManager.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Please wait a moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: ColorManager.white.withOpacity(0.7),
                          fontSize: 14))
                ]);
              } else {
                /* ... Progress UI (0-100%) ... */
                return ValueListenableBuilder<double>(
                    valueListenable: _exportProgressNotifier,
                    builder: (context, progressValue, child) {
                      return Column(mainAxisSize: MainAxisSize.min, children: [
                        Stack(alignment: Alignment.center, children: [
                          SizedBox(
                              width: 90,
                              height: 90,
                              child: CircularProgressIndicator(
                                  value: progressValue,
                                  strokeWidth: 7.0,
                                  backgroundColor: Colors.grey.shade700,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      ColorManager.yellow))),
                          ClipOval(
                              child: Image.asset('assets/image/logo.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) => Icon(
                                      Icons.video_library,
                                      size: 40,
                                      color: Colors.white54)))
                        ]),
                        const SizedBox(height: 20),
                        Text('${(progressValue * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                                color: ColorManager.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Please wait, generating video...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColorManager.white.withOpacity(0.7),
                                fontSize: 14))
                      ]);
                    });
              }
            },
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 15.0, top: 5.0),
          actions: <Widget>[
            ValueListenableBuilder<bool>(
              /* ... Cancel Button UI ... */
              valueListenable: _isFinalizingVideoNotifier,
              builder: (context, isFinalizing, child) {
                if (isFinalizing) return const SizedBox.shrink();
                return TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              color: Colors.redAccent.withOpacity(0.7)))),
                  child: const Text('Cancel Export',
                      style: TextStyle(color: Colors.redAccent, fontSize: 15)),
                  onPressed: () async {
                    zlog(data: "User tapped Cancel Export button.");
                    // Stop game animation first
                    if (gameInitialized) {
                      tacticBoardGame?.performStopAnimation(hardReset: false);
                    }

                    RecordingOutput? cancelledRecOutput;
                    try {
                      zlog(
                          data:
                              "Stopping widget recording due to cancellation.");
                      cancelledRecOutput =
                          await _widgetCaptureXPlusController.stopRecording();
                      zlog(
                          data:
                              "Widget recording stopped on cancel. Output: ${cancelledRecOutput?.filePath}, Success: ${cancelledRecOutput?.success}.");
                    } catch (e, s) {
                      zlog(data: "Error stopping recording on cancel: $e\n$s");
                    }

                    // Pop with null to signify cancellation to the awaiter of _showVideoExportProgressDialog
                    if (mounted && Navigator.canPop(dialogContext)) {
                      // Use dialogContext directly here
                      Navigator.of(dialogContext).pop(null);
                    }
                    _exportProgressNotifier.value = 0.0; // Reset notifiers
                    _isFinalizingVideoNotifier.value = false;
                    BotToast.showText(text: "Video export cancelled by user.");
                    // The boardProvider state will be reset by the caller (onShare)
                  },
                );
              },
            ),
          ],
        );
      },
    );

    // Cleanup _currentExportDialogContext after showDialog completes (either by pop or future completion)
    _currentExportDialogContext = null;
    _isFinalizingVideoNotifier.value = false; // Ensure this is reset

    // If dialogResult is null here, it means it was popped with null (cancel/error) or an issue occurred.
    // If export was still marked active in provider, onShare will clean it up.
    zlog(data: "showDialog completed. Returning: ${dialogResult?.filePath}");
    return dialogResult;
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    int quarterTurns = bp.boardAngle;

    // if (quarterTurns != previousAngle) {
    //   updateTacticBoardIfNecessary(widget.scene);
    // }

    ref.listen(boardProvider, (prev, current) {
      if (prev?.showFullScreen != current.showFullScreen) {
        if (gameInitialized) {
          tacticBoardGame?.redrawLines();
        }
      }
      if (current.refreshBoard == true) {
        if (gameInitialized) {
          tacticBoardGame?.redrawLines();
        }
        if (mounted) {
          ref.read(boardProvider.notifier).toggleRefreshBoard(false);
        }
      }
      // If animatingObj is cleared externally while dialog is up, dismiss dialog
      if (prev?.animatingObj != null &&
          current.animatingObj == null &&
          _currentExportDialogContext != null) {
        if (mounted && Navigator.canPop(_currentExportDialogContext!)) {
          Navigator.of(_currentExportDialogContext!).pop(null);
          zlog(
              data:
                  "AnimatingObj cleared externally, dismissing export dialog with null.");
        }
      }
    });
    previousAngle = quarterTurns;

    return DragTarget<FieldItemModel>(
      /* ... (onAcceptWithDetails - Same as before) ... */
      onAcceptWithDetails: (details) async {
        if (tacticBoardGame == null) return;
        // if (!gameInitialized ||
        //     isBoardBusy(bp) ||
        //     _currentExportDialogContext != null) {
        //   return;
        // }
        // FieldItemModel fieldItemModel = details.data;
        // final RenderBox gameScreenBox = context.findRenderObject() as RenderBox;
        // final Vector2 gameScreenSize = gameScreenBox.size.toVector2();
        // final double gameScreenWidth = gameScreenSize.x;
        // final Offset globalGameScreenOffset =
        //     gameScreenBox.localToGlobal(Offset.zero);
        // final Vector2 screenRelativeOffset =
        //     details.offset.toVector2() - globalGameScreenOffset.toVector2();
        // final double dx = screenRelativeOffset.x;
        // final double dy = screenRelativeOffset.y;
        // Vector2 transformedOffset = (quarterTurns == 1)
        //     ? Vector2(dy, gameScreenWidth - dx)
        //     : screenRelativeOffset;
        // Vector2 actualPosition =
        //     transformedOffset + tacticBoardGame.gameField.position;
        // fieldItemModel.offset = SizeHelper.getBoardRelativeVector(
        //     gameScreenSize: gameScreenSize, actualPosition: actualPosition);
        //
        // if (fieldItemModel is EquipmentModel) {
        //   fieldItemModel =
        //       fieldItemModel.copyWith(id: RandomGenerator.generateId());
        // }
        //
        // await tacticBoardGame.addItem(fieldItemModel);

        // 1. Initial checks to ensure the board is ready to accept items.
        if (!gameInitialized ||
            isBoardBusy(bp) ||
            _currentExportDialogContext != null) {
          return;
        }

        // 2. Get the data for the item that was dropped.
        FieldItemModel fieldItemModel = details.data;

        // 3. [NEW] Get the item's size to calculate its center.
        // We provide a default size in case the model's size is null.
        // You should use the same default you use in your components (e.g., AppSize.s32).
        final Vector2 itemSize = fieldItemModel.size ?? Vector2(32.0, 32.0);

        // 4. Find the position and size of the game widget on the screen.
        final RenderBox gameScreenBox = context.findRenderObject() as RenderBox;
        final Vector2 gameScreenSize = gameScreenBox.size.toVector2();
        final double gameScreenWidth = gameScreenSize.x;
        final Offset globalGameScreenOffset =
            gameScreenBox.localToGlobal(Offset.zero);

        // 5. Calculate the cursor's drop position relative to the game widget's top-left corner.
        final Vector2 screenRelativeOffset =
            details.offset.toVector2() - globalGameScreenOffset.toVector2();
        final double dx = screenRelativeOffset.x;
        final double dy = screenRelativeOffset.y;

        // 6. Determine the cursor's absolute position on the canvas, accounting for board rotation.
        final Vector2 cursorPosition = (quarterTurns == 1)
            ? Vector2(dy, gameScreenWidth - dx)
            : screenRelativeOffset;

        // 7. [NEW FIX] Adjust the position to place the ITEM'S CENTER under the cursor.
        // We do this by subtracting half of the item's width and height.
        final Vector2 centerOffset = itemSize / 2;
        final Vector2 adjustedTargetPosition = cursorPosition + centerOffset;

        // 8. [PREVIOUS FIX] Convert the adjusted absolute position into a relative offset for storage.
        fieldItemModel.offset = SizeHelper.getBoardRelativeVector(
          gameScreenSize: tacticBoardGame!.gameField.size,
          actualPosition:
              adjustedTargetPosition, // Use the new adjusted position
        );

        // 9. If the item is equipment (like a cone), give it a new unique ID.
        if (fieldItemModel is EquipmentModel) {
          fieldItemModel =
              fieldItemModel.copyWith(id: RandomGenerator.generateId());
        }

        // 10. Add the fully configured item to the tactic board.
        await tacticBoardGame?.addItem(fieldItemModel);
      },
      builder: (BuildContext context, List<Object?> candidateData,
          List<dynamic> rejectedData) {
        if (!gameInitialized) {
          return Center(
              child: Text("Field is not initialized. Contact developer!!",
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: ColorManager.white)));
        }
        return tacticBoardGame == null
            ? SizedBox.shrink()
            : RotatedBox(
                quarterTurns: quarterTurns,
                child: Stack(
                  children: [
                    RepaintBoundary(
                        key: _gameBoundaryKey,
                        child: WidgetCaptureXPlus(
                            controller: _widgetCaptureXPlusController,
                            childToRecord: Container(
                                padding: EdgeInsets.only(bottom: 0),
                                child: RiverpodAwareGameWidget(
                                    game: tacticBoardGame!,
                                    key: gameWidgetKey)))),
                    if (isBoardBusy(bp) &&
                        bp.animatingObj != null &&
                        ref.read(animationProvider).selectedAnimationModel !=
                            null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Offstage(
                          offstage: _currentExportDialogContext != null,
                          child: SizedBox(
                            height: 35,
                            child: AnimationControlsWidget(
                              key: ValueKey(
                                  "${bp.animatingObj.hashCode}_${ref.read(animationProvider).selectedAnimationModel!.id}"),
                              animatingObj: bp.animatingObj!,
                              game: tacticBoardGame!,
                              animationModel: ref
                                  .read(animationProvider)
                                  .selectedAnimationModel!
                                  .copyWith(),
                              initialIsPlaying: bp.animatingObj!.isAnimating &&
                                  !bp.animatingObj!.isExporting,
                              initialPaceFactor: 1.0,
                              onExportProgressCallback: (progress) async {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((t) async {
                                  _exportProgressNotifier.value = progress;
                                  if (progress >= 1.0 &&
                                      !_isFinalizingVideoNotifier.value) {
                                    _isFinalizingVideoNotifier.value = true;
                                    zlog(
                                        data:
                                            "Animation playback 100%. Switched to finalizing video state.");
                                    RecordingOutput? recordingOutput;
                                    try {
                                      zlog(
                                          data:
                                              "Stopping widget recording (finalization step).");
                                      recordingOutput =
                                          await _widgetCaptureXPlusController
                                              .stopRecording();
                                      zlog(
                                          data:
                                              "Widget recording stopped. Output: ${recordingOutput?.filePath}, Success: ${recordingOutput?.success}");
                                    } catch (e, s) {
                                      zlog(
                                        data:
                                            "Error stopping widget recording (finalization step): $e\n$s",
                                      );
                                    }

                                    if (_currentExportDialogContext != null &&
                                        mounted &&
                                        Navigator.canPop(
                                            _currentExportDialogContext!)) {
                                      // This is the crucial pop that returns the result to _showVideoExportProgressDialog's awaiter
                                      Navigator.of(_currentExportDialogContext!)
                                          .pop(recordingOutput);
                                    }
                                    // _isFinalizingVideoNotifier and provider state are reset by the caller of _showVideoExportProgressDialog (onShare)
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      )
                    else if (_currentExportDialogContext == null)
                      Align(
                        /* ... (FormSpeedDialComponent) ... */
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 30,
                          child: FormSpeedDialComponent(
                              tacticBoardGame: tacticBoardGame!,
                              config: widget.config ??
                                  FormSpeedDialConfig(
                                    onShare: () async {
                                      AnimationModel? selectedAnimation = ref
                                          .read(animationProvider)
                                          .selectedAnimationModel;
                                      if (isBoardBusy(bp)) {
                                        BotToast.showText(
                                            text:
                                                "Please wait for the current operation to complete.");
                                        return;
                                      }
                                      if (selectedAnimation == null) {
                                        await AnimationSharer.captureAndShare(
                                            _gameBoundaryKey,
                                            context: context,
                                            fileName: FileNameGenerator
                                                .generateZporterCaptureFilename());
                                      } else {
                                        AnimationShareType? type =
                                            await _showShareChoiceDialog(
                                                context, 'Share As');
                                        if (type == AnimationShareType.image) {
                                          await AnimationSharer.captureAndShare(
                                              _gameBoundaryKey,
                                              context: context,
                                              fileName: FileNameGenerator
                                                  .generateZporterCaptureFilename());
                                        } else if (type ==
                                            AnimationShareType.video) {
                                          if (!mounted) return;

                                          // 1. Set state to exporting
                                          if (mounted) {
                                            ref
                                                .read(boardProvider.notifier)
                                                .toggleAnimating(
                                                    animatingObj:
                                                        AnimatingObj.export());
                                          }

                                          // 2. Show dialog (which starts recording) and await its result
                                          final RecordingOutput? finalOutput =
                                              await _showVideoExportProgressDialog();
                                          zlog(
                                              data:
                                                  "Awaited _showVideoExportProgressDialog. Final Output: ${finalOutput?.filePath}, Success: ${finalOutput?.success}");

                                          // 3. Dialog is closed, now reset board state fully
                                          if (mounted) {
                                            ref
                                                .read(boardProvider.notifier)
                                                .toggleAnimating(
                                                    animatingObj: null);
                                          }

                                          // 4. Process the result
                                          if (finalOutput != null &&
                                              finalOutput.success &&
                                              finalOutput.filePath != null) {
                                            try {
                                              AnimationSharer.shareImageFile(
                                                context: context,
                                                finalOutput.filePath!,
                                                // text: Platform.isIOS
                                                //     ? null
                                                //     : "Zporter Football Pad Animation",
                                                // title: Platform.isIOS
                                                //     ? "Zporter Football Pad Animation"
                                                //     : null,
                                                text: Platform.isIOS
                                                    ? null
                                                    : "${finalOutput.filePath!.split("/").last}",
                                                title: Platform.isIOS
                                                    ? "${finalOutput.filePath!.split("/").last}"
                                                    : null,
                                                subject:
                                                    "Check out this from my Zporter Football Pad",
                                              );
                                              zlog(
                                                  data:
                                                      "Video ready for sharing: ${finalOutput.filePath}");
                                            } catch (e) {}

                                            // TODO: Share/Save finalOutput.filePath
                                            // Example: await AnimationSharer.shareFile(finalOutput.filePath!);
                                          } else if (finalOutput != null &&
                                              !finalOutput.success) {
                                            BotToast.showText(
                                                text:
                                                    "Video export failed: ${finalOutput.errorMessage ?? 'Unknown error.'}");
                                          } else {
                                            // finalOutput is null
                                            BotToast.showText(
                                                text:
                                                    "Video export was cancelled or did not complete.");
                                          }
                                        }
                                      }
                                    },
                                    onDownload: () async {
                                      AnimationModel? selectedAnimation = ref
                                          .read(animationProvider)
                                          .selectedAnimationModel;
                                      if (isBoardBusy(bp)) {
                                        BotToast.showText(
                                            text:
                                                "Please wait for the current operation to complete.");
                                        return;
                                      }
                                      if (selectedAnimation == null) {
                                        await AnimationDownloader
                                            .captureAndDownload(
                                                _gameBoundaryKey,
                                                fileName: FileNameGenerator
                                                    .generateZporterCaptureFilename());
                                      } else {
                                        AnimationShareType? type =
                                            await _showShareChoiceDialog(
                                                context, 'Download As');
                                        if (type == AnimationShareType.image) {
                                          await AnimationDownloader
                                              .captureAndDownload(
                                                  _gameBoundaryKey,
                                                  fileName: FileNameGenerator
                                                      .generateZporterCaptureFilename());
                                        } else if (type ==
                                            AnimationShareType.video) {
                                          if (!mounted) return;

                                          // 1. Set state to exporting
                                          if (mounted) {
                                            ref
                                                .read(boardProvider.notifier)
                                                .toggleAnimating(
                                                    animatingObj:
                                                        AnimatingObj.export());
                                          }

                                          // 2. Show dialog (which starts recording) and await its result
                                          final RecordingOutput? finalOutput =
                                              await _showVideoExportProgressDialog();
                                          zlog(
                                              data:
                                                  "Awaited _showVideoExportProgressDialog. Final Output: ${finalOutput?.filePath}, Success: ${finalOutput?.success}");

                                          // 3. Dialog is closed, now reset board state fully
                                          if (mounted) {
                                            ref
                                                .read(boardProvider.notifier)
                                                .toggleAnimating(
                                                    animatingObj: null);
                                          }

                                          // 4. Process the result
                                          if (finalOutput != null &&
                                              finalOutput.success &&
                                              finalOutput.filePath != null) {
                                            AnimationDownloader.downloadFile(
                                                finalOutput.filePath!,
                                                text:
                                                    "${FileNameGenerator.generateZporterCaptureFilename()}.mp4");
                                            zlog(
                                                data:
                                                    "Video ready for sharing: ${finalOutput.filePath}");
                                            // TODO: Share/Save finalOutput.filePath
                                            // Example: await AnimationSharer.shareFile(finalOutput.filePath!);
                                          } else if (finalOutput != null &&
                                              !finalOutput.success) {
                                            BotToast.showText(
                                                text:
                                                    "Video export failed: ${finalOutput.errorMessage ?? 'Unknown error.'}");
                                          } else {
                                            // finalOutput is null
                                            BotToast.showText(
                                                text:
                                                    "Video export was cancelled or did not complete.");
                                          }
                                        }
                                      }
                                    },
                                  )),
                        ),
                      ),
                    if (bp.animatingObj?.isAnimating == true &&
                        !bp.animatingObj!.isExporting &&
                        _currentExportDialogContext == null)
                      Positioned(
                        /* ... (Close button for normal animation) ... */
                        top: 10.0,
                        right: 10.0,
                        child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              splashColor: Colors.white12,
                              onTap: () {
                                tacticBoardGame?.performStopAnimation();
                                if (mounted) {
                                  ref
                                      .read(boardProvider.notifier)
                                      .toggleAnimating(animatingObj: null);
                                }
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: closeButtonBackgroundColor,
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.close,
                                      color: closeButtonColor, size: 26.0)),
                            )),
                      ),
                  ],
                ),
              );
      },
    );
  }

  Future<AnimationShareType?> _showShareChoiceDialog(
      BuildContext context, String title) async {
    /* ... (Same as before) ... */
    return await showDialog<AnimationShareType>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return SimpleDialog(
              backgroundColor: ColorManager.black,
              title: Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: ColorManager.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              children: <Widget>[
                SimpleDialogOption(
                    onPressed: () =>
                        Navigator.pop(dialogContext, AnimationShareType.image),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(children: [
                          Icon(Icons.image_outlined,
                              color: ColorManager.white.withOpacity(0.8)),
                          const SizedBox(width: 10),
                          Text('Image (Current Scene)',
                              style: TextStyle(
                                  color: ColorManager.white, fontSize: 16))
                        ]))),
                SimpleDialogOption(
                    onPressed: () =>
                        Navigator.pop(dialogContext, AnimationShareType.video),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(children: [
                          Icon(Icons.videocam_outlined,
                              color: ColorManager.white.withOpacity(0.8)),
                          const SizedBox(width: 10),
                          Text('Video/GIF (Animation)',
                              style: TextStyle(
                                  color: ColorManager.white, fontSize: 16))
                        ]))),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(
                        color: ColorManager.grey.withOpacity(0.3), height: 1)),
                SimpleDialogOption(
                    onPressed: () => Navigator.pop(dialogContext, null),
                    child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: ColorManager.grey, fontSize: 14)))))
              ]);
        });
  }
}
