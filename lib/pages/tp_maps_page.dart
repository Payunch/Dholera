import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tp_map.dart';
import '../services/api_service.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import 'vault_page.dart';

class TpMapsPage extends StatefulWidget {
  const TpMapsPage({super.key});

  @override
  State<TpMapsPage> createState() => _TpMapsPageState();
}

class _TpMapsPageState extends State<TpMapsPage> {
  final ApiService _apiService = ApiService();
  List<TpMap> _tpMaps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTpMaps();
    _apiService.trackActivity('TP Maps List');
  }

  Future<void> _fetchTpMaps() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getTpMaps();
      if (mounted && response['success'] == true) {
        setState(() {
          _tpMaps = (response['tpMaps'] as List)
              .map((json) => TpMap.fromJson(json))
              .toList();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              state.translate('tp_maps_title'),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 16,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00)))
              : _tpMaps.isEmpty
                  ? _buildEmptyState(state, isDark)
                  : RefreshIndicator(
                      color: const Color(0xFFFF7A00),
                      onRefresh: _fetchTpMaps,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: _tpMaps.length,
                        itemBuilder: (context, index) => _buildTpCard(_tpMaps[index], state, isDark),
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildEmptyState(LocalizationState state, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: isDark ? Colors.white30 : Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No TP Maps Loaded',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh or check your internet connection.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchTpMaps,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
              ),
              child: const Text('REFRESH'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTpCard(TpMap tp, LocalizationState state, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF3A506B) : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A00).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.map_outlined, size: 26, color: Color(0xFFFF7A00)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: tp.badges.map((badge) {
                      final isCompliance = badge['type'] == 'compliance';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompliance
                              ? const Color(0xFF16A34A).withValues(alpha: 0.15)
                              : const Color(0xFFFF7A00).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCompliance ? const Color(0xFF16A34A) : const Color(0xFFFF7A00),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          badge['text'].toString().toUpperCase(),
                          style: TextStyle(
                            color: isCompliance ? const Color(0xFF16A34A) : const Color(0xFFFF7A00),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              tp.title,
              style: GoogleFonts.inter(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.layers, tp.area, isDark: isDark),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.shield_outlined, tp.focus, iconColor: const Color(0xFFFF7A00), isDark: isDark),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VaultPage()),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                label: const Text('EXPLORE OFFICIAL GAZZETE & MAP PDF'),
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
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor, required bool isDark}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor ?? (isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: iconColor ?? (isDark ? Colors.grey[300] : Colors.grey[700]),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
