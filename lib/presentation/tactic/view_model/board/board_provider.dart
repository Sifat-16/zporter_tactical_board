import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

final boardProvider = StateNotifierProvider<BoardController, BoardState>(
  (ref) => BoardController(ref),
);

class BoardController extends StateNotifier<BoardState> {
  BoardController(this.ref) : super(BoardState());

  Ref ref;

  addBoardComponent({required FieldItemModel fieldItemModel}) {
    if (fieldItemModel is PlayerModel) {
      state = state.copyWith(players: [...state.players, fieldItemModel]);
    } else if (fieldItemModel is EquipmentModel) {
      state = state.copyWith(equipments: [...state.equipments, fieldItemModel]);
    } else if (fieldItemModel is FormModel) {
      state = state.copyWith(forms: [...state.forms, fieldItemModel]);
    }
  }

  // playAnimation(
  //     PlayBoardAnimationEvent event,
  //     Emitter<BoardState> emit,
  //     ) {
  //   for (var e in state.animationModel?.animations ?? []) {
  //     zlog(data: "Item on the board ${e.toJson()}");
  //   }
  // }

  onAnimationSave() {
    try {
      AnimationItemModel animationItemModel = AnimationItemModel(
        id: ObjectId(),
        components: [
          ...state.players.map((e) => e.clone()),
          ...state.equipments.map((e) => e.clone()),
          ...state.forms.map((e) => e.clone()),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      AnimationModel? animationModel = state.animationModel;
      animationModel ??= AnimationModel(
        id: ObjectId(),
        animations: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      animationModel.animations.add(animationItemModel);
      zlog(
        data:
            "On Animation save the items ${animationModel.animations.map((t) => t.components.map((c) => c.toJson()).toList()).toList()}",
      );
      state = state.copyWith(animationModel: animationModel);
    } catch (e) {
    } finally {
      BotToast.showText(text: "Animation saved");
    }
  }

  showAnimationEvent() {
    state = state.copyWith(showAnimation: true);
    BotToast.showText(text: "Playing animation");
  }

  completeAnimationEvent() {
    state = state.copyWith(showAnimation: false);
  }

  toggleSelectItemEvent({required FieldItemModel? fieldItemModel}) {
    FieldItemModel? previousSelectedModel = state.selectedItemOnTheBoard;
    if (fieldItemModel == null) {
      state = state.copyWith(forceItemModelNull: true);
    } else {
      if (fieldItemModel.id == previousSelectedModel?.id) {
        state = state.copyWith(forceItemModelNull: true);
      } else {
        state = state.copyWith(selectedItemOnTheBoard: fieldItemModel);
      }
    }
    zlog(
      data: "Selected item to work ${state.selectedItemOnTheBoard.runtimeType}",
    );
  }
}
