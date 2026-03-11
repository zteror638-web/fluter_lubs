class Idea {
  final String id;
  String content;
  String? description;
  DateTime createdAt;
  bool isFavorite;
  String? source;
  Color? color;
  String? category;

  Idea({
    required this.id,
    required this.content,
    this.description,
    required this.createdAt,
    this.isFavorite = false,
    this.source,
    this.color,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
      'source': source,
      'colorValue': color?.value,
      'category': category,
    };
  }

  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      id: json['id'],
      content: json['content'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      isFavorite: json['isFavorite'] == 1,
      source: json['source'],
      color: json['colorValue'] != null 
          ? Color(json['colorValue']) 
          : null,
      category: json['category'],
    );
  }
}