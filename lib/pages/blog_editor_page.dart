import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/app_update.dart';
import '../models/seo_review_result.dart';
import '../services/api_service.dart';

class BlogEditorPage extends StatefulWidget {
  final AppUpdate? update;
  final bool initialExclusive;

  const BlogEditorPage({super.key, this.update, this.initialExclusive = false});

  @override
  State<BlogEditorPage> createState() => _BlogEditorPageState();
}

class _BlogEditorPageState extends State<BlogEditorPage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _category;
  late bool _published;
  late bool _isExclusive;
  late DateTime _publishedAt;
  late String _imagePosition;
  XFile? _pickedFile;
  String? _existingImageUrl;
  bool _isSubmitting = false;

  late TextEditingController _seoTitleController;
  late TextEditingController _seoDescriptionController;
  late TextEditingController _seoKeywordsController;
  late TextEditingController _slugController;
  late TextEditingController _imageAltTextController;
  late TextEditingController _imageTitleController;
  late TextEditingController _tagsController;

  SeoReviewResult? _seoReview;
  bool _isReviewing = false;

  final List<String> _categories = [
    'Infrastructure',
    'Industrial',
    'Planning',
    'Investment',
    'General',
    'Article',
    'Announcement',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _titleController = TextEditingController(text: widget.update?.title ?? '');
    _contentController = TextEditingController(
      text: widget.update?.content ?? '',
    );
    _category = widget.update?.category ?? 'General';
    _published = widget.update?.published ?? false;
    _isExclusive = widget.update?.isExclusive ?? widget.initialExclusive;
    _publishedAt =
        widget.update?.publishedAt ??
        widget.update?.createdAt ??
        DateTime.now();
    _imagePosition = widget.update?.imagePosition ?? 'top';
    _existingImageUrl = widget.update?.imageUrl;

    _seoTitleController = TextEditingController(
      text: widget.update?.seoTitle ?? '',
    );
    _seoDescriptionController = TextEditingController(
      text: widget.update?.seoDescription ?? '',
    );
    _seoKeywordsController = TextEditingController(
      text: widget.update?.seoKeywords ?? '',
    );
    _slugController = TextEditingController(text: widget.update?.slug ?? '');
    _imageAltTextController = TextEditingController(
      text: widget.update?.imageAltText ?? '',
    );
    _imageTitleController = TextEditingController(
      text: widget.update?.imageTitle ?? '',
    );
    _tagsController = TextEditingController(text: widget.update?.tags ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _seoTitleController.dispose();
    _seoDescriptionController.dispose();
    _seoKeywordsController.dispose();
    _slugController.dispose();
    _imageAltTextController.dispose();
    _imageTitleController.dispose();
    _tagsController.dispose();
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
      'isExclusive': _isExclusive,
      'publishedAt': _publishedAt.toIso8601String(),
      'imagePosition': _imagePosition,
      if (_pickedFile != null) 'imagePath': _pickedFile!.path,
      'seoTitle': _seoTitleController.text.trim(),
      'seoDescription': _seoDescriptionController.text.trim(),
      'seoKeywords': _seoKeywordsController.text.trim(),
      'slug': _slugController.text.trim(),
      'imageAltText': _imageAltTextController.text.trim(),
      'imageTitle': _imageTitleController.text.trim(),
      'tags': _tagsController.text.trim(),
    };

    try {
      final result = widget.update == null
          ? await _apiService.createUpdate(data)
          : await _apiService.updateUpdate(widget.update!.id, data);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.update == null ? 'Blog created' : 'Blog updated',
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _runSeoReview() async {
    setState(() => _isReviewing = true);
    try {
      final data = {
        'title': _titleController.text,
        'content': _contentController.text,
        'category': _category,
        'focusKeyword': _seoKeywordsController.text,
        'seoTitle': _seoTitleController.text,
        'seoDescription': _seoDescriptionController.text,
        'slug': _slugController.text,
        'imageAltText': _imageAltTextController.text,
        'tags': _tagsController.text,
      };
      final res = await _apiService.reviewBlogSeo(data);
      if (res['success'] == true) {
        setState(() {
          _seoReview = SeoReviewResult.fromJson(res['data'] ?? res);
        });
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AI Review Failed: ${res['error']}')),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('AI Review Error: $e')));
    } finally {
      if (mounted) setState(() => _isReviewing = false);
    }
  }

  void _applySeoSuggestions() {
    if (_seoReview == null) return;
    setState(() {
      if (_seoReview!.seoTitle.isNotEmpty)
        _seoTitleController.text = _seoReview!.seoTitle;
      if (_seoReview!.metaDescription.isNotEmpty)
        _seoDescriptionController.text = _seoReview!.metaDescription;
      if (_seoReview!.slug.isNotEmpty) _slugController.text = _seoReview!.slug;
      if (_seoReview!.primaryKeyword.isNotEmpty)
        _seoKeywordsController.text = _seoReview!.primaryKeyword;
      if (_seoReview!.imageAltText.isNotEmpty)
        _imageAltTextController.text = _seoReview!.imageAltText;
      if (_seoReview!.imageTitle.isNotEmpty)
        _imageTitleController.text = _seoReview!.imageTitle;
      if (_seoReview!.tags.isNotEmpty)
        _tagsController.text = _seoReview!.tags.join(', ');
    });
  }

  void _insertFaq(String question) {
    final answerController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add FAQ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: question,
              decoration: const InputDecoration(labelText: 'Question'),
              onChanged: (val) => question = val,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Answer'),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (question.isNotEmpty && answerController.text.isNotEmpty) {
                setState(() {
                  _contentController.text += '\n\n<h3>Q: $question</h3>\n<p>A: ${answerController.text}</p>\n';
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Insert FAQ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.update == null
              ? (_isExclusive ? 'Create App Only Blog' : 'Create Blog')
              : (_isExclusive ? 'Edit App Only Blog' : 'Edit Blog'),
        ),
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
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildEditView(), _buildPreviewView()],
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
              validator: (v) =>
                  v == null || v.isEmpty ? 'Title required' : null,
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
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
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
              validator: (v) =>
                  v == null || v.isEmpty ? 'Content required' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text(
              'Image Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
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
                        DropdownMenuItem(
                          value: 'bottom',
                          child: Text('Bottom'),
                        ),
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
                        ? Image.file(
                            File(_pickedFile!.path),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            _existingImageUrl!.startsWith('http')
                                ? _existingImageUrl!
                                : 'https://api.dholeraplatform.com$_existingImageUrl',
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 150,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            ),
                          ),
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

            // --- SEO Fields ---
            const Text(
              'SEO Configuration',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _seoKeywordsController,
              decoration: const InputDecoration(
                labelText: 'Focus Keyword',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _slugController,
              decoration: const InputDecoration(
                labelText: 'Slug (URL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _seoTitleController,
              decoration: const InputDecoration(
                labelText: 'SEO Title (50-60 chars)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _seoDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Meta Description (140-160 chars)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _imageAltTextController,
              decoration: const InputDecoration(
                labelText: 'Image ALT Text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _imageTitleController,
              decoration: const InputDecoration(
                labelText: 'Image Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // --- AI SEO REVIEW ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'AI SEO Review',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isReviewing ? null : _runSeoReview,
                        icon: _isReviewing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: const Text('Analyze'),
                      ),
                    ],
                  ),
                  if (_seoReview != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Estimated Score: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_seoReview!.estimatedScore}/100',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _seoReview!.estimatedScore >= 90
                                ? Colors.green
                                : Colors.red,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _applySeoSuggestions,
                          icon: const Icon(Icons.check),
                          label: const Text('Apply AI Metadata'),
                        ),
                      ],
                    ),
                    if (_seoReview!.missingItems.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Missing Checkpoints:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ..._seoReview!.missingItems.map(
                        (e) => Text(
                          '- $e',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                    if (_seoReview!.improvements.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Suggestions:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ..._seoReview!.improvements.map(
                        (e) => Text(
                          '- $e',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                    if (_seoReview!.faqQuestions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Suggested FAQs (Tap to Insert):',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _seoReview!.faqQuestions
                            .map(
                              (q) => ActionChip(
                                label: Text(q),
                                onPressed: () => _insertFaq(q),
                                backgroundColor: Colors.white,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Published'),
              subtitle: Text(
                _seoReview != null && _seoReview!.estimatedScore < 90
                    ? 'Score < 90. Publishing disabled.'
                    : (_seoReview == null ? 'Run AI Review to unlock publishing' : 'Make blog live'),
                style: TextStyle(
                  color: (_seoReview == null || _seoReview!.estimatedScore < 90)
                      ? Colors.red
                      : null,
                ),
              ),
              value: _published,
              onChanged: (_seoReview == null || _seoReview!.estimatedScore < 90)
                  ? (v) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('SEO Score must be 90+ to publish. Saved as draft.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      setState(() => _published = false);
                    }
                  : (v) => setState(() => _published = v),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('App Only Blog'),
              subtitle: const Text('Visible only inside the mobile app'),
              value: _isExclusive,
              onChanged: (v) => setState(() => _isExclusive = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            const Text(
              'Publication Date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _publishedAt,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (!mounted) return;
                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_publishedAt),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _publishedAt = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMM dd, yyyy - hh:mm a').format(_publishedAt),
                    ),
                  ],
                ),
              ),
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
                Text(
                  'dholeraplatform.com',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            _titleController.text.isEmpty
                ? 'Blog Title'
                : _titleController.text,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                'Dholera Growth Team',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              Text(
                DateFormat('dd MMM yyyy').format(_publishedAt),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const Divider(height: 32),

          // Top Image
          if (_imagePosition == 'top' &&
              (_pickedFile != null || _existingImageUrl != null)) ...[
            _buildPreviewImage(),
            const SizedBox(height: 20),
          ],

          // Content
          ..._buildFormattedContent(),

          // Bottom Image
          if (_imagePosition == 'bottom' &&
              (_pickedFile != null || _existingImageUrl != null)) ...[
            const SizedBox(height: 20),
            _buildPreviewImage(),
          ],

          const SizedBox(height: 40),
          const Center(
            child: Text(
              '--- End of Preview ---',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _pickedFile != null
          ? Image.file(
              File(_pickedFile!.path),
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.network(
              _existingImageUrl!.startsWith('http')
                  ? _existingImageUrl!
                  : 'https://api.dholeraplatform.com$_existingImageUrl',
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: Colors.blueGrey[50],
                child: const Center(
                  child: Icon(Icons.image, color: Colors.grey, size: 50),
                ),
              ),
            ),
    );
  }

  List<Widget> _buildFormattedContent() {
    final text = _contentController.text.isEmpty
        ? 'Your content will appear here...'
        : _contentController.text;
    final paragraphs = text.split('\n\n');

    return paragraphs.map((p) {
      if (p.trim().isEmpty) return const SizedBox();

      // Simple header detection (e.g. if it ends with :)
      final isHeader = p.trim().endsWith(':') || p.trim().startsWith('#');

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
