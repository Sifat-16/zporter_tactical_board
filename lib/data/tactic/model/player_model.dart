// import 'package:flame/components.dart';
// import 'package:flutter/foundation.dart'; // For describeEnum
// import 'package:flutter/material.dart'; // For Color
//
// // Assuming FieldItemModel and its helpers (vector2ToJson/FromJson, parseObjectId etc.)
// // are defined in 'field_item_model.dart' or imported correctly.
// import 'field_item_model.dart';
//
// // Ensure this enum definition matches your project
// enum PlayerType { HOME, OTHER, AWAY, UNKNOWN }
//
// class PlayerModel extends FieldItemModel {
//   String role;
//   String? imagePath;
//   int jerseyNumber;
//   PlayerType playerType;
//   String? name;
//   bool showImage;
//   bool showNr;
//   bool showName;
//   bool showRole;
//
//   String? imageBase64;
//
//   PlayerModel(
//       {
//       // --- Base FieldItemModel properties ---
//       required super.id,
//       required super.offset, // PlayerModel seems to require offset unlike others
//       super.fieldItemType =
//           FieldItemType.PLAYER, // Default type for PlayerModel
//       super.angle,
//       super.canBeCopied = false, // Keep existing default from provided code
//       super.scaleSymmetrically =
//           true, // Keep existing default from provided code
//       super.createdAt,
//       super.updatedAt,
//       // --- New FieldItemModel properties ---
//       super.size,
//       super.color, // You might set a default color based on playerType later
//       super.opacity,
//       // --- PlayerModel specific properties ---
//       required this.role,
//       required this.jerseyNumber,
//       required this.playerType,
//       this.imagePath,
//       this.showImage = true,
//       this.showName = true,
//       this.showNr = true,
//       this.showRole = true,
//       this.name});
//
//   @override
//   Map<String, dynamic> toJson() {
//     // Keep existing toJson logic
//     return {
//       ...super.toJson(), // Includes base fields + fieldItemType='PLAYER'
//       'role': role,
//       'imagePath': imagePath,
//       'jerseyNumber': jerseyNumber,
//       'playerType': playerType.name,
//       'name': name,
//       'showName': showName,
//       'showNr': showNr,
//       'showRole': showRole,
//       'showImage': showImage
//       // Use describeEnum for serialization
//     };
//   }
//
//   // --- FIXED fromJson Static Method ---
//   static PlayerModel fromJson(Map<String, dynamic> json) {
//     // --- Parse Base Class Properties DIRECTLY from JSON ---
//     // DO NOT call FieldItemModel.fromJson(json) here!
//     // Use static helpers from FieldItemModel where appropriate.
//
//     final id = json['_id']; // Use helper
//     final offset = FieldItemModel.offsetFromJson(json['offset']) ??
//         Vector2.zero(); // Use helper + Default
//     final scaleSymmetrically =
//         json['scaleSymmetrically'] as bool? ?? true; // Default from constructor
//     final angle = json['angle'] as double?;
//     final canBeCopied =
//         json['canBeCopied'] as bool? ?? false; // Default from constructor
//     final createdAt =
//         json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
//     final updatedAt =
//         json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
//     final size = FieldItemModel.vector2FromJson(json['size']); // Use helper
//     final color = json['color'] != null ? Color(json['color']) : null;
//     final opacity = json['opacity'] == null
//         ? null
//         : double.parse(json['opacity'].toString());
//
//     // final fieldItemType = FieldItemType.PLAYER; // We know this because we are in PlayerModel.fromJson
//
//     // --- Deserialize PlayerModel Specific Properties (Keep Existing Logic) ---
//     final playerTypeString = json['playerType'] as String?;
//     final playerType = PlayerType.values.firstWhere(
//       (e) => describeEnum(e) == playerTypeString,
//       orElse: () => PlayerType.UNKNOWN, // Default if null or invalid
//     );
//     final role = json['role'] as String? ?? 'Unknown'; // Default if null
//     final jerseyNumber = json['jerseyNumber'] as int? ?? -1; // Default if null
//     final imagePath = json['imagePath'] as String?;
//
//     final name = json['name'] as String?;
//
//     bool showImage = (json['showImage'] as bool?) ?? true;
//     bool showNr = (json['showNr'] as bool?) ?? true;
//     bool showName = (json['showName'] as bool?) ?? true;
//     bool showRole = (json['showRole'] as bool?) ?? true;
//
//     // --- Construct and Return PlayerModel Instance ---
//     return PlayerModel(
//       // Pass parsed base properties
//       id: id,
//       offset: offset,
//       scaleSymmetrically: scaleSymmetrically,
//       angle: angle,
//       canBeCopied: canBeCopied,
//       createdAt: createdAt,
//       updatedAt: updatedAt,
//       size: size,
//       color: color,
//       opacity: opacity,
//       name: name,
//       showImage: showImage,
//       showName: showName,
//       showNr: showNr,
//       showRole: showRole,
//       // fieldItemType is set automatically by PlayerModel constructor
//
//       // Pass parsed PlayerModel specific properties
//       role: role,
//       jerseyNumber: jerseyNumber,
//       imagePath: imagePath,
//       playerType: playerType,
//     );
//   }
//
//   // --- copyWith and clone remain unchanged from your provided code ---
//   @override
//   PlayerModel copyWith(
//       {
//       // --- Base FieldItemModel properties ---
//       String? id,
//       Vector2? offset,
//       bool? scaleSymmetrically,
//       FieldItemType? fieldItemType, // Usually not overridden for specific types
//       double? angle,
//       bool? canBeCopied,
//       DateTime? createdAt,
//       DateTime? updatedAt,
//       Vector2? size,
//       Color? color,
//       double? opacity,
//       // --- PlayerModel properties ---
//       String? role,
//       int? jerseyNumber,
//       String? imagePath,
//       PlayerType? playerType,
//       String? name,
//       bool? showImage,
//       bool? showNr,
//       bool? showName,
//       bool? showRole}) {
//     return PlayerModel(
//         // --- Use new or existing values for base properties ---
//         id: id ?? this.id,
//         offset: offset ??
//             this
//                 .offset
//                 ?.clone(), // Assumes Vector2 is immutable OR handle clone if needed
//         scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
//         fieldItemType: this.fieldItemType, // Keep original type PLAYER
//         angle: angle ?? this.angle,
//         canBeCopied: canBeCopied ?? this.canBeCopied,
//         createdAt: createdAt ?? this.createdAt,
//         updatedAt: updatedAt ?? this.updatedAt,
//         size: size ??
//             this.size, // Assumes Vector2 is immutable OR handle clone if needed
//         color: color ?? this.color, // Color is immutable
//         opacity: opacity ?? this.opacity,
//         // --- Use new or existing values for PlayerModel properties ---
//         role: role ?? this.role,
//         jerseyNumber: jerseyNumber ?? this.jerseyNumber,
//         imagePath:
//             imagePath ?? this.imagePath, // Handles null assignment correctly
//         playerType: playerType ?? this.playerType,
//         name: name ?? this.name,
//         showImage: showImage ?? this.showImage,
//         showName: showName ?? this.showName,
//         showNr: showNr ?? this.showNr,
//         showRole: showRole ?? this.showRole);
//   }
//
//   @override
//   PlayerModel clone() => copyWith(); // Keep simplified clone
// }

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'field_item_model.dart';

enum PlayerType { HOME, OTHER, AWAY, UNKNOWN }

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
    String? imagePath,
    String? imageBase64,
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
      imagePath: imagePath,
      imageBase64: imageBase64,
    );
  }

  @override
  PlayerModel clone() => copyWith();
}
