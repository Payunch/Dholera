import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'contact_page.dart';
import 'vault_page.dart';
import 'tp_maps_page.dart';

class InvestmentGuidePage extends StatefulWidget {
  const InvestmentGuidePage({super.key});

  @override
  State<InvestmentGuidePage> createState() => _InvestmentGuidePageState();
}

class _InvestmentGuidePageState extends State<InvestmentGuidePage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Investment Guide');
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
                'INVESTMENT GUIDE',
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
                    'assets/images/strategic-location.png',
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
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A00).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'OFFICIAL DHOLERA SIR DUE DILIGENCE BLUEPRINT',
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
                    'How to Invest in Dholera Smart City',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A step-by-step master roadmap covering Town Planning schemes, zoning regulations, legal documentation, and capital appreciation drivers.',
                    style: TextStyle(
                      color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 5 Steps
                  _buildStepCard(
                    context,
                    stepNumber: '01',
                    title: 'TP Scheme Selection (Activation vs Horizon)',
                    desc: 'Focus your capital based on your timeline. Town Planning 1 & 2 represent the 22.5 sq km Activation Area with completed trunk roads, subterranean utility ducts, water, power, and SCADA sensors. TP3 to TP6 offer larger land banks for 7-10 year horizons.',
                    icon: Icons.map_outlined,
                    actionText: 'VIEW TP MAPS',
                    onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TpMapsPage())),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  _buildStepCard(
                    context,
                    stepNumber: '02',
                    title: 'Zoning & GDCR Verification',
                    desc: 'Verify the statutory zoning of your plot: Residential, Commercial, City Center, Industrial, or High-Access Corridor. Check FSI/FAR allowances, maximum height restrictions, and road setback parameters governed by DSIRDA GDCR regulations.',
                    icon: Icons.domain_verification,
                    actionText: 'OPEN OFFICIAL PORTALS',
                    onAction: () => _launchURL('https://dholeraplatform.com/portals'),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  _buildStepCard(
                    context,
                    stepNumber: '03',
                    title: 'Title Clearance & RERA Scrutiny',
                    desc: 'Never purchase agricultural land without Non-Agricultural (NA) conversion or without final title clearance certificate issued by an accredited advocate. For residential and commercial plots, ensure the project holds an active Gujarat RERA registration number.',
                    icon: Icons.gavel_rounded,
                    actionText: 'DOWNLOAD GAZETTES',
                    onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaultPage())),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  _buildStepCard(
                    context,
                    stepNumber: '04',
                    title: 'Incentives & Stamp Duty Optimization',
                    desc: 'Investors in semiconductor, electronics, and industrial sectors can leverage the Gujarat Industrial Policy: up to 100% stamp duty exemption, capital expenditure subsidies up to 25%, and power tariff reimbursements for early operationalization.',
                    icon: Icons.savings_outlined,
                    actionText: 'CONSULT ADVISOR',
                    onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage())),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  _buildStepCard(
                    context,
                    stepNumber: '05',
                    title: 'Infrastructure Anchors & Exit Strategy',
                    desc: 'Capital growth is tethered directly to five operational milestones: Ahmedabad-Dholera NH-751 Expressway, Dholera International Airport cargo flights, Tata Semiconductor Fab commercial wafer production, and Semi-High-Speed Metro connectivity.',
                    icon: Icons.trending_up_rounded,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 32),

                  // Valuation Benchmark Box
                  _buildValuationBox(context, isDark),

                  const SizedBox(height: 32),

                  // Call to Action
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

  Widget _buildStepCard(
    BuildContext context, {
    required String stepNumber,
    required String title,
    required String desc,
    required IconData icon,
    String? actionText,
    VoidCallback? onAction,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF3A506B) : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: TextStyle(
              color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
              fontSize: 12,
              height: 1.6,
            ),
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFFF7A00)),
                label: Text(
                  actionText,
                  style: const TextStyle(
                    color: Color(0xFFFF7A00),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValuationBox(BuildContext context, bool isDark) {
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
              const Icon(Icons.analytics_outlined, color: Color(0xFFFF7A00), size: 22),
              const SizedBox(width: 8),
              Text(
                'Dholera SIR Land Valuation Benchmarks',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildValuationRow('TP 1 Activation Zone (Residential)', '₹5,500 – ₹9,500 / sq. yd.', isDark),
          const Divider(height: 16),
          _buildValuationRow('TP 2 High-Access Spine (Commercial)', '₹12,000 – ₹22,000 / sq. yd.', isDark),
          const Divider(height: 16),
          _buildValuationRow('Airport Aviation Corridor (Logistics)', '₹4,500 – ₹8,000 / sq. yd.', isDark),
          const Divider(height: 16),
          _buildValuationRow('TP 3 & TP 4 Horizon Parcels', '₹2,800 – ₹4,200 / sq. yd.', isDark),
        ],
      ),
    );
  }

  Widget _buildValuationRow(String zone, String range, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            zone,
            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[300] : Colors.grey[700], fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          range,
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
            'Ready to Begin Your Due Diligence?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect directly with our senior investment analysts for Title verification, Site Visit scheduling, and Jantri rate analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final text = Uri.encodeComponent('Hi Naresh, I reviewed the Dholera Investment Guide and would like an investment consultation.');
                _launchURL('https://wa.me/918200448270?text=$text');
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('WHATSAPP INVESTMENT DESK'),
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
