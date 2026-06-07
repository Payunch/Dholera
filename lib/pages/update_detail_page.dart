import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/app_update.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDetailPage extends StatelessWidget {
  final AppUpdate update;
  final bool isAdmin;

  const UpdateDetailPage({
    super.key,
    required this.update,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Category Color Mapping
    Color catColor;
    Color catBg;
    switch (update.category) {
      case 'Infrastructure':
        catColor = Colors.blue[600]!;
        catBg = Colors.blue[50]!;
        break;
      case 'Industrial':
        catColor = Colors.green[700]!;
        catBg = Colors.green[50]!;
        break;
      case 'Investment':
        catColor = Colors.orange[600]!;
        catBg = Colors.orange[50]!;
        break;
      default:
        catColor = Colors.slate[600]!;
        catBg = Colors.slate[50]!;
    }

    if (isDark) catBg = catColor.withOpacity(0.1);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? const Color(0xFF020617) : Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: update.imageUrl != null
                  ? Image.network(
                      update.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: catBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: catColor.withOpacity(0.2)),
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
                      const SizedBox(width: 16),
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMMM d, yyyy').format(update.publishedAt ?? update.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    update.title,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -1,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Author Section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: Colors.grey[isDark ? 800 : 100]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.orange,
                          child: Text('DP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dholera Growth Team',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Verified Analysis',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {},
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Content
                  Text(
                    update.content,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.7,
                      color: isDark ? Colors.slate[300] : const Color(0xFF334155),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // CTA Footer
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.03) : Colors.slate[50],
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.grey[isDark ? 900 : 100]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Ready to invest in Dholera SIR?',
                          textAlign: TextCenter.center,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _launchURL('https://wa.me/917435808031'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7A00),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: Text(
                              'BOOK FREE SITE VISIT',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                              side: BorderSide(color: isDark ? Colors.grey[800]! : const Color(0xFF0F172A), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              'VIEW VERIFIED PROJECTS',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12),
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
        child: Icon(Icons.article_outlined, size: 64, color: Colors.white24),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
