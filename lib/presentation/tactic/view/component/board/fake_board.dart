// import 'dart:async';
//
// import 'package:flame/extensions.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
//
// import 'game_field.dart';
// import 'mixin/board_riverpod_integration.dart';
// import 'mixin/drawing_input_handler.dart';
// import 'mixin/item_management.dart';
// import 'mixin/layering_management.dart';
//
// class TacticBoardFake extends TacticBoardGame
//     with
//         DrawingInputHandler, // Provides drawing state and drag handlers
//         ItemManagement, // Provides addItem, _checkAndRemoveComponent, _copyItem
//         LayeringManagement, // Provides layering helpers and _moveUp/DownElement
//         BoardRiverpodIntegration // Provides setupBoardListeners
//         {
//   TacticBoardFake();
//
//   @override
//   FutureOr<void> onLoad() async {
//     await super.onLoad();
//     _initiateField(); // Field setup specific to this game
//     setupBoardListeners(); // Call the listener setup method from the mixin
//   }
//
//   // Methods specific to TacticBoard remain here
//   _initiateField() {
//     gameField = GameField(size: Vector2(size.x - 20, size.y - 20));
//     ref.read(boardProvider.notifier).updateFieldSize(size: gameField.size);
//     add(gameField); // add() is available via FlameGame
//   }
//
//   @override
//   Color backgroundColor() {
//     return ColorManager.grey.withValues(alpha: 0.1);
//   }
//
//   @override
//   bool get debugMode => false;
//
//   @override
//   void rotate() {} // Unchanged
// }
