import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import '../services/api_service.dart';
import 'contact_page.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('About Us');
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
                  title: Text(state.translate('nav_about')),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://api.dholeraplatform.com/uploads/images/futuristic_dholera.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0F172A)),
                      ),
                      Container(color: Colors.black.withOpacity(0.5)),
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
                      _buildTag('OUR MISSION'),
                      const SizedBox(height: 20),
                      const Text(
                        'THE INTELLIGENCE HUB',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'TRANSPARENCY. VERIFICATION. GROWTH.',
                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 10),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'We are the definitive, independent digital layer for Dholera Smart City real estate and industrial intelligence.',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Established to bridge the gap between complex urban planning and investor clarity, our platform provides the most comprehensive repository of TP Maps, project specifications, and policy updates in the Dholera Special Investment Region.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.6),
                      ),
                      const SizedBox(height: 40),
                      _buildInfoGrid(),
                      const SizedBox(height: 40),
                      _buildCTA(),
                      const SizedBox(height: 40),
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
        color: Colors.orange,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Widget _buildInfoGrid() {
    final items = [
      {'title': 'Verified Data', 'desc': 'Maps and specs double-checked against official records.', 'icon': Icons.verified_user},
      {'title': 'Investor First', 'desc': 'Built to protect and empower the individual investor.', 'icon': Icons.ads_click},
      {'title': 'Expert Group', 'desc': 'Connecting developers, investors, and policymakers.', 'icon': Icons.groups},
      {'title': 'Track Record', 'desc': '5+ years monitoring DSIR infrastructure growth.', 'icon': Icons.history},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.8,
      children: items.map((item) => _buildInfoCard(item)).toList(),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item['icon'] as IconData, color: Colors.orange, size: 28),
          const SizedBox(height: 16),
          Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Text(item['desc'] as String, style: TextStyle(color: Colors.grey[600], fontSize: 10, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildCTA() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Text(
            'BUILDING THE FUTURE, ONE DECODED MAP AT A TIME.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'Join the elite circle of data-driven investors.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 0.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage())),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('CONTACT OUR EXPERTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
