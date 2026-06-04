import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/leads/leads_bloc.dart';
import '../blocs/leads/leads_event.dart';
import '../blocs/leads/leads_state.dart';
import '../models/lead.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class LeadsPage extends StatelessWidget {
  const LeadsPage({super.key});

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
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _showExportOptions(context),
            tooltip: 'Export Data',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<LeadsBloc>().add(const FetchLeadsRequested(refresh: true)),
            tooltip: 'Refresh Vault',
          ),
        ],
      ),
      body: BlocBuilder<LeadsBloc, LeadsState>(
        builder: (context, state) {
          if (state.status == LeadsStatus.loading && state.leads.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state.status == LeadsStatus.failure && state.leads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Unknown error occurred'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<LeadsBloc>().add(const FetchLeadsRequested(refresh: true)),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            );
          }

          final leads = state.leads;
          if (leads.isEmpty) {
            return const Center(child: Text('No leads found in the vault.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<LeadsBloc>().add(const FetchLeadsRequested(refresh: true));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leads.length,
              itemBuilder: (context, index) {
                final lead = leads[index];
                return _LeadCard(lead: lead);
              },
            ),
          );
        },
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Export Intelligence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: AppColors.primary),
            title: const Text('Export Leads (Excel)'),
            onTap: () {
              Navigator.pop(context);
              _exportData(context, ApiConfig.exportLeadsEndpoint, 'leads_export');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.teal),
            title: const Text('Full System Backup (JSON)'),
            subtitle: const Text('For complete database recovery'),
            onTap: () {
              Navigator.pop(context);
              _exportData(context, ApiConfig.systemBackupEndpoint, 'dholera_full_backup.json');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, String endpoint, String filename) async {
    try {
      final apiService = ApiService();
      final response = await apiService.downloadExport(endpoint);
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${filename}_${DateTime.now().millisecondsSinceEpoch}.${filename.endsWith('json') ? 'json' : 'xlsx'}';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export ready: $filename')),
          );
          await Share.shareXFiles([XFile(filePath)], text: 'Dholera Export: $filename');
        }
      } else {
        throw Exception('Failed to download export');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}

class _LeadCard extends StatelessWidget {
  final Lead lead;
  const _LeadCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.surface,
      elevation: 2,
      child: InkWell(
        onTap: () => _showLeadDetails(context, lead),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a').format(lead.createdAt),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: lead.status),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoItem(label: 'MOBILE', value: lead.phone),
                  _InfoItem(label: 'SOURCE', value: lead.source),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('tel:${lead.phone}')),
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('CALL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                         final msg = Uri.encodeComponent("Hello ${lead.name}, thank you for your interest in Dholera SIR.");
                         launchUrl(Uri.parse("https://wa.me/91${lead.phone}?text=$msg"));
                      },
                      icon: const Icon(Icons.message, size: 18),
                      label: const Text('WHATSAPP'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLeadDetails(BuildContext context, Lead lead) {
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.orange;
    if (status == 'Verified') color = Colors.green;
    if (status == 'Contacted') color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
