import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;
  String? _error;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getSettings();
      if (response['success'] == true) {
        setState(() {
          _settings = response['settings'] ?? {};
          _controllers.forEach((_, controller) => controller.dispose());
          _controllers.clear();
          
          _settings.forEach((key, value) {
            _controllers[key] = TextEditingController(text: value.toString());
          });
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['error'] ?? 'Failed to load settings';
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

  Future<void> _saveSettings() async {
    final Map<String, dynamic> updates = {};
    _controllers.forEach((key, controller) {
      updates[key] = controller.text;
    });

    if (updates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No settings to save')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _apiService.updateSettings(updates);
      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully')));
        _fetchSettings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addNewSetting() {
    String newKey = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Setting Field'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Setting Name (e.g. whatsapp_number)'),
          onChanged: (value) => newKey = value.trim().toLowerCase().replaceAll(' ', '_'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (newKey.isNotEmpty) {
                setState(() {
                  _controllers[newKey] = TextEditingController();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Settings'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addNewSetting, tooltip: 'Add new field'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchSettings),
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
                      ElevatedButton(onPressed: _fetchSettings, child: const Text('Retry')),
                    ],
                  ),
                )
              : _controllers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.settings_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No settings found.', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addNewSetting,
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Setting'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: _controllers.keys.map((key) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: TextField(
                                    controller: _controllers[key],
                                    decoration: InputDecoration(
                                      labelText: key.replaceAll('_', ' ').toUpperCase(),
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _controllers[key]!.dispose();
                                            _controllers.remove(key);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _saveSettings,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                              child: const Text('SAVE ALL SETTINGS', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
