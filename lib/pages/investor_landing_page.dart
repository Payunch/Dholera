import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import '../models/app_update.dart';
import '../services/api_service.dart';
import 'projects_page.dart';
import 'tp_maps_page.dart';
import 'clearance_engine_page.dart';
import 'airport_page.dart';
import 'infrastructure_page.dart';
import 'updates_page.dart';
import 'portals_page.dart';

class InvestorLandingPage extends StatefulWidget {
  const InvestorLandingPage({super.key});

  @override
  State<InvestorLandingPage> createState() => _InvestorLandingPageState();
}

class _InvestorLandingPageState extends State<InvestorLandingPage> {
  final ApiService _apiService = ApiService();
  List<AppUpdate> _latestInsights = [];
  bool _isInsightsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInsights();
    _apiService.trackActivity('Investor Home');
  }

  Future<void> _fetchInsights() async {
    final response = await _apiService.getUpdates();
    if (response['success'] == true) {
      final allUpdates = AppUpdate.fromList(response['updates']);
      setState(() {
        _latestInsights = allUpdates.where((u) => u.published).take(3).toList();
        _isInsightsLoading = false;
      });
    } else {
      setState(() => _isInsightsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _fetchInsights,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(state.translate('dholera_platform')),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&q=80&w=2070',
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.translate('hero_title'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.translate('hero_subtitle'),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, state.translate('benefits_title')),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          Icons.map,
                          state.translate('verified_maps'),
                          state.translate('strategic_loc_desc'),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TpMapsPage())),
                        ),
                        _buildFeatureCard(
                          context,
                          Icons.trending_up,
                          state.translate('realtime_updates'),
                          state.translate('featured_insights_desc'),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsPage())),
                        ),
                        _buildFeatureCard(
                          context,
                          Icons.calculate,
                          state.translate('fee_calculator'),
                          state.translate('compliance_verification'),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClearanceEnginePage())),
                        ),
                        const SizedBox(height: 32),
                        _buildSectionTitle(context, 'Core Infrastructure'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSmallCard(
                                context,
                                Icons.airplanemode_active,
                                'Airport',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AirportPage())),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSmallCard(
                                context,
                                Icons.construction,
                                'Trunk Infra',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InfrastructurePage())),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildSectionTitle(context, 'Official Directories'),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          Icons.account_balance,
                          'Government Portals',
                          'Direct access to DSIRDA, RERA, and Land Records.',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PortalsPage())),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle(context, state.translate('featured_insights')),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdatesPage())),
                              child: const Text('SEE ALL'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isInsightsLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_latestInsights.isEmpty)
                          const Text('No recent updates available.')
                        else
                          ..._latestInsights.map((u) => _buildInsightCard(context, u)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String desc, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCard(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange, size: 28),
            const SizedBox(height: 12),
            Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, AppUpdate update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (update.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                update.imageUrl!.startsWith('http') ? update.imageUrl! : 'https://api.dholeraplatform.com${update.imageUrl}',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                      child: Text(update.category.toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                    Text(DateFormat('MMM dd').format(update.createdAt), style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(update.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  update.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
