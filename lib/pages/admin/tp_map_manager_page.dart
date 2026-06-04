import 'package:flutter/material.dart';
import '../../models/tp_map.dart';
import '../../services/api_service.dart';
import 'tp_map_editor_page.dart';

class TpMapManagerPage extends StatefulWidget {
  const TpMapManagerPage({super.key});

  @override
  State<TpMapManagerPage> createState() => _TpMapManagerPageState();
}

class _TpMapManagerPageState extends State<TpMapManagerPage> {
  final ApiService _apiService = ApiService();
  List<TpMap> _tpMaps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMaps();
  }

  Future<void> _fetchMaps() async {
    setState(() => _isLoading = true);
    final response = await _apiService.getTpMaps();
    if (response['success'] == true) {
      setState(() {
        _tpMaps = (response['tpMaps'] as List)
            .map((json) => TpMap.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TP Map Manager', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchMaps),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tpMaps.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tpMaps.length,
                  itemBuilder: (context, index) => _buildMapTile(_tpMaps[index]),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(null),
        label: const Text('NEW SCHEME'),
        icon: const Icon(Icons.map_outlined),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No schemes found.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMapTile(TpMap map) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.layers_outlined, color: Colors.indigo),
        ),
        title: Text(map.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${map.tpId.toUpperCase()} • ${map.area}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _openEditor(map)),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _deleteMap(map)),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMap(TpMap map) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scheme?'),
        content: Text('Are you sure you want to remove "${map.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final response = await _apiService.deleteTpMap(map.id!);
        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scheme deleted successfully')));
            _fetchMaps();
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
  }

  void _openEditor(TpMap? map) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TpMapEditorPage(tpMap: map)),
    );
    if (result == true) _fetchMaps();
  }
}
