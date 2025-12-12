import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

// Extension to access custom window properties
extension WindowExtension on web.Window {
  @JS('__tacticalBoardSaveRequestId')
  external JSString? get tacticalBoardSaveRequestId;
}

// JavaScript interop classes for postMessage data
@JS()
@anonymous
extension type SaveResultJS._(JSObject _) implements JSObject {
  external factory SaveResultJS({
    String collectionId,
    String animationId,
    String? thumbnailUrl,
  });
}

@JS()
@anonymous
extension type SaveMessageJS._(JSObject _) implements JSObject {
  external factory SaveMessageJS({
    String type,
    String requestId,
    SaveResultJS result,
  });
}

/// State manager that is exposed to JavaScript via JS Interop.
/// Allows the parent web application to control and interact with the
/// Flutter tactical board widget.
///
/// Based on the ng-flutter example from Flutter samples.
@JSExport()
class TacticalBoardStateManager {
  TacticalBoardStateManager({
    required ValueNotifier<Map<String, dynamic>?> animationData,
    required ValueNotifier<String?> thumbnail,
    required ValueNotifier<bool> isDirty,
  })  : _animationData = animationData,
        _thumbnail = thumbnail,
        _isDirty = isDirty;

  final ValueNotifier<Map<String, dynamic>?> _animationData;
  final ValueNotifier<String?> _thumbnail;
  final ValueNotifier<bool> _isDirty;

  // Store the raw JSON string for getAnimationData()
  String? _animationDataJson;

  // Callbacks that will be set by the Flutter widget
  VoidCallback? _onSaveCallback;
  VoidCallback? _onCancelCallback;

  // Callback for when initial animation data is set by JavaScript
  VoidCallback? _onInitialAnimationDataSet;

  /// Get the current animation data as JSON string
  /// Returns null if no data is loaded
  String? getAnimationData() {
    print(
        '[TacticalBoardStateManager] getAnimationData called, returning: ${_animationDataJson?.substring(0, _animationDataJson!.length > 100 ? 100 : _animationDataJson!.length)}...');
    return _animationDataJson;
  }

  /// Set animation data from JavaScript
  /// This is called by the parent app to load initial data
  void setAnimationData(String jsonData) {
    print(
        '[TacticalBoardStateManager] setAnimationData called with: ${jsonData.substring(0, jsonData.length > 100 ? 100 : jsonData.length)}...');
    _animationDataJson = jsonData;
    _isDirty.value = true;
    // Notify Flutter widget that initial animation data was set
    _onInitialAnimationDataSet?.call();
  }

  /// Register callback for when initial animation data is set from JavaScript
  /// The Flutter widget uses this to load the animation data into the board
  /// If animation data was already set before the callback was registered,
  /// the callback will be called immediately.
  void onInitialAnimationDataSet(VoidCallback callback) {
    _onInitialAnimationDataSet = callback;
    print(
        '[TacticalBoardStateManager] Initial animation data callback registered');

    // If animation data was already set before callback was registered,
    // call the callback immediately
    if (_animationDataJson != null && _animationDataJson!.isNotEmpty) {
      print(
          '[TacticalBoardStateManager] Animation data already exists, calling callback immediately');
      callback();
    }
  }

  /// Get the initial animation data JSON (used by Flutter widget to load data)
  String? getInitialAnimationDataJson() {
    return _animationDataJson;
  }

  /// Get the current thumbnail (base64 encoded PNG)
  /// Returns null if no thumbnail has been generated
  String? getThumbnail() {
    print(
        '[TacticalBoardStateManager] getThumbnail called, has value: ${_thumbnail.value != null && _thumbnail.value!.isNotEmpty}');
    return _thumbnail.value;
  }

  /// Check if the board has unsaved changes
  bool getIsDirty() {
    return _isDirty.value;
  }

  /// Request save operation
  /// This triggers the Flutter widget to capture thumbnail and prepare data
  void save() {
    print('[TacticalBoardStateManager] save() called from JavaScript');
    _onSaveCallback?.call();
  }

  /// Request cancel operation
  /// This triggers the Flutter widget to close without saving
  void cancel() {
    print('[TacticalBoardStateManager] cancel() called from JavaScript');
    _onCancelCallback?.call();
  }

  /// Register callback for save requests
  /// Called by the Flutter widget to handle save operations
  void onSaveRequested(VoidCallback callback) {
    _onSaveCallback = callback;
    print('[TacticalBoardStateManager] Save callback registered');
  }

  /// Register callback for cancel requests
  /// Called by the Flutter widget to handle cancel operations
  void onCancelRequested(VoidCallback callback) {
    _onCancelCallback = callback;
    print('[TacticalBoardStateManager] Cancel callback registered');
  }

  /// Allows parent app to subscribe to animation data changes
  void onAnimationDataChanged(VoidCallback f) {
    _animationData.addListener(f);
  }

