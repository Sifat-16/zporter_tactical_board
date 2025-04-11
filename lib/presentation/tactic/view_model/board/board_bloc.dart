// import 'dart:async';
//
// import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mongo_dart/mongo_dart.dart';
// import 'package:zporter_tactical_board/app/helper/logger.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
// import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/field_item_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
// import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_event.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';
//
// class BoardBloc extends Bloc<BoardEvent, BoardState> {
//   BoardBloc() : super(BoardState()) {
//     on<AddBoardComponentEvent>(_addBoardComponent);
//     on<PlayBoardAnimationEvent>(_playAnimation);
//     on<SaveToAnimationEvent>(_onAnimationSave);
//     on<ShowAnimationEvent>(_showAnimationEvent);
//     on<CompleteAnimationEvent>(_completeAnimationEvent);
//     on<ToggleSelectItemEvent>(_toggleSelectItemEvent);
//   }
//
//   FutureOr<void> _addBoardComponent(
//     AddBoardComponentEvent event,
//     Emitter<BoardState> emit,
//   ) {
//     FieldItemModel fieldItemModel = event.fieldItemModel;
//
//     if (fieldItemModel is PlayerModel) {
//       emit(state.copyWith(players: [...state.players, fieldItemModel]));
//     } else if (fieldItemModel is EquipmentModel) {
//       emit(state.copyWith(equipments: [...state.equipments, fieldItemModel]));
//     } else if (fieldItemModel is FormModel) {
//       emit(state.copyWith(forms: [...state.forms, fieldItemModel]));
//     }
//   }
//
//   FutureOr<void> _playAnimation(
//     PlayBoardAnimationEvent event,
//     Emitter<BoardState> emit,
//   ) {
//     for (var e in state.animationModel?.animations ?? []) {
//       zlog(data: "Item on the board ${e.toJson()}");
//     }
//   }
//
//   FutureOr<void> _onAnimationSave(
//     SaveToAnimationEvent event,
//     Emitter<BoardState> emit,
//   ) {
//     try {
//       AnimationItemModel animationItemModel = AnimationItemModel(
//         id: ObjectId(),
//         components: [
//           ...state.players.map((e) => e.clone()),
//           ...state.equipments.map((e) => e.clone()),
//           ...state.forms.map((e) => e.clone()),
//         ],
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//       AnimationModel? animationModel = state.animationModel;
//       animationModel ??= AnimationModel(
//         id: ObjectId(),
//         animations: [],
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//       animationModel.animations.add(animationItemModel);
//       zlog(
//         data:
//             "On Animation save the items ${animationModel.animations.map((t) => t.components.map((c) => c.toJson()).toList()).toList()}",
//       );
//       emit(state.copyWith(animationModel: animationModel));
//     } catch (e) {
//     } finally {
//       BotToast.showText(text: "Animation saved");
//     }
//   }
//
//   FutureOr<void> _showAnimationEvent(
//     ShowAnimationEvent event,
//     Emitter<BoardState> emit,
//   ) {
//     emit(state.copyWith(showAnimation: true));
//     BotToast.showText(text: "Playing animation");
//   }
//
//   FutureOr<void> _completeAnimationEvent(
//     CompleteAnimationEvent event,
//     Emitter<BoardState> emit,
//   ) {
//     emit(state.copyWith(showAnimation: false));
//   }
//
//   FutureOr<void> _toggleSelectItemEvent(
//     ToggleSelectItemEvent event,
//     Emitter<BoardState> emit,
//   ) {
//     FieldItemModel? fieldItemModel = event.fieldItemModel;
//     FieldItemModel? previousSelectedModel = state.selectedItemOnTheBoard;
//     if (fieldItemModel == null) {
//       emit(state.copyWith(forceItemModelNull: true));
//     } else {
//       if (fieldItemModel.id == previousSelectedModel?.id) {
//         emit(state.copyWith(forceItemModelNull: true));
//       } else {
//         emit(state.copyWith(selectedItemOnTheBoard: fieldItemModel));
//       }
//     }
//   }
// }
