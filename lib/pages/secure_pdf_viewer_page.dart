import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class SecurePdfViewerPage extends StatefulWidget {
  final int pdfId;
  final String title;

  const SecurePdfViewerPage({super.key, required this.pdfId, required this.title});

  @override
  State<SecurePdfViewerPage> createState() => _SecurePdfViewerPageState();
}

class _SecurePdfViewerPageState extends State<SecurePdfViewerPage> {
  final ApiService _apiService = ApiService();
  String? _localPath;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final token = await _apiService.getAuthToken();
      final url = await _apiService.getPdfViewUrl(widget.pdfId);
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp_pdf_${widget.pdfId}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        
        if (mounted) {
          setState(() {
            _localPath = file.path;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load document (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Delete temp file on exit for security
    if (_localPath != null) {
      File(_localPath!).delete().catchError((_) => null);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : PDFView(
                  filePath: _localPath,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: false,
                  pageFling: false,
                  onError: (error) {
                    setState(() => _error = error.toString());
                  },
                  onPageError: (page, error) {
                    setState(() => _error = error.toString());
                  },
                ),
    );
  }
}
