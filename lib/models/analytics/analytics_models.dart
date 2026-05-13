class AnalyticsMetric {
  final DateTime date;
  final int leads;
  final int updates;
  final int visitors;

  AnalyticsMetric({
    required this.date,
    required this.leads,
    required this.updates,
    required this.visitors,
  });

  double get conversionRate => leads > 0 ? (updates / leads) * 100 : 0.0;

  factory AnalyticsMetric.fromJson(Map<String, dynamic> json) {
    return AnalyticsMetric(
      date: DateTime.parse(json['date']),
      leads: json['leads'] ?? 0,
      updates: json['updates'] ?? 0,
      visitors: json['visitors'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'leads': leads,
    'updates': updates,
    'visitors': visitors,
  };
}

class AnalyticsSummary {
  final int totalLeads;
  final int totalUpdates;
  final int totalVisitors;
  final double leadTrend;
  final List<AnalyticsMetric> dailyMetrics;
  final List<AnalyticsMetric> topDays;

  AnalyticsSummary({
    required this.totalLeads,
    required this.totalUpdates,
    required this.totalVisitors,
    required this.leadTrend,
    required this.dailyMetrics,
    required this.topDays,
  });

  double get averageConversionRate => totalLeads > 0 ? (totalUpdates / totalLeads) * 100 : 0.0;
}
