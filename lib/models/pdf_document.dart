class PdfDocument {
  final int id;
  final String title;
  final String? category;
  final String? filePath;
  final bool isProtected;

  PdfDocument({
    required this.id,
    required this.title,
    this.category,
    this.filePath,
    required this.isProtected,
  });

  factory PdfDocument.fromJson(Map<String, dynamic> json) {
    return PdfDocument(
      id: json['id'],
      title: json['title'] ?? 'Untitled PDF',
      category: json['category'],
      filePath: json['file_path'],
      isProtected: json['is_protected'] ?? true,
    );
  }

  static List<PdfDocument> fromList(List<dynamic> list) {
    return list.map((item) => PdfDocument.fromJson(item)).toList();
  }
}
