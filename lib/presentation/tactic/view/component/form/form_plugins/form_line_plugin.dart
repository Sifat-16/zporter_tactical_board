import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';

import 'form_component_plugin.dart';

class FormLinePlugin implements FormComponentPlugin {
  @override
  void render(Canvas canvas, FormModel model, Vector2 size, Vector2 scale) {
    if (model.formItemModel is LineModel) {
      final line = model.formItemModel as LineModel;
      final paint =
          Paint()
            ..color = line.color
            ..strokeWidth = line.thickness * scale.x
            ..style = PaintingStyle.stroke;

      // Adjust start and end points for scaling
      final scaledStart = line.start;
      final scaledEnd = line.end;

      canvas.drawLine(scaledStart.toOffset(), scaledEnd.toOffset(), paint);
    }
  }

  @override
  void onScaleUpdate(
    FormModel model,
    Vector2 scale,
    Function(Vector2) updateSize,
  ) {
    // No specific scaling logic needed for line here
    // But you might want to update the line thickness if needed
  }

  @override
  void showTextInputDialog(
    FormModel model,
    BuildContext context,
    Function(String) onTextUpdated,
  ) {
    // Lines don't have text input, so leave this empty
  }

  @override
  Vector2 calculateSize(FormModel model, Vector2 scale) {
    // Lines don't have a specific size, but we need to return something
    return Vector2.zero(); // Or a small default size
  }
}

class DraggableDot extends CircleComponent with DragCallbacks {
  final Function(Vector2) onPositionChanged;
  final double radius;
  final Vector2 initialPosition;

  DraggableDot({
    required this.onPositionChanged,
    required this.initialPosition,
    this.radius = 8.0,
    Color color = Colors.blue,
  }) : super(
         radius: radius,
         position: initialPosition,
         anchor: Anchor.center,
         paint: Paint()..color = color,
       );

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.add(event.localDelta);
    onPositionChanged(position);
  }
}

class LineDrawerComponent extends PositionComponent {
  final LineModel lineModel;
  final Color lineColor;
  final double circleRadius;
  List<DraggableDot> dots = [];

  LineDrawerComponent({
    required this.lineModel,
    this.lineColor = Colors.black,
    this.circleRadius = 8.0,
  }) {
    _createDots();
  }

  void _createDots() {
    dots = [
      DraggableDot(
        initialPosition: lineModel.start,
        onPositionChanged: (newPos) {
          lineModel.start = newPos;
          _updateLine();
        },
      ),
      DraggableDot(
        initialPosition: lineModel.end,
        onPositionChanged: (newPos) {
          lineModel.end = newPos;
          _updateLine();
        },
      ),
    ];
    addAll(dots);
  }

  void _updateLine() {
    // No need to update middle dot positions since they're removed
  }

  @override
  void render(Canvas canvas) {
    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      lineModel.start.toOffset(),
      lineModel.end.toOffset(),
      paint,
    );
  }
}
