import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
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
  bool _isLoading = true;
  String? _error;
  String? _localPdfPath;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();
    _loadPdfStream();
  }

  Future<void> _loadPdfStream() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final bytes = await _apiService.getPdfBytes(widget.pdfId);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/secure_pdf_${widget.pdfId}_${DateTime.now().millisecondsSinceEpoch}.pdf');

      await tempFile.writeAsBytes(bytes, flush: true);

      if (mounted) {
        setState(() {
          _localPdfPath = tempFile.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (_localPdfPath != null) {
      try {
        final file = File(_localPdfPath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }
    super.dispose();
  }

  Future<void> _toggleOrientation() async {
    final nextLandscape = !_isLandscape;
    await SystemChrome.setPreferredOrientations(
      nextLandscape
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp],
    );
    if (mounted) {
      setState(() {
        _isLandscape = nextLandscape;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isReady)
            IconButton(
              tooltip: _isLandscape ? 'Portrait view' : 'Landscape view',
              onPressed: _toggleOrientation,
              icon: Icon(
                _isLandscape ? Icons.screen_lock_portrait : Icons.screen_rotation,
                color: Colors.white,
              ),
            ),
          if (_isReady && _totalPages > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Securing & loading document...', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            )
              : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_clock, color: Colors.orange, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadPdfStream,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Retry', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : _localPdfPath != null
                  ? PDFView(
                      filePath: _localPdfPath,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: true,
                      pageSnap: true,
                      defaultPage: _currentPage,
                      fitPolicy: FitPolicy.BOTH,
                      preventLinkNavigation: true,
                      onRender: (pages) {
                        setState(() {
                          _totalPages = pages ?? 0;
                          _isReady = true;
                        });
                      },
                      onError: (error) {
                        setState(() {
                          _error = error.toString();
                        });
                      },
                      onPageError: (page, error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Page $page error: $error')),
                        );
                      },
                      onPageChanged: (int? page, int? total) {
                        if (page != null) {
                          setState(() {
                            _currentPage = page;
                          });
                        }
                      },
                    )
                  : const SizedBox.shrink(),
    );
  }
}
