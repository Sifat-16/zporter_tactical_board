import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/board/model/guide_line.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_state.dart';

class SmartGuideComponent extends PositionComponent
    with RiverpodComponentMixin {
  SmartGuideComponent()
      : super(
          priority: 100, // Draw on top of everything
          anchor: Anchor.topLeft,
          position: Vector2.zero(),
        );

  List<GuideLine> _activeGuides = [];
  final Paint _paint = Paint()
    ..strokeWidth = 1.0 // You can make the line thicker here
    ..style = PaintingStyle.stroke;

  @override
  Future<void> onLoad() async {
    // Listen to the provider for changes to the active guides list
    addToGameWidgetBuild(() {
      ref.listen<List<GuideLine>>(
        boardProvider.select((state) => state.activeGuides),
        (previous, next) {
          _activeGuides = next;
        },
      );
    });
  }

  @override
  void render(Canvas canvas) {
    // If the list is empty, do nothing.
    if (_activeGuides.isEmpty) {
      return;
    }

    // Draw all active guide lines
    for (final line in _activeGuides) {
      _paint.color = line.color;
      canvas.drawLine(line.start.toOffset(), line.end.toOffset(), _paint);
    }
  }

  // This component only needs to repaint when the provider tells it to.
  @override
  bool get isRepaintBoundary => true;
}
