class PdfDocument {
  final int id;
  final String title;
  final String category;
  final DateTime createdAt;
  final DateTime? documentDate;
  final bool unlocked;

  PdfDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    this.documentDate,
    this.unlocked = false,
  });

  factory PdfDocument.fromJson(Map<String, dynamic> json) {
    return PdfDocument(
      id: json['id'],
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      documentDate: json['documentDate'] != null ? DateTime.parse(json['documentDate']) : null,
      unlocked: json['unlocked'] == true,
    );
  }

  static List<PdfDocument> fromList(List<dynamic> list) {
    return list.map((item) => PdfDocument.fromJson(item)).toList();
  }
}
