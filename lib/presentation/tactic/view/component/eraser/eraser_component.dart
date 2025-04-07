import 'dart:ui';

import 'package:flame/components.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class EraserComponent extends CircleComponent {
  EraserComponent({
    required double radius,
    required Vector2 position,
    // Example appearance: semi-transparent white circle
    Color color = ColorManager.white, // White with ~53% opacity
  }) : super(
         radius: radius,
         position: position,
         paint: Paint()..color = color,
         anchor: Anchor.center, // Position the circle by its center
       );
}
