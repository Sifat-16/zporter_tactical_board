import 'dart:ui';

import 'package:zporter_tactical_board/v2/core/coordinate_system.dart';
import 'package:zporter_tactical_board/v2/engine/element_painters.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';

/// Hit-tests screen-pixel points against board elements.
///
/// Replaces V1's Flame `componentsAtPoint()`. Tests elements
/// in reverse z-order (top first) so the topmost overlapping
/// element is returned — matching user expectation when tapping.
class HitTester {
  const HitTester();

  /// Find the topmost element at the given screen-pixel point.
  ///
  /// Elements are tested in reverse z-order (highest zIndex first).
  /// Returns null if no element is hit.
  BoardElement? hitTest(
    Offset screenPoint,
    List<BoardElement> elements,
    CoordinateSystem coords,
  ) {
    // Sort descending by zIndex so we check top elements first
    final sorted = List.of(elements);
    sorted.sort((a, b) {
      final za = a.zIndex ?? 0;
      final zb = b.zIndex ?? 0;
      return zb.compareTo(za); // descending
    });

    for (final element in sorted) {
      final painter = getPainterForElement(element);
      if (painter.hitTest(screenPoint, element, coords)) {
        return element;
      }
    }

    return null;
  }

  /// Find all elements at the given screen-pixel point.
  ///
  /// Returns elements in z-order (topmost first).
  List<BoardElement> hitTestAll(
    Offset screenPoint,
    List<BoardElement> elements,
    CoordinateSystem coords,
  ) {
    final sorted = List.of(elements);
    sorted.sort((a, b) {
      final za = a.zIndex ?? 0;
      final zb = b.zIndex ?? 0;
      return zb.compareTo(za);
    });

    final hits = <BoardElement>[];
    for (final element in sorted) {
      final painter = getPainterForElement(element);
      if (painter.hitTest(screenPoint, element, coords)) {
        hits.add(element);
      }
    }
    return hits;
  }
}
