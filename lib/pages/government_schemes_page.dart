import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'vault_page.dart';

class GovernmentSchemesPage extends StatefulWidget {
  const GovernmentSchemesPage({super.key});

  @override
  State<GovernmentSchemesPage> createState() => _GovernmentSchemesPageState();
}

class _GovernmentSchemesPageState extends State<GovernmentSchemesPage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Government Schemes');
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
                'GOVT SCHEMES',
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'GUJARAT INDUSTRIAL & CENTRAL FISCAL INCENTIVES',
                      style: TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Government Policies & Subsidies',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A comprehensive directory of state and central capital subsidies, stamp duty refunds, power concessions, and plug-and-play incentives for Dholera SIR.',
                    style: TextStyle(
                      color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Policy 1: Semiconductor
                  _buildPolicyCard(
                    context,
                    tag: 'FLAGSHIP SECTOR',
                    tagColor: Colors.purple,
                    title: 'Gujarat Semiconductor Policy (2022–2027)',
                    summary: 'World-leading fiscal package empowering semiconductor fabrication, OSAT, and ATMP packaging units in Dholera Semicon City.',
                    points: [
                      '75% Land Subsidy for first 200 acres acquired in Dholera SIR',
                      '₹2 per unit electricity tariff subsidy for 10 operational years',
                      '100% Stamp Duty & Registration Fee reimbursement',
                      'Additional 20% state capital assistance on top of 50% Central ISM support',
                      'Dedicated ultra-pure water tariff at ₹12/cubic meter for 5 years',
                    ],
                    icon: Icons.memory,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // Policy 2: IT / ITeS
                  _buildPolicyCard(
                    context,
                    tag: 'HIGH-TECH & DATA CENTERS',
                    tagColor: Colors.blue,
                    title: 'Gujarat IT / ITeS Policy (2022–2027)',
                    summary: 'Tailored for cloud hyperscalers, artificial intelligence campuses, and electronic system design units establishing in TP1 Central Business District.',
                    points: [
                      'CAPEX Support up to 33% (maximum ₹200 Crores)',
                      'OPEX Support up to 15% (maximum ₹40 Crores per year)',
                      'Employment Generation Subsidy: Up to ₹50,000 per local graduate engineer',
                      'Electricity Duty 100% waiver for 5 operational years',
                      'Subsea cable landing station and high-density fiber redundancy',
                    ],
                    icon: Icons.cloud_done_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // Policy 3: Clean Energy & Solar
                  _buildPolicyCard(
                    context,
                    tag: 'ESG & CLEAN TECH',
                    tagColor: Colors.green,
                    title: 'Dholera Green Energy & Solar Park Incentives',
                    summary: 'Direct grid synchronization from the 4,400 MW Dholera Solar Park offering 100% renewable power quotas.',
                    points: [
                      'Zero Transmission Charges for clean power wheeling inside DSIR boundary',
                      'Net-metering exemptions for industrial rooftop arrays',
                      'Subsidized green hydrogen electrolyzer installation grant',
                      'Zero Liquid Discharge (ZLD) effluent treatment pre-connected',
                    ],
                    icon: Icons.solar_power_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // Policy 4: MSME & Ancillary Clusters
                  _buildPolicyCard(
                    context,
                    tag: 'MANUFACTURING ANCILLARY',
                    tagColor: Colors.orange,
                    title: 'Gujarat MSME Atmanirbhar Policy',
                    summary: 'Dedicated financial incentives for small and medium tier-2/tier-3 suppliers serving anchor industries.',
                    points: [
                      'Interest Subsidy: Up to 7% on term loans for 7 years',
                      'Quality Certification Assistance: 100% reimbursement up to ₹10 Lakhs',
                      'Patent Filing Support: 75% reimbursement for global patent registration',
                      'Assisted allotment in plug-and-play micro industrial sheds',
                    ],
                    icon: Icons.precision_manufacturing_outlined,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 32),

                  // Official Gazette Vault Link Card
                  _buildVaultLinkCard(context, isDark),

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

  Widget _buildPolicyCard(
    BuildContext context, {
    required String tag,
    required Color tagColor,
    required String title,
    required String summary,
    required List<String> points,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Icon(icon, color: tagColor, size: 24),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: TextStyle(
              color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFFFF7A00), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultLinkCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.picture_as_pdf, color: Color(0xFF2563EB), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Official Policy Gazette Vault',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Download government resolution PDFs, notifications, and application forms.',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VaultPage()),
            ),
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF2563EB)),
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
            'Need Custom Subsidy Eligibility Assessment?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our corporate desk calculates exact capital subsidies, power concessions, and stamp duty exemptions for your Dholera land project.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final text = Uri.encodeComponent('Hi Naresh, I would like an assessment of Gujarat Government subsidies for my business in Dholera SIR.');
                _launchURL('https://wa.me/918200448270?text=$text');
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('CHECK SUBSIDY ELIGIBILITY'),
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
