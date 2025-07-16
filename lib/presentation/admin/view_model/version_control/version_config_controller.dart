import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/data/admin/model/version_config_model.dart';

// Defines the state for our controller
class VersionConfigState {
  final VersionConfig config;
  final bool isLoading;
  final String? error;

  const VersionConfigState({
    required this.config,
    this.isLoading = false,
    this.error,
  });

  VersionConfigState copyWith({
    VersionConfig? config,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return VersionConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// The controller that manages the state
class VersionConfigController extends StateNotifier<VersionConfigState> {
  VersionConfigController()
      : super(VersionConfigState(config: VersionConfig.empty())) {
    _fetchConfig();
  }

  final _db = FirebaseFirestore.instance;
  static const String _collectionPath = 'app_config';
  static const String _documentPath = 'version_info';

  // Fetches the current configuration from Firestore
  Future<void> _fetchConfig() async {
    state = state.copyWith(isLoading: true);
    try {
      final doc =
          await _db.collection(_collectionPath).doc(_documentPath).get();
      if (doc.exists) {
        state = state.copyWith(
          config: VersionConfig.fromFirestore(doc),
          isLoading: false,
        );
      } else {
        // If the document doesn't exist, use the default empty config
        // and save it to Firestore to create it for the first time.
        await saveConfig(VersionConfig.empty());
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Saves the updated configuration to Firestore
  Future<bool> saveConfig(VersionConfig newConfig) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _db
          .collection(_collectionPath)
          .doc(_documentPath)
          .set(newConfig.toJson());
      state = state.copyWith(config: newConfig, isLoading: false);
      return true; // Indicate success
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false; // Indicate failure
    }
  }
}

// The Riverpod provider to access the controller from the UI
final versionConfigProvider =
    StateNotifierProvider<VersionConfigController, VersionConfigState>((ref) {
  return VersionConfigController();
});
