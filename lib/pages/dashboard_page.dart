import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/auth_provider.dart';
import '../services/api_service.dart';
import '../config/assets.dart';
import '../theme/app_colors.dart';
import 'leads_page.dart';
import 'user_dashboard_page.dart';
import 'updates_page.dart';
import 'settings_page.dart';
import 'pdf_manager_page.dart';
import 'analytics_overview_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late ApiService _apiService;
  Map<String, dynamic>? _analytics;
  bool _isLoadingAnalytics = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoadingAnalytics = true);
    try {
      final result = await _apiService.getAnalytics();
      if (result['success'] == true) {
        setState(() => _analytics = result['analytics']);
      }
    } catch (e) {
      // Handle silently
    } finally {
      if (mounted) {
        setState(() => _isLoadingAnalytics = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(AppAssets.logo, height: 28, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            const SizedBox(width: 12),
            const Text(
              'Admin Dashboard',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.primary),
                onSelected: (value) {
                  if (value == 'logout') authProvider.logout();
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(authProvider.user?['email'] ?? 'Admin', style: const TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _isLoadingAnalytics
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    if (_analytics != null)
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.2,
                        children: [
                          _buildStatCard('Total Leads', _analytics?['totalLeads']?.toString() ?? '0', AppColors.primary, Icons.people),
                          _buildStatCard('This Month', _analytics?['leadsThisMonth']?.toString() ?? '0', AppColors.accentSuccess, Icons.trending_up),
                          _buildStatCard('Updates', _analytics?['totalUpdates']?.toString() ?? '0', AppColors.accentWarning, Icons.update),
                          _buildStatCard('Visitors', _analytics?['totalVisitors']?.toString() ?? '0', AppColors.accentInfo, Icons.visibility),
                        ],
                      )
                    else
                      const Center(child: Text('No analytics data available', style: TextStyle(color: AppColors.textSecondary))),
                    const SizedBox(height: 32),
                    const Text(
                      'Management',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    _buildActionGrid(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        _buildActionTile('Analytics', Icons.analytics, AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsOverviewPage()))),
        _buildActionTile('Leads', Icons.people, AppColors.accentInfo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeadsPage()))),
        _buildActionTile('Content', Icons.edit_document, AppColors.accentWarning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdatesPage()))),
        _buildActionTile('Documents', Icons.picture_as_pdf, AppColors.accentSuccess, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfManagerPage()))),
        _buildActionTile('Users/OTP', Icons.admin_panel_settings, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserDashboardPage()))),
        _buildActionTile('Settings', Icons.settings, AppColors.textSecondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))),
      ],
    );
  }

  Widget _buildActionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          border: Border.all(color: color.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

