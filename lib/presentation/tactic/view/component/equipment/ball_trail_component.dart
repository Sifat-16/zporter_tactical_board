//
//
// import 'dart:ui';
// import 'package:flame/components.dart';
// import 'package:flutter/material.dart' as m;
// import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';
//
// // MODIFIED: The segment now remembers its own ground position
// class _TrailSegment {
//   Vector2 position; // The visual position (with altitude)
//   Vector2 groundPosition; // The logical position on the ground
//   double life;
//   final double initialLife;
//   Vector2 size;
//
//   _TrailSegment({
//     required this.position,
//     required this.groundPosition,
//     required this.life,
//     required this.size,
//   }) : initialLife = life;
// }
//
// class BallTrailComponent extends PositionComponent {
//   final EquipmentComponent ball;
//   final List<_TrailSegment> _segments = [];
//   late final Timer _spawnTimer;
//
//   static const double trailLifetime = 0.4;
//   static const double spawnInterval = 0.02;
//   static const Color trailStartColor = Color(0x99FFFFFF);
//   static const Color trailEndColor = Color(0x00FFFFFF);
//   static const Color groundEchoColor = m.Colors.black;
//   static const double groundEchoOpacity = 0.07;
//
//   BallTrailComponent({required this.ball}) {
//     _spawnTimer = Timer(
//       spawnInterval,
//       onTick: _spawnSegment,
//       repeat: true,
//     );
//   }
//
//   // MODIFIED: We now calculate and store both visual and ground positions
//   void _spawnSegment() {
//     final visualPosition = Vector2(
//       ball.absoluteCenter.x,
//       ball.absoluteCenter.y - ball.altitude,
//     );
//     _segments.add(
//       _TrailSegment(
//         position: visualPosition,
//         groundPosition:
//             ball.absoluteCenter.clone(), // Store the ground position
//         size: ball.size.clone(),
//         life: trailLifetime,
//       ),
//     );
//   }
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//     _spawnTimer.update(dt);
//     for (int i = _segments.length - 1; i >= 0; i--) {
//       final segment = _segments[i];
//       segment.life -= dt;
//       if (segment.life <= 0) {
//         _segments.removeAt(i);
//       } else {
//         double lifeRatio = (segment.life / segment.initialLife).clamp(0.0, 1.0);
//         segment.size.setFrom(ball.size * lifeRatio);
//       }
//     }
//   }
//
//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     if (_segments.length < 2) {
//       return;
//     }
//
//     final airTrailPointsTop = <Offset>[];
//     final airTrailPointsBottom = <Offset>[];
//     final groundTrailPointsTop = <Offset>[];
//     final groundTrailPointsBottom = <Offset>[];
//
//     for (final segment in _segments) {
//       final halfHeight = segment.size.y / 2;
//
//       // Air trail uses the segment's visual position
//       final airCenter = segment.position;
//       airTrailPointsTop.add(Offset(airCenter.x, airCenter.y - halfHeight));
//       airTrailPointsBottom.add(Offset(airCenter.x, airCenter.y + halfHeight));
//
//       // MODIFIED: Ground echo now uses the segment's stored ground position
//       final groundCenter = segment.groundPosition;
//       groundTrailPointsTop
//           .add(Offset(groundCenter.x, groundCenter.y - halfHeight));
//       groundTrailPointsBottom
//           .add(Offset(groundCenter.x, groundCenter.y + halfHeight));
//     }
//
//     final airPath = Path();
//     airPath.moveTo(airTrailPointsTop.first.dx, airTrailPointsTop.first.dy);
//     for (final point in airTrailPointsTop) {
//       airPath.lineTo(point.dx, point.dy);
//     }
//     for (final point in airTrailPointsBottom.reversed) {
//       airPath.lineTo(point.dx, point.dy);
//     }
//     airPath.close();
//
//     final groundPath = Path();
//     groundPath.moveTo(
//         groundTrailPointsTop.first.dx, groundTrailPointsTop.first.dy);
//     for (final point in groundTrailPointsTop) {
//       groundPath.lineTo(point.dx, point.dy);
//     }
//     for (final point in groundTrailPointsBottom.reversed) {
//       groundPath.lineTo(point.dx, point.dy);
//     }
//     groundPath.close();
//
//     final airPaint = Paint()
//       ..shader = Gradient.linear(
//         // START POINT: Always the beginning of the tail
//         _segments.first.position.toOffset(),
//         // END POINT: Always the current ball position (head)
//         _segments.last.position.toOffset(),
//         // COLORS: Reversed to match the new start/end points
//         [trailEndColor, trailStartColor],
//       );
//     final groundPaint = Paint()
//       ..shader = Gradient.linear(
//         _segments.first.groundPosition
//             .toOffset(), // Use ground positions for gradient
//         _segments.last.groundPosition.toOffset(),
//         [groundEchoColor.withOpacity(groundEchoOpacity), m.Colors.transparent],
//       );
//
//     canvas.drawPath(groundPath, groundPaint);
//     canvas.drawPath(airPath, airPaint);
//   }
// }

