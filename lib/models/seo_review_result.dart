class SeoReviewResult {
  final int estimatedScore;
  final String primaryKeyword;
  final String seoTitle;
  final String metaDescription;
  final String slug;
  final String imageAltText;
  final String imageTitle;
  final List<String> tags;
  final List<String> missingItems;
  final List<String> improvements;
  final List<String> faqQuestions;

  SeoReviewResult({
    required this.estimatedScore,
    required this.primaryKeyword,
    required this.seoTitle,
    required this.metaDescription,
    required this.slug,
    required this.imageAltText,
    required this.imageTitle,
    required this.tags,
    required this.missingItems,
    required this.improvements,
    required this.faqQuestions,
  });

  factory SeoReviewResult.fromJson(Map<String, dynamic> json) {
    return SeoReviewResult(
      estimatedScore: json['estimatedScore'] ?? 0,
      primaryKeyword: json['primaryKeyword'] ?? '',
      seoTitle: json['seoTitle'] ?? '',
      metaDescription: json['metaDescription'] ?? '',
      slug: json['slug'] ?? '',
      imageAltText: json['imageAltText'] ?? '',
      imageTitle: json['imageTitle'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      missingItems: List<String>.from(json['missingItems'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
      faqQuestions: List<String>.from(json['faqQuestions'] ?? []),
    );
  }
}
