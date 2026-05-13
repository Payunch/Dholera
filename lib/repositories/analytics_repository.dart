import 'dart:math';
import '../../models/analytics/analytics_models.dart';

class AnalyticsRepository {
  Future<AnalyticsSummary> getAnalytics({
    required DateTime start,
    required DateTime end,
  }) async {
    // In a real app, you would call:
    // final response = await http.get('api/analytics?start=${start}&end=${end}');
    
    await Future.delayed(const Duration(milliseconds: 800));

    final List<AnalyticsMetric> metrics = [];
    final random = Random();
    int totalLeads = 0;
    int totalUpdates = 0;
    int totalVisitors = 0;

    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final date = start.add(Duration(days: i));
      final leads = random.nextInt(20) + 5;
      final updates = (leads * (random.nextDouble() * 0.4 + 0.1)).round();
      final visitors = leads * (random.nextInt(5) + 3);

      metrics.add(AnalyticsMetric(
        date: date,
        leads: leads,
        updates: updates,
        visitors: visitors,
      ));

      totalLeads += leads;
      totalUpdates += updates;
      totalVisitors += visitors;
    }

    final topDays = List<AnalyticsMetric>.from(metrics)
      ..sort((a, b) => b.leads.compareTo(a.leads));

    return AnalyticsSummary(
      totalLeads: totalLeads,
      totalUpdates: totalUpdates,
      totalVisitors: totalVisitors,
      leadTrend: 12.5,
      dailyMetrics: metrics,
      topDays: topDays.take(5).toList(),
    );
  }
}
