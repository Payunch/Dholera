class Lead {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String source;
  final int timeSpent;
  final String status;
  final String? visitedPages;
  final String? notes;
  final DateTime? lastContacted;
  final bool verified;
  final bool returningVisitor;
  final int visitCount;
  final String? otpRaw;
  final String? passcodeRaw;
  final bool isRegistered;
  final bool isRead;
  final DateTime createdAt;

  Lead({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.source,
    required this.timeSpent,
    required this.status,
    this.visitedPages,
    this.notes,
    this.lastContacted,
    required this.verified,
    required this.returningVisitor,
    required this.visitCount,
    this.otpRaw,
    this.passcodeRaw,
    required this.isRegistered,
    this.isRead = false,
    required this.createdAt,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      phone: json['phone'] ?? '',
      email: json['email'],
      source: json['source'] ?? 'Website',
      timeSpent: json['timeSpent'] ?? 0,
      status: json['status'] ?? 'New',
      visitedPages: json['visited_pages'],
      notes: json['notes'],
      lastContacted: json['last_contacted'] != null 
          ? DateTime.parse(json['last_contacted']) 
          : null,
      verified: json['verified'] ?? false,
      returningVisitor: json['returning_visitor'] ?? false,
      visitCount: json['visit_count'] ?? 1,
      otpRaw: json['otp_raw'],
      passcodeRaw: json['passcode_raw'],
      isRegistered: json['is_registered'] ?? false,
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static List<Lead> fromList(List<dynamic> list) {
    return list.map((item) => Lead.fromJson(item)).toList();
  }
}
