class AppUpdate {
  final int id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final String imagePosition;
  final bool published;
  final DateTime? publishedAt;
  final DateTime createdAt;

  AppUpdate({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    this.imagePosition = 'top',
    required this.published,
    this.publishedAt,
    required this.createdAt,
  });

  factory AppUpdate.fromJson(Map<String, dynamic> json) {
    return AppUpdate(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'General',
      imageUrl: json['imageUrl'],
      imagePosition: json['imagePosition'] ?? 'top',
      published: json['published'] ?? true,
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static List<AppUpdate> fromList(List<dynamic> list) {
    return list.map((item) => AppUpdate.fromJson(item)).toList();
  }
}
