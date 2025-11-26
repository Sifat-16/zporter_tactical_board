import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class DustPuffEffect extends PositionComponent {
  final _random = Random();

  @override
  Future<void> onLoad() async {
    // This effect will spawn 5-7 small, grey circles ("dust particles")
    final particleCount = 5 + _random.nextInt(3);

    for (int i = 0; i < particleCount; i++) {
      final circle = CircleComponent(
        radius: 2 + _random.nextDouble() * 3,
        paint: Paint()..color = Colors.grey.withOpacity(0.5),
      );

      add(circle);

      // Each circle will move outwards and fade away over 0.3 - 0.5 seconds
      final duration = 0.3 + _random.nextDouble() * 0.2;
      final targetPosition =
          Vector2.random(_random) * (15 + _random.nextDouble() * 20);

      circle.add(
        MoveEffect.to(targetPosition, EffectController(duration: duration))
          ..onComplete = () => circle.removeFromParent(),
      );
      circle.add(
        OpacityEffect.fadeOut(EffectController(duration: duration)),
      );
    }

    // The whole effect component removes itself after 0.5 seconds
    add(RemoveEffect(delay: 0.5));
  }
}
