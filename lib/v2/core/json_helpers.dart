import 'dart:ui';

/// JSON serialization helpers for V1-compatible data formats.
///
/// V1 uses two different Vector2 serialization formats:
/// - `offset` fields: `{dx: num, dy: num}`
/// - `size`, `start`, `end`, `vertices`: `{x: num, y: num}`
///
/// V2 uses Dart's [Offset] and [Size] but must read/write V1 JSON.
class JsonHelpers {
  const JsonHelpers._();

  // ---------------------------------------------------------------------------
  // Offset serialization (position fields) — uses {dx, dy} keys
  // ---------------------------------------------------------------------------

  /// Serialize [Offset] to V1-compatible JSON with `dx`/`dy` keys.
  static Map<String, dynamic>? offsetToJson(Offset? offset) {
    if (offset == null) return null;
    return {'dx': offset.dx, 'dy': offset.dy};
  }

  /// Deserialize [Offset] from V1 JSON. Handles both `{dx, dy}` and `{x, y}`.
  static Offset? offsetFromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final dx = (json['dx'] ?? json['x']) as num?;
    final dy = (json['dy'] ?? json['y']) as num?;
    if (dx == null || dy == null) return null;
    return Offset(dx.toDouble(), dy.toDouble());
  }

  // ---------------------------------------------------------------------------
  // Point serialization (start, end, vertices, control points) — uses {x, y}
  // ---------------------------------------------------------------------------

  /// Serialize [Offset] as a point with `x`/`y` keys (for line endpoints,
  /// shape vertices, control points).
  static Map<String, dynamic>? pointToJson(Offset? point) {
    if (point == null) return null;
    return {'x': point.dx, 'y': point.dy};
  }

  /// Deserialize [Offset] from a point JSON `{x, y}`. Also handles `{dx, dy}`.
  static Offset? pointFromJson(dynamic json) {
    // Same parsing logic — V1's offsetFromJson checks both key formats.
    return offsetFromJson(json);
  }

  // ---------------------------------------------------------------------------
  // Size serialization — uses {x, y} keys (V1 stores size as Vector2)
  // ---------------------------------------------------------------------------

  /// Serialize [Size] to V1-compatible JSON with `x`/`y` keys.
  static Map<String, dynamic>? sizeToJson(Size? size) {
    if (size == null) return null;
    return {'x': size.width, 'y': size.height};
  }

  /// Deserialize [Size] from V1 JSON `{x, y}`.
  static Size? sizeFromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final x = (json['x'] ?? json['dx']) as num?;
    final y = (json['y'] ?? json['dy']) as num?;
    if (x == null || y == null) return null;
    return Size(x.toDouble(), y.toDouble());
  }

  // ---------------------------------------------------------------------------
  // Color serialization — stored as ARGB int
  // ---------------------------------------------------------------------------

  /// Serialize [Color] to int for JSON.
  static int? colorToJson(Color? color) {
    // ignore: deprecated_member_use
    return color?.value;
  }

  /// Deserialize [Color] from int.
  static Color? colorFromJson(dynamic json) {
    if (json == null) return null;
    if (json is int) return Color(json);
    if (json is num) return Color(json.toInt());
    return null;
  }

  // ---------------------------------------------------------------------------
  // DateTime serialization — ISO8601 strings
  // ---------------------------------------------------------------------------

  static String? dateTimeToJson(DateTime? dt) => dt?.toIso8601String();

  static DateTime? dateTimeFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return DateTime.tryParse(json);
    return null;
  }

  // ---------------------------------------------------------------------------
  // List of Offsets (for free draw points, polygon vertices)
  // ---------------------------------------------------------------------------

  /// Serialize list of points using `{x, y}` format.
  static List<Map<String, dynamic>>? pointListToJson(List<Offset>? points) {
    if (points == null) return null;
    return points.map((p) => {'x': p.dx, 'y': p.dy}).toList();
  }

  /// Deserialize list of points from JSON.
  static List<Offset> pointListFromJson(dynamic json) {
    if (json is! List) return [];
    return json
        .map((item) => pointFromJson(item))
        .where((p) => p != null)
        .cast<Offset>()
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Safe numeric parsing
  // ---------------------------------------------------------------------------

  static double? toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
