import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/lead.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  final ApiService _apiService = ApiService();
  List<Lead> _leads = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchLeads();
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendWhatsApp(String phoneNumber) async {
    // Format phone: remove non-digits, ensure country code
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (!cleanPhone.startsWith('91') && cleanPhone.length == 10) {
      cleanPhone = '91$cleanPhone';
    }
    
    final Uri whatsappUri = Uri.parse("https://wa.me/$cleanPhone");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Leads'),
        backgroundColor: Colors.orange,
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
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          title: Text(
                            lead.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lead.phone),
                              Text(
                                'Source: ${lead.source} | Status: ${lead.status}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Received: ${DateFormat('dd MMM yyyy, hh:mm a').format(lead.createdAt)}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.phone, color: Colors.green),
                                onPressed: () => _makePhoneCall(lead.phone),
                              ),
                              IconButton(
                                icon: const Icon(Icons.message, color: Colors.blue),
                                onPressed: () => _sendWhatsApp(lead.phone),
                              ),
                            ],
                          ),
                          onTap: () {
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
                  _detailRow(Icons.info_outline, 'Status', lead.status),
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
                        onPressed: () => _makePhoneCall(lead.phone),
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _sendWhatsApp(lead.phone),
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
