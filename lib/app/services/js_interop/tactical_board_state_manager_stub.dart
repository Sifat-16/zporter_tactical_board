/// Stub implementation of TacticalBoardStateManager for non-web platforms
/// This file provides empty implementations so the code compiles on mobile/desktop
library;

import 'package:flutter/foundation.dart';

/// Stub state manager for non-web platforms
/// This class is never actually used on mobile/desktop, but exists so code compiles
class TacticalBoardStateManager {
  TacticalBoardStateManager({
    required ValueNotifier<Map<String, dynamic>?> animationData,
    required ValueNotifier<String?> thumbnail,
    required ValueNotifier<bool> isDirty,
  });

  String? getAnimationData() => null;
  void setAnimationData(String jsonData) {}
  void onInitialAnimationDataSet(VoidCallback callback) {}
  String? getInitialAnimationDataJson() => null;
  String? getThumbnail() => null;
  bool getIsDirty() => false;
  void save() {}
  void cancel() {}
  void resize() {}
  void onSaveRequested(VoidCallback callback) {}
  void onCancelRequested(VoidCallback callback) {}
  void onResizeRequested(VoidCallback callback) {}
  void onAnimationDataChanged(VoidCallback f) {}
  void onThumbnailChanged(VoidCallback f) {}
  void onIsDirtyChanged(VoidCallback f) {}
  void notifySaveComplete() {}
  void updateThumbnail(String base64Thumbnail) {}
  void updateAnimationData(String jsonData) {}
  void setSaveResult({
    required String collectionId,
    required String animationId,
    String? thumbnailUrl,
  }) {}
  String? getSavedCollectionId() => null;
  String? getSavedAnimationId() => null;
  String? getSavedThumbnailUrl() => null;
}
