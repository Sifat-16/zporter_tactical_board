import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_model_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/r&d/tactic_board_game.dart';

class PlayerSpriteComponent extends SpriteComponent
    with HasGameReference<TacticBoardGame>, DragCallbacks, TapCallbacks {
  PlayerModelV2 playerModelV2;
  SelectionBorder? _selectionBorder;
  bool _isRotationHandleDragged = false; // Flag to prevent player drag

  PlayerSpriteComponent({required this.playerModelV2, super.priority = 1});

  bool _isSelected = false;

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite("football.png");
    size *= 0.3;
    anchor = Anchor.center;
    position = Vector2(game.gameField.size.x / 2, game.gameField.size.y / 2);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    _isSelected = !_isSelected;

    _updateSelectionBorder();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    if (!_isRotationHandleDragged) {
      // Prevent drag if rotation handle is dragged
      position += event.canvasDelta;
      zlog(data: "Drag callback event Player ${event.localDelta}");
    }
  }

  void _updateSelectionBorder() {
    if (_isSelected) {
      if (_selectionBorder == null) {
        _selectionBorder = SelectionBorder(player: this);
        add(_selectionBorder!);
      }
    } else {
      if (_selectionBorder != null) {
        remove(_selectionBorder!);
        _selectionBorder = null;
      }
    }
  }

  void setRotationHandleDragged(bool value) {
    _isRotationHandleDragged = value;
  }
}

class SelectionBorder extends RectangleComponent {
  PlayerSpriteComponent player;
  SelectionBorder({required this.player})
    : super(
        size: player.size + Vector2.all(20),
        anchor: Anchor.center,

        position: Vector2(player.size.x / 2, player.size.y / 2),
        paint:
            Paint()
              ..color = const Color(0xFF00FF00)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
        priority: 2,
      ) {
    add(RotationHandle(player)..position = Vector2(size.x / 2, 0));

    List<Vector2> vertices = getVertices();

    Vector2 topLeft = vertices[0];
    Vector2 topRight = vertices[1];
    Vector2 bottomLeft = vertices[2];
    Vector2 bottomRight = vertices[3];

    // Add scaling handles to corners
    add(
      ScalingHandle(player: player, anchor: Anchor.topLeft, color: Colors.white)
        ..position = topLeft,
    );
    add(
      ScalingHandle(player: player, anchor: Anchor.topRight, color: Colors.red)
        ..position = topRight,
    );
    add(
      ScalingHandle(
        player: player,
        anchor: Anchor.bottomLeft,
        color: Colors.black,
      )..position = bottomLeft,
    );
    add(
      ScalingHandle(
        player: player,
        anchor: Anchor.bottomRight,
        color: Colors.blue,
      )..position = bottomRight,
    );
  }

  List<Vector2> getVertices() {
    return [
      Vector2(-10, -10), //top left
      Vector2(size.x + 10, -10), //top right
      Vector2(-10, size.y + 10), //bottom left
      Vector2(size.x + 10, size.y + 10), //bottom right
    ];
  }

  void updateHandlePositions() {
    List<Vector2> vertices = getVertices();

    Vector2 topLeft = vertices[0];
    Vector2 topRight = vertices[1];
    Vector2 bottomLeft = vertices[2];
    Vector2 bottomRight = vertices[3];

    children.whereType<ScalingHandle>().toList()[0]
      ..position.setFrom(topLeft)
      ..anchor = Anchor.topLeft;
    children.whereType<ScalingHandle>().toList()[1]
      ..anchor = Anchor.topRight
      ..position.setFrom(topRight);
    children.whereType<ScalingHandle>().toList()[2]
      ..anchor = Anchor.bottomLeft
      ..position.setFrom(bottomLeft);
    children.whereType<ScalingHandle>().toList()[3]
      ..anchor = Anchor.bottomRight
      ..position.setFrom(bottomRight);

    children.whereType<RotationHandle>().first.position.setFrom(
      Vector2(size.x / 2, 0),
    );
  }
}

class RotationHandle extends PositionComponent {
  // Remove DragCallbacks
  final PlayerSpriteComponent player;
  final double rotationSpeed = 0.15;

  RotationHandle(this.player)
    : super(anchor: Anchor.bottomCenter, priority: 3) {
    // Add the line component
    add(
      CustomPaintComponent(
        painter: LinePainter(),
        size: Vector2(0, 30),
        anchor: Anchor.bottomCenter,
      ),
    );

    // Add the circle component (handle) with DragCallbacks
    add(
      DraggableCircleComponent(
        player: player,
        rotationSpeed: rotationSpeed,
        position: Vector2(0, -30),
      ),
    );
  }
}

class DraggableCircleComponent extends CircleComponent with DragCallbacks {
  final PlayerSpriteComponent player;
  final double rotationSpeed;

  DraggableCircleComponent({
    required this.player,
    required this.rotationSpeed,
    super.position,
  }) : super(
         radius: 8,
         paint: Paint()..color = const Color(0xFF00FF00),
         anchor: Anchor.center,
       );

  @override
  void onDragStart(DragStartEvent event) {
    if (!player._isSelected) return;
    super.onDragStart(event);
    player.setRotationHandleDragged(true);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!player._isSelected) return;
    Vector2 delta = event.localDelta;
    double angle = delta.screenAngle();
    player.angle += angle * rotationSpeed;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!player._isSelected) return;
    super.onDragEnd(event);
    player.setRotationHandleDragged(false);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (!player._isSelected) return;
    super.onDragCancel(event);
    player.setRotationHandleDragged(false);
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF00FF00)
          ..strokeWidth = 2;
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

class ScalingHandle extends CircleComponent with DragCallbacks {
  final PlayerSpriteComponent player;
  final Anchor anchor;

  final Color color;

  ScalingHandle({
    required this.player,
    required this.anchor,
    this.color = const Color(0xFF00FF00),
  }) : super(radius: 6, paint: Paint()..color = color, anchor: anchor);

  @override
  void onDragUpdate(DragUpdateEvent event) {
    zlog(data: "Dragging the scale ${event.localDelta}");
    Vector2 delta = event.localDelta;

    // Calculate scaling factor based on drag direction and anchor
    double scaleX = 1.0;
    double scaleY = 1.0;

    if (anchor == Anchor.topLeft || anchor == Anchor.bottomLeft) {
      scaleX -= delta.x / player.size.x;
    } else {
      scaleX += delta.x / player.size.x;
    }

    if (anchor == Anchor.topLeft || anchor == Anchor.topRight) {
      scaleY -= delta.y / player.size.y;
    } else {
      scaleY += delta.y / player.size.y;
    }

    // Apply scaling to the player component
    player.size.x *= scaleX;
    player.size.y *= scaleY;

    // Ensure size doesn't become negative or too small
    player.size.x = player.size.x.clamp(10, double.infinity);
    player.size.y = player.size.y.clamp(10, double.infinity);

    // Update the selection border size
    player._selectionBorder?.size = player.size + Vector2.all(20);

    // Update the selection border's position
    player._selectionBorder?.position.setFrom(
      Vector2(player.size.x / 2, player.size.y / 2),
    );

    // Update handle positions
    player._selectionBorder?.updateHandlePositions();
  }
}
