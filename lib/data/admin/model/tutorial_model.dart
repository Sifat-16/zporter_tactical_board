class Tutorial {
  final String id;
  final String name;
  final String contentJson;
  final String? thumbnailUrl;

  const Tutorial({
    required this.id,
    required this.name,
    this.contentJson = '',
    this.thumbnailUrl,
  });

  Tutorial copyWith({
    String? id,
    String? name,
    String? contentJson,
    String? thumbnailUrl,
  }) {
    return Tutorial(
      id: id ?? this.id,
      name: name ?? this.name,
      contentJson: contentJson ?? this.contentJson,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contentJson': contentJson,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory Tutorial.fromJson(Map<String, dynamic> map) {
    return Tutorial(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      contentJson: map['contentJson'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
    );
  }
}
