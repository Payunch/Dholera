import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'contact_page.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Terms & Conditions');
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
              title: const Text('Terms & Conditions', style: TextStyle(fontSize: 16)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/arialviewdholeraexpress.webp',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0F172A)),
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.6)),
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
                  _buildTag('LEGAL'),
                  const SizedBox(height: 20),
                  const Text(
                    'TERMS OF SERVICE',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.1),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'These terms explain the rules for using Dholera Platform, your account, and your responsibilities.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Effective date: August 9, 2026',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact: gohelnaresh7707@gmail.com',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 40),
                  _buildContent(),
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

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('1. Acceptance of Terms'),
        _buildSectionText('By creating an account or using the app, you agree to these Terms. If you do not agree, do not use the service.'),

        _buildSectionTitle('2. Accounts and passwords'),
        _buildSectionText('You are responsible for keeping your login credentials confidential and for all activity under your account. You must provide accurate information and update it when it changes.'),
        _buildSectionText('If you believe your account was accessed without permission, contact us immediately so we can help secure it.'),

        _buildSectionTitle('3. Acceptable use'),
        _buildSectionText('You agree not to misuse the platform, including by uploading unlawful, harmful, defamatory, misleading, or infringing content; attempting unauthorized access; scraping or abusing the service; or interfering with the app, backend, or security controls.'),

        _buildSectionTitle('4. User content'),
        _buildSectionText('You keep ownership of the content you submit, but you give us the limited right to host, store, display, and process it so the app can function. You are responsible for making sure your content is lawful and accurate. We may remove or restrict content that violates these terms or applicable law.'),

        _buildSectionTitle('5. Information provided in the app'),
        _buildSectionText('Content in the app is for general information only. It is not legal, financial, tax, or investment advice. You should verify important information independently before making decisions.'),

        _buildSectionTitle('6. Third-party services'),
        _buildSectionText('The app may use third-party providers for authentication, hosting, messaging, storage, analytics, and notifications. Their use is subject to their own terms and privacy policies.'),

        _buildSectionTitle('7. Suspension and deletion'),
        _buildSectionText('We may suspend or terminate access if we believe the account or content violates these terms, causes security risk, or creates legal exposure. You may also delete your account from the app settings or request deletion through our contact channels.'),

        _buildSectionTitle('8. Disclaimer and limitation of liability'),
        _buildSectionText('The service is provided on an as-is and as-available basis. To the maximum extent permitted by law, we disclaim warranties of uninterrupted availability, accuracy, and fitness for a particular purpose.'),
        _buildSectionText('To the maximum extent permitted by law, Dholera Platform is not liable for indirect, incidental, special, or consequential damages arising from your use of the app.'),

        _buildSectionTitle('9. Changes to these terms'),
        _buildSectionText('We may update these terms from time to time. Continued use of the app after an update means you accept the revised terms.'),

        _buildSectionTitle('10. Contact'),
        _buildSectionText('For questions about these terms or account deletion, contact gohelnaresh7707@gmail.com or use the in-app Contact Us page.'),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
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
          const Text(
            'If you want to delete your account, use the app settings or contact us using the details above.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
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
