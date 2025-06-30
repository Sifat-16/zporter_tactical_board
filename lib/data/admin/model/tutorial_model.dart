class Tutorial {
  final String id;
  final String name;
  final String contentJson;
  final String? thumbnailUrl;
  final int orderIndex;

  const Tutorial({
    required this.id,
    required this.name,
    this.contentJson = '',
    this.thumbnailUrl,
    this.orderIndex = 0,
  });

  Tutorial copyWith({
    String? id,
    String? name,
    String? contentJson,
    String? thumbnailUrl,
    int? orderIndex,
  }) {
    return Tutorial(
      id: id ?? this.id,
      name: name ?? this.name,
      contentJson: contentJson ?? this.contentJson,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contentJson': contentJson,
      'thumbnailUrl': thumbnailUrl,
      'orderIndex': orderIndex,
    };
  }

  factory Tutorial.fromJson(Map<String, dynamic> map) {
    return Tutorial(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      contentJson: map['contentJson'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      orderIndex: map['orderIndex'] as int? ?? 0,
    );
  }
}
