import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/pdf_document.dart';
import '../services/api_service.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import 'secure_pdf_viewer_page.dart';

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
    final response = await _apiService.getMyVaultPdfs();
    if (response['success'] == true) {
      setState(() {
        _pdfs = (response['pdfs'] as List)
            .map((json) => PdfDocument.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.translate('nav_vault'), style: const TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pdfs.isEmpty
                  ? _buildEmptyVault(state)
                  : RefreshIndicator(
                      onRefresh: _fetchVault,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _pdfs.length,
                        itemBuilder: (context, index) => _buildPdfCard(_pdfs[index], state),
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildEmptyVault(LocalizationState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            'Your Vault is Empty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Unlock official TP maps or documents on the platform to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to Projects or TP Maps
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('EXPLORE MAPS'),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfCard(PdfDocument pdf, LocalizationState state) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SecurePdfViewerPage(pdfId: pdf.id, title: pdf.title)),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pdf.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pdf.category} • ${DateFormat('MMM dd, yyyy').format(pdf.createdAt)}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
