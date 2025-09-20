import 'package:flame/components.dart';

class SizeHelper {
  static Vector2 getBoardRelativeVector({
    required Vector2 gameScreenSize,
    required Vector2 actualPosition,
  }) {
    double factorX = 0.0; // Initialize to 0.0
    double factorY = 0.0; // Initialize to 0.0

    // Calculate X factor without wrapping
    if (gameScreenSize.x > 0) {
      factorX = actualPosition.x / gameScreenSize.x;
    }
    // else factorX remains 0.0 if gameScreenSize.x is not positive

    // Calculate Y factor without wrapping
    if (gameScreenSize.y > 0) {
      factorY = actualPosition.y / gameScreenSize.y;
    }
    // else factorY remains 0.0 if gameScreenSize.y is not positive

    return Vector2(factorX, factorY);
  }

  static Vector2 getBoardActualVector({
    required Vector2 gameScreenSize,
    required Vector2
        actualPosition, // This 'actualPosition' is the input relative position
  }) {
    double relativeX = actualPosition.x; // Using the input relative x directly
    double relativeY = actualPosition.y; // Using the input relative y directly

    // --- Calculate actual pixel coordinates using the *as-is* relative values ---

    double convertedX =
        (gameScreenSize.x > 0) ? gameScreenSize.x * relativeX : 0.0;
    double convertedY =
        (gameScreenSize.y > 0) ? gameScreenSize.y * relativeY : 0.0;

    Vector2 convertedPosition = Vector2(convertedX, convertedY);

    return convertedPosition;
  }

  static double getBoardRelativeDimension({
    required Vector2 gameScreenSize,
    required double actualSize,
  }) {
    double avgDim = (gameScreenSize.x + gameScreenSize.y) / 2.0;

    return actualSize / avgDim;
  }

  static double getBoardActualDimension({
    required Vector2 gameScreenSize,
    required double relativeSize,
  }) {
    double avgDim = (gameScreenSize.x + gameScreenSize.y) / 2.0;

    return relativeSize * avgDim;
  }
}
