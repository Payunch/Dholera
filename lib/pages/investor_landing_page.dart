import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import '../models/app_update.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'projects_page.dart';
import 'project_detail_page.dart';
import 'tp_maps_page.dart';
import 'clearance_engine_page.dart';
import 'airport_page.dart';
import 'infrastructure_page.dart';
import 'update_detail_page.dart';
import 'portals_page.dart';
import 'government_schemes_page.dart';
import 'investment_guide_page.dart';
import 'plots_for_sale_page.dart';
import 'smart_city_page.dart';
import 'updates_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'travel_lifestyle_page.dart';
import 'privacy_policy_page.dart';
import 'terms_page.dart';
import 'settings_page.dart';

class InvestorLandingPage extends StatefulWidget {
  const InvestorLandingPage({super.key});

  @override
  State<InvestorLandingPage> createState() => _InvestorLandingPageState();
}

class _InvestorLandingPageState extends State<InvestorLandingPage> {
  final ApiService _apiService = ApiService();
  StreamSubscription? _notificationSubscription;
  List<AppUpdate> _latestInsights = [];
  List<Project> _featuredProjects = [];
  bool _isInsightsLoading = true;

  // Site visit form state
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  DateTime? _visitDate;
  bool _isSubmitting = false;
  bool _isSubmitSuccess = false;

  @override
  void initState() {
    super.initState();
    _fetchInsights();
    _setupNotificationListener();
    _apiService.trackActivity('Investor Home');
  }

