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

  static const List<String> allowedLeadStatuses = [
    'New',
    'Contacted',
    'Converted',
    'Follow-up',
    'Not Interested',
    'Closed'
  ];

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
          ListTile(
            leading: const Icon(Icons.history, color: Colors.blueGrey),
            title: const Text('Export User Sessions'),
            onTap: () {
              Navigator.pop(context);
              _exportData(ApiConfig.exportSessionsEndpoint, 'user_sessions');
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: const Text('Export PDF Metadata'),
            onTap: () {
              Navigator.pop(context);
              _exportData(ApiConfig.exportPdfsEndpoint, 'pdfs_metadata');
            },
          ),
          ListTile(
            leading: const Icon(Icons.article, color: Colors.orange),
            title: const Text('Export Blogs/Updates'),
            onTap: () {
              Navigator.pop(context);
              _exportData(ApiConfig.exportUpdatesEndpoint, 'blogs_export');
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

  Future<bool> _updateLeadStatus(int id, String status) async {
    try {
      final result = await _apiService.updateLeadStatus(id, status);
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lead status updated to $status')),
          );
        }
        return true;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['error']}')),
          );
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      return false;
    }
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
          _hasMore = newLeads.length == 20; // Assuming limit is 20
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
      appBar: AppBar(
        title: const Text('Manage Leads'),
        backgroundColor: Colors.orange,
        actions: [
          if (_isExporting)
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
          ? const Center(child: CircularProgressIndicator())
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
                    itemCount: _leads.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _leads.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: _fetchLeads,
                              child: const Text('Load More'),
                            ),
                          ),
                        );
                      }

                      final lead = _leads[index];
                      final bool isToday = lead.createdAt.day == DateTime.now().day &&
                          lead.createdAt.month == DateTime.now().month &&
                          lead.createdAt.year == DateTime.now().year;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(
                                lead.name,
                                style: TextStyle(
                                  fontWeight: lead.isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                              if (isToday) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                ),
                              ],
                              const Spacer(),
                              if (!lead.isRead)
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lead.phone),
                              Text(
                                'Source: ${lead.source} | Status: ${lead.status}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            if (!lead.isRead) {
                              await _apiService.markLeadAsRead(lead.id);
                              await _fetchLeads(refresh: true);
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    lead.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _detailRow(Icons.phone, 'Phone', lead.phone),
                  if (lead.email != null) _detailRow(Icons.email, 'Email', lead.email!),
                  
                  // Status Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 20, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Status', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              DropdownButton<String>(
                                value: allowedLeadStatuses.contains(lead.status) ? lead.status : 'New',
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: allowedLeadStatuses.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) async {
                                  if (newValue != null && newValue != lead.status) {
                                    final success = await _updateLeadStatus(lead.id, newValue);
                                    if (!context.mounted) return;
                                    if (success) {
                                      Navigator.pop(context);
                                      await _fetchLeads(refresh: true);
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  _detailRow(Icons.source, 'Source', lead.source),
                  _detailRow(Icons.timer, 'Time Spent', '${lead.timeSpent} seconds'),
                  _detailRow(Icons.calendar_today, 'Created At', 
                      DateFormat('dd MMM yyyy, hh:mm a').format(lead.createdAt)),
                  _detailRow(Icons.verified, 'Verified', lead.verified ? 'Yes' : 'No'),
                  _detailRow(Icons.repeat, 'Returning Visitor', lead.returningVisitor ? 'Yes' : 'No'),
                  _detailRow(Icons.visibility, 'Visit Count', lead.visitCount.toString()),
                  if (lead.notes != null && lead.notes!.isNotEmpty)
                    _detailRow(Icons.note, 'Notes', lead.notes!),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => launchUrl(Uri.parse('tel:${lead.phone}')),
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => launchUrl(Uri.parse('https://wa.me/91${lead.phone}')),
                        icon: const Icon(Icons.message),
                        label: const Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
