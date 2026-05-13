import '../../models/analytics/analytics_models.dart';
import '../services/api_service.dart';

class AnalyticsRepository {
  final ApiService _apiService = ApiService();

  Future<AnalyticsSummary> getAnalytics({
    required DateTime start,
    required DateTime end,
  }) async {
    final response = await _apiService.getDetailedAnalytics(start, end);

    if (response['success'] != true || response['analytics'] == null) {
      throw Exception(response['error'] ?? 'Failed to load detailed analytics');
    }

    final data = response['analytics'];
    
    final List<AnalyticsMetric> metrics = (data['dailyMetrics'] as List)
        .map((m) => AnalyticsMetric.fromJson(m))
        .toList();

    final List<AnalyticsMetric> topDays = (data['topDays'] as List)
        .map((m) => AnalyticsMetric.fromJson(m))
        .toList();

    return AnalyticsSummary(
      totalLeads: data['totalLeads'] ?? 0,
      totalUpdates: data['totalUpdates'] ?? 0,
      totalVisitors: data['totalVisitors'] ?? 0,
      leadTrend: (data['leadTrend'] ?? 0).toDouble(),
      dailyMetrics: metrics,
      topDays: topDays,
    );
  }
}

