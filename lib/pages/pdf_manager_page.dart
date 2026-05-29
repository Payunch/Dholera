import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
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

  String _formatUploadedAt(DateTime? uploadedAt) {
    if (uploadedAt == null) return 'Upload time unavailable';
    return DateFormat('dd MMM yyyy, hh:mm a').format(uploadedAt);
  }

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
    String title = '';
    String category = 'Naksha';
    bool isProtected = true;
    File? selectedFile;
    bool submitting = false;
    final categories = ['Naksha', 'DP Map', 'Brochure', 'Legal', 'General', 'Policy', 'Survey'];

    await showDialog<void>(
      context: context,
      barrierDismissible: !submitting,
      builder: (dialogContext) {
        final isCompact = MediaQuery.of(dialogContext).size.width < 720;

        Future<void> pickPdf(StateSetter setDialogState) async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );
          if (result != null && result.files.single.path != null) {
            setDialogState(() => selectedFile = File(result.files.single.path!));
          }
        }

        Future<void> submit(StateSetter setDialogState) async {
          if (title.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
            return;
          }
          if (selectedFile == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please choose a PDF file')));
            return;
          }

          setDialogState(() => submitting = true);
          try {
            final response = await _apiService.uploadPdf({
              'title': title.trim(),
              'category': category,
              'is_protected': isProtected,
              'pdfPath': selectedFile!.path,
            });

            if (!mounted) return;
            if (response['success'] == true) {
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              final uploadedPdfData = response['pdf'];
              if (uploadedPdfData is Map<String, dynamic>) {
                setState(() {
                  _pdfs = [PdfDocument.fromJson(uploadedPdfData), ..._pdfs];
                });
              }
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF uploaded successfully')));
              _fetchPdfs();
            } else {
              setDialogState(() => submitting = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response['error']}')));
            }
          } catch (e) {
            if (!mounted) return;
            setDialogState(() => submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }

        return Dialog(
          insetPadding: isCompact ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isCompact ? double.infinity : 760,
              maxHeight: isCompact ? double.infinity : MediaQuery.of(dialogContext).size.height * 0.9,
            ),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Upload PDF',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: submitting ? null : () => Navigator.pop(dialogContext),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                onChanged: (value) => title = value,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                  hintText: 'e.g. Plot No 5 Naksha',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                initialValue: category,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(),
                                ),
                                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (value) => setDialogState(() => category = value ?? 'General'),
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Protected document'),
                                subtitle: const Text('Require a valid token before viewing'),
                                value: isProtected,
                                onChanged: (value) => setDialogState(() => isProtected = value),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).dividerColor),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedFile?.path.split('/').last ?? 'No file selected',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Choose a PDF from your device and upload it to the secure document library.'),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: submitting ? null : () => pickPdf(setDialogState),
                                          icon: const Icon(Icons.upload_file),
                                          label: const Text('Choose PDF'),
                                        ),
                                        if (selectedFile != null)
                                          TextButton(
                                            onPressed: submitting ? null : () => setDialogState(() => selectedFile = null),
                                            child: const Text('Clear file'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: submitting ? null : () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: submitting ? null : () => submit(setDialogState),
                                child: submitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Upload PDF'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
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
                            subtitle: Text(
                              'Category: ${pdf.category ?? 'General'}\nUploaded: ${_formatUploadedAt(pdf.createdAt)}',
                            ),
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
