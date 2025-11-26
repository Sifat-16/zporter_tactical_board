import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';

/// Service for managing user preferences using SharedPreferences + Firestore
/// - Local storage (SharedPreferences) for offline/quick access
/// - Cloud storage (Firestore) for cross-device sync and backup
/// - Uses userId from parent app for proper user identification
class UserPreferencesService {
  static const String _keyHomeTeamBorderColor = 'home_team_border_color';
  static const String _keyAwayTeamBorderColor = 'away_team_border_color';

  // Firestore collection and field names
  static const String _firestoreCollection = 'user_preferences';
  static const String _fieldHomeTeamBorderColor = 'homeTeamBorderColor';
  static const String _fieldAwayTeamBorderColor = 'awayTeamBorderColor';
  static const String _fieldLastUpdated = 'lastUpdated';

  // Default colors
  static const Color _defaultHomeColor = Color(0xFF2196F3); // Blue
  static const Color _defaultAwayColor = Color(0xFFF44336); // Red

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The user ID from the parent app (passed via TacticboardScreen)
  String? _userId;

  /// Set the user ID from the parent app
  /// Should be called when user logs in or app initializes
  void setUserId(String userId) {
    _userId = userId;
    zlog(data: 'UserPreferencesService: Set userId to $userId');
  }

  /// Get the current user ID
  /// Throws if userId hasn't been set
  String _getUserId() {
    if (_userId == null || _userId!.isEmpty) {
      zlog(data: 'ERROR: userId not set in UserPreferencesService');
      throw Exception(
          'UserPreferencesService: userId not set. Call setUserId() first.');
    }
    return _userId!;
  }

  /// Get home team border color - tries Firestore first, falls back to local
  Future<Color> getHomeTeamBorderColor() async {
    try {
      // Try to fetch from Firestore first (for cross-device sync)
      final userId = _getUserId();
      final doc =
          await _firestore.collection(_firestoreCollection).doc(userId).get();

      if (doc.exists && doc.data()?[_fieldHomeTeamBorderColor] != null) {
        final colorValue = doc.data()![_fieldHomeTeamBorderColor] as int;

        // Also update local cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_keyHomeTeamBorderColor, colorValue);

        zlog(data: 'Fetched home team color from Firestore: $colorValue');
        return Color(colorValue);
      }
    } catch (e) {
      zlog(data: 'Error fetching from Firestore, using local: $e');
    }

    // Fall back to local SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_keyHomeTeamBorderColor);
    return colorValue != null ? Color(colorValue) : _defaultHomeColor;
  }

  /// Get away team border color - tries Firestore first, falls back to local
  Future<Color> getAwayTeamBorderColor() async {
    try {
      // Try to fetch from Firestore first (for cross-device sync)
      final userId = _getUserId();
      final doc =
          await _firestore.collection(_firestoreCollection).doc(userId).get();

      if (doc.exists && doc.data()?[_fieldAwayTeamBorderColor] != null) {
        final colorValue = doc.data()![_fieldAwayTeamBorderColor] as int;

        // Also update local cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_keyAwayTeamBorderColor, colorValue);

        zlog(data: 'Fetched away team color from Firestore: $colorValue');
        return Color(colorValue);
      }
    } catch (e) {
      zlog(data: 'Error fetching from Firestore, using local: $e');
    }

    // Fall back to local SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_keyAwayTeamBorderColor);
    return colorValue != null ? Color(colorValue) : _defaultAwayColor;
  }

  /// Save home team border color - saves to both local and Firestore
  Future<void> setHomeTeamBorderColor(Color color) async {
    // Save to local storage first (immediate)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHomeTeamBorderColor, color.value);

    // Save to Firestore (for cloud backup)
    try {
      final userId = _getUserId();
      await _firestore.collection(_firestoreCollection).doc(userId).set({
        _fieldHomeTeamBorderColor: color.value,
        _fieldLastUpdated: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      zlog(data: 'Saved home team color to Firestore: ${color.value}');
    } catch (e) {
      zlog(data: 'Error saving to Firestore (saved locally): $e');
    }
  }

  /// Save away team border color - saves to both local and Firestore
  Future<void> setAwayTeamBorderColor(Color color) async {
    // Save to local storage first (immediate)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAwayTeamBorderColor, color.value);

    // Save to Firestore (for cloud backup)
    try {
      final userId = _getUserId();
      await _firestore.collection(_firestoreCollection).doc(userId).set({
        _fieldAwayTeamBorderColor: color.value,
        _fieldLastUpdated: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      zlog(data: 'Saved away team color to Firestore: ${color.value}');
    } catch (e) {
      zlog(data: 'Error saving to Firestore (saved locally): $e');
    }
  }

  /// Sync local preferences to Firestore (useful after offline changes)
  Future<void> syncToFirestore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _getUserId();

      final homeColor = prefs.getInt(_keyHomeTeamBorderColor);
      final awayColor = prefs.getInt(_keyAwayTeamBorderColor);

      final Map<String, dynamic> data = {
        _fieldLastUpdated: FieldValue.serverTimestamp(),
      };

      if (homeColor != null) {
        data[_fieldHomeTeamBorderColor] = homeColor;
      }
      if (awayColor != null) {
        data[_fieldAwayTeamBorderColor] = awayColor;
      }

      if (data.length > 1) {
        // Only sync if there's actual data
        await _firestore
            .collection(_firestoreCollection)
            .doc(userId)
            .set(data, SetOptions(merge: true));
        zlog(data: 'Synced preferences to Firestore');
      }
    } catch (e) {
      zlog(data: 'Error syncing to Firestore: $e');
    }
  }

  /// Clear all preferences (useful for testing or reset)
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHomeTeamBorderColor);
    await prefs.remove(_keyAwayTeamBorderColor);

    // Also clear from Firestore
    try {
      final userId = _getUserId();
      await _firestore.collection(_firestoreCollection).doc(userId).delete();
      zlog(data: 'Cleared preferences from local and Firestore');
    } catch (e) {
      zlog(data: 'Error clearing Firestore preferences: $e');
    }
  }
}
