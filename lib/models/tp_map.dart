class TpMap {
  final int? id;
  final String tpId;
  final String title;
  final String area;
  final String focus;
  final List<dynamic> badges;

  TpMap({
    this.id,
    required this.tpId,
    required this.title,
    required this.area,
    required this.focus,
    required this.badges,
  });

  factory TpMap.fromJson(Map<String, dynamic> json) {
    return TpMap(
      id: json['id'],
      tpId: json['tp_id'] ?? '',
      title: json['title'] ?? '',
      area: json['area'] ?? '',
      focus: json['focus'] ?? '',
      badges: json['badges'] ?? [],
    );
  }
}
