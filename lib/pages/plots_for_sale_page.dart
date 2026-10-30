import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import 'project_detail_page.dart';
import 'contact_page.dart';

class PlotsForSalePage extends StatefulWidget {
  const PlotsForSalePage({super.key});

  @override
  State<PlotsForSalePage> createState() => _PlotsForSalePageState();
}

class _PlotsForSalePageState extends State<PlotsForSalePage> {
  final ApiService _apiService = ApiService();
  List<Project> _allPlots = [];
  List<Project> _filteredPlots = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Residential', 'Commercial', 'Industrial'];

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Plots for Sale');
    _loadPlots();
  }

  Future<void> _loadPlots() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getProjects();
      if (mounted && res['success'] == true && res['projects'] is List) {
        final list = (res['projects'] as List)
            .map((json) => Project.fromJson(json))
            .toList();
        setState(() {
          _allPlots = list;
          _filteredPlots = list;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _filter(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredPlots = _allPlots;
      } else {
        _filteredPlots = _allPlots.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                'VERIFIED PLOTS',
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
                    'assets/images/dream-world-city.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0B132B)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.75),
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

          // Header Intro
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A00).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'RERA APPROVED & DSIRDA COMPLIANT',
                      style: TextStyle(
                        color: Color(0xFFFF7A00),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dholera SIR Plots for Sale',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Direct title-clear land parcels, gated developments, and industrial plots in Town Planning Scheme 1 & 2 activation corridors.',
                    style: TextStyle(
                      color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFFFF7A00),
                            backgroundColor: isDark ? const Color(0xFF1C2541) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFFFF7A00)
                                    : (isDark ? const Color(0xFF3A506B) : Colors.grey[300]!),
                              ),
                            ),
                            onSelected: (_) => _filter(cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Plot Cards List
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF7A00)),
              ),
            )
          else if (_filteredPlots.isEmpty)
            SliverToBoxAdapter(
              child: _buildCuratedPlotFallbackList(context, isDark),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final project = _filteredPlots[index];
                    return _buildPlotCard(context, project, isDark);
                  },
                  childCount: _filteredPlots.length,
                ),
              ),
            ),

          // Bottom Consultation Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildConsultationBanner(context, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlotCard(BuildContext context, Project project, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF3A506B) : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  project.image != null && project.image!.startsWith('http')
                      ? project.image!
                      : 'https://api.dholeraplatform.com${project.image}',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/ui_blueprint.png',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    project.category.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              if (project.reraApproved)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'RERA',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFFFF7A00)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        project.location?.split(',')[0] ?? 'Dholera SIR Activation Area',
                        style: const TextStyle(
                          color: Color(0xFFFF7A00),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  project.name,
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),

                // Plot Specs Grid
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PLOT SIZES', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(project.plotSizes ?? '150 - 500 Sq. Yd.', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 28, color: isDark ? Colors.white12 : Colors.grey[300]!),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ROAD WIDTH', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(project.roadWidth ?? '18m / 24m TP Road', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Actions Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final text = Uri.encodeComponent('Hi, I am interested in plot rates and availability for ${project.name} in Dholera SIR.');
                          _launchURL('https://wa.me/918200448270?text=$text');
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('WHATSAPP RATES'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProjectDetailPage(project: project)),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('SPECS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuratedPlotFallbackList(BuildContext context, bool isDark) {
    final curated = [
      {
        'name': 'Dholera Central TP1 Smart Plots',
        'category': 'Residential',
        'location': 'TP 1, Activation Sector B',
        'sizes': '150 to 450 Sq. Yd.',
        'road': '18m Sub-Arterial Road',
        'image': 'assets/images/dholera-activation-area-utility-plots-2026.jpg',
      },
      {
        'name': 'Airport Aviation Corridor Plots',
        'category': 'Commercial',
        'location': 'Navagam, Airport Expressway Link',
        'sizes': '500 to 2,000 Sq. Yd.',
        'road': '55m TP Highway',
        'image': 'assets/images/dholera-airport-aviation-corridor-plots-2026.jpg',
      },
      {
        'name': 'High-Tech Zone 2 Industrial Parcels',
        'category': 'Industrial',
        'location': 'TP 2, Semiconductor Ancillary Hub',
        'sizes': '1 to 5 Acres',
        'road': '70m Heavy Transit Spine',
        'image': 'assets/images/dholera-semiconductor-ancillary-campus-2026.jpg',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: curated.map((plot) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C2541) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? const Color(0xFF3A506B) : Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.asset(
                    plot['image']!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset('assets/images/ui_blueprint.png', height: 180, fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plot['location']!, style: const TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold, fontSize: 11)),
                      const SizedBox(height: 6),
                      Text(plot['name']!, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: Text('Sizes: ${plot['sizes']}', style: const TextStyle(fontSize: 11, color: Colors.grey))),
                          Expanded(child: Text('Road: ${plot['road']}', style: const TextStyle(fontSize: 11, color: Colors.grey))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final text = Uri.encodeComponent('Hi, I am interested in plot rates for ${plot['name']} in Dholera SIR.');
                            _launchURL('https://wa.me/918200448270?text=$text');
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 16),
                          label: const Text('INQUIRE PLOT AVAILABILITY'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7A00),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConsultationBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B132B), Color(0xFF1C2541)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent, color: Color(0xFFFF7A00), size: 36),
          const SizedBox(height: 12),
          const Text(
            'Need Custom Land Plot Sizing in TP1 to TP6?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our accredited Dholera specialists provide site-visit coordination, registry due-diligence, and official rate comparison.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('BOOK FREE DHOLERA SITE VISIT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
