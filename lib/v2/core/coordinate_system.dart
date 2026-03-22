import 'dart:ui';

/// Converts between relative (0.0–1.0) and screen-pixel coordinate spaces.
///
/// Replaces V1 [SizeHelper]. All V2 models store positions as ratios
/// so layouts work identically on any screen size.
///
/// **Positions** (element centers) scale linearly per axis:
///   screenX = relativeX × fieldWidth
///   screenY = relativeY × fieldHeight
///
/// **Dimensions** (element sizes, radii, stroke widths) scale by the
/// average of width and height to maintain aspect-ratio consistency:
///   screenSize = relativeSize × (fieldWidth + fieldHeight) / 2
///
/// All positions are **center-anchored**: the offset stored in a
/// [BoardElement] represents the element's center, not its top-left.
class CoordinateSystem {
  /// The current screen-pixel size of the board.
  final Size fieldSize;

  const CoordinateSystem(this.fieldSize);

  /// Average dimension — used for size/dimension scaling to maintain
  /// aspect ratio across non-square fields.
  double get _avgDimension => (fieldSize.width + fieldSize.height) / 2.0;

  // ---------------------------------------------------------------------------
  // Position conversion (per-axis scaling)
  // ---------------------------------------------------------------------------

  /// Convert a relative position (0.0–1.0) to screen pixels.
  Offset toScreen(Offset relative) {
    return Offset(
      fieldSize.width > 0 ? relative.dx * fieldSize.width : 0.0,
      fieldSize.height > 0 ? relative.dy * fieldSize.height : 0.0,
    );
  }

  /// Convert a screen-pixel position to a relative position (0.0–1.0).
  Offset toRelative(Offset screen) {
    return Offset(
      fieldSize.width > 0 ? screen.dx / fieldSize.width : 0.0,
      fieldSize.height > 0 ? screen.dy / fieldSize.height : 0.0,
    );
  }

  // ---------------------------------------------------------------------------
  // Dimension conversion (average-based scaling)
  // ---------------------------------------------------------------------------

  /// Convert a relative dimension to screen pixels.
  ///
  /// Uses the average of field width and height so circles stay
  /// circular and squares stay square regardless of field aspect ratio.
  double dimensionToScreen(double relative) {
    return _avgDimension > 0 ? relative * _avgDimension : 0.0;
  }

  /// Convert a screen-pixel dimension to a relative value.
  double dimensionToRelative(double screen) {
    return _avgDimension > 0 ? screen / _avgDimension : 0.0;
  }

  /// Convert a relative size to screen-pixel size.
  ///
  /// Uses per-axis scaling (not average) because sizes like element
  /// bounding boxes follow the same coordinate space as positions.
  Size sizeToScreen(Size relative) {
    return Size(
      fieldSize.width > 0 ? relative.width * fieldSize.width : 0.0,
      fieldSize.height > 0 ? relative.height * fieldSize.height : 0.0,
    );
  }

  /// Convert a screen-pixel size to relative size.
  Size sizeToRelative(Size screen) {
    return Size(
      fieldSize.width > 0 ? screen.width / fieldSize.width : 0.0,
      fieldSize.height > 0 ? screen.height / fieldSize.height : 0.0,
    );
  }

  // ---------------------------------------------------------------------------
  // Convenience: delta conversion (for drag events)
  // ---------------------------------------------------------------------------

  /// Convert a screen-pixel drag delta to a relative delta.
  Offset deltaToRelative(Offset screenDelta) {
    return toRelative(screenDelta);
  }

  /// Convert a relative delta to screen pixels.
  Offset deltaToScreen(Offset relativeDelta) {
    return toScreen(relativeDelta);
  }

  // ---------------------------------------------------------------------------
  // Rect helpers
  // ---------------------------------------------------------------------------

  /// Get the screen-pixel rect for a center-anchored element.
  ///
  /// Given an element's relative center position and relative size,
  /// returns the Rect in screen pixels for painting/hit testing.
  Rect elementRect({
    required Offset relativeCenter,
    required Size relativeSize,
  }) {
    final center = toScreen(relativeCenter);
    final w = dimensionToScreen(relativeSize.width);
    final h = dimensionToScreen(relativeSize.height);
    return Rect.fromCenter(center: center, width: w, height: h);
  }

  /// Check if a screen-pixel point is inside a center-anchored element.
  bool containsPoint({
    required Offset screenPoint,
    required Offset relativeCenter,
    required Size relativeSize,
  }) {
    return elementRect(
      relativeCenter: relativeCenter,
      relativeSize: relativeSize,
    ).contains(screenPoint);
  }
}
