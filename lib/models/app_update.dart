import '../config/api_config.dart';

class AppUpdate {
  final int id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final String imagePosition;
  final bool published;
  final bool isExclusive;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final String? seoTitle;
  final String? seoDescription;
  final String? seoKeywords;
  final String? slug;
  final String? imageAltText;
  final String? imageTitle;
  final String? tags;

  AppUpdate({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    this.imagePosition = 'top',
    required this.published,
    this.isExclusive = false,
    this.publishedAt,
    required this.createdAt,
    this.seoTitle,
    this.seoDescription,
    this.seoKeywords,
    this.slug,
    this.imageAltText,
    this.imageTitle,
    this.tags,
  });

  String? get resolvedImageUrl {
    final raw = imageUrl?.trim();
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    final baseOrigin = Uri.parse(
      ApiConfig.apiBaseUrl,
    ).replace(path: '').toString();
    final normalized = raw.startsWith('/') ? raw : '/$raw';
    return '$baseOrigin$normalized';
  }

  factory AppUpdate.fromJson(Map<String, dynamic> json) {
    return AppUpdate(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'General',
      imageUrl: json['imageUrl'],
      imagePosition: json['imagePosition'] ?? 'top',
      published: _asBool(json['published'], fallback: true),
      isExclusive: _asBool(json['isExclusive']),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      seoTitle: json['seoTitle'],
      seoDescription: json['seoDescription'],
      seoKeywords: json['seoKeywords'],
      slug: json['slug'],
      imageAltText: json['imageAltText'],
      imageTitle: json['imageTitle'],
      tags: json['tags'],
    );
  }

  static bool _asBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }

  static List<AppUpdate> fromList(List<dynamic> list) {
    return list.map((item) => AppUpdate.fromJson(item)).toList();
  }
}
