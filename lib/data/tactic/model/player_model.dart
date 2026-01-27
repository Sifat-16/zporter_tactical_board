import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'field_item_model.dart';

enum PlayerType { HOME, OTHER, AWAY, UNKNOWN }

const Object _sentinel = Object();

class PlayerModel extends FieldItemModel {
  String role;
  // --- NO CHANGE: This is now the permanent "role" number for lineups ---
  int jerseyNumber;

  // --- CHANGE 1: ADD the new editable display number ---
  int? displayNumber;

  PlayerType playerType;
  String? name;
  bool showImage;
  bool showNr;
  bool showName;
  bool showRole;

  String? imagePath;
  String? imageBase64;
  String? imageUrl; // Firebase Storage URL (Phase 2 Week 2)
  Color? borderColor; // Custom border color for team identification

  PlayerModel({
    required super.id,
    required super.offset,
    super.fieldItemType = FieldItemType.PLAYER,
    super.angle,
    super.canBeCopied = false,
    super.scaleSymmetrically = true,
    super.createdAt,
    super.updatedAt,
    super.size,
    super.color,
    super.opacity,
    super.zIndex,
    required this.role,
    required this.jerseyNumber,
    // --- CHANGE 2: Add to constructor ---
    this.displayNumber,
    required this.playerType,
    this.name,
    this.showImage = true,
    this.showName = true,
    this.showNr = true,
    this.showRole = true,
    this.imagePath,
    this.imageBase64,
    this.imageUrl,
    this.borderColor,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'role': role,
      'jerseyNumber': jerseyNumber,
      // --- CHANGE 3: Add to JSON ---
      'displayNumber': displayNumber,
      'playerType': playerType.name,
      'name': name,
      'showName': showName,
      'showNr': showNr,
      'showRole': showRole,
      'showImage': showImage,
      'imagePath': imagePath,
      'imageBase64': imageBase64,
      'imageUrl': imageUrl,
      'borderColor': borderColor?.value,
    };
  }

  /// Serialize for Firestore - EXCLUDES imageBase64 to prevent large payloads
  /// Use this method when saving to remote Firestore database
  Map<String, dynamic> toJsonForFirestore() {
    return {
      ...super.toJson(),
      'role': role,
      'jerseyNumber': jerseyNumber,
      'displayNumber': displayNumber,
      'playerType': playerType.name,
      'name': name,
      'showName': showName,
      'showNr': showNr,
      'showRole': showRole,
      'showImage': showImage,
      'imagePath': imagePath,
      // CRITICAL: Never include imageBase64 in Firestore to prevent large documents
      // 'imageBase64': imageBase64, // EXCLUDED
      'imageUrl': imageUrl,
      'borderColor': borderColor?.value,
    };
  }

  static PlayerModel fromJson(Map<String, dynamic> json) {
    final id = json['_id'];
    final offset =
        FieldItemModel.offsetFromJson(json['offset']) ?? Vector2.zero();
    final scaleSymmetrically = json['scaleSymmetrically'] as bool? ?? true;
    final angle = json['angle'] as double?;
    final canBeCopied = json['canBeCopied'] as bool? ?? false;
    final createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    final updatedAt =
        json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
    final size = FieldItemModel.vector2FromJson(json['size']);
    final color = json['color'] != null ? Color(json['color']) : null;
    final opacity = json['opacity'] == null
        ? null
        : double.parse(json['opacity'].toString());
    final playerTypeString = json['playerType'] as String?;
    final playerType = PlayerType.values.firstWhere(
      (e) => describeEnum(e) == playerTypeString,
      orElse: () => PlayerType.UNKNOWN,
    );
    final role = json['role'] as String? ?? 'Unknown';
    final name = json['name'] as String?;
    final showImage = (json['showImage'] as bool?) ?? true;
    final showNr = (json['showNr'] as bool?) ?? true;
    final showName = (json['showName'] as bool?) ?? true;
    final showRole = (json['showRole'] as bool?) ?? true;
    final imagePath = json['imagePath'] as String?;
    final imageBase64 = json['imageBase64'] as String?;
    final imageUrl = json['imageUrl'] as String?;
    final borderColor =
        json['borderColor'] != null ? Color(json['borderColor'] as int) : null;
    final zIndex = json['zIndex'] as int?;

    // --- CHANGE 4: Update fromJson for new field and data migration ---
    final jerseyNum = json['jerseyNumber'] as int? ?? -1;
    final displayNum = json['displayNumber'] as int?;

    return PlayerModel(
      id: id,
      offset: offset,
      scaleSymmetrically: scaleSymmetrically,
      angle: angle,
      canBeCopied: canBeCopied,
      createdAt: createdAt,
      updatedAt: updatedAt,
      size: size,
      color: color,
      opacity: opacity,
      zIndex: zIndex,
      name: name,
      showImage: showImage,
      showName: showName,
      showNr: showNr,
      showRole: showRole,
      role: role,
      jerseyNumber: jerseyNum,
      // If displayNumber is null (for old players), initialize it with the jerseyNumber
      displayNumber: displayNum ?? jerseyNum,
      playerType: playerType,
      imagePath: imagePath,
      imageBase64: imageBase64,
      imageUrl: imageUrl,
      borderColor: borderColor,
    );
  }

  @override
  PlayerModel copyWith({
    String? id,
    Vector2? offset,
    bool? scaleSymmetrically,
    FieldItemType? fieldItemType,
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? size,
    Color? color,
    double? opacity,
    int? zIndex,
    String? role,
    int? jerseyNumber,
    // --- CHANGE 5: Add to copyWith ---
    int? displayNumber,
    PlayerType? playerType,
    String? name,
    bool? showImage,
    bool? showNr,
    bool? showName,
    bool? showRole,
    Object? imagePath = _sentinel,
    Object? imageBase64 = _sentinel,
    Object? imageUrl = _sentinel,
    Object? borderColor = _sentinel,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      offset: offset ?? this.offset?.clone(),
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      fieldItemType: this.fieldItemType,
      angle: angle ?? this.angle,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      size: size ?? this.size,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      zIndex: zIndex ?? this.zIndex,
      role: role ?? this.role,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      // --- CHANGE 6: Update copyWith logic ---
      displayNumber: displayNumber ?? this.displayNumber,
      playerType: playerType ?? this.playerType,
      name: name ?? this.name,
      showImage: showImage ?? this.showImage,
      showName: showName ?? this.showName,
      showNr: showNr ?? this.showNr,
      showRole: showRole ?? this.showRole,
      imagePath: imagePath == _sentinel ? this.imagePath : imagePath as String?,
      imageBase64:
          imageBase64 == _sentinel ? this.imageBase64 : imageBase64 as String?,
      imageUrl: imageUrl == _sentinel ? this.imageUrl : imageUrl as String?,
      borderColor:
          borderColor == _sentinel ? this.borderColor : borderColor as Color?,
    );
  }

  @override
  PlayerModel clone() => copyWith();

  // Phase 2 Week 2: Image optimization helpers
  bool get hasBase64Image => imageBase64 != null && imageBase64!.isNotEmpty;
  bool get hasImageUrl => imageUrl != null && imageUrl!.isNotEmpty;
  bool get needsImageMigration => hasBase64Image && !hasImageUrl;
}
