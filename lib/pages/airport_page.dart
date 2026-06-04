import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import '../services/api_service.dart';

class AirportPage extends StatefulWidget {
  const AirportPage({super.key});

  @override
  State<AirportPage> createState() => _AirportPageState();
}

class _AirportPageState extends State<AirportPage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Airport Details');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(state.translate('nav_airport')),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://api.dholeraplatform.com/uploads/images/airportVision.webp',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.slate[900]),
                      ),
                      Container(color: Colors.black.withOpacity(0.4)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTag(state.translate('airport_hero_tag')),
                      const SizedBox(height: 16),
                      Text(
                        state.translate('airport_hero_title'),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.translate('airport_hero_subtitle'),
                        style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle(state.translate('airport_strategic_title')),
                      const SizedBox(height: 12),
                      Text(
                        state.translate('airport_strategic_desc'),
                        style: const TextStyle(fontSize: 15, height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      _buildCheckItem('1426 Hectares of land allocated'),
                      _buildCheckItem('4E Category - Capable of handling A380s'),
                      _buildCheckItem('Cargo-focused multi-modal logistics'),
                      _buildCheckItem('Parallel to the Ahmedabad-Dholera Expressway'),
                      const SizedBox(height: 40),
                      _buildMilestoneCard('Phase 1', 'Under Construction', 'Expected 2025-26', 'Runway and Terminal building for 1.5 million passengers per year.'),
                      _buildMilestoneCard('Phase 2', 'Planned', '2030+', 'Expansion to handle larger cargo and increased passenger traffic.'),
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

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.black, letterSpacing: 1.2, color: Colors.grey),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(String phase, String status, String date, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Text(phase, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey[300]!)),
                child: Text(status, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(date, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
