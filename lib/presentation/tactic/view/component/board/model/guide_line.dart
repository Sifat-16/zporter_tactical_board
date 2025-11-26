import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

class GuideLine {
  final Vector2 start;
  final Vector2 end;
  final Color color;

  GuideLine({
    required this.start,
    required this.end,
    this.color =
        ColorManager.yellow, // You can change the default snap color here
  });
}
