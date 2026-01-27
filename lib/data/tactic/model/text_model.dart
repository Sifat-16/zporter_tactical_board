import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // For Color, if needed by FieldItemModel defaults

import 'field_item_model.dart'; // Ensure this path is correct

class TextModel extends FieldItemModel {
  String text;
  String name;
  String imagePath;

  TextModel({
    required super.id,
    super.fieldItemType = FieldItemType.TEXT,
    required this.text,
    Vector2? offset,
    Vector2? size,
    Color? color,
    double? angle,
    bool? scaleSymmetrically,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? opacity,
    super.zIndex,
    required this.name,
    required this.imagePath,
  }) : super(
          // Pass through or provide defaults for other super parameters
          offset: offset ?? Vector2.zero(), // Example default
          size: size ?? Vector2(100, 30), // Example default: width, height
          color: color ?? Colors.black, // Example default
          angle: angle ?? 0.0,
          scaleSymmetrically: scaleSymmetrically ?? false,
          canBeCopied: canBeCopied ?? true,
          createdAt: createdAt ?? DateTime.now(),
          updatedAt: updatedAt ?? DateTime.now(),
          opacity: opacity ?? 1.0,
        );

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['text'] = text;
    json['name'] = name;
    json['imagePath'] = imagePath;
    return json;
  }

  static TextModel fromJson(Map<String, dynamic> json) {
    final text =
        json['text'] as String? ?? ''; // Default to empty string if null

    final id = json['_id'] as String;
    final offset = FieldItemModel.offsetFromJson(json['offset']);
    final scaleSymmetrically = json['scaleSymmetrically'] as bool? ?? false;
    final angle = json['angle'] as double?;
    final canBeCopied = json['canBeCopied'] as bool? ?? true;
    final createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    final updatedAt =
        json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null;
    final size = FieldItemModel.vector2FromJson(json['size']);
    final color = json['color'] != null ? Color(json['color']) : Colors.black;
    final opacity = json['opacity'] as double?;
    final zIndex = json['zIndex'] as int?;
    final name = json['name'] as String? ?? '';
    final imagePath = json['imagePath'] as String? ?? '';

    return TextModel(
      id: id,
      text: text,
      offset: offset,
      size: size,
      color: color,
      angle: angle,
      scaleSymmetrically: scaleSymmetrically,
      canBeCopied: canBeCopied,
      createdAt: createdAt,
      updatedAt: updatedAt,
      opacity: opacity,
      zIndex: zIndex,
      name: name,
      imagePath: imagePath,
    );
  }

  @override
  TextModel copyWith({
    // Base properties
    String? id,
    Vector2? offset,
    FieldItemType? fieldItemType, // Usually not changed in copyWith
    bool? scaleSymmetrically,
    double? angle,
    bool? canBeCopied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Vector2? size,
    Color? color,
    double? opacity,
    int? zIndex,
    String? text,
    String? name,
    String? imagePath,
  }) {
    return TextModel(
      id: id ?? this.id,
      text: text ?? this.text,
      offset: offset ?? this.offset?.clone(),
      size: size ?? this.size?.clone(),
      color: color ?? this.color,
      fieldItemType: FieldItemType.TEXT,
      angle: angle ?? this.angle,
      scaleSymmetrically: scaleSymmetrically ?? this.scaleSymmetrically,
      canBeCopied: canBeCopied ?? this.canBeCopied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      opacity: opacity ?? this.opacity,
      zIndex: zIndex ?? this.zIndex,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  TextModel clone() => copyWith();
}
