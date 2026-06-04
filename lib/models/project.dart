class Project {
  final int? id;
  final String slug;
  final String name;
  final String category;
  final String taglineKey;
  final String descKey;
  final String? plotSizes;
  final String? offering;
  final String? roadWidth;
  final String? zoning;
  final String? status;
  final bool reraApproved;
  final String? mapUrl;
  final String? whatsappText;
  final String? location;
  final String? image;

  Project({
    this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.taglineKey,
    required this.descKey,
    this.plotSizes,
    this.offering,
    this.roadWidth,
    this.zoning,
    this.status,
    this.reraApproved = false,
    this.mapUrl,
    this.whatsappText,
    this.location,
    this.image,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      taglineKey: json['taglineKey'] ?? '',
      descKey: json['descKey'] ?? '',
      plotSizes: json['plotSizes'],
      offering: json['offering'],
      roadWidth: json['roadWidth'],
      zoning: json['zoning'],
      status: json['status'],
      reraApproved: json['reraApproved'] == true,
      mapUrl: json['mapUrl'],
      whatsappText: json['whatsappText'],
      location: json['location'],
      image: json['image'],
    );
  }
}
