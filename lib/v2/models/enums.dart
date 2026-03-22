/// All enums used across V2 models.
/// JSON serialization uses `.name` for V1 compatibility.

enum FieldItemType {
  PLAYER,
  EQUIPMENT,
  LINE,
  FREEDRAW,
  CIRCLE,
  SQUARE,
  TRIANGLE,
  POLYGON,
  TEXT;

  static FieldItemType fromString(String value) {
    return FieldItemType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown FieldItemType: $value'),
    );
  }
}

enum PlayerType {
  HOME,
  OTHER,
  AWAY,
  UNKNOWN;

  static PlayerType fromString(String? value) {
    if (value == null) return PlayerType.UNKNOWN;
    return PlayerType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PlayerType.UNKNOWN,
    );
  }
}

enum BallSpin {
  none,
  left,
  right,
  knuckleball;

  static BallSpin fromString(String? value) {
    if (value == null) return BallSpin.none;
    return BallSpin.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BallSpin.none,
    );
  }
}

enum LineType {
  WALK_ONE_WAY,
  WALK_TWO_WAY,
  JOG_ONE_WAY,
  JOG_TWO_WAY,
  SPRINT_ONE_WAY,
  SPRINT_TWO_WAY,
  JUMP,
  PASS,
  PASS_HIGH_CROSS,
  DRIBBLE,
  SHOOT,
  UNKNOWN;

  static LineType fromString(String? value) {
    if (value == null) return LineType.UNKNOWN;
    return LineType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LineType.UNKNOWN,
    );
  }
}

enum BoardBackground {
  full,
  halfUp,
  halfDown,
  verticalCorridors,
  clean;

  static BoardBackground fromString(String? value) {
    if (value == null) return BoardBackground.full;
    return BoardBackground.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BoardBackground.full,
    );
  }
}

enum PathType {
  straight,
  catmullRom,
  bezier;

  static PathType fromString(String? value) {
    if (value == null) return PathType.straight;
    return PathType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PathType.straight,
    );
  }
}

enum TrajectoryType {
  passing,
  dribbling,
  shooting,
  running,
  defending;

  static TrajectoryType fromString(String? value) {
    if (value == null) return TrajectoryType.running;
    return TrajectoryType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TrajectoryType.running,
    );
  }

  double get speedMultiplier {
    switch (this) {
      case TrajectoryType.passing:
        return 2.0;
      case TrajectoryType.shooting:
        return 2.5;
      case TrajectoryType.dribbling:
        return 1.2;
      case TrajectoryType.running:
        return 1.5;
      case TrajectoryType.defending:
        return 1.0;
    }
  }
}

enum TrajectoryLineStyle {
  solid,
  dashed,
  dotted;

  static TrajectoryLineStyle fromString(String? value) {
    if (value == null) return TrajectoryLineStyle.solid;
    return TrajectoryLineStyle.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TrajectoryLineStyle.solid,
    );
  }
}

enum ControlPointType {
  sharp,
  smooth,
  symmetric;

  static ControlPointType fromString(String? value) {
    if (value == null) return ControlPointType.smooth;
    return ControlPointType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ControlPointType.smooth,
    );
  }
}

enum PlaybackState {
  stopped,
  preparing,
  playing,
  paused,
  scrubbing,
}
