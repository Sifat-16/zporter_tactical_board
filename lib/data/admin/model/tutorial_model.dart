// class Tutorial {
//   final String id;
//   final String name;
//   final String contentJson;
//   final String? thumbnailUrl;
//   final int orderIndex;
//
//   const Tutorial({
//     required this.id,
//     required this.name,
//     this.contentJson = '',
//     this.thumbnailUrl,
//     this.orderIndex = 0,
//   });
//
//   Tutorial copyWith({
//     String? id,
//     String? name,
//     String? contentJson,
//     String? thumbnailUrl,
//     int? orderIndex,
//   }) {
//     return Tutorial(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       contentJson: contentJson ?? this.contentJson,
//       thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
//       orderIndex: orderIndex ?? this.orderIndex,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'contentJson': contentJson,
//       'thumbnailUrl': thumbnailUrl,
//       'orderIndex': orderIndex,
//     };
//   }
//
//   factory Tutorial.fromJson(Map<String, dynamic> map) {
//     return Tutorial(
//       id: map['id'] ?? '',
//       name: map['name'] ?? '',
//       contentJson: map['contentJson'] ?? '',
//       thumbnailUrl: map['thumbnailUrl'],
//       orderIndex: map['orderIndex'] as int? ?? 0,
//     );
//   }
// }

enum TutorialType {
  richText,
  video,
}

class Tutorial {
  final String id;
  final String name;
  final String contentJson;
  final String? thumbnailUrl;
  final int orderIndex;
  // --- NEW FIELDS ---
  final TutorialType tutorialType;
  final String? videoUrl;

  const Tutorial({
    required this.id,
    required this.name,
    this.contentJson = '',
    this.thumbnailUrl,
    this.orderIndex = 0,
    // --- NEW FIELDS ---
    this.tutorialType =
        TutorialType.richText, // Default to richText for old data
    this.videoUrl,
  });

  Tutorial copyWith({
    String? id,
    String? name,
    String? contentJson,
    String? thumbnailUrl,
    int? orderIndex,
    TutorialType? tutorialType,
    String? videoUrl,
  }) {
    return Tutorial(
      id: id ?? this.id,
      name: name ?? this.name,
      contentJson: contentJson ?? this.contentJson,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      orderIndex: orderIndex ?? this.orderIndex,
      tutorialType: tutorialType ?? this.tutorialType,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contentJson': contentJson,
      'thumbnailUrl': thumbnailUrl,
      'orderIndex': orderIndex,
      // --- NEW FIELDS ---
      'tutorialType': tutorialType.name, // Save enum as a string
      'videoUrl': videoUrl,
    };
  }

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    return Tutorial(
      id: json['id'] as String,
      name: json['name'] as String,
      contentJson: json['contentJson'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
      // --- NEW FIELDS ---
      // Read enum from string, default to richText if the field doesn't exist
      tutorialType: TutorialType.values.firstWhere(
        (e) => e.name == json['tutorialType'],
        orElse: () => TutorialType.richText,
      ),
      videoUrl: json['videoUrl'] as String?,
    );
  }
}
