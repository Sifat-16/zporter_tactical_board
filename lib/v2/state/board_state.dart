import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:zporter_tactical_board/v2/models/animation_model.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/scene_model.dart';

/// Immutable board state for the V2 tactical board.
///
/// Replaces V1's mutable [BoardState] that had 28+ fields mixing
/// data, UI flags, and Flame references. V2 separates concerns:
///
/// - **Scene data**: current scene with all components
/// - **Selection**: which element is selected
/// - **Board config**: field color, background, grid, team colors
/// - **UI transient state**: drag flags, fullscreen, guides
///
/// All positions in the scene's components are stored as relative
/// ratios (0.0–1.0), center-anchored.
class BoardStateV2 {
  // ---------------------------------------------------------------------------
  // Scene data
  // ---------------------------------------------------------------------------

  /// The current scene being edited. Contains all board elements.
  final SceneModelV2 currentScene;

  /// The animation this scene belongs to (null in standalone board mode).
  final AnimationModelV2? animation;

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  /// Currently selected element on the board (null = nothing selected).
  final String? selectedElementId;

  /// Element staged for copy/paste (null = nothing copied).
  final String? copiedElementId;

  // ---------------------------------------------------------------------------
  // Board configuration (persisted per animation/scene)
  // ---------------------------------------------------------------------------

  /// Board background layout (full pitch, half pitch, etc.).
  final BoardBackground boardBackground;

  /// Field/pitch fill color.
  final Color boardColor;

  /// Grid snap size in screen pixels (0 = grid disabled).
  final double gridSize;

  /// Home team default border color.
  final Color homeTeamBorderColor;

  /// Away team default border color.
  final Color awayTeamBorderColor;

  /// Board rotation angle (0 = normal, 1 = rotated 180°).
  final int boardAngle;

  // ---------------------------------------------------------------------------
  // UI transient state (not persisted)
  // ---------------------------------------------------------------------------

  /// Whether an element is being dragged on the board.
  final bool isDraggingItem;

  /// Whether an element is being dragged FROM the panel TO the board.
  final bool isDraggingElementToBoard;

  /// Whether the board is in fullscreen mode.
  final bool showFullScreen;

  /// Whether a fullscreen toggle animation is in progress.
  final bool isTogglingFullscreen;

  /// Whether trajectory editing mode is active.
  final bool trajectoryEditingEnabled;

  /// Whether design changes apply to all similar items.
  final bool applyDesignToAll;

  /// Whether the animation panel is visible.
  final bool showAnimation;

  /// Active smart-alignment guide lines.
  final List<GuideLine> activeGuides;

  const BoardStateV2({
    required this.currentScene,
    this.animation,
    this.selectedElementId,
    this.copiedElementId,
    this.boardBackground = BoardBackground.full,
    this.boardColor = const Color(0xFF9E9E9E),
    this.gridSize = 50.0,
    this.homeTeamBorderColor = Colors.blue,
    this.awayTeamBorderColor = const Color(0xFF974AC8),
    this.boardAngle = 0,
    this.isDraggingItem = false,
    this.isDraggingElementToBoard = false,
    this.showFullScreen = false,
    this.isTogglingFullscreen = false,
    this.trajectoryEditingEnabled = false,
    this.applyDesignToAll = false,
    this.showAnimation = false,
    this.activeGuides = const [],
  });

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------

  /// All components in the current scene.
  List<BoardElement> get components => currentScene.components;

  /// The currently selected element, or null.
  BoardElement? get selectedElement {
    if (selectedElementId == null) return null;
    try {
      return components.firstWhere((c) => c.id == selectedElementId);
    } catch (_) {
      return null;
    }
  }

