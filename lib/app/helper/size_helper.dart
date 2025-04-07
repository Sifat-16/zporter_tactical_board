import 'package:flame/components.dart';

class SizeHelper {
  static Vector2 getBoardRelativeVector({
    required Vector2 gameScreenSize,
    required Vector2 actualPosition,
  }) {
    double factorX = 0;
    double factorY = 0;
    if (gameScreenSize.x > 0) {
      factorX = actualPosition.x / gameScreenSize.x;
    }
    if (gameScreenSize.y > 0) {
      factorY = actualPosition.y / gameScreenSize.y;
    }
    return Vector2(factorX, factorY);
  }

  static Vector2 getBoardActualVector({
    required Vector2 gameScreenSize,
    required Vector2 actualPosition,
  }) {
    Vector2 convertedPosition = Vector2(
      gameScreenSize.x * (actualPosition.x),
      gameScreenSize.y * (actualPosition.y),
    );
    return convertedPosition;
  }
}
