import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'field_item_model.dart';

enum PlayerType { HOME, OTHER, AWAY, UNKNOWN }

const Object _sentinel = Object();

class PlayerModel extends FieldItemModel {
  String role;
  int jerseyNumber;
  PlayerType playerType;
  String? name;
  bool showImage;
  bool showNr;
  bool showName;
  bool showRole;

  // --- MODIFIED: Keep imagePath for compatibility, add imageBase64 for persistence ---
  String? imagePath;
  String? imageBase64;

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
    required this.role,
    required this.jerseyNumber,
    required this.playerType,
    this.name,
    this.showImage = true,
    this.showName = true,
    this.showNr = true,
    this.showRole = true,
    // --- MODIFIED ---
    this.imagePath,
    this.imageBase64,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'role': role,
      'jerseyNumber': jerseyNumber,
      'playerType': playerType.name,
      'name': name,
      'showName': showName,
      'showNr': showNr,
      'showRole': showRole,
      'showImage': showImage,
      // --- MODIFIED: Add imageBase64 to the JSON output ---
      'imagePath': imagePath, // Still here for temporary use if needed
      'imageBase64': imageBase64,
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
    final jerseyNumber = json['jerseyNumber'] as int? ?? -1;
    final name = json['name'] as String?;
    final showImage = (json['showImage'] as bool?) ?? true;
    final showNr = (json['showNr'] as bool?) ?? true;
    final showName = (json['showName'] as bool?) ?? true;
    final showRole = (json['showRole'] as bool?) ?? true;

    // --- MODIFIED: Deserialize imageBase64 ---
    final imagePath = json['imagePath'] as String?;
    final imageBase64 = json['imageBase64'] as String?;

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
      name: name,
      showImage: showImage,
      showName: showName,
      showNr: showNr,
      showRole: showRole,
      role: role,
      jerseyNumber: jerseyNumber,
      playerType: playerType,
      // --- MODIFIED ---
      imagePath: imagePath,
      imageBase64: imageBase64,
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
    String? role,
    int? jerseyNumber,
    PlayerType? playerType,
    String? name,
    bool? showImage,
    bool? showNr,
    bool? showName,
    bool? showRole,
    // --- MODIFIED: Add imageBase64 and allow clearing imagePath ---
    Object? imagePath = _sentinel,
    Object? imageBase64 = _sentinel,
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
      role: role ?? this.role,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      playerType: playerType ?? this.playerType,
      name: name ?? this.name,
      showImage: showImage ?? this.showImage,
      showName: showName ?? this.showName,
      showNr: showNr ?? this.showNr,
      showRole: showRole ?? this.showRole,
      // --- MODIFIED ---
      // Important: Allow explicit null/empty to "remove" the image.
      imagePath: imagePath == _sentinel ? this.imagePath : imagePath as String?,
      imageBase64:
          imageBase64 == _sentinel ? this.imageBase64 : imageBase64 as String?,
    );
  }

  @override
  PlayerModel clone() => copyWith();
}
