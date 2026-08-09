import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'contact_page.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Privacy Policy');
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
              title: const Text('Privacy Policy', style: TextStyle(fontSize: 16)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/dholeraexpress.webp',
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
                    'OUR PRIVACY POLICY',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.1),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'This policy explains how Dholera Platform collects, uses, stores, and deletes user data.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Effective date: August 9, 2026',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Privacy contact: gohelnaresh7707@gmail.com',
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
        _buildSectionTitle('1. Information we collect'),
        _buildSectionText('Account information: name, mobile number, email address, password hash, account role, and profile details you provide during sign-up or profile updates.'),
        _buildSectionText('Support and inquiry information: messages, contact form submissions, lead details, and any files or content you choose to upload.'),
        _buildSectionText('Device and usage information: IP address, device/user-agent information, timestamps, login events, session activity, notification token, and basic analytics needed to keep the app stable and secure.'),

        _buildSectionTitle('2. How we use your information'),
        _buildSectionText('We use your data to create and secure your account, authenticate sign-ins, keep you signed in on trusted devices, send password reset or verification emails, and show personalized account details such as your initials and profile data.'),
        _buildSectionText('We also use data to respond to support requests, moderate content, prevent abuse, improve app stability, and deliver app notifications.'),

        _buildSectionTitle('3. Sharing with service providers'),
        _buildSectionText('We do not sell your personal data. We may share data with trusted service providers only when needed to run the service, such as hosting, authentication, email delivery, storage, push notifications, and analytics. Examples may include Firebase, Cloudinary, Resend, Google services, and our backend hosting providers.'),
        _buildSectionText('We may also disclose data if required by law or to protect the rights, safety, and security of our users and platform.'),

        _buildSectionTitle('4. Retention and deletion'),
        _buildSectionText('We keep account data only as long as needed for the service, legal obligations, security, and legitimate business purposes. You can request deletion from the app settings or by contacting us at the privacy contact above. When an account is deleted, we remove associated personal data unless we must keep a limited record for fraud prevention, security, or legal compliance.'),

        _buildSectionTitle('5. Security'),
        _buildSectionText('We use reasonable technical and organizational safeguards such as encrypted transport, hashed passwords, access controls, and rate limiting. No method of transmission or storage is completely secure, so we cannot guarantee absolute security.'),

        _buildSectionTitle('6. Your choices'),
        _buildSectionText('You can review or update account information in the app, sign out of the app, delete your account, and contact us if you want help with privacy-related requests.'),

        _buildSectionTitle('7. Children'),
        _buildSectionText('The app is not intended for children under 13, and we do not knowingly collect personal data from children under 13. If you believe a child has provided personal data, contact us so we can review and delete it where appropriate.'),

        _buildSectionTitle('8. Changes to this policy'),
        _buildSectionText('We may update this policy from time to time. If we make material changes, we will update the policy in the app and revise the effective date above.'),
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
            'To request account deletion or ask a privacy question, use the in-app Contact Us page or email gohelnaresh7707@gmail.com.',
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
