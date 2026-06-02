import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/auth_provider.dart';
import '../services/api_service.dart';
import '../config/assets.dart';
import '../theme/app_colors.dart';
import 'leads_page.dart';
import 'updates_page.dart';
import 'settings_page.dart';
import 'pdf_manager_page.dart';
import 'analytics_overview_page.dart';
import 'user_sessions_page.dart';
import 'approvals_page.dart';
import 'database_explorer_page.dart';
import 'system_page.dart';
import '../widgets/ad_banner.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late ApiService _apiService;
  Map<String, dynamic>? _analytics;
  bool _isLoadingAnalytics = false;
  DateTimeRange? _selectedDateRange;
  
  // Notification / Approvals state
  int _pendingApprovalsCount = 0;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    await _loadAnalytics();
    await _startNotificationPolling();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _startNotificationPolling() async {
    await _checkPendingApprovals();
    // Poll every 30 seconds
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkPendingApprovals();
    });
  }

  Future<void> _checkPendingApprovals() async {
    try {
      final result = await _apiService.getPendingCount();
      if (result['success'] == true) {
        final newCount = result['count'] ?? 0;
        
        // If count increased, show an in-app "notification" snackbar
        if (newCount > _pendingApprovalsCount && mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: const Text('🔔 NEW PAYMENT: A user is awaiting approval!', style: TextStyle(fontWeight: FontWeight.bold)),
               backgroundColor: AppColors.primary,
               duration: const Duration(seconds: 10),
               action: SnackBarAction(
                 label: 'VIEW', 
                 textColor: Colors.white, 
                 onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsPage()))
               ),
             ),
           );
        }
        
        if (mounted) {
          setState(() => _pendingApprovalsCount = newCount);
        }
      }
    } catch (e) {
      // Silent error for polling
    }
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoadingAnalytics = true);
    try {
      final result = _selectedDateRange == null
          ? await _apiService.getAnalytics()
          : await _apiService.getDetailedAnalytics(_selectedDateRange!.start, _selectedDateRange!.end);
          
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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      await _loadAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              AppAssets.logoPath,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text(
              'Master Control',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: AppColors.primary),
            onPressed: _selectDateRange,
            tooltip: 'Filter by Date',
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsPage())),
              ),
              if (_pendingApprovalsCount > 0)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      '$_pendingApprovalsCount',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
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
      body: Column(
        children: [
          Expanded(
            child: _isLoadingAnalytics
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: () async {
                      await _loadAnalytics();
                      await _checkPendingApprovals();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDateRange == null 
                                  ? 'Overview' 
                                  : '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              if (_selectedDateRange != null)
                                TextButton(
                                  onPressed: () {
                                    setState(() => _selectedDateRange = null);
                                    _loadAnalytics();
                                  },
                                  child: const Text('Reset', style: TextStyle(color: AppColors.primary)),
                                ),
                            ],
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
                                _buildStatCard('Total Leads', _analytics?['totalLeads']?.toString() ?? '0', AppColors.primary, Icons.people, hasNew: (_analytics?['leadsToday'] ?? 0) > 0),
                                _buildStatCard('Approvals', _pendingApprovalsCount.toString(), Colors.orange, Icons.check_circle, hasNew: _pendingApprovalsCount > 0),
                                _buildStatCard('This Month', _analytics?['leadsThisMonth']?.toString() ?? '0', AppColors.accentSuccess, Icons.trending_up),
                                _buildStatCard('Visitors', _analytics?['totalVisitors']?.toString() ?? '0', AppColors.accentInfo, Icons.visibility),
                              ],
                            ),
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
          ),
          const SizedBox(height: 12),
          const Center(child: AdBanner()),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon, {bool hasNew = false}) {
    return InkWell(
      onTap: title == 'Approvals' ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsPage())) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Column(
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
            if (hasNew)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
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
        _buildActionTile('Approvals', Icons.fact_check, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsPage()))),
        _buildActionTile('Analytics', Icons.analytics, AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsOverviewPage()))),
        _buildActionTile('Leads', Icons.people, AppColors.accentInfo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeadsPage()))),
        _buildActionTile('Updates', Icons.edit_document, AppColors.accentWarning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdatesPage()))),
        _buildActionTile('Documents', Icons.picture_as_pdf, AppColors.accentSuccess, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfManagerPage()))),
        _buildActionTile('Database', Icons.storage, Colors.indigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DatabaseExplorerPage()))),
        _buildActionTile('System', Icons.settings_applications, Colors.blueGrey, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemPage()))),
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
          color: color.withAlpha(13),
          border: Border.all(color: color.withAlpha(25)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
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
