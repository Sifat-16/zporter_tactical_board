// import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart'; // Base class/interface
// // Import the other mixins to make their types known for casting
//
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart'; // Needed for method signatures
//
// import 'item_management.dart';
// import 'layering_management.dart'; // Needed for method signatures
//
// // Assuming the base class TacticBoardGame provides RiverpodGameMixin features
// mixin BoardRiverpodIntegration on TacticBoardGame {
//   // Method to setup listeners, moved from TacticBoard.onLoad
//   void setupBoardListeners() {
//     // addToGameWidgetBuild is available via RiverpodGameMixin applied to TacticBoardGame or TacticBoard
//     addToGameWidgetBuild(() {
//       // ref is available via RiverpodGameMixin
//       ref.listen(boardProvider, (BoardState? previous, BoardState current) {
//         // Explicit types might help analyzer
//
//         // Cast 'this' to ItemManagement to call its methods
//         (this as ItemManagement).checkAndRemoveComponent(previous, current);
//
//         if (current.copyItem != null) {
//           // Cast 'this' to ItemManagement to call its method
//           (this as ItemManagement).copyItem(current.copyItem);
//         }
//
//         if (current.moveDown == true) {
//           // Cast 'this' to LayeringManagement to call its method
//           (this as LayeringManagement).moveDownElement(
//             current.selectedItemOnTheBoard,
//           );
//           ref.read(boardProvider.notifier).moveDownComplete();
//         }
//
//         if (current.moveUp == true) {
//           // Cast 'this' to LayeringManagement to call its method
//           (this as LayeringManagement).moveUpElement(
//             current.selectedItemOnTheBoard,
//           );
//           ref.read(boardProvider.notifier).moveUpComplete();
//         }
//       });
//     });
//   }
// }

import 'package:zporter_tactical_board/presentation/tactic/view/component/board/tactic_board_game.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';
import 'layering_management.dart';

mixin BoardRiverpodIntegration on TacticBoardGame {
  void setupBoardListeners() {
    addToGameWidgetBuild(() {
      ref.listen(boardProvider, (BoardState? previous, BoardState current) {
        // --- REMOVED: Item deletion and copying is no longer handled here ---
        // The animationProvider state change now drives component removal via loadScene.

        // Layering is a purely visual concern handled by the game, so this logic stays.
        if (current.moveDown == true) {
          (this as LayeringManagement).moveDownElement(
            current.selectedItemOnTheBoard,
          );
          ref.read(boardProvider.notifier).moveDownComplete();
        }

        if (current.moveUp == true) {
          (this as LayeringManagement).moveUpElement(
            current.selectedItemOnTheBoard,
          );
          ref.read(boardProvider.notifier).moveUpComplete();
        }
      });
    });
  }
}
