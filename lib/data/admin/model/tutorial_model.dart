class Tutorial {
  final String id;
  final String name;
  final String contentJson;

  const Tutorial({
    required this.id,
    required this.name,
    this.contentJson = '',
  });

  Tutorial copyWith({
    String? id,
    String? name,
    String? contentJson,
  }) {
    return Tutorial(
      id: id ?? this.id,
      name: name ?? this.name,
      contentJson: contentJson ?? this.contentJson,
    );
  }

  // Convert a Tutorial object into a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contentJson': contentJson,
    };
  }

  // Create a Tutorial object from a Map
  factory Tutorial.fromJson(Map<String, dynamic> map) {
    return Tutorial(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      contentJson: map['contentJson'] ?? '',
    );
  }
}
