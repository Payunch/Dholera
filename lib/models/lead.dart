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

  final bool isPro;
  final String? browserFingerprint;
  final List<dynamic>? sessions;
  final List<String>? visitedPagesList;

  bool get isVerified => verified;

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
    this.isPro = false,
    this.browserFingerprint,
    this.sessions,
    this.visitedPagesList,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    // Handle visitedPages which can be string or list from backend merged intelligence
    List<String>? pages;
    if (json['visitedPages'] is List) {
      pages = List<String>.from(json['visitedPages']);
    }

    return Lead(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: json['name']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      source: json['source']?.toString() ?? 'Website',
      timeSpent: (json['totalTimeSpent'] is num
          ? (json['totalTimeSpent'] as num).toInt()
          : (json['timeSpent'] is num
              ? (json['timeSpent'] as num).toInt()
              : (int.tryParse(json['totalTimeSpent']?.toString() ?? json['timeSpent']?.toString() ?? '0') ?? 0))),
      status: json['status']?.toString() ?? 'New',
      visitedPages: json['visited_pages']?.toString(),
      notes: json['notes']?.toString(),
      lastContacted: json['last_contacted'] != null 
          ? DateTime.tryParse(json['last_contacted'].toString()) 
          : null,
      verified: _asBool(json['verified']),
      returningVisitor: _asBool(json['returning_visitor']),
      visitCount: json['visit_count'] is num
          ? (json['visit_count'] as num).toInt()
          : (int.tryParse(json['visit_count']?.toString() ?? '1') ?? 1),
      otpRaw: json['otp_raw']?.toString(),
      passcodeRaw: json['passcode_raw']?.toString(),
      isRegistered: _asBool(json['is_registered']),
      isRead: _asBool(json['isRead']),
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      isPro: _asBool(json['is_pro']),
      browserFingerprint: json['browserFingerprint']?.toString(),
      sessions: json['sessions'] is List ? json['sessions'] : null,
      visitedPagesList: pages,
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

  factory Lead.fromLocalMap(Map<String, dynamic> map) {
    return Lead(
      id: map['id'] is int ? map['id'] : (int.tryParse(map['id']?.toString() ?? '0') ?? 0),
      name: map['name']?.toString() ?? 'Unknown',
      phone: map['phone']?.toString() ?? '',
      source: map['source']?.toString() ?? 'Push',
      timeSpent: 0,
      status: map['status']?.toString() ?? 'New',
      verified: true,
      returningVisitor: false,
      visitCount: 1,
      isRegistered: false,
      isRead: false,
      createdAt: map['createdAt'] != null
          ? (DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  static List<Lead> fromList(List<dynamic> list) {
    return list.map((item) => Lead.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'source': source,
      'timeSpent': timeSpent,
      'status': status,
      'visited_pages': visitedPages,
      'notes': notes,
      'last_contacted': lastContacted?.toIso8601String(),
      'verified': verified,
      'returning_visitor': returningVisitor,
      'visit_count': visitCount,
      'otp_raw': otpRaw,
      'passcode_raw': passcodeRaw,
      'is_registered': isRegistered,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'is_pro': isPro,
      'browserFingerprint': browserFingerprint,
      'sessions': sessions,
      'visitedPages': visitedPagesList,
    };
  }
}
