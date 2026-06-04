import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import '../services/api_service.dart';

class InfrastructurePage extends StatefulWidget {
  const InfrastructurePage({super.key});

  @override
  State<InfrastructurePage> createState() => _InfrastructurePageState();
}

class _InfrastructurePageState extends State<InfrastructurePage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Infrastructure Details');
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
                  title: Text(state.translate('nav_infrastructure')),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://api.dholeraplatform.com/uploads/images/arialviewdholeraexpress.webp',
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
                      _buildTag(state.translate('infra_hero_tag')),
                      const SizedBox(height: 16),
                      Text(
                        state.translate('infra_hero_title'),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.translate('infra_hero_subtitle'),
                        style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      _buildCategoryCard('Industrial & Semicon', Icons.memory, [
                        "Tata Electronics Mega Fab - ₹91,000 Cr",
                        "Micron ATMP Plant - Memory manufacturing",
                        "22.5 sq km allocated for Industrial activity",
                        "Direct link to Dedicated Freight Corridor"
                      ]),
                      _buildCategoryCard('Utility Powerhouse', Icons.bolt, [
                        "4400 MW Solar Park - Largest in India",
                        "24x7 Uninterrupted Industrial Power",
                        "SCADA-enabled Smart Water Management",
                        "Zero Liquid Discharge (ZLD) system"
                      ]),
                      _buildCategoryCard('Connectivity', Icons.add_road, [
                        "Ahmedabad-Dholera 109km Expressway",
                        "Massive 10-lane backbone for transit",
                        "Dholera Metro Rail connectivity planned",
                        "Multi-modal Logistic Hub (Airport + Port)"
                      ]),
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

  Widget _buildCategoryCard(String title, IconData icon, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.orange, size: 24),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
