import '../theme/board_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_event.dart';
import '../blocs/localization/localization_state.dart';
import '../blocs/theme/theme_bloc.dart';
import '../blocs/theme/theme_event.dart';
import '../blocs/theme/theme_state.dart';
import '../services/app_update_service.dart';
import 'admin/admin_bottom_nav_bar.dart';
import 'login_page.dart';
import 'plots_for_sale_page.dart';
import 'investment_guide_page.dart';
import 'government_schemes_page.dart';
import 'smart_city_page.dart';
import 'travel_lifestyle_page.dart';
import 'portals_page.dart';
import 'about_page.dart';
import 'contact_page.dart';

class InvestorProfilePage extends StatefulWidget {
  const InvestorProfilePage({super.key});

  @override
  State<InvestorProfilePage> createState() => _InvestorProfilePageState();
}

class _InvestorProfilePageState extends State<InvestorProfilePage> {
  String _currentVersion = '1.0.4+7';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() {
          _currentVersion = '${info.version}+${info.buildNumber}';
        });
      }
    }).catchError((_) {});
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final loc = context.read<LocalizationBloc>();
        final currentCode = loc.state.locale.languageCode;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'SELECT LANGUAGE / ભાષા પસંદ કરો',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1,
                      color: isDark ? Colors.amber.shade300 : const Color(0xFFD97706),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildLangTile('English', 'English', 'en', currentCode, loc),
                _buildLangTile('ગુજરાતી', 'Gujarati', 'gu', currentCode, loc),
                _buildLangTile('हिन्दी', 'Hindi', 'hi', currentCode, loc),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLangTile(String nativeName, String engName, String code, String currentCode, LocalizationBloc loc) {
    final isSelected = currentCode == code;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
        color: isSelected ? const Color(0xFFFF7A00) : Colors.grey,
      ),
      title: Text(nativeName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(engName, style: const TextStyle(fontSize: 12)),
      onTap: () {
        loc.add(LocalizationChanged(Locale(code)));
        Navigator.pop(context);
      },
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to sign out from your Dholera Platform session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(AuthLogoutRequested());
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;
    final userName = authState.userName ?? 'Investor';
    final userEmail = authState.userEmail ?? '';
    final isAdmin = authState.role == AppRole.adminOwner;

    final initials = userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join()
        .toUpperCase();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'INVESTOR DESK & PROFILE',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 15,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        children: [
          // 1. User Info Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isAdmin ? Colors.amber.shade700 : const Color(0xFFFF7A00),
                  child: Text(
                    initials.isEmpty ? 'U' : initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (userEmail.isNotEmpty)
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? Colors.amber.withValues(alpha: 0.15)
                              : const Color(0xFFFF7A00).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isAdmin ? '🛡️ PLATFORM ADMINISTRATOR' : 'VERIFIED INVESTOR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: isAdmin ? (isDark ? Colors.amber.shade300 : const Color(0xFFB45309)) : const Color(0xFFFF7A00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. 1-Tap Admin Switcher Banner (ONLY shown if user is admin)
          if (isAdmin) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.amber.shade400, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.amber, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADMIN CONSOLE',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Access leads, Gemini AI blogs, map uploader & releases.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminBottomNavBar()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('OPEN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 3. Direct Senior Advisory Desk (Naresh Gohel)
          _buildSectionHeader('DIRECT INVESTOR DESK', isDark),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.support_agent_rounded, color: Colors.green, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Naresh Gohel',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            'Senior Dholera SIR Consultant & Land Desk',
                            style: TextStyle(color: Colors.grey, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl('https://wa.me/918200448270?text=Hello%20Naresh%20bhai%2C%20I%20need%20expert%20consultation%20regarding%20Dholera%20SIR%20plots%20and%20TP%20schemes.'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _launchUrl('tel:+918200448270'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        ),
                        icon: const Icon(Icons.phone_outlined, size: 16),
                        label: const Text('Call Desk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage()));
                    },
                    icon: const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFFFF7A00)),
                    label: const Text(
                      'Request Free On-Site Visit & Land Records Verification',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. SIR Knowledge Base & Directories (Clean Secondary Nav)
          _buildSectionHeader('SIR DIRECTORIES & REFERENCE GUIDES', isDark),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildDirectoryTile(
                  icon: Icons.landscape_outlined,
                  title: 'Verified Plots & Land Catalog',
                  subtitle: 'RERA residential, commercial & industrial plots',
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlotsForSalePage())),
                ),
                _buildDivider(isDark),
                _buildDirectoryTile(
                  icon: Icons.trending_up_rounded,
                  title: '5-Step Investment Roadmap',
                  subtitle: 'TP Schemes, GDCR zoning & title clearance guide',
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestmentGuidePage())),
                ),
                _buildDivider(isDark),
                _buildDirectoryTile(
                  icon: Icons.account_balance_outlined,
                  title: 'Gujarat Semiconductor & IT Policies',
                  subtitle: '75% power/water subsidies & state incentives',
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GovernmentSchemesPage())),
                ),
                _buildDivider(isDark),
                _buildDirectoryTile(
                  icon: Icons.smart_toy_outlined,
                  title: 'Smart City Infrastructure (SCADA)',
                  subtitle: 'Subterranean utility ducts & 4400MW solar park',
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartCityPage())),
                ),
                _buildDivider(isDark),
                _buildDirectoryTile(
                  icon: Icons.flight_takeoff_outlined,
                  title: 'Expressway & International Airport',
                  subtitle: 'NH-751 45-min commute & Navagam airport transit',
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TravelLifestylePage())),
                ),
                _buildDivider(isDark),
                _buildDirectoryTile(
                  icon: Icons.public_outlined,
                  title: 'Official Govt Verification Portals',
                  subtitle: 'AnyRoR 7/12, Gujarat RERA, and GIDC links',
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PortalsPage())),
                ),
                _buildDivider(isDark),
                _buildDirectoryTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About Dholera Platform',
                  subtitle: 'Our mission, data accuracy & founder credentials',
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 5. Preferences & Settings
          _buildSectionHeader('APP PREFERENCES', isDark),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: Color(0xFFFF7A00)),
                  title: const Text('Language / ભાષા / भाषा', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder<LocalizationBloc, LocalizationState>(
                        builder: (context, loc) {
                          final code = loc.locale.languageCode;
                          final name = code == 'gu' ? 'ગુજરાતી' : (code == 'hi' ? 'हिन्दी' : 'English');
                          return Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF7A00)));
                        },
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                    ],
                  ),
                  onTap: () => _showLanguageSelector(context),
                ),
                _buildDivider(isDark),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    final isDarkMode = themeState.boardTheme == AppBoardTheme.blueBoard;
                    return SwitchListTile(
                      secondary: Icon(
                        isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                        color: const Color(0xFFFF7A00),
                      ),
                      title: const Text('Dark Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      value: isDarkMode,
                      activeThumbColor: const Color(0xFFFF7A00),
                      onChanged: (val) {
                        context.read<ThemeBloc>().add(
                          ThemeChanged(val ? AppBoardTheme.blueBoard : AppBoardTheme.standard),
                        );
                      },
                    );
                  },
                ),
                _buildDivider(isDark),
                ListTile(
                  leading: const Icon(Icons.system_update_rounded, color: Color(0xFFFF7A00)),
                  title: const Text('App Updates', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('Installed Build: v$_currentVersion', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                  onTap: () {
                    AppUpdateService().checkForUpdates(context, silent: false, forcePrompt: true);
                  },
                ),
                _buildDivider(isDark),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.redAccent)),
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Dholera SIR Growth Platform • v$_currentVersion',
              style: TextStyle(fontSize: 11.5, color: isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildDirectoryTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: isDark ? Colors.amber.shade300 : const Color(0xFFD97706)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 54,
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
    );
  }
}
