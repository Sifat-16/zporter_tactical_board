import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences using SharedPreferences
/// Stores global settings like team border colors that persist across app restarts
class UserPreferencesService {
  static const String _keyHomeTeamBorderColor = 'home_team_border_color';
  static const String _keyAwayTeamBorderColor = 'away_team_border_color';

  // Default colors
  static const Color _defaultHomeColor = Color(0xFF2196F3); // Blue
  static const Color _defaultAwayColor = Color(0xFFF44336); // Red

  /// Get home team border color from preferences
  Future<Color> getHomeTeamBorderColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_keyHomeTeamBorderColor);
    return colorValue != null ? Color(colorValue) : _defaultHomeColor;
  }

  /// Get away team border color from preferences
  Future<Color> getAwayTeamBorderColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_keyAwayTeamBorderColor);
    return colorValue != null ? Color(colorValue) : _defaultAwayColor;
  }

  /// Save home team border color to preferences
  Future<void> setHomeTeamBorderColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHomeTeamBorderColor, color.value);
  }

  /// Save away team border color to preferences
  Future<void> setAwayTeamBorderColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAwayTeamBorderColor, color.value);
  }

  /// Clear all preferences (useful for testing or reset)
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHomeTeamBorderColor);
    await prefs.remove(_keyAwayTeamBorderColor);
  }
}
