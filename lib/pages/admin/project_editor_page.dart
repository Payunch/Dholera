import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../services/api_service.dart';

class ProjectEditorPage extends StatefulWidget {
  final Project? project;
  const ProjectEditorPage({super.key, this.project});

  @override
  State<ProjectEditorPage> createState() => _ProjectEditorPageState();
}

class _ProjectEditorPageState extends State<ProjectEditorPage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _slugController;
  late TextEditingController _taglineKeyController;
  late TextEditingController _descKeyController;
  late TextEditingController _plotSizesController;
  late TextEditingController _offeringController;
  late TextEditingController _roadWidthController;
  late TextEditingController _zoningController;
  late TextEditingController _statusController;
  late TextEditingController _imageController;
  String _category = 'Residential';
  bool _reraApproved = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _nameController = TextEditingController(text: p?.name);
    _slugController = TextEditingController(text: p?.slug);
    _taglineKeyController = TextEditingController(text: p?.taglineKey);
    _descKeyController = TextEditingController(text: p?.descKey);
    _plotSizesController = TextEditingController(text: p?.plotSizes);
    _offeringController = TextEditingController(text: p?.offering);
    _roadWidthController = TextEditingController(text: p?.roadWidth);
    _zoningController = TextEditingController(text: p?.zoning);
    _statusController = TextEditingController(text: p?.status);
    _imageController = TextEditingController(text: p?.image);
    _category = p?.category ?? 'Residential';
    _reraApproved = p?.reraApproved ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final data = {
      'name': _nameController.text,
      'slug': _slugController.text,
      'category': _category,
      'taglineKey': _taglineKeyController.text,
      'descKey': _descKeyController.text,
      'plotSizes': _plotSizesController.text,
      'offering': _offeringController.text,
      'roadWidth': _roadWidthController.text,
      'zoning': _zoningController.text,
      'status': _statusController.text,
      'reraApproved': _reraApproved,
      'image': _imageController.text,
    };

    // Implement create/update in ApiService
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save functionality pending API implementation.')));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'New Project' : 'Edit Project'),
        actions: [
          if (!_isLoading) IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Basic Information'),
                    _buildTextField(_nameController, 'Project Name'),
                    _buildTextField(_slugController, 'URL Slug (e.g. satyaja-bliss)'),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ['Residential', 'Commercial', 'Industrial'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _category = val!),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Localization Keys'),
                    _buildTextField(_taglineKeyController, 'Tagline Key (from translations)'),
                    _buildTextField(_descKeyController, 'Description Key (from translations)'),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Technical Specs'),
                    _buildTextField(_plotSizesController, 'Plot Sizes'),
                    _buildTextField(_offeringController, 'Offering'),
                    _buildTextField(_roadWidthController, 'Road Width'),
                    _buildTextField(_zoningController, 'Zoning'),
                    _buildTextField(_statusController, 'Development Status'),
                    SwitchListTile(
                      title: const Text('RERA Approved', style: TextStyle(fontSize: 14)),
                      value: _reraApproved,
                      onChanged: (val) => setState(() => _reraApproved = val),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Media'),
                    _buildTextField(_imageController, 'Image Path/URL'),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.all(20)),
                        child: const Text('SAVE PROJECT'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    );
  }
}
