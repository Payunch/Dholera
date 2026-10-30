import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portal.dart';
import '../services/api_service.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';

class PortalsPage extends StatefulWidget {
  const PortalsPage({super.key});

  @override
  State<PortalsPage> createState() => _PortalsPageState();
}

class _PortalsPageState extends State<PortalsPage> {
  final ApiService _apiService = ApiService();
  Map<String, List<Portal>> _groupedPortals = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPortals();
    _apiService.trackActivity('Portals Directory');
  }

  Future<void> _fetchPortals() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getPortals();
      if (mounted && response['success'] == true) {
        final List<Portal> allPortals = (response['portals'] as List)
            .map((json) => Portal.fromJson(json))
            .toList();

        final Map<String, List<Portal>> grouped = {};
        for (var p in allPortals) {
          if (!grouped.containsKey(p.category)) {
            grouped[p.category] = [];
          }
          grouped[p.category]!.add(p);
        }

        setState(() {
          _groupedPortals = grouped;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: isDark ? const Color(0xFF0B132B) : Colors.white,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'OFFICIAL PORTALS',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/about_banner.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0B132B)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF7A00)),
                  ),
                )
              else if (_groupedPortals.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No portals currently available.',
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      _groupedPortals.entries
                          .map((entry) => _buildCategorySection(entry.key, entry.value, isDark))
                          .toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(String category, List<Portal> portals, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A00),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              category.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        if (portals.isNotEmpty && portals.first.categorySubtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16, left: 12),
            child: Text(
              portals.first.categorySubtitle,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
            ),
          )
        else
          const SizedBox(height: 16),
        ...portals.map((p) => _buildPortalCard(p, isDark)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPortalCard(Portal portal, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF3A506B) : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _launchUrl(portal.url),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      portal.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A00).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.open_in_new, size: 14, color: Color(0xFFFF7A00)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                portal.desc,
                style: TextStyle(
                  color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.link, size: 12, color: Color(0xFFFF7A00)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      portal.url,
                      style: const TextStyle(
                        color: Color(0xFFFF7A00),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
