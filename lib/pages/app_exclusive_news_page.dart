import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/localization/localization_bloc.dart';
import '../models/app_update.dart';
import '../services/api_service.dart';
import 'blog_editor_page.dart';
import 'update_detail_page.dart';

class AppExclusiveNewsPage extends StatefulWidget {
  const AppExclusiveNewsPage({super.key});

  @override
  State<AppExclusiveNewsPage> createState() => _AppExclusiveNewsPageState();
}

class _AppExclusiveNewsPageState extends State<AppExclusiveNewsPage> {
  final ApiService _apiService = ApiService();
  List<AppUpdate> _updates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUpdates();
  }

  Future<void> _fetchUpdates() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final lang = context.read<LocalizationBloc>().state.locale.languageCode;
      final response = await _apiService.getUpdates(
        lang: lang,
        audience: 'app',
        exclusiveOnly: true,
      );
      if (!mounted) return;
      if (response['success'] == true) {
        final List<dynamic> data = response['updates'] ?? [];
        setState(() {
          _updates = AppUpdate.fromList(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['error'] ?? 'Failed to load app exclusive news';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openEditor() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BlogEditorPage(initialExclusive: true),
      ),
    );
    if (result == true) {
      await _fetchUpdates();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<AuthBloc>().state.role == AppRole.adminOwner;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'EXCLUSIVE NEWS',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        actions: [
          IconButton(
            onPressed: _fetchUpdates,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: _openEditor,
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'New App Only',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _error != null
              ? _buildErrorView()
              : _updates.isEmpty
                  ? _buildEmptyView()
                  : RefreshIndicator(
                      color: Colors.orange,
                      onRefresh: _fetchUpdates,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: _updates.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final update = _updates[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UpdateDetailPage(
                                  update: update,
                                  isAdmin: isAdmin,
                                ),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.blueGrey[100]!,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                                    blurRadius: 28,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (update.resolvedImageUrl != null)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(28),
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Image.network(
                                          update.resolvedImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: Colors.blueGrey[50],
                                            child: const Center(
                                              child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(22),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(999),
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
                                            const Spacer(),
                                            Text(
                                              DateFormat('MMM d, yyyy').format(update.createdAt),
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                color: Colors.grey[500],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          update.title,
                                          style: GoogleFonts.inter(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            height: 1.15,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          update.content.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' '),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            height: 1.5,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Content Temporarily Unavailable',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'App-only content feed is unavailable right now.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchUpdates,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'NO APP ONLY NEWS YET',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w900,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'When admin posts an exclusive update, it will appear here.',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchUpdates,
            child: const Text('REFRESH'),
          ),
        ],
      ),
    );
  }
}
