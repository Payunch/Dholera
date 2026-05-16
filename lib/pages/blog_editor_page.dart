import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/app_update.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class BlogEditorPage extends StatefulWidget {
  final AppUpdate? update;

  const BlogEditorPage({super.key, this.update});

  @override
  State<BlogEditorPage> createState() => _BlogEditorPageState();
}

class _BlogEditorPageState extends State<BlogEditorPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _category;
  late bool _published;
  late String _imagePosition;
  XFile? _pickedFile;
  String? _existingImageUrl;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Infrastructure',
    'Industrial',
    'Planning',
    'Investment',
    'General',
    'Article',
    'Announcement'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _titleController = TextEditingController(text: widget.update?.title ?? '');
    _contentController = TextEditingController(text: widget.update?.content ?? '');
    _category = widget.update?.category ?? 'General';
    _published = widget.update?.published ?? true;
    _imagePosition = widget.update?.imagePosition ?? 'top';
    _existingImageUrl = widget.update?.imageUrl;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() {
        _pickedFile = photo;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'category': _category,
      'published': _published,
      'imagePosition': _imagePosition,
      if (_pickedFile != null) 'imagePath': _pickedFile!.path,
    };

    try {
      final result = widget.update == null
          ? await _apiService.createUpdate(data)
          : await _apiService.updateUpdate(widget.update!.id, data);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.update == null ? 'Blog created' : 'Blog updated')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error']}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.update == null ? 'Create Blog' : 'Edit Blog'),
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Edit', icon: Icon(Icons.edit)),
            Tab(text: 'Preview', icon: Icon(Icons.visibility)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        actions: [
          if (!_isSubmitting)
            IconButton(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              tooltip: 'Save',
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEditView(),
          _buildPreviewView(),
        ],
      ),
    );
  }

  Widget _buildEditView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Title required' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                helperText: 'Use blank lines for paragraphs',
              ),
              maxLines: 12,
              minLines: 5,
              validator: (v) => v == null || v.isEmpty ? 'Content required' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text('Image Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Image'),
                  ),
                ),
                const SizedBox(width: 8),
                if (_pickedFile != null || _existingImageUrl != null)
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _imagePosition,
                      decoration: const InputDecoration(
                        labelText: 'Position',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'top', child: Text('Top')),
                        DropdownMenuItem(value: 'bottom', child: Text('Bottom')),
                        DropdownMenuItem(value: 'none', child: Text('None')),
                      ],
                      onChanged: (v) => setState(() => _imagePosition = v!),
                    ),
                  ),
              ],
            ),
            if (_pickedFile != null || _existingImageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    _pickedFile != null
                        ? Image.file(File(_pickedFile!.path), height: 150, width: double.infinity, fit: BoxFit.cover)
                        : Image.network(_existingImageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.error))),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: IconButton.filled(
                        onPressed: () => setState(() {
                          _pickedFile = null;
                          _existingImageUrl = null;
                        }),
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Published'),
              value: _published,
              onChanged: (v) => setState(() => _published = v),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated Website Look
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.language, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text('dholeraplatform.com', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Category Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _category.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          
          // Title
          Text(
            _titleController.text.isEmpty ? 'Blog Title' : _titleController.text,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.black, height: 1.1),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: Colors.orange, child: Icon(Icons.person, size: 14, color: Colors.white)),
              const SizedBox(width: 8),
              const Text('Dholera Growth Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              Text(DateFormat('dd MMM yyyy').format(DateTime.now()), style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const Divider(height: 32),

          // Top Image
          if (_imagePosition == 'top' && (_pickedFile != null || _existingImageUrl != null)) ...[
            _buildPreviewImage(),
            const SizedBox(height: 20),
          ],

          // Content
          ..._buildFormattedContent(),

          // Bottom Image
          if (_imagePosition == 'bottom' && (_pickedFile != null || _existingImageUrl != null)) ...[
            const SizedBox(height: 20),
            _buildPreviewImage(),
          ],
          
          const SizedBox(height: 40),
          const Center(
            child: Text('--- End of Preview ---', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _pickedFile != null
          ? Image.file(File(_pickedFile!.path), width: double.infinity, fit: BoxFit.cover)
          : Image.network(_existingImageUrl!, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox()),
    );
  }

  List<Widget> _buildFormattedContent() {
    final text = _contentController.text.isEmpty ? 'Your content will appear here...' : _contentController.text;
    final paragraphs = text.split('\n\n');
    
    return paragraphs.map((p) {
      if (p.trim().isEmpty) return const SizedBox();
      
      // Simple header detection (e.g. if it ends with :)
      bool isHeader = p.trim().endsWith(':') || p.trim().startsWith('#');
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          p.trim().replaceAll('#', ''),
          style: TextStyle(
            fontSize: isHeader ? 20 : 16,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: isHeader ? Colors.orange[800] : Colors.black87,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
      );
    }).toList();
  }
}
