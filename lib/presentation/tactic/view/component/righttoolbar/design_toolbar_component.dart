import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zporter_tactical_board/app/core/component/color_picker_slider.dart';
import 'package:zporter_tactical_board/app/core/component/custom_slider.dart';
import 'package:zporter_tactical_board/app/core/component/opacity_slider.dart';
import 'package:zporter_tactical_board/app/core/component/switcher_component.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/free_draw_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/line_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/shape_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

class DesignToolbarComponent extends ConsumerStatefulWidget {
  const DesignToolbarComponent({super.key});

  @override
  ConsumerState<DesignToolbarComponent> createState() =>
      _DesignToolbarComponentState();
}

class _DesignToolbarComponentState
    extends ConsumerState<DesignToolbarComponent> {
  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);
    return bp.selectedItemOnTheBoard == null
        ? Center(
            child: Text(
              "Tap and mark what to redesign",
              style: Theme.of(
                context,
              ).textTheme.labelMedium!.copyWith(color: ColorManager.white),
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
            child: ListView(
              children: [
                // NEW: Apply to All Similar Items Toggle
                _buildApplyToAllToggle(boardState: bp),
                SizedBox(height: 20),
                _buildTopActionWidget(boardState: bp),
                SizedBox(height: 20),
                _buildFillColorWidget("Fill Color", boardState: bp),
                SizedBox(height: 20),
                _buildOpacitySliderWidget(boardState: bp),
                SizedBox(height: 20),
                // REMOVED: The old aerial pass switcher is now gone from here.
                if (bp.selectedItemOnTheBoard is PlayerModel)
                  _buildSwitcherWidget(
                      playerModel: bp.selectedItemOnTheBoard as PlayerModel),
              ],
            ),
          );
  }

  // NEW: Build the "Apply to All Similar Items" toggle
  Widget _buildApplyToAllToggle({required BoardState boardState}) {
    final selectedItem = boardState.selectedItemOnTheBoard;

    // Determine what "similar items" means for the selected item
    String similarItemsLabel = "";
    if (selectedItem is PlayerModel) {
      if (selectedItem.playerType == PlayerType.HOME) {
        similarItemsLabel = "all Home team players";
      } else if (selectedItem.playerType == PlayerType.AWAY) {
        similarItemsLabel = "all Away team players";
      } else if (selectedItem.playerType == PlayerType.OTHER) {
        similarItemsLabel = "all Other team members";
      }
    } else if (selectedItem is EquipmentModel) {
      similarItemsLabel = "all ${selectedItem.name}s";
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: ColorManager.dark2.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: boardState.applyDesignToAll
              ? ColorManager.yellow.withOpacity(0.6)
              : ColorManager.grey.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Apply to Similar Items",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: ColorManager.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  similarItemsLabel.isNotEmpty
                      ? "Changes will affect $similarItemsLabel"
                      : "Changes will affect this item only",
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: ColorManager.grey.withOpacity(0.8),
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Switch(
            value: boardState.applyDesignToAll,
            onChanged: (value) {
              ref.read(boardProvider.notifier).toggleApplyDesignToAll(value);
            },
            activeColor: ColorManager.yellow,
            activeTrackColor: ColorManager.yellow.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  // REMOVED: The helper method for the old switcher is now gone.

  Widget _buildTopActionWidget({required BoardState boardState}) {
    FieldItemModel? selectedItem = boardState.selectedItemOnTheBoard;
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (selectedItem?.canBeCopied == true)
            Expanded(
              child: FittedBox(
                child: GestureDetector(
                  onTap: () {
                    ref.read(boardProvider.notifier).copyElement();
                  },
                  child: Transform.scale(
                    scale: 0.7,
                    child: Icon(Icons.copy, color: ColorManager.grey),
                  ),
                ),
              ),
            ),
          Expanded(
            child: FittedBox(
              child: GestureDetector(
                onTap: () {
                  ref.read(boardProvider.notifier).moveDown();
                },
                child: Icon(Icons.move_down_outlined, color: ColorManager.grey),
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              child: GestureDetector(
                onTap: () {
                  ref.read(boardProvider.notifier).moveUp();
                },
                child: Icon(Icons.move_up_outlined, color: ColorManager.grey),
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              child: GestureDetector(
                onTap: () {
                  ref.read(boardProvider.notifier).removeElement();
                },
                child: Transform.scale(
                  scale: 0.7,
                  child: Icon(FontAwesomeIcons.trash, color: ColorManager.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFillColorWidget(String title, {required BoardState boardState}) {
    FieldItemModel item = boardState.selectedItemOnTheBoard!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
        ),
        SizedBox(height: 10),
        ColorSlider(
          initialColor: item.color,
          colors: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.purple,
          ],
          onColorChanged: (c) {
            // Update the selected item immediately
            item.color = c;

            // Update the selected item in the provider to trigger re-render
            if (item is PlayerModel) {
              ref
                  .read(boardProvider.notifier)
                  .updatePlayerModel(newModel: item);
            } else if (item is EquipmentModel) {
              ref
                  .read(boardProvider.notifier)
                  .updateEquipmentModel(newModel: item);
            }

            // Apply to all similar items if toggle is enabled
            if (boardState.applyDesignToAll) {
              final similarItems =
                  ref.read(boardProvider.notifier).getSimilarItems();

              if (item is PlayerModel) {
                final updatedPlayers = similarItems
                    .cast<PlayerModel>()
                    .map((p) => p.copyWith(color: c))
                    .toList();
                ref
                    .read(boardProvider.notifier)
                    .updateMultiplePlayers(updatedPlayers: updatedPlayers);
              } else if (item is EquipmentModel) {
                final updatedEquipments = similarItems
                    .cast<EquipmentModel>()
                    .map((e) => e.copyWith(color: c))
                    .toList();
                ref.read(boardProvider.notifier).updateMultipleEquipments(
                    updatedEquipments: updatedEquipments);
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildOpacitySliderWidget({required BoardState boardState}) {
    FieldItemModel item = boardState.selectedItemOnTheBoard!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Opacity",
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
        ),
        SizedBox(height: 10),
        OpacitySlider(
          initial: item.opacity ?? 1,
          onOpacityChanged: (v) {
            // Update the selected item immediately
            item.opacity = v;

            // Update the selected item in the provider to trigger re-render
            if (item is PlayerModel) {
              ref
                  .read(boardProvider.notifier)
                  .updatePlayerModel(newModel: item);
            } else if (item is EquipmentModel) {
              ref
                  .read(boardProvider.notifier)
                  .updateEquipmentModel(newModel: item);
            }

            // Apply to all similar items if toggle is enabled
            if (boardState.applyDesignToAll) {
              final similarItems =
                  ref.read(boardProvider.notifier).getSimilarItems();

              if (item is PlayerModel) {
                final updatedPlayers = similarItems
                    .cast<PlayerModel>()
                    .map((p) => p.copyWith(opacity: v))
                    .toList();
                ref
                    .read(boardProvider.notifier)
                    .updateMultiplePlayers(updatedPlayers: updatedPlayers);
              } else if (item is EquipmentModel) {
                final updatedEquipments = similarItems
                    .cast<EquipmentModel>()
                    .map((e) => e.copyWith(opacity: v))
                    .toList();
                ref.read(boardProvider.notifier).updateMultipleEquipments(
                    updatedEquipments: updatedEquipments);
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildSizeSliderWidget({required BoardState boardState}) {
    FieldItemModel item = boardState.selectedItemOnTheBoard!;
    if (item is LineModelV2 ||
        item is FreeDrawModelV2 ||
        item is ShapeModel ||
        item is EquipmentModel) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Size",
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
        ),
        SizedBox(height: 10),
        CustomSlider(
          min: 16,
          max: 100,
          initial: item.size?.x ?? 32,
          onValueChanged: (v) {
            setState(() {
              item.size = Vector2(v, v);
            });
          },
        ),
      ],
    );
  }

  Widget _buildSwitcherWidget({required PlayerModel playerModel}) {
    final boardState = ref.watch(boardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitcherComponent(
          title: "Image",
          initialValue: playerModel.showImage,
          onChanged: (t) {
            playerModel.showImage = t;
            ref
                .read(boardProvider.notifier)
                .updatePlayerModel(newModel: playerModel);

            // NEW: Apply to all similar players if toggle is enabled
            if (boardState.applyDesignToAll) {
              final similarItems =
                  ref.read(boardProvider.notifier).getSimilarItems();
              final updatedPlayers = similarItems
                  .cast<PlayerModel>()
                  .map((p) => p.copyWith(showImage: t))
                  .toList();
              ref
                  .read(boardProvider.notifier)
                  .updateMultiplePlayers(updatedPlayers: updatedPlayers);
            }
          },
        ),
        SizedBox(height: 10),
        SwitcherComponent(
          title: "Name",
          initialValue: playerModel.showName,
          onChanged: (t) {
            playerModel.showName = t;
            ref
                .read(boardProvider.notifier)
                .updatePlayerModel(newModel: playerModel);

            // NEW: Apply to all similar players if toggle is enabled
            if (boardState.applyDesignToAll) {
              final similarItems =
                  ref.read(boardProvider.notifier).getSimilarItems();
              final updatedPlayers = similarItems
                  .cast<PlayerModel>()
                  .map((p) => p.copyWith(showName: t))
                  .toList();
              ref
                  .read(boardProvider.notifier)
                  .updateMultiplePlayers(updatedPlayers: updatedPlayers);
            }
          },
        ),
        SizedBox(height: 10),
        SwitcherComponent(
          title: "Number",
          initialValue: playerModel.showNr,
          onChanged: (t) {
            playerModel.showNr = t;
            ref
                .read(boardProvider.notifier)
                .updatePlayerModel(newModel: playerModel);

            // NEW: Apply to all similar players if toggle is enabled
            if (boardState.applyDesignToAll) {
              final similarItems =
                  ref.read(boardProvider.notifier).getSimilarItems();
              final updatedPlayers = similarItems
                  .cast<PlayerModel>()
                  .map((p) => p.copyWith(showNr: t))
                  .toList();
              ref
                  .read(boardProvider.notifier)
                  .updateMultiplePlayers(updatedPlayers: updatedPlayers);
            }
          },
        ),
        SizedBox(height: 10),
        SwitcherComponent(
          title: "Role",
          initialValue: playerModel.showRole,
          onChanged: (t) {
            playerModel.showRole = t;
            ref
                .read(boardProvider.notifier)
                .updatePlayerModel(newModel: playerModel);

            // NEW: Apply to all similar players if toggle is enabled
            if (boardState.applyDesignToAll) {
              final similarItems =
                  ref.read(boardProvider.notifier).getSimilarItems();
              final updatedPlayers = similarItems
                  .cast<PlayerModel>()
                  .map((p) => p.copyWith(showRole: t))
                  .toList();
              ref
                  .read(boardProvider.notifier)
                  .updateMultiplePlayers(updatedPlayers: updatedPlayers);
            }
          },
        ),
      ],
    );
  }
}
