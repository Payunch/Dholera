import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../models/app_update.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  List<AppUpdate> _updates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUpdates();
  }

  Future<void> _fetchUpdates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getUpdates();
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
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUpdate(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this update?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await _apiService.deleteUpdate(id);
        if (!mounted) return;
        if (result['success'] == true) {
          _fetchUpdates();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update deleted')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Updates'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(onPressed: _fetchUpdates, icon: const Icon(Icons.refresh)),
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
                      ElevatedButton(onPressed: _fetchUpdates, child: const Text('Retry')),
                    ],
                  ),
                )
              : _updates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.update_disabled, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No updates found'),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _fetchUpdates, child: const Text('Refresh')),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchUpdates,
                      child: ListView.builder(
                        itemCount: _updates.length,
                        itemBuilder: (context, index) {
                          final update = _updates[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: update.imageUrl != null
                                  ? Image.network(update.imageUrl!, width: 50, height: 50, fit: BoxFit.cover, 
                                      errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported))
                                  : const Icon(Icons.update, size: 40, color: Colors.orange),
                              title: Text(update.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${update.category} • ${DateFormat('dd MMM yyyy').format(update.createdAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteUpdate(update.id),
                              ),
                              onTap: () => _showUpdateDetails(update),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateUpdateDialog(),
        backgroundColor: Colors.orange,
        tooltip: 'Create New Update',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showUpdateDetails(AppUpdate update) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (update.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(update.imageUrl!, width: double.infinity, height: 250, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox()),
                ),
              const SizedBox(height: 16),
              Text(update.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(update.category, style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w500)),
              const Divider(height: 32),
              Text(update.content, style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Created: ${DateFormat('dd MMM yyyy, hh:mm a').format(update.createdAt)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(update.published ? Icons.check_circle : Icons.unpublished, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Status: ${update.published ? "Published" : "Draft"}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateUpdateDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final categoryController = TextEditingController(text: 'General');
    final imageUrlController = TextEditingController();
    XFile? pickedFile;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Update'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
                TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content'), maxLines: 3),
                const SizedBox(height: 16),
                if (pickedFile != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(pickedFile!.path), height: 100, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => setDialogState(() => pickedFile = null),
                        ),
                      )
                    ],
                  )
                else
                  TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: 'Image URL (optional)')),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
                    if (photo != null) {
                      setDialogState(() => pickedFile = photo);
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Pick Image from Gallery'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || contentController.text.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Content are required')));
                  }
                  return;
                }
                
                final result = await _apiService.createUpdate({
                  'title': titleController.text,
                  'content': contentController.text,
                  'category': categoryController.text,
                  'imageUrl': pickedFile == null && imageUrlController.text.isNotEmpty ? imageUrlController.text : null,
                  'imagePath': pickedFile?.path,
                  'published': true,
                });

                if (!context.mounted) return;
                Navigator.pop(dialogContext);
                _fetchUpdates();
                
                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update created successfully')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
