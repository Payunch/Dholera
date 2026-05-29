class PdfDocument {
  final int id;
  final String title;
  final String? category;
  final String? filePath;
  final bool isProtected;
  final DateTime? createdAt;

  PdfDocument({
    required this.id,
    required this.title,
    this.category,
    this.filePath,
    required this.isProtected,
    this.createdAt,
  });

  factory PdfDocument.fromJson(Map<String, dynamic> json) {
    return PdfDocument(
      id: json['id'],
      title: json['title'] ?? 'Untitled PDF',
      category: json['category'],
      filePath: json['file_path'],
      isProtected: json['is_protected'] ?? true,
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at'] ?? json['uploadedAt'] ?? json['uploaded_at'] ?? json['uploadDate'] ?? json['upload_date']),
    );
  }

  static List<PdfDocument> fromList(List<dynamic> list) {
    return list.map((item) => PdfDocument.fromJson(item)).toList();
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value)?.toLocal();
    return null;
  }
}
