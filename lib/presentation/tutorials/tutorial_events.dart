// lib/app/tutorial/tutorial_events.dart
import 'dart:async';

import 'package:flutter/widgets.dart'; // For GlobalKey

// Event when the initial tap-and-hold starts on the tutored player
class PlayerTutorialDragInteractionStartedEvent {
  final GlobalKey playerKey;
  PlayerTutorialDragInteractionStartedEvent(this.playerKey);
}

// NEW: Event for when a player (ideally the tutored one) is successfully placed on the field
class PlayerSuccessfullyDraggedToFieldEvent {
  final GlobalKey? playerKey; // Optional: key of the player that was dragged
  // You could add more data, like the PlayerModel itself if needed
  PlayerSuccessfullyDraggedToFieldEvent({this.playerKey});
}

class TutorialEvents {
  TutorialEvents._();

  // For the initial interaction (tap-down/drag-start) on the tutored player
  static final _playerDragInteractionStartedController =
      StreamController<PlayerTutorialDragInteractionStartedEvent>.broadcast();
  static Stream<PlayerTutorialDragInteractionStartedEvent>
  get onPlayerTutorialDragInteractionStarted =>
      _playerDragInteractionStartedController.stream;
  static void firePlayerTutorialDragInteractionStarted(GlobalKey playerKey) {
    _playerDragInteractionStartedController.add(
      PlayerTutorialDragInteractionStartedEvent(playerKey),
    );
  }

  // NEW: For successful placement on the field
  static final _playerSuccessfullyDraggedToFieldController =
      StreamController<PlayerSuccessfullyDraggedToFieldEvent>.broadcast();
  static Stream<PlayerSuccessfullyDraggedToFieldEvent>
  get onPlayerSuccessfullyDraggedToField =>
      _playerSuccessfullyDraggedToFieldController.stream;
  static void firePlayerSuccessfullyDraggedToField({GlobalKey? playerKey}) {
    _playerSuccessfullyDraggedToFieldController.add(
      PlayerSuccessfullyDraggedToFieldEvent(playerKey: playerKey),
    );
  }

  // Dispose method if you need to clean up controllers (e.g., for tests or app shutdown)
  // static void dispose() {
  //   _playerDragInteractionStartedController.close();
  //   _playerSuccessfullyDraggedToFieldController.close();
  // }
}