  /// Field size from the current scene.
  Size get fieldSize => currentScene.fieldSize;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  BoardStateV2 copyWith({
    SceneModelV2? currentScene,
    Object? animation = _sentinel,
    Object? selectedElementId = _sentinel,
    Object? copiedElementId = _sentinel,
    BoardBackground? boardBackground,
    Color? boardColor,
    double? gridSize,
    Color? homeTeamBorderColor,
    Color? awayTeamBorderColor,
    int? boardAngle,
    bool? isDraggingItem,
    bool? isDraggingElementToBoard,
    bool? showFullScreen,
    bool? isTogglingFullscreen,
    bool? trajectoryEditingEnabled,
    bool? applyDesignToAll,
    bool? showAnimation,
    List<GuideLine>? activeGuides,
  }) {
    return BoardStateV2(
      currentScene: currentScene ?? this.currentScene,
      animation: animation == _sentinel
          ? this.animation
          : animation as AnimationModelV2?,
      selectedElementId: selectedElementId == _sentinel
          ? this.selectedElementId
          : selectedElementId as String?,
      copiedElementId: copiedElementId == _sentinel
          ? this.copiedElementId
          : copiedElementId as String?,
      boardBackground: boardBackground ?? this.boardBackground,
      boardColor: boardColor ?? this.boardColor,
      gridSize: gridSize ?? this.gridSize,
      homeTeamBorderColor: homeTeamBorderColor ?? this.homeTeamBorderColor,
      awayTeamBorderColor: awayTeamBorderColor ?? this.awayTeamBorderColor,
      boardAngle: boardAngle ?? this.boardAngle,
      isDraggingItem: isDraggingItem ?? this.isDraggingItem,
      isDraggingElementToBoard:
          isDraggingElementToBoard ?? this.isDraggingElementToBoard,
      showFullScreen: showFullScreen ?? this.showFullScreen,
      isTogglingFullscreen: isTogglingFullscreen ?? this.isTogglingFullscreen,
      trajectoryEditingEnabled:
          trajectoryEditingEnabled ?? this.trajectoryEditingEnabled,
      applyDesignToAll: applyDesignToAll ?? this.applyDesignToAll,
      showAnimation: showAnimation ?? this.showAnimation,
      activeGuides: activeGuides ?? this.activeGuides,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BoardStateV2) return false;
    return currentScene == other.currentScene &&
        animation == other.animation &&
        selectedElementId == other.selectedElementId &&
        copiedElementId == other.copiedElementId &&
        boardBackground == other.boardBackground &&
        boardColor == other.boardColor &&
        gridSize == other.gridSize &&
        homeTeamBorderColor == other.homeTeamBorderColor &&
        awayTeamBorderColor == other.awayTeamBorderColor &&
        boardAngle == other.boardAngle &&
        isDraggingItem == other.isDraggingItem &&
        isDraggingElementToBoard == other.isDraggingElementToBoard &&
        showFullScreen == other.showFullScreen &&
        isTogglingFullscreen == other.isTogglingFullscreen &&
        trajectoryEditingEnabled == other.trajectoryEditingEnabled &&
        applyDesignToAll == other.applyDesignToAll &&
        showAnimation == other.showAnimation &&
        listEquals(activeGuides, other.activeGuides);
  }

  @override
  int get hashCode => Object.hash(
        currentScene,
        animation,
        selectedElementId,
        copiedElementId,
        boardBackground,
        boardColor,
        gridSize,
        homeTeamBorderColor,
        awayTeamBorderColor,
        boardAngle,
        isDraggingItem,
        isDraggingElementToBoard,
        showFullScreen,
        isTogglingFullscreen,
        trajectoryEditingEnabled,
        applyDesignToAll,
        showAnimation,
        Object.hashAll(activeGuides),
      );
}

/// A smart-alignment guide line for snapping during drag.
class GuideLine {
  final Offset start;
  final Offset end;
  final bool isHorizontal;

  const GuideLine({
    required this.start,
    required this.end,
    required this.isHorizontal,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GuideLine) return false;
    return start == other.start &&
        end == other.end &&
        isHorizontal == other.isHorizontal;
  }

  @override
  int get hashCode => Object.hash(start, end, isHorizontal);
}

const Object _sentinel = Object();
