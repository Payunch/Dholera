import 'package:flutter/material.dart';
import '../../models/tp_map.dart';
import '../../services/api_service.dart';

class TpMapEditorPage extends StatefulWidget {
  final TpMap? tpMap;
  const TpMapEditorPage({super.key, this.tpMap});

  @override
  State<TpMapEditorPage> createState() => _TpMapEditorPageState();
}

class _TpMapEditorPageState extends State<TpMapEditorPage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _tpIdController;
  late TextEditingController _areaController;
  late TextEditingController _focusController;

  @override
  void initState() {
    super.initState();
    final m = widget.tpMap;
    _titleController = TextEditingController(text: m?.title);
    _tpIdController = TextEditingController(text: m?.tpId);
    _areaController = TextEditingController(text: m?.area);
    _focusController = TextEditingController(text: m?.focus);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final data = {
      'title': _titleController.text,
      'tp_id': _tpIdController.text,
      'area': _areaController.text,
      'focus': _focusController.text,
      'badges': widget.tpMap?.badges ?? [], // Keep existing badges for now
    };

    try {
      final response = await _apiService.saveTpMap(data, id: widget.tpMap?.id);
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scheme saved successfully')));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response['error']}')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tpMap == null ? 'New Scheme' : 'Edit Scheme')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_titleController, 'Scheme Title (e.g. Town Planning Scheme 1)'),
                    _buildTextField(_tpIdController, 'TP ID (e.g. tp1)'),
                    _buildTextField(_areaController, 'Area Category'),
                    _buildTextField(_focusController, 'Development Focus'),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.all(20)),
                        child: const Text('SAVE SCHEME'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
