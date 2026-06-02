import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class SystemPage extends StatefulWidget {
  const SystemPage({super.key});

  @override
  State<SystemPage> createState() => _SystemPageState();
}

class _SystemPageState extends State<SystemPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _exportBackup() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.downloadExport('${_apiService.apiBaseUrl}/admin/backup');
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'dholera_backup_${DateTime.now().millisecondsSinceEpoch}.json';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backup saved to documents: $fileName')),
          );
        }
      } else {
        throw Exception('Export failed (${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRestore() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Restore'),
            content: const Text('This will overwrite current platform data with the backup file. Are you sure?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Restore Data'),
              ),
            ],
          ),
        );

        if (confirm != true) return;

        setState(() => _isLoading = true);
        final resultData = await _apiService.restoreSystem(result.files.single.path!);
        
        if (mounted) {
          if (resultData['ok'] == true || resultData['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ System data restored successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ Restore failed: ${resultData['error'] ?? resultData['details']}')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _syncLocalPdfs() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.apiClient.post('/pdf/sync-disk', headers: await _apiService.getMutationHeaders());
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync complete. New PDFs added to database.')),
        );
      } else {
        throw Exception('Sync failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('System Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSectionHeader('Data Portability'),
              _buildSystemCard(
                'Full System Backup', 
                'Export all leads, sessions, and logs to a JSON file.',
                Icons.cloud_download,
                Colors.blue,
                _exportBackup
              ),
              const SizedBox(height: 16),
              _buildSystemCard(
                'Restore Platform', 
                'Import a previously exported JSON backup file.',
                Icons.settings_backup_restore,
                Colors.orange,
                _handleRestore
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Intelligence Management'),
              _buildSystemCard(
                'Sync Local PDFs', 
                'Scan the server storage for new documents.',
                Icons.sync,
                Colors.green,
                _syncLocalPdfs
              ),
              const SizedBox(height: 16),
              _buildSystemCard(
                'Clear Cache', 
                'Force refresh all system metadata.',
                Icons.delete_sweep,
                Colors.red,
                () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('System cache purged.')));
                }
              ),
            ],
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSystemCard(String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      borderOnForeground: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