  /// Allows parent app to subscribe to thumbnail changes
  void onThumbnailChanged(VoidCallback f) {
    _thumbnail.addListener(f);
  }

  /// Allows parent app to subscribe to dirty state changes
  void onIsDirtyChanged(VoidCallback f) {
    _isDirty.addListener(f);
  }

  /// Notify that data has been saved successfully
  /// This is called by the Flutter widget after save completes
  void notifySaveComplete() {
    _isDirty.value = false;
    print('[TacticalBoardStateManager] Save complete, isDirty = false');
  }

  /// Update the thumbnail
  /// Called by the Flutter widget when thumbnail is captured
  void updateThumbnail(String base64Thumbnail) {
    _thumbnail.value = base64Thumbnail;
    print(
        '[TacticalBoardStateManager] Thumbnail updated (${base64Thumbnail.length} chars)');
  }

  /// Update the animation data
  /// Called by the Flutter widget when data changes
  void updateAnimationData(String jsonData) {
    print(
        '[TacticalBoardStateManager] Animation data updated (${jsonData.length} chars)');
    _animationDataJson = jsonData;
    _isDirty.value = true;
  }

  // ============== SAVE RESULT DATA ==============
  // These store the results after saving to Firebase

  String? _savedCollectionId;
  String? _savedAnimationId;
  String? _savedThumbnailUrl;

  /// Set save result data after successful Firebase save and notify React via postMessage
  /// Called by Flutter widget after saving animation to Firebase
  ///
  /// This implements the event-driven save protocol:
  /// 1. Read the requestId from window.__tacticalBoardSaveRequestId
  /// 2. Send postMessage with type 'TACTICAL_BOARD_SAVED' and the save result
  /// 3. Store the result data for backward compatibility (polling approach)
  void setSaveResult({
    required String collectionId,
    required String animationId,
    String? thumbnailUrl,
  }) {
    _savedCollectionId = collectionId;
    _savedAnimationId = animationId;
    _savedThumbnailUrl = thumbnailUrl;

    final truncatedUrl = thumbnailUrl != null && thumbnailUrl.length > 50
        ? '${thumbnailUrl.substring(0, 50)}...'
        : thumbnailUrl;
    print(
        '[TacticalBoardStateManager] Save result set: collectionId=$collectionId, animationId=$animationId, thumbnailUrl=$truncatedUrl');

    // EVENT-DRIVEN APPROACH: Send postMessage to React
    _notifyReactSaveComplete(
      collectionId: collectionId,
      animationId: animationId,
      thumbnailUrl: thumbnailUrl,
    );
  }

  /// Notify React that save is complete via postMessage (event-driven approach)
  void _notifyReactSaveComplete({
    required String collectionId,
    required String animationId,
    String? thumbnailUrl,
  }) {
    try {
      // Step 1: Read the requestId that React stored in window
      final requestId = _getRequestIdFromWindow();

      if (requestId == null) {
        print(
            '[TacticalBoardStateManager] WARNING: No requestId found in window.__tacticalBoardSaveRequestId - React may be using polling approach');
        // Still continue - backward compatible with polling approach
        return;
      }

      // Step 2: Create JavaScript objects using proper interop types
      final result = SaveResultJS(
        collectionId: collectionId,
        animationId: animationId,
        thumbnailUrl: thumbnailUrl,
      );

      final message = SaveMessageJS(
        type: 'TACTICAL_BOARD_SAVED',
        requestId: requestId,
        result: result,
      );

      // Step 3: Send postMessage to window (React app)
      web.window.postMessage(message, '*'.toJS);

      print(
          '[TacticalBoardStateManager] ✅ Posted TACTICAL_BOARD_SAVED event to React with requestId: $requestId');
    } catch (e, stackTrace) {
      print(
          '[TacticalBoardStateManager] ❌ Error sending postMessage to React: $e');
      print('[TacticalBoardStateManager] Stack trace: $stackTrace');
      // Don't throw - backward compatible with polling approach
    }
  }

  /// Read the requestId that React stored in window.__tacticalBoardSaveRequestId
  String? _getRequestIdFromWindow() {
    try {
      // Use extension method to access window property
      final requestIdJS = web.window.tacticalBoardSaveRequestId;

      if (requestIdJS == null) {
        return null;
      }

      return requestIdJS.toDart;
    } catch (e) {
      print(
          '[TacticalBoardStateManager] Error reading requestId from window: $e');
      return null;
    }
  }

  /// Get saved collection ID (called by React after save)
  String? getSavedCollectionId() {
    return _savedCollectionId;
  }

  /// Get saved animation ID (called by React after save)
  String? getSavedAnimationId() {
    return _savedAnimationId;
  }

  /// Get saved thumbnail URL (called by React after save)
  String? getSavedThumbnailUrl() {
    return _savedThumbnailUrl;
  }

  /// Clear save result data
  void clearSaveResult() {
    _savedCollectionId = null;
    _savedAnimationId = null;
    _savedThumbnailUrl = null;
  }
}
