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
    bool published = true;
    bool submitting = false;
    final categories = ['Infrastructure', 'Industrial', 'Planning', 'Investment', 'General', 'Article', 'Announcement'];

    showDialog(
      context: context,
      barrierDismissible: !submitting,
      builder: (dialogContext) {
        final isCompact = MediaQuery.of(dialogContext).size.width < 700;

        Future<void> pickImage(StateSetter setDialogState) async {
          final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
          if (photo != null) {
            setDialogState(() => pickedFile = photo);
          }
        }

        Future<void> submit(StateSetter setDialogState) async {
          if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Content are required')));
            return;
          }

          setDialogState(() => submitting = true);
          final result = await _apiService.createUpdate({
            'title': titleController.text.trim(),
            'content': contentController.text.trim(),
            'category': categoryController.text.trim().isEmpty ? 'General' : categoryController.text.trim(),
            'imageUrl': pickedFile == null && imageUrlController.text.trim().isNotEmpty ? imageUrlController.text.trim() : null,
            'imagePath': pickedFile?.path,
            'published': published,
          });

          if (!context.mounted) return;
          if (result['success'] == true) {
            Navigator.pop(dialogContext);
            _fetchUpdates();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update created successfully')));
          } else {
            setDialogState(() => submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
          }
        }

        return Dialog(
          insetPadding: isCompact ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isCompact ? double.infinity : 900,
              maxHeight: isCompact ? double.infinity : MediaQuery.of(dialogContext).size.height * 0.92,
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
                            Expanded(
                              child: Text(
                                'Create New Update',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                                controller: titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                initialValue: categoryController.text,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(),
                                ),
                                items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                                onChanged: (value) => setDialogState(() => categoryController.text = value ?? 'General'),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: contentController,
                                decoration: const InputDecoration(
                                  labelText: 'Content',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: isCompact ? 10 : 16,
                                minLines: 8,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Header Image',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: submitting ? null : () => pickImage(setDialogState),
                                    icon: const Icon(Icons.image),
                                    label: const Text('Choose Image'),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: imageUrlController,
                                      decoration: const InputDecoration(
                                        labelText: 'Image URL (optional)',
                                        border: OutlineInputBorder(),
                                      ),
                                      enabled: pickedFile == null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (pickedFile != null)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Theme.of(context).dividerColor),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: [
                                      Image.file(
                                        File(pickedFile!.path),
                                        height: 220,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: IconButton.filledTonal(
                                          onPressed: submitting ? null : () => setDialogState(() => pickedFile = null),
                                          icon: const Icon(Icons.close),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Published'),
                                subtitle: const Text('Make the update visible to public users immediately'),
                                value: published,
                                onChanged: (value) => setDialogState(() => published = value),
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
                                    : const Text('Create Update'),
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
}
