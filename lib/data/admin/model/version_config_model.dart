import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class VersionConfig {
  final bool isForceUpdateEnabled;
  final String updateTitle;
  final String updateMessage;
  final String androidStoreUrl;
  final String iosStoreUrl;
  final String defaultMinAndroidVersion;
  final String defaultMinIosVersion;
  final List<UpdateRule> rules;

  const VersionConfig({
    required this.isForceUpdateEnabled,
    required this.updateTitle,
    required this.updateMessage,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
    required this.defaultMinAndroidVersion,
    required this.defaultMinIosVersion,
    required this.rules,
  });

  VersionConfig copyWith({
    bool? isForceUpdateEnabled,
    String? updateTitle,
    String? updateMessage,
    String? androidStoreUrl,
    String? iosStoreUrl,
    String? defaultMinAndroidVersion,
    String? defaultMinIosVersion,
    List<UpdateRule>? rules,
  }) {
    return VersionConfig(
      isForceUpdateEnabled: isForceUpdateEnabled ?? this.isForceUpdateEnabled,
      updateTitle: updateTitle ?? this.updateTitle,
      updateMessage: updateMessage ?? this.updateMessage,
      androidStoreUrl: androidStoreUrl ?? this.androidStoreUrl,
      iosStoreUrl: iosStoreUrl ?? this.iosStoreUrl,
      defaultMinAndroidVersion:
          defaultMinAndroidVersion ?? this.defaultMinAndroidVersion,
      defaultMinIosVersion: defaultMinIosVersion ?? this.defaultMinIosVersion,
      rules: rules ?? this.rules,
    );
  }

  factory VersionConfig.empty() {
    return const VersionConfig(
      isForceUpdateEnabled: false,
      updateTitle: 'Update Available',
      updateMessage:
          'A new version of the app is available. Please update to continue.',
      androidStoreUrl: '',
      iosStoreUrl: '',
      defaultMinAndroidVersion: '1.0.0',
      defaultMinIosVersion: '1.0.0',
      rules: [],
    );
  }

  factory VersionConfig.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return VersionConfig(
      isForceUpdateEnabled: data['is_force_update_enabled'] ?? false,
      updateTitle: data['update_title'] ?? 'Update Available',
      updateMessage:
          data['update_message'] ?? 'Please update the app to continue.',
      androidStoreUrl: data['android_store_url'] ?? '',
      iosStoreUrl: data['ios_store_url'] ?? '',
      defaultMinAndroidVersion: data['default_min_android_version'] ?? '1.0.0',
      defaultMinIosVersion: data['default_min_ios_version'] ?? '1.0.0',
      rules: (data['rules'] as List<dynamic>? ?? [])
          .map((ruleData) =>
              UpdateRule.fromMap(ruleData as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_force_update_enabled': isForceUpdateEnabled,
      'update_title': updateTitle,
      'update_message': updateMessage,
      'android_store_url': androidStoreUrl,
      'ios_store_url': iosStoreUrl,
      'default_min_android_version': defaultMinAndroidVersion,
      'default_min_ios_version': defaultMinIosVersion,
      'rules': rules.map((rule) => rule.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VersionConfig &&
        other.isForceUpdateEnabled == isForceUpdateEnabled &&
        other.updateTitle == updateTitle &&
        other.updateMessage == updateMessage &&
        other.androidStoreUrl == androidStoreUrl &&
        other.iosStoreUrl == iosStoreUrl &&
        other.defaultMinAndroidVersion == defaultMinAndroidVersion &&
        other.defaultMinIosVersion == defaultMinIosVersion &&
        listEquals(other.rules, rules);
  }

  @override
  int get hashCode =>
      isForceUpdateEnabled.hashCode ^
      updateTitle.hashCode ^
      updateMessage.hashCode ^
      androidStoreUrl.hashCode ^
      iosStoreUrl.hashCode ^
      defaultMinAndroidVersion.hashCode ^
      defaultMinIosVersion.hashCode ^
      rules.hashCode;
}

@immutable
class UpdateRule {
  final String ruleName;
  final String updateType;
  final String minAndroidVersion;
  final String minIosVersion;
  final List<String> targetPlatforms;
  final List<String> targetAppVersions;
  final List<String> targetCountries;
  final int rolloutPercentage;
  final List<String> targetUserIds;

  const UpdateRule({
    required this.ruleName,
    this.updateType = 'hard',
    required this.minAndroidVersion,
    required this.minIosVersion,
    this.targetPlatforms = const [],
    this.targetAppVersions = const [],
    this.targetCountries = const [],
    this.rolloutPercentage = 100,
    this.targetUserIds = const [],
  });

  // --- THIS IS THE MISSING METHOD THAT IS NOW ADDED ---
  UpdateRule copyWith({
    String? ruleName,
    String? updateType,
    String? minAndroidVersion,
    String? minIosVersion,
    List<String>? targetPlatforms,
    List<String>? targetAppVersions,
    List<String>? targetCountries,
    int? rolloutPercentage,
    List<String>? targetUserIds,
  }) {
    return UpdateRule(
      ruleName: ruleName ?? this.ruleName,
      updateType: updateType ?? this.updateType,
      minAndroidVersion: minAndroidVersion ?? this.minAndroidVersion,
      minIosVersion: minIosVersion ?? this.minIosVersion,
      targetPlatforms: targetPlatforms ?? this.targetPlatforms,
      targetAppVersions: targetAppVersions ?? this.targetAppVersions,
      targetCountries: targetCountries ?? this.targetCountries,
      rolloutPercentage: rolloutPercentage ?? this.rolloutPercentage,
      targetUserIds: targetUserIds ?? this.targetUserIds,
    );
  }
  // ---------------------------------------------------

  factory UpdateRule.fromMap(Map<String, dynamic> map) {
    return UpdateRule(
      ruleName: map['rule_name'] ?? 'Untitled Rule',
      updateType: map['update_type'] ?? 'hard',
      minAndroidVersion: map['min_android_version'] ?? '1.0.0',
      minIosVersion: map['min_ios_version'] ?? '1.0.0',
      targetPlatforms: List<String>.from(map['target_platforms'] ?? []),
      targetAppVersions: List<String>.from(map['target_app_versions'] ?? []),
      targetCountries: List<String>.from(map['target_countries'] ?? []),
      rolloutPercentage: map['rollout_percentage'] ?? 100,
      targetUserIds: List<String>.from(map['target_user_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rule_name': ruleName,
      'update_type': updateType,
      'min_android_version': minAndroidVersion,
      'min_ios_version': minIosVersion,
      'target_platforms': targetPlatforms,
      'target_app_versions': targetAppVersions,
      'target_countries': targetCountries,
      'rollout_percentage': rolloutPercentage,
      'target_user_ids': targetUserIds,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateRule &&
        other.ruleName == ruleName &&
        other.updateType == updateType &&
        other.minAndroidVersion == minAndroidVersion &&
        other.minIosVersion == minIosVersion &&
        listEquals(other.targetPlatforms, targetPlatforms) &&
        listEquals(other.targetAppVersions, targetAppVersions) &&
        listEquals(other.targetCountries, targetCountries) &&
        other.rolloutPercentage == rolloutPercentage &&
        listEquals(other.targetUserIds, targetUserIds);
  }

  @override
  int get hashCode =>
      ruleName.hashCode ^
      updateType.hashCode ^
      minAndroidVersion.hashCode ^
      minIosVersion.hashCode ^
      targetPlatforms.hashCode ^
      targetAppVersions.hashCode ^
      targetCountries.hashCode ^
      rolloutPercentage.hashCode ^
      targetUserIds.hashCode;
}
