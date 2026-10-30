import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'airport_page.dart';

class TravelLifestylePage extends StatefulWidget {
  const TravelLifestylePage({super.key});

  @override
  State<TravelLifestylePage> createState() => _TravelLifestylePageState();
}

class _TravelLifestylePageState extends State<TravelLifestylePage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Travel & Lifestyle');
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
                'TRAVEL & LIFESTYLE',
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
                    'assets/images/dholera_lifestyle_square.png',
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
                      'CONNECTIVITY, CULTURE & LIVING AMENITIES',
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
                    'Living & Commuting in Dholera',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'From 45-minute expressway transit to the historic maritime dockyards of Lothal, experience world-class living standards in Gujarat’s flagship global city.',
                    style: TextStyle(
                      color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildHighlightCard(
                    context,
                    tag: 'SUPER HIGHWAY',
                    title: 'Ahmedabad-Dholera Expressway (NH-751)',
                    timeEstimate: '45 Mins Commute',
                    desc: 'The 109-kilometer, 4-lane access-controlled expressway (expandable to 8 lanes) connects Sarkhej in Ahmedabad directly to Dholera SIR Activation Zone with uninterrupted speeds up to 120 km/h.',
                    icon: Icons.add_road,
                    imagePath: 'assets/images/dholera-expressway-connectivity-2026.jpg',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  _buildHighlightCard(
                    context,
                    tag: 'RAPID TRANSIT',
                    title: 'Semi-High Speed Metro Rail Corridor',
                    timeEstimate: 'Direct CBD Access',
                    desc: 'Running directly along the expressway median, the elevated metro line connects Gandhinagar, GIFT City, Ahmedabad Airport, and Dholera with planned high-speed electric trainsets.',
                    icon: Icons.tram_outlined,
                    imagePath: 'assets/images/dholera-metro-transit-corridor-2026.jpg',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  _buildHighlightCard(
                    context,
                    tag: 'GLOBAL AIR GATEWAY',
                    title: 'Dholera International Airport (Navagam)',
                    timeEstimate: '15 Mins from City Center',
                    desc: 'Spanning 1,426 hectares, this 4E Category international hub features dual runways capable of handling A380 passenger liners and Boeing 777 freighter aircraft for seamless cargo transit.',
                    icon: Icons.flight_takeoff,
                    imagePath: 'assets/images/dholera-international-airport-runway-2026.jpg',
                    onTapExtra: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AirportPage())),
                    extraText: 'VIEW RUNWAY STATUS',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  _buildHighlightCard(
                    context,
                    tag: 'HERITAGE & TOURISM',
                    title: 'Lothal National Maritime Heritage Complex',
                    timeEstimate: '20 Mins from TP1',
                    desc: 'Adjacent to Dholera SIR, the Ministry of Ports is constructing the ₹4,500 Crore National Maritime Heritage Complex celebrating the 4,500-year-old Indus Valley civilization dockyard.',
                    icon: Icons.museum_outlined,
                    imagePath: 'assets/images/arialviewdholeraexpress.webp',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  _buildHighlightCard(
                    context,
                    tag: 'WILDLIFE ECO-SANCTUARY',
                    title: 'Velavadar Blackbuck National Park',
                    timeEstimate: '35 Mins Leisure Drive',
                    desc: 'A pristine savannah ecosystem home to thousands of endangered Indian Blackbucks, striped hyenas, and migratory raptors, offering luxury weekend retreats for expatriates and executives.',
                    icon: Icons.pets_outlined,
                    imagePath: 'assets/images/fghj-300x200.jpeg',
                    isDark: isDark,
                  ),

                  const SizedBox(height: 32),

                  // Commute Time Table
                  _buildCommuteMatrix(context, isDark),

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

  Widget _buildHighlightCard(
    BuildContext context, {
    required String tag,
    required String title,
    required String timeEstimate,
    required String desc,
    required IconData icon,
    required String imagePath,
    VoidCallback? onTapExtra,
    String? extraText,
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
              errorBuilder: (_, __, ___) => Image.asset('assets/images/ui_lifestyle.png', height: 180, width: double.infinity, fit: BoxFit.cover),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        timeEstimate,
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                if (onTapExtra != null && extraText != null) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: onTapExtra,
                    icon: const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFFF7A00)),
                    label: Text(
                      extraText,
                      style: const TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommuteMatrix(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF1F2937) : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car, color: Color(0xFFFF7A00), size: 22),
              const SizedBox(width: 8),
              Text(
                'Transit & Commute Matrix',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMatrixRow('Ahmedabad Ring Road (SP Ring)', '109 km', '45 - 50 Mins', isDark),
          const Divider(height: 16),
          _buildMatrixRow('Bhavnagar Maritime Port', '68 km', '40 Mins', isDark),
          const Divider(height: 16),
          _buildMatrixRow('Vadodara Industrial Corridor', '135 km', '75 Mins', isDark),
          const Divider(height: 16),
          _buildMatrixRow('GIFT City Gandhinagar', '130 km', '65 Mins via Metro', isDark),
        ],
      ),
    );
  }

  Widget _buildMatrixRow(String destination, String distance, String duration, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            destination,
            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[300] : Colors.grey[700], fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          distance,
          style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[500]),
        ),
        const SizedBox(width: 12),
        Text(
          duration,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFFF7A00)),
        ),
      ],
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
            'Plan Your Visit to Dholera SIR',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'We arrange chauffeured expressway visits from Ahmedabad, complete with corridor maps, drone briefings, and certified on-ground consultants.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final text = Uri.encodeComponent('Hi Naresh, I would like to book a site visit pickup from Ahmedabad to tour Dholera SIR.');
                _launchURL('https://wa.me/918200448270?text=$text');
              },
              icon: const Icon(Icons.car_rental, size: 16),
              label: const Text('BOOK CHAUFFEURED SITE VISIT'),
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
