import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';

/// Visual indicator for the drop zone where users can drag items to remove them
class DropZoneComponent extends PositionComponent {
  bool _isVisible = false;
  double _pulseTimer = 0.0;
  double _pulseOpacity = 0.5;
  double _pulseScale = 1.0;

  final Paint _borderPaint = Paint()
    ..color = ColorManager.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8;

  DropZoneComponent({
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position);

  void show() {
    _isVisible = true;
    _pulseTimer = 0.0;
  }

  void hide() {
    _isVisible = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isVisible) {
      // Pulsing animation for width scale and color intensity
      _pulseTimer += dt * 2.5; // Speed of pulsing
      final pulse = (1 + math.sin(_pulseTimer)) / 2; // 0 to 1
      _pulseOpacity = 0.5 +
          (0.4 * pulse); // Oscillates between 0.5 and 0.9 (color intensity)
      _pulseScale = 0.95 +
          (0.10 * pulse); // Oscillates between 0.95 and 1.05 (width only)
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_isVisible) return;

    canvas.save();

    // Apply pulsing scale for WIDTH only (from left edge)
    canvas.translate(0, 0); // Scale from left edge
    canvas.scale(
        _pulseScale, 1.0); // Only scale X (width), keep Y (height) constant

    // Create gradient from left (deep red) to right (more transparent)
    // Color pulses from light red to deep red
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        ColorManager.red.withOpacity(_pulseOpacity), // Pulsing deep red at left
        ColorManager.red
            .withOpacity(_pulseOpacity * 0.2), // Much more faded at right
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(size.toRect())
      ..style = PaintingStyle.fill;

    // Draw gradient background
    canvas.drawRect(size.toRect(), paint);

    // Draw border
    canvas.drawRect(size.toRect(), _borderPaint);

    canvas.restore();
  }
}
