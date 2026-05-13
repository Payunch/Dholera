import 'package:flutter/material.dart';
import '../models/analytics/analytics_models.dart';
import '../theme/app_colors.dart';

class AnalyticsHeatMap extends StatelessWidget {
  final List<AnalyticsMetric> metrics;

  const AnalyticsHeatMap({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    final maxLeads = metrics.map((m) => m.leads).reduce((a, b) => a > b ? a : b);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lead Activity Intensity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final metric = metrics[index];
            final intensity = maxLeads > 0 ? metric.leads / maxLeads : 0.0;
            
            return Tooltip(
              message: '${metric.date.day}/${metric.date.month}: ${metric.leads} leads',
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1 + (intensity * 0.9)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '${metric.date.day}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: intensity > 0.6 ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
