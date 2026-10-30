import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import '../services/api_service.dart';

class ProjectDetailPage extends StatefulWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final ApiService _apiService = ApiService();
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Project: ${widget.project.name}');
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList('saved_project_ids') ?? [];
      if (mounted) {
        setState(() {
          _isBookmarked = bookmarks.contains(widget.project.id.toString());
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleBookmark() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList('saved_project_ids') ?? [];
      final idStr = widget.project.id.toString();
      final adding = !bookmarks.contains(idStr);

      if (adding) {
        bookmarks.add(idStr);
      } else {
        bookmarks.remove(idStr);
      }
      await prefs.setStringList('saved_project_ids', bookmarks);

      if (mounted) {
        setState(() => _isBookmarked = adding);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adding ? 'Saved to Bookmarked Projects' : 'Removed from Bookmarks'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFFFF7A00),
          ),
        );
      }
    } catch (_) {}
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
                expandedHeight: 280,
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
                  background: Image.network(
                    widget.project.image != null && widget.project.image!.startsWith('http')
                        ? widget.project.image!
                        : 'https://api.dholeraplatform.com${widget.project.image}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/ui_blueprint.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7A00).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.project.category.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFFF7A00),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (widget.project.reraApproved)
                            const Row(
                              children: [
                                Icon(Icons.verified, color: Color(0xFF16A34A), size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'RERA VERIFIED',
                                  style: TextStyle(
                                    color: Color(0xFF16A34A),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.project.name,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.translate(widget.project.taglineKey),
                        style: TextStyle(
                          color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Project Specifications'),
                      const SizedBox(height: 14),
                      _buildSpecGrid(isDark),
                      const SizedBox(height: 28),
                      _buildSectionTitle('About Project'),
                      const SizedBox(height: 12),
                      Text(
                        state.translate(widget.project.descKey),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: isDark ? Colors.grey[300] : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: _buildBottomActions(context, isDark),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildSpecGrid(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 500 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.1,
          children: [
            _buildSpecItem(Icons.straighten, 'Plot Sizes', widget.project.plotSizes ?? 'N/A', isDark),
            _buildSpecItem(Icons.home_work, 'Offering', widget.project.offering ?? 'N/A', isDark),
            _buildSpecItem(Icons.add_road, 'Road Width', widget.project.roadWidth ?? 'N/A', isDark),
            _buildSpecItem(Icons.layers, 'Zoning', widget.project.zoning ?? 'N/A', isDark),
          ],
        );
      },
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF3A506B) : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFFF7A00)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF1F2937) : Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _launchWhatsapp,
                icon: const Icon(Icons.chat_bubble, size: 18),
                label: const Text('WHATSAPP INQUIRY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: _isBookmarked
                    ? const Color(0xFFFF7A00)
                    : (isDark ? const Color(0xFF1C2541) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isBookmarked
                      ? const Color(0xFFFF7A00)
                      : (isDark ? const Color(0xFF3A506B) : Colors.grey[300]!),
                ),
              ),
              child: IconButton(
                onPressed: _toggleBookmark,
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _isBookmarked ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                ),
                padding: const EdgeInsets.all(14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchWhatsapp() async {
    final text = Uri.encodeComponent(
      widget.project.whatsappText ?? 'Hi, I am interested in ${widget.project.name} in Dholera SIR.',
    );
    final url = Uri.parse('https://wa.me/918200448270?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
