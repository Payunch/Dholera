import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/app_update.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import 'blog_editor_page.dart';
import 'update_detail_page.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
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
      final response = await _apiService.getUpdates();
      if (!mounted) return;
      if (response['success'] == true) {
        final List<dynamic> updatesData = response['updates'] ?? [];
        setState(() {
          _updates = AppUpdate.fromList(updatesData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['error'] ?? 'Failed to load updates';
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

  void _navigateToEditor([AppUpdate? update]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogEditorPage(update: update),
      ),
    );

    if (result == true) {
      _fetchUpdates();
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
          'INTELLIGENCE',
          style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        actions: [
          IconButton(onPressed: _fetchUpdates, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
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
                        separatorBuilder: (context, index) => const SizedBox(height: 24),
                        itemBuilder: (context, index) {
                          return _buildUpdateCard(_updates[index], isAdmin, isDark);
                        },
                      ),
                    ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _navigateToEditor,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildUpdateCard(AppUpdate update, bool isAdmin, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => UpdateDetailPage(update: update, isAdmin: isAdmin)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.slate[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (update.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    update.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.slate[100]),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        update.category.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange[700],
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy').format(update.createdAt),
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    update.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    update.content,
                    maxLines: 3,
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
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Error: $_error', textAlign: TextCenter.center),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _fetchUpdates, child: const Text('RETRY')),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'NO INTELLIGENCE FOUND',
            style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _fetchUpdates, child: const Text('REFRESH')),
        ],
      ),
    );
  }
}

