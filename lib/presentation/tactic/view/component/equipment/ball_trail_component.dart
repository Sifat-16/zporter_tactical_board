// import 'dart:ui';
// import 'package:flame/components.dart';
//
// import 'equipment_component.dart';
//
// // A private helper class to manage individual points in our trail.
// class _TrailSegment {
//   Vector2 position;
//   double life;
//   final double initialLife;
//   Vector2 size;
//
//   _TrailSegment({
//     required this.position,
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
//   // --- You can easily customize the trail's appearance here ---
//   static const double trailLifetime =
//       0.4; // How long each trail segment lasts in seconds
//   static const double spawnInterval =
//       0.03; // How often a new segment is created
//   static const double initialOpacity =
//       0.5; // Starting opacity of a trail segment
//   // ---------------------------------------------------------
//
//   BallTrailComponent({required this.ball}) {
//     // This timer will call the _spawnSegment method periodically
//     _spawnTimer = Timer(
//       spawnInterval,
//       onTick: _spawnSegment,
//       repeat: true,
//     );
//   }
//
//   void _spawnSegment() {
//     // Only add a new segment if the ball actually has a sprite to draw
//     if (ball.sprite != null) {
//       _segments.add(
//         _TrailSegment(
//           position: ball.position.clone() - ball.size / 2, // Adjust for anchor
//           size: ball.size.clone(),
//           life: trailLifetime,
//         ),
//       );
//     }
//   }
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//     _spawnTimer.update(dt);
//
//     // Iterate backwards through the list to safely remove items as we go
//     for (int i = _segments.length - 1; i >= 0; i--) {
//       final segment = _segments[i];
//       segment.life -= dt; // Decrease the life of the segment
//
//       if (segment.life <= 0) {
//         _segments.removeAt(i); // Remove segment if its life is over
//       } else {
//         // This makes the trail segment shrink as it fades, which looks nice
//         double lifeRatio = (segment.life / segment.initialLife).clamp(0.0, 1.0);
//         segment.size.setFrom(ball.size * lifeRatio);
//       }
//     }
//   }
//
//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     final paint = Paint();
//     final ballSprite = ball.sprite;
//
//     if (ballSprite == null) return; // Safety check
//
//     // Draw each segment with decreasing opacity
//     for (final segment in _segments) {
//       double lifeRatio = (segment.life / segment.initialLife).clamp(0.0, 1.0);
//       paint.color = Color.fromRGBO(255, 255, 255, lifeRatio * initialOpacity);
//
//       // Render the sprite at the segment's historical position and size
//       ballSprite.render(
//         canvas,
//         position: segment.position,
//         size: segment.size,
//         overridePaint: paint,
//       );
//     }
//   }
// }

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' as m;
import 'package:zporter_tactical_board/presentation/tactic/view/component/equipment/equipment_component.dart';

// The _TrailSegment class is unchanged
class _TrailSegment {
  Vector2 position;
  final double altitude;
  double life;
  final double initialLife;
  Vector2 size;

  _TrailSegment({
    required this.position,
    required this.altitude,
    required this.life,
    required this.size,
  }) : initialLife = life;
}

class BallTrailComponent extends PositionComponent {
  final EquipmentComponent ball;
  final List<_TrailSegment> _segments = [];
  late final Timer _spawnTimer;

  // --- Customizable Parameters ---
  static const double trailLifetime = 0.4;
  static const double spawnInterval =
      0.02; // A faster spawn rate for a smoother ribbon
  static const Color trailStartColor =
      Color(0x99FFFFFF); // Opaque white near the ball
  static const Color trailEndColor =
      Color(0x00FFFFFF); // Transparent at the tail
  static const Color groundEchoColor = m.Colors.black;
  static const double groundEchoOpacity = 0.07;
  // ---------------------------------------------------------

  BallTrailComponent({required this.ball}) {
    _spawnTimer = Timer(
      spawnInterval,
      onTick: _spawnSegment,
      repeat: true,
    );
  }

  void _spawnSegment() {
    _segments.add(
      _TrailSegment(
        position: ball.absoluteCenter, // Use the center for path calculations
        altitude: ball.altitude,
        size: ball.size.clone(),
        life: trailLifetime,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spawnTimer.update(dt);

    for (int i = _segments.length - 1; i >= 0; i--) {
      final segment = _segments[i];
      segment.life -= dt;
      if (segment.life <= 0) {
        _segments.removeAt(i);
      } else {
        // Shrink the trail segment's potential width as it fades
        double lifeRatio = (segment.life / segment.initialLife).clamp(0.0, 1.0);
        segment.size.setFrom(ball.size * lifeRatio);
      }
    }
  }

  // COMPLETE RENDER OVERHAUL: We now build and draw a continuous Path.
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // We need at least 2 points to draw a line segment
    if (_segments.length < 2) {
      return;
    }

    // --- 1. Collect all the top and bottom points for the ribbon ---
    final airTrailPointsTop = <Offset>[];
    final airTrailPointsBottom = <Offset>[];
    final groundTrailPointsTop = <Offset>[];
    final groundTrailPointsBottom = <Offset>[];

    for (final segment in _segments) {
      final halfHeight = segment.size.y / 2;
      final center = segment.position;

      // Calculate points for the airborne trail
      airTrailPointsTop
          .add(Offset(center.x, center.y - halfHeight - segment.altitude));
      airTrailPointsBottom
          .add(Offset(center.x, center.y + halfHeight - segment.altitude));

      // Calculate points for the ground echo
      groundTrailPointsTop.add(Offset(center.x, center.y - halfHeight));
      groundTrailPointsBottom.add(Offset(center.x, center.y + halfHeight));
    }

    // --- 2. Build the continuous Path objects ---
    final airPath = Path();
    airPath.moveTo(airTrailPointsTop.first.dx, airTrailPointsTop.first.dy);
    for (final point in airTrailPointsTop) {
      airPath.lineTo(point.dx, point.dy);
    }
    // Connect to the bottom line, looping backwards
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

    // --- 3. Create Gradient paints that fade along the path's length ---
    final airPaint = Paint()
      ..shader = Gradient.linear(
        _segments.first.position.toOffset(), // Start of gradient
        _segments.last.position.toOffset(), // End of gradient
        [trailStartColor, trailEndColor],
      );

    final groundPaint = Paint()
      ..shader = Gradient.linear(
        _segments.first.position.toOffset(),
        _segments.last.position.toOffset(),
        [groundEchoColor.withOpacity(groundEchoOpacity), m.Colors.transparent],
      );

    // --- 4. Draw the paths ---
    canvas.drawPath(groundPath, groundPaint);
    canvas.drawPath(airPath, airPaint);
  }
}
