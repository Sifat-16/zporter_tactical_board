// File: lib/presentation/admin/view_model/default_animation_view_model/default_animation_state.dart
// (Adjust path as needed)

import 'package:flutter/foundation.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart'; // Adjust path

enum DefaultAnimationStatus { initial, loading, success, error }

@immutable
class DefaultAnimationState {
  final DefaultAnimationStatus status;
  final List<AnimationModel>
  defaultAnimations; // List of individual default animations
  final String? errorMessage;

  const DefaultAnimationState({
    this.status = DefaultAnimationStatus.initial,
    this.defaultAnimations = const [],
    this.errorMessage,
  });

  DefaultAnimationState copyWith({
    DefaultAnimationStatus? status,
    List<AnimationModel>? defaultAnimations,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DefaultAnimationState(
      status: status ?? this.status,
      defaultAnimations: defaultAnimations ?? this.defaultAnimations,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
