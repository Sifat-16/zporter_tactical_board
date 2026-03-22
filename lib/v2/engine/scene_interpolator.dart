import 'dart:ui' show Offset, lerpDouble;

import 'package:zporter_tactical_board/v2/engine/trajectory_calculator.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';
import 'package:zporter_tactical_board/v2/models/trajectory_model.dart';

/// Interpolates between two consecutive scenes at a given progress.
///
/// Pure static utility — no state, no side effects.
///
/// Element matching is by ID:
///   - Matched: position lerped (or trajectory path if available)
///   - Only in [to]: appears at its final position
///   - Only in [from]: omitted from result
///   - Non-position properties (color, size, role, etc.) come from [to]
class SceneInterpolator {
  SceneInterpolator._();

  /// Interpolate between [from] and [to] at [progress] (0.0–1.0).
  ///
  /// Returns a new [SceneModelV2] with interpolated element positions.
  /// Scene metadata (id, fieldColor, etc.) comes from [to].
  static SceneModelV2 interpolate({
    required SceneModelV2 from,
    required SceneModelV2 to,
    required double progress,
  }) {
    final p = progress.clamp(0.0, 1.0);

    // Build lookup for 'from' elements by ID
    final fromMap = <String, BoardElement>{};
    for (final element in from.components) {
      fromMap[element.id] = element;
    }

    // Interpolate each element in 'to' scene (preserving order)
    final interpolated = <BoardElement>[];
    for (final toElement in to.components) {
      final fromElement = fromMap[toElement.id];

      if (fromElement == null) {
        // New element — appears at its final position
        interpolated.add(toElement);
        continue;
      }

      final fromOffset = fromElement.offset;
      final toOffset = toElement.offset;

      if (fromOffset == null || toOffset == null) {
        // Can't interpolate without both offsets
        interpolated.add(toElement);
        continue;
      }

      // Check for custom trajectory
      final trajectory = to.trajectoryData?.getTrajectory(toElement.id);

      final interpolatedOffset = _interpolatePosition(
        startOffset: fromOffset,
        endOffset: toOffset,
        progress: p,
        trajectory: trajectory,
      );

      interpolated.add(toElement.copyWithBase(offset: interpolatedOffset));
    }

    return to.copyWith(components: interpolated);
  }

  /// Interpolate a single element's position.
  ///
  /// Uses straight lerp by default, or a trajectory path if available
  /// and enabled.
  static Offset _interpolatePosition({
    required Offset startOffset,
    required Offset endOffset,
    required double progress,
    TrajectoryPathV2? trajectory,
  }) {
    if (trajectory != null && trajectory.isCustomPath) {
      final path = TrajectoryCalculatorV2.calculatePath(
        startPosition: startOffset,
        endPosition: endOffset,
        trajectory: trajectory,
        frameCount: 100,
      );
      return TrajectoryCalculatorV2.getPositionAtTime(path, progress);
    }

    // Straight lerp
    return Offset(
      lerpDouble(startOffset.dx, endOffset.dx, progress)!,
      lerpDouble(startOffset.dy, endOffset.dy, progress)!,
    );
  }
}
