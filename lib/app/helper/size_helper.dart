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

  // static Vector2 getBoardRelativeVector({
  //   required Vector2 gameScreenSize,
  //   required Vector2 actualPosition,
  // }) {
  //   double factorX = 0.0; // Initialize to 0.0 (double)
  //   double factorY = 0.0; // Initialize to 0.0 (double)
  //
  //   // --- Calculate and Wrap X factor ---
  //   if (gameScreenSize.x > 0) {
  //     // Calculate the raw factor
  //     factorX = actualPosition.x / gameScreenSize.x;
  //
  //     // Use modulo 1.0 to get the fractional part (remainder)
  //     // This brings the value into the range (-1.0, 1.0)
  //     factorX = factorX % 1.0;
  //
  //     // If the result is negative, add 1.0 to wrap it into [0.0, 1.0)
  //     // e.g., -0.2 % 1.0 = -0.2 -> -0.2 + 1.0 = 0.8
  //     // e.g., -1.5 % 1.0 = -0.5 -> -0.5 + 1.0 = 0.5
  //     if (factorX < 0) {
  //       factorX += 1.0;
  //     }
  //     // Note: If factorX was exactly 1.0, 1.0 % 1.0 is 0.0.
  //     // If factorX was exactly 2.0, 2.0 % 1.0 is 0.0.
  //     // If factorX was exactly -1.0, -1.0 % 1.0 is 0.0.
  //     // So, values exactly on the boundary wrap to 0.0, satisfying '< 1'.
  //   }
  //   // else factorX remains 0.0 if gameScreenSize.x is not positive
  //
  //   // --- Calculate and Wrap Y factor ---
  //   if (gameScreenSize.y > 0) {
  //     // Calculate the raw factor
  //     factorY = actualPosition.y / gameScreenSize.y;
  //
  //     // Use modulo 1.0
  //     factorY = factorY % 1.0;
  //
  //     // Adjust if negative
  //     if (factorY < 0) {
  //       factorY += 1.0;
  //     }
  //   }
  //   // else factorY remains 0.0 if gameScreenSize.y is not positive
  //
  //   return Vector2(factorX, factorY);
  // }

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

  // static Vector2 getBoardActualVector({
  //   required Vector2 gameScreenSize,
  //   required Vector2
  //   actualPosition, // Input relative position, potentially outside [0, 1)
  // }) {
  //   // --- Step 1: Wrap the input relative coordinates into the [0.0, 1.0) range ---
  //
  //   double relativeX = actualPosition.x;
  //   double relativeY = actualPosition.y;
  //
  //   // Wrap X component using modulo
  //   // This handles values > 1, < 0, and exactly on boundaries
  //   relativeX = relativeX % 1.0;
  //   if (relativeX < 0) {
  //     relativeX += 1.0; // Ensures the result is in [0.0, 1.0)
  //   }
  //
  //   // Wrap Y component using modulo
  //   relativeY = relativeY % 1.0;
  //   if (relativeY < 0) {
  //     relativeY += 1.0; // Ensures the result is in [0.0, 1.0)
  //   }
  //
  //   // --- Step 2: Calculate actual pixel coordinates using the *wrapped* relative values ---
  //
  //   // Check for non-positive screen dimensions to avoid non-sensical results like NaN or negative coords
  //   double convertedX =
  //       (gameScreenSize.x > 0) ? gameScreenSize.x * relativeX : 0.0;
  //   double convertedY =
  //       (gameScreenSize.y > 0) ? gameScreenSize.y * relativeY : 0.0;
  //
  //   // The resulting convertedX will be in [0, gameScreenSize.x)
  //   // The resulting convertedY will be in [0, gameScreenSize.y)
  //   // This satisfies the condition "less than gamefield size".
  //
  //   Vector2 convertedPosition = Vector2(convertedX, convertedY);
  //
  //   return convertedPosition;
  // }

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
