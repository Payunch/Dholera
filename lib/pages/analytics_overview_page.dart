import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/analytics/analytics_models.dart';
import '../repositories/analytics_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/stat_card.dart';
import '../widgets/analytics_bar_chart.dart';
import '../widgets/analytics_line_chart.dart';
import '../widgets/heatmap_grid.dart';

class AnalyticsOverviewPage extends StatefulWidget {
  const AnalyticsOverviewPage({super.key});

  @override
  State<AnalyticsOverviewPage> createState() => _AnalyticsOverviewPageState();
}

class _AnalyticsOverviewPageState extends State<AnalyticsOverviewPage> {
  final AnalyticsRepository _repository = AnalyticsRepository();
  String _selectedFilter = 'This Month';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  late Future<AnalyticsSummary> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _analyticsFuture = _repository.getAnalytics(start: _startDate, end: _endDate);
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      final now = DateTime.now();
      if (filter == 'Today') {
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
      } else if (filter == 'Yesterday') {
        _startDate = DateTime(now.year, now.month, now.day - 1);
        _endDate = DateTime(now.year, now.month, now.day - 1, 23, 59);
      } else if (filter == 'Last 7 Days') {
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
      } else if (filter == 'This Month') {
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
      } else if (filter == 'This Year') {
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
      }
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics Overview', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: AppColors.primary),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (range != null) {
                setState(() {
                  _startDate = range.start;
                  _endDate = range.end;
                  _selectedFilter = 'Custom';
                  _loadData();
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<AnalyticsSummary>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterBar(),
                  const SizedBox(height: 24),
                  _buildStatGrid(data),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Lead Generation Trend'),
                  _buildCard(AnalyticsBarChart(metrics: data.dailyMetrics)),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Comparison Trend (Leads vs Visitors vs Updates)'),
                  _buildCard(AnalyticsLineChart(metrics: data.dailyMetrics)),
                  const SizedBox(height: 24),
                  _buildCard(AnalyticsHeatMap(metrics: data.dailyMetrics)),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Top Performing Days'),
                  _buildTopDaysList(data.topDays),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['Today', 'Yesterday', 'Last 7 Days', 'This Month', 'This Year'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(f),
            selected: _selectedFilter == f,
            onSelected: (_) => _onFilterChanged(f),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(color: _selectedFilter == f ? Colors.white : AppColors.textPrimary),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildStatGrid(AnalyticsSummary data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        StatCard(
          title: 'Total Leads',
          value: '${data.totalLeads}',
          trend: '+${data.leadTrend}%',
          isPositive: true,
          icon: Icons.person_add,
          iconColor: AppColors.primary,
        ),
        StatCard(
          title: 'Total Visitors',
          value: '${data.totalVisitors}',
          trend: '+8.2%',
          isPositive: true,
          icon: Icons.visibility,
          iconColor: AppColors.accentInfo,
        ),
        StatCard(
          title: 'Total Updates',
          value: '${data.totalUpdates}',
          trend: '-2.1%',
          isPositive: false,
          icon: Icons.update,
          iconColor: AppColors.accentSuccess,
        ),
        StatCard(
          title: 'Conv. Rate',
          value: '${data.averageConversionRate.toStringAsFixed(1)}%',
          trend: '+1.4%',
          isPositive: true,
          icon: Icons.analytics,
          iconColor: AppColors.accentWarning,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTopDaysList(List<AnalyticsMetric> topDays) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topDays.length,
      itemBuilder: (context, index) {
        final day = topDays[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text('${index + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('MMM dd, yyyy').format(day.date), style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${day.visitors} unique visitors', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.accentSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${day.leads} Leads', style: const TextStyle(color: AppColors.accentSuccess, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