  void _setupNotificationListener() {
    _notificationSubscription = NotificationService.dataStream.listen((data) {
      if (!mounted) return;

      final notificationType = data['type']?.toString();
      if (notificationType != 'insight') {
        return;
      }

      _fetchInsights();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['title']?.toString() ?? 'A new update is available',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'VIEW',
            textColor: Colors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UpdatesPage()),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchInsights() async {
    try {
      final lang = context.read<LocalizationBloc>().state.locale.languageCode;
      final updatesResponse = await _apiService.getUpdates(lang: lang, audience: 'app');
      final projectsResponse = await _apiService.getProjects();

      if (mounted) {
        setState(() {
          if (updatesResponse['success'] == true) {
            final allUpdates = AppUpdate.fromList(updatesResponse['updates']);
            _latestInsights = allUpdates
                .where((u) => u.published)
                .take(3)
                .toList();
          }
          if (projectsResponse['success'] == true) {
            final allProjects = (projectsResponse['projects'] as List)
                .map((p) => Project.fromJson(p))
                .toList();
            _featuredProjects = allProjects.take(3).toList();
          }
          _isInsightsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isInsightsLoading = false);
    }
  }

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
          body: RefreshIndicator(
            onRefresh: _fetchInsights,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 500.0,
                  floating: false,
                  pinned: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      state.translate('dholera_platform'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 16,
                      ),
                    ),
                    background: _HeroSlider(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTrustBanner(context, state),
                        const SizedBox(height: 20),
                        _buildLatestNewsBanner(context),
                        const SizedBox(height: 32),
                        _buildSectionTitle(
                          context,
                          state.translate('benefits_title'),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          Icons.map,
                          state.translate('verified_maps'),
                          state.translate('strategic_loc_desc'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TpMapsPage(),
                            ),
                          ),
                        ),
                        _buildFeatureCard(
                          context,
                          Icons.trending_up,
                          state.translate('realtime_updates'),
                          state.translate('featured_insights_desc'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProjectsPage(),
                            ),
                          ),
                        ),
                        _buildFeatureCard(
                          context,
                          Icons.calculate,
                          state.translate('fee_calculator'),
                          state.translate('compliance_verification'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ClearanceEnginePage(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildSectionTitle(context, 'Investment Resources'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSmallCard(
                                context,
                                Icons.real_estate_agent,
                                'Plots for Sale',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PlotsForSalePage(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSmallCard(
                                context,
                                Icons.menu_book,
                                'Investment Guide',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const InvestmentGuidePage(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          Icons.account_balance_wallet,
                          'Government Schemes',
                          'Explore Gujarat Government and Central Government subsidies for Dholera.',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GovernmentSchemesPage(),
                            ),
                          ),
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
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AirportPage(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSmallCard(
                                context,
                                Icons.construction,
                                'Trunk Infra',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const InfrastructurePage(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSmallCard(
                                context,
                                Icons.location_city,
                                'Smart City Features',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SmartCityPage(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSmallCard(
                                context,
                                Icons.directions_car,
                                'Travel & Lifestyle',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TravelLifestylePage(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildSectionTitle(context, 'Official Directories'),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          Icons.account_balance,
                          'Government Portals',
                          'Direct access to DSIRDA, RERA, and Land Records.',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PortalsPage(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle(
                              context,
                              state.translate('featured_insights'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UpdatesPage(),
                                ),
                              ),
                              child: const Text('SEE ALL'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isInsightsLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_latestInsights.isEmpty)
                          const Text('No recent updates available.')
                        else
                          ..._latestInsights.map(
                            (u) => _buildInsightCard(context, u),
                          ),
                        const SizedBox(height: 40),
                        Center(
                          child: Wrap(
                            spacing: 16,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PrivacyPolicyPage(),
                                  ),
                                ),
                                child: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TermsPage(),
                                  ),
                                ),
                                child: const Text(
                                  'Terms of Service',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        _buildSectionTitle(context, 'Featured Developments'),
                        const SizedBox(height: 16),
                        if (_isInsightsLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_featuredProjects.isEmpty)
                          const Text('No projects available.')
                        else
                          _buildFeaturedProjects(context, state),

                        const SizedBox(height: 40),
                        _buildSiteVisitForm(context, state),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String desc, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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

  Widget _buildSmallCard(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
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
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, AppUpdate update) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UpdateDetailPage(update: update, isAdmin: false),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (update.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  update.imageUrl!.startsWith('http')
                      ? update.imageUrl!
                      : 'https://api.dholeraplatform.com${update.imageUrl}',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/ui_infrastructure.png',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          update.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd').format(update.createdAt),
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    update.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    update.content.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBanner(BuildContext context, LocalizationState state) {
    final logos = [
      'assets/images/tata.png',
      'assets/images/larsen-toubro.png',
      'assets/images/torrent.png',
      'assets/images/renew.png',
      'assets/images/vedanta.png',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.translate('institutional_anchors_title').toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(height: 60, child: _AutoScrollingLogos(logos: logos)),
      ],
    );
  }

  Widget _buildLatestNewsBanner(BuildContext context) {
    final update = _latestInsights.isNotEmpty ? _latestInsights.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10172A), Color(0xFF1F2937)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'LATEST NEWS',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              if (update?.isExclusive == true) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'APP ONLY',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Icon(
                Icons.notifications_active_outlined,
                color: Colors.orange.shade200,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            update?.title ?? 'No admin news posted yet',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            update == null
                ? 'When the admin publishes a blog or update, it will appear here first and then on the Updates screen.'
                : update.content
                    .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ')
                    .trim(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (update != null)
                Text(
                  DateFormat('dd MMM yyyy').format(update.createdAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                Text(
                  'Admin to user news feed',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpdatesPage()),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orangeAccent,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'OPEN UPDATES',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProjects(BuildContext context, LocalizationState state) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredProjects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final project = _featuredProjects[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailPage(project: project),
              ),
            ),
            child: Container(
              width: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      (project.image ?? '').startsWith('http')
                          ? (project.image ?? '')
                          : 'https://api.dholeraplatform.com${project.image ?? ''}',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/ui_blueprint.png',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            project.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                project.location ?? 'Dholera SIR',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSiteVisitForm(BuildContext context, LocalizationState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: _isSubmitSuccess
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.greenAccent,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.translate('request_received'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We will contact you shortly.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => setState(() {
                      _isSubmitSuccess = false;
                      _name = '';
                      _phone = '';
                      _visitDate = null;
                    }),
                    child: const Text(
                      'BOOK ANOTHER',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      state.translate('exclusive_offer'),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.translate('talk_to_owner_title').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Fields
                  TextFormField(
                    initialValue: _name,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: state.translate('full_name'),
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => _name = val ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _phone,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: state.translate('mobile_number'),
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      counterText: '',
                    ),
                    validator: (val) => val == null || val.length != 10
                        ? 'Enter 10 digit number'
                        : null,
                    onSaved: (val) => _phone = val ?? '',
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 7)),
                      );
                      if (date != null) setState(() => _visitDate = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _visitDate == null
                                ? state.translate('deployment_date')
                                : DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_visitDate!),
                            style: TextStyle(
                              color: _visitDate == null
                                  ? Colors.grey
                                  : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_visitDate == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      child: Text(
                        state.translate('date_limit_msg'),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate() &&
                                  _visitDate != null) {
                                final messenger = ScaffoldMessenger.of(context);
                                _formKey.currentState!.save();
                                setState(() => _isSubmitting = true);
                                try {
                                  await _apiService.createLead({
                                    'name': _name,
                                    'phone': _phone,
                                    'date': _visitDate!.toIso8601String(),
                                    'source': 'App Site Visit Request',
                                    'notes':
                                        'Requested site visit for: ${_visitDate!.toIso8601String()}',
                                  });
                                  await _apiService.trackActivity(
                                    'Lead Submitted',
                                  );
                                  if (mounted) {
                                    setState(() => _isSubmitSuccess = true);
                                  }
                                } catch (e) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Saved locally, but failed to sync to server',
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isSubmitting = false);
                                  }

                                  // Always try to open WhatsApp as a fallback/notification
                                  final msg =
                                      "Hello Naresh, I have submitted a Site Visit Request.\n*Name:* $_name\n*Phone:* $_phone\n*Date:* ${DateFormat('MMM dd, yyyy').format(_visitDate!)}";
                                  final uri = Uri.parse(
                                    "https://wa.me/917435808031?text=${Uri.encodeComponent(msg)}",
                                  );
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                }
                              } else if (_visitDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select a preferred date',
                                    ),
                                  ),
                                );
                              }
                            },
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              state.translate('establish_conn').toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _AutoScrollingLogos extends StatefulWidget {
  final List<String> logos;
  const _AutoScrollingLogos({required this.logos});

  @override
  State<_AutoScrollingLogos> createState() => _AutoScrollingLogosState();
}

class _AutoScrollingLogosState extends State<_AutoScrollingLogos> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    if (_isScrolling || !mounted) return;
    _isScrolling = true;
    _scrollLoop();
  }

  void _scrollLoop() async {
    while (_isScrolling && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!_scrollController.hasClients) continue;

      final double maxScroll = _scrollController.position.maxScrollExtent;
      final double currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll - 50) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(currentScroll + 1.0);
      }
    }
  }

  @override
  void dispose() {
    _isScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 32),
          child: Opacity(
            opacity: 0.7,
            child: Image.asset(
              widget.logos[index % widget.logos.length],
              height: 40,
              width: 80,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

class _HeroSlider extends StatefulWidget {
  @override
  State<_HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<_HeroSlider>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;
  final List<String> _images = [
    'assets/images/dholera_landscape_wide.png',
    'assets/images/futuristic_dholera.png',
    'assets/images/airportFeatureimage.webp',
    'assets/images/airportVision.webp',
    'assets/images/expressHighway.webp',
    'assets/images/bliss_grandeur.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      final int nextPage = (_currentPage + 1) % _images.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.05 + (_animationController.value * 0.05),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.black87),
                  );
                },
              ),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.6),
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.4),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  'DHOLERA PLATFORM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dholera Platform is a comprehensive application designed for exploring and tracking real estate investments, smart city developments, and infrastructure progress in Dholera SIR.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(
                          "https://wa.me/917435808031?text=Hello%20Owner",
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.chat),
                      label: const Text(
                        'Talk to Owner',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProjectsPage()),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.business),
                      label: const Text(
                        'View Projects',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
