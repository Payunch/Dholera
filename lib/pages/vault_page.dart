import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/pdf_document.dart';
import '../services/api_service.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import 'secure_pdf_viewer_page.dart';
import 'tp_maps_page.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final ApiService _apiService = ApiService();
  List<PdfDocument> _pdfs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVault();
    _apiService.trackActivity('My Vault');
  }

  Future<void> _fetchVault() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getMyVaultPdfs();
      if (response['success'] == true &&
          response['pdfs'] is List &&
          (response['pdfs'] as List).isNotEmpty) {
        if (mounted) {
          setState(() {
            _pdfs = (response['pdfs'] as List)
                .map((json) => PdfDocument.fromJson(json))
                .toList();
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {}

    try {
      final catalog = await _apiService.getPdfs();
      if (mounted && catalog['success'] == true && catalog['pdfs'] is List) {
        setState(() {
          _pdfs = (catalog['pdfs'] as List)
              .map((json) => PdfDocument.fromJson(json))
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              state.translate('nav_vault'),
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
              : _pdfs.isEmpty
                  ? _buildEmptyVault(state, isDark)
                  : RefreshIndicator(
                      color: const Color(0xFFFF7A00),
                      onRefresh: _fetchVault,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: _pdfs.length,
                        itemBuilder: (context, index) => _buildPdfCard(_pdfs[index], state, isDark),
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildEmptyVault(LocalizationState state, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 72, color: isDark ? Colors.white24 : Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Your Vault is Ready',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore official TP maps, GDCR master plans, or project brochures to view them securely here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TpMapsPage()),
              ),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('EXPLORE TOWN PLANNING MAPS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfCard(PdfDocument pdf, LocalizationState state, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF3A506B) : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SecurePdfViewerPage(
              pdfId: pdf.id,
              title: pdf.title,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pdf.title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Official Document • Tap to View',
                      style: TextStyle(
                        color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Added: ${DateFormat('dd MMM yyyy').format(pdf.createdAt)}',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
