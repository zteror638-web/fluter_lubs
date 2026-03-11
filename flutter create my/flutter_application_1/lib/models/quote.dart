class Quote {
  final String id;
  final String content;
  final String author;
  final List<String> tags;
  bool isFavorite;
  DateTime? lastViewed;

  Quote({
    required this.id,
    required this.content,
    required this.author,
    required this.tags,
    this.isFavorite = false,
    this.lastViewed,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['_id'] ?? DateTime.now().toString(),
      content: json['content'] ?? '',
      author: json['author'] ?? 'Unknown',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author,
      'isFavorite': isFavorite ? 1 : 0,
      'lastViewed': lastViewed?.toIso8601String(),
    };
  }

  factory Quote.fromDatabase(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      content: json['content'],
      author: json['author'],
      tags: [],
      isFavorite: json['isFavorite'] == 1,
      lastViewed: json['lastViewed'] != null 
          ? DateTime.parse(json['lastViewed']) 
          : null,
    );
  }
}