import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'contact_page.dart';

class GovernmentSchemesPage extends StatefulWidget {
  const GovernmentSchemesPage({super.key});

  @override
  State<GovernmentSchemesPage> createState() => _GovernmentSchemesPageState();
}

class _GovernmentSchemesPageState extends State<GovernmentSchemesPage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Government Schemes & Policies');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Government Schemes & Policies', style: TextStyle(fontSize: 16)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://api.dholeraplatform.com/uploads/images/futuristic_dholera.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0B132B)),
                  ),
                  Container(color: Colors.black.withOpacity(0.6)),
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
                  _buildTag('POLICY & INCENTIVES'),
                  const SizedBox(height: 20),
                  const Text(
                    'GUJARAT GOVERNMENT SUBSIDIES',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.1),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Explore the range of state and central government incentives available for industries and residents in Dholera SIR.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 40),
                  _buildContentPlaceholder(),
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
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Widget _buildContentPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.construction, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Detailed content coming soon.",
              style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCTA() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'HAVE QUESTIONS?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'Our experts are here to help you navigate Dholera.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 0.5),
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
            child: const Text('CONTACT US', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
