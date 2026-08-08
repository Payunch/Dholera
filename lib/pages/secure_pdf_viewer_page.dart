import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
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
  String? _pdfUrl;

  @override
  void initState() {
    super.initState();
    _openPdfExternal();
  }

  Future<void> _openPdfExternal() async {
    try {
      final url = await _apiService.getPdfViewUrl(widget.pdfId);
      final uri = Uri.parse(url);
      
      if (mounted) {
        setState(() {
          _pdfUrl = url;
        });
      }

      // Force launch without checking canLaunchUrl to avoid Android 11+ intent visibility issues
      final launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      
      if (launched && mounted) {
        // Go back automatically if it successfully launched the browser
        Navigator.of(context).pop();
      } else {
        if (mounted) {
          setState(() {
            _error = 'Could not automatically open the browser. Please tap the button below.';
            _isLoading = false;
          });
        }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Opening in external browser...', style: TextStyle(color: Colors.grey)),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _error != null ? Icons.warning_amber_rounded : Icons.check_circle_outline, 
                      color: _error != null ? Colors.orange : Colors.green, 
                      size: 64
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error ?? 'Document ready.', 
                      style: const TextStyle(fontSize: 16), 
                      textAlign: TextAlign.center
                    ),
                    const SizedBox(height: 32),
                    if (_pdfUrl != null) ...[
                      ElevatedButton.icon(
                        onPressed: () => launchUrl(Uri.parse(_pdfUrl!), mode: LaunchMode.inAppBrowserView),
                        icon: const Icon(Icons.open_in_browser, color: Colors.white),
                        label: const Text('Open Document', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _pdfUrl!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('URL copied to clipboard')),
                          );
                        },
                        icon: const Icon(Icons.copy, color: Colors.grey),
                        label: const Text('Copy Link', style: TextStyle(color: Colors.grey)),
                      ),
                    ]
                  ],
                ),
              ),
      ),
    );
  }
}
