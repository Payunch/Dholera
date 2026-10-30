import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
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
                    'ABOUT DHOLERA',
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
                        'assets/images/dholerasirGujrat.webp',
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTag('OUR MISSION'),
                      const SizedBox(height: 16),
                      Text(
                        'THE INTELLIGENCE HUB',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TRANSPARENCY. VERIFICATION. GROWTH.',
                        style: TextStyle(
                          color: const Color(0xFFFF7A00),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'We are the definitive, independent digital layer for Dholera Smart City real estate and industrial intelligence.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Established to bridge the gap between complex urban planning and investor clarity, our platform provides the most comprehensive repository of TP Maps, project specifications, and policy updates in the Dholera Special Investment Region.',
                        style: TextStyle(
                          color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildInfoGrid(isDark),
                      const SizedBox(height: 32),
                      _buildFounderCard(isDark),
                      const SizedBox(height: 32),
                      _buildCTA(context, isDark),
                      const SizedBox(height: 32),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7A00),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }

  Widget _buildInfoGrid(bool isDark) {
    final items = [
      {'title': 'Verified Data', 'desc': 'Maps and specs double-checked against official records.', 'icon': Icons.verified_user},
      {'title': 'Investor First', 'desc': 'Built to protect and empower the individual investor.', 'icon': Icons.ads_click},
      {'title': 'Expert Group', 'desc': 'Connecting developers, investors, and policymakers.', 'icon': Icons.groups},
      {'title': 'Track Record', 'desc': '5+ years monitoring DSIR infrastructure growth.', 'icon': Icons.history},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            return SizedBox(
              width: cardWidth,
              child: _buildInfoCard(item, isDark),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFounderCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF3A506B) : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/ng.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'NARESH GOHEL',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'FOUNDER & MANAGING DIRECTOR',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFFF7A00), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 14),
          Text(
            'Leading the digital transformation of Dholera Smart City real estate through verified geospatial intelligence, transparent land due diligence, and investor advocacy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF3A506B) : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item['icon'] as IconData, color: const Color(0xFFFF7A00), size: 24),
          const SizedBox(height: 12),
          Text(
            item['title'] as String,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item['desc'] as String,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
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
          const Text(
            'BUILDING THE FUTURE, ONE DECODED MAP AT A TIME.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900, height: 1.3),
          ),
          const SizedBox(height: 12),
          const Text(
            'Join the elite circle of data-driven investors.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 0.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage())),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
              ),
              child: const Text('CONTACT OUR EXPERTS'),
            ),
          ),
        ],
      ),
    );
  }
}
