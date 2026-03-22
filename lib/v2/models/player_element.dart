import 'dart:ui';

import 'package:zporter_tactical_board/v2/core/json_helpers.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';

/// Immutable player element on the tactical board.
///
/// Matches V1 [PlayerModel] field-for-field. JSON is V1-compatible.
class PlayerElement extends BoardElement {
  final String role;
  final int jerseyNumber;
  final int? displayNumber;
  final PlayerType playerType;
  final String? name;
  final bool showImage;
  final bool showNr;
  final bool showName;
  final bool showRole;
  final String? imagePath;
  final String? imageBase64;
  final String? imageUrl;
  final Color? borderColor;

  const PlayerElement({
    required super.id,
    super.offset,
    super.angle,
    super.canBeCopied = false,
    super.scaleSymmetrically = true,
    super.createdAt,
    super.updatedAt,
    super.size,
    super.color,
    super.opacity = 1.0,
    super.zIndex,
    required this.role,
    required this.jerseyNumber,
    this.displayNumber,
    required this.playerType,
    this.name,
    this.showImage = true,
    this.showNr = true,
    this.showName = true,
    this.showRole = true,
    this.imagePath,
    this.imageBase64,
    this.imageUrl,
    this.borderColor,
  }) : super(fieldItemType: FieldItemType.PLAYER);

  bool get hasBase64Image =>
      imageBase64 != null && imageBase64!.isNotEmpty;

  bool get hasImageUrl =>
      imageUrl != null && imageUrl!.isNotEmpty;

  bool get needsImageMigration => hasBase64Image && !hasImageUrl;

  @override
  Map<String, dynamic> toJson() {
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
      'imageBase64': imageBase64,
      'imageUrl': imageUrl,
      'borderColor': JsonHelpers.colorToJson(borderColor),
    };
  }

  /// V1-compatible: excludes imageBase64 to keep Firestore doc small.
  Map<String, dynamic> toJsonForFirestore() {
    final json = toJson();
    json.remove('imageBase64');
    return json;
  }

  factory PlayerElement.fromJson(Map<String, dynamic> json) {
    final jerseyNum = JsonHelpers.toInt(json['jerseyNumber']) ?? -1;
    final displayNum = JsonHelpers.toInt(json['displayNumber']);

    return PlayerElement(
      id: json['_id'] as String? ?? '',
      offset: JsonHelpers.offsetFromJson(json['offset']) ?? Offset.zero,
      scaleSymmetrically: json['scaleSymmetrically'] as bool? ?? true,
      angle: JsonHelpers.toDouble(json['angle']),
      canBeCopied: json['canBeCopied'] as bool? ?? false,
      createdAt: JsonHelpers.dateTimeFromJson(json['createdAt']),
      updatedAt: JsonHelpers.dateTimeFromJson(json['updatedAt']),
      size: JsonHelpers.sizeFromJson(json['size']),
      color: JsonHelpers.colorFromJson(json['color']),
      opacity: JsonHelpers.toDouble(json['opacity']) ?? 1.0,
      zIndex: JsonHelpers.toInt(json['zIndex']),
      role: json['role'] as String? ?? 'Unknown',
      jerseyNumber: jerseyNum,
      displayNumber: displayNum ?? jerseyNum,
      playerType: PlayerType.fromString(json['playerType'] as String?),
      name: json['name'] as String?,
      showImage: json['showImage'] as bool? ?? true,
      showNr: json['showNr'] as bool? ?? true,
      showName: json['showName'] as bool? ?? true,
      showRole: json['showRole'] as bool? ?? true,
      imagePath: json['imagePath'] as String?,
      imageBase64: json['imageBase64'] as String?,
      imageUrl: json['imageUrl'] as String?,
      borderColor: JsonHelpers.colorFromJson(json['borderColor']),
    );
  }

  PlayerElement copyWith({
    String? id,
    Object? offset = sentinel,
    bool? scaleSymmetrically,
    double? angle,
    bool? canBeCopied,
    Object? createdAt = sentinel,
    Object? updatedAt = sentinel,
    Object? size = sentinel,
    Object? color = sentinel,
    double? opacity,
    Object? zIndex = sentinel,
    String? role,
    int? jerseyNumber,
    Object? displayNumber = sentinel,
    PlayerType? playerType,
    Object? name = sentinel,
    bool? showImage,
    bool? showNr,
    bool? showName,
    bool? showRole,
    Object? imagePath = sentinel,
    Object? imageBase64 = sentinel,
    Object? imageUrl = sentinel,
    Object? borderColor = sentinel,
  }) {
    return PlayerElement(
      id: id ?? this.id,
      offset: offset == sentinel ? this.offset : offset as Offset?,
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      angle: angle ?? this.angle,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt:
          createdAt == sentinel ? this.createdAt : createdAt as DateTime?,
      updatedAt:
          updatedAt == sentinel ? this.updatedAt : updatedAt as DateTime?,
      size: size == sentinel ? this.size : size as Size?,
      color: color == sentinel ? this.color : color as Color?,
      opacity: opacity ?? this.opacity,
      zIndex: zIndex == sentinel ? this.zIndex : zIndex as int?,
      role: role ?? this.role,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      displayNumber: displayNumber == sentinel
          ? this.displayNumber
          : displayNumber as int?,
      playerType: playerType ?? this.playerType,
      name: name == sentinel ? this.name : name as String?,
      showImage: showImage ?? this.showImage,
      showNr: showNr ?? this.showNr,
      showName: showName ?? this.showName,
      showRole: showRole ?? this.showRole,
      imagePath:
          imagePath == sentinel ? this.imagePath : imagePath as String?,
      imageBase64: imageBase64 == sentinel
          ? this.imageBase64
          : imageBase64 as String?,
      imageUrl:
          imageUrl == sentinel ? this.imageUrl : imageUrl as String?,
      borderColor:
          borderColor == sentinel ? this.borderColor : borderColor as Color?,
    );
  }

  @override
  BoardElement copyWithBase({
    String? id,
    Object? offset = sentinel,
    bool? scaleSymmetrically,
    double? angle,
    bool? canBeCopied,
    Object? createdAt = sentinel,
    Object? updatedAt = sentinel,
    Object? size = sentinel,
    Object? color = sentinel,
    double? opacity,
    Object? zIndex = sentinel,
  }) {
    return copyWith(
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
    );
  }

  @override
  PlayerElement clone() => copyWith();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PlayerElement) return false;
    return super == other &&
        role == other.role &&
        jerseyNumber == other.jerseyNumber &&
        displayNumber == other.displayNumber &&
        playerType == other.playerType &&
        name == other.name &&
        showImage == other.showImage &&
        showNr == other.showNr &&
        showName == other.showName &&
        showRole == other.showRole &&
        imagePath == other.imagePath &&
        imageBase64 == other.imageBase64 &&
        imageUrl == other.imageUrl &&
        borderColor == other.borderColor;
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        role,
        jerseyNumber,
        displayNumber,
        playerType,
        name,
        showImage,
        showNr,
        showName,
        showRole,
        imagePath,
        imageBase64,
        imageUrl,
        borderColor,
      );
}
