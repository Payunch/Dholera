import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/analytics/analytics_models.dart';
import '../theme/app_colors.dart';

class AnalyticsLineChart extends StatelessWidget {
  final List<AnalyticsMetric> metrics;

  const AnalyticsLineChart({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          lineTouchData: const LineTouchData(enabled: true),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < metrics.length && index % 10 == 0) {
                    return Text('${metrics[index].date.day}', style: const TextStyle(fontSize: 10));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            _createLineData(metrics.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.leads.toDouble())).toList(), AppColors.primary),
            _createLineData(metrics.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.visitors.toDouble())).toList(), AppColors.accentInfo),
            _createLineData(metrics.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.updates.toDouble())).toList(), AppColors.accentSuccess),
          ],
        ),
      ),
    );
  }

  LineChartBarData _createLineData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.1)),
    );
  }
}
