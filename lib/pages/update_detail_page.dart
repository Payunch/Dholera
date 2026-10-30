import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/app_update.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_html/flutter_html.dart';

class UpdateDetailPage extends StatefulWidget {
  final AppUpdate update;
  final bool isAdmin;

  const UpdateDetailPage({
    super.key,
    required this.update,
    this.isAdmin = false,
  });

  @override
  State<UpdateDetailPage> createState() => _UpdateDetailPageState();
}

class _UpdateDetailPageState extends State<UpdateDetailPage> {
  final ApiService _apiService = ApiService();
  late AppUpdate _currentUpdate;
  bool _isLoadingContent = false;

  @override
  void initState() {
    super.initState();
    _currentUpdate = widget.update;
    if (_currentUpdate.content.trim().isEmpty) {
      _loadFullUpdate();
    }
  }

  Future<void> _loadFullUpdate() async {
    setState(() => _isLoadingContent = true);
    try {
      final res = await _apiService.getUpdateById(_currentUpdate.id);
      if (mounted && res['success'] == true && res['update'] != null) {
        setState(() {
          _currentUpdate = AppUpdate.fromJson(res['update']);
          _isLoadingContent = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback: fetch from list
    try {
      final listRes = await _apiService.getUpdates(audience: 'app');
      if (mounted && listRes['success'] == true && listRes['updates'] is List) {
        final matches = (listRes['updates'] as List)
            .map((e) => AppUpdate.fromJson(e))
            .where((u) => u.id == _currentUpdate.id);
        if (matches.isNotEmpty) {
          setState(() {
            _currentUpdate = matches.first;
            _isLoadingContent = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoadingContent = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final update = _currentUpdate;

    // Category Color Mapping
    Color catColor;
    Color catBg;
    switch (update.category) {
      case 'Infrastructure':
        catColor = const Color(0xFF2563EB);
        catBg = const Color(0xFFDBEAFE);
        break;
      case 'Industrial':
        catColor = const Color(0xFF16A34A);
        catBg = const Color(0xFFDCFCE7);
        break;
      case 'Investment':
        catColor = const Color(0xFFEA580C);
        catBg = const Color(0xFFFFEDD5);
        break;
      default:
        catColor = const Color(0xFF0F766E);
        catBg = const Color(0xFFCCFBF1);
    }

    if (isDark) {
      catBg = catColor.withValues(alpha: 0.18);
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final appBarHeight = (screenWidth * 0.58).clamp(240.0, 360.0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: appBarHeight,
            pinned: true,
            stretch: true,
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
              stretchModes: const [StretchMode.zoomBackground],
              background: update.resolvedImageUrl != null
                  ? Image.network(
                      update.resolvedImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: catBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: catColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          update.category.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: catColor,
                          ),
                        ),
                      ),
                      if (update.isExclusive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'APP ONLY',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMMM d, yyyy').format(update.publishedAt ?? update.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    update.title,
                    style: GoogleFonts.inter(
                      fontSize: screenWidth < 360 ? 22 : 26,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Author & Share Bar
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: isDark ? const Color(0xFF1E293B) : Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFFFF7A00),
                          child: Text('DP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (update.author?.isNotEmpty == true) ? update.author! : 'Dholera Growth Platform',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Verified Infrastructure Intelligence',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          color: isDark ? Colors.white70 : Colors.black87,
                          onPressed: () {
                            Share.share(
                              'Read this latest Dholera SIR intelligence: ${update.title}\n\nhttps://dholeraplatform.com/blogs/${update.id}${update.isExclusive ? "?audience=app" : ""}',
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content or Loader
                  if (_isLoadingContent)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Color(0xFFFF7A00)),
                            SizedBox(height: 16),
                            Text('Loading intelligence report...'),
                          ],
                        ),
                      ),
                    )
                  else
                    Html(
                      data: update.content.isNotEmpty
                          ? update.content
                          : '<p>No content details found for this update.</p>',
                      style: {
                        "body": Style(
                          fontSize: FontSize(15),
                          lineHeight: const LineHeight(1.7),
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          fontFamily: 'Inter',
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        "h2": Style(
                          fontSize: FontSize(20),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          margin: Margins.only(top: 24, bottom: 12),
                        ),
                        "h3": Style(
                          fontSize: FontSize(17),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          margin: Margins.only(top: 18, bottom: 8),
                        ),
                        "p": Style(
                          margin: Margins.only(bottom: 16),
                        ),
                        "a": Style(
                          color: const Color(0xFFFF7A00),
                          textDecoration: TextDecoration.underline,
                        ),
                      },
                    ),

                  const SizedBox(height: 48),

                  // CTA Footer
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C2541) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? const Color(0xFF3A506B) : Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Ready to Invest in Dholera SIR?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Get direct access to certified TP plots, verified GDCR valuations, and official subsidy advisory.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _launchURL('https://wa.me/918200448270?text=${Uri.encodeComponent("Hi, I read \"${update.title}\" and want official Dholera rate sheets.")}'),
                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                            label: const Text('WHATSAPP RATES & BROCHURE'),
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
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF0F172A),
      child: const Center(
        child: Icon(Icons.apartment_rounded, color: Colors.white30, size: 64),
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
