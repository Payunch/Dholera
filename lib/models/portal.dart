class Portal {
  final int id;
  final String category;
  final String categorySubtitle;
  final String name;
  final String desc;
  final String url;

  Portal({
    required this.id,
    required this.category,
    required this.categorySubtitle,
    required this.name,
    required this.desc,
    required this.url,
  });

  factory Portal.fromJson(Map<String, dynamic> json) {
    return Portal(
      id: json['id'],
      category: json['category'] ?? '',
      categorySubtitle: json['category_subtitle'] ?? '',
      name: json['name'] ?? '',
      desc: json['desc'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