// lib/presentation/tactic/view/component/equipment/ball_trail_component.dart

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' as m;
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';

// _TrailSegment class remains the same...
class _TrailSegment {
  Vector2 position;
  Vector2 groundPosition;
  double life;
  final double initialLife;
  Vector2 size;

  _TrailSegment({
    required this.position,
    required this.groundPosition,
    required this.life,
    required this.size,
  }) : initialLife = life;
}

class BallTrailComponent extends PositionComponent {
  final EquipmentComponent ball;
  final List<_TrailSegment> _segments = [];
  // REMOVED: The internal timer is no longer needed here.
  // late final Timer _spawnTimer;

  static const double trailLifetime = 0.4;
  // MOVED: The spawn interval constant is moved to ArcingAnimation
  static const Color trailStartColor = Color(0x99FFFFFF);
  static const Color trailEndColor = Color(0x00FFFFFF);
  static const Color groundEchoColor = m.Colors.black;
  static const double groundEchoOpacity = 0.07;

  BallTrailComponent({required this.ball}); // Constructor is simpler now

  // MODIFIED: This is now a public method to be called from the outside.
  void spawnSegment() {
    final visualPosition = Vector2(
      ball.absoluteCenter.x,
      ball.absoluteCenter.y - ball.altitude,
    );
    _segments.add(
      _TrailSegment(
        position: visualPosition,
        groundPosition: ball.absoluteCenter.clone(),
        size: ball.size.clone(),
        life: trailLifetime,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // REMOVED: No longer updating the internal timer.
    // _spawnTimer.update(dt);

    // The rest of the update logic remains the same
    for (int i = _segments.length - 1; i >= 0; i--) {
      final segment = _segments[i];
      segment.life -= dt;
      if (segment.life <= 0) {
        _segments.removeAt(i);
      } else {
        double lifeRatio = (segment.life / segment.initialLife).clamp(0.0, 1.0);
        segment.size.setFrom(ball.size * lifeRatio);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_segments.length < 2) {
      return;
    }

    final airTrailPointsTop = <Offset>[];
    final airTrailPointsBottom = <Offset>[];
    final groundTrailPointsTop = <Offset>[];
    final groundTrailPointsBottom = <Offset>[];

    for (final segment in _segments) {
      final halfHeight = segment.size.y / 2;
      final airCenter = segment.position;
      airTrailPointsTop.add(Offset(airCenter.x, airCenter.y - halfHeight));
      airTrailPointsBottom.add(Offset(airCenter.x, airCenter.y + halfHeight));

      final groundCenter = segment.groundPosition;
      groundTrailPointsTop
          .add(Offset(groundCenter.x, groundCenter.y - halfHeight));
      groundTrailPointsBottom
          .add(Offset(groundCenter.x, groundCenter.y + halfHeight));
    }

    final airPath = Path();
    airPath.moveTo(airTrailPointsTop.first.dx, airTrailPointsTop.first.dy);
    for (final point in airTrailPointsTop) {
      airPath.lineTo(point.dx, point.dy);
    }
    for (final point in airTrailPointsBottom.reversed) {
      airPath.lineTo(point.dx, point.dy);
    }
    airPath.close();

    final groundPath = Path();
    groundPath.moveTo(
        groundTrailPointsTop.first.dx, groundTrailPointsTop.first.dy);
    for (final point in groundTrailPointsTop) {
      groundPath.lineTo(point.dx, point.dy);
    }
    for (final point in groundTrailPointsBottom.reversed) {
      groundPath.lineTo(point.dx, point.dy);
    }
    groundPath.close();

    // Using the corrected gradient from the last attempt, as it's more robust.
    final airPaint = Paint()
      ..shader = Gradient.linear(
        _segments.first.position.toOffset(),
        _segments.last.position.toOffset(),
        [trailEndColor, trailStartColor],
      );

    final groundPaint = Paint()
      ..shader = Gradient.linear(
        _segments.first.groundPosition.toOffset(),
        _segments.last.groundPosition.toOffset(),
        [groundEchoColor.withOpacity(groundEchoOpacity), m.Colors.transparent],
      );

    canvas.drawPath(groundPath, groundPaint);
    canvas.drawPath(airPath, airPaint);
  }
}
