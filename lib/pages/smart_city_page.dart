import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'infrastructure_page.dart';

class SmartCityPage extends StatefulWidget {
  const SmartCityPage({super.key});

  @override
  State<SmartCityPage> createState() => _SmartCityPageState();
}

class _SmartCityPageState extends State<SmartCityPage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Smart City Features');
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
                'SMART CITY',
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
                    'assets/images/futuristic_dholera.png',
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A00).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'IGBC PLATINUM GREENFIELD URBAN ECOSYSTEM',
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
                    'Smart City Infrastructure & IoT',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore the subterranean utility conduits, automated command centers, renewable microgrids, and IoT urban sensors driving Dholera SIR.',
                    style: TextStyle(
                      color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildPillarCard(
                    context,
                    tag: 'COMMAND & CONTROL',
                    title: 'ABCD Administrative Center',
                    desc: 'The LEED Gold-certified ABCD Command Building operates as the neurological brain of Dholera. City-wide SCADA sensors, automated traffic management, smart streetlights, CCTV surveillance, and water network telemetry feed into a centralized 24x7 control room.',
                    icon: Icons.business,
                    imagePath: 'assets/images/dholera-activation-area-abcd-building-2026.jpg',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  _buildPillarCard(
                    context,
                    tag: 'ENGINEERING MARVEL',
                    title: 'Subterranean Utility Duct Network',
                    desc: 'All utilities — potable water, recycled water, electrical power, PNG cooking gas, telecommunications fiber, and storm drainage — are pre-laid beneath sidewalks in walk-through concrete ducts. No road will ever be dug up for utility repairs.',
                    icon: Icons.alt_route,
                    imagePath: 'assets/images/dholera-activation-area-utility-plots-2026.jpg',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  _buildPillarCard(
                    context,
                    tag: 'CLEAN ENERGY HUB',
                    title: '4,400 MW Ultra Mega Solar Park',
                    desc: 'Spread across coastal marshland in the southern corridor, the 4,400 MW solar park connects to 400kV gas-insulated substations to ensure 100% green energy availability for semiconductor fabs and data centers.',
                    icon: Icons.wb_sunny_outlined,
                    imagePath: 'assets/images/dholera-solar-park-grid-substation-2026.jpg',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  _buildPillarCard(
                    context,
                    tag: 'WATER SECURITY',
                    title: '100 MLD Desalination & 100% ZLD',
                    desc: 'Dholera features an ocean-fed Seawater Reverse Osmosis (SWRO) desalination plant providing 100 MLD drinking water, paired with a Zero Liquid Discharge (ZLD) effluent treatment plant that recycles 100% of municipal and industrial wastewater.',
                    icon: Icons.water_drop_outlined,
                    imagePath: 'assets/images/dholera-smart-city-residential-tp-2026.jpg',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  _buildPillarCard(
                    context,
                    tag: 'ECOLOGY & RECREATION',
                    title: '15km Central Canal & Riverfront',
                    desc: 'A central balancing canal runs through TP1 with artificial lakes, check dams, and waterfront promenades. It functions both as flood prevention balancing reservoirs and as a prime civic and lifestyle destination.',
                    icon: Icons.park_outlined,
                    imagePath: 'assets/images/dholera_lifestyle_square.png',
                    isDark: isDark,
                  ),

                  const SizedBox(height: 32),

                  // Trunk Infra Link
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.construction_rounded, color: Color(0xFFFF7A00), size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Deep-Dive into Trunk Infrastructure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('Explore Tata Semiconductor Fab, Freight Corridors, and Expressways.', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InfrastructurePage())),
                          icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFFF7A00)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Consultation CTA
                  _buildBottomCTA(context, isDark),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarCard(
    BuildContext context, {
    required String tag,
    required String title,
    required String desc,
    required IconData icon,
    required String imagePath,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF3A506B) : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.asset(
              imagePath,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset('assets/images/ui_infrastructure.png', height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7A00).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Color(0xFFFF7A00),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(icon, color: const Color(0xFFFF7A00), size: 22),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: TextStyle(
                    color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(BuildContext context, bool isDark) {
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
          const Text(
            'Experience Dholera Smart Infrastructure Firsthand',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Book an exclusive guided tour of the ABCD Building, subterranean ducts, and activation plots with our senior technical advisors.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final text = Uri.encodeComponent('Hi Naresh, I would like to book a site visit to inspect Dholera Smart City infrastructure.');
                _launchURL('https://wa.me/918200448270?text=$text');
              },
              icon: const Icon(Icons.location_city, size: 16),
              label: const Text('SCHEDULE INFRASTRUCTURE SITE TOUR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
              ),
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
