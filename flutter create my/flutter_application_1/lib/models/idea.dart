class Idea {
  final String id;
  String content;
  DateTime createdAt;
  bool isFavorite;

  Idea({
    required this.id,
    required this.content,
    required this.createdAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      isFavorite: json['isFavorite'],
    );
  }
}