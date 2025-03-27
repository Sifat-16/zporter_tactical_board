// Rotation handle for field components
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

import 'draggable_circle_component.dart';
import 'field_component.dart';

class RotationHandle extends PositionComponent {
  final FieldComponent component;
  final double rotationSpeed = 0.15;

  RotationHandle(this.component)
    : super(anchor: Anchor.bottomCenter, priority: 3) {
    add(
      CustomPaintComponent(
        painter: LinePainter(),
        size: Vector2(0, 20),
        anchor: Anchor.bottomCenter,
      ),
    );
    add(
      DraggableCircleComponent(
        component: component,
        rotationSpeed: rotationSpeed,
        position: Vector2(0, -20),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF00FF00)
          ..strokeWidth = 1;
    canvas.drawLine(Offset(0, 0), Offset(0, -size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CustomPaintComponent extends Component {
  final CustomPainter painter;
  final Vector2 size;
  final Anchor anchor;

  CustomPaintComponent({
    required this.painter,
    required this.size,
    required this.anchor,
  });

  @override
  void render(Canvas canvas) {
    final offset = anchor.toVector2();
    canvas.save();
    canvas.translate(offset.x, offset.y);
    painter.paint(canvas, Size(size.x, size.y));
    canvas.restore();
  }
}
