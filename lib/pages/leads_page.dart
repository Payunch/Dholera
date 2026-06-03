import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/lead.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../config/api_config.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  final ApiService _apiService = ApiService();
  List<Lead> _leads = [];
  bool _isLoading = true;
  bool _isExporting = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  Future<void> _exportData(String endpoint, String filename) async {
    setState(() => _isExporting = true);
    try {
      final response = await _apiService.downloadExport(endpoint);
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${filename}_${DateTime.now().millisecondsSinceEpoch}.${filename.endsWith('json') ? 'json' : 'xlsx'}';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export ready: $filename')),
          );
        }
        await Share.shareXFiles([XFile(filePath)], text: 'Dholera Export: $filename');
      } else {
        throw Exception('Failed to download export');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Export Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: AppColors.primary),
            title: const Text('Export Leads'),
            onTap: () {
              Navigator.pop(context);
              _exportData(ApiConfig.exportLeadsEndpoint, 'leads_export');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.teal),
            title: const Text('Full System Backup (JSON)'),
            subtitle: const Text('For complete system restore'),
            onTap: () {
              Navigator.pop(context);
              _exportData(ApiConfig.systemBackupEndpoint, 'dholera_full_backup.json');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _fetchLeads({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _leads = [];
        _hasMore = true;
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await _apiService.getLeads(page: _currentPage);
      if (response['success'] == true || response['leads'] != null) {
        final List<dynamic> leadsData = response['leads'] ?? [];
        final List<Lead> newLeads = Lead.fromList(leadsData);
        
        setState(() {
          _leads.addAll(newLeads);
          _isLoading = false;
          _hasMore = newLeads.length >= 20;
          _currentPage++;
        });
      } else {
        setState(() {
          _error = response['error'] ?? 'Failed to load leads';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Intelligence Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (_isExporting)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Export Options',
              onPressed: _showExportOptions,
            ),
          IconButton(onPressed: () => _fetchLeads(refresh: true), icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading && _leads.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null && _leads.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      ElevatedButton(
                        onPressed: () => _fetchLeads(refresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _fetchLeads(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _leads.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _leads.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: _fetchLeads,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textPrimary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Load More Intelligence'),
                            ),
                          ),
                        );
                      }

                      final lead = _leads[index];
                      final bool isToday = lead.createdAt.day == DateTime.now().day &&
                          lead.createdAt.month == DateTime.now().month &&
                          lead.createdAt.year == DateTime.now().year;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  lead.name,
                                  style: TextStyle(
                                    fontWeight: lead.isRead ? FontWeight.w500 : FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (lead.isPro)
                                const Icon(Icons.verified, size: 16, color: Colors.orange),
                              if (isToday) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(lead.phone, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(
                                '${lead.source} • ${lead.status} • ${(lead.timeSpent / 60).round()}m active',
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          onTap: () async {
                            if (!lead.isRead) {
                              await _apiService.markLeadAsRead(lead.id);
                            }
                            if (!mounted) return;
                            _showLeadDetails(lead);
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showLeadDetails(Lead lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2))),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lead.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                              Text('DATABASE ID: ${lead.id}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                            ],
                          ),
                        ),
                        if (lead.isPro)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.orange.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                            child: const Text('PRO', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 10)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    _sectionHeader('Contact Information'),
                    _detailItem(Icons.phone, 'Phone', lead.phone, color: Colors.green),
                    
                    const SizedBox(height: 24),
                    _sectionHeader('Intelligence Data'),
                    Row(
                      children: [
                        Expanded(child: _statBox('Active Time', '${(lead.timeSpent / 60).round()}m', Icons.timer)),
                        const SizedBox(width: 12),
                        Expanded(child: _statBox('Visits', lead.visitCount.toString(), Icons.repeat)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _detailItem(Icons.source, 'Entry Source', lead.source),
                    _detailItem(Icons.calendar_today, 'First Contact', DateFormat('dd MMM yyyy, hh:mm a').format(lead.createdAt)),
                    
                    const SizedBox(height: 24),
                    _sectionHeader('Technical Fingerprint'),
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.blueGrey[900], borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        lead.browserFingerprint ?? 'Not captured',
                        style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 10),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    _sectionHeader('User Journey (Pages)'),
                    if (lead.visitedPagesList != null && lead.visitedPagesList!.isNotEmpty)
                      ...lead.visitedPagesList!.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.description, size: 14, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(child: Text(p, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                            ],
                          ),
                        ),
                      ))
                    else
                      const Text('No page data recorded', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),

                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => launchUrl(Uri.parse('tel:${lead.phone}')),
                            icon: const Icon(Icons.phone),
                            label: const Text('CALL'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => launchUrl(Uri.parse('https://wa.me/91${lead.phone.replaceFirst('+', '')}')),
                            icon: const Icon(Icons.message),
                            label: const Text('WHATSAPP'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('CLOSE DOSSIER'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey)),
    );
  }

  Widget _statBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.orange),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: (color ?? Colors.orange).withAlpha(20), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 18, color: color ?? Colors.orange),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
