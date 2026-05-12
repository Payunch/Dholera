import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/pdf_document.dart';

class PdfManagerPage extends StatefulWidget {
  const PdfManagerPage({super.key});

  @override
  State<PdfManagerPage> createState() => _PdfManagerPageState();
}

class _PdfManagerPageState extends State<PdfManagerPage> {
  final ApiService _apiService = ApiService();
  List<PdfDocument> _pdfs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPdfs();
  }

  Future<void> _fetchPdfs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getPdfs();
      if (response['success'] == true) {
        setState(() {
          _pdfs = PdfDocument.fromList(response['pdfs'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['error'] ?? 'Failed to load PDFs';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _viewPdf(int id) async {
    try {
      final url = await _apiService.getPdfViewUrl(id);
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open PDF viewer')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final uploadData = await _showUploadDialog();
      if (uploadData == null) return;

      setState(() => _isLoading = true);

      try {
        final response = await _apiService.uploadPdf({
          'title': uploadData['title'],
          'category': uploadData['category'],
          'is_protected': true,
          'pdfPath': result.files.single.path,
        });

        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF uploaded successfully')),
            );
          }
          _fetchPdfs();
        } else {
          setState(() {
            _error = response['error'];
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, String>?> _showUploadDialog() async {
    String title = '';
    String category = 'Naksha';
    final categories = ['Naksha', 'DP Map', 'Brochure', 'Legal', 'General'];

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Upload PDF Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => title = value,
                  decoration: const InputDecoration(labelText: 'Title', hintText: "e.g. Plot No 5 Naksha"),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) => setDialogState(() => category = value!),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(context, {'title': title, 'category': category}),
                child: const Text('Upload'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage PDFs'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(onPressed: _fetchPdfs, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchPdfs, child: const Text('Retry')),
                    ],
                  ),
                )
              : _pdfs.isEmpty
                  ? const Center(child: Text('No PDFs uploaded yet'))
                  : ListView.builder(
                      itemCount: _pdfs.length,
                      itemBuilder: (context, index) {
                        final pdf = _pdfs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                            title: Text(pdf.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Category: ${pdf.category ?? 'General'}'),
                            trailing: const Icon(Icons.open_in_new, color: Colors.blue),
                            onTap: () => _viewPdf(pdf.id),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadPdf,
        backgroundColor: Colors.redAccent,
        tooltip: 'Upload New PDF',
        child: const Icon(Icons.add),
      ),
    );
  }
}
