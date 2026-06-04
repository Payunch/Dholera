import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import 'projects_page.dart';
import 'tp_maps_page.dart';
import 'clearance_engine_page.dart';
import 'airport_page.dart';
import 'infrastructure_page.dart';

class InvestorLandingPage extends StatelessWidget {
  const InvestorLandingPage({super.key});

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
          body: CustomScrollView(
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
                              Colors.black.withOpacity(0.7),
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
                      _buildSectionTitle(context, state.translate('featured_insights')),
                      const SizedBox(height: 16),
                      Text(state.translate('featured_insights_desc')),
                    ],
                  ),
                ),
              ),
            ],
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
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
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
}
