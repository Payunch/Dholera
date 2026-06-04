import 'package:flutter/material.dart';
import 'login_page.dart';
import 'user/user_bottom_nav_bar.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/images/logo.png', height: 80),
              const SizedBox(height: 40),
              const Text(
                'Welcome to Dholera',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select your role to continue',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 60),
              _buildRoleCard(
                context,
                'ADMIN / OWNER',
                'Manage leads, blogs, and platform data.',
                Icons.admin_panel_settings,
                Colors.orange,
              ),
              const SizedBox(height: 24),
              _buildRoleCard(
                context,
                'USER / INVESTOR',
                'Browse TP maps, projects, and insights.',
                Icons.person,
                Colors.blue,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const UserBottomNavBar()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, String desc, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
