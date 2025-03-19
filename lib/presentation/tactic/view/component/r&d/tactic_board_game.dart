import 'dart:async';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_model_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/player_sprite_component.dart';

import 'game_field.dart';

class TacticBoardGame extends FlameGame {
  late GameField gameField;
  List<PlayerModelV2> players = [];

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    _initiateField();
    return super.onLoad();
  }

  _initiateField() {
    gameField = GameField(size: Vector2(size.x - 20, size.y - 20));
    add(gameField);
  }

  // _initiatePlayerSprite(){
  //   players.forEach((e){
  //
  //   });
  // }

  @override
  Color backgroundColor() {
    // TODO: implement backgroundColor
    return ColorManager.grey;
  }

  addPlayer(PlayerModelV2 player) {
    print("On Drag end ${player.offset}");
    players.add(player);
    add(PlayerSpriteComponent(playerModelV2: player));
  }

  @override
  // TODO: implement debugMode
  bool get debugMode => false;
}
